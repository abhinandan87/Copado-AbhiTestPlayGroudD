//-----------------------------
// @author: Prachi Bhasin
// @date: 31 July 2017
// @param: NA
// @description: SFDC1-366 Test class for ApproveAdClaim class 
// @companyname : VERTIBA 
// @lastmodifiedBy : Prachi Bhasin for SFDC1-2233
// @lastmodifiedDate : Sprint 7
//-----------------------------

@isTest
private class TestApproveAdClaim {
    //-----------------------------
    // @author: Prachi Bhasin
    // @date: 3 July 2017
    // @param: NA
    // @description: Test method for approveAdClaim method
    // @return: NA
    //-----------------------------
    
    @isTest
    private static void testApproveAdClaim() {
        
        Account a = TestUtility.createTestAccount('Account testSetCaseAdditionalFieldsObject', false);
        a.DataGovernanceStatus__c = 'Approved';
        insert a;
           
        Contact c = new Contact();
        c.firstname = 'Test';
        c.lastname = 'testSetCaseAdditionalFieldsObject';
        c.AccountId = a.Id;
        c.EmailUnknown__c = true;
        c.Phone = '1234532';
        insert c;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', firstName='test',HRManager__c='manager',LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,AdClaimsApprover__c = true, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser123@ihs456789.com',ADID__c='test'+system.now().millisecond(),EmployeeNumber=String.valueOf(Math.round(Math.random()*10000)),EmployeeNumber__c=String.valueOf(Math.round(Math.random()*10000)));
        insert u;
        
        
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('New Business').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.StageName= '1-Sales Qualified';
        opp.RecordTypeId = devRecordTypeId;
        opp.CloseDate = System.today()+2;
        opp.Amount = 123;
        opp.GAM__c = u.id;
        opp.AccountId = a.id;
        insert opp;       
        
        System.assertEquals(opp.GAM__c, u.id,'Expected Global Account Manager not found in Opportunity.');
        
        
        
        OpportunityTeamMember otm = new OpportunityTeamMember(); 
        otm =[Select id, name, userId from OpportunityTeamMember where OpportunityId=:opp.id and TeamMemberRole = 'Account Owner' limit 1];       
        System.assertEquals(opp.GAM__c, otm.userId);
        
        AdClaim__c AdClaimobj = new AdClaim__c();
        
        
        AdClaimobj.AdditionalValidationAssignedTo__c   =   u.id    ;
        AdClaimobj.AdditionalValidationAssignedTo__c=u.id;
        AdClaimobj.AdditionalValidationRequired__c='Yes';
        AdClaimobj.AdDurationEndDate__c=System.Today();
        AdClaimobj.AdDurationStartDate__c=System.Today().addDays(-5);
        AdClaimobj.AnnualSubscriptionOrContract__c='Yes';
        AdClaimobj.ApprovalComments__c='Test Comments';
        AdClaimobj.ApprovedClaimLanguage__c='English';
        AdClaimobj.ApprovedDate__c=System.Today();
        AdClaimobj.ApprovedDisclaimerLanguage__c='English';
        AdClaimobj.ApprovingParty__c=u.id;
        AdClaimobj.ClaimExpirationDate__c=System.Today();
        AdClaimobj.ClaimsStatus__c='Submitted';
        AdClaimobj.ClaimTitle__c='Test Tittle';
        AdClaimobj.Comments__c='Test Comment';
        AdClaimobj.ContactName__c=c.id;
        AdClaimobj.CurrencyISOCode__c='U.S. Dollar';
        AdClaimobj.DataValidated__c=True;
        AdClaimobj.DataValidationCompletedBy__c=u.id;
        AdClaimobj.DoesSubstantiatingDataExist__c='Yes (please attach)';
        AdClaimobj.FeeForClaim__c=100;
        AdClaimobj.IHSAccountRepresentative__c=u.id;
        AdClaimobj.MediaType__c='Email';
        AdClaimobj.Opportunity__c=opp.id;
        AdClaimobj.OtherSourceFileUsed__c='Test';
        AdClaimobj.PhoneNumber__c='123456789';
       // AdClaimobj.PriorClaim__c=;
        AdClaimobj.ProposedClaimLanguage__c='English';
        AdClaimobj.ProposedDisclaimerLanguage__c='English';
        AdClaimobj.RejectionComments__c='Test Comment';
        AdClaimobj.RepresentedOrganization__c=a.id;
        AdClaimobj.RequestDate__c=System.Today();
        AdClaimobj.RequestingOrganization__c=a.id;
        AdClaimobj.SourceFileUsed__c='New';
        AdClaimobj.TypeOfClaim__c='Loyalty';
        AdClaimobj.UpdateOfAPriorClaim__c='No';    
        insert AdClaimobj;

        Set<Id> pIds = (new Map<Id, ProcessInstance>([SELECT Id,Status,TargetObjectId FROM ProcessInstance where Status='Pending' and TargetObjectId = :AdClaimobj.id])).keySet();
        Set<Id> pInstanceWorkitems;
        
        // Process Builder is Activated, send the Record in approval Process Manually in Test Class
        if(pIds.isEmpty())
        {
            // Create an approval request for the account
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(AdClaimobj.id);
            // Submit the record to specific process and skip the criteria evaluation
            req1.setProcessDefinitionNameOrId('AdClaimApprovalProcess');
            req1.setSkipEntryCriteria(true);
            // Submit the approval request for the account
            Approval.ProcessResult result = Approval.process(req1);
            
            // Verify the result
            System.assert(result.isSuccess());
        }
        
        System.RunAs(u){
            AdClaimobj.ClaimsStatus__c = 'Approved';
            update AdClaimobj;
            
            // To Verify the Record has been Approverd
            pInstanceWorkitems = (new Map<Id, ProcessInstanceWorkitem>([SELECT Id,ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId in :pIds])).keySet();
            System.assert(pInstanceWorkitems.isEmpty(),'Records pending for approval.');
        }
        
        pInstanceWorkitems = (new Map<Id, ProcessInstanceWorkitem>([SELECT Id,ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId in :pIds])).keySet();
        if(!pInstanceWorkitems.isEmpty())
        {
            ApproveAdClaim.approveAdClaimRecord(new List<id>{AdClaimobj.id});
            
            pInstanceWorkitems = (new Map<Id, ProcessInstanceWorkitem>([SELECT Id,ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId in :pIds])).keySet();
            // To Verify the Record has been Approverd
            System.assert(pInstanceWorkitems.isEmpty(),'Records pending for approval.');
        }
    }           
    
}