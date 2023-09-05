({
    init: function (component, event, helper) {
        setTimeout(function () {
        	var utilityBarAPI = component.find("utilitybar");
            utilityBarAPI.toggleModalMode(true);
            var eventHandler = function (response) {
                component.set('v.disableButton',false);
                if(component.get('v.accId')!=undefined && component.get('v.recordId')!=null && component.get('v.recordId')!=undefined && component.get('v.accId')==component.get('v.recordId') && !component.get('v.justSaved')) {
            		console.log('Do not refresh the component');
                }	
                else{
                    component.set('v.accId',null);
                    helper.fetchRecordInfo(component, event, helper);
                 }
            }
            utilityBarAPI.onUtilityClick({
                eventHandler: eventHandler
            }).then(function (result) {
                console.log(result);
            }).catch(function (error) {
                console.log(error);
            });
            utilityBarAPI.isUtilityPoppedOut({
            }).then(function (result) {
                helper.fetchRecordInfo(component, event, helper);
            });
		}, 1);
    },
    handleSaveContact: function(component, event, helper) {
        var utilityBarAPI = component.find("utilitybar");	
        console.log('Get account id selected--->'+component.get('v.accId'));
        component.set('v.disableButton',true);
        var fname = component.find("firstname").get("v.value");
        var mname = component.find("middlename").get("v.value");
        var lname = component.find("lastname").get("v.value");
        var email = component.find("email").get("v.value");
        var phone = component.find("phone").get("v.value");
        var accId=component.get('v.accId');
        var title = component.find("title").get("v.value");
 		var action = component.get("c.createContact");
 		action.setParams({
            "firstname": fname,
            "middlename":mname,
            "lastname": lname,
            "phone":phone,
            "email": email,
            "accId": accId,
            "title":title
        });
        if(accId!=undefined && accId!=null && accId.startsWith("001")){
            action.setCallback(this, function(response) {
                var res = response.getReturnValue();
                var resultsToast = $A.get("e.force:showToast");
                if (response.getState() === "SUCCESS") {
                    if(response!=null){ 
                        console.log(res.Id);
                    }
                    var successMessage='Contact created. Click {url} to open.'
                    var successMessageUrl = successMessage.replace('{url}', '{1}');
                    resultsToast.setParams({
                        "message": successMessageUrl,
                        "messageTemplate": successMessageUrl,
                        "messageTemplateData": ['Salesforce', {
                            url: '/'+res.Id,
                            label: fname+' '+lname	
                         }],
                        "type": "Success",
                        "duration": "60",
                        "mode": "dismissible"
                    });
                    var utilityAPI = component.find("utilitybar");
                    utilityAPI.minimizeUtility();
                    utilityBarAPI.isUtilityPoppedOut({
                    }).then(function (result) {
                       setTimeout(function () { window.close();}, 4000);
                    });
                    helper.fetchRecordInfo(component, event, helper);
                    component.set('v.justSaved',true);
                    
                } else if(response.getState() === "ERROR") {
                    component.set('v.disableButton',false);
                    var error = response.getError();
                    var errorMessage;
                    errorMessage=error[0].message;
                    errorMessage=errorMessage.split(',')[1];
                    if(errorMessage.includes('Please enter Email address or check the Email Unknown box')){
                        errorMessage='Please enter the Email address';
                    }
                    else if(errorMessage.includes('Required fields') && lname==''){
                        errorMessage='Please enter the Last Name';
                    }
                    else if(errorMessage.includes('first name') && fname==''){
                        errorMessage='Please enter the First Name';
                    }
                    else if(errorMessage.includes('Please select the existing contact or update the information for the new contact')){
                        errorMessage='A contact already exists with this email address.';
                    }
                    resultsToast.setParams({
                        "type": "Error",
                        "message": errorMessage,
                        "duration": "30",
                        "mode": "dismissible"
                    });
                    
                }
                resultsToast.fire();
            });
        	$A.enqueueAction(action);
        }
        else{
            component.set('v.disableButton',false);
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                        "type": "Error",
                        "message": "Select Account.",
                        "duration": "30",
                        "mode": "dismissible"
            });
            resultsToast.fire();
        }
    },
    fetchAccountId : function(component,event,helper) {
        console.log('Account ID changed-->'+component.get('v.accId'));
    }
})