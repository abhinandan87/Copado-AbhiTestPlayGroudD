({
    /*
     * This method is being called from init event
     * to fetch all available recordTypes
     * */
  fetchListOfRecordTypes: function(component, event, helper) {
	  var oppAction = component.get("c.getOpportunity");
      oppAction.setParams({
        opportunityId :component.get("v.recordId")
      });
      oppAction.setCallback(this, function(response) {
		 var state = response.getState();
         if (state === "SUCCESS") {
			var oppty = response.getReturnValue();
			  console.log('oppty--------- ',JSON.stringify(oppty));
			  component.set("v.oppty", oppty);
			
			var action = component.get("c.fetchRecordTypeValues");
			//pass the object name here for which you want
			//to fetch record types
			action.setParams({
			  objectName: "WorkRequestForm__c",
				opportunityId :component.get("v.recordId")
			});
			action.setCallback(this, function(response) {
			  var mapOfRecordTypes = response.getReturnValue();
			  console.log('mapOfRecordTypes--------- ',JSON.stringify(mapOfRecordTypes));
			  component.set("v.mapOfRecordType", mapOfRecordTypes);
			  var recordTypeList = [];
			  //Creating recordTypeList from retrieved Map
			  for (var key in mapOfRecordTypes) {
				recordTypeList.push(mapOfRecordTypes[key]);
			  }
			  if (recordTypeList.length == 0) {
				 component.set("v.isFormType", false); 
			  } else {
                  recordTypeList.sort();
				component.set("v.lstOfRecordType", recordTypeList);
			  }
			});
			$A.enqueueAction(action);
		  }
		  else if (state == "INCOMPLETE") {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
               "title": "Oops!",
               "message": "No Internet Connection"
            });
            toastEvent.fire();
             
         } else if (state == "ERROR") {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
               "title": "Error!",
               "message": "Please contact your administrator"
            });
            toastEvent.fire();
         }
	  }
	  );
	  $A.enqueueAction(oppAction);
  },

  /*
     * This method will be called when "Next" button is clicked
     * It finds the recordTypeId from selected recordTypeName
     * and passes same value to helper to create a record
     * */
  createRecord: function(component, event, helper, sObjectRecord) {
    var selectedRecordTypeName = component.find("recordTypePickList").get("v.value");
      console.log('selectedRecordTypeName-------- '+selectedRecordTypeName);
    if (selectedRecordTypeName != "") {
        component.set("v.isFormTypeSelected", true);
      var selectedRecordTypeMap = component.get("v.mapOfRecordType");
      var selectedRecordTypeId;
      //finding selected recordTypeId from recordTypeName
      for (var key in selectedRecordTypeMap) {
        if (selectedRecordTypeName == selectedRecordTypeMap[key]) {
          selectedRecordTypeId = key; //match found, set value in selectedRecordTypeId variable
          break;
        }
      }
      //Close Quick Action Modal here
      helper.closeModal();
      //Calling CreateRecord modal here without providing recordTypeId
      helper.showCreateRecordModal(component, selectedRecordTypeId, "WorkRequestForm__c");
    } else {
      alert("You did not select any record type");
    }
  },

  /*
     * closing quickAction modal window
     * */
  closeModal: function(component, event, helper) {
    helper.closeModal();
  },
  enbleSumitbutton: function(component, event, helper) {
    var selectedFormType = component.find("recordTypePickList").get("v.value");
    console.log('selectedFormType-------- '+selectedFormType);
    if (selectedFormType != "") {
   		component.set("v.isFormTypeSelected", false);          
    } else {
        component.set("v.isFormTypeSelected", true);
    }
 }
})