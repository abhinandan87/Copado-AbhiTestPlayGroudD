import { LightningElement, wire, track, api } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCountryOptions from '@salesforce/apex/WorkRequestFormCountryHelper.getCountryOptions';
import getCountrySelectionsByDataType from '@salesforce/apex/WorkRequestFormCountryHelper.getCountrySelectionsByDataType';
import upsertCountrySelections from '@salesforce/apex/WorkRequestFormCountryHelper.upsertCountrySelections';
import getDataTypes from '@salesforce/apex/WorkRequestFormCountryHelper.getDataTypes';
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import NAME_FIELD from '@salesforce/schema/WorkRequestForm__c.Name';
import PARCDataFiles_FIELD from '@salesforce/schema/WorkRequestForm__c.PARCDataFiles__c';
import WorldviewVIO_FIELD from '@salesforce/schema/WorkRequestForm__c.PARCDataFiles__c';
import DataExtractGlobalVIOPARC_FIELD from '@salesforce/schema/WorkRequestForm__c.DataExtractGlobalVIOPARC__c';

import messageChannel from '@salesforce/messageChannel/SaveCountrySelections__c';
import {publish, MessageContext} from 'lightning/messageService'

export default class WrfCountryGrid extends LightningElement {

    @api recordId;
    @track geolist;
    @track vehicleTypeList;
    @track listGeos;
    @track listVehicleTypes;
    @track listRegions;
    @track listDataTypes = [];
    @track loadParam = true;
    isLoading = false;
    @track dataType;
  //  @track dataTypeOptions = [{ label: 'Global VIO', value: 'Global VIO' }];
    mapCountries = new Map();
    mapSelectedCountries = new Map();
    @track selectedCountriesData;
    @track listSelectedCountriesData;
    @track countryOptionsData;
    @track selectedOptions = [];
    refreshGrid = true;
    refreshChildGrid = false;
    @api requestType;


    @wire(MessageContext)
    messageContext;

    publishMessage() {
        let dtType = this.dataType;
        let reqType = this.requestType;
        let message = {dataType: dtType, requestType: reqType };
        publish(this.messageContext, messageChannel, message);
    }
    

    @wire(getRecord, { recordId: '$recordId', fields: [NAME_FIELD, PARCDataFiles_FIELD, WorldviewVIO_FIELD, DataExtractGlobalVIOPARC_FIELD] })
    rec({ error, data }) {
        if (data) {
            console.log(data);
        }
        else {
            console.log(error);
        }
    };

    get dataTypeSelected() {
        if (this.dataType) {
            return true;
        }
        return false;
    }

    handleDataTypeChange(event) {
        this.dataType = event.target.value;
        this.refreshGrid = false;
        this.mapCountries = new Map();
        this.loadParam = !this.loadParam;
        this.isLoading = true;
        refreshApex(this.selectedCountriesData);
        refreshApex(this.countryOptionsData);
        this.refreshGrid = true;
    }

    @wire(getCountrySelectionsByDataType, ({ wrfId: '$recordId', dataType: '$dataType', requestType: '$requestType' }))
    //countrySelections({ error, data }) {
    countrySelections(response) {
        this.selectedCountriesData = response;
        if (response.data) {
            this.listSelectedCountriesData = response.data;
            this.validateAndProcessCountrySelections(response.data);
        } else {
            console.log(response.error);
        }
    }

    /* Get the country options from the apex controller */
    getCountrySelectionsForWRF() {
        getCountrySelectionsByDataType({ wrfId: this.recordId, dataType: this.dataType, requestType: this.requestType })
            .then(data => {
                this.validateAndProcessCountrySelections(data);
            })
            .catch(error => {
                console.log(error);
            });
    }

    handleModalClose() {
        this.dispatchWRFEvent('closemodel');
    }

    dispatchWRFEvent(name) {
        var evt = new CustomEvent(name);;
        this.dispatchEvent(evt);
    }

    /* Get the country options from the apex controller */
    upsertCountrySelectionsForWRF(selections) {
        this.isLoading = true;
        upsertCountrySelections({ listSelections: selections, wrfId: this.recordId, dataType:this.dataType, requestType: this.requestType })
            .then(data => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Selections Saved Successfully',
                        variant: 'success'
                    })
                );
                this.isLoading = false;
                this.publishMessage();
            })
            .catch(error => {
                console.log(error);
            });
        
    }

    validateAndProcessCountrySelections(data) {
        if(!data) {
            return;
        }
        var arrData = [];
        data.forEach(obj => {
            if(obj.VehicleType__c) {
                arrData.push(obj);
            }
        });
        this.processCountrySelections(arrData);
    }

    processCountrySelections(data) {
        if(!data) {
            return;
        }
        this.mapSelectedCountries = new Map();
        for (let i = 0; i < data.length; i++) {
            let obj = { ...data[i] };

            if (this.mapSelectedCountries.has(obj.Country__c+obj.DataType__c)) {
                let cntryObj = this.mapSelectedCountries.get(obj.Country__c+obj.DataType__c);
                let mapGeos = cntryObj.mapGeos;
                let geoObj = this.getGeoObject(obj.Geography__c, obj.Country__c, true);
                mapGeos.set(obj.Geography__c, geoObj);
                obj.VehicleType__c.split(";").forEach(vt => {
                    let vtObj = this.getVehicleTypeObject(vt, obj.Geography__c, true, false);
                    vtObj.value = true;
                    let mapVehicleTypes = geoObj.mapVehicleTypes;
                    mapVehicleTypes.set(vt, vtObj);
                });

            } else {
                let cntryObj = this.getCountryObject(obj.Country__c, obj.Region__c, obj.Comments__c, obj.DataType__c, obj.RequestType__c, obj.ISOCode__c);
                let geoObj = this.getGeoObject(obj.Geography__c, obj.Country__c, true);
                let mapGeos = cntryObj.mapGeos;
                mapGeos.set(obj.Geography__c, geoObj);
                obj.VehicleType__c.split(";").forEach(vt => {
                    let vtObj = this.getVehicleTypeObject(vt, obj.Geography__c, true, false);
                    vtObj.value = true;
                    let mapVehicleTypes = geoObj.mapVehicleTypes;
                    mapVehicleTypes.set(vt, vtObj);
                });
                cntryObj.mapGeos = mapGeos;
                let cntryKey = obj.Country__c + obj.DataType__c;
                this.mapSelectedCountries.set(cntryKey, cntryObj);
            }
        }
    }

    @wire(getDataTypes, { requestType: '$requestType'})
    dataTypes(response) {
        if (response.data) {
            this.processDataTypes(response.data);
        }        
    }

    @wire(getCountryOptions, { requestType: '$requestType', dataType: '$dataType', loadParam: '$listSelectedCountriesData' })
    countryOptions(response) {
        this.getCountrySelectionsForWRF();
        this.countryOptionsData = response;
        if (response.data) {
            refreshApex(this.selectedCountriesData);
            this.validateAndProcessCountrySelections(this.selectedCountriesData.data);
            this.prepareSupportedListsFromOptions(this.countryOptionsData.data);
            this.processCountryOptions(this.countryOptionsData.data);
            this.isLoading = false;
        }
        else {
            console.log(response.error);
            this.isLoading = false;
        }
    };


    handleCommentChange(event) {
        let countryName = event.target.dataset.id;
        var countryObj = this.mapCountries.get(countryName);
        if (countryObj) {
            countryObj.Comments__c = event.detail.value;
        }
    }

    handleCheckboxChange(event) {
        this.refreshGrid = false;
        //Vehicle-Key is expected to be in the format country_geo_VehicleType
        //Split the key based on '_'
        var vehicleKey = event.target.dataset.id;
        var listVehicleKeySplit = vehicleKey.split('_');
        var country = listVehicleKeySplit[0];
        var geo = listVehicleKeySplit[1];
        var vt = listVehicleKeySplit[2];
        var valueChange = event.target.checked;
        this.updateCountrySelection(country, geo, vt, valueChange);
        this.refreshGrid = true;
    }

    handleSelectionChange(event) {
        var inputCountry = event.detail;
        this.updateCountrySelection(inputCountry.Country, inputCountry.Geo, inputCountry.VehicleType, inputCountry.ValueUpdated);
    }

    updateCountrySelection(country, geo, vehicleType, valueChange) {
        let selectedCountry = this.mapCountries.get(country);
        if (!selectedCountry) {
            return false;
        }
        let selectedGeo = selectedCountry.mapGeos.get(geo);
        if (!selectedGeo) {
            return false;
        }
        let selectedVehicleType = selectedGeo.mapVehicleTypes.get(vehicleType);
        if (!selectedVehicleType) {
            return false;
        }
        if (selectedCountry && selectedGeo && selectedVehicleType) {
            selectedGeo.values.forEach(vehType => {
                if (vehType === vehicleType) {
                    vehType.value = valueChange;
                }
            });
            selectedVehicleType.value = valueChange;
            //return false;
        }
        return selectedVehicleType;
    }
    handleChange(e) {
        if (e.target.checked) {
            this.selectedOptions.push(e.target.label);
        } else {
            let index = this.selectedOptions.indexOf(e.target.label);
            this.selectedOptions.splice(index, 1);
        }
    }

    get countryValues() {
        let listCountries = Array.from(this.mapCountries.values());
        /*
        listCountries.sort(function(obj1, obj2) {
            return obj1.Name - obj2.Name;
        });
        */
        listCountries.sort((a,b) => (a.Name  > b.Name)? 1:-1)
        return listCountries;
        //return Array.from(this.mapCountries.values()).sort();
    }

    prepareSupportedListsFromOptions(data) {
        this.listGeos = [];
        this.listVehicleTypes = [];
        this.listRegions = [];
        var setGeos = new Set();
        var setVehicleTypes = new Set();
        var setRegions = new Set();
        if(!data) {
            return;
        }
        for (let i = 0; i < data.length; i++) {
            let obj = { ...data[i] };

            // Get set of Geos from the Country Options. This list will be used for Header section
            obj.Geography__c.split(";").forEach(geo => {
                setGeos.add(geo);
            });

            // Get set of Vehicletypes from the Country Options. This list will be used for Header section
            obj.VehicleType__c.split(";").forEach(vt => {
                setVehicleTypes.add(vt);
            });

            // Get set of Regions from the Country Options. This list will be used for Filtering section
            obj.Region__c.split(';').forEach(region => {
                setRegions.add(region);
            });
           
            
        }

        /* Converting the set to arrays for usability. */
        this.listGeos = Array.from(setGeos).sort();
        this.listVehicleTypes = Array.from(setVehicleTypes).sort();
        this.selectedOptions = Array.from(setRegions).sort();
        this.listRegions = Array.from(setRegions).sort();
        
    }

    processDataTypes(data) {
        var setDataTypes = new Set();
        for (let i = 0; i < data.length; i++) {
            let obj = { ...data[i] };
            // Get set of Reions from the Country Options. This list will be used for Filtering section
            obj.DataType__c.split(';').forEach(dataType => {
                setDataTypes.add(dataType);
            });            
        }
        this.listDataTypes = Array.from(setDataTypes).sort();
    }

    get hasRegions() {
        if (this.regionOptions && this.regionOptions.length > 0) {
            return true;
        } else {
            return false;
        }
    }

    /*Handles Selection from Child Components. Updates selected options based on user input selections */
    handleSelection(event) {
        this.selectedOptions = event.detail;
    }

    /* Handles Header Click Selections */
    handleHeaderClick(event) {
        this.refreshChildGrid = true;
        this.refreshGrid = false;
        var headerOption = event.detail;
        //Array.from(this.mapCountries.values()).forEach(country => {
        this.filteredResults.forEach(country => {
            if (country.mapGeos.has(headerOption.geo)) {
                var geoObj = country.mapGeos.get(headerOption.geo);
                if (geoObj.mapVehicleTypes.has(headerOption.vehicleType)) {
                    // var vehType = geoObj.mapVehicleTypes.get(headerOption.vehicleType);
                    geoObj.values.forEach(vehType => {
                        if (vehType.Name === headerOption.vehicleType) {
                            vehType.value = (!vehType.Disabled && !vehType.value);
                        }
                    });

                }
            }
        });
        this.refreshGrid = true;
        this.refreshChildGrid = false;

    }

    submitDetails(event) {
        var selections = this.getUserCountrySelections();
        this.upsertCountrySelectionsForWRF(selections);
    }

    getUserCountrySelections() {
        var listSelections = [];
        Array.from(this.mapCountries.values()).forEach(country => {
            //Processing Geos
            country.values.forEach(geo => {
                //processing Vehicle Types
                var vehicleTypes = '';
                geo.values.forEach(vt => {
                    if (vt.value === true) {
                        vehicleTypes = vehicleTypes + vt.Name + ';';
                    }
                }); // END of VehicleTypes loop
                if (vehicleTypes != '') {
                    let countryUserSelection = this.getCountrySelectionObject(country.Name, this.recordId, this.requestType, this.dataType, geo.Name, vehicleTypes, country.Comments__c, country.Region, country.ISOCode__c)
                    listSelections.push(countryUserSelection);
                }
            })
        });
        return listSelections;
    }

    handleCountryNameClick(event) {
        this.refreshGrid = false;
        //var countryName = 'Australia';
        var countryName = event.target.firstChild.data;
        countryName = countryName.substring(0,countryName.indexOf(' - '));
        var countryObj = this.mapCountries.get(countryName);
        Array.from(countryObj.mapGeos.values()).forEach(geoObj => {

            geoObj.values.forEach(vehType => {
                vehType.value = (!vehType.Disabled && !vehType.value);
            });
        });
        this.refreshGrid = true;
    }

    get dataTypeOptions() {
        var dataTypeOptions = [];
        this.listDataTypes.forEach(dataType=>{
            dataTypeOptions.push({label:dataType, value:dataType});
        });
        if(dataTypeOptions.length > 0 && dataTypeOptions.length == 1) {
            this.assignDataType(dataTypeOptions[0]);
        }
        return dataTypeOptions;
    }

    assignDataType(dataTypeOption) {
        if(dataTypeOption && !this.dataType) {
            this.dataType = dataTypeOption.value;
        }
    }

    /*Handles the filtered results based on selected options and country options */
    get filteredResults() {
        var options = this.selectedOptions;
        var results = [];
        if (this.countryValues) {
            results = this.countryValues.filter(function (opt) {
                return options.includes(opt.Region);
            });
        }
        return results.sort();
    }

    /* Region Options used for display of selection check boxes*/
    get regionOptions() {
        var options = [];
        if (this.listRegions) {
            this.listRegions.forEach(region => {
                let opt = { label: region, value: this.selectedOptions.includes(region) };
                options.push(opt);
            });
        }
        return options;
    }

    processCountryOptions(data) {
        if(!data) {
            return;
        }
        this.mapCountries = new Map();
        for (let i = 0; i < data.length; i++) {
            let obj = { ...data[i] };
            this.processVehicleTypes(obj);
        }
        this.listGeos;
        this.listVehicleTypes;
        this.countryValues;
    }

    processVehicleTypes(obj) {
        var countries = obj.Country__c.split(";");
        countries.forEach(cntry => {
            var cntryObj = null;

            if (!this.mapCountries.has(cntry)) {
                let cntryKey = cntry +  obj.DataType__c;
                let comments = this.mapSelectedCountries.get(cntryKey) ? this.mapSelectedCountries.get(cntryKey).Comments__c : '';
                cntryObj = this.getCountryObject(cntry, obj.Region__c, comments, obj.DataType__c, obj.RequestType__c, obj.ISOCode__c);
                this.mapCountries.set(cntry, cntryObj);
            } else {
                cntryObj = this.mapCountries.get(cntry);
            }

            //For each Geo Process Available for selection and drill down vehicle types process Available for Selection

            this.listGeos.forEach(geo => {
                var objGeoList = obj.Geography__c.split(";");
                var geoAvialble = objGeoList.includes(geo);
                var opGeoObj = null;
                var opVehilces = new Map();
                if (cntryObj.mapGeos && !cntryObj.mapGeos.has(geo)) {
                    opGeoObj = this.getGeoObject(geo, cntry, geoAvialble);

                    this.listVehicleTypes.forEach(vt => {
                        var vtAvailable;
                        let objVehicleTypeList = obj.VehicleType__c.split(";");

                        if (geoAvialble === true) {
                            vtAvailable = objVehicleTypeList.includes(vt);
                        } else {
                            vtAvailable = false;
                        }
                        let opVehObj = this.getVehicleTypeObject(vt, opGeoObj, vtAvailable, !vtAvailable);
                        opVehObj.value = this.getCountrySelection(cntry, geo, vt, obj.DataType__c);
                        opVehilces.set(vt, opVehObj);
                    });

                    opGeoObj.mapVehicleTypes = opVehilces;
                    cntryObj.mapGeos.set(geo, opGeoObj);

                } else if (cntryObj.mapGeos && cntryObj.mapGeos.has(geo)) {
                    opGeoObj = cntryObj.mapGeos.get(geo);
                    //Override Vehicle Selections only existing vehicle types not avaliable for selection and Current processing vehiles are available for selection.    
                    //   if (!opGeoObj.Available) {
                    opGeoObj.mapVehicleTypes.forEach((vehicleValue, vehicleKey) => {
                        let objVehicleTypeList = obj.VehicleType__c.split(";");
                        vehicleValue.GeoName = geo;
                        if (!vehicleValue.Available) {
                            vehicleValue.Available = objVehicleTypeList.includes(vehicleKey) && geoAvialble;
                            vehicleValue.Disabled = !(objVehicleTypeList.includes(vehicleKey) && geoAvialble);
                            vehicleValue.value = this.getCountrySelection(cntry, geo, vehicleKey, obj.DataType__c);
                        }
                    });
                    //}
                }
                opGeoObj.values = Array.from(opGeoObj.mapVehicleTypes.values());
            }); // End of Geos Loop
            cntryObj.values = Array.from(cntryObj.mapGeos.values());
        }); // End of Countries Loop
    }

    getCountrySelection(country, geo, vehicleType, recDataType) {
        let cntryKey = country+recDataType;
        let selectedCountry = this.mapSelectedCountries.get(cntryKey);
        if (!selectedCountry) {
            return false;
        }
        let selectedGeo = selectedCountry.mapGeos.get(geo);
        if (!selectedGeo) {
            return false;
        }
        let selectedVehicleType = selectedGeo.mapVehicleTypes.get(vehicleType);
        if (!selectedVehicleType) {
            return false;
        }
        if (selectedCountry && selectedGeo && selectedVehicleType && selectedCountry.dataType === recDataType) {
            return selectedVehicleType.value;
            //return false;
        }
        return false;
    }

    getCountryObject(country, regionValue, comments, dataTypeValue, requestTypeValue, IsoCode ) {
        return { Name: country, mapGeos: new Map(), values: [], Comments__c: comments, Region: regionValue, dataType:dataTypeValue, requestType: requestTypeValue, ISOCode__c:IsoCode, displayName: country+ ' - ' + (IsoCode ? IsoCode : '') };
    }

    getGeoObject(geo, country, available) {
        return { Name: geo, Country: country, Available: available, mapVehicleTypes: new Map(), values: [] };
    }


    getVehicleTypeObject(vehicleType, geo, available, disabled) {
        return { Name: vehicleType, GeoName: geo.Name, Country: geo.Country, vehicleKey: geo.Country + '_' + geo.Name + '_' + vehicleType, Available: available, Disabled: disabled, value: false };
    }

    getCountrySelectionObject(country, wrf, requestType, dataType, geo, vehicleTypes, comments, region, IsoCode) {
        return {
            Country__c: country, WorkRequestForm__c: wrf, RequestType__c: requestType, DataType__c: dataType,
            Geography__c: geo, VehicleType__c: vehicleTypes, Comments__c: comments, Region__c: region, ISOCode__c:IsoCode
        };
    }

    get headerStyleClass() {
        var cols = 6;
        if (this.listGeos) {
            cols = this.listGeos.length;
        }
        // Adding one more columns for Country Name and Comments apart from Geo in the Header row.
        cols = cols + 2;
        let colsString = cols.toString();
        return 'slds-size_1-of-' + colsString + ' borderedTableHeaderSmall';
    }

    get headerWithCenterStyleClass() {
        var cols = 6;
        if (this.listGeos) {
            cols = this.listGeos.length;
        }
        // Adding one more columns for Country Name and Comments apart from Geo in the Header row.
        cols = cols + 2;
        let colsString = cols.toString();
        return 'slds-size_1-of-' + colsString + ' slds-align_absolute-center slds-theme_shade borderedTableHeader';
    }

    get headerWithNoCustomStyle() {
        var cols = 6;
        if (this.listGeos) {
            cols = this.listGeos.length;
        }
        // Adding one more columns for Country Name and Comments apart from Geo in the Header row.
        cols = cols + 2;
        let colsString = cols.toString();
        return 'slds-size_1-of-' + colsString;
    }

    get rowDataStyleClass() {
        var cols = 3;
        if (this.listVehicleTypes) {
            cols = this.listVehicleTypes.length;
        }
        let colsString = cols.toString();
        //return 'slds-size_1-of-' + colsString + ' slds-align_absolute-center borderedTableCell';
        return 'slds-size_1-of-' + colsString + ' slds-align_absolute-center';
    }

    get rowStyleClass() {
        var cols = 3;
        if (this.listVehicleTypes) {
            cols = this.listVehicleTypes.length;
        }
        let colsString = cols.toString();
        return 'slds-size_1-of-' + colsString;
    }


    get customStyle() {
        // return 'background-color:#00ab4e;padding:5px;border-style:solid;border-left:2px;border-color:white'
        return this.headerWithCenterStyleClass + ' borderedTableHeader';
    }
}