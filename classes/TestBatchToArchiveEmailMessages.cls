@isTest
public class TestBatchToArchiveEmailMessages {
    
    @isTest
    private static void testBatchJob(){
        
        Account a = TestUtility.createTestAccount('Account ArchiveEmailMessages', true);
        
        Contact c = new Contact( firstname = 'Test', lastname = 'testArchiveEmailMessages', AccountId = a.Id, email='test@ishmarkit.com');
        insert c;       
        
        ProductGroup__c pg = new ProductGroup__c(Name = 'NRG');
        insert pg;
        
        Case testCase = new Case(subject = 'Test subject ArchiveEmailMessages',AccountId = a.Id,contactId = c.Id,ProductGroup__c = pg.Id, status='Closed - Canceled',
                                 ResolutionDescription__c='test email archive',SkillLevel__c='1 - General',ClosedReason__c='No Action Required',
                                Type='Access',ContactValidation__c=true,RecordTypeId='0120P000000tGrqQAE');
        insert testCase;
        
        EmailMessage emailMessage = new EmailMessage(status = '3',fromName = 'test archival',subject = 'This is the Subject!', htmlBody = '<html><body><b>Hello</b></body></html>',
                                                     ParentId=testCase.Id); 
        insert emailMessage; // insert 
         
         
        EmailMessageRelation emr = new EmailMessageRelation(emailMessageId = emailMessage.Id,relationId = c.Id, relationType = 'FromAddress'); 
        insert emr;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'testEmail',
            PathOnClient = 'emailAttach.jpg',
            VersionData = Blob.valueOf('Test email content.'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [
                                            SELECT Id, Title, LatestPublishedVersionId 
                                            FROM ContentDocument
                                        ];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink(LinkedEntityId = emailMessage.Id,ContentDocumentId = documents[0].Id,shareType = 'V');
        insert cdl;
        
        Attachment attach=new Attachment(Name='Email Attachment',body=Blob.valueOf('Email Attachment Body'),parentId = emailMessage.Id);   	
        insert attach;
        
         Test.startTest();
        BatchToArchiveEmailMessagesScheduler sh1 = new BatchToArchiveEmailMessagesScheduler();
		String sch = '0 0 23 * * ?'; 
        system.schedule('Test Archive Email', sch, sh1);
        database.executeBatch(new BatchToArchiveEmailMessages('',true));
        database.executeBatch(new BatchToCloneAttachments('',true));
        database.executeBatch(new BatchToDeleteEmailMessages(''));
        Test.stopTest();
        
        List<ArchivedEmailMessage__c> aemLst = [Select id from ArchivedEmailMessage__c];
        system.assertEquals(true, aemLst.size()>0,'ArchivedEmailMessage records are not created');
        
    }

}