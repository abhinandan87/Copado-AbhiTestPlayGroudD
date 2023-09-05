({
    checkUserPermission: function(component, event, helper) {
        try{
            console.log('Checking creatable permission..');
            var objAPIName;
            if(component.get('v.objectType')=='Opportunity'){
                objAPIName='Opportunity';
            }
            else if(component.get('v.objectType')=='Contact'){
                objAPIName='Contact';
            }
            var action = component.get("c.checkCreationPermission");
            action.setParams({ "objAPIName" : objAPIName })
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('Successfully fetched create permission status');
                    if(!response.getReturnValue()){
                        component.set('v.hasCreateAccess', false);
                    }
                    else{
                        component.set('v.hasCreateAccess', true);
                    }
                    console.log('Create access to the logged in user for'+objAPIName+'-->'+component.get('v.hasCreateAccess'));
                    component.set('v.showSpinner',false);
                }else if(state === "ERROR") {
                    component.set('v.hasCreateAccess', false);
                    console.log('An error has occurred.'+response.getError());
                }
                this.fetchLookupInfo(component, event, this);
            });
            $A.enqueueAction(action);
        }catch(error){
            console.log(error);
        }
    },
    fetchLookupInfo : function(component, event, helper) {
        try{
            console.log('Getting into fetchLookupInfo');
            component.set('v.showSpinner',true);
            component.set('v.justSaved',false);
            var recordId= component.get('v.recordId');
            var action = component.get("c.fetchSObjectfields");
            if (recordId !== null && recordId !== undefined && recordId.startsWith("001")) {
                action.setParams({ "recordString" : recordId });
            }
            //Logic to render Parent Account on their related lists pages//
            var currentURL=window.location.href;
            var urlpart1=currentURL.split('/lightning/r/')[1];
            var urlpart2;
            console.log(urlpart1);
            if(urlpart1!=undefined){
                console.log('Starts with 001?-->'+urlpart1.startsWith("001"));
                urlpart2=urlpart1.split('/')[1];
                if(urlpart2!=undefined){
                    var accIdFromRelatedPage=(urlpart1.split('/')[0]).toString();
                    if(urlpart1.startsWith("001") && urlpart2.startsWith('related') && (recordId=='' || recordId==null)){
                        recordId=accIdFromRelatedPage;
                        action.setParams({ "recordString" : recordId });
                    }
                }
                
            }
            //component.set('v.accId', recordId);
            //-----------------------------------------------------//
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var res=response.getReturnValue();
                    console.log('response-->'+JSON.stringify(res));
                    if(res!==null && res.Id.startsWith("001")){
                        component.set('v.currentRecord', response.getReturnValue());
                        component.set('v.accId', res.Id);
                    }
                    else{
                    	component.set('v.accId', '');
                    }
                    this.hideSpinner(component);
                }else if(state === "ERROR") {
                    console.log('An error has occurred.'+response.getError());
                }
                
            });
            $A.enqueueAction(action);
        }catch(error){
            console.log(error);
        }
    },
    fetchBudgetValues: function(component, event, helper) {
        console.log('Fetching budget values...');
        var action = component.get("c.fetchPickListValues");
        action.setParams({ 
            "objectAPIName" : "Opportunity",
            "fieldAPIName" : "BudgetRange__c"
        });
        var inputStageName = component.find("InputStageName");
        var budgetOptions=[];
        budgetOptions.push({label: '--None--', value: '--None--'});
        action.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                budgetOptions.push({label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            component.set('v.budgetValues',budgetOptions);
        });
        $A.enqueueAction(action); 
    },
    fetchBusinessSegment: function(component, event, helper) {
        console.log('Fetching BusinessSegment...');
        var action = component.get("c.fetchPickListValues");
        action.setParams({ 
            "objectAPIName" : "Contact",
            "fieldAPIName" : "BusinessSegment__c"
        });
        var businessSegmentOptions=[];
        businessSegmentOptions.push({label: '--None--', value: '--None--'});
        action.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                businessSegmentOptions.push({label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            component.set('v.businessSegment',businessSegmentOptions);
        });
        $A.enqueueAction(action); 
    },
     fetchJobTitle: function(component, event, helper) {
        console.log('Fetching Job Title...');
        var action = component.get("c.fetchPickListValues");
        action.setParams({ 
            "objectAPIName" : "Contact",
            "fieldAPIName" : "JobTitle__c"
        });
        var jobTitleOptions=[];
        jobTitleOptions.push({label: '--None--', value: '--None--'});
        action.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                jobTitleOptions.push({label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            component.set('v.jobTitle',jobTitleOptions);
        });
        $A.enqueueAction(action); 
    },
    fetchJobFunction: function(component, event, helper) {
        console.log('Fetching Job Function...');
        var action = component.get("c.fetchPickListValues");
        action.setParams({ 
            "objectAPIName" : "Contact",
            "fieldAPIName" : "JobFunction__c"
        });
        var jobFunctionOptions=[];
        jobFunctionOptions.push({label: '--None--', value: '--None--'});
        action.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                jobFunctionOptions.push({label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            component.set('v.jobFunction',jobFunctionOptions);
        });
        $A.enqueueAction(action); 
    },
    fetchGroupDesk: function(component, event, helper) {
        console.log('Fetching Group/Desk...');
        var action = component.get("c.fetchPickListValues");
        action.setParams({ 
            "objectAPIName" : "Contact",
            "fieldAPIName" : "GroupDesk__c"
        });
        var groupDeskOptions=[];
        groupDeskOptions.push({label: '--None--', value: '--None--'});
        action.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                groupDeskOptions.push({label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            component.set('v.groupDesk',groupDeskOptions);
        });
        $A.enqueueAction(action); 
    },
    handleSaveContact: function(component, event, helper) {
        var accId = component.get('v.accId');
        var fname = component.get('v.fname');
        var mname = component.get('v.mname');
        var lname = component.get('v.lname');
        var email = component.get('v.email');
        var phone = component.get('v.phone');
        var title = component.get('v.title');
        var businessSegment = component.get('v.selectedBusiness');
        var jobTitle = component.get('v.selectedJobTitle');
        var jobFunction = component.get('v.selectedJobFunction');
        var groupDesk = component.get('v.selectedGroupDesk');
        var action = component.get("c.createContact");
        action.setParams({
            "firstname": fname,
            "middlename":mname,
            "lastname": lname,
            "phone":phone,
            "email": email,
            "accId": accId,
            "title":title,
            "businessSegment":businessSegment,
            "jobTitle":jobTitle,
            "jobFunction":jobFunction,
            "groupDesk":groupDesk
        });
       var resultsToast = $A.get("e.force:showToast");
       if(component.get('v.title') == null || component.get('v.selectedBusiness') == '--None--' || component.get('v.selectedJobTitle') == '--None--' ||component.get('v.selectedJobFunction') == '--None--' ||component.get('v.selectedGroupDesk') == '--None--'){
            var errorMessage;
            errorMessage = 'Please enter contact details like Title, Business Segment, Job Title, Job Function, Group/Desk.';
                    console.log('debugging'+ errorMessage);
                    resultsToast.setParams({
                        "type": "Error",
                        "message": errorMessage,
                        "duration": "30",
                        "mode": "dismissible"
                    });
            resultsToast.fire();
            component.set('v.disableButton',false);
            component.set('v.showSpinContact',false);
           }
        else if(accId!=undefined && accId!=null  && accId!='' && accId.startsWith("001")){
            action.setCallback(this, function(response) {
                var res = response.getReturnValue();
                
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
                    /*utilityAPI.isUtilityPoppedOut({
                    }).then(function (result) {
                        setTimeout(function () { window.close();}, 4000);
                    });*/
                    //helper.fetchLookupInfo(component, event, helper);
                    component.set('v.justSaved',true);
                    component.set('v.fname',null);
                    component.set('v.mname',null);
                    component.set('v.lname',null);
                    component.set('v.phone',null);
                    component.set('v.email',null);
                    component.set('v.title',null);
                    component.set('v.selectedBusiness','--None--');
                    component.set('v.selectedJobTitle','--None--');
                    component.set('v.selectedJobFunction','--None--');
                    component.set('v.selectedGroupDesk','--None--');
                    component.set('v.showSpinContact',false);
                }else if(response.getState() === "ERROR") {
                    component.set('v.showSpinContact',false);
                    component.set('v.disableButton',false);
                    var error = response.getError();
                    var errorMessage;
                    errorMessage=error[0].message;
                    console.log(errorMessage);
                    if(errorMessage.includes('FIELD_CUSTOM_VALIDATION_EXCEPTION, ')){
                        errorMessage=errorMessage.split('FIELD_CUSTOM_VALIDATION_EXCEPTION, ')[1];
                    }
                    else{
                        if(errorMessage.includes(',')) {
                            var partToRemovefromErrorMsg = errorMessage.split(',')[0];
                            //errorMessage=errorMessage.split(',')[1];
                            errorMessage = errorMessage.replace(partToRemovefromErrorMsg, '');
                        }
                    }
                    if(errorMessage.includes('Please enter Email address or check the Email Unknown box')){
                        errorMessage='Please enter the Email address';
                    }
                    else if(errorMessage.includes('Required fields') && (lname=='' || lname==null)){
                        errorMessage='Please enter the Last Name';
                    }
                    else if(errorMessage.includes('first name') && (fname=='' || fname==null)){
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
            component.set('v.showSpinContact',false);
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
    handleSaveOpportunity: function(component, event, helper) {
        var oppyName = component.get('v.oppyName');
        var accId=component.get('v.accId');
        var budgetRange = component.get('v.selectedBudget');
        var closeDate=component.get('v.closeDate');
        var action = component.get("c.createOpportunity");
        action.setParams({
            "oppyName": oppyName,
            "accId":accId,
            "cDate": closeDate,
            "budgetRange":budgetRange,
        });
        if(accId!=undefined && accId!=null && accId!='' && accId.startsWith("001") && closeDate!=undefined && closeDate!='' && closeDate!=null){
            action.setCallback(this, function(response) {
                var res = response.getReturnValue();
                var resultsToast = $A.get("e.force:showToast");
                if (response.getState() === "SUCCESS") {
                    if(response!=null){ 
                        console.log(res.Id);
                    }
                    var successMessage='Opportunity created. Click {url} to open.'
                    var successMessageUrl = successMessage.replace('{url}', '{1}');
                    resultsToast.setParams({
                        "message": successMessageUrl,
                        "messageTemplate": successMessageUrl,
                        "messageTemplateData": ['Salesforce', {
                            url: '/'+res.Id,
                            label: oppyName	
                        }],
                        "type": "Success",
                        "duration": "60",
                        "mode": "dismissible"
                    });
                    var utilityAPI = component.find("utilitybar");
                    utilityAPI.minimizeUtility();
                    /*utilityAPI.isUtilityPoppedOut({
                    }).then(function (result) {
                        setTimeout(function () { window.close();}, 4000);
                    });*/
                    //helper.fetchLookupInfo(component, event, helper);
                    component.set('v.justSaved',true);
                    component.set('v.oppyName',null);
                    component.set('v.selectedBudget','--None--');
                    component.set('v.closeDate','');
                    component.set('v.showSpinOppy',false);
                } else if(response.getState() === "ERROR") {
                    component.set('v.showSpinOppy',false);
                    component.set('v.disableButton',false);
                    var error = response.getError();
                    var errorMessage;
                    errorMessage=JSON.stringify(error[0]);
                    if(error[0]!=undefined && error[0].message){
                        errorMessage=error[0].message;
                    }
                    if(errorMessage!=undefined && errorMessage.includes(',')){
                        errorMessage=errorMessage.split(',')[1];
                    }
                    if(errorMessage!=undefined && errorMessage.includes(':')){
                        errorMessage=errorMessage.split(':')[0];
                    }
                    if(errorMessage!=undefined && errorMessage.includes('cDate')){
                        errorMessage='Please enter correct format for Close Date.'
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
            component.set('v.showSpinOppy',false);
            component.set('v.disableButton',false);
            var resultsToast = $A.get("e.force:showToast");
            if(accId=='' || accId==undefined || accId==null || (accId!=undefined && !accId.startsWith("001")) || (accId!=null && !accId.startsWith("001"))){
                resultsToast.setParams({
                    "type": "Error",
                    "message": "Select Account.",
                    "duration": "30",
                    "mode": "dismissible"
                });
            }
            else if(closeDate==undefined || closeDate==null || closeDate==''){
                resultsToast.setParams({
                    "type": "Error",
                    "message": "Enter Close Date.",
                    "duration": "30",
                    "mode": "dismissible"
                });
            }
            resultsToast.fire();
        }
    },
    showSpinner: function(component) {
        component.set('v.showSpinner',true);
    },
    hideSpinner : function(component) {
        component.set('v.showSpinner',false);
    },
})