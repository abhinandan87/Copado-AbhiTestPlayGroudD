({
	isCommunity : function(component) {
        var action = component.get("c.isCommunity");
        action.setCallback(this, function(response) {
            var isCommunity = response.getReturnValue(); 
            component.set("v.isCommunity",isCommunity);
        });
        $A.enqueueAction(action);
    },
    showExampleModal : function(component) {      
        var modal = component.find("thecontainer");
        $A.util.removeClass(modal, 'hideDiv');        
    },
    
    hideExampleModal : function(component) {
        var modal = component.find("thecontainer");
        $A.util.addClass(modal, 'hideDiv');
    },
	callToServer : function(component, method, callback, params) {
		var action = component.get(method);
        if(params) {
            action.setParams(params);
        }
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                callback.call(this,response.getReturnValue());
            }
            else if(state === "ERROR") {
                alert('Problem with connection. Please try again.');
            }
        });
		$A.enqueueAction(action);
    },  
	
    refreshView : function() {
        return new Promise($A.getCallback(function(resolve, reject) {
            //To refresh the view
            $A.get('e.force:refreshView').fire();
            resolve(true); 
        }));
	},
    
    handleCallBackInPromiseFashion : function(component, event, helper) {
        helper.refreshView()
        .then(
            // resolve handler
            $A.getCallback(function(result) {
                $A.get("e.force:closeQuickAction").fire();
            }),    
            // reject handler
            $A.getCallback(function(error) {
                alert("Promise was rejected: " +  error);
            })
    	)
        .then(
            // resolve handler
            $A.getCallback(function(result) {
                var recordId = component.get('v.createdRecordId');
                var editRecordEvent = $A.get("e.force:editRecord");
                editRecordEvent.setParams( {
                    "recordId": recordId                                  
                });
               editRecordEvent.fire();
            }) 
        )
    },
    
    
	subscribe: function (component, event, helper) {
    component.set('v.showSpinner',false);
    const empApi = component.find('empApi');
    empApi.setDebugFlag(true);
    const channel = component.get('v.channel');
    const replayId = -1;
    console.log('OK2');
    debugger;
    empApi.subscribe(channel, replayId, $A.getCallback(eventReceived => {
            // Process event (this is called each time we receive an event)
            console.log('OK1');
            console.log('Received event ', JSON.stringify(eventReceived));
            console.log('eventReceived.recordId'+eventReceived.data.payload.recordId__c);
        	
            var recordId = component.get('v.recordId');
        	if(recordId == eventReceived.data.payload.recordId__c){
                component.set('v.showSpinner',true);
                this.displayToast(component, eventReceived.data.payload.ErrorStatus__c, eventReceived.data.payload.message__c);
                helper.hideExampleModal(component);
                $A.get("e.force:closeQuickAction").fire();
    		}
        }))
        .then(subscription => {
            console.log('Subscription request sent to: ', subscription);
        	component.set('v.subscription', subscription);
        });
       helper.unsubscribe(component, event, helper);  
  },
    
    unsubscribe: function (component, event, helper) {
    const empApi = component.find('empApi');
    const channel = component.get('v.subscription');
   const callback1 = function (message) {
      console.log('Unsubscribed from channel ');
    }; 
     console.log('Unsubscribed from channel ');
    empApi.unsubscribe(component.get('v.subscription'), $A.getCallback(callback1));
    
  },
    
   // onReceiveNotification: function (component, message) {
    
 // },
    displayToast: function (component, type, message) {
    console.log('inside toast');
    const toastEvent = $A.get('e.force:showToast');
    toastEvent.setParams({
      type: type,
      message: message
    });
    console.log('type' + type);
    console.log('message'+message);
    toastEvent.fire();
    
  }  
})