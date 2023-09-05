import { LightningElement, api, wire, track } from "lwc";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getRecord } from "lightning/uiRecordApi";
//import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import LICENSE_FIELD from "@salesforce/schema/OpportunityLineItem.LicenseType__c";
import RISK_STATUS_FIELD from "@salesforce/schema/OpportunityLineItem.RiskStatus__c";
//import checkRecordAccess from '@salesforce/apex/UtilityClass.checkRecordAccessforUser';
//Import Custom Labels
import IndiaLevyTax from "@salesforce/label/c.IndianLevyTax";
import IndianLevyMessage from "@salesforce/label/c.IndianLevyMessage";
import LicenseTypeGeneralMessage from "@salesforce/label/c.LicenseTypeGeneralMessage";
import LicenseTypeEnterpriseMessage from "@salesforce/label/c.LicenseTypeEnterpriseMessage";
import RecordTypeVal from "@salesforce/label/c.DefaultLwcRecordTypeId";
import NegativeSalesPriceError from "@salesforce/label/c.NegativeSalesPriceError";
import AddEditProdMaxUpdateProducts from "@salesforce/label/c.AddEditProdMaxUpdateProducts";

//Import logged in user related details
import strUserId from "@salesforce/user/Id";
import PROFILE_NAME_FIELD from "@salesforce/schema/User.Profile.Name";
import hasEnhancedSalesPermission from "@salesforce/customPermission/EnhancedSalesPermission";

import saveProducts from "@salesforce/apex/OpportunityEditProductControllerLWC.saveProducts";
import { showMessage, sortByArray } from "c/lwcUtility";

// Lightning Message Service and message channels
import { publish, subscribe, MessageContext } from "lightning/messageService";
import PRODUCT_FILTERS from "@salesforce/messageChannel/ProductFilters__c";
import PRODUCT_GLOBAL_VALUES from "@salesforce/messageChannel/ProductGlobalValues__c";
import SELECTED_PRODUCTS_LIST from "@salesforce/messageChannel/SelectedProductsList__c";

export default class OpportunityEditProductList extends LightningElement {
  //input parameters
  @api recordId;
  @api opsWrapper;

  //Constant values
  sortOLIByFieldName = "Product2.Name";
  sortOLIDirection = "asc";
  errorVariant = "error";
  successVariant = "success";
  toastMode = "dismissible";
  legalEntity = "Legal Entity";
  scrollAfterNItems = 5;
  oneYear = 1;
  //Variables
  error;
  licensePicklistValues;
  riskStatusPicklistValues;
  statusPicklistValues;
  isProductRiskPicklistValues;
  discountTypePicklistValues;
  oppy;
  prodAllShow = false;
  deleteWorkingIndex = -1;
  lstOPSWrapper = [];
  productFilterSubscription;
  filterValues;
  //Global Values
  productGlobalValuesSubscription;
  globalValues;
  globalProRationApplied = false;
  globalDiscStep = "Flat";
  globalDiscAmount = 0;
  label = {
    IndiaLevyTax,
    IndianLevyMessage,
    LicenseTypeEnterpriseMessage,
    LicenseTypeGeneralMessage,
    NegativeSalesPriceError,
    AddEditProdMaxUpdateProducts
  };
  //Variables related to Pagination
  pageNumber = 1;
  pageSize = 25;
  totalItemCount = 0;
  tooltipmessage = 0;
  userProfileName = "";
  deleteProdName = "";
  isModalOpen = false;
  isSalesOps = false;
  isLegalUpdated = false;
  isAdmin = false;
  autoRenewNoChanges = false;
  showSpinner = false;
  hasRemoveProductAccess = true;
  isLegalModalOpen = false;
  productsDeleted = false;
  hasOppyEditAccess = false;
  is6W = false;
  disableAmounts = false;
  showErrorMsg = false;
  firstRendered = false;

  @track workingOPSWrapperList = [];
  @track filteredOPSWrapperList = [];
  @track oldLstOPSWrapper = [];
  @track emptyProductList = true;
  @track legalProdList = [];
  //@track newRecordOptions = [];

  @wire(MessageContext) messageContext;

  //Set Picklist Values
  @wire(getPicklistValues, {
    recordTypeId: RecordTypeVal,
    fieldApiName: LICENSE_FIELD
  })
  getLicensePicklistValues(result) {
    if (result.data) {
      this.licensePicklistValues = [
        { label: "--None--", value: "", selected: true },
        ...result.data.values
      ];
    } else if (result.error) {
      this.error = result.error;
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: RecordTypeVal,
    fieldApiName: RISK_STATUS_FIELD
  })
  getRiskStatusPicklistValues(result) {
    if (result.data) {
      this.riskStatusPicklistValues = [
        { label: "--None--", value: "", selected: true },
        ...result.data.values
      ];
    } else if (result.error) {
      this.error = result.error;
    }
  }

  @wire(getRecord, {
    recordId: strUserId,
    fields: [PROFILE_NAME_FIELD]
  })
  wireuser({ error, data }) {
    if (error) {
      this.error = error;
    } else if (data) {
      this.userProfileName = data.fields.Profile.value.fields.Name.value;
      if (
        this.userProfileName.includes("Sales Ops") ||
        this.userProfileName.includes("User Support") ||
        hasEnhancedSalesPermission
      ) {
        this.isSalesOps = true;
      }
      if (
        this.userProfileName === "IHSMarkit System Admin" ||
        this.userProfileName === "System Administrator"
      ) {
        //no validation checks are required for system admins
        this.isAdmin = true;
      }
    }
  }

  get yearOptions() {
    return [
      { label: "1", value: "1" },
      { label: "2", value: "2" },
      { label: "3", value: "3" },
      { label: "4", value: "4" },
      { label: "5", value: "5" }
    ];
  }

  get prodAtRiskOptions() {
    return [
      { label: "Yes", value: "Yes" },
      { label: "No", value: "No" }
    ];
  }

  get discountTypeOptions() {
    return [
      { label: "No Discount", value: "No Discount" },
      { label: "Amount", value: "Amount" },
      { label: "Percentage", value: "Percentage" }
    ];
  }

  //Initialize values
  connectedCallback() {
    console.log("Prod: Oppy Id " + this.recordId);
    this.oppy = this.opsWrapper.oppy;
    this.is6W = this.oppy.StageName.toLowerCase().indexOf("6w") !== -1 ? true : false;
    this.hasOppyEditAccess = this.opsWrapper.hasOpportunityEditAccess;
    this.isAdmin = this.opsWrapper.isAdmin;
    this.isSalesOps = this.opsWrapper.isSalesOps;
    this.hasRemoveProductAccess = this.opsWrapper.hasRemoveProductAccess;
    this.lstOPSWrapper = JSON.parse(
      JSON.stringify(this.opsWrapper.lstOPSWrapper)
    );
    this.oldLstOPSWrapper = JSON.parse(JSON.stringify(this.lstOPSWrapper));
    //Initialized filter values
    this.filterValues = {
      searchKey: "",
      statuses: ["New", "Existing", "Lost"],
      productrisks: ["Yes", "No"],
      sortby: "Name",
      yearSelected: ["1", "2", "3", "4", "5"]
    };
    this.pageNumber = 1;
    if (this.opsWrapper.canBeProRated && this.opsWrapper.isProRated === "Yes") {
      this.globalProRationApplied = true;
    }
    this.autoRenewNoChanges =
    !this.isAdmin &&
    !this.isSalesOps &&
    this.oppy.AutoRenewal__c &&
    !this.oppy.DoesThisAutoRenewalHaveChanges__c
      ? true
      : false;
    this.disableAmounts =
      this.oppy.RecordType.DeveloperName === "Gratis" ||
      (this.autoRenewNoChanges && !this.oppy.PriceChangeOnly__c & this.is6W)
        ? true
        : false;
    this.updateLstOPSWrapper();
    this.updateStatusPickList();
    this.updateFilteredProdList();
    this.subscriptions();
    this.firstRendered = true;
  }

  //Update lstOPSWrapper to add Error flag
  updateLstOPSWrapper() {
    this.lstOPSWrapper.forEach((item)=>{
      item.showError = false;
      //IHSMUS-5172035 - Added new fields 
      item.prodFirstYearValue = item.lstOPS[0].TotalPrice__c;
      item.prodTotalPrice = this.getProdTotalPrice(item.lstOPS);
    });
  }

  //Calculate Sum of Total Price for all OPS records
  getProdTotalPrice(lstOPS) {
    let dTotalPrice = 0.0;
    for(let i = 0; i<lstOPS.length; i++) {
      dTotalPrice = parseFloat(dTotalPrice) + parseFloat(lstOPS[i].TotalPrice__c);
    }
    return dTotalPrice;
  }

  //Update Picklist options based on Opportunity Record Type
  updateStatusPickList() {
    if (this.oppy.RecordType.DeveloperName === "NewBusiness") {
      this.statusPicklistValues = [
        { value: "New", label: "New" },
        { value: "Lost", label: "Lost" }
      ];
    } else {
      this.statusPicklistValues = [
        { value: "Existing", label: "Existing" },
        { value: "Lost", label: "Lost" }
      ];
    }
  }

  //Update Product List to be displayed on screen
  updateFilteredProdList() {
    if (this.lstOPSWrapper) {
      let sSearchKeyValue = "";
      let listStatuses = [];
      let listProdRisks = [];
      let listYearSelected = [];
      let errorProducts = false;
      let sortField = "";
      this.pageNumber = 1;
      this.updateListOPSWrapper();
      //Check if Filter is applied
      if (this.filterValues) {
        if (this.filterValues.searchKey) {
          sSearchKeyValue = this.filterValues.searchKey;
        }
        if (this.filterValues.statuses) {
          listStatuses = this.filterValues.statuses;
        }
        if (this.filterValues.productrisks) {
          listProdRisks = this.filterValues.productrisks;
        }
        if (this.filterValues.sortby) {
          sortField = this.filterValues.sortby;
        }
        if (this.filterValues.yearSelected) {
          listYearSelected = this.filterValues.yearSelected;
        }
        errorProducts = this.filterValues.errorProducts;
      }
      let iNewIndex = 0;
      // Processing main List to add more fields and filter based on filter criteria
      this.filteredOPSWrapperList = this.lstOPSWrapper.flatMap(
        (item, index) => {
          let newList = {
            ...item,
            prodIndex: iNewIndex + 1,
            mainListIndex: index,
            prodCollapseId: "Collapse" + item.oppyProduct.Id + iNewIndex,
            prodId: item.oppyProduct.Id,
            prodDtlShow: false,
            prodStatusReadOnly:
              (item.status === "New" &&
                this.oppy.RecordType.DeveloperName !== "NewBusiness"),
            Name: item.oppyProduct.Product2.Name,
            MaterialCode__c: item.oppyProduct.MaterialCode__c,
            prorationApplied:
              this.globalProRationApplied &&
              item.oppyProduct.Product2.AAG__c === "Subscription"
                ? true
                : false,
            discountPrcReadOnly:
              (item.discountType !== "Percentage" || this.disableAmounts)
                ? true
                : false,
            discountAmtReadOnly:
              (item.discountType !== "Amount" || this.disableAmounts)
                ? true
                : false,
            disableIsProdAtRisk: item.status !== "Existing" ? true : false,
            disableRiskStatus:
              item.oppyProduct.IsProductatRisk__c === "No" ? true : false,
            disableDelete:
              this.hasOppyEditAccess && item.status !== "New" ? true : false,
            isInactiveProduct: item.oppyProduct.Product2.IsActive
              ? false
              : true,
            showLTEnterpriseMessage:
              item.oppyProduct.Product2.Division__c !== "Financial Services" &&
              item.oppyProduct.Product2.Division__c !== "OSTTRA" &&
              item.oppyProduct.LicenseType__c === "Enterprise Wide License"
                ? true
                : false,
            showLTGeneralMessage:
              item.oppyProduct.Product2.Division__c !== "Financial Services" &&
              item.oppyProduct.Product2.Division__c !== "OSTTRA" &&
              (item.oppyProduct.LicenseType__c === "Customer License" ||
              item.oppyProduct.LicenseType__c === "Divisional License" ||
              item.oppyProduct.LicenseType__c === "Departmental License" ||
              item.oppyProduct.LicenseType__c === "User License" ||
              item.oppyProduct.LicenseType__c === "Site License")
                ? true
                : false
          };
          newList.oppyProduct.IsProductatRisk__c = newList.oppyProduct
            .IsProductatRisk__c
            ? newList.oppyProduct.IsProductatRisk__c
            : "No";
          newList.oppyProduct.IsProRated__c = newList.oppyProduct.IsProRated__c
            ? newList.oppyProduct.IsProRated__c
            : "No";
          //Check if Product is satisfying filter conditions
          if (
            (!sSearchKeyValue ||
              item.oppyProduct.Product2.Name.toLowerCase().includes(
                sSearchKeyValue.toLowerCase()
              ) ||
              item.oppyProduct.MaterialCode__c.includes(sSearchKeyValue)) &&
            listStatuses.includes(item.status) &&
            listProdRisks.includes(item.oppyProduct.IsProductatRisk__c) &&
            listYearSelected.includes(item.productTermSelected) &&
            !item.isDeleted && (!errorProducts ||(errorProducts && item.showError))
          ) {
            iNewIndex++;
            return [newList];
          } else {
            return [];
          }
        }
      );

      this.filteredOPSWrapperList = JSON.parse(
        JSON.stringify(this.filteredOPSWrapperList)
      );

      if (sortField) {
        //Sort Array based on sort
        const cloneRecords = [...this.filteredOPSWrapperList];
        cloneRecords.sort(sortByArray(sortField, 1));
        this.filteredOPSWrapperList = cloneRecords;
        this.filteredOPSWrapperList.forEach((item, index) => {
          this.filteredOPSWrapperList[index].prodIndex = index + 1;
          this.filteredOPSWrapperList[index].prodCollapseId =
            "Collapse" + item.oppyProduct.Id + index;
        });
      }
      this.calculateProRationforAll();

      this.emptyProductList = (this.filteredOPSWrapperList.length == 0);
      this.totalItemCount = this.filteredOPSWrapperList.length;
      this.updateWorkingProdList();
    }
  }

  //Update Working List to display Products only on current page
  updateWorkingProdList() {
    let iNewIndex = 0;
    let iProdDtlShow = 0;
    let fromItemNbr = this.pageSize * (this.pageNumber - 1); //20
    let toItemNbr = this.pageSize * this.pageNumber; //30
    this.workingOPSWrapperList = this.filteredOPSWrapperList.flatMap(
      (item, index) => {
        let newList = {
          ...item,
          filterListIndex: index,
          workingIndex: iNewIndex
        };
        if (index >= fromItemNbr && index < toItemNbr) {
          newList.prodIndex = index + 1;
          if (item.prodDtlShow) {
            iProdDtlShow++;
          }
          newList.prodCollapseId = "Collapse" + item.oppyProduct.Id + iNewIndex;
          iNewIndex++;
          return [newList];
        } else {
          return [];
        }
      }
    );
    if (iProdDtlShow == 0 || iNewIndex > iProdDtlShow) {
      this.prodAllShow = false;
    } else {
      this.prodAllShow = true;
    }
  }

  //Changes made in Filter List should be updated in lstOPSWrapper
  updateListOPSfromFilter() {
    if (this.filteredOPSWrapperList && this.filteredOPSWrapperList.length > 0) {
      this.filteredOPSWrapperList.forEach((item) => {
        let prdIndex = item.mainListIndex;
        this.lstOPSWrapper[prdIndex].oppyProduct = item.oppyProduct;
        this.lstOPSWrapper[prdIndex].lstOPS = item.lstOPS;
        this.lstOPSWrapper[prdIndex].isDeleted = item.isDeleted;
        this.lstOPSWrapper[prdIndex].discountType = item.discountType;
        this.lstOPSWrapper[prdIndex].productTermSelected =
          item.productTermSelected;
        this.lstOPSWrapper[prdIndex].status = item.status;
        this.lstOPSWrapper[prdIndex].showError = item.showError;
        this.lstOPSWrapper[prdIndex].productQty = item.productQty;
        this.lstOPSWrapper[prdIndex].isIndianLevyProd = item.isIndianLevyProd;
        //Update list OPS with status and discount Type from Oppy Product level
        let tempOPSList = this.lstOPSWrapper[prdIndex].lstOPS;
        if (
          this.lstOPSWrapper[prdIndex].lstOPS &&
          this.lstOPSWrapper[prdIndex].lstOPS.length > 0
        ) {
          this.lstOPSWrapper[prdIndex].lstOPS = tempOPSList.map((opsItem) => {
            opsItem.Status__c = item.status;
            opsItem.DiscountType__c = item.discountType;
            return opsItem;
          });
        }
      });
    }
  }

  //Changes made in Working List should be updated in lstOPSWrapper
  updateListOPSWrapper() {
    if (this.workingOPSWrapperList && this.workingOPSWrapperList.length > 0) {
      this.workingOPSWrapperList.forEach((item) => {
        let prdIndex = item.mainListIndex;
        //let prdIndex = this.lstOPSWrapper.findIndex((prod) => prod.oppyProduct.Id === item.oppyProduct.Id);
        //let prdFilterIndex = this.filteredOPSWrapperList.findIndex((prod) => prod.oppyProduct.Id === item.oppyProduct.Id);
        this.filteredOPSWrapperList[item.filterListIndex] = item;
        this.lstOPSWrapper[prdIndex].oppyProduct = item.oppyProduct;
        this.lstOPSWrapper[prdIndex].lstOPS = item.lstOPS;
        this.lstOPSWrapper[prdIndex].isDeleted = item.isDeleted;
        this.lstOPSWrapper[prdIndex].discountType = item.discountType;
        this.lstOPSWrapper[prdIndex].productTermSelected = item.productTermSelected;
        this.lstOPSWrapper[prdIndex].status = item.status;
        this.lstOPSWrapper[prdIndex].showError = item.showError;
        this.lstOPSWrapper[prdIndex].productQty = item.productQty;
        this.lstOPSWrapper[prdIndex].isIndianLevyProd = item.isIndianLevyProd;
        //Update list OPS with status and discount Type from Oppy Product level
        let tempOPSList = this.lstOPSWrapper[prdIndex].lstOPS;
        if (
          this.lstOPSWrapper[prdIndex].lstOPS &&
          this.lstOPSWrapper[prdIndex].lstOPS.length > 0
        ) {
          this.lstOPSWrapper[prdIndex].lstOPS = tempOPSList.map((opsItem) => {
            opsItem.Status__c = item.status;
            opsItem.DiscountType__c = item.discountType;
            return opsItem;
          });
        }
      });
    }
  }

  // Calculate ProRated values for all subscription Products
  calculateProRationforAll() {
    this.filteredOPSWrapperList.forEach((item, index, prodList) => {
      if (
        this.globalProRationApplied &&
        item.oppyProduct.Product2.AAG__c === "Subscription"
      ) {
        prodList[index].showError = false;
        prodList[index].lstOPS.forEach((ops, opsIndex, opsList) => {
          let discAmount = 0;
          let indianLevy = 0;
          let annualUnitPrice = 0;
          if (
            opsList[opsIndex].AnnualizedUnitPrice__c &&
            opsList[opsIndex].AnnualizedUnitPrice__c >= 0
          ) {
            annualUnitPrice = opsList[opsIndex].AnnualizedUnitPrice__c;
          }
          if (item.discountType === "Amount") {
            discAmount = opsList[opsIndex].AnnualizedDiscountAmount__c;
          }
          if (item.discountType === "Percentage") {
            discAmount = parseFloat(
              (opsList[opsIndex].AnnualizedDiscountPercent__c *
                annualUnitPrice) /
                100
            ).toFixed(2);
          }
          let annualSalesPrice = annualUnitPrice - discAmount;

          if (annualSalesPrice < 0) {
            this.showError();
            this.showErrorMsg = true;
            prodList[index].showError = true;
          }

          if (item.isIndianLevyProd) {
            let indianLevyTax = this.label.IndiaLevyTax;
            indianLevy = parseFloat(
              (annualSalesPrice * indianLevyTax) / 100
            ).toFixed(2);
          }
          annualSalesPrice =
            parseFloat(annualSalesPrice) + parseFloat(indianLevy);
          opsList[opsIndex].AnnualizedTotalAmount__c = parseFloat(
            annualSalesPrice * opsList[opsIndex].Quantity__c
          ).toFixed(2);

          //ProRated Amount Calculations
          let unitPrice = parseFloat(
            (annualUnitPrice / 360) * item.proRatedDays
          ).toFixed(2);
          let discount = parseFloat(
            (discAmount / 360) * item.proRatedDays
          ).toFixed(2);
          let discountPercent = 0.0;
          if (unitPrice == 0.0 || unitPrice == null) {
            discountPercent = 0.0;
          } else {
            discountPercent = parseFloat((discount / unitPrice) * 100).toFixed(
              2
            );
          }
          let salesPrice = unitPrice - discount;

          if (item.isIndianLevyProd) {
            let indianLevyTax = this.label.IndiaLevyTax;
            indianLevy = parseFloat((salesPrice * indianLevyTax) / 100).toFixed(
              2
            );
          }
          salesPrice = parseFloat(salesPrice) + parseFloat(indianLevy);
          opsList[opsIndex].DiscountAmount__c = discount;
          opsList[opsIndex].DiscountPercent__c = discountPercent;
          opsList[opsIndex].SalesPrice__c = salesPrice;
          opsList[opsIndex].TotalPrice__c = parseFloat(
            salesPrice * opsList[opsIndex].Quantity__c
          ).toFixed(2);
          opsList[opsIndex].ExternalListPrice__c =
            parseFloat(unitPrice) + parseFloat(indianLevy);
          prodList[index].oppyProduct.IsProRated__c = "Yes";
        });
      }
      prodList[index].prodFirstYearValue = prodList[index].lstOPS[0].TotalPrice__c;
      prodList[index].prodTotalPrice = this.getProdTotalPrice(prodList[index].lstOPS);
    });
  }

  //Revert Proration with Indian Levy if applied earlier
  revertProRationChanges() {
    this.filteredOPSWrapperList.forEach((item, index, prodList) => {
      if (item.oppyProduct.Product2.AAG__c === "Subscription") {
        prodList[index].showError = false;
        prodList[index].oppyProduct.IsProRated__c = "No";
        prodList[index].lstOPS.forEach((ops, opsIndex, opsList) => {
          //Set ExternalListPrice back without Indian Levy if applied
          if (ops.SalesPrice__c < 0) {
            this.showError();
            this.showErrorMsg = true;
            prodList[index].showError = true;
          }
          if (item.isIndianLevyProd) {
            let indianLevyTax = this.label.IndiaLevyTax;
            let dividingFactor = parseFloat(1 + indianLevyTax / 100).toFixed(2);
            if (ops.SalesPrice__c && ops.SalesPrice__c > 0) {
              opsList[opsIndex].ExternalListPrice__c = (
                parseFloat(ops.SalesPrice__c / dividingFactor) +
                parseFloat(ops.DiscountAmount__c)
              ).toFixed(2);
            }
          }
        });
      }
    });
  }

  // Subscribe to the different Message Channels
  subscriptions() {
    // Subscribe to ProductsFiltered message
    this.productFilterSubscription = subscribe(
      this.messageContext,
      PRODUCT_FILTERS,
      (message) => this.handleFilterChange(message)
    );

    // Subscribe to ProductsGlobalValue message
    this.productGlobalValuesSubscription = subscribe(
      this.messageContext,
      PRODUCT_GLOBAL_VALUES,
      (message) => this.handleGlobalValuesChange(message)
    );
  }

  //Collapse or Expand Individual Product Details
  collapseDtl(event) {
    if (event.currentTarget.dataset.id) {
      let collapseProdId = event.currentTarget.dataset.id;
      let n = 18;
      let prodIndex = Number(
        collapseProdId.replace("Collapse", "").substring(n)
      );

      if (this.workingOPSWrapperList[prodIndex].prodDtlShow === true) {
        this.workingOPSWrapperList[prodIndex].prodDtlShow = false;
      } else {
        this.workingOPSWrapperList[prodIndex].prodDtlShow = true;
      }
      //Set Exapnd All or Collapse All based on products displayed
      let iProdCount = 0;
      let iProdDtlShow = 0;
      this.workingOPSWrapperList.forEach((item) => {
        iProdCount++;
        if (item.prodDtlShow) {
          iProdDtlShow++;
        }
      });
      if (iProdDtlShow == 0 || iProdDtlShow < iProdCount) {
        this.prodAllShow = false;
      } else {
        this.prodAllShow = true;
      }
    }
  }

  //Collapse or Expand all Product Details
  collapseAll(event) {
    if (event.currentTarget.dataset.id) {
      this.prodAllShow = !this.prodAllShow;
      this.workingOPSWrapperList.forEach((item, index) => {
        if (this.prodAllShow === true) {
          this.workingOPSWrapperList[index].prodDtlShow = true;
        } else {
          this.workingOPSWrapperList[index].prodDtlShow = false;
        }
      });
    }
  }

  //Delete Product from List
  deleteProd(event) {
    let prodIndx = event.currentTarget.dataset.id;
    if (prodIndx) {
      this.deleteWorkingIndex = prodIndx;
      this.deleteProdName =
        this.workingOPSWrapperList[prodIndx].oppyProduct.Product2.Name;
      this.isModalOpen = true;
    }
  }

  // User confirmed for deleting the Product
  deleteProdConfirmed() {
    if (this.deleteWorkingIndex !== -1) {
      this.isModalOpen = false;
      this.workingOPSWrapperList[this.deleteWorkingIndex].isDeleted = true;
      this.deleteWorkingIndex = -1;
      this.isLegalUpdated = false;
      this.updateFilteredProdList();
    }
  }

  // to close modal set isModalOpen tarck value as false
  closeModal() {
    this.isModalOpen = false;
  }

  // to close modal set isLegalModalOpen tarck value as false
  closeLegalModal(event) {
    let legalEntityName = "";
    if (!event || !event.target || event.target.dataset.id !== "CloseModal") {
      this.isLegalUpdated = true;
      if (event.detail.legalEntityName) {
        legalEntityName = event.detail.legalEntityName;
      }
      this.saveUpdatedProducts();
    }
    this.isLegalModalOpen = false;
    this.stopSpinnerEvent(legalEntityName);
  }

  //Receive Fitlers selected by User and refine Product List
  handleFilterChange(message) {
    this.filterValues = message.prodFilters;
    this.updateFilteredProdList();
  }

  //Receive GLobal Values selected by User and Apply it on the filtered Product List
  handleGlobalValuesChange(message) {
    this.updateListOPSWrapper();
    this.hideError();
    this.globalValues = message.prodGlobalValues;
    this.filteredOPSWrapperList.forEach((item, index) => {
      this.filteredOPSWrapperList[index].showError = false;
      let sLicenseType = '';
      switch (this.globalValues.fieldName) {
        case "Proration":
          this.filteredOPSWrapperList[index].prorationApplied =
            this.globalValues.fieldValue === "Yes" &&
            item.oppyProduct.Product2.AAG__c === "Subscription"
              ? true
              : false;
          this.globalProRationApplied =
            this.globalValues.fieldValue === "Yes" ? true : false;
          if (this.globalProRationApplied) {
            this.onGlobalProrationYearUpdate();
            this.calculateProRationforAll();
          } else {
            this.revertProRationChanges();
          }
          item.prodFirstYearValue = item.lstOPS[0].TotalPrice__c;
          item.prodTotalPrice = this.getProdTotalPrice(item.lstOPS);    
          break;
        case "LicenseType":
          sLicenseType = this.globalValues.fieldValue;
          this.filteredOPSWrapperList[index].oppyProduct.LicenseType__c =
            this.globalValues.fieldValue;
          this.filteredOPSWrapperList[index].showLTEnterpriseMessage =
            this.filteredOPSWrapperList[index].oppyProduct.Product2
              .Division__c !== "Financial Services" &&
            this.filteredOPSWrapperList[index].oppyProduct.Product2
              .Division__c !== "OSTTRA" &&
            sLicenseType === "Enterprise Wide License"
              ? true
              : false;
          this.filteredOPSWrapperList[index].showLTGeneralMessage =
            this.filteredOPSWrapperList[index].oppyProduct.Product2
              .Division__c !== "Financial Services" &&
            this.filteredOPSWrapperList[index].oppyProduct.Product2
              .Division__c !== "OSTTRA" &&
            (sLicenseType === "Customer License" ||
            sLicenseType === "Divisional License" ||
            sLicenseType === "Departmental License" ||
            sLicenseType === "User License" ||
            sLicenseType === "Site License")
              ? true
              : false;
          this.udpateFilterProductError(index);
          break;
        case "DiscountType":
          this.updateOPSDiscAmount(0.0, index);
          this.filteredOPSWrapperList[index].discountType =
            this.globalValues.fieldValue;
          this.filteredOPSWrapperList[index].discountPrcReadOnly =
            this.globalValues.fieldValue === "Percentage" ? false : true;
          this.filteredOPSWrapperList[index].discountAmtReadOnly =
            this.globalValues.fieldValue === "Amount" ? false : true;
          break;
        case "DiscountStep":
          this.globalDiscStep = this.globalValues.fieldValue;
          this.updateOPSDiscAmount(this.globalDiscAmount, index);
          if (item.lstOPS) {
            item.lstOPS.forEach((opsItem) => {
              if (
                (this.filteredOPSWrapperList[index].prorationApplied &&
                  opsItem.AnnualizedTotalAmount__c < 0) ||
                opsItem.SalesPrice__c < 0
              ) {
                this.showError();
                this.showErrorMsg = true;
                this.filteredOPSWrapperList[index].showError = true;
              }
            });
          }
          item.prodFirstYearValue = item.lstOPS[0].TotalPrice__c;
          item.prodTotalPrice = this.getProdTotalPrice(item.lstOPS);    
          break;
        case "DiscountValue":
          this.globalDiscAmount = this.globalValues.fieldValue;
          this.updateOPSDiscAmount(this.globalValues.fieldValue, index);
          if (item.lstOPS) {
            item.lstOPS.forEach((opsItem) => {
              if (
                (this.filteredOPSWrapperList[index].prorationApplied &&
                  opsItem.AnnualizedTotalAmount__c < 0) ||
                opsItem.SalesPrice__c < 0
              ) {
                this.showError();
                this.showErrorMsg = true;
                this.filteredOPSWrapperList[index].showError = true;
              }
            });
          }
          item.prodFirstYearValue = item.lstOPS[0].TotalPrice__c;
          item.prodTotalPrice = this.getProdTotalPrice(item.lstOPS);   
          break;
        case "Uplift":
          if (!item.prorationApplied) {
            this.applyGlobalUplift(this.globalValues.fieldValue, index);
          }
          item.prodFirstYearValue = item.lstOPS[0].TotalPrice__c;
          item.prodTotalPrice = this.getProdTotalPrice(item.lstOPS);    
          break;
        case "Years":
          this.onGlobalTermChange(this.globalValues.fieldValue);
          item.prodFirstYearValue = item.lstOPS[0].TotalPrice__c;
          item.prodTotalPrice = this.getProdTotalPrice(item.lstOPS);    
          break;
        case "ProdAtRisk":
          if (this.globalValues.fieldValue && item.status === "Existing") {
            this.filteredOPSWrapperList[index].oppyProduct.IsProductatRisk__c =
              "Yes";
            this.filteredOPSWrapperList[index].disableRiskStatus = false;
          } else {
            this.filteredOPSWrapperList[index].oppyProduct.IsProductatRisk__c =
              "No";
            this.filteredOPSWrapperList[index].disableRiskStatus = true;
            this.filteredOPSWrapperList[index].oppyProduct.EstimatedValueatRisk__c = null;
          }
          break;
        case "RiskStatus":
          this.filteredOPSWrapperList[index].oppyProduct.RiskStatus__c =
            this.globalValues.fieldValue;
          break;
        case "Probability":
          if (
            this.globalValues.fieldValue < 0 ||
            this.globalValues.fieldValue > 100
          ) {
            this.showError();
            this.filteredOPSWrapperList[index].showError = true;
          } else {
            this.filteredOPSWrapperList[index].oppyProduct.Probability__c =
              this.globalValues.fieldValue;
          }
          break;
        default:
          break;
      }
    });
    this.updateListOPSfromFilter();
    this.updateWorkingProdList();
  }

  //Update Discount value for all Products
  updateOPSDiscAmount(discVal, prodIndex) {
    let discAmount = 0;
    let stepCounter = 1;
    let stepDownCounter = this.filteredOPSWrapperList[prodIndex].lstOPS.length;
    let stepDownDiscount = discVal / stepDownCounter;
    this.filteredOPSWrapperList[prodIndex].lstOPS.forEach((ops, opsIndex) => {
      let calculatedDiscount;
      calculatedDiscount = parseFloat(discVal * stepCounter).toFixed(2);
      if (this.globalDiscStep === "Step down") {
        calculatedDiscount = parseFloat(
          stepDownDiscount * stepDownCounter--
        ).toFixed(2);
      }

      if (this.filteredOPSWrapperList[prodIndex].prorationApplied) {
        if (this.filteredOPSWrapperList[prodIndex].discountType === "Amount") {
          this.filteredOPSWrapperList[prodIndex].lstOPS[
            opsIndex
          ].AnnualizedDiscountAmount__c = calculatedDiscount;
          if (
            !this.filteredOPSWrapperList[prodIndex].lstOPS[opsIndex]
              .AnnualizedUnitPrice__c ||
            this.filteredOPSWrapperList[prodIndex].lstOPS[opsIndex]
              .AnnualizedUnitPrice__c == 0
          ) {
            this.filteredOPSWrapperList[prodIndex].lstOPS[
              opsIndex
            ].AnnualizedDiscountPercent__c = 0;
          } else {
            this.filteredOPSWrapperList[prodIndex].lstOPS[
              opsIndex
            ].AnnualizedDiscountPercent__c = parseFloat(
              (calculatedDiscount /
                this.filteredOPSWrapperList[prodIndex].lstOPS[opsIndex]
                  .AnnualizedUnitPrice__c) *
                100
            ).toFixed(2);
          }
          discAmount = calculatedDiscount;
        } else if (
          this.filteredOPSWrapperList[prodIndex].discountType === "Percentage"
        ) {
          this.filteredOPSWrapperList[prodIndex].lstOPS[
            opsIndex
          ].AnnualizedDiscountPercent__c = calculatedDiscount;
          this.filteredOPSWrapperList[prodIndex].lstOPS[
            opsIndex
          ].AnnualizedDiscountAmount__c = parseFloat(
            (calculatedDiscount *
              this.filteredOPSWrapperList[prodIndex].lstOPS[opsIndex]
                .AnnualizedUnitPrice__c) /
              100
          ).toFixed(2);
          discAmount = parseFloat(
            (calculatedDiscount *
              this.filteredOPSWrapperList[prodIndex].lstOPS[opsIndex]
                .AnnualizedUnitPrice__c) /
              100
          ).toFixed(2);
        }
        this.calculateProrationValuesforGlobal(discAmount, prodIndex, opsIndex);
      } else {
        if (this.filteredOPSWrapperList[prodIndex].discountType === "Amount") {
          this.filteredOPSWrapperList[prodIndex].lstOPS[
            opsIndex
          ].DiscountAmount__c = calculatedDiscount;
          if (
            !this.filteredOPSWrapperList[prodIndex].lstOPS[opsIndex]
              .ExternalListPrice__c ||
            this.filteredOPSWrapperList[prodIndex].lstOPS[opsIndex]
              .ExternalListPrice__c == 0
          ) {
            this.filteredOPSWrapperList[prodIndex].lstOPS[
              opsIndex
            ].DiscountPercent__c = 0;
          } else {
            this.filteredOPSWrapperList[prodIndex].lstOPS[
              opsIndex
            ].DiscountPercent__c = parseFloat(
              (calculatedDiscount /
                this.filteredOPSWrapperList[prodIndex].lstOPS[opsIndex]
                  .ExternalListPrice__c) *
                100
            ).toFixed(2);
          }
          discAmount = calculatedDiscount;
        } else if (
          this.filteredOPSWrapperList[prodIndex].discountType === "Percentage"
        ) {
          this.filteredOPSWrapperList[prodIndex].lstOPS[
            opsIndex
          ].DiscountPercent__c = calculatedDiscount;
          this.filteredOPSWrapperList[prodIndex].lstOPS[
            opsIndex
          ].DiscountAmount__c = parseFloat(
            (calculatedDiscount *
              this.filteredOPSWrapperList[prodIndex].lstOPS[opsIndex]
                .ExternalListPrice__c) /
              100
          ).toFixed(2);
          discAmount = parseFloat(
            (calculatedDiscount *
              this.filteredOPSWrapperList[prodIndex].lstOPS[opsIndex]
                .ExternalListPrice__c) /
              100
          ).toFixed(2);
        }
        this.calculateTotalValueforGlobal(discAmount, prodIndex, opsIndex);
      }
      if (this.globalDiscStep.indexOf("Step") >= 0) {
        stepCounter++;
      }
    });
  }

  //Calculate values for specific OPS record
  calculateTotalValueforGlobal(discAmount, prodIndex, opsIndex) {
    let indianLevy = 0;
    let salesPrice = 0;
    if (
      this.filteredOPSWrapperList[prodIndex].lstOPS[opsIndex]
        .ExternalListPrice__c &&
      this.filteredOPSWrapperList[prodIndex].lstOPS[opsIndex]
        .ExternalListPrice__c >= 0
    ) {
      salesPrice =
        this.filteredOPSWrapperList[prodIndex].lstOPS[opsIndex]
          .ExternalListPrice__c;
    }
    salesPrice = salesPrice - discAmount;

    if (this.filteredOPSWrapperList[prodIndex].isIndianLevyProd) {
      let indianLevyTax = this.label.IndiaLevyTax;
      indianLevy = parseFloat((salesPrice * indianLevyTax) / 100).toFixed(2);
    }
    salesPrice = parseFloat(salesPrice) + parseFloat(indianLevy);
    this.filteredOPSWrapperList[prodIndex].lstOPS[opsIndex].SalesPrice__c =
      salesPrice;
    this.filteredOPSWrapperList[prodIndex].lstOPS[opsIndex].TotalPrice__c =
      parseFloat(
        salesPrice *
          this.filteredOPSWrapperList[prodIndex].lstOPS[opsIndex].Quantity__c
      ).toFixed(2);
  }

  //Calculate ProRation Amount for specific OPS record
  calculateProrationValuesforGlobal(discAmount, prodIndex, opsIndex) {
    let indianLevy = 0;
    let annualUnitPrice = 0;
    let isProRation = this.filteredOPSWrapperList[prodIndex].prorationApplied;
    let proRatedDays = this.filteredOPSWrapperList[prodIndex].proRatedDays;
    if (isProRation && proRatedDays !== 360 && proRatedDays < 720) {
      if (
        this.filteredOPSWrapperList[prodIndex].lstOPS[opsIndex]
          .AnnualizedUnitPrice__c &&
        this.filteredOPSWrapperList[prodIndex].lstOPS[opsIndex]
          .AnnualizedUnitPrice__c >= 0
      ) {
        annualUnitPrice =
          this.filteredOPSWrapperList[prodIndex].lstOPS[opsIndex]
            .AnnualizedUnitPrice__c;
      }
      let annualSalesPrice = annualUnitPrice - discAmount;

      if (this.filteredOPSWrapperList[prodIndex].isIndianLevyProd) {
        let indianLevyTax = this.label.IndiaLevyTax;
        indianLevy = parseFloat(
          (annualSalesPrice * indianLevyTax) / 100
        ).toFixed(2);
      }
      annualSalesPrice = parseFloat(annualSalesPrice) + parseFloat(indianLevy);
      this.filteredOPSWrapperList[prodIndex].lstOPS[
        opsIndex
      ].AnnualizedTotalAmount__c = parseFloat(
        annualSalesPrice *
          this.filteredOPSWrapperList[prodIndex].lstOPS[opsIndex].Quantity__c
      ).toFixed(2);

      //ProRated Amount Calculations
      let unitPrice = parseFloat(
        (annualUnitPrice / 360) * proRatedDays
      ).toFixed(2);
      let discount = parseFloat((discAmount / 360) * proRatedDays).toFixed(2);
      let discountPercent = 0.0;
      if (unitPrice == 0.0 || unitPrice == null) {
        discountPercent = 0.0;
      } else {
        discountPercent = parseFloat((discount / unitPrice) * 100).toFixed(2);
      }
      let salesPrice = unitPrice - discount;
      if (this.filteredOPSWrapperList[prodIndex].isIndianLevyProd) {
        let indianLevyTax = this.label.IndiaLevyTax;
        indianLevy = parseFloat((salesPrice * indianLevyTax) / 100).toFixed(2);
      }
      salesPrice = parseFloat(salesPrice) + parseFloat(indianLevy);
      this.filteredOPSWrapperList[prodIndex].lstOPS[
        opsIndex
      ].DiscountAmount__c = discount;
      this.filteredOPSWrapperList[prodIndex].lstOPS[
        opsIndex
      ].DiscountPercent__c = discountPercent;
      this.filteredOPSWrapperList[prodIndex].lstOPS[opsIndex].SalesPrice__c =
        salesPrice;
      this.filteredOPSWrapperList[prodIndex].lstOPS[opsIndex].TotalPrice__c =
        parseFloat(
          salesPrice *
            this.filteredOPSWrapperList[prodIndex].lstOPS[opsIndex].Quantity__c
        ).toFixed(2);
      this.filteredOPSWrapperList[prodIndex].lstOPS[
        opsIndex
      ].ExternalListPrice__c = parseFloat(unitPrice) + parseFloat(indianLevy);
      this.filteredOPSWrapperList[prodIndex].oppyProduct.IsProRated__c = "Yes";
      this.filteredOPSWrapperList[prodIndex].prodFirstYearValue = this.filteredOPSWrapperList[prodIndex].lstOPS[0].TotalPrice__c;
      this.filteredOPSWrapperList[prodIndex].prodTotalPrice = this.getProdTotalPrice(this.filteredOPSWrapperList[prodIndex].lstOPS);    
    }
  }

  //apply Uplift percentage on External List price for all Products
  applyGlobalUplift(upliftpercent, prodIndex) {
    let year = 1;
    let previousListPrice = 0;
    let discAmt = 0;
    let salesPrice = 0;
    let indianLevy = 0;
    this.filteredOPSWrapperList[prodIndex].lstOPS.forEach((ops, opsIndex) => {
      let percentIncrease = 0.0;
      if (year > 1) {
        percentIncrease = parseFloat(
          (upliftpercent * previousListPrice) / 100
        ).toFixed(2);
        this.filteredOPSWrapperList[prodIndex].lstOPS[
          opsIndex
        ].ExternalListPrice__c =
          parseFloat(previousListPrice) + parseFloat(percentIncrease);
        discAmt =
          this.filteredOPSWrapperList[prodIndex].lstOPS[opsIndex]
            .DiscountAmount__c;
        salesPrice =
          parseFloat(previousListPrice) + parseFloat(percentIncrease);

        salesPrice = salesPrice - discAmt;

        if (this.filteredOPSWrapperList[prodIndex].isIndianLevyProd) {
          let indianLevyTax = this.label.IndiaLevyTax;
          indianLevy = parseFloat((salesPrice * indianLevyTax) / 100).toFixed(
            2
          );
        }
        salesPrice = parseFloat(salesPrice) + parseFloat(indianLevy);
        this.filteredOPSWrapperList[prodIndex].lstOPS[opsIndex].SalesPrice__c =
          salesPrice;
        this.filteredOPSWrapperList[prodIndex].lstOPS[opsIndex].TotalPrice__c =
          parseFloat(
            salesPrice *
              this.filteredOPSWrapperList[prodIndex].lstOPS[opsIndex]
                .Quantity__c
          ).toFixed(2);
      }
      previousListPrice =
        this.filteredOPSWrapperList[prodIndex].lstOPS[opsIndex]
          .ExternalListPrice__c;
      year++;
    });
  }

  //Update Years to 1 for Prorated products
  onGlobalProrationYearUpdate() {
    this.filteredOPSWrapperList.forEach((item, index) => {
      let mapProductSchedulesAll = item.mapOPSAll;
      if (
        item.oppyProduct.Product2.AAG__c === "Subscription" &&
        this.globalProRationApplied
      ) {
        if (mapProductSchedulesAll[this.oneYear]) {
          this.filteredOPSWrapperList[index].lstOPS =
            mapProductSchedulesAll[this.oneYear];
          this.filteredOPSWrapperList[index].productTermSelected =
            this.oneYear.toString();
        }
      }
    });
  }

  //Handle Global Term value change
  onGlobalTermChange(globalYear) {
    //Logic may need to revisit to handle existing Discount amount or values on OPS
    this.filteredOPSWrapperList.forEach((item, index) => {
      let mapProductSchedulesAll = item.mapOPSAll;
      if (
        item.oppyProduct.Product2.AAG__c === "Subscription" &&
        this.globalProRationApplied
      ) {
        if (mapProductSchedulesAll[this.oneYear]) {
          this.filteredOPSWrapperList[index].lstOPS =
            mapProductSchedulesAll[this.oneYear];
          this.filteredOPSWrapperList[index].productTermSelected =
            this.oneYear.toString();
        }
      } else {
        if (mapProductSchedulesAll[globalYear]) {
          this.filteredOPSWrapperList[index].lstOPS =
            mapProductSchedulesAll[globalYear];
          this.filteredOPSWrapperList[index].productTermSelected =
            globalYear.toString();
        } else {
          for (let i = 5; i > 0; i--) {
            if (mapProductSchedulesAll[i]) {
              this.filteredOPSWrapperList[index].lstOPS =
                mapProductSchedulesAll[i];
              this.filteredOPSWrapperList[index].productTermSelected =
                i.toString();
              break;
            }
          }
        }
      }
    });
  }

  //Update Error status on working List Product
  udpateWorkingProductError(prodIndex) {
    if (
      this.workingOPSWrapperList[prodIndex].oppyProduct.LicenseType__c &&
      this.workingOPSWrapperList[prodIndex].oppyProduct.LicenseType__c !== "" &&
      this.workingOPSWrapperList[prodIndex].status &&
      this.workingOPSWrapperList[prodIndex].status !== "" 
    ) {
      this.workingOPSWrapperList[prodIndex].showError = false;
    }
  }

  //Update Error status on working List Product
  udpateFilterProductError(prodIndex) {
    if (
      this.filteredOPSWrapperList[prodIndex].oppyProduct.LicenseType__c &&
      this.filteredOPSWrapperList[prodIndex].oppyProduct.LicenseType__c !==
        "" &&
      this.filteredOPSWrapperList[prodIndex].status &&
      this.filteredOPSWrapperList[prodIndex].status !== "" 
    ) {
      this.filteredOPSWrapperList[prodIndex].showError = false;
    }
  }

  //Update values when Unit Price updated
  onListPriceChange(event) {
    let prdIndex = event.target.dataset.prodIndex;
    this.workingOPSWrapperList[prdIndex].showError = false;
    this.revalidateHideError();
    let opsIndex = event.target.dataset.id;
    let externalListPriceField = this.template.querySelector(
      `[data-id="${opsIndex}"][data-prod-index="${prdIndex}"]`
    );
    this.workingOPSWrapperList[prdIndex].lstOPS[opsIndex].ExternalListPrice__c =
      event.target.value;
    if (event.target.value) {
      externalListPriceField.setCustomValidity("");
      this.calculateTotalValue(prdIndex, opsIndex, true);
    } else {
      this.showError();
      this.workingOPSWrapperList[prdIndex].showError = true;
      externalListPriceField.setCustomValidity("Please enter valid Price.");
    }
    externalListPriceField.reportValidity();
  }

  //Handle List Price Change
  onListPriceFocus(event) {
    let prdIndex = event.target.dataset.prodIndex;
    let indianLevy = 0;
    let adjustedListPrice = 0;
    let opsIndex = event.target.dataset.id;
    let externalListPrice = event.target.value;
    let discAmt =
      this.workingOPSWrapperList[prdIndex].lstOPS[opsIndex].DiscountAmount__c;
    let salesPrice = parseFloat(externalListPrice - discAmt).toFixed(2);
    if (this.workingOPSWrapperList[prdIndex].isIndianLevyProd) {
      let indianLevyTax = this.label.IndiaLevyTax;
      indianLevy = parseFloat((salesPrice * indianLevyTax) / 100).toFixed(2);
      adjustedListPrice = parseFloat(salesPrice) + parseFloat(indianLevy);
      if (Math.sign(salesPrice) > 0 && !Number.isNaN(adjustedListPrice)) {
        this.workingOPSWrapperList[prdIndex].lstOPS[
          opsIndex
        ].displayIndianLevy = true;
        this.tooltipmessage = adjustedListPrice.toFixed(2);
      } else {
        this.tooltipmessage = 0;
        this.workingOPSWrapperList[prdIndex].lstOPS[
          opsIndex
        ].displayIndianLevy = false;
      }
    }
  }

  //Reset tooltip
  resetToolTip(event) {
    let prdIndex = event.target.dataset.prodIndex;
    let opsIndex = event.target.dataset.id;
    this.workingOPSWrapperList[prdIndex].lstOPS[
      opsIndex
    ].displayIndianLevy = false;
  }

  //Update values when Unit Price updated
  onDiscAmountChange(event) {
    let prdIndex = event.target.dataset.prodIndex;
    this.workingOPSWrapperList[prdIndex].showError = false;
    this.revalidateHideError();
    let opsIndex = event.target.dataset.id;
    let discAmountField = this.template.querySelector(
      `[data-id="${opsIndex}"][data-prod-index="${prdIndex}"][data-field="Discount Amount"]`
    );
    this.workingOPSWrapperList[prdIndex].lstOPS[opsIndex].DiscountAmount__c =
      event.target.value;
    if (event.target.value) {
      this.workingOPSWrapperList[prdIndex].lstOPS[opsIndex].DiscountPercent__c =
        parseFloat(
          (event.target.value /
            this.workingOPSWrapperList[prdIndex].lstOPS[opsIndex]
              .ExternalListPrice__c) *
            100
        ).toFixed(2);
      discAmountField.setCustomValidity("");
      this.calculateTotalValue(prdIndex, opsIndex, false);
    } else {
      this.showError();
      this.workingOPSWrapperList[prdIndex].showError = true;
      discAmountField.setCustomValidity("Please enter valid Discount Amount.");
    }
    discAmountField.reportValidity();
  }

  //Update values when Unit Price updated
  onDiscPercentChange(event) {
    let prdIndex = event.target.dataset.prodIndex;
    this.workingOPSWrapperList[prdIndex].showError = false;
    this.revalidateHideError();
    let opsIndex = event.target.dataset.id;
    let discPercentField = this.template.querySelector(
      `[data-id="${opsIndex}"][data-prod-index="${prdIndex}"][data-field="Discount Percent"]`
    );
    this.workingOPSWrapperList[prdIndex].lstOPS[opsIndex].DiscountPercent__c =
      event.target.value;
    if (event.target.value) {
      this.workingOPSWrapperList[prdIndex].lstOPS[opsIndex].DiscountAmount__c =
        parseFloat(
          (event.target.value *
            this.workingOPSWrapperList[prdIndex].lstOPS[opsIndex]
              .ExternalListPrice__c) /
            100
        ).toFixed(2);
      discPercentField.setCustomValidity("");
      this.calculateTotalValue(prdIndex, opsIndex, false);
    } else {
      this.showError();
      this.workingOPSWrapperList[prdIndex].showError = true;
      discPercentField.setCustomValidity(
        "Please enter valid Discount Percent."
      );
    }
    discPercentField.reportValidity();
  }

  //Calculate values for specific OPS record
  calculateTotalValue(prodIndex, opsIndex, showToolkit) {
    this.workingOPSWrapperList[prodIndex].showError = false;
    this.revalidateHideError();
    let discAmount = 0;
    let indianLevy = 0;
    let adjustedListPrice = 0;
    let salesPrice = 0;
    if (
      this.workingOPSWrapperList[prodIndex].lstOPS[opsIndex]
        .ExternalListPrice__c
    ) {
      salesPrice =
        this.workingOPSWrapperList[prodIndex].lstOPS[opsIndex]
          .ExternalListPrice__c;
    }
    if (this.workingOPSWrapperList[prodIndex].discountType === "Amount") {
      discAmount =
        this.workingOPSWrapperList[prodIndex].lstOPS[opsIndex]
          .DiscountAmount__c;
      this.workingOPSWrapperList[prodIndex].lstOPS[
        opsIndex
      ].DiscountPercent__c = parseFloat(
        (discAmount / salesPrice) * 100
      ).toFixed(2);
    }
    if (this.workingOPSWrapperList[prodIndex].discountType === "Percentage") {
      discAmount = parseFloat(
        (this.workingOPSWrapperList[prodIndex].lstOPS[opsIndex]
          .DiscountPercent__c *
          salesPrice) /
          100
      ).toFixed(2);
      this.workingOPSWrapperList[prodIndex].lstOPS[opsIndex].DiscountAmount__c =
        discAmount;
    }
    salesPrice = salesPrice - discAmount;

    if (salesPrice < 0) {
      this.showError();
      this.showErrorMsg = true;
      this.workingOPSWrapperList[prodIndex].showError = true;
    }
    if (this.workingOPSWrapperList[prodIndex].isIndianLevyProd) {
      let indianLevyTax = this.label.IndiaLevyTax;
      indianLevy = parseFloat((salesPrice * indianLevyTax) / 100).toFixed(2);
      if (showToolkit) {
        adjustedListPrice = parseFloat(salesPrice) + parseFloat(indianLevy);
        if (Math.sign(salesPrice) > 0 && !Number.isNaN(adjustedListPrice)) {
          this.workingOPSWrapperList[prodIndex].lstOPS[
            opsIndex
          ].displayIndianLevy = true;
          this.tooltipmessage = adjustedListPrice.toFixed(2);
        } else {
          this.tooltipmessage = 0;
          this.workingOPSWrapperList[prodIndex].lstOPS[
            opsIndex
          ].displayIndianLevy = false;
        }
      }
    }
    salesPrice = parseFloat(salesPrice) + parseFloat(indianLevy);
    this.workingOPSWrapperList[prodIndex].lstOPS[opsIndex].SalesPrice__c =
      salesPrice;
    this.workingOPSWrapperList[prodIndex].lstOPS[opsIndex].TotalPrice__c =
      parseFloat(
        salesPrice *
          this.workingOPSWrapperList[prodIndex].lstOPS[opsIndex].Quantity__c
      ).toFixed(2);

      this.workingOPSWrapperList[prodIndex].prodFirstYearValue = this.workingOPSWrapperList[prodIndex].lstOPS[0].TotalPrice__c;
      this.workingOPSWrapperList[prodIndex].prodTotalPrice = this.getProdTotalPrice(this.workingOPSWrapperList[prodIndex].lstOPS);    
  }

  //Show Error Message and disable buttons
  showError() {
    this.dispatchEvent(
      new CustomEvent("errormsg", { detail: { value: "Error" } })
    );
  }

  //Hide Error Message and enable buttons
  hideError() {
    this.showErrorMsg = false;
    this.dispatchEvent(
      new CustomEvent("errormsg", { detail: { value: "Success" } })
    );
  }

  //re-validate if there is any Product left with error
  revalidateHideError() {
    if(this.workingOPSWrapperList) {
      let errorProdCount = this.workingOPSWrapperList.filter((item)=>{
        return item.showError;
      }).length;
      if(errorProdCount == 0) {
        let errorFilterProdCount = this.filteredOPSWrapperList.filter((item)=>{
          return item.showError;
        }).length;
        if(errorFilterProdCount <= 1) {
          this.hideError();
        }
      }
    }
  }

  //Update values when Annual Unit Price Changed for a specific OPS record
  onAnnualPriceChange(event) {
    let prdIndex = event.target.dataset.prodIndex;
    this.workingOPSWrapperList[prdIndex].showError = false;
    this.revalidateHideError();
    let opsIndex = event.target.dataset.id;
    let annualUnitPriceField = this.template.querySelector(
      `[data-id="${opsIndex}"][data-prod-index="${prdIndex}"]`
    );
    this.workingOPSWrapperList[prdIndex].lstOPS[
      opsIndex
    ].AnnualizedUnitPrice__c = event.target.value;
    if (event.target.value) {
      annualUnitPriceField.setCustomValidity("");
    } else {
      this.showError();
      this.workingOPSWrapperList[prdIndex].showError = true;
      annualUnitPriceField.setCustomValidity("Please eneter valid Price.");
    }
    annualUnitPriceField.reportValidity();
    this.calculateProrationValues(prdIndex, opsIndex, true);
  }

  //Show Tooltip message if Indian Levy is applied on Annual Price
  onAnnualPriceFocus(event) {
    let prdIndex = event.target.dataset.prodIndex;
    let indianLevy = 0;
    let adjustedListPrice = 0;
    let opsIndex = event.target.dataset.id;
    let annualUnitPrice = event.target.value;
    let discAmt =
      this.workingOPSWrapperList[prdIndex].lstOPS[opsIndex]
        .AnnualizedDiscountAmount__c;
    let salesPrice = parseFloat(annualUnitPrice - discAmt).toFixed(2);
    if (this.workingOPSWrapperList[prdIndex].isIndianLevyProd) {
      let indianLevyTax = this.label.IndiaLevyTax;
      indianLevy = parseFloat((salesPrice * indianLevyTax) / 100).toFixed(2);
      adjustedListPrice = parseFloat(salesPrice) + parseFloat(indianLevy);
      if (Math.sign(salesPrice) > 0 && !Number.isNaN(adjustedListPrice)) {
        this.workingOPSWrapperList[prdIndex].lstOPS[
          opsIndex
        ].displayIndianLevy = true;
        this.tooltipmessage = adjustedListPrice.toFixed(2);
      } else {
        this.tooltipmessage = 0;
        this.workingOPSWrapperList[prdIndex].lstOPS[
          opsIndex
        ].displayIndianLevy = false;
      }
    }
  }

  //Update values when Unit Price updated
  onAnnualizedDiscAmtChange(event) {
    let prdIndex = event.target.dataset.prodIndex;
    let opsIndex = event.target.dataset.id;
    let discAmountField = this.template.querySelector(
      `[data-id="${opsIndex}"][data-prod-index="${prdIndex}"][data-field="Annualized Discount Amount"]`
    );
    this.workingOPSWrapperList[prdIndex].lstOPS[
      opsIndex
    ].AnnualizedDiscountAmount__c = event.target.value;
    if (event.target.value) {
      this.workingOPSWrapperList[prdIndex].lstOPS[
        opsIndex
      ].AnnualizedDiscountPercent__c = parseFloat(
        (event.target.value /
          this.workingOPSWrapperList[prdIndex].lstOPS[opsIndex]
            .AnnualizedUnitPrice__c) *
          100
      ).toFixed(2);
      discAmountField.setCustomValidity("");
      this.calculateProrationValues(prdIndex, opsIndex, false);
    } else {
      this.showError();
      discAmountField.setCustomValidity("Please enter valid Discount Amount.");
    }
    discAmountField.reportValidity();
  }

  //Update values when Unit Price updated
  onAnnualizedDiscPrcChange(event) {
    let prdIndex = event.target.dataset.prodIndex;
    this.workingOPSWrapperList[prdIndex].showError = false;
    this.revalidateHideError();
    let opsIndex = event.target.dataset.id;
    let discPercentField = this.template.querySelector(
      `[data-id="${opsIndex}"][data-prod-index="${prdIndex}"][data-field="Annualized Discount Percent"]`
    );
    this.workingOPSWrapperList[prdIndex].lstOPS[
      opsIndex
    ].AnnualizedDiscountPercent__c = event.target.value;
    if (event.target.value) {
      this.workingOPSWrapperList[prdIndex].lstOPS[
        opsIndex
      ].AnnualizedDiscountAmount__c = parseFloat(
        (event.target.value *
          this.workingOPSWrapperList[prdIndex].lstOPS[opsIndex]
            .AnnualizedUnitPrice__c) /
          100
      ).toFixed(2);
      discPercentField.setCustomValidity("");
    } else {
      this.showError();
      this.workingOPSWrapperList[prdIndex].showError = true;
      discPercentField.setCustomValidity(
        "Please enter valid Discount Percent."
      );
    }
    discPercentField.reportValidity();
    this.calculateProrationValues(prdIndex, opsIndex, false);
  }

  //Calculate ProRation Amount for specific OPS record
  calculateProrationValues(prodIndex, opsIndex, showToolkit) {
    this.workingOPSWrapperList[prodIndex].showError = false;
    this.revalidateHideError();
    let discAmount = 0;
    let indianLevy = 0;
    let annualUnitPrice = 0;
    let adjustedListPrice = 0;
    let isProRation = this.workingOPSWrapperList[prodIndex].prorationApplied;
    let proRatedDays = this.workingOPSWrapperList[prodIndex].proRatedDays;
    if (isProRation && proRatedDays !== 360 && proRatedDays < 720) {
      if (
        this.workingOPSWrapperList[prodIndex].lstOPS[opsIndex]
          .AnnualizedUnitPrice__c
      ) {
        annualUnitPrice =
          this.workingOPSWrapperList[prodIndex].lstOPS[opsIndex]
            .AnnualizedUnitPrice__c;
      }
      if (this.workingOPSWrapperList[prodIndex].discountType === "Amount") {
        discAmount =
          this.workingOPSWrapperList[prodIndex].lstOPS[opsIndex]
            .AnnualizedDiscountAmount__c;
        this.workingOPSWrapperList[prodIndex].lstOPS[
          opsIndex
        ].AnnualizedDiscountPercent__c = parseFloat(
          (discAmount / annualUnitPrice) * 100
        ).toFixed(2);
      }
      if (this.workingOPSWrapperList[prodIndex].discountType === "Percentage") {
        discAmount = parseFloat(
          (this.workingOPSWrapperList[prodIndex].lstOPS[opsIndex]
            .AnnualizedDiscountPercent__c *
            annualUnitPrice) /
            100
        ).toFixed(2);
        this.workingOPSWrapperList[prodIndex].lstOPS[
          opsIndex
        ].AnnualizedDiscountAmount__c = discAmount;
      }
      let annualSalesPrice = annualUnitPrice - discAmount;

      if (annualSalesPrice < 0) {
        this.showError();
        this.showErrorMsg = true;
        this.workingOPSWrapperList[prodIndex].showError = true;
      }

      if (this.workingOPSWrapperList[prodIndex].isIndianLevyProd) {
        let indianLevyTax = this.label.IndiaLevyTax;
        indianLevy = parseFloat(
          (annualSalesPrice * indianLevyTax) / 100
        ).toFixed(2);
        if (showToolkit) {
          adjustedListPrice =
            parseFloat(annualSalesPrice) + parseFloat(indianLevy);
          if (
            Math.sign(annualSalesPrice) > 0 &&
            !Number.isNaN(adjustedListPrice)
          ) {
            this.workingOPSWrapperList[prodIndex].lstOPS[
              opsIndex
            ].displayIndianLevy = true;
            this.tooltipmessage = adjustedListPrice.toFixed(2);
          } else {
            this.tooltipmessage = 0;
            this.workingOPSWrapperList[prodIndex].lstOPS[
              opsIndex
            ].displayIndianLevy = false;
          }
        }
      }
      annualSalesPrice = parseFloat(annualSalesPrice) + parseFloat(indianLevy);
      this.workingOPSWrapperList[prodIndex].lstOPS[
        opsIndex
      ].AnnualizedTotalAmount__c = parseFloat(
        annualSalesPrice *
          this.workingOPSWrapperList[prodIndex].lstOPS[opsIndex].Quantity__c
      ).toFixed(2);

      //ProRated Amount Calculations
      let unitPrice = parseFloat(
        (annualUnitPrice / 360) * proRatedDays
      ).toFixed(2);
      let discount = parseFloat((discAmount / 360) * proRatedDays).toFixed(2);
      let discountPercent = 0.0;
      if (unitPrice == 0.0 || unitPrice == null) {
        discountPercent = 0.0;
      } else {
        discountPercent = parseFloat((discount / unitPrice) * 100).toFixed(2);
      }
      let salesPrice = unitPrice - discount;
      if (this.workingOPSWrapperList[prodIndex].isIndianLevyProd) {
        let indianLevyTax = this.label.IndiaLevyTax;
        indianLevy = parseFloat((salesPrice * indianLevyTax) / 100).toFixed(2);
      }
      salesPrice = parseFloat(salesPrice) + parseFloat(indianLevy);
      this.workingOPSWrapperList[prodIndex].lstOPS[opsIndex].DiscountAmount__c =
        discount;
      this.workingOPSWrapperList[prodIndex].lstOPS[
        opsIndex
      ].DiscountPercent__c = discountPercent;
      this.workingOPSWrapperList[prodIndex].lstOPS[opsIndex].SalesPrice__c =
        salesPrice;
      this.workingOPSWrapperList[prodIndex].lstOPS[opsIndex].TotalPrice__c =
        parseFloat(
          salesPrice *
            this.workingOPSWrapperList[prodIndex].lstOPS[opsIndex].Quantity__c
        ).toFixed(2);
      this.workingOPSWrapperList[prodIndex].lstOPS[
        opsIndex
      ].ExternalListPrice__c = parseFloat(unitPrice) + parseFloat(indianLevy);
      this.workingOPSWrapperList[prodIndex].oppyProduct.IsProRated__c = "Yes";
      this.workingOPSWrapperList[prodIndex].prodFirstYearValue = this.workingOPSWrapperList[prodIndex].lstOPS[0].TotalPrice__c;
      this.workingOPSWrapperList[prodIndex].prodTotalPrice = this.getProdTotalPrice(this.workingOPSWrapperList[prodIndex].lstOPS);  
    }
  }

  //Update values when Quantity is updated
  onQtyChange(event) {
    let prdIndex = event.target.dataset.id;
    this.workingOPSWrapperList[prdIndex].showError = false;
    this.revalidateHideError();
    let qtyValue = 1;
    let qtyField = this.template.querySelector(
      `[data-id="${prdIndex}"][data-field="Quantity"]`
    );
    if (event.target.value && event.target.value >= 1) {
      qtyValue = event.target.value;
      qtyField.setCustomValidity("");
      this.workingOPSWrapperList[prdIndex].productQty = qtyValue;
    } else {
      this.showError();
      this.workingOPSWrapperList[prdIndex].showError = true;
      qtyField.setCustomValidity("Please enter valid quantity");
    }
    qtyField.reportValidity();

    let aagPord = this.workingOPSWrapperList[prdIndex].oppyProduct.Product2.AAG__c;

    this.workingOPSWrapperList[prdIndex].lstOPS.forEach((item, index) => {
      this.workingOPSWrapperList[prdIndex].lstOPS[index].Quantity__c = qtyValue;
      if (this.globalProRationApplied && aagPord === "Subscription") {
        this.calculateProrationValues(prdIndex, index, false);
      } else {
        this.calculateTotalValue(prdIndex, index, false);
      }
    });

  }

  //Enable/disable Discount fields based on Discount Type value
  handleDiscTypeChange(event) {
    let prdIndex = event.target.dataset.id;
    this.workingOPSWrapperList[prdIndex].discountType = event.target.value;
    if (event.target.value === "Amount") {
      this.workingOPSWrapperList[prdIndex].discountAmtReadOnly = false;
      this.workingOPSWrapperList[prdIndex].discountPrcReadOnly = true;
    } else if (event.target.value === "Percentage") {
      this.workingOPSWrapperList[prdIndex].discountAmtReadOnly = true;
      this.workingOPSWrapperList[prdIndex].discountPrcReadOnly = false;
    } else {
      this.workingOPSWrapperList[prdIndex].discountAmtReadOnly = true;
      this.workingOPSWrapperList[prdIndex].discountPrcReadOnly = true;
      
      //Update Discount Amount/percent to Zero
      let aagPord = this.workingOPSWrapperList[prdIndex].oppyProduct.Product2.AAG__c;

      this.workingOPSWrapperList[prdIndex].lstOPS.forEach((ops, opsIndex) => {
        if (this.globalProRationApplied && aagPord === "Subscription") {
          this.workingOPSWrapperList[prdIndex].lstOPS[opsIndex].AnnualizedDiscountAmount__c = 0;
          this.workingOPSWrapperList[prdIndex].lstOPS[opsIndex].AnnualizedDiscountPercent__c = 0;
          this.calculateProrationValues(prdIndex, opsIndex, false);
        } else {
          this.workingOPSWrapperList[prdIndex].lstOPS[opsIndex].DiscountAmount__c = 0;
          this.workingOPSWrapperList[prdIndex].lstOPS[opsIndex].DiscountPercent__c = 0;
          this.calculateTotalValue(prdIndex, opsIndex, false);
        }
      });
    }
  }

  handleTermChange(event) {
    let prdIndex = event.target.dataset.id;
    let years = event.target.value;
    let aagProd = this.workingOPSWrapperList[prdIndex].oppyProduct.Product2.AAG__c;
    if (
      years > 1 &&
      this.globalProRationApplied &&
      aagProd === "Subscription"
    ) {
      let errMsg = "For Prorated Products, Term will be set to 1.";
      showMessage(this, "Error!", errMsg, this.errorVariant);
      years = "1";
      event.target.value = "1";
    } else {
      this.workingOPSWrapperList[prdIndex].lstOPS =
        this.workingOPSWrapperList[prdIndex].mapOPSAll[years];
      let lstOPSCurrent = this.workingOPSWrapperList[prdIndex].lstOPS;
      for (let opsIndex in this.workingOPSWrapperList[prdIndex].lstOPS) {
        if (this.globalProRationApplied && aagProd === "Subscription") {
          this.workingOPSWrapperList[prdIndex].lstOPS[
            opsIndex
          ].AnnualizedDiscountAmount__c =
            lstOPSCurrent[opsIndex].AnnualizedDiscountAmount__c;
          this.workingOPSWrapperList[prdIndex].lstOPS[
            opsIndex
          ].AnnualizedDiscountPercent__c =
            lstOPSCurrent[opsIndex].AnnualizedDiscountPercent__c;
          if (lstOPSCurrent[opsIndex].AnnualizedUnitPrice__c <= 0) {
            this.workingOPSWrapperList[prdIndex].lstOPS[
              opsIndex
            ].AnnualizedDiscountAmount__c = 0;
            this.workingOPSWrapperList[prdIndex].lstOPS[
              opsIndex
            ].AnnualizedDiscountPercent__c = 0;
          }
          this.calculateProrationValues(prdIndex, opsIndex, false);
        } else {
          this.workingOPSWrapperList[prdIndex].lstOPS[
            opsIndex
          ].DiscountAmount__c = lstOPSCurrent[opsIndex].DiscountAmount__c;
          this.workingOPSWrapperList[prdIndex].lstOPS[
            opsIndex
          ].DiscountPercent__c = lstOPSCurrent[opsIndex].DiscountPercent__c;
          if (lstOPSCurrent[opsIndex].ExternalListPrice__c <= 0) {
            this.workingOPSWrapperList[prdIndex].lstOPS[
              opsIndex
            ].DiscountAmount__c = 0;
            this.workingOPSWrapperList[prdIndex].lstOPS[
              opsIndex
            ].DiscountPercent__c = 0;
          }
          this.calculateTotalValue(prdIndex, opsIndex, false);
        }
      }
    }
    this.workingOPSWrapperList[prdIndex].productTermSelected = years;
  }

  //Update Product Status and enable/disable Delete Button
  handleProdStatusChange(event) {
    let prdIndex = event.target.dataset.id;
    this.workingOPSWrapperList[prdIndex].oppyProduct.Status__c =
      event.target.value;
    this.workingOPSWrapperList[prdIndex].status = event.target.value;
    if (
      this.hasOppyEditAccess &&
      this.workingOPSWrapperList[prdIndex].status !== "New"
    ) {
      this.workingOPSWrapperList[prdIndex].disableDelete = true;
    } else {
      this.workingOPSWrapperList[prdIndex].disableDelete = false;
    }
  }

  //Update Product at Risk and enable/disable Risk Status field
  handleProdAtRiskChange(event) {
    let prdIndex = event.target.dataset.id;
    this.workingOPSWrapperList[prdIndex].oppyProduct.IsProductatRisk__c = event.target.value;
    if (this.workingOPSWrapperList[prdIndex].oppyProduct.IsProductatRisk__c === "Yes") {
      this.workingOPSWrapperList[prdIndex].disableRiskStatus = false;
    } else {
      this.workingOPSWrapperList[prdIndex].oppyProduct.EstimatedValueatRisk__c = null;
      this.workingOPSWrapperList[prdIndex].disableRiskStatus = true;
    }
  }

  //Update Risk Status Value
  handleRiskStatusChange(event) {
    let prdIndex = event.target.dataset.id;
    this.workingOPSWrapperList[prdIndex].oppyProduct.RiskStatus__c =
      event.target.value;
  }

  //Update License Type value and reset error flag & conditional messages
  handleLicenseChange(event) {
    let prdIndex = event.target.dataset.id;
    let sLicenseType = event.target.value;
    this.workingOPSWrapperList[prdIndex].oppyProduct.LicenseType__c =
      sLicenseType;
    this.workingOPSWrapperList[prdIndex].showLTEnterpriseMessage =
      this.workingOPSWrapperList[prdIndex].oppyProduct.Product2.Division__c !==
        "Financial Services" &&
      this.workingOPSWrapperList[prdIndex].oppyProduct.Product2.Division__c !==
        "OSTTRA" &&
      sLicenseType === "Enterprise Wide License"
        ? true
        : false;
    this.workingOPSWrapperList[prdIndex].showLTGeneralMessage =
      this.workingOPSWrapperList[prdIndex].oppyProduct.Product2.Division__c !==
        "Financial Services" &&
      this.workingOPSWrapperList[prdIndex].oppyProduct.Product2.Division__c !==
        "OSTTRA" &&
      (sLicenseType === "Customer License" ||
      sLicenseType === "Divisional License" ||
      sLicenseType === "Departmental License" ||
      sLicenseType === "User License" ||
      sLicenseType === "Site License")
        ? true
        : false;
    this.udpateWorkingProductError(prdIndex);
  }

  onProbabilityChange(event) {
    let prdIndex = event.target.dataset.id;
    if (event.target.value && event.target.value >= 0) {
      this.workingOPSWrapperList[prdIndex].oppyProduct.Probability__c =
        event.target.value;
    }
  }

  onLocSitesChange(event) {
    let prdIndex = event.target.dataset.id;
    if (event.target.value && event.target.value >= 0) {
      this.workingOPSWrapperList[
        prdIndex
      ].oppyProduct.NumberofLocationsSites__c = event.target.value;
    } else {
      this.workingOPSWrapperList[
        prdIndex
      ].oppyProduct.NumberofLocationsSites__c = null;
    }
  }

  onConUsersChange(event) {
    let prdIndex = event.target.dataset.id;
    if (event.target.value && event.target.value >= 0) {
      this.workingOPSWrapperList[
        prdIndex
      ].oppyProduct.NumberofConcurrentUsersSeats__c = event.target.value;
    } else {
      this.workingOPSWrapperList[
        prdIndex
      ].oppyProduct.NumberofConcurrentUsersSeats__c = null;
    }
  }

  onPotUsersChange(event) {
    let prdIndex = event.target.dataset.id;
    if (event.target.value && event.target.value >= 0) {
      this.workingOPSWrapperList[
        prdIndex
      ].oppyProduct.NumberofPotentialUsers__c = event.target.value;
    } else {
      this.workingOPSWrapperList[
        prdIndex
      ].oppyProduct.NumberofPotentialUsers__c = null;
    }
  }

  onAuthUsersChange(event) {
    let prdIndex = event.target.dataset.id;
    if (event.target.value && event.target.value >= 0) {
      this.workingOPSWrapperList[prdIndex].oppyProduct.AuthorizedUsers__c =
        event.target.value;
    } else {
      this.workingOPSWrapperList[prdIndex].oppyProduct.AuthorizedUsers__c = null;
    }
  }

  onDescriptionChange(event) {
    let prdIndex = event.target.dataset.id;
    this.workingOPSWrapperList[prdIndex].oppyProduct.Description = event.target.value;
  }

  onEstValChange(event) {
    let prdIndex = event.target.dataset.id;
    if (event.target.value && event.target.value >= 0) {
      this.workingOPSWrapperList[prdIndex].oppyProduct.EstimatedValueatRisk__c =
        event.target.value;
    } else {
      this.workingOPSWrapperList[
        prdIndex
      ].oppyProduct.EstimatedValueatRisk__c = null;
    }
  }

  //Move to the previous page and show updated list of Products
  handlePreviousPage() {
    this.pageNumber = this.pageNumber - 1;
    this.updateListOPSWrapper();
    this.updateWorkingProdList();
  }

  //Move to the next page and show updated list of Products
  handleNextPage() {
    this.pageNumber = this.pageNumber + 1;
    this.updateListOPSWrapper();
    this.updateWorkingProdList();
  }

  //Display products based on Updated Page Size
  handlePageSize(event) {
    let pgSize = event.detail.size;
    if (pgSize) {
      this.pageSize = pgSize;
      this.pageNumber = 1;
      this.updateListOPSWrapper();
      this.updateWorkingProdList();
    }
  }

  //Save updated Product Details on Opportunity Line Item. This method is getting called from Container while user clicks on Save button
  @api
  saveOppyProductList() {
    if (this.lstOPSWrapper) {
      //this.showSpinner = true;
      let deletedProducts = 0;
      let anyProductDeleted = false;
      let anyProductError = false;
      this.updateListOPSWrapper();
      //Validate if any Product is without required values or Deleted
      for (let key in this.lstOPSWrapper) {
        if (this.lstOPSWrapper[key].isDeleted) {
          anyProductDeleted = true;
          deletedProducts++;
        } else {
          // Validation is required only for Products which are not deleted
          if (
            !this.lstOPSWrapper[key].oppyProduct.LicenseType__c ||
            this.lstOPSWrapper[key].oppyProduct.LicenseType__c === "" ||
            !this.lstOPSWrapper[key].status ||
            this.lstOPSWrapper[key].status === "" 
          ) {
            this.lstOPSWrapper[key].showError = true;
            let errorMsg = "Some of the required fields(Status/ License Type) are missing on Products.";
            showMessage(this, "Details Required!", errorMsg, this.errorVariant);
            let workingIndex = this.workingOPSWrapperList.findIndex(
              (item) => item.mainListIndex == key
            );
            if (workingIndex !== -1) {
              this.workingOPSWrapperList[workingIndex].showError = true;
            }
            anyProductError = true;
            let filterIndex = this.filteredOPSWrapperList.findIndex(
              (item) => item.mainListIndex == key
            );
            if (filterIndex !== -1) {
              this.filteredOPSWrapperList[filterIndex].showError = true;
            }
          }
        }
      }
      if (anyProductError) {
        this.stopSpinnerEvent("Error");
        return;
      }
      if (
        deletedProducts !== this.lstOPSWrapper.length &&
        anyProductDeleted &&
        !this.isLegalUpdated
      ) {
        this.updateLegalProductList();
        this.isLegalModalOpen = true;
        return;
      }
      this.saveUpdatedProducts();
    }
  }

  //Save Products and show error/success message
  async saveUpdatedProducts() {
    let tempNewOPSList = JSON.parse(JSON.stringify(this.lstOPSWrapper));
    let iMaxUpdProds = this.label.AddEditProdMaxUpdateProducts;
    let savedResult = '';
    let tempOldOPSList = [];

    try {
      while(tempNewOPSList.length > 0) {
        let tempOPSWrapperList = tempNewOPSList.splice(0, iMaxUpdProds);
        savedResult = await saveProducts({
          oppyId: this.recordId,
          wrapperJson: JSON.stringify(tempOPSWrapperList)
        }); 
        if (savedResult.indexOf("Error occurred") !== -1) {
          //Revert Old changes done by last batch if any
          if(tempOldOPSList && tempOldOPSList.length > 0) {
            let revertResult = await saveProducts({
              oppyId: this.recordId,
              wrapperJson: JSON.stringify(tempOldOPSList)
            });
          }
          //show error message based on its type
          if (
            savedResult.includes("FIELD_CUSTOM_VALIDATION_EXCEPTION") ||
            savedResult.includes("NUMBER_OUTSIDE_VALID_RANGE")
          ) {
            let validationMessage = "";
            if (savedResult.includes("FIELD_CUSTOM_VALIDATION_EXCEPTION")) {
              let initialValidationMessage = savedResult.split(
                "FIELD_CUSTOM_VALIDATION_EXCEPTION,"
              )[1];
              validationMessage = initialValidationMessage.split(": [")[0];
            } else if (savedResult.includes("NUMBER_OUTSIDE_VALID_RANGE")) {
              let initialValidationMessage = savedResult.split(
                "NUMBER_OUTSIDE_VALID_RANGE,"
              )[1];
              validationMessage = initialValidationMessage.split(": [")[0];
            }
            showMessage(this, "Error!", validationMessage, this.errorVariant);
          } else {
            showMessage(this, "Oops!", savedResult, this.errorVariant);
          }
          this.stopSpinnerEvent("Error");
          return;
        } else {
          tempOldOPSList.push(...(this.oldLstOPSWrapper.splice(0, iMaxUpdProds)));
        }
      }
      this.stopSpinnerEvent("Success");
      let successMsg = "Opportunity Products are updated successfully.";
      showMessage(this, "Products Saved!", successMsg, this.successVariant);
  } catch(error) {
      this.error = JSON.stringify(error);
      let errMsg = this.label.AddEditProdMaxLimitError;
      console.log("Save Error " + this.error);
      showMessage(this, "Error occurred", errMsg, this.errorVariant);
      this.stopSpinnerEvent("Error");
    }
  }

  //Stop spinner once details are saved successfully
  stopSpinnerEvent(saveStatus) {
    this.dispatchEvent(
      new CustomEvent("stopspinner", { detail: { status: saveStatus } })
    );
  }

  //Update Product List to be sent back to Legal Entity change component
  updateLegalProductList() {
    this.legalProdList = [];
    this.productsDeleted = false;
    this.lstOPSWrapper.forEach((item) => {
      if (!item.isDeleted) {
        let prodVar = {
          productId: item.oppyProduct.Product2Id,
          product: { MaterialCode__c: item.oppyProduct.MaterialCode__c }
        };
        this.legalProdList.push(prodVar);
      } else {
        this.productsDeleted = true;
      }
    });
  }

  //Publish on message channel to move to Legal Entity Page. This method is getting called from Container when User clicks on Change Legal Entity
  @api
  publishChangeLegalEntity() {
    this.updateListOPSWrapper();
    this.updateLegalProductList();
    publish(this.messageContext, SELECTED_PRODUCTS_LIST, {
      selProductsList: this.legalProdList,
      mode: "editScreen",
      productsRemoved: this.productsDeleted
    });
  }
}