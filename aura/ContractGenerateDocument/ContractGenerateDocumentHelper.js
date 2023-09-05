({
    GenerateDocument : function (component,event,helper,accountId,contractId,oppId,recTypeId) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/apex/loop__looplus?&eid="+contractId+"&accountId="+accountId +
            "&opportunityId="+oppId+"&hidecontact=true&filter="+recTypeId+
            "&filtertype=contains",
            "isredirect": "true"
        });
        urlEvent.fire();
    },
    
    SendWithDocuSign : function (component,event,helper,sessionid,accountId,contractId,oppId,recTypeId) {
        console.log('SendWithDocuSign method called');
       var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": "/apex/loop__looplus?&eid="+contractId+"&accountId="+accountId +
                    "&opportunityId="+oppId+"&filter="+recTypeId+
                    " Secure&sessionId="+sessionid+
                    "&autorun=true&hideddp=true&attach=true",
                    "isredirect": "true"
                });
                urlEvent.fire();
    },
    
    GenerateDistributorOF : function (component,event,helper,accountId,contractId,oppId,recTypeId) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/apex/loop__looplus?&eid="+contractId+"&accountId="+accountId +
            "&opportunityId="+oppId+"&hidecontact=true&filter=Distributor Form&filtertype=contains",
            "isredirect": "true"
        });
        urlEvent.fire();
    },
    
     GenerateDistributorOFWord : function (component,event,helper,accountId,contractId,oppId,recTypeId) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/apex/loop__looplus?&eid="+contractId+"&accountId="+accountId +
            "&opportunityId="+oppId+"&hidecontact=true&filter=Distributor Word Form &filtertype=contains",
            "isredirect": "true"
        });
        urlEvent.fire();
    },
    
    PreviewDocuments : function (component,event,helper,accountId,contractId,oppId,recTypeId) {
       console.log('Preview Doc inpreview method'+accountId);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/apex/loop__looplus?&eid="+contractId+"&accountId="+accountId +
            "&opportunityId="+oppId+"&filter="+recTypeId+" Preview&autorun=true&hideddp=true",
            "isredirect": "true"
        });
        urlEvent.fire();
    },
    
    ConvertToWord : function (component,event,helper,accountId,contractId,oppId,recTypeId) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/apex/loop__looplus?&eid="+contractId+"&accountId="+accountId +
            "&opportunityId="+oppId+"&filter="+recTypeId+" Redline&autorun=true&hideddp=true",
            "isredirect": "true"
        });
        urlEvent.fire();
      },

})