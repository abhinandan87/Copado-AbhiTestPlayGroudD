({
    doInit : function (component, event,helper) {
        var action  = component.get("c.getContractInfo");
        action.setParams({
            "conId": component.get("v.recordId")
        });
        action.setCallback(this,function (a){
            var state = a.getState();
            if (component.isValid() && state === "SUCCESS") {
                console.log('data return from class!!!'+ a.getReturnValue());
                var wrpCont =  a.getReturnValue();
                var cont = wrpCont.con;
                console.log('AccountId in doInit!!!'+ cont.AccountId);
                component.set("v.AccountID",cont.AccountId);
                component.set("v.OppID",cont.Opportunity__c);
                component.set("v.RecordTypeName",cont.RecordTypeName__c);
                var contractId = cont.Id;
                var sessionid = wrpCont.sessionid;
                //SFDC-4575 - Disable Document Generation for MAs and NDAs for MarkitServ Entities
                var errLegalEntity = false;
                if(cont.RecordTypeName__c === 'NDA' || cont.RecordTypeName__c === 'Master Agreement') {
                    var legalEntities = $A.get("$Label.c.MarkitServLegalEntities");
                    var legalEntitiesArr = legalEntities.split(',');
                    for (var i=0; i<legalEntitiesArr.length; i++) {
                        if(legalEntitiesArr[i].trim() === cont.IHSMarkitLegalEntity__r.Name.trim()) {
                            errLegalEntity = true;
                            break;
                        }
                    }
                }
                if(errLegalEntity) {
                    component.set("v.showError",true);
                    var errMsg = $A.get("$Label.c.GenerateDocumentErrorLegalEntity");
                    component.set("v.errorMessage",errMsg);
                } else {
                    if((cont.GeneralAgreementType__c==undefined || cont.GeneralAgreementType__c==null
                        || cont.GeneralAgreementType__c=='') && cont.Fastrack__c==false && cont.RecordTypeName__c === 'Order Form'){
                        component.set("v.showError",true);
                        var errMsg = $A.get("$Label.c.GenerateDocumentError");
                        component.set("v.errorMessage",errMsg);
                    } else if (cont.BillingFrequency__c==undefined || cont.BillingFrequency__c==null || cont.BillingFrequency__c==''){
                        component.set("v.showError",true);
                        var errMsg =  $A.get("$Label.c.BillingFrequencyError");
                        component.set("v.errorMessage",errMsg);
                    }
                    else{
                        component.set("v.showError",false);
                        var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        dismissActionPanel.fire();
                        var accountId=component.get("v.AccountID");
                        var contractId=component.get("v.recordId");
                        var oppId = component.get("v.OppID");
                        var recTypeId = component.get("v.RecordTypeName");
                        var buttonLabel=component.get("v.quickActionName");
                        //SFDC-4575 - Check for undefined values
                        if(oppId == null) {
                            oppId = '';
                        }
                        if(accountId == null) {
                            accountId = '';
                        }
                        if(buttonLabel=='GenerateDocument'){
                            helper.GenerateDocument(component,event,helper,accountId,contractId,oppId,recTypeId);
                        }
                        else if(buttonLabel=='SendWithDocuSign'){
                            helper.SendWithDocuSign(component,event,helper,sessionid,accountId,contractId,oppId,recTypeId);
                        }
                        else if(buttonLabel=='GenerateDistributorOrderForms'){
                             helper.GenerateDistributorOF(component,event,helper,accountId,contractId,oppId,recTypeId);
                        }	
                        else if(buttonLabel=='GenerateDistributorOrderFormsWord'){
                              helper.GenerateDistributorOFWord(component,event,helper,accountId,contractId,oppId,recTypeId);
                        }
                        else if(buttonLabel=='ConPreviewDocuments'){
                                console.log('Preview Doc in condition'+accountId);
                               helper.PreviewDocuments(component,event,helper,accountId,contractId,oppId,recTypeId);
                        }
                        else if(buttonLabel=='ConConvertToWord'){
                                helper.ConvertToWord(component,event,helper,accountId,contractId,oppId,recTypeId);
                        }
                    }
                }    
            }
            else if(a.getState() == "ERROR"){
                console.log("callback error", a.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
})