({
	doInit : function(component,event,helper) {
        helper.callToServer(
            component,
            "c.findProductsRelatedToOpportunity",
            function(response) {
                var jsonObject=JSON.parse(response);
                console.log('jsonObject---'+jsonObject);
                if(jsonObject == '' || jsonObject == null ) {
                	document.getElementById("noProducts").style.display = "block" ;
                    document.getElementById("buttons").style.display = "none" ;
                }
                else
                	component.set('v.recordList',jsonObject)
            }, 
            {opptyId: component.get('v.oppyId')}
        ); 
    },
    
    createContractLineItems : function(component,event,helper) {
        var strSelectRecordIds=[];
        var values = [];
        values = component.get("v.recordList"); 
        var valueInstance;
        for(var valueInstance in values) {
            if(values[valueInstance].checked == true)
                strSelectRecordIds.push(values[valueInstance].recordId);
        }
        //console.log('strSelectRecordIds.length='+strSelectRecordIds.length);
        if(strSelectRecordIds.length <= 0) {            
            alert('You must select the required product/s to proceed with this trial contract.');
        }
        else {
            var strId = JSON.stringify(strSelectRecordIds);
            helper.callToServer(
                component,
                "c.createTrialContractRecord",
                function(response) {
                    var jsonObject=response;
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": jsonObject    
                    });
                    navEvt.fire();   
                }, 
                {oppRecordId: component.get('v.oppyId'),
                 oppLineItemId: strId}
            );
        }        
    },
    
    closeModalPopup : function(component,event, helper){ 
       document.getElementById("newClientSectionId").style.display = "none" ;
       var navEvt = $A.get("e.force:navigateToSObject");
       	   navEvt.setParams({
           "recordId": component.get('v.oppyId')    
         });
       navEvt.fire();
   },
   toggleSelectAll : function(component,event) {
    var selectAllVal = component.find("selectAll").get("v.value");
    //set all products as checked
    var values = [];
    values = component.get("v.recordList"); 
    for(var valueInstance in values) {
        values[valueInstance].checked = selectAllVal;
    }
    component.set("v.recordList",values);

   }
})