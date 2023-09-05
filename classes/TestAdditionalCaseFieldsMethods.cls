//-----------------------------
// @author: Uttam Arya
// @date: 22 June 2017
// @param: NA
// @description: Test class for Additional Case Fields trigger methods 
// @return: NA
//-----------------------------

@isTest
private class TestAdditionalCaseFieldsMethods {

    //-----------------------------
    // @author: Uttam Arya
    // @date: 22 June 2017
    // @param: NA
    // @description: Test method for Additional Case Fields trigger methods populateAdditionalFiledsLookupInCase on insert
    // @return: NA
    //-----------------------------
	@isTest 
    static void testpopulateAdditionalFiledsLookupInCase() {
	    
	    Account a = TestUtility.createTestAccount('Account testpopulateAdditionalFiledsLookupInCase', true);
        
        Contact c = new Contact();
        c.firstname = 'Test';
        c.lastname = 'testpopulateAdditionalFiledsLookupInCase';
        c.AccountId = a.Id;
        
        //Assuming NRG recordtype exist in system
        
        ProductGroup__c pg = new ProductGroup__c();
        pg.Name = 'NRG';
        insert pg;
        
        Case testCase = new Case();
        testCase.subject = 'Test subject testpopulateAdditionalFiledsLookupInCase';
        testCase.AccountId = a.Id;
        testCase.contactId = c.Id;
        insert testCase;
        
        AdditionalCaseFields__c acf = new AdditionalCaseFields__c();
        acf.Case__c = testCase.Id;
        insert acf;
        
        list <Case> testCaseResult = [Select AdditionalFields__c, Id from case where Id = :testCase.Id];
         System.assertEquals(1, testCaseResult.size(),'Verify that the case is created');
        System.assertEquals(acf.Id, testCaseResult[0].AdditionalFields__c,'Compare the AddionalcCaseField Id');

	}
    //-----------------------------
    // @author: Vishnu vardhan Chowdary Andra
    // @date: 19 June 2018
    // @description: This method tests that case is assigned to queue mentioned in Delivery Queue field 
    // 				of Delivery Case record type.
    // @companyname: VERTIBA 
    //----------------------------- 
    /*@isTest
    private static void testDeliveryCaseOwnerAssignment() {
        Id caseRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId();
        Id deliveryRecordTypeId = Schema.Sobjecttype.AdditionalCaseFields__c.getRecordTypeInfosByName().
        								get('Delivery').getRecordTypeId();
        Account testAccount = TestUtility.createTestAccount('testAccount', true);
        Contact testContact = TestUtility.createContact(testAccount.Id, 'testihsmarkit@testihsmarkit.com',
                                                        true, 'Test', 'Contact');
        ProductGroup__c testProductgroup = TestUtility.createProductGroup('Delivery', true, false);
        
        AdditionalCaseTypeLinking__c aCaseTypeLinkingDelivery = new AdditionalCaseTypeLinking__c();
        aCaseTypeLinkingDelivery.CaseRecordType__c = 'Customer Care';
        aCaseTypeLinkingDelivery.AdditionalCaseRecordType__c = 'Delivery';
        aCaseTypeLinkingDelivery.ProductGroup__c = testProductgroup.Id;
        insert aCaseTypeLinkingDelivery;
        
        System.debug('aCaseTypeLinkingDelivery:' + aCaseTypeLinkingDelivery);
        
        Case testCase = new Case();
        testCase.RecordTypeId = caseRecordTypeId;
        testCase.ProductGroup__c = testProductgroup.id;
        testCase.subject = 'Test subject';
        testCase.AccountId = testAccount.Id;
        testCase.contactId = testContact.Id;
        insert testCase;
        
        Map<String,Id> queueIdMap = new map<String,Id>();
        for(Group queue : [Select Name, Id From Group where Type = 'Queue'
                                      and name in ('OE PD/4D/Haystack')]) {
            queueIdMap.put(queue.Name, queue.id);
        }

        Test.startTest();
        testCase = [Select id, OwnerId, AdditionalFields__c from case where id =: testCase.Id];
        //updating delivery queue field to Erights. Case owner should be changed to Erights. 
        AdditionalCaseFields__c acf = new AdditionalCaseFields__c(id=testCase.AdditionalFields__c);
        acf.DeliveryQueue__c= 'OE PD/4D/Haystack';
        update acf;
        testCase = [Select id, OwnerId, AdditionalFields__c from case where id =: testCase.Id];
        System.assertEquals(queueIdMap.get(acf.DeliveryQueue__c), testCase.OwnerId,'Case owner is not correct');
        Test.stopTest();
    }*/

    //-----------------------------
    // @author: Vishnu vardhan Chowdary Andra
    // @date: 14 August 2018
    // @description: This method tests that OMDH case is created and updated from ACF, OMDH is a
    // 			child case of Customer Case
    // @companyname: VERTIBA 
    //-----------------------------     
    @isTest
    private static void testCreateOrUpdateCaseFromACF() {
        Account a = TestUtility.createTestAccount('IHS Markit', true);
        
        String testEmail = 'test@ihsmarkit.com';
        User myTestUser = TestUtility.createAdminUser(testEmail, true);
        
        Contact c = TestUtility.createContact(a.Id,testEmail ,true,'Test', 'testSetCaseAdditionalFieldsObject');
        //creating contract
        Product2 testProd = TestUtility.createProduct('Test Product', true);
        Id standardId = Test.getStandardPricebookId();
        PricebookEntry testPBE = TestUtility.createPriceBookEntry(standardId, testProd.Id, true);
        
        LegalEntity__c legalEntity = TestUtility.createLegalEntityWithEligibleFields('testLegalEntity','USD', true, 
                                                                  'No', 'No', 'Yes', 'No', 'No', 'No', 'No');
        List<Country__c> lstCountry = TestUtility.loadCountryData();
        Country__c country = lstCountry.get(0);
        Contract contract1 = TestUtility.createContractWithInsertOptional(a.Id, legalEntity.Id, country.Id, standardId,true);

        List<ProductGroup__c> productGroups = new List<ProductGroup__c> ();
        productGroups.add(new ProductGroup__c(Name = 'Order Mgmt. Helpdesk'));
        productGroups.add(new ProductGroup__c(Name = 'Delivery Helpdesk'));
        productGroups.add(new ProductGroup__c(Name = 'Retail Helpdesk'));
        insert productGroups;
        
        List<AdditionalCaseTypeLinking__c> actlRecords = new List<AdditionalCaseTypeLinking__c>();
        actlRecords.add(new AdditionalCaseTypeLinking__c(ADDITIONALCASERECORDTYPE__C='Order Management Helpdesk',CASERECORDTYPE__C='Customer Care',PRODUCTGROUP__C=productGroups.get(0).id));
        actlRecords.add(new AdditionalCaseTypeLinking__c(ADDITIONALCASERECORDTYPE__C='Order Management Helpdesk',CASERECORDTYPE__C='Order Management/Delivery Help Desk',PRODUCTGROUP__C=productGroups.get(0).id));
        actlRecords.add(new AdditionalCaseTypeLinking__c(ADDITIONALCASERECORDTYPE__C='Delivery Helpdesk',CASERECORDTYPE__C='Customer Care',PRODUCTGROUP__C=productGroups.get(1).id));
        actlRecords.add(new AdditionalCaseTypeLinking__c(ADDITIONALCASERECORDTYPE__C='Delivery Helpdesk',CASERECORDTYPE__C='Order Management/Delivery Help Desk',PRODUCTGROUP__C=productGroups.get(1).id));
        actlRecords.add(new AdditionalCaseTypeLinking__c(ADDITIONALCASERECORDTYPE__C='Retail',CASERECORDTYPE__C='Customer Care',PRODUCTGROUP__C=productGroups.get(2).id));
        actlRecords.add(new AdditionalCaseTypeLinking__c(ADDITIONALCASERECORDTYPE__C='Retail',CASERECORDTYPE__C='Order Management/Delivery Help Desk',PRODUCTGROUP__C=productGroups.get(2).id));
        insert actlRecords;
        // creating case
        Id omdhRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName(). get('Order Management/Delivery Help Desk').getRecordTypeId();
        Id customerCaseRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId();
        Id deliveryRecordTypeId = Schema.Sobjecttype.AdditionalCaseFields__c.getRecordTypeInfosByName(). get('Delivery Helpdesk').getRecordTypeId(); 
        Id retailRecordTypeId = Schema.Sobjecttype.AdditionalCaseFields__c.getRecordTypeInfosByName(). get('Retail').getRecordTypeId();
        Id omRecordTypeId = Schema.Sobjecttype.AdditionalCaseFields__c.getRecordTypeInfosByName(). get('Order Management Helpdesk').getRecordTypeId();

        List<Case> customerCases = new List<Case>();
        Case case1 = TestUtility.createCase(customerCaseRecordTypeId, a.Id, c.Id, userInfo.getUserId(), 'OM Case', false);
        case1.ProductGroup__c = productGroups.get(0).Id;
        Case case2 = TestUtility.createCase(customerCaseRecordTypeId, a.Id, c.Id, userInfo.getUserId(), 'Delivery Case', false);
        case2.ProductGroup__c = productGroups.get(1).Id;
        Case case3 = TestUtility.createCase(customerCaseRecordTypeId, a.Id, c.Id, userInfo.getUserId(), 'Retail Case', false);
        case3.ProductGroup__c = productGroups.get(2).Id;
        customerCases.add(case1);
        customerCases.add(case2);
        customerCases.add(case3);
        insert customerCases;
        List<Id> caseIds = new List<Id>();
        Test.startTest();
        for(Case cas:customerCases) {
            caseIds.add(cas.Id);
        }
        List<AdditionalCaseFields__c> acfList = [select id, OMRegion__c, SFDCContract__c, SAPContractOrder__c, DeliveryTeam__c,
                                                 DocNumber__c, SDONumber__c, RMA__c, GEDOrderInvoice__c, Subscription__c,
                                                 RecordTypeId from AdditionalCaseFields__c where case__c in :caseIds];
        System.assertEquals(3, acfList.size(),'Verify the size of ACF');
        List<AdditionalCaseFields__c> acfListTest = new List<AdditionalCaseFields__c>();
        //Now update acf's such that OMDH case is created.
        for(AdditionalCaseFields__c acf:acfList) {
            if(acf.RecordTypeId == omRecordTypeId) {
                acf.OMRegion__c = 'EMEA';
                acf.SFDCContract__c = contract1.Id;
                acf.SAPContractOrder__c = 'SAP Contract';
            } else if (acf.RecordTypeId == deliveryRecordTypeId) {
                acf.DeliveryTeam__c = 'Global Insight Fulfillment';
            } else {
                acf.DeliveryTeam__c = 'RETAIL-Order Fulfillment';
                acf.SDONumber__c = 'Retail SDO Number';
                acf.DocNumber__c = 'Retail DOC Number';
            }
            acfListTest.add(acf);
        }
        System.runAs(myTestUser) { //There is a validation to check contact should have logged in user email
            update acfListTest;//3 child cases to be created. 
            List<Case> childCaseList = [Select id, Doc__c, SDO__c, DeliveryTeam__c, SAPContractOrder__c, TeamSelect__c,
                                        RMA__c, OMDStatus__c, Contract__c, OrderManagementRegion__c
                                        from Case where recordtypeId =: omdhRecordTypeId];
            System.assertEquals(3, childCaseList.size(),'Verify child case size');
            for (Case cas : childCaseList) {
                System.assertEquals(cas.OMDStatus__c, 'New','Check OMDStatus');
                if(cas.TeamSelect__c == 'Order Management') {
                    System.assertEquals(cas.OrderManagementRegion__c, 'EMEA','verify OM Region');
                    System.assertEquals(cas.SAPContractOrder__c, 'SAP Contract','Verify SAP Contract');
                    System.assertEquals(cas.Contract__c, contract1.Id,'Comapre Contract Ids');
                } else if(cas.TeamSelect__c == 'Delivery') {
                    System.assertEquals(cas.DeliveryTeam__c, 'Global Insight Fulfillment','Verify Delivery team');
                    System.assert(String.isBlank(cas.RMA__c),'Verify RMA');
                } else {
                    System.assertEquals(cas.Doc__c, 'Retail DOC Number','DOC');
                    System.assertEquals(cas.SDO__c, 'Retail SDO Number','SDO');
                    System.assertEquals(cas.DeliveryTeam__c, 'RETAIL-Order Fulfillment','Delivery team');
                    System.assert(String.isBlank(cas.RMA__c),'RMS is blank');
                }
            }
            acfListTest = new List<AdditionalCaseFields__c>();
            for(AdditionalCaseFields__c acf:acfList) {
                if(acf.RecordTypeId == omRecordTypeId) {
                    acf.SAPContractOrder__c = 'Test Contract';
                } else if (acf.RecordTypeId == deliveryRecordTypeId) {
                    acf.RMA__c = 'Delivery RMA';
                } else {
                    acf.RMA__c = 'Retail RMA';
                }
                acfListTest.add(acf);
            }
            update acfListTest;
            childCaseList = [Select SAPContractOrder__c, RMA__c, TeamSelect__c from Case where recordtypeId =: omdhRecordTypeId];
            System.assertEquals(3, childCaseList.size(),'Verify child case list size');
            for (Case cas : childCaseList) {
                if(cas.TeamSelect__c == 'Order Management') {
                    System.assertEquals(cas.SAPContractOrder__c, 'Test Contract','SAP Contract Order');
                } else if(cas.TeamSelect__c == 'Delivery') {
                    System.assertEquals(cas.RMA__c, 'Delivery RMA','Delivery RMA');
                } else {
                    System.assertEquals(cas.RMA__c, 'Retail RMA','Retail RMA');
                }
            }
        }
        Test.stopTest();
    }
    
    //-----------------------------
    // @author: Vaishali Jain
    // @date: 13 April 2021
    // @param: NA 
    // @description: This method tests that ResolvedbyIHSMarkitOPSTeam picklist and notes are mandatory on case on update of ACF
    // @return: NA 
    //-----------------------------     
    @isTest
    private static void testNotesMandatoryForResolvedbyIHSMarkitOPSTeam() {
        Id nrgRecordTypeId = Schema.Sobjecttype.AdditionalCaseFields__c.getRecordTypeInfosByName().get('NRG').getRecordTypeId();
        Account a = TestUtility.createTestAccount('Account testNotesMandatoryForResolvedbyIHSMarkitOPSTeam', true);
        
        Contact c = new Contact();
        c.firstname = 'Test';
        c.lastname = 'testNotesMandatoryForResolvedbyIHSMarkitOPSTeam';
        c.AccountId = a.Id;
        c.Email = 'test630@test.com';
        insert c;
        
        Case testCase = new Case();
        testCase.subject = 'Test subject testNotesMandatoryForResolvedbyIHSMarkitOPSTeam';
        testCase.AccountId = a.Id;
        testCase.contactId = c.Id;
        insert testCase;
        
        AdditionalCaseFields__c acf = new AdditionalCaseFields__c();
        acf.Case__c = testCase.Id;
        acf.RecordTypeId = nrgRecordTypeId;
        acf.ResolvedbyIHSMarkitOPSTeam__c = 'Resolved by CC & OPS';
        Test.startTest();
        try{
        insert acf;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false,'expectedExceptionThrown');
        }
        Test.stopTest();
    }
}