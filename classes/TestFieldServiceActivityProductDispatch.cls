@isTest
public class TestFieldServiceActivityProductDispatch {
    
     @isTest 
    static void testAfterInsertAndUpdate(){
        test.startTest();
        Account testAccount = TestUtility.createTestAccount('testAccount', false);
        testAccount.DataGovernanceStatus__c = 'Approved';
        insert testAccount;
        Contact testContact = TestUtility.createContact(testAccount.Id, 'test@test.com', true, 'test','data');
        ProductGroup__c pg = TestUtility.createProductGroup('MRO',false,false);
        WorkOrder workOrder = testUtility.createFieldServiceActivity(testContact.Id,true);
        FieldServiceActivityProduct__c fap = testUtility.createFSAProduct(workOrder.Id, pg.Id,true);     
        fap.LegacyIDUnique__c ='tEsTDaTa';
        update fap;
        test.stopTest();  
        FieldServiceActivityProductDispatcher.isAfterInsertProcessing = true;
        FieldServiceActivityProduct__c fap2 = testUtility.createFSAProduct(workOrder.Id, pg.Id,true);     
        FieldServiceActivityProductDispatcher.isAfterUpdateProcessing = true;
        fap2.LegacyIDUnique__c ='testDatefap2';
        update fap2;           
        system.assertEquals(fap.FieldServiceActivity__c, workOrder.Id);
        system.assertEquals(fap2.FieldServiceActivity__c, workOrder.Id);
        system.assertEquals(fap.LegacyIDUnique__c, 'tEsTDaTa');
    }
   
}