// @author: Uttam Arya
// @date: 31 Aug 2017
// @param: NA
// @description: Test class for ContentDocumentLink trigger methods 
// @return: NA
//-----------------------------

@isTest
private class TestContentDocumentLinkMethods {
    
    //-----------------------------
    // @author: Uttam Arya
    // @date: 31 Aug 2017
    // @param: NA
    // @description: SFDC1-2243 Test method for ContentDocumentLink trigger methods populateMISAttachmentAddedInOpportunityWhenAttachmentIsInsertedInLightning on insert
    // @return: NA
    // @Modifiedby: Mohit Modi
    // @Modified Description: 06 Nov 2017 : Updated Test Method logic to capture the attahment added on Opportunity Attachment as well.
    //-----------------------------
    @isTest private static void testpopulateMISAttachmentAddedInOpportunityWhenAttachmentIsInsertedInLightning() {
        
        Account acct = TestUtility.createTestAccount('Test Attachmnet Insertion', true);
        Opportunity oppt = TestUtility.createOpportunity(acct.Id, 'Test Oppy Attachment', true);
        
        OpportunityAttachment__c oppAtt = new OpportunityAttachment__c(AttachmentType__c = 'Final Proposal',Opportunity__c =oppt.id );
        insert oppAtt ;
        
        string before = 'Testing base 64 encode';            
        Blob beforeblob = Blob.valueOf(before);
        
        //Insert contentdocument data
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test';           
        cv.VersionData = beforeblob;          
        insert cv;         
        
        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
        
        //insert new ContentDocumentLink
        ContentDocumentLink newFileShare = new ContentDocumentLink();
        newFileShare.contentdocumentid = testcontent.contentdocumentid;
        newFileShare.LinkedEntityId = oppt.Id;
        newFileShare.ShareType= 'V';
        
        //insert new ContentDocumentLink
        ContentDocumentLink newFileShareOppAtt = new ContentDocumentLink();
        newFileShareOppAtt.contentdocumentid = testcontent.contentdocumentid;
        newFileShareOppAtt.LinkedEntityId = oppAtt.Id;
        newFileShareOppAtt.ShareType= 'V';
        
        insert new List<ContentDocumentLink>{newFileShare,newFileShareOppAtt};
        
        //Assert if MIS field is inserted
        Opportunity opp = [select MISAttachmentAdded__c from Opportunity where Id =: oppt.Id];
        
        System.assertNotEquals(opp.MISAttachmentAdded__c, null, 'MISAttachmentAdded field should not be null');
        
    }
    
    //-----------------------------
    // @author: Sharique
    // @date: 26 May 2021
    // @param: NA
    // @description: SFDC1-2530 Test method for ContentDocumentLink trigger methods updateContractOncePOIsAttached on insert
    // @return: NA
    //-----------------------------
    @isTest private static void testMethodupdateContractOncePOIsAttached() {
        
        Account acct = TestUtility.createTestAccount('Test Attachmnet Insertion', true);
        Id stdPricebookId = Test.getStandardPricebookId();
        LegalEntity__c testLegalEntity = TestUtility.createLegalEntity('IHSM test legalEntity', 'USD'); 
        Contract testContract = TestUtility.createContractWithInsertOptional(acct.Id, testLegalEntity.Id, null, stdPricebookId,true );

        ContractAttachment__c ctrtAtt = new ContractAttachment__c(AttachmentType__c = 'Purchase Order',Contract__c =testContract.id);
        insert ctrtAtt ;
        
        string before = 'Testing base 64 encode';            
        Blob beforeblob = Blob.valueOf(before);
        
        //Insert contentdocument data
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test';           
        cv.VersionData = beforeblob;          
        insert cv;         
        
        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
        
        //insert new ContentDocumentLink
        ContentDocumentLink newFileShare = new ContentDocumentLink();
        newFileShare.contentdocumentid = testcontent.contentdocumentid;
        newFileShare.LinkedEntityId = ctrtAtt.Id;
        newFileShare.ShareType= 'V';
        
        /*insert new ContentDocumentLink
        ContentDocumentLink newFileShareOppAtt = new ContentDocumentLink();
        newFileShareOppAtt.contentdocumentid = testcontent.contentdocumentid;
        newFileShareOppAtt.LinkedEntityId = ctrtAtt.Id;
        newFileShareOppAtt.ShareType= 'V';*/
        
        insert new List<ContentDocumentLink>{newFileShare};
        
        ContractAttachment__c conAtt = [select Id,POAttached__c from ContractAttachment__c where Id =: ctrtAtt.Id];
        System.assertEquals(conAtt.POAttached__c, 'Yes','File attached was failed');
        
    }
    
     //-----------------------------
    // @author: Sharique
    // @date: 23 Auguest 2021
    // @param: NA
    // @description: SFDCfor C-4182 Test method for delete operations
    // @return: NA
    //-----------------------------
    @isTest private static void testMethodDeleteFile() {
        
        Account acct = TestUtility.createTestAccount('Test Attachmnet Insertion', true);
        Id stdPricebookId = Test.getStandardPricebookId();
        LegalEntity__c testLegalEntity = TestUtility.createLegalEntity('IHSM test legalEntity', 'USD'); 
        Contract testContract = TestUtility.createContractWithInsertOptional(acct.Id, testLegalEntity.Id, null, stdPricebookId,true );

        ContractAttachment__c ctrtAtt = new ContractAttachment__c(AttachmentType__c = 'Purchase Order',Contract__c =testContract.id);
        insert ctrtAtt ;
        
        string before = 'Testing base 64 encode';            
        Blob beforeblob = Blob.valueOf(before);
        
        //Insert contentdocument data
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test';           
        cv.VersionData = beforeblob;          
        insert cv;         
        
        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
        
        //insert new ContentDocumentLink
        ContentDocumentLink newFileShare = new ContentDocumentLink();
        newFileShare.contentdocumentid = testcontent.contentdocumentid;
        newFileShare.LinkedEntityId = ctrtAtt.Id;
        newFileShare.ShareType= 'V';
             
        insert new List<ContentDocumentLink>{newFileShare};
        
        delete newFileShare;
        List<ContentDocumentLink> cdl = [Select id, ShareType from ContentDocumentLink where LinkedEntityId = :ctrtAtt.Id and ShareType = 'V' LIMIT 1];
        System.assertEquals(0, cdl.size(), 'Checking if ContentDocumentLink delete was successful');
    }
    
}