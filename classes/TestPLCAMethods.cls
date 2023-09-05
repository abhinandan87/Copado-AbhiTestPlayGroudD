// @author: Vishnu Vardhan Chowdary
// @date: 17 Dec 2018
// @param: NA
// @description: Test class for Product Login Contact Association trigger methods 
// @return: NA
//-----------------------------
@isTest
public class TestPLCAMethods {

    //-----------------------------
    // @author: Vishnu Vardhan Chowdary
    // @date: 17 Dec 2018
    // @param: NA
    // @description: SFDC1-10703 Test method for populateUniqueProductLoginContactId
    // @return: NA
    //-----------------------------
    private static testMethod void testPopulateUniqueProductLoginContactId() {
        Account a = TestUtility.createTestAccount(System.Label.CaseUnknownAccountName, true);

        Contact con = new Contact();
        con.firstname = 'Test1';
        con.lastname = 'Test1';
        con.Email = 'pl.contactExists@ihsmarkit.com';
        con.AccountId = a.Id;
        insert con;
        Test.startTest();
        
        ProductLogin__c testProductLogin = TestUtility.createProductLogin('testPopulateUniqueProductLoginContactId@test.com', false);
        testProductLogin.Email__c = con.Email;
        insert testProductLogin;
        list <ProductLogin__c> testProductLoginResult = [SELECT Id,
                                             (SELECT UniqueProductContactId__c, Contact__c FROM ProductLoginContactAssociations1__r) 
                                             FROM ProductLogin__c];
        //Assert if Product Login is inserted
        System.assertEquals(1, testProductLoginResult.size());
        System.assert(testProductLoginResult[0].ProductLoginContactAssociations1__r != null);
        ProductLoginContactAssociation__c pLCA = testProductLoginResult[0].ProductLoginContactAssociations1__r.get(0);
        System.assertEquals(pLCA.Contact__c, con.Id);
        System.assertEquals(pLCA.UniqueProductContactId__c, testProductLogin.Id + '' + con.Id);

        Test.stopTest();
    }
}