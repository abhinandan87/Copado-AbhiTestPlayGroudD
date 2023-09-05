//-----------------------------
// @author: Digvijay Singh
// @date: 24 Mar 2021
// @param: NA
// @description: Test class for Case Comment trigger methods 
// @return: NA
//-----------------------------

@isTest
public with sharing class TestCaseCommentMethods {
   
    //-----------------------------
    // @author: Digvijay 
    // @date: 24 March 2021
    // @param: NA
    // @description: Test method for Case comment trigger methods 
    // @return: NA
    //-----------------------------

    private static testMethod void testupdateFieldOnCaseOnNewComment() {
        Id customerCaseRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId();
        Account a = TestUtility.createTestAccount('Account For Case Comment Test', true);
        
        Contact c = TestUtility.createContact(a.Id,'xyz1929@gmail.com',true,'Test1919','LName1929');

        Case testCase = TestUtility.createCase(customerCaseRecordTypeId, a.Id, c.Id, 
                                  UserInfo.getUserId(), 'Test Subject', true);

        Test.startTest();
        CaseComment objcomment = new CaseComment();
        objcomment.CommentBody = 'Case Comment';
        objcomment.ParentId = testCase.id;
        insert objcomment ;
         
        testCase = [Select Id ,LastModifiedDateForRelatedData__c,DaysSinceCaseLastModified__c from case where Id=:testCase.id];
        //LastModifiedDateForRelatedData__c should update with  Date time when the Case comment was added.
        System.assertNotEquals(testCase.LastModifiedDateForRelatedData__c, null);
        //DaysSinceCaseLastModified__c should the differnce betwen today and when the last case comment was added.
        System.assertEquals(testCase.DaysSinceCaseLastModified__c , 0);
        Test.StopTest();

    }

      //-----------------------------
    // @author: Digvijay 
    // @date: 24 March 2021
    // @param: NA
    // @description: Test method for Case comment trigger methods 
    // @return: NA
    //-----------------------------

    private static testMethod void testupdateFieldOnCaseOnCommentUpdate() {
        Id customerCaseRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId();
        Account a = TestUtility.createTestAccount('Account For Case Comment Test', true);
        
        Contact c =TestUtility.createContact(a.Id,'xyz1929@gmail.com',true,'Test1919','LName1929');

        Case testCase = TestUtility.createCase(customerCaseRecordTypeId, a.Id,c.Id, 
                                  UserInfo.getUserId(), 'Test Subject', true);

        
        CaseComment objcomment = new CaseComment();
        objcomment.CommentBody = 'Case Comment';
        objcomment.ParentId = testCase.id;
        insert objcomment ;

        Test.startTest();
        objcomment.CommentBody = 'Case comment Update';
        update objcomment;
        testCase = [Select Id ,LastModifiedDateForRelatedData__c,DaysSinceCaseLastModified__c from case where Id=:testCase.id];
        //LastModifiedDateForRelatedData__c should update with  Date time when the Case comment was added.
        System.assertNotEquals(testCase.LastModifiedDateForRelatedData__c, null);
        //DaysSinceCaseLastModified__c should the differnce betwen today and when the last case comment was added.
        System.assertEquals(testCase.DaysSinceCaseLastModified__c , 0); 
        Test.StopTest();

    }
}