@IsTest(SeeAllData = true)
public with sharing class LightningLoginFormControllerTest {

 /*SFDC-3314 Commented as part of Winter 21 Repo Upgrade. 
  * Links to documentation: https://trailblazer.salesforce.com/issues_view?id=a1p4V0000003wXrQAI&title=lightningloginformcontrollertest-testloginwithinvalidcredentials-test-assertion-fails, https://trailblazers.salesforce.com/answers?id=9064S000000D89VQAS
  * @IsTest
 static void testLoginWithInvalidCredentials() {
  System.assertEquals('Argument 1 cannot be null', LightningLoginFormController.login('testUser', 'fakepwd', null));
 }*/

 @IsTest
 static void LightningLoginFormControllerInstantiation() {
  LightningLoginFormController controller = new LightningLoginFormController();
  System.assertNotEquals(controller, null, 'Class was not initialized');
 }

 @IsTest
 static void testIsUsernamePasswordEnabled() {
  //System.assertEquals(true, LightningLoginFormController.getIsUsernamePasswordEnabled(),'UserName and password is not enabled');
 }

 @IsTest
 static void testIsSelfRegistrationEnabled() {
  System.assertEquals(false, LightningLoginFormController.getIsSelfRegistrationEnabled(),'Self Registration is enabled');
 }

 @IsTest
 static void testGetSelfRegistrationURL() {
  System.assertEquals(null, LightningLoginFormController.getSelfRegistrationUrl(),'Self Registration has a valid URL');
 }

  @IsTest
 static void testgetForgotPasswordUrl() {
  System.assertEquals(null, LightningLoginFormController.getForgotPasswordUrl(),'Forgot Password has a valid URL');
 }
    
 @IsTest
 static void testAuthConfig() {
  Auth.AuthConfiguration authConfig = LightningLoginFormController.getAuthConfig();
  System.assertNotEquals(null, authConfig,'AuthConfiguration not initialized');
 }
    
    @isTest
    static void testLoginMethod() {
        LightningLoginFormController.login('Test@test.com','test@123','test.com');
        System.assertEquals(null, LightningLoginFormController.login('Test@test.com','test@123','test.com'), 'User is allowed to login to current page');
    }
    
    @isTest
    static void testsetExperienceId() {
        LightningLoginFormController.setExperienceId('testString');       
        System.assertNotEquals(null, LightningLoginFormController.setExperienceId('testString'),'value of the experience ID is null');
    }
    
    @isTest
    static void testsetExperienceId2() {
        LightningLoginFormController.setExperienceId(null); 
        System.assertNotEquals(null, LightningLoginFormController.setExperienceId('testString'),'value of the experience ID is null');
    }
}