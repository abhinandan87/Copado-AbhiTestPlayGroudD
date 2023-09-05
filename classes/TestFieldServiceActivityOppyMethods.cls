// @author: Shikhar Singh
// // @date: 06 June 2022
// @param: NA
// @description: Test class for FSAO methods 
// @return: NA
//-----------------------------

@isTest
private class TestFieldServiceActivityOppyMethods {
    
    //-----------------------------
    // @author: Shikhar Singh
    // @date: 06 June 2022
    // @param: NA
    // @description: SFDC-5786 Test method for FSAOMethods to update Primary Opportunity on insert, update and Delete
    // @return: NA
    //-----------------------------

    @isTest
    private static void testPrimaryOpportunityUpdateAndDeleteOnFsa() {
        Account acc = TestUtility.createTestAccount('Test Acc 1',true);
        Contact con = TestUtility.createContact(acc.Id, 'test@test.com.ibnvalid', true, 'Test', 'Contact FSA');
        WorkOrder FSA = TestUtility.createFieldServiceActivity(con.Id,true);
        test.startTest();
        Opportunity oppy1 = TestUtility.createOpportunity(acc.Id,'Test Oppy FSA',true);
        Opportunity oppy2 = TestUtility.createOpportunity(acc.Id,'Test Oppy FSA',true);
        oppy1.FirstYearValue__c = 1000;
        update oppy1;
        oppy2.FirstYearValue__c = 2000;
        update oppy2;
        
        TriggerFrameworkExtension__c setting = new TriggerFrameworkExtension__c();
		setting.Name = 'FieldServiceActivityOpportunity__c';
		setting.ModifiedObjectName__c = 'FieldServiceActivityOppy__c';
		insert setting;
        
        FieldServiceActivityOpportunity__c FSAO1 = new FieldServiceActivityOpportunity__c(FieldServiceActivity__c = FSA.Id, Opportunity__c= oppy1.Id);
        insert FSAO1;
        
        List<WorkOrder> listOfWorkOrder1 = [Select Id,PrimaryOpportunityName__c FROM WorkOrder WHERE ID=: FSA.ID];
        
        for(WorkOrder wo: listOfWorkOrder1) {
            System.assertEquals(oppy1.Id, wo.PrimaryOpportunityName__c, 'The Oppy does not match 1');
        }
        
        FieldServiceActivityOpportunity__c FSAO2 = new FieldServiceActivityOpportunity__c(FieldServiceActivity__c = FSA.Id, Opportunity__c= oppy2.Id);
        insert FSAO2;
        
        List<WorkOrder> listOfWorkOrder2 = [Select Id,PrimaryOpportunityName__c FROM WorkOrder WHERE ID=: FSA.ID];
        
        for(WorkOrder wo: listOfWorkOrder2) {
            System.assertEquals(oppy2.Id, wo.PrimaryOpportunityName__c, 'The Oppy does not match 2');
        }
     
        
        delete FSAO2;
        List<WorkOrder> listOfWorkOrder3 = [Select Id,PrimaryOpportunityName__c FROM WorkOrder WHERE ID=: FSA.ID];
        
        for(WorkOrder wo: listOfWorkOrder3) {
            System.assertEquals(oppy1.Id, wo.PrimaryOpportunityName__c, 'The Oppy does not match 3');
        }
        
        test.stopTest();    
    }
    
}