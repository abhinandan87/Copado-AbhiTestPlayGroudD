//-----------------------------
// @author: Uttam Arya
// @date: 22 June 2017
// @param: NA
// @description: SFDC1-834 TestLiveChatOfflineFormController - test class for LiveChatPreChatController
// @return: NA
//-----------------------------
@isTest(seealldata=false)
private class TestLiveChatPreChatController {
    // ensure Chat_Survey__c inserted and redirection to confirmation page occurs
    @isTest
    static void test1() {
        
        Account ac = TestUtility.createTestAccount('Test Pre Chat',true);

        //START - Insert Product Group
        String groupName = 'Active Live Chat';
        ProductGroup__c objProductGroup = TestUtility.createProductGroup(groupName, false);
        objProductGroup.VisibleInLiveChat__c = true;
        objProductGroup.Status__c = 'Active';
        insert objProductGroup;
        //END
        
        Contact myContact1 = TestUtility.createContact(ac.Id, 'uttam.arya@test.ihsmarkit.com',true, 'Uttam', 'Arya');
        
        PageReference pageRef = Page.LiveChatPreChat;
        
        Test.setCurrentPage(pageRef);

        LiveChatPreChatController controller = new LiveChatPreChatController();
        
        controller.suppliedemail = 'uttam.arya@test.ihsmarkit.com';
        
        Contact assertCon = LiveChatPreChatController.getContact(controller.suppliedemail);
        
        System.assertEquals(myContact1.Id, assertCon.Id);
        
        //START - Assert Product ID
        controller.SelectedProduct = groupName;
        controller.productIdSecuritiesFinance = objProductGroup.id;
        String pId = LiveChatPreChatController.getProductId(groupName);
        System.assert(string.isNotBlank(pId));
        //END
    }
    
}