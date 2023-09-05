({
    doInit : function(component, event, helper) {
        var id = component.get("v.pageReference").state.c__recordId;
        var actionname = component.get("v.pageReference").state.c__actionname;       
        component.set("v.recId", id);     
        component.set("v.quickActionName",actionname);
      	component.set("v.showComponent", actionname);
    },
    
    changePageRef : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
	},
    
    handleSelectedProducts : function(component, message, helper){
        if (message != null && message.getParam("selProductsList") != null) {    
            component.set("v.selectedProdList", message.getParam("selProductsList"));
            if(message.getParam("filProductsList") != undefined){
                console.log('enterhandle**' + message.getParam("filProductsList"));
            	component.set("v.filterProdList", message.getParam("filProductsList"));
            }
            component.set("v.screenMode", message.getParam("mode"));
            component.set("v.productsRemoved", message.getParam("productsRemoved"));
            component.set("v.showComponent", 'LegalEntity');
        }
         console.log('screenMode** ' + component.get("v.screenMode"));
        console.log('filters** ' + JSON.stringify(component.get("v.filterProdList")));
    },
    
     handleLegalProducts : function(component, message, helper){
         // Read the message argument to get the values in the message payload
        if (message != null && message.getParam("legalProdList") != null) {
            component.set("v.selectedProdList", message.getParam("legalProdList"));  
            component.set("v.quickActionName",'AddOppProductButton');
            component.set("v.showComponent", 'AddOppProductButton');
             console.log('filterslegal** ' + JSON.stringify(component.get("v.filterProdList")));
        }
    },
    
    handleAddProducts : function(component, message, helper){
    	 if (message != null && message.getParam("addProdList") != null) {
            component.set("v.legProdList", message.getParam("addProdList"));   
            component.set("v.legalEntityId",message.getParam("legalEntityId"));
            component.set("v.legalEntityName",message.getParam("legalEntityName"));
            component.set("v.showComponent", 'OpportunityAddProductContainer');
        }
	}
})