/**
* @Author : Mohit Modi
* @Date : 14 Nov 2017
* @Description : Test Class for accessCheckController
* @company : Vertiba
*/
    @isTest
    private class TestProductSelectorController {
    
        @testSetup static void setup() {
            Account acc = TestUtility.createTestAccount('Account testAccountforOpp', true);
            
            Contact c = new Contact();
        	c.firstname = 'Test';
        	c.lastname = 'testSetCaseAdditionalFieldsObject';
        	c.AccountId = acc.Id;
        	c.Phone = '12345';
        	c.EmailUnknown__c = true;
            insert c;
     
            Product2 testProd = TestUtility.createProduct('Test Product', true);
            Id standardId = Test.getStandardPricebookId();
            LegalEntity__c legalEntity = TestUtility.createLegalEntity('testLegalEntity','USD');
            List<Country__c> lstCountry = TestUtility.loadCountryData();
            Country__c country = lstCountry.get(0);
            Contract contract = TestUtility.createContractWithInsertOptional(acc.Id, legalEntity.Id, country.Id, standardId,FALSE);
            Id orderFormRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
            contract.recordtypeid = orderFormRecordTypeId;
            insert contract;
    		
            List<Opportunity> oppyList = new List<Opportunity>();
            Opportunity testOpportunity1 = TestUtility.createOpportunity(acc.Id,'first test Oppy', false);
            testOpportunity1.Amount = 1000;
        	oppyList.add(testOpportunity1);
        	User u = TestUtility.createTestUser('IHSMarkit Sales: General','standardrollupuser@testorg.com',true);
            User u2 = TestUtility.createTestUser('IHSMarkit Sales: User Support','usersupport@testorg.com',true);
            
        	Id RecordTypeIdOppty = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Inner Year').getRecordTypeId();
            Id renRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
            Opportunity testOpportunity2 = TestUtility.createOpportunity(acc.Id,'Rollup test Oppy', false);
            testOpportunity2.recordtypeid = RecordTypeIdOppty;
            testOpportunity2.StageName = '6WP-Closed Won/Order Processed';
        	testOpportunity2.ContractBeingRenewed__c = contract.Id;
        	testOpportunity2.AutoRenewal__c = true;
            testOpportunity2.DoesThisAutoRenewalHaveChanges__c = false;
            testOpportunity2.OwnerId = u.Id;
        	oppyList.add(testOpportunity2);   
          
            Opportunity testRenewalOpp = TestUtility.createOpportunity(acc.id,'Test Opp Renewal', false);
            testRenewalOpp.StageName= '3-Renewal Pending';
            testRenewalOpp.RecordTypeId = renRecordTypeId;
        	testRenewalOpp.AutoRenewal__c = true;
            testRenewalOpp.PriceChangeOnly__c = false;
            testRenewalOpp.DoesThisAutoRenewalHaveChanges__c = false;
        	oppyList.add(testRenewalOpp);

            Opportunity testOpportunity4 = TestUtility.createOpportunity(acc.Id,'Inner Year test Oppy', false);
            testOpportunity4.recordtypeid = RecordTypeIdOppty;
            testOpportunity4.StageName = '1-Sales Qualified';
            testOpportunity4.ContractBeingRenewed__c = contract.Id;
        	testOpportunity4.AutoRenewal__c = true;
            testOpportunity4.DoesThisAutoRenewalHaveChanges__c = false;
            testOpportunity4.OwnerId = u.Id;
            oppyList.add(testOpportunity4);

        	insert oppyList;
            
            OpportunityContactRole oppContactRole = new OpportunityContactRole();
            oppContactRole.OpportunityID = testRenewalOpp.id;
            oppContactRole.ContactId = c.id;
            oppContactRole.IsPrimary = true;
            insert oppContactRole;
        }    
        
        @isTest
        private static void testCommunityCheck () {
                   	
            test.startTest();
            Boolean isCommunity = ProductSelectorController.isCommunity();
            System.assertEquals(false, isCommunity, 'Community Portal');
            test.stopTest();
        }
        
         @isTest
        private static void testcheckRecordAccessforUser () {
                   	
            test.startTest();
            Opportunity testOpportunity1 = [Select id from Opportunity where Name = 'first test Oppy' LIMIT 1];
            Opportunity testOpportunity3 = [Select id from Opportunity where Name = 'Test Opp Renewal' LIMIT 1];
            ProductSelectorController.ProductSelectorValidatorWrapper assertAccess = ProductSelectorController.checkRecordAccessforUser (userinfo.getuserID(),testOpportunity1.id,'Add Products');
            System.assertEquals(true, assertAccess.isSuccess,'Check access is true' );
            User u = [select Id from User where Email = 'usersupport@testorg.com' LIMIT 1];
            System.runAs(u) {
                ProductSelectorController.ProductSelectorValidatorWrapper assertAccess2 = ProductSelectorController.checkRecordAccessforUser (u.Id,testOpportunity3.id,'Edit Products');
                System.assertEquals(false, assertAccess2.isSuccess,'Check access is false' );
            }
            test.stopTest();
        }
        
         @isTest
        private static void testcheckRecordAccessforGeneral () {
                   	
            test.startTest();
            Opportunity testOpportunity3 = [Select id from Opportunity where Name = 'Test Opp Renewal' LIMIT 1];
            Opportunity testOpportunity2 = [Select id from Opportunity where Name = 'Rollup test Oppy' LIMIT 1];
            Opportunity testOpportunity4 = [Select id from Opportunity where Name = 'Inner Year test Oppy' LIMIT 1];
            
            ProductSelectorController.ProductSelectorValidatorWrapper assertAccess = ProductSelectorController.checkRecordAccessforUser (userinfo.getuserID(),testOpportunity3.id,'Add Products');
            System.assertEquals(false, assertAccess.isSuccess,'Check access is true' );
            User u = [select Id from User where Email = 'standardrollupuser@testorg.com'];
            System.runAs(u) {
                ProductSelectorController.ProductSelectorValidatorWrapper assertAccess2 = ProductSelectorController.checkRecordAccessforUser (u.Id,testOpportunity2.id,'Add Products');
                System.assertEquals(false, assertAccess2.isSuccess,'Check access is false' );
                ProductSelectorController.ProductSelectorValidatorWrapper assertAccess3 = ProductSelectorController.checkRecordAccessforUser (u.Id,testOpportunity4.id,'Add Products');
                System.assertEquals(false, assertAccess3.isSuccess,'Check access is false' );
            }
            test.stopTest();
        }
         @isTest
        private static void testExceptionRequestStatus () {
                   	
            test.startTest();
            Opportunity testOpty = [Select id, Amount from Opportunity where Name = 'first test Oppy' LIMIT 1];
            System.assertEquals(1000, testOpty.Amount, 'Amount should be 1000');
            String exceptionStatus = ProductSelectorController.exceptionRequestCheck(testOpty.Id);
            System.assertEquals(Null, exceptionStatus, 'Exception Status should be Blank');
            test.stopTest();
        }
    }