/*  @author: Akash Punera
*   @date: 8 Jun 2022
*   @description: Test class for RecordEditController
*/
@isTest(SeeAllData=false)
public class TestRecordEditController {
    @isTest
    public static void testgetCase() {
        Account objAcc = TestUtility.createTestAccount('Test Account', false);
        insert objAcc;
        
        Contact testContact = TestUtility.createContact(objAcc.id, 'testcontactfor@case.com', false,
                                                        'Test', 'test case contact');
        insert testContact;
        
        Id caseRecordTypeId = Schema.SobjectType.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId();
        Case objCase = TestUtility.createCase(caseRecordTypeId, objAcc.Id, testContact.Id,
                                               UserInfo.getUserId(), 'Test Subject', true);
        test.startTest();
        Case c = RecordEditController.getCase(objCase.id);
        system.assert(c.id == objCase.id,'Case id does not match');
        test.stoptest();
    }
}