//-----------------------------
// @author: Vinod Merwade
// @date: 6 Nov 2017
// @description:  Test class for the CustomLinkController
// @return: NA
// @Company: Vertiba
//-----------------------------

@isTest
public class TestCustomLinkController {
    
    //-----------------------------
    // @author: Vinod Merwade
    // @date: 6 Nov 2017
    // @description:  Test Setup for the loading the custom links
    // @return: NA
    // @Company: Vertiba
    //-----------------------------
    
    @testSetup public static void setup() {
        CustomLink__c cLink1 = new CustomLink__c(
            CustomLinkName__c = 'Opportunity List',
            Domain__c='Global',
            URL__c = '/006/o',
            Active__c = true
        );
        insert cLink1;
        CustomLink__c cLink2 = new CustomLink__c(
            CustomLinkName__c = 'Opportunity List',
            Domain__c='Global',
            URL__c = 'https://www.google.com',
            Active__c = true
        );
        insert cLink2;
    }
    //-----------------------------
    // @author: Vinod Merwade
    // @date: 6 Nov 2017
    // @description:  Test Setup for the loading the custom links
    // @return: NA
    // @Company: Vertiba
    //-----------------------------
    public static testmethod void customLinkControllerTest() {
        List<CustomLink__c> cl = new List<CustomLink__c>();
        String domain='Global';
        cl= CustomLinkController.loadCustomLinks(domain);
        Account a=TestUtility.createTestAccount('TestAccount', true);
        SObject accRecord=CustomLinkController.fetchSObjectfields(a.id);
        system.assertNotEquals(a.id, null);
        system.assertEquals(2, cl.size());
    }
    
}