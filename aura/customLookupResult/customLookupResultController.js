({
   doInit : function (component, event, helper) {
       if(component.get('v.secondaryFieldName')!==undefined && component.get("v.secondaryFieldName")!=='' && component.get("v.secondaryFieldName")!==null){
           var secondaryFieldValuetemp='';
           if(component.get('v.secondaryFieldName').includes(".")){
               secondaryFieldValuetemp=component.get("v.oRecord");
               var fieldList=component.get('v.secondaryFieldName').split(".");
               for(var i=0;i<fieldList.length;i++){
                   var arrayValue=fieldList[i];
                   if(secondaryFieldValuetemp[arrayValue]==undefined){
                   	   secondaryFieldValuetemp='';
                       break;
                   }
                   secondaryFieldValuetemp=secondaryFieldValuetemp[arrayValue];
               }
           }
           else{
               secondaryFieldValuetemp=component.get("v.oRecord");
               if(secondaryFieldValuetemp[component.get('v.secondaryFieldName')]!=undefined){
               		secondaryFieldValuetemp=secondaryFieldValuetemp[component.get('v.secondaryFieldName')];
               }
               else{
                   secondaryFieldValuetemp='';
               }
           }
           if(secondaryFieldValuetemp!='' && secondaryFieldValuetemp!=null){
               var secondaryFieldValue = JSON.stringify(secondaryFieldValuetemp).slice(1,-1);
               component.set('v.secondaryFieldValue',(secondaryFieldValue));
           }
       }
   },
   selectRecord : function(component, event, helper){   
    // get the selected record from list  
      var getSelectRecord = component.get("v.oRecord");
    // call the event   
      var compEvent = component.getEvent("oSelectedRecordEvent");
    // set the Selected sObject Record to the event attribute.  
         compEvent.setParams({"recordByEvent" : getSelectRecord,
                              "recordId":getSelectRecord.Id,
                              "valueChanged":getSelectRecord.Id
                             });  
    // fire the event  
         compEvent.fire();
    },
})