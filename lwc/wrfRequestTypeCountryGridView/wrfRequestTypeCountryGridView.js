import { LightningElement, wire, track, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getCountrySelectionsByDataType from '@salesforce/apex/WorkRequestFormCountryHelper.getCountrySelectionsByDataType';

export default class WrfRequestTypeCountryGridView extends LightningElement {

    @api recordId;
    @api dTypeValue;
    @track geolist;
    @track vehicleTypeList;
    @track listGeos;
    @track listVehicleTypes;
    @track listRegions;
    @track mapCountries = new Map();
    @track mapSelectedCountries = new Map();
    @track selectedOptions = [];
    @api requestType;
    @track dataTp;
    refreshGrid = true;
    gridviewDisplay=false;
    loadParam=true;
    @track listCountrySelections;
    @api
    refreshCountryViewGrid(){
        //this.loadParam=true;  
        this.refreshGrid = false;
        this.dataTp = this.dTypeValue;
        refreshApex(this.listCountrySelections);
        this.validateAndProcessCountrySelections(this.listCountrySelections.data);
        this.refreshGrid = true;
    }
    connectedCallback() {
        this.refreshCountryViewGrid();
    }
  
    @wire(getCountrySelectionsByDataType, ({ wrfId: '$recordId', dataType: '$dataTp', requestType: '$requestType' }))
    countrySelections(response ) {
        this.listCountrySelections=response;
        if (response.data) {
            this.mapSelectedCountries = new Map();
            this.mapCountries= new Map();
            if(response.data.length){
                this.gridviewDisplay=true;  
            }
            //this.processCountrySelections(response.data);
            this.validateAndProcessCountrySelections(response.data);
        } else {
            console.log(response.error);
        }
        this.loadParam=false;
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
        this.refreshGrid = false;
        for (let i = 0; i < data.length; i++) {
            let obj = { ...data[i] };
           /** if(!this.dataTypeValue){
                this.dataTypeValue=obj.DataType__c;
            } */
            if (this.mapSelectedCountries.has(obj.Country__c)) {
                let cntryObj = this.mapSelectedCountries.get(obj.Country__c);
                let mapGeos = cntryObj.mapGeos;
                let geoObj = this.getGeoObject(obj.Geography__c, obj.Country__c, true);
                mapGeos.set(obj.Geography__c, geoObj);
                
                if(!obj.VehicleType__c) {
                   continue;
                }
                obj.VehicleType__c.split(";").forEach(vt => {
                    let vtObj = this.getVehicleTypeObject(vt, obj.Geography__c, true, false);
                    vtObj.value = true;
                    let mapVehicleTypes = geoObj.mapVehicleTypes;
                    mapVehicleTypes.set(vt, vtObj);
                });
                geoObj.values = Array.from(geoObj.mapVehicleTypes.values());
                cntryObj.values = Array.from(cntryObj.mapGeos.values());
                this.mapSelectedCountries.set(obj.Country__c, cntryObj);
            } else {
                let cntryObj = this.getCountryObject(obj.Country__c, obj.Region__c, obj.Comments__c,obj.ISOCode__c);
                let geoObj = this.getGeoObject(obj.Geography__c, obj.Country__c, true);
                let mapGeos = cntryObj.mapGeos;
                mapGeos.set(obj.Geography__c, geoObj);
                obj.VehicleType__c.split(";").forEach(vt => {
                    let vtObj = this.getVehicleTypeObject(vt, obj.Geography__c, true, false);
                    vtObj.value = true;
                    let mapVehicleTypes = geoObj.mapVehicleTypes;
                    mapVehicleTypes.set(vt, vtObj);
                });
                geoObj.values = Array.from(geoObj.mapVehicleTypes.values());
                cntryObj.mapGeos = mapGeos;
                cntryObj.values = Array.from(cntryObj.mapGeos.values());
                this.mapSelectedCountries.set(obj.Country__c, cntryObj);
            }
        }
        this.prepareSupportedListsFromOptions(data);
        this.processCountryOptions(data);
        this.refreshGrid = true;
        //this.showCountryGridView();
    }
    get selectedCountryValues() {
        var selectedCountries = [];
        if (this.mapSelectedCountries) {
            selectedCountries = Array.from(this.mapCountries.values());
            selectedCountries.sort((a,b) => (a.Name  > b.Name)? 1:-1)
            return selectedCountries;
        }
        return selectedCountries;
    }
   
    prepareSupportedListsFromOptions(data) {
        var setGeos = new Set();
        var setVehicleTypes = new Set();
        var setRegions = new Set();
        for (let i = 0; i < data.length; i++) {
            let obj = { ...data[i] };

            // Get set of Geos from the Country Options. This list will be used for Header section
            obj.Geography__c.split(";").forEach(geo => {
                setGeos.add(geo);
            });

            if(!obj.VehicleType__c) {
               continue;
            }

            // Get set of Vehicletypes from the Country Options. This list will be used for Header section
            obj.VehicleType__c.split(";").forEach(vt => {
                setVehicleTypes.add(vt);
            });
        }

        /* Converting the set to arrays for usability. */
        this.listGeos = Array.from(setGeos).sort();
        this.listVehicleTypes = Array.from(setVehicleTypes).sort();
        this.selectedOptions = Array.from(setRegions).sort();
    }


    processCountryOptions(data) {
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
                cntryObj = this.getCountryObject(cntry, obj.Region__c, obj.Comments__c,obj.ISOCode__c);
                this.mapCountries.set(cntry, cntryObj);
            } else {
                cntryObj = this.mapCountries.get(cntry);
            }

            //For each Geo Process Available for selection and drill down vehicle types process Available for Selection

            this.listGeos.forEach(geo => {
                var objGeoList = obj.Geography__c.split(";");
                var geoAvialble = objGeoList.includes(geo);
                var mapTempVehicleTypes = new Map();;
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
                        opVehObj.value = this.getCountrySelection(cntry, geo, vt);
                        opVehilces.set(vt, opVehObj);
                    });

                    opGeoObj.mapVehicleTypes = opVehilces;
                    mapTempVehicleTypes = opVehilces;
                    cntryObj.mapGeos.set(geo, opGeoObj);

                } else if (cntryObj.mapGeos && cntryObj.mapGeos.has(geo)) {
                    opGeoObj = cntryObj.mapGeos.get(geo);
                    opGeoObj.mapVehicleTypes.forEach((vehicleValue, vehicleKey) => {
                        let objVehicleTypeList = obj.VehicleType__c.split(";");
                        vehicleValue.GeoName = geo;
                        if (!vehicleValue.Available) {
                            vehicleValue.Available = objVehicleTypeList.includes(vehicleKey) && geoAvialble;
                            vehicleValue.Disabled = !(objVehicleTypeList.includes(vehicleKey) && geoAvialble);
                            vehicleValue.value = this.getCountrySelection(cntry, geo, vehicleKey);
                        }
                    });
                }
                opGeoObj.values = Array.from(opGeoObj.mapVehicleTypes.values());
            }); // End of Geos Loop
            cntryObj.values = Array.from(cntryObj.mapGeos.values());
        }); // End of Countries Loop
    }

    getCountrySelection(country, geo, vehicleType) {
        let selectedCountry = this.mapSelectedCountries.get(country);
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
            return selectedVehicleType.value;
            //return false;
        }
        return false;
    }
    getCountryObject(country, regionValue, comments, isoCode) {
        
        return { Name: country, mapGeos: new Map(), values: [], Comments__c: comments, Region: regionValue , ISOCode__c:isoCode, displayName : country+(isoCode ? '-'+isoCode : '')};
    }

    getGeoObject(geo, country, available) {
        return { Name: geo, Country: country, Available: available, mapVehicleTypes: new Map(), values: [] };
    }


    getVehicleTypeObject(vehicleType, geo, available, disabled) {
        return { Name: vehicleType, GeoName: geo.Name, Country: geo.Country, vehicleKey: geo.Country + '_' + geo.Name + '_' + vehicleType, Available: available, Disabled: disabled, value: false };
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