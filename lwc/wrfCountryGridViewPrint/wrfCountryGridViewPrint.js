import { LightningElement, track, api, wire } from 'lwc';
import getCountrySelections from '@salesforce/apex/WorkRequestFormCountryHelper.getCountrySelections';
import { refreshApex } from '@salesforce/apex';

export default class WrfCountryGridViewPrint extends LightningElement {
        @api recordId;
        @api requestType;
        @track listDataTypes = [];
        @track dataTypesList;
        refreshView = true;
        @wire(getCountrySelections, { wrfId: '$recordId', requestType: '$requestType' })
        dataTypes(response) {
            this.dataTypesList = response;
            if (response.data) {
                this.processDataTypes(response.data);
            }
        }
    
        handlePrint() {
            var url = '/apex/wrfCountrySelectionsPage?Id=' + this.recordId + '&requestType='+this.requestType;
            window.open(url, '_blank');
        }
    
        handleWindowPrint() {
            window.print();
        }
        processDataTypes(data) {
            var setDataTypes = new Set();
            this.listDataTypes = [];
            for (let i = 0; i < data.length; i++) {
                let obj = { ...data[i] };
                obj.DataType__c.split(';').forEach(dataType => {
                    setDataTypes.add(dataType);
                });
            }
            this.listDataTypes = Array.from(setDataTypes).sort();
        }
        refreshViewGrid() {
            this.refreshView = false;
            this.dataTypesList.data = undefined;
            refreshApex(this.dataTypesList);
            if (this.dataTypesList.data) {
                this.processDataTypes(this.dataTypesList.data);
            }
            let childCmps = this.template.querySelectorAll('c-wrf-request-type-country-grid-view');
            childCmps.forEach(cmp => {
                cmp.refreshCountryViewGrid();
            });
            this.refreshView = true;
        }
    }