({
    onfocus : function(component,event,helper){
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
        var getInputkeyWord = '';
        var getInputSearchText = component.get("v.SearchKeyWord");
        if(getInputSearchText !== undefined && getInputSearchText !== null && getInputSearchText !== '' && getInputSearchText.length>0){
            getInputkeyWord = getInputSearchText;
        }
        else{
            getInputkeyWord = '';
        }
        console.log('getInputkeyWord-->'+getInputkeyWord);
        helper.searchHelper(component,event,getInputkeyWord);
    },
    keyPressController : function(component, event, helper) {
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
        
    },
    
    // function for clear the Record Selaction 
    clear :function(component,event,helper){
        
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 
        
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", {} );
		component.set("v.selectedRecordId",'');
		component.set("v.isChanged",'');
        
        var forSearchIcon = component.find("searchIcon");
        $A.util.removeClass(forSearchIcon, 'slds-hide');
        $A.util.addClass(forSearchIcon, 'slds-show');
        
    },
    
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
        // get the selected Account record from the COMPONETN event 	 
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        var selectedRecordId = event.getParam("recordId");
        
        var forSearchIcon = component.find("searchIcon");
        $A.util.addClass(forSearchIcon, 'slds-hide');
        $A.util.removeClass(forSearchIcon, 'slds-show');
        
        component.set("v.selectedRecordId",selectedRecordId);
        component.set("v.selectedRecord" , selectedAccountGetFromEvent); 
        component.set("v.isChanged",selectedRecordId);//has the latest recordId change
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');  
        
    },
    doInit : function (component, event, helper) {
        var selectedRecord  = component.get("v.selectedRecord");
        if(selectedRecord) {
            var forclose = component.find("lookup-pill");
            $A.util.addClass(forclose, 'slds-show');
            $A.util.removeClass(forclose, 'slds-hide');
            
            
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
            
            var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show');  
            
            var forSearchIcon = component.find("searchIcon");
            $A.util.addClass(forSearchIcon, 'slds-hide');
            $A.util.removeClass(forSearchIcon, 'slds-show');
        }
        else{
            var forSearchIcon = component.find("searchIcon");
            $A.util.removeClass(forSearchIcon, 'slds-hide');
            $A.util.addClass(forSearchIcon, 'slds-show');
        }
    },
    // automatically call when the component is done waiting for a response to a server request.  
    hideSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : false });
        evt.fire();    
    },
    // automatically call when the component is waiting for a response to a server request.
    showSpinner : function (component, event, helper) {
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : true });
        evt.fire();    
    },
    clearList: function (component, event, helper) {
        setTimeout(function(){
        console.log('Getting into blur function');
        var selectedRecordId  = component.get("v.selectedRecordId");
            if(selectedRecordId==null || selectedRecordId==='') {
                	var forclose = component.find("searchRes");
                    $A.util.addClass(forclose, 'slds-is-close');
                    $A.util.removeClass(forclose, 'slds-is-open');
                	component.set("v.listOfSearchRecords", null ); 
            }
        }, 200);
    }
    
})