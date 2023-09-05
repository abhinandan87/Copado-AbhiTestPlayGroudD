({
    handleOnSubmit : function(component, event, helper) {
        var programmer = component.get("v.programmer");        
        var sObjectName = component.get("v.sObjectName");
        if(programmer=='' || programmer===undefined||programmer===null){
            var toastEvent = $A.get("e.force:showToast");
            if(sObjectName==='ChangeLog__c'){
                toastEvent.setParams({        
                    "message": "Programmer field is blank",
                    "type": 'error',
                });
            }
            else if(sObjectName==='WorkRequestForm__c'){
                toastEvent.setParams({        
                    "message": "Programmer Assigned field is blank",
                    "type": 'error',
                });   
            }
            toastEvent.fire();
            
        }
        else{
            component.find("editForm").submit();
            component.set('v.loaded',true);      
        }
        
    },    
    handleSuccess : function(component, event, helper) {
        component.set('v.loaded',false);
        var sObjectName = component.get("v.sObjectName");
        //Redirect to detail page on success
        var payload = event.getParams().response;
        var navService = component.find("navService");
        if(sObjectName==='ChangeLog__c'){
            var pageReference = {
                type: 'standard__recordPage',
                attributes: {
                    "recordId": payload.id,
                    "objectApiName": component.get("v.ChangeLog__c"),
                    "actionName": "view"
                }
            }  
            }
        else if(sObjectName==='WorkRequestForm__c'){
            var pageReference = {
                type: 'standard__recordPage',
                attributes: {
                    "recordId": payload.id,
                    "objectApiName": component.get("v.WorkRequestForm__c"),
                    "actionName": "view"
                }
            }  
            }
        
        event.preventDefault();
        navService.navigate(pageReference);         
        var param = event.getParams();
        var fields = param.response.fields;
        var recordName = fields.Name.value;       
        var toastEvent = $A.get("e.force:showToast");
        if(sObjectName==='ChangeLog__c'){
            toastEvent.setParams({        
                "message": "Change Log \""+recordName+"\" was saved",
                "type": 'success',
            });
        }
        else if(sObjectName==='WorkRequestForm__c'){
            toastEvent.setParams({        
                "message": "Work Request Form \""+recordName+"\" was saved",
                "type": 'success',
            });  
        }
        toastEvent.fire(); 
      },
    
    handleCancel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        $A.get("e.force:closeQuickAction").fire() 
    },
    //Added as fix for SFDC-4981
     handleOnLoad: function(component, event, helper){
      var sObjectName = component.get("v.sObjectName");
      if(sObjectName==='ChangeLog__c'){
      var recUi = event.getParam("recordUi");      
      var programmerVal = recUi.record.fields["Programmer__c"].value;      
       component.set('v.programmer',programmerVal);  
      }
      else if(sObjectName==='WorkRequestForm__c'){
      var recUi = event.getParam("recordUi");      
      var programmerAssigned = recUi.record.fields["ProgrammerAssigned__c"].value;      
       component.set('v.programmer',programmerAssigned);
        }
      
    }
})