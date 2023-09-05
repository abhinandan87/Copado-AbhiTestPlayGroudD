({
    handleSelect : function(component, event, helper) {
        if(event.getParam('id')=='details' || 
            event.getParam('id')=='overview' || 
            event.getParam('id')=='activity' || 
            event.getParam('id')=='tcrm1' || 
            event.getParam('id')=='tcrm2' || 
            event.getParam('id')=='accountPlanDoc' || 
            event.getParam('id')=='accountOverviewDoc' ||
            event.getParam('id')=='customerInsights'||
          event.getParam('id')=='linkedInTab' ) {
            component.set("v.currentTab",event.getParam('id'));
        }
        else {
            var appEvent = $A.get("e.c:EventAccountQuickAction");
            appEvent.setParams({
                "message" : event.getParam('id') });
            appEvent.fire();
            component.find("tabs").set("v.selectedTabId",component.get("v.currentTab"));
        }
    }
})