// @author: Sharique Iqbal
// @date: 23 Aug 2021
// @param: NA
// @description: Test class for ContentDocument trigger methods 
// @return: NA
//-----------------------------

@isTest
private class TestContentDocumentMethods {
      
     //-----------------------------
    // @author: Sharique
    // @date: 23 Auguest 2021
    // @param: NA
    // @description: SFDC-4182 Test Method for delete operations
    // @return: NA
    //-----------------------------
    
    @isTest  private static void testMethodDeleteFile() { 
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
        ContractAttachment__c contrtAttach = [select Id, Contract__c, (Select Id From ContentDocumentLinks) from ContractAttachment__c limit 1];
        system.assertEquals(1, contrtAttach.ContentDocumentLinks.size());  
        
        delete [Select id from ContentDocument];
        
    }
    
     //-----------------------------
    // @author: Digvijay
    // @date: 9 Nov 2022
    // @param: NA
    // @description:  Test Method for VOC attachement operations
    // @return: NA
    //-----------------------------
    
    @isTest  private static void testMethodDeleteVOCFile() { 
        Account acct = TestUtility.createTestAccount('Test Attachmnet Insertion', true);
        VoiceofCustomer__c voc=new VoiceofCustomer__c(CustomerAccountName__c=acct.Id);
        insert voc;

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
        newFileShare.LinkedEntityId = voc.Id;
        newFileShare.ShareType= 'V';
             
        insert new List<ContentDocumentLink>{newFileShare};
        voc=[Select Id,FileAttached__c from VoiceofCustomer__c where id=:voc.id];
        system.assertEquals('Yes', voc.FileAttached__c);       
        delete [Select id from ContentDocument];
        voc=[Select Id,FileAttached__c from VoiceofCustomer__c where id=:voc.id];
        system.assertEquals('No', voc.FileAttached__c); 
        
    }
    
}