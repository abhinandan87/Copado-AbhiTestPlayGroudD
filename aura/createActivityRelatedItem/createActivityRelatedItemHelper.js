({
    fetchLookupInfo : function(component, event, helper) {
        try{
            component.set('v.showSpinner',true);
            component.set('v.justSaved',false);
            component.set('v.contactRecord',null);
            component.set('v.accRecord',null);
            component.set('v.oppRecord',null);
            component.set('v.accId','');
            component.set('v.oppId','');
            component.set('v.contactId','');
            
            component.set('v.selectedRelatedToType','Account');
            var tempConId;
            var tempAccId;
            var tempOppId;
            var recordId= component.get('v.recordId');
            var action = component.get("c.fetchSObjectfields");
            if(recordId !== null && recordId.startsWith("00U")==false){
                component.set('v.eventWhatId','');
            }
            if(recordId !== null && recordId.startsWith("00T")==false){
                component.set('v.taskWhatId','');
            }
            if (recordId != null && recordId != undefined && recordId.startsWith("003")) {
                tempConId=recordId;
                action.setParams({ "recordString" : tempConId });
            }
            if (recordId !== null && recordId !== undefined && recordId.startsWith("001")) {
                tempAccId=recordId;
                action.setParams({ "recordString" : tempAccId });
                //component.set('v.selectedRelatedToType','Account');
            }
            if (recordId !== null && recordId !== undefined && recordId.startsWith("006")) {
                tempOppId=recordId;
                action.setParams({ "recordString" : tempOppId });
                //component.set('v.selectedRelatedToType','Opportunity');
            }
            //Logic to render Parent Account on their related lists pages//
            var currentURL=window.location.href;
            var urlpart1=currentURL.split('/lightning/r/')[1];
            var urlpart2;
            console.log(urlpart1);
            if(urlpart1!==undefined){
                urlpart2=urlpart1.split('/')[1];
                if(urlpart2!==undefined){
                    var accIdFromRelatedPage=(urlpart1.split('/')[0]).toString();
                    if(urlpart1.startsWith("003") && urlpart2.startsWith('related') && (recordId==='' || recordId===null)){
                        recordId=accIdFromRelatedPage;
                        action.setParams({ "recordString" : recordId });
                        tempConId=recordId;
                    }
                    if(urlpart1.startsWith("001") && urlpart2.startsWith('related') && (recordId==='' || recordId===null)){
                        recordId=accIdFromRelatedPage;
                        action.setParams({ "recordString" : recordId });
                        tempAccId=recordId;
                        //component.set('v.selectedRelatedToType','Account');
                    }
                    if(urlpart1.startsWith("006") && urlpart2.startsWith('related') && (recordId==='' || recordId===null)){
                        recordId=accIdFromRelatedPage;
                        action.setParams({ "recordString" : recordId });
                        tempOppId=recordId;
                        //component.set('v.selectedRelatedToType','Opportunity');
                    }
                }
                
            }
            //-----------------------------------------------------//
            if(component.get('v.eventWhatId')!==null){
                if(component.get('v.eventWhatId').startsWith("001")){
                    tempAccId=component.get('v.eventWhatId');
                    action.setParams({ "recordString" : tempAccId });
                    //component.set('v.selectedRelatedToType','Account');
                }
                else if(component.get('v.eventWhatId').startsWith("006")){
                    tempOppId=component.get('v.eventWhatId');
                    action.setParams({ "recordString" : tempOppId });
                    //component.set('v.selectedRelatedToType','Opportunity');
                }
            }
            if(component.get('v.taskWhatId')!==null){
                if(component.get('v.taskWhatId').startsWith("001")){
                    tempAccId=component.get('v.taskWhatId');
                    action.setParams({ "recordString" : tempAccId });
                    //component.set('v.selectedRelatedToType','Account');
                }
                else if(component.get('v.taskWhatId').startsWith("006")){
                    tempOppId=component.get('v.taskWhatId');
                    action.setParams({ "recordString" : tempOppId });
                    //component.set('v.selectedRelatedToType','Opportunity');
                }                
            }
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var res=response.getReturnValue();
                    if(res!==null && res.Id.startsWith("003")){
                        component.set('v.contactRecord', response.getReturnValue());
                        console.log(component.get('v.contactRecord'));
                        component.set('v.contactId', res.Id);
                    }
                    if(res!==null && res.Id.startsWith("001")){
                        component.set('v.accRecord', response.getReturnValue());
                        console.log(component.get('v.accRecord'));
                        component.set('v.accId', res.Id);
                        component.set('v.selectedRelatedToType','Account');
                    }
                    if(res!==null && res.Id.startsWith("006")){
                        component.set('v.oppRecord', response.getReturnValue());
                        console.log(component.get('v.oppRecord'));
                        component.set('v.oppId', res.Id);
                        component.set('v.selectedRelatedToType','Opportunity');
                    }
                    if(res!==null && recordId !== undefined && recordId !== null && (recordId.startsWith("00U")==true || recordId.startsWith("00T")==true)){
                        if(res.Id.startsWith("001")){
                            component.set('v.selectedRelatedToType','Opportunity');
                            component.set('v.selectedRelatedToType','Account');
                        }
                        else if(res!==null && res.Id.startsWith("006")){
                            component.set('v.selectedRelatedToType','Account');
                            component.set('v.selectedRelatedToType','Opportunity');
                        }
                    }
                    if(res===null){
                        component.set('v.oppId', '');
                        component.set('v.accId', '');
                        component.set('v.contactId', '');
                        component.set('v.taskWhatId','');
                        component.set('v.taskWhatId','');
                    }
                    var userId=$A.get("$SObjectType.CurrentUser.Id");
                    if(component.get('v.userId')!= userId){
                        component.set('v.userId','');
                        this.fetchCurrentUser(component, event, this);
                    }
                    if(component.get('v.initLoad')===true){
                        this.checkUserPermission(component, event, helper);
                    }else{
                        component.set('v.showSpinner',false);
                    }
                }else if(state === "ERROR") {
                    console.log('An error has occurred.'+response.getError());
                    component.set('v.showSpinner',false);
                }
            });
            $A.enqueueAction(action);
        }catch(error){
            console.log(error);
        }
    },
    checkEventCreatePermission: function(component, event, helper) {
        component.set('v.showSpinner',true);
        var action = component.get("c.checkCreationPermission");
        action.setParams({ "objAPIName" : "Event" })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(!response.getReturnValue()){
                    component.set('v.hasEventCreateAccess', false);
                }
                else{
                    component.set('v.hasEventCreateAccess', true);
                }
                console.log('Create access to the logged in user for Event-->'+component.get('v.hasEventCreateAccess'));
                this.checkTaskCreatePermission(component, event, this);
                component.set('v.showSpinner',true);
            }else if(state === "ERROR") {
                component.set('v.hasEventCreateAccess', false);
                console.log('An error has occurred.'+response.getError());
            }
        });
        $A.enqueueAction(action);
        
    },
    checkTaskCreatePermission: function(component, event, helper) {
        component.set('v.showSpinner',true);
        var action = component.get("c.checkCreationPermission");
        action.setParams({ "objAPIName" : "Task" })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(!response.getReturnValue()){
                    component.set('v.hasTaskCreateAccess', false);
                }
                else{
                    component.set('v.hasTaskCreateAccess', true);
                }
                console.log('Create access to the logged in user for Task-->'+component.get('v.hasTaskCreateAccess'));
                /*if(component.get('v.recordId')!=undefined && component.get('v.recordId')!=null){
                    if(component.get('v.recordId').startsWith("00U")){
                        if(component.get('v.eventWhatId')==''){
                        	this.fetchEventWhatId(component, event, this);
                        }
                    }
                    else if(component.get('v.recordId').startsWith("00T")){
                        if(component.get('v.taskWhatId')==''){
                        	this.fetchTaskWhatId(component, event, this);
                        }
                    }
                        else{
                            component.set('v.showSpinner',false);
                        }
                }
                else{
                    component.set('v.showSpinner',false);
                }*/
                component.set('v.showSpinner',false);
                console.log('showspinner--->'+component.get('v.showSpinner'));
            }else if(state === "ERROR") {
                component.set('v.hasTaskCreateAccess', false);
                console.log('An error has occurred.'+response.getError());
            }
        });
        $A.enqueueAction(action);
        
    },
    fetchBudgetValues: function(component, event, helper) {
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
        });
        $A.enqueueAction(action); 
    },
    fetchEventSubjectValues: function(component, event, helper) {
        console.log('Fetching Event Subject Values...');
        var inputEventSubjectType = component.find("EventSubjectType");
        var typeOptions=[];
        typeOptions.push({label: '--None--', value: '--None--'});
        var action = component.get("c.fetchPickListValues");
        action.setParams({ 
            "objectAPIName" : "Event",
            "fieldAPIName": "Subject"
        });
        action.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                typeOptions.push({label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            //component.set('v.eventSubjectTypes',typeOptions);
        });
        $A.enqueueAction(action); 
    },    
    fetchTaskSubjectValues: function(component, event, helper) {
        console.log('Fetching Task Subject Values...');
        var subjectOptions=[];
        subjectOptions.push({label: '--None--', value: '--None--'});
        var action = component.get("c.fetchPickListValues");
        action.setParams({ 
            "objectAPIName" : "Task",
            "fieldAPIName": "Subject"
        });
        action.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                subjectOptions.push({label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            //component.set('v.taskSubjectTypes',subjectOptions);
        });
        $A.enqueueAction(action);
    },
    fetchTaskPriorityValues: function(component, event, helper) {
        //component.set('v.showSpinner',true);
        console.log('Fetching Task Priority Values...');
        var inputTaskPriority = component.find("priority");
        var priorityOptions=[];
        var action = component.get("c.fetchPickListValues");
        action.setParams({ 
            "objectAPIName" : "Task",
            "fieldAPIName": "Priority"
        });
        action.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                priorityOptions.push({label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            component.set('v.taskPriorityValues',priorityOptions);
            //component.set('v.showSpinner',false);
        });
        $A.enqueueAction(action); 
    },
    fetchTaskStatusValues: function(component, event, helper) {
        //component.set('v.showSpinner',true);
        console.log('Fetching Task Status Values...');
        var inputTaskStatus = component.find("status");
        var statusOptions=[];
        var action = component.get("c.fetchPickListValues");
        action.setParams({ 
            "objectAPIName" : "Task",
            "fieldAPIName": "Status"
        });
        action.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                statusOptions.push({label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            component.set('v.taskStatusValues',statusOptions);
            //component.set('v.showSpinner',false);
        });
        $A.enqueueAction(action); 
    },
    fetchActivitySubTypeValues: function(component, event, helper) {
        //component.set('v.showSpinner',true);
        console.log('Fetching Activity Sub-Type Values...');
        var inputActivityValues = component.find("subType");
        var subTypeOptions=[];
        var action = component.get("c.fetchPickListValues");
        action.setParams({
            "objectAPIName" : "Task",
            "fieldAPIName": "SubType__c"
        });
        action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            var activityMap = [];
            for(var key in result){
                activityMap.push({key: key, value: result[key]});
            }
            //console.log("cObj in String Format===>"+JSON.stringify(result) );
            component.set("v.activitySubTypeValues", activityMap);
        });
        $A.enqueueAction(action);
    },
    checkUserPermission: function(component, event, helper) {
        component.set('v.initLoad', false);
        this.checkEventCreatePermission(component, event, helper);
    },
    showSpinner: function(component) {
        component.set('v.showSpinner',true);
    },
    hideSpinner : function(component) {
        component.set('v.showSpinner',false);
    },
    handleSaveEvent : function(component, event, helper) {
        if(component.get('v.subject')!='' && component.get('v.subject')!=null && component.get('v.subject').trim()!==''){
            var WhatId=null;
            if(component.get('v.selectedRelatedToType')=='Account' && component.get('v.accId')!=null && component.get('v.accId')!='' && component.get('v.accId').startsWith('001')){
                WhatId=component.get('v.accId');
            }
            else if(component.get('v.selectedRelatedToType')=='Opportunity' && component.get('v.oppId')!=null && component.get('v.oppId')!='' && component.get('v.oppId').startsWith('006')){
                WhatId=component.get('v.oppId');
            }
            var obj = { eventType: component.get('v.selectedType'), eventSubject: component.get('v.subject'), eventSubType: component.get('v.subType'), eventWhoId: component.get('v.contactId'), eventWhatId: WhatId, StartDateTime:component.get('v.eventStartTime'), EndDateTime: component.get('v.eventEndTime'), OwnerId:component.get('v.userId'), Location:component.get('v.eventLocation')};
            var myEventJSON = JSON.stringify(obj);
            var action=component.get("c.createEvent");
            action.setParams({ 
                "eventJSONString" : myEventJSON
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var res = response.getReturnValue();
                    if(response!=null){ 
                        console.log(res.Id);
                    }
                    var successMessage='Event {url} is created.'
                    var successMessageUrl = successMessage.replace('{url}', '{1}');
                    if(component.get('v.addMoreDetail')==true){
                        window.parent.location='/'+res.Id ;
                    }
                    else{
                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            "message": successMessageUrl,
                            "messageTemplate": successMessageUrl,
                            "messageTemplateData": ['Salesforce', {
                                url: '/'+res.Id,
                                label: res.Subject	
                            }],
                            "type": "Success",
                            "duration": "60",
                            "mode": "dismissible"
                        });
                        resultsToast.fire();
                    }
                    component.set('v.showSpinActivity',false);
                    var utilityAPI = component.find("utilitybar");
                    utilityAPI.minimizeUtility();
                    component.set('v.justSaved',true);
                    component.set('v.selectedType','Meeting');
                    component.set('v.subject','');
                    component.set('v.accId','');
                    component.set('v.oppId','');
                    component.set('v.contactId','');
                    component.set('v.eventStartTime','');
                    component.set('v.eventEndTime','');
                    component.set('v.eventLocation','');
                    component.set('v.taskDueDate','');
                    component.set('v.priority','');
                    component.set('v.taskDueDate','');
                    component.set('v.showSpinActivity',false);
                    component.set('v.subType','');
                    var userId=$A.get("$SObjectType.CurrentUser.Id");
                    if(component.get('v.userId')!= userId){
                        this.fetchCurrentUser(component, event, this);
                    }
                }
                else if(state === "ERROR"){
                    component.set('v.showSpinActivity',false);
                    component.set('v.disableButton',false);
                    component.set('v.disableButton1',false);
                    var resultsToast = $A.get("e.force:showToast");
                    var error = response.getError();
                    var errorMessage;
                    errorMessage=JSON.stringify(error[0]);
                    if(error[0]!=undefined && error[0].message){
                        errorMessage=error[0].message;
                    }
                    if(errorMessage!=undefined && errorMessage.includes(',')){
                        errorMessage=errorMessage.split(',')[1];
                    }
                    if(errorMessage!=undefined && errorMessage.includes('Attempt to de-reference a null object')){
                        errorMessage='Please enter start and end time.'
                    }
                    if(errorMessage!=undefined && errorMessage.includes('Invalid id:') && component.get('v.selectedType')!='Task'){
                        errorMessage='Please assign the event to a user.'
                    }
                    resultsToast.setParams({
                        "type": "Error",
                        "message": errorMessage,
                        "duration": "30",
                        "mode": "dismissible"
                    });
                    resultsToast.fire();
                }
                
            });
            $A.enqueueAction(action); 
        }
        else{
            component.set('v.disableButton',false);
            component.set('v.disableButton1',false);
            component.set('v.showSpinActivity',false);
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "type": "Error",
                "message": "Enter Subject.",
                "duration": "30",
                "mode": "dismissible"
            });
            resultsToast.fire();
        }
    },
    handleSaveTask : function(component, event, helper) {
        if(component.get('v.subject')!='' && component.get('v.subject')!=null && component.get('v.subject').trim()!==''){
            var WhatId='';
            if(component.get('v.selectedRelatedToType')=='Account' && component.get('v.accId')!=null && component.get('v.accId')!='' && component.get('v.accId').startsWith('001')){
                WhatId=component.get('v.accId');
            }
            else if(component.get('v.selectedRelatedToType')=='Opportunity' && component.get('v.oppId')!=null && component.get('v.oppId')!='' && component.get('v.oppId').startsWith('006')){
                WhatId=component.get('v.oppId');
            }
            var obj = { taskType: component.get('v.selectedType'), taskSubject: component.get('v.subject'), taskSubType: component.get('v.subType'), taskWhoId:component.get('v.contactId'), taskWhatId: WhatId, OwnerId: component.get('v.userId'), ActivityDate: component.get('v.taskDueDate'), Priority: component.get('v.priority'), Activity:component.get('v.subType'), Status: component.get('v.status') };
            var myTaskJSON = JSON.stringify(obj);
            var action=component.get("c.createTask");
            action.setParams({ 
                "taskJSONString" : myTaskJSON
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var res = response.getReturnValue();
                    if(response!=null){ 
                        console.log(res.Id);
                    }
                    var resultsToast = $A.get("e.force:showToast");
                    var successMessage='Task {url} is created.'
                    var successMessageUrl = successMessage.replace('{url}', '{1}');
                    resultsToast.setParams({
                        "message": successMessageUrl,
                        "messageTemplate": successMessageUrl,
                        "messageTemplateData": ['Salesforce', {
                            url: '/'+res.Id,
                            label: res.Subject	
                        }],
                        "type": "Success",
                        "duration": "60",
                        "mode": "dismissible"
                    });
                    resultsToast.fire();
                    
                    component.set('v.showSpinActivity',false);
                    var utilityAPI = component.find("utilitybar");
                    utilityAPI.minimizeUtility();
                    utilityAPI.isUtilityPoppedOut({
                    }).then(function (result) {
                        setTimeout(function () { window.close();}, 4000);
                    });
                    component.set('v.justSaved',true);
                    component.set('v.selectedType','Meeting');
                    component.set('v.subject','');
                    component.set('v.accId','');
                    component.set('v.oppId','');
                    component.set('v.contactId','');
                    component.set('v.eventStartTime','');
                    component.set('v.eventEndTime','');
                    component.set('v.eventLocation','');
                    component.set('v.taskDueDate','');
                    component.set('v.priority','');
                    component.set('v.taskDueDate','');
                    component.set('v.showSpinActivity',false);
                    component.set('v.subType','');
                    var userId=$A.get("$SObjectType.CurrentUser.Id");
                    if(component.get('v.userId')!= userId){
                        this.fetchCurrentUser(component, event, this);
                    }
                }
                else if(state === "ERROR"){
                    component.set('v.showSpinActivity',false);
                    component.set('v.disableButton',false);
                    component.set('v.disableButton1',false);
                    var resultsToast = $A.get("e.force:showToast");
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
                    if(errorMessage!=undefined && errorMessage.includes('Invalid id') && component.get('v.selectedType')=='Task'){
                        errorMessage='Please assign the task to a user.'
                    }
                    resultsToast.setParams({
                        "type": "Error",
                        "message": errorMessage,
                        "duration": "30",
                        "mode": "dismissible"
                    });
                    resultsToast.fire();
                }
            });
            $A.enqueueAction(action);
        }
        else{
            component.set('v.disableButton',false);
            component.set('v.disableButton1',false);
            component.set('v.showSpinActivity',false);
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "type": "Error",
                "message": "Enter Subject.",
                "duration": "30",
                "mode": "dismissible"
            });
            resultsToast.fire();
        }                   
    },
    fetchEventWhatId : function(component, event, helper) {
        component.set('v.showSpinner', true);
        var eventId=component.get('v.recordId');
        var action=component.get("c.fetchEventWhatId");
        action.setParams({ 
            "eventId" : eventId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                component.set('v.eventWhatId',res);
                console.log('Event response-->'+res);
                if(component.get('v.eventWhatId')!='' || component.get('v.initLoad')===true){
                    component.set('v.showSpinner', true);
                    this.fetchLookupInfo(component,event,helper);
                }
                else{
                    component.set('v.showSpinner',false);
                }
            }
            else if(state === "ERROR"){
                console.log('Some error has occurred while fetching Event What Id:'+response.getError());
                component.set('v.showSpinner',false);
            }
        });
        $A.enqueueAction(action);
    },
    fetchTaskWhatId : function(component, event, helper) {
        component.set('v.showSpinner', true);
        var taskId=component.get('v.recordId');
        var action=component.get("c.fetchTaskWhatId");
        action.setParams({ 
            "taskId" : taskId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                component.set('v.taskWhatId',res);
                console.log('Task response-->'+res);
                if(component.get('v.taskWhatId')!='' || component.get('v.initLoad')===true){
                    component.set('v.showSpinner', true);
                    this.fetchLookupInfo(component,event,helper);
                }
                else{
                    component.set('v.showSpinner',false);
                }
            }
            else if(state === "ERROR"){
                console.log('Some error has occurred while fetching Task What Id:'+response.getError());
                component.set('v.showSpinner',false);
            }
        });
        $A.enqueueAction(action);
    },
    fetchCurrentUser : function(component, event, helper) {
        //component.set('v.showSpinner',true);
        console.log('Fetching current user..');
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        var action=component.get("c.fetchCurrentUser");
        action.setParams({ 
            "userId" : userId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                component.set('v.userId',res.Id);
                component.set('v.userRecord',res);
                //component.set('v.showSpinner',false);
            }
            else if(state === "ERROR"){
                console.log('Some error has occurred while fetching the current user:'+response.getError());
                component.set('v.showSpinner',false);
            }
        });
        $A.enqueueAction(action);
    },
    clearFields : function(component, event, helper) {
        if(component.get('v.recordId')!=undefined && component.get('v.recordId')!=null && component.get('v.recordId').startsWith("00U")){
            console.log('Disabling event creation when on event page');
            component.set('v.onEventPage',true);
            component.set('v.selectedType', 'Task');
        }
        else{
            component.set('v.onEventPage',false);
            component.set('v.selectedType', 'Meeting');
        }
        var timezone = $A.get("$Locale.timezone");
        var startdateValue = new Date();
        startdateValue.setHours(startdateValue.getHours()+1);
        startdateValue.setMinutes(0);
        var enddateValue = new Date();
        enddateValue.setHours(enddateValue.getHours()+2);
        enddateValue.setMinutes(0);
        component.set('v.priority','Normal');
        component.set('v.status','Open');
        component.set('v.taskWhatId','');
        component.set('v.eventWhatId','');
        component.set('v.subject','');
        component.set('v.eventLocation','');
        component.set('v.taskDueDate','');
        //component.set('v.selectedRelatedToType','Account');
        component.set("v.eventStartTime", startdateValue.toISOString());
        component.set("v.eventEndTime", enddateValue.toISOString());
        component.set('v.accId','');
        component.set('v.contactId','');
        component.set('v.oppId','');
        component.set('v.accRecord',null);
        component.set('v.oppRecord',null);
        component.set('v.contactRecord',null);
        component.set('v.subType','');
    }
})