({
    /*
     * This methid takes recordTypeId and entityTypeName parameters
     * and invoke standard force:createRecord event to create record
     * if recordTypeIs is blank, this will create record under master recordType
     * */
    showCreateRecordModal : function(component, recordTypeId, entityApiName) {
        console.log('recordTypeId----- ',recordTypeId,'------------entityApiName------------  ',entityApiName);
        var createRecordEvent = $A.get("e.force:createRecord");
        if(createRecordEvent){ //checking if the event is supported
            if(recordTypeId){//if recordTypeId is supplied, then set recordTypeId parameter
                var oppty=component.get("v.oppty");
                createRecordEvent.setParams({
                    "entityApiName": entityApiName,
                    "recordTypeId": recordTypeId,
                      "defaultFieldValues": {
               			"OpportunityName__c" : oppty.Id,
                        "FormType__c" : component.find("recordTypePickList").get("v.value"),
                        "Name" : oppty.Name + ' - ' + 'WRF',
                        "OpportunityNumber__c" : oppty.Opportunitynum__c,
                        "PrimarySalesContact__c" : oppty.OwnerId,
                        "Revenue__c" : oppty.Amount, 
                        "AccountName__c" : oppty.AccountId,
                        "CostCenter__c" : oppty.CostCenter__c,
                        "UltimateCustomeracct__c" : oppty.AISUltimateClient__c,
                        "CurrencyISOCode" : oppty.CurrencyIsoCode,
                        "Internal__c" : false
                    }
                  
                });
            } else{//else create record under master recordType
                createRecordEvent.setParams({
                    "entityApiName": entityApiName
                   /** "defaultFieldValues": {
                          "AccountId": component.get("v.recordId")
                    }**/
                });
            }
            createRecordEvent.fire();
        } else{
            alert('This event is not supported');
        }
    },
    /*
     * closing quickAction modal window
     * */
    closeModal : function(){
        var closeEvent = $A.get("e.force:closeQuickAction");
        if(closeEvent){
        closeEvent.fire();
        } else{
            alert('force:closeQuickAction event is not supported in this Ligthning Context');
        }
    },
})