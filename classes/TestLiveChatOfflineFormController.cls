/*--------------------------------------------------------------------------------------------------------------------
    Author:        
    Company:       
    Description:   TestLiveChatOfflineFormController - test class for LiveChatOfflineFormController
    History
    07/01/2016     First Release
----------------------------------------------------------------------------------------------------------------------*/
@isTest
private class TestLiveChatOfflineFormController {
    // ensure Case inserted and redirection to confirmation page occurs
    static testMethod void testCaseCreation() {
        
                
        Account ac = TestUtility.createTestAccount('Test Pre Chat',true);
        Contact myContact1 = TestUtility.createContact(ac.Id, 'uttam.arya@test.com',true, 'Uttam', 'Arya');
       	insert new MSFPlatform__c(Name = 'MSF',Platform__c = 'Web Portal', DeliveryMechanism__c = 'Web Application');
        insert new ProductGroup__c(Name = 'MSF',VisibleInLiveChat__c = true, Status__c = 'Active');
        PageReference pageRef = Page.LiveChatOfflineForm;
        Test.setCurrentPage(pageRef);
        System.currentPageReference().getParameters().put('suppliedProduct', 'MSF');
        
        LiveChatOfflineFormController controller = new LiveChatOfflineFormController();
        controller.email = 'uttam.arya@test.com';
        controller.phone = '01234';
        controller.message = 'my comment';
        
        PageReference result = controller.submit();
        Case c = [select id from Case];
        System.assert(c != null);
        // verify that page fails without parameters
        System.assertEquals(Page.LiveChatConfirmation.getURL(), result.getURL().split('\\?')[0]);
        
        System.currentPageReference().getParameters().put('buttonOrigin', 'MSF');
        LiveChatOfflineFormController lcof = new LiveChatOfflineFormController();
        lcof.email = 'test.test@test.com';
        lcof.phone = '01234';
        lcof.message = 'my comment';
        lcof.contactName = 'Test';
        lcof.accountName = 'Test';
        lcof.submit();
        List<Case> lstCase = [Select Id from Case WHERE Suppliedemail = 'test.test@test.com'];
        System.assertEquals(1, lstCase.size(),'Verifying that the case has been created');
    }
}