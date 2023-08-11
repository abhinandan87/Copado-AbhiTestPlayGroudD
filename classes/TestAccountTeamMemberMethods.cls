//-----------------------------
// @author: Sharique Iqbal	
// @date: 13th Jan 2022
// @description: Test class for AccountTeamMemberMethods trigger methods 
// @company: IHS Markit
//-----------------------------

@isTest
private class TestAccountTeamMemberMethods {

        @isTest
        private static void TestUpdateATMNameOnAcc() {
            //create test data
            Test.startTest();
            User testUser = testUtility.createTestUser('IHSMarkit Data Governance', 'salesUSer345435@test.com', true);
            Account testAccount  = testUtility.createTestAccount('test Account', True );
            Test.stopTest();
            Account Acc = [Select Id, AccountTeamMembers__c From Account Where Name = 'test Account' limit 1];
            System.assert(Acc.AccountTeamMembers__c != null ,'Account Team Member Name was not updated on Account');
        }
        
        @isTest
        private static void TestUpdateATMNameOnAccForDeletion() {
            //create test data
            Test.startTest();
            User testUser = testUtility.createTestUser('IHSMarkit Data Governance', 'salesUSer345435@test.com', true);
            Account testAccount  = testUtility.createTestAccount('test Account', True );
            List<AccountTeamMember> atmList = [Select Id From AccountTeamMember Where AccountId = :testAccount.Id limit 1];
            delete atmList;
            Test.stopTest();
            Account Acc = [Select Id, AccountTeamMembers__c From Account Where Name = 'test Account'];
            System.assert(Acc.AccountTeamMembers__c == null ,'Account Team Member Name was not updated on Account');
         
        }
}