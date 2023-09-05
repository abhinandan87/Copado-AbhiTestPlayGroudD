import { LightningElement,api } from 'lwc';
import getColumns from '@salesforce/apex/HierarchyController.getColumns';
import hierarchyData from '@salesforce/apex/HierarchyController.getHierarchyAccounts';
import sendErrorEmail from '@salesforce/apex/AccountLandingPageController.sendErrorEmail';

export default class HierarchyMainTab extends LightningElement {

    @api accountMap = {};
    accounts = [];
    accountExpandedRows = [];
    accountColumns = [];
    currentUrl = '';

    connectedCallback(){
        this.currentUrl = window.location.href;
        // To get the columns on load
        this.getColumns();
    }

    getColumns(){
        // To fetch the columns
        getColumns()
        .then(data => {
                if (data) {
                    let cols = [];
                    // Add first column as Name 
                    // let accountUrl = 'https://' + location.host + '/';
                    //Make the Account name field an URL (accURL - that will will populated in the getHierarchyData() function) column and opening up in a separate tab (using target : '_blank')

                    cols[0] = { type: 'String',  fieldName : 'Name', label : 'Account Name', initialWidth: 180,
                        cellAttributes : {iconName :{fieldName : 'currentRecord'}, iconPosition : 'right',variant : 'brand' } };
                    cols[1] = { type: 'url',  fieldName : 'accUrl', label : '', initialWidth: 2, 
                                   typeAttributes : { label : 'View', target : '_blank'}};
                
                    for(var i=2;i<=data.length+1;i++){
                        cols[i] = data[i-2];
                    }

                    this.accountColumns = cols;
                    //Get the hierarchy data
                     this.getHierarchyData();
                };
            })
            .catch(error => {
                console.log('Error getting columns in hierarchy tab', error);
            })
    }

    // To get the accounts parent and child up to 5 levels
    getHierarchyData(){
        hierarchyData({accountId : this.accountMap.Id, windowUrl: this.currentUrl})
         .then(data => {
                if (data) {
                        let result = data;
                        let expandedAccounts = [];
                        let accounts = {};
                        accounts[undefined] = {Name : "Root" , _children : []};
            
                        const acctId = this.accountMap.Id;
                        const parentAccId = this.accountMap.ParentId;
                        let baseUrl = 'https://'+location.host+'/';
                        result.forEach(accRec => {
                            if(accRec.Id !== acctId && accRec.DivisionId){
                                accRec.accUrl = baseUrl+accRec.DivisionId; //Add the accURL to the data
                            }
                        });
                        
                        result.forEach(function(accRecord){
                            accounts[accRecord.Id] = accRecord;
                            accounts[accRecord.Id].currentRecord = accounts[accRecord.Id].Id === acctId ? 'utility:pinned' : 'novalue';
                        });
                        let expandRows = false;

                        result.forEach(function(accRecord){

                                if(accRecord.Id === parentAccId || expandRows === true){
                                        expandedAccounts.push(accRecord.Name);
                                        expandRows = true;
                                }

                                if(accounts[accRecord.ParentId]){
                                        accounts[accRecord.ParentId]._children = [];  
                                }
                        });

                        result.forEach(function(accRecord){
                            accounts[accRecord.ParentId]._children.push(accounts[accRecord.Id]);
                        });

                        // Sort the accounts based on total acv
                        result.forEach(function(accRecord){
                            accounts[accRecord.ParentId]._children.sort(function (rec1,rec2){
                                let rec1Acv=rec1.Total_ACV__c;
                                let rec2Acv = rec2.Total_ACV__c;
                                return rec1Acv==rec2Acv ? 0 : rec1.Total_ACV__c > rec2.Total_ACV__c ? -1 : 1;
                                
                            });
                        });

                        this.accounts=accounts[undefined]._children;
                            this.accountExpandedRows=expandedAccounts;
                        };
            })
            .catch(error => {
                let errorMap = this.generateErrorMap(error);
                sendErrorEmail({errorObject: errorMap});
                console.log('Error getting the hierarchy data', error);
            })
    }


    generateErrorMap(error){
        let errorMap = {
            'Url': this.currentUrl,
            'Error': error.body.message,
            'StatusCode': 'Callout not made.'
        }

        return errorMap;
    }
}