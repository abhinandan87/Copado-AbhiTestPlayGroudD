/*--------------------------------------------------------------------------------------------------------------------
    Author:        Akshay Dogra
    Company:       
    Description:   TestLiveChatPostChatController - test class for LiveChatPostChatFormController
    History
    21/03/2022    First Release
----------------------------------------------------------------------------------------------------------------------*/
@IsTest
private class TestLiveChatPostChatController {
    
    /*
    * @author: Akshay Dogra
    * @date: 15 March 2022
    * @description: SFDC1-834, SFDC1-281 LiveChatPostChatController - visualforce controller for LiveChatPostChat page.
    * @companyname:
    */ 
    @IsTest
    private static void liveChatPostChat() {
        
        LiveChatPostChatController.LiveAgentInput lAI = new LiveChatPostChatController.LiveAgentInput('contactEmail',null,null,null,null,null);
        
        String str = '[{"label": "contactEmail","value": "jon@example.com","LiveAgentInput": [{"label": "contactEmail","value": "contactEmail","contactEmail": "abc@abc.com","msfProductCode": "123","isExactMatchable": true}],"transcriptFields": [ "c__EmailAddress"],"displayToAgent": true},{"label": "msfProductCode","value": "jon@example.com","LiveAgentInput": [{"label": "contactEmail","value": "contactEmail","contactEmail": "abc@abc.com","msfProductCode": "123","isExactMatchable": true}],"transcriptFields": [ "c__EmailAddress"],"displayToAgent": true},{"label": "buttonOrigin","value": "jon@example.com","LiveAgentInput": [{"label": "contactEmail","value": "contactEmail","contactEmail": "abc@abc.com","msfProductCode": "123","isExactMatchable": true}],"transcriptFields": [ "c__EmailAddress"],"displayToAgent": true}]';
        String ck = 'TEST123';
        String body = '<p align="center">Chat Started: Tuesday, July 25, 2017, 01:44:14 (+0530)</p><p align="center">Chat Origin: IHSMarkitSupportMCS</p><p align="center">Agent Uttam A</p>( 2s ) Uttam A: Hello Uttam Arya, welcome to IHS Markit live chat support, my name is Uttam how can I help you today?<br>';
        
        Account ac = TestUtility.createTestAccount('Test Post Chat',true);
        Contact myContact1 = TestUtility.createContact(ac.Id, 'akshay.dogra@test.com',true, 'Akshay', 'Dogra');
 		ProductGroup__c pg = TestUtility.createProductGroup('Delivery', true);
        
        AdditionalCaseTypeLinking__c aCaseTypeLinkingNRG = TestUtility.createAdditionalCaseTypeLinking('Customer Care','NRG',false);
        aCaseTypeLinkingNRG.ProductGroup__c = pg.Id;
        insert aCaseTypeLinkingNRG;
        
        Id caseRecordTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId();
        
        Case testCase = TestUtility.createCase(caseRecordTypeId, ac.Id, myContact1.Id,  userInfo.getUserId(), 'Test subject Live Chat Test', false);
        testCase.ProductGroup__c = pg.Id;
        insert testCase;
        
        PageReference pageRef = Page.LiveChatPostChat;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('chatKey','Thank you');
        pageRef.getParameters().put('chatDetails',str);
        
        LiveChatPostChatController controller = new LiveChatPostChatController();
        controller.email = 'akshay.dogra@test.com';
        controller.emailExist = false;
        controller.chatKey = ck;
        controller.sendTranscript = 'Yes';
        controller.buttonOrigin = 'MSF';
        controller.msfProductCode = 'SFP';
        
        PageReference result1 = controller.redirect();
        
        LiveChatVisitor v = new LiveChatVisitor();
        insert v;
        LiveChatTranscript t = new LiveChatTranscript(ChatKey = ck, LiveChatVisitorId = v.Id, body = body);
        t.CaseId = testCase.Id;
        insert t;

        MSFPlatform__c c1= TestUtility.createMSFPlatform('SFT', 'API', ' Excel Toolkit', true);
        MSFPlatform__c c2= TestUtility.createMSFPlatform('SFP', 'Web Application', ' Web Portal', true);
        
        PageReference result = controller.submit();
        
        controller.sendTranscript = 'No';
        controller.submit();
        
        // verify that page fails without parameters
        System.assertEquals(Page.livechatpostchat.getURL(), result.getURL().split('\\?')[0]); 
    }  
}