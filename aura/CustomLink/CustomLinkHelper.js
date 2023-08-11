({
	callToServer : function(component, method,callback) {
        var domain = component.get("v.domain");
		var action = component.get(method);
        action.setParams({ "domain" : domain }); 
        action.setCallback(this, function(response) {
           
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                callback.call(this,response.getReturnValue());
            }else if(state === "ERROR") {
                alert('Please try again.'+response.getError());
            }
        });
		$A.enqueueAction(action);
    },
    fetchRecordInfo : function(component){
        var recordId=component.get('v.recordId');
        var action = component.get("c.fetchSObjectfields");
        action.setParams({ "recordString" : recordId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.currentRecord', response.getReturnValue());
            }else if(state === "ERROR") {
                alert('Please try again.'+response.getError());
            }
        
        var pageSize = component.get("v.pageSize");
            this.callToServer(
                component,
                "c.loadCustomLinks",
                function(response) {
                    component.set("v.customLinks",response);
                    component.set("v.totalSize", component.get("v.customLinks").length);
                    if(component.get("v.totalSize")>= pageSize) {
                        component.set("v.hideButtons",false);
                    }
                    component.set("v.start",0);
                    component.set("v.end",pageSize-1);
                    var paginationList = [];
                    for(var i=0; i< pageSize; i++) {
                        if(response[i]!=null) {
                            paginationList.push(response[i]);
                        }
                    }
                    console.log('record-->'+JSON.stringify(component.get('v.currentRecord')));
                    for(var i=0; i<paginationList.length;i++) {
                          if(component.get('v.recordId')!=undefined && component.get('v.recordId')!=null && paginationList[i].RelatedField__c!=undefined && component.get('v.currentRecord')!=undefined && component.get('v.currentRecord')!=null) {
                              if(!paginationList[i].RelatedField__c.includes(",")){    
                                    var relatedFieldName=paginationList[i].RelatedField__c;
                                    var key = 'v.currentRecord.'+relatedFieldName;
                                    var relatedFieldValue = component.get(key);
                                    if(relatedFieldValue!=null || relatedFieldValue!=undefined){
                                        if(relatedFieldName=='Id'){
                                            relatedFieldValue=relatedFieldValue.slice(0, 15);
                                        }
                                    }
                                    paginationList[i].URL__c=paginationList[i].URL__c.replace("{FieldValue0}", relatedFieldValue);
                              }
                              else if(paginationList[i].RelatedField__c.includes(",")){
                                  if(paginationList[i].URL__c.includes("{FieldValue1}")){
                                      paginationList[i].RelatedField__c =  paginationList[i].RelatedField__c.split(" ").join("");
                                      var listOfFields=[];
                                      listOfFields=paginationList[i].RelatedField__c.split(",");
                                      for(var j=0; j<listOfFields.length;j++){
                                          var relatedFieldName=listOfFields[j];
                                          var key = 'v.currentRecord.'+relatedFieldName;
                                          var relatedFieldValue = component.get(key);
                                          if(relatedFieldValue!=null || relatedFieldValue!=undefined){
                                                if(relatedFieldName=='Id'){
                                                    relatedFieldValue=relatedFieldValue.slice(0, 15);
                                                }
                                          }
                                          paginationList[i].URL__c=paginationList[i].URL__c.replace("{FieldValue"+[j]+"}", relatedFieldValue);
                                      }
                                  }
                              }
                          }
                     }
                    component.set('v.paginationList', paginationList);
                    component.set('v.initComplete',true);
                    var spinner = component.find("spinner");
                    $A.util.addClass(spinner, 'slds-hide');
                    $A.util.removeClass(spinner, 'slds-show');
            });
        });
		$A.enqueueAction(action);
	}
})