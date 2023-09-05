//-----------------------------
// @author: Vishnu Vardhan Chowdary Andra
// @date: 08 Oct 2018
// @param: NA
// @description: Test class for CreateOMDHCaseController methods 
// @return: NA
//-----------------------------
@isTest
public class TestCreateOMDHCaseController {

    //-----------------------------
    // @author: Vishnu Vardhan Chowdary
    // @date: 08 Oct 2018
    // @description: Method to create test data.
    // @param: 
    // @return: void
    //-----------------------------
    @testSetup 
    static void dataSetup() {
        Account acc = TestUtility.createTestAccount('Account testAccount', false);
        acc.DataGovernanceStatus__c = 'Approved';
        insert acc;

        List<LoadingGroup__c> lgList = new List<LoadingGroup__c> ();
        lgList.add(TestUtility.createLoadingGroup('IHS', 'IHS Lg1', false));
        lgList.add(TestUtility.createLoadingGroup('IHS', 'Markit Lg2', false));
        lgList.add(TestUtility.createLoadingGroup('Markit', 'Markit Lg3', false));
        lgList.get(0).deliveryTeam__c = 'Erights';
        lgList.get(0).deliveryTeam__c = 'Erights2';
        insert lgList;

        Id standardId = Test.getStandardPricebookId();
        List<Product2> productList = new List<Product2>();
        productList.add(TestUtility.createProductWithLoadingGroup('Test Product1', lgList.get(0).id, false));
        productList.add(TestUtility.createProductWithLoadingGroup('Test Product2', lgList.get(0).id, false));
        productList.add(TestUtility.createProductWithLoadingGroup('Test Product3', lgList.get(1).id, false));
        productList.add(TestUtility.createProductWithLoadingGroup('Test Product4', lgList.get(1).id, false));
        productList.add(TestUtility.createProductWithLoadingGroup('Test Product5', lgList.get(2).id, false));
        insert productList;

        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        pbeList.add(TestUtility.createPriceBookEntry(standardId, productList.get(0).id, false));
        pbeList.add(TestUtility.createPriceBookEntry(standardId, productList.get(1).id, false));
        pbeList.add(TestUtility.createPriceBookEntry(standardId, productList.get(2).id, false));
        pbeList.add(TestUtility.createPriceBookEntry(standardId, productList.get(3).id, false));
        pbeList.add(TestUtility.createPriceBookEntry(standardId, productList.get(4).id, false));
        insert pbeList;

        Opportunity testOpportunity = TestUtility.createOpportunity(acc.Id, 'test Opppy', false);
        testOpportunity.BudgetRange__c = '< 25,000';
        testOpportunity.ActivityCreated__c = true;
        testOpportunity.CloseDate = System.today() + 180;
        insert testOpportunity;

        Contact testContact = TestUtility.createContact(acc.Id, 'testihsmarkit@testihsmarkit.com',
                                                        true, 'Test', 'Contact');
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = testOpportunity.Id, ContactId = testContact.Id, IsPrimary=true);
        insert ocr;

        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        oliList.add(TestUtility.createOpportunityLineItem(testOpportunity.Id, pbeList.get(0), false));
        oliList.add(TestUtility.createOpportunityLineItem(testOpportunity.Id, pbeList.get(1), false));
        oliList.add(TestUtility.createOpportunityLineItem(testOpportunity.Id, pbeList.get(2), false));
        oliList.add(TestUtility.createOpportunityLineItem(testOpportunity.Id, pbeList.get(3), false));
        insert oliList;
        
        Id ofRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Id contractRecId = ContractRecordTypeSelectionController.createDefaultRecord(ofRecordTypeId, testOpportunity.Id);
    }

    //-----------------------------
    // @author: Vishnu Vardhan Chowdary
    // @date: 08 Oct 2018
    // @description: Test method to test if Retail/OM case is created or not.
    // @param: 
    // @return: void
    //-----------------------------
    @isTest
    public static void testRetailAndOMCaseCreation() {
        Id testContractId = [SELECT Id FROM Contract LIMIT 1].Id;
        System.assert(testContractId!=null);
		Test.startTest();
        Case cas = CreateOMDHCaseController.getOMDHRecord();
        Contract ctrct = CreateOMDHCaseController.getContractDetails(testContractId);
        cas.Subject = 'Retail Case';
        cas.Description = 'Retail Case Description';
        cas.TeamSelect__c = 'Retail';
        cas.Contract__c = ctrct.Id;
        cas.DeliveryTeam__c = 'RETAIL-SDM1';
        cas.OrderManagementRegion__c = 'EMEA';
        cas.SingleSignOnSAM__c = false;
        cas.AccountId = ctrct.AccountId;
        cas.AccountReference__c =ctrct.AccountId;
        String successMessage = CreateOMDHCaseController.saveOMDHCase(cas);
        System.assertEquals('Case record created', successMessage);
        cas = [SELECT Id, Contract__c, AccountReference__c, TeamSelect__c FROM case where Contract__c = :testContractId  LIMIT 1];
        System.assertNotEquals(cas, null);
        System.assertEquals(cas.Contract__c, testContractId);
        System.assertEquals(cas.AccountReference__c, ctrct.AccountId);
        Test.stopTest();
    }

    //-----------------------------
    // @author: Vishnu Vardhan Chowdary
    // @date: 08 Oct 2018
    // @description: Test method to test if Delivrey cases are created or not, with correct case products..
    // @param: 
    // @return: void
    //-----------------------------
    @isTest
    public static void testDeliveryCaseCreation() {
        Id testContractId = [SELECT Id FROM Contract LIMIT 1].Id;
        System.assert(testContractId!=null);
        Set<String> delTeams = new Set<String>{'Erights','Global Delivery EMEA ADandM','Global Delivery Help Desk','Delivery Technical'};
        Test.startTest();
        
        Contract ctrct = CreateOMDHCaseController.getContractDetails(testContractId);
        List<ProductSelectorWrapperClass> lstProductWrapper = CreateOMDHCaseController.getAvailableProductsForContract(testContractId);
        System.assertEquals(4, lstProductWrapper.size());//Markit category products are not to be included.
        //remove the last one, and create case. Since we have 2 products for loading group, we will have 2 Cases created.
        lstProductWrapper.remove(3);
        
        Case cas = CreateOMDHCaseController.getOMDHRecord();
        cas.Subject = 'Delivery Case';
        cas.Description = 'Delivery Case Description';
        cas.TeamSelect__c = 'Delivery';
        cas.Contract__c = ctrct.Id;
        cas.OrderManagementRegion__c = 'EMEA';
        //cas.SingleSignOnSAM__c = true;
        cas.AccountId = ctrct.AccountId;
        cas.AccountReference__c =ctrct.AccountId;
        
        String successMessage = CreateOMDHCaseController.createDeliveryCases(cas, Json.serialize(lstProductWrapper));
        System.assertEquals('Cases are Created!', successMessage);

        List<Case> caseList = [SELECT Id, LoadingGroupOnboarding__c, DeliveryTeam__C, (select id, Product__c from CaseProducts__r) 
               FROM case where Contract__c = :testContractId and TeamSelect__c = 'Delivery' and isClosed=false];
        System.assertNotEquals(caseList, null);
        System.assertEquals(caseList.size(), 2);
        //One will have default value, another will have default value
        System.assert(delTeams.contains(caseList.get(0).deliveryTeam__c));
        System.assert(delTeams.contains(caseList.get(1).deliveryTeam__c));
        
        //Again get the products, all 4 should be returned. Earlier only products 
        //for which delivery case is not created, was returned.
        lstProductWrapper = CreateOMDHCaseController.getAvailableProductsForContract(testContractId);
        System.assertEquals(4, lstProductWrapper.size());
        cas.SingleSignOnSAM__c = true;
        successMessage = CreateOMDHCaseController.createDeliveryCases(cas, Json.serialize(lstProductWrapper));
        System.assertEquals('Cases are Created!', successMessage);

        caseList = [SELECT Id, LoadingGroupOnboarding__c, DeliveryTeam__c, (select id, Product__c from CaseProducts__r) 
               FROM case where Contract__c = :testContractId and TeamSelect__c = 'Delivery' and isClosed=false];
        System.assertNotEquals(caseList, null);
        //New cases are added in the above step, making a total of 4
        System.assertEquals(caseList.size(), 4);
        for(case c: caseList) {
            System.assert(delTeams.contains(c.deliveryTeam__c));
        }
        
        //Again get the products for which delivery case is to be created. All products should be returned.
        lstProductWrapper = CreateOMDHCaseController.getAvailableProductsForContract(testContractId);
        System.assertEquals(lstProductWrapper.size(), 4);
        Test.stopTest();
    }
}