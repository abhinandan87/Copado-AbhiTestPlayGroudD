<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CustomerCareNewCommentEmailNotification</fullName>
        <description>Customer Care New Comment / Email Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>CorporateMailTemplates/NewCaseEmail</template>
    </alerts>
    <alerts>
        <fullName>ImplementationAdditionalEmailNotificationsRequestedbyDeliveryTeamSFDC_2414</fullName>
        <description>Implementation Additional Email Notifications Requested by Delivery Team (SFDC - 2414)</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ContactEmail1__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/OMDHCaseCloseNotification</template>
    </alerts>
    <alerts>
        <fullName>JoinerTransferLeaverNewEmailAlert</fullName>
        <ccEmails>outboundemailtracking@21z8xofo0ebdgfmc8mgzkx2lpp7fxva27co1i135p3tibn4vnm.m-diwweaw.cs20.apex.sandbox.salesforce.com</ccEmails>
        <description>SFDC1-6292 JTL new email alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>CorporateMailTemplates/NewCaseEmailTracked</template>
    </alerts>
    <alerts>
        <fullName>NewCaseCommentEmailNotification</fullName>
        <description>SFDC1-6294 New Case Comment Email Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>CorporateMailTemplates/CustomerCareCaseComment</template>
    </alerts>
    <alerts>
        <fullName>Notificationforasalespersonwhenemailinquiryisturnedintoacase</fullName>
        <description>SFDC1-6027: Notification for a sales person when email inquiry is turned into a case</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/TemplateforSalessupporttocreateEmailnotification</template>
    </alerts>
    <alerts>
        <fullName>NotifyCaseContactsOfClosedSalesforceHelpdeskCase</fullName>
        <description>SFDC1-9013: Notify Case Contacts of &quot;Closed&quot; Salesforce Helpdesk Case + SFDC1-10592 remove Web Email address from Recipients list</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CorporateMailTemplates/SalesforceHelpdeskCaseClose</template>
    </alerts>
    <alerts>
        <fullName>NotifyCaseContactsOfNewSalesforceHelpdeskCase</fullName>
        <description>SFDC1-9013: Notify Case Contacts of &quot;New&quot; Salesforce Helpdesk Case</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CorporateMailTemplates/SalesforceHelpdeskCaseCreation</template>
    </alerts>
    <alerts>
        <fullName>NotifyCaseContactsofClosedCustomerMasterDataCase</fullName>
        <description>SFDC-3962: Notify Case Contacts of &quot;Closed&quot; Customer Master Data Case</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/CustomerMasterDataCaseClosed</template>
    </alerts>
    <alerts>
        <fullName>NotifyCaseContactsofNewCustomerMasterDataCase</fullName>
        <description>SFDC-3962: Notify Case Contacts of &quot;New&quot; Customer Master Data Case</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/CustomerMasterDataCaseCreation</template>
    </alerts>
    <alerts>
        <fullName>NotifyCaseCreatorandContactsofNewChannelPartnerCase</fullName>
        <description>SFDC-2290: Notify Case Creator and Contacts of New Channel Partner Case</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/ChannelPartnerCaseCreation</template>
    </alerts>
    <alerts>
        <fullName>NotifyCreatorAndContactNewCustomerCareCase</fullName>
        <description>SFDC1-3643: Notify Case Creator and Contacts of New Customer Care Case</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CorporateMailTemplates/CustomerCareCaseCreations</template>
    </alerts>
    <alerts>
        <fullName>NotifyCreatorAndContactNewOnboardingCase</fullName>
        <description>SFDC1-3643: Notify Case Creator and Contacts of New Onboarding Case</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CorporateMailTemplates/OnboardingCaseCreation</template>
    </alerts>
    <alerts>
        <fullName>NotifyCreatorAndContactNewResponseManagementCase</fullName>
        <description>SFDC1-3643: Notify Case Creator and Contacts of New Response Management Case</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CorporateMailTemplates/ResponseManagementCaseCreation</template>
    </alerts>
    <alerts>
        <fullName>NotifyCreatorAndContactNewResponseManagementCaseforExternalUser</fullName>
        <description>SFDC-4579 Response Management Team Enhancements - Part 2 for Case Creation</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CorporateMailTemplates/ResponseManagementCaseCreationforExternalUser</template>
    </alerts>
    <alerts>
        <fullName>NotifyCreatorAndContactsClosedCustomerCareCase</fullName>
        <description>SFDC1-3643: Notify Case Creator and Contacts of &quot;Closed&quot; Customer Care Case + SFDC1-10592 remove Web Email address from Recipients list</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CorporateMailTemplates/CustomerCareCaseClose</template>
    </alerts>
    <alerts>
        <fullName>NotifyCreatorAndContactsClosedCustomerCareClosed</fullName>
        <description>SFDC-4998: Notify When Customer Experience Case Is Closed</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CorporateMailTemplates/CustomerExperienceCaseClose</template>
    </alerts>
    <alerts>
        <fullName>NotifyCreatorAndContactsClosedOnboardingCase</fullName>
        <description>SFDC1-3643: Notify Case Creator and Contacts of &quot;Closed&quot; Onboarding Case + SFDC1-10592 remove Web Email address from Recipients list</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CorporateMailTemplates/OnboardingCaseClose</template>
    </alerts>
    <alerts>
        <fullName>NotifyCreatorAndContactsClosedResponseManagementCase</fullName>
        <description>SFDC1-3643: Notify Case Creator and Contacts of &quot;Closed&quot; Response Management Case + SFDC1-10592 remove Web Email address from Recipients list</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ContactEmail1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CorporateMailTemplates/ResponseManagementCaseClose</template>
    </alerts>
    <alerts>
        <fullName>NotifyCreatorAndContactsClosedResponseManagementCaseInsertReopen</fullName>
        <description>Email Alert for Internal Reopen  SFDC-4579 Response Management Team Enhancements - Part 2</description>
        <protected>false</protected>
        <recipients>
            <field>InternalEmailforContact__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CorporateMailTemplates/ResponseManagementCasereopen</template>
    </alerts>
    <alerts>
        <fullName>NotifyCreatorAndContactsClosedResponseManagementCaseInsertReopenforExternalUser</fullName>
        <description>Email Alert for Internal Reopen for External User  SFDC-4579 Response Management Team Enhancements - Part 2</description>
        <protected>false</protected>
        <recipients>
            <field>ExternalEmailforContact__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CorporateMailTemplates/ResponseManagementCaseReopenforExternalUser</template>
    </alerts>
    <alerts>
        <fullName>NotifyCreatorAndContactsClosedResponseManagementCaseInternal</fullName>
        <description>Email Alert for Internal SFDC-4579 Response Management Team Enhancements - Part 2</description>
        <protected>false</protected>
        <recipients>
            <field>InternalEmailforContact__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>InternalEmailforWeb__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CorporateMailTemplates/ResponseManagementCaseClose</template>
    </alerts>
    <alerts>
        <fullName>NotifyCreatorAndContactsReopenedCustomerCareCase</fullName>
        <description>SFDC1-3643: Notify Case Creator and Contacts of &quot;Reopened&quot; Customer Care Case</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CorporateMailTemplates/CustomerCareCasereopen</template>
    </alerts>
    <alerts>
        <fullName>NotifyCreatorAndContactsReopenedOnboardingCase</fullName>
        <description>SFDC1-3643: Notify Case Creator and Contacts of &quot;Reopend&quot; Onboarding Case</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CorporateMailTemplates/OnboardingCasereopen</template>
    </alerts>
    <alerts>
        <fullName>NotifyCreatorAndContactsReopenedResponseManagementCase</fullName>
        <description>SFDC1-3643: Notify Case Creator and Contacts of &quot;Reopened&quot; Response Management Case</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CorporateMailTemplates/ResponseManagementCasereopen</template>
    </alerts>
    <alerts>
        <fullName>NotifyCreatorAndContactsReopenedResponseManagementCaseforExternalUser</fullName>
        <description>SFDC-4579 Response Management Team Enhancements - Part 2 for Case Reopen</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CorporateMailTemplates/ResponseManagementCaseReopenforExternalUser</template>
    </alerts>
    <alerts>
        <fullName>NotifyCustomerCareCaseCloseWithSurveyLink</fullName>
        <description>SFDC-234 Close Case With Survey Link</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CSCustomerCare/CloseCaseSurveyResponseTemplate</template>
    </alerts>
    <alerts>
        <fullName>NotifyDataLakeTeamToReviewClient</fullName>
        <ccEmails>DataLake-Sales@ihsmarkit.com</ccEmails>
        <description>Notify Data Lake Team to review Client for Data Lake Access</description>
        <protected>false</protected>
        <senderAddress>no-replysfdc@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CSCustomerCare/NotifyDataLakeTeamToReviewClientForDataLakeAccess</template>
    </alerts>
    <alerts>
        <fullName>NotifyFinanceFormsTeamForCaseCreation</fullName>
        <description>SFDC-1465 Notify Finance Forms team for case creation</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CorporateMailTemplates/FinanceFormsCaseCreation</template>
    </alerts>
    <alerts>
        <fullName>NotifyOwnerThatCaseIsReopened</fullName>
        <description>Notify Owner that Case is Reopened</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/CaseReopenedSendToCaseOwner</template>
    </alerts>
    <alerts>
        <fullName>NotifyQueueForNewCase</fullName>
        <description>NotifyQueueForNewCase</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/CaseNotificationForBRSBusiness</template>
    </alerts>
    <alerts>
        <fullName>NotifyWebEmailofNewSalesSupportClicktoolsCase</fullName>
        <description>SFDC-3294: Notify Web Email of &quot;New&quot; Sales Support Clicktools Case</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/ChannelPartnerCaseCreation</template>
    </alerts>
    <alerts>
        <fullName>NotifyWebEmailofNewSalesforceBusinessAnalystClicktoolsCase</fullName>
        <description>SFDC-4108: Notify Web Email of &quot;New&quot; Salesforce Business Analyst Clicktools Case</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/ClicktoolsRequestIntakeformCaseCreation</template>
    </alerts>
    <alerts>
        <fullName>NotifyWhenContractManagementCaseIsClosed</fullName>
        <description>NotifyWhenContractManagementCaseIsClosed</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/NotifyWhenContractManagementCaseIsClosed</template>
    </alerts>
    <alerts>
        <fullName>NotifyWhenCustomerExperienceCaseIsCreated</fullName>
        <description>Notify When Customer Experience Case Is Created</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CorporateMailTemplates/CustomerExperienceCaseCreations</template>
    </alerts>
    <alerts>
        <fullName>NotifyasalespersonwhencasestatusisClosedORResolved</fullName>
        <description>SFDC1-6028: Notify a sales person when case status is &quot;Closed&quot; OR &quot;Resolved&quot;</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/TemplateforSalessupportwhencasestatusissettoResolvedORClosed</template>
    </alerts>
    <alerts>
        <fullName>NotifywhenContractManagementCaseIsCreated</fullName>
        <description>NotifywhenContractManagementCaseIsCreated</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/NotifyWhenContractManagementCaseIsCreated</template>
    </alerts>
    <alerts>
        <fullName>NotifywhenContractSignatoriesCaseIsClosed</fullName>
        <description>NotifywhenContractSignatoriesCaseIsClosed</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/NotifyWhenContractSignatoriesCaseIsClosed</template>
    </alerts>
    <alerts>
        <fullName>NotifywhenContractSignatoriesCaseIsCreated</fullName>
        <description>NotifywhenContractSignatoriesCaseIsCreated</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/NotifyWhenContractSignatoriesCaseIsCreated</template>
    </alerts>
    <alerts>
        <fullName>OMDHAdditionalEmailNotificationsRequestedbyDeliveryTeamSFDC</fullName>
        <description>OMDH Additional Email Notifications Requested by Delivery Team (SFDC - 2414)</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>ContactEmail1__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/OMDHCaseCloseNotification</template>
    </alerts>
    <alerts>
        <fullName>OnboardingNewCommentEmailNotification</fullName>
        <description>Onboarding New Comment / Email Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>CorporateMailTemplates/NewCaseEmail</template>
    </alerts>
    <alerts>
        <fullName>ResponseManagementNewCommentEmailNotification</fullName>
        <description>Response Management New Comment / Email Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>CorporateMailTemplates/NewCaseEmail</template>
    </alerts>
    <alerts>
        <fullName>SFDC_3843_Notify_Case_Contact_of_Partner_Inquiries_Case</fullName>
        <description>SFDC-3843: Notify Case Contact of Partner Inquiries Case</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CorporateMailTemplates/Partner_Inquiries_Case_Creation</template>
    </alerts>
    <alerts>
        <fullName>SFDC_3843_Notify_Case_Contact_of_Partner_Inquiries_Closed_Case</fullName>
        <description>SFDC-3843: Notify Case Contact of Partner Inquiries Closed Case</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CorporateMailTemplates/Partner_Inquiries_Closed_Case</template>
    </alerts>
    <alerts>
        <fullName>SalesforceSuggestionCaseOPENEmailAlert</fullName>
        <description>SFDC1-9849 Auto-Email Response - Salesforce Suggestion Case OPEN</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/NewSalesforceSuggestionCaseOpen</template>
    </alerts>
    <fieldUpdates>
        <fullName>AssignCustomerCommunityCaseGoldfire</fullName>
        <description>For Customer Support Community.  Assigns cases from Goldfire users to the appropriate queue.</description>
        <field>OwnerId</field>
        <lookupValue>CSGoldfireSupport</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>AssignCustomerCommunityCaseGoldfire</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AssignCustomerCommunityCaseKingdom</fullName>
        <description>For Customer Support Community.  Assigns cases from Kingdom users to appropriate queue.</description>
        <field>OwnerId</field>
        <lookupValue>CSEnergyKingdom</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>AssignCustomerCommunityCaseKingdom</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AssignDeliveryHelpdeskCase</fullName>
        <description>SFDC1-6470 assign case to &quot;CS | Delivery&quot;</description>
        <field>OwnerId</field>
        <lookupValue>CSDelivery</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign Delivery Helpdesk Case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AssignOrderManagementHelpdeskCase</fullName>
        <description>SFDC1-6470 assign case to &quot;CS | Order Management&quot; queue</description>
        <field>OwnerId</field>
        <lookupValue>CSOrderManagement</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign Order Management Helpdesk Case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AssignRetailCase</fullName>
        <description>SFDC1-7096 assign case to &quot;CS | Retail&quot;</description>
        <field>OwnerId</field>
        <lookupValue>CSRetail</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign Retail Case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AssignmentGlobalSalesSupportAPAC</fullName>
        <description>SFDC-1989 Assigns the case to the Global Sales Support - APAC queue.</description>
        <field>OwnerId</field>
        <lookupValue>SalesSalesSupportAPAC</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assignment Global Sales Support APAC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AssignmentGlobalSalesSupportAmericas</fullName>
        <description>SFDC-1989 Assigns the case to the Global Sales Support - Americas queue.</description>
        <field>OwnerId</field>
        <lookupValue>SalesSalesSupportAmericas</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assignment Global Sales Support Americas</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AssignmentGlobalSalesSupportEMEA</fullName>
        <description>SFDC-1989 Assigns the case to the Global Sales Support - EMEA queue.</description>
        <field>OwnerId</field>
        <lookupValue>SalesSalesSupportEMEA</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assignment Global Sales Support EMEA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CaseOwnerToMergedQueue</fullName>
        <description>SFDC-2961: Assign Case to Merged Queue</description>
        <field>OwnerId</field>
        <lookupValue>MergedQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>CaseOwnerToMergedQueue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CaseOwnerToQueue</fullName>
        <description>SFDC1-5583 Change the Case owner to FM | Customer Care Queue when created from Lead
SFDC-3461: updating queue - IHS Markit Customer Care</description>
        <field>OwnerId</field>
        <lookupValue>IHSMarkitCustomerCare</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Case Owner To Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CaseOwnerUpdateToSalesforceHelpdesk</fullName>
        <description>SFDC1-8267
Assigns the case owner to Salesforce Helpdesk Queue.</description>
        <field>OwnerId</field>
        <lookupValue>FMSalesforceHelpdesk</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Case Owner update to Salesforce Helpdesk</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DeleteCaseOwnerAssignment</fullName>
        <description>SFDC1-1039: Change case owner to delete queue when Status is changed to delete</description>
        <field>OwnerId</field>
        <lookupValue>DeleteQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Delete Case Owner Assignment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DoNotSurveyReasonUpdate</fullName>
        <description>SFDC1-5513: Do Not Survey Reason to be changed to Ticket not actioned for cases that are not updated in long time</description>
        <field>DoNotSurveyReason__c</field>
        <formula>&quot;Ticket not actioned&quot;</formula>
        <name>Do Not Survey Reason Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DoNotSurveyToFalse</fullName>
        <description>SFDC1-5513: Set do not survey field to false.</description>
        <field>DoNotSurvey__c</field>
        <literalValue>0</literalValue>
        <name>Do Not Survey To False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Do_Not_Survey_Reason_Update</fullName>
        <description>Test</description>
        <field>DoNotSurveyReason__c</field>
        <formula>&quot;Ticket not actioned&quot;</formula>
        <name>Do Not Survey Reason Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Do_Not_Survey_To_False</fullName>
        <field>DoNotSurvey__c</field>
        <literalValue>0</literalValue>
        <name>Do Not Survey To False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>DuplicateCaseOwnerAssignment</fullName>
        <description>SFDC1-1930: When case status is changed to duplicate change the owner to duplicate queue</description>
        <field>OwnerId</field>
        <lookupValue>DuplicateQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Duplicate Case Owner Assignment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OMDHStatusUpdatetoInProgress</fullName>
        <description>SFDC-4229: Auto change status to &quot;In Progress&quot; once case is assigned</description>
        <field>OMDStatus__c</field>
        <literalValue>In Progress</literalValue>
        <name>OMDHStatusUpdatetoInProgress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PopulateOriginalQueueName</fullName>
        <description>SFDC-1469 Email-to-Case queue name used in the initial case creation</description>
        <field>OriginQueueName__c</field>
        <formula>Owner:Queue.QueueName</formula>
        <name>PopulateOriginalQueueName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RunCustomCaseAssignmentLogic</fullName>
        <description>SFDC1-7574 When the standard case assignment rule assigns case to &apos;To Be Assigned&apos; queue, this workflow checks the custom checkbox field on case and executes the custom code.</description>
        <field>RunCaseAssignmentRule__c</field>
        <literalValue>1</literalValue>
        <name>RunCustomCaseAssignmentLogic</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SFDCHelpdeskCaseAssignment</fullName>
        <description>SFDC1-7866.
Assign SFDC Helpdesk cases created from the quick actions to the associated queue.</description>
        <field>OwnerId</field>
        <lookupValue>FMSalesforceHelpdesk</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>SFDC Helpdesk Case Assignment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SalesforceSuggestionQueueUpdate</fullName>
        <description>SFDC1-8978; Case owner of Salesforce Suggestion record type changes</description>
        <field>OwnerId</field>
        <lookupValue>SalesforceSuggestion</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Salesforce Suggestion Queue Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetCasePrioritytoHigh</fullName>
        <description>SFDC1-1378: Update case priority to high Outage/Password/Login related issues</description>
        <field>Priority</field>
        <literalValue>High</literalValue>
        <name>Set Case Priority to High</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetOMDStatusToNew</fullName>
        <description>SFDC1-9432: Set OMD status to New when OM Help Desk Case record is created</description>
        <field>OMDStatus__c</field>
        <literalValue>New</literalValue>
        <name>SetOMDStatusToNew</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetStatusToAutoClosed</fullName>
        <description>SFDC1-5513 Set Status to Auto-Closed – No Action Taken</description>
        <field>Status</field>
        <literalValue>Auto-Closed – No Action Taken</literalValue>
        <name>Set Status To Auto Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetStatusToInProgress</fullName>
        <description>SFDC1-5339, When the case is in status NEW and the owner is changed from a queue to an individual, the case status changes to IN PROGRESS.</description>
        <field>Status</field>
        <literalValue>In Progress</literalValue>
        <name>SetStatusToInProgress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Status_To_Auto_Closed</fullName>
        <field>Status</field>
        <literalValue>Auto-Closed – No Action Taken</literalValue>
        <name>Set Status To Auto Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateCaseOwner</fullName>
        <description>SFDC1-965 &amp; SFDC1-683 update Case Owner to &quot;Account Governance&quot; queue</description>
        <field>OwnerId</field>
        <lookupValue>DataGovernance</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Update Case Owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateCaseRecordType</fullName>
        <description>SFDC1-6470 update Case record type to &quot;Order Management/Delivery Help Desk&quot;</description>
        <field>RecordTypeId</field>
        <lookupValue>OrderManagementDeliveryHelpDesk</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Case Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateCaseRejectionPastDueCheck</fullName>
        <description>SFDC-4228: Auto Renewal Opportunity should be Reopened after 10 days</description>
        <field>CaseRejectionPastDue__c</field>
        <literalValue>1</literalValue>
        <name>Update Case Rejection Past Due Check</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateCaseStatustoInProgress</fullName>
        <description>SFDC1-5258 This workflow will automatically update the status of a Data Governance&apos;s New Account case from &quot;New&quot; to &quot;In Progress&quot; once the &quot;Account Created/Associated&quot; field is populated. 
SFDC1-7673 remove criteria for Case record type as it has changed</description>
        <field>Status</field>
        <literalValue>In Progress</literalValue>
        <name>Update Case Status to In Progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateCurrentQueue</fullName>
        <description>SFDC1-1389, Field will be updated with the Current Queue name. SFDC1-10055: Dont poopulate to be assigned queue name in Current queue.</description>
        <field>CurrentQueue__c</field>
        <formula>IF(
	LEFT(OwnerId,3)=&apos;00G&apos;,
	IF(CONTAINS(OwnerId , $Label.ToBeAssignedQueueId),
		CurrentQueue__c,
		Owner:Queue.QueueName) , 
	&apos;&apos;)</formula>
        <name>Update Current Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateExternalforContact</fullName>
        <description>SFDC-4579 Response Management Team Enhancements - Part 2</description>
        <field>ExternalEmailforContact__c</field>
        <formula>If(
AND(
NOT(CONTAINS( Contact.Email, &apos;@ihsmarkit.com&apos;)),
NOT(CONTAINS( Contact.Email, &apos;@ihs.com&apos;)),
NOT(CONTAINS( Contact.Email, &apos;@polk.com&apos;)),
NOT(CONTAINS( Contact.Email, &apos;@ipreo.com&apos;)),
NOT(CONTAINS( Contact.Email, &apos;@mserv.com&apos;)),
NOT(CONTAINS( Contact.Email, &apos;@markit.com&apos;)),
NOT(CONTAINS( Contact.Email, &apos;@automotivemastermind.com&apos;))),Contact.Email,&apos;&apos;)</formula>
        <name>Update External for Contact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateExternalforWeb</fullName>
        <description>SFDC-4579 Response Management Team Enhancements - Part 2</description>
        <field>ExternalEmailforWeb__c</field>
        <formula>If(
AND(
NOT(CONTAINS( SuppliedEmail, &apos;@ihsmarkit.com&apos;)),
NOT(CONTAINS( SuppliedEmail, &apos;@ihs.com&apos;)),
NOT(CONTAINS( SuppliedEmail, &apos;@polk.com&apos;)),
NOT(CONTAINS( SuppliedEmail, &apos;@ipreo.com&apos;)),
NOT(CONTAINS( SuppliedEmail, &apos;@mserv.com&apos;)),
NOT(CONTAINS( SuppliedEmail, &apos;@markit.com&apos;)),
NOT(CONTAINS( SuppliedEmail, &apos;@automotivemastermind.com&apos;))),SuppliedEmail,&apos;&apos;)</formula>
        <name>Update External for Web</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateInternalforContact</fullName>
        <description>SFDC-4579 Response Management Team Enhancements - Part 2</description>
        <field>InternalEmailforContact__c</field>
        <formula>If( 
OR( 
CONTAINS( Contact.Email, &apos;@ihsmarkit.com&apos;),
CONTAINS( Contact.Email, &apos;@ihs.com&apos;),
CONTAINS( Contact.Email, &apos;@polk.com&apos;),
CONTAINS( Contact.Email, &apos;@ipreo.com&apos;),
CONTAINS( Contact.Email, &apos;@mserv.com&apos;), 
CONTAINS( Contact.Email, &apos;@markit.com&apos;),
CONTAINS( Contact.Email, &apos;@automotivemastermind.com&apos;)),Contact.Email,&apos;&apos;)</formula>
        <name>Update Internal for Contact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateInternalforWeb</fullName>
        <description>SFDC-4579 Response Management Team Enhancements - Part 2</description>
        <field>InternalEmailforWeb__c</field>
        <formula>If(
AND(
CONTAINS( SuppliedEmail, &apos;@ihsmarkit.com&apos;),
CONTAINS( SuppliedEmail, &apos;@ihs.com&apos;),
CONTAINS( SuppliedEmail, &apos;@polk.com&apos;),
CONTAINS( SuppliedEmail, &apos;@ipreo.com&apos;),
CONTAINS( SuppliedEmail, &apos;@mserv.com&apos;),
CONTAINS( SuppliedEmail, &apos;@markit.com&apos;),
CONTAINS( SuppliedEmail, &apos;@automotivemastermind.com&apos;)),SuppliedEmail,&apos;&apos;)</formula>
        <name>Update Internal for Web</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdatePINEmailCaseOwner</fullName>
        <description>SFDC1-4145: Update the case owner</description>
        <field>OwnerId</field>
        <lookupValue>FMCTIPIN</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Update PIN Email Case Owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdatePreviousOwner</fullName>
        <description>SFDC1-1389, Field will be updated with the Previous Queue name. SFDC1-10055: Dont poopulate to be assigned queue name in Current queue.</description>
        <field>PreviousQueue__c</field>
        <formula>IF(
	NOT(ISBLANK(PRIORVALUE(CurrentQueue__c))),
	IF(CONTAINS(PRIORVALUE(CurrentQueue__c) , &apos;To Be Assigned&apos;),
		PreviousQueue__c,
		PRIORVALUE(CurrentQueue__c)), 
	PreviousQueue__c)</formula>
        <name>Update Previous Owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateRecordTypeToContractManagement</fullName>
        <description>SFDC1-10602: Update Case record type to Contract Management</description>
        <field>RecordTypeId</field>
        <lookupValue>ContractManagement</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>UpdateRecordTypeToContractManagement</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateRecordTypeToSalesOps</fullName>
        <description>SFDC1-10602: Update Case record type to Sales Ops</description>
        <field>RecordTypeId</field>
        <lookupValue>SalesOperations</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>UpdateRecordTypeToSalesOps</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateRecordTypeToSalesforceHelp</fullName>
        <description>SFDC1-5799, update case record type to Salesforce Help whenever owner sets to FM | Salesforce Helpdesk</description>
        <field>RecordTypeId</field>
        <lookupValue>SalesforceHelpdesk</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>UpdateRecordTypeToSalesforceHelp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateRecordTypeToSalesforceHelpdesk</fullName>
        <description>SFDC1-10602: Update Case record type to Salesforce Helpdesk</description>
        <field>RecordTypeId</field>
        <lookupValue>SalesforceHelpdesk</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>UpdateRecordTypeToSalesforceHelpdesk</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateStatusToNew</fullName>
        <description>SFDC1-5799, when case owner sets to FM | Salesforce Helpdesk, set the status to New.</description>
        <field>Status</field>
        <literalValue>New</literalValue>
        <name>UpdateStatusToNew</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateWebChatCaseDescription</fullName>
        <description>SFDC1-3537 Update Web Chat Case Description when contact is known to &quot;Web Chat – &lt;FirstName&gt; &lt;LastName&gt; at &lt;Account Name&gt;&quot;</description>
        <field>Description</field>
        <formula>&quot;Web Chat - &quot; + Contact.FirstName + &quot; &quot; + Contact.LastName + &quot; at &quot; + Account.Name</formula>
        <name>Update Web Chat Case Description</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateWebChatCaseSubject</fullName>
        <description>SFDC1-3537 Update Web Chat Case Subject when contact is known to &quot;Web Chat – &lt;FirstName&gt; &lt;LastName&gt; at &lt;Account Name&gt;&quot;</description>
        <field>Subject</field>
        <formula>&quot;Web Chat - &quot; + Contact.FirstName + &quot; &quot; + Contact.LastName + &quot; at &quot; + Account.Name</formula>
        <name>Update Web Chat Case Subject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdatingCaseOwner</fullName>
        <description>SFDC1-3608:This is a field update to ensure that any case that has been raised from &apos;prmtmapp@mtmprodappg3.mserv.local&apos; and has a subject of &apos;Errored Dealer&apos;s trades for PIMCO due to trading permissions for the day&apos; is auto-updated</description>
        <field>OwnerId</field>
        <lookupValue>FMMWCPSOnboarding</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Updating CaseOwner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdatingCaseRecordType</fullName>
        <description>SFDC1-3608: This is a field update to ensure that any case that has been raised from &apos;prmtmapp@mtmprodappg3.mserv.local&apos; and has a subject of &apos;Errored Dealer&apos;s trades for PIMCO due to trading permissions for the day&apos; is auto-updated</description>
        <field>RecordTypeId</field>
        <lookupValue>Onboarding</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Updating Case RecordType</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>AccountGovernanceCase</fullName>
        <actions>
            <name>UpdateCaseOwner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Customer Master Data</value>
        </criteriaItems>
        <description>SFDC1-965 &amp; SFDC1-683 assign Account Governance cases to Account Governance queue
SFDC1-7673 changed Case record type for Data Governance cases</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AssignCaseOwnerToDeleteQueue</fullName>
        <actions>
            <name>DeleteCaseOwnerAssignment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Delete</value>
        </criteriaItems>
        <description>SFDC1:1039 - Assign case to delete queue when status is changed to Delete</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AssignCaseOwnerToDuplicateQueue</fullName>
        <actions>
            <name>DuplicateCaseOwnerAssignment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Duplicate</value>
        </criteriaItems>
        <description>SFDC1:1039 - Assign case to duplicate queue when status is changed to Duplicate</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AssignCustomerCommunityCaseGoldfire</fullName>
        <actions>
            <name>AssignCustomerCommunityCaseGoldfire</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>For Customer Support Community.  Assigns new cases from Goldfire users to the appropriate queue.</description>
        <formula>CONTAINS($Profile.Name,&quot;Goldfire&quot;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>AssignCustomerCommunityCaseKingdom</fullName>
        <actions>
            <name>AssignCustomerCommunityCaseKingdom</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>For Customer Support Community.  Assigns new cases from Kingdom users to the Kingdom queue.</description>
        <formula>CONTAINS($Profile.Name,&quot;Kingdom&quot;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>AssignDeliveryHelpdeskCase</fullName>
        <actions>
            <name>AssignDeliveryHelpdeskCase</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC1-6470 assign Order Management/Delivery Help Desk case to &quot;CS | Delivery&quot; queue when Team Select = &quot;Delivery&quot;</description>
        <formula>AND( LEFT(OwnerId,3) &lt;&gt; &apos;005&apos;, RecordType.Name = &apos;Order Management/Delivery Help Desk&apos;, ISPICKVAL(TeamSelect__c, &quot;Delivery&quot;), NOT(CONTAINS(Owner:Queue.QueueName, &quot;Global Delivery Help Desk&quot;)), NOT(CONTAINS(Owner:Queue.QueueName, &quot;Global Delivery EMEA ADandM&quot;)),NOT(CONTAINS(Owner:Queue.QueueName, &quot;Delivery Technical&quot;)), NOT(Owner:Queue.QueueName == &quot;Delivery|Experts Portal&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AssignGlobalCustomerCareCase</fullName>
        <actions>
            <name>CaseOwnerToQueue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Quick Action</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Customer Care</value>
        </criteriaItems>
        <description>SFDC-218 assign case created via global quick action for FM | Customer Care</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>AssignOrderManagementHelpdeskCase</fullName>
        <actions>
            <name>AssignOrderManagementHelpdeskCase</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Order Management/Delivery Help Desk</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.TeamSelect__c</field>
            <operation>equals</operation>
            <value>Order Management</value>
        </criteriaItems>
        <description>SFDC1-6470 assign Order Management/Delivery Help Desk case to &quot;CS | Order Management&quot; queue when Team Select = &quot;Order Management&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AssignRetailCase</fullName>
        <actions>
            <name>AssignRetailCase</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Order Management/Delivery Help Desk</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.TeamSelect__c</field>
            <operation>equals</operation>
            <value>Retail</value>
        </criteriaItems>
        <description>SFDC1-7096 assign Order Management/Delivery Help Desk case to &quot;CS | Retail&quot; queue when Team Select = &quot;Retail&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Case Rejection Past Due Check</fullName>
        <active>true</active>
        <description>SFDC-4228: Auto Renewal Opportunity should be Reopened after 10 days</description>
        <formula>AND ( Opportunity__r.AutoRenewal__c  = True,  Opportunity__r.DoesThisAutoRenewalHaveChanges__c = False ,  RecordType.Name = &apos;Order Management&apos; ,   ISPICKVAL(Status , &apos;Rejected&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>UpdateCaseRejectionPastDueCheck</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>10</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CaseFromLead</fullName>
        <actions>
            <name>CaseOwnerToQueue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC1-5583 Owner of the Case should assigned to  FM | Customer Care Case queue when the case is created from the Lead. SFDC1-5970 Chanigng isNull to IsBlank as per the standards.
SFDC1-7609 Change rule to apply this logic only for Customer Care cases</description>
        <formula>NOT(ISBLANK( LeadReference__c)) &amp;&amp; RecordType.DeveloperName = &quot;Customer Care&quot;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ClickToolsRequestIntakeFormCaseCreation</fullName>
        <actions>
            <name>NotifyWebEmailofNewSalesforceBusinessAnalystClicktoolsCase</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>Request Intake Form</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Salesforce Business Analysis</value>
        </criteriaItems>
        <description>SFDC-4108: ClickTools Request Intake Form case creation</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ClicktoolsCaseNotify</fullName>
        <actions>
            <name>NotifyWebEmailofNewSalesSupportClicktoolsCase</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND (4 OR 5 OR 6)</booleanFilter>
        <criteriaItems>
            <field>Case.CreatedById</field>
            <operation>equals</operation>
            <value>ClickTools Interface</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Sales Support</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Channel partner Operations - E&amp;PD</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Channel partner Operations - M&amp;T</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Channel partner Operations - Energy</value>
        </criteriaItems>
        <description>SFDC-3294: Case creation email notification to requestor when a new case gets created in SF from Clicktools</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CustomerCareCaseClosedWithSurveyLink</fullName>
        <actions>
            <name>NotifyCustomerCareCaseCloseWithSurveyLink</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>SFDC-234 Close Case with Survey Link Email
SFDC-744 Bug fix to include a check on &quot;Do not Notify&quot;
SFDC-3424 Hotfix to move criteria into formula</description>
        <formula>(     ISNEW()      ||     (         ISCHANGED(IsClosed)         &amp;&amp; IsClosed         &amp;&amp; PRIORVALUE(IsClosed)=false     ) ) &amp;&amp; CONTAINS(TEXT(Status), &apos;Closed&apos;) &amp;&amp; NOT(ISPICKVAL(Status,&apos;Auto-Closed – No Action Taken&apos;)) &amp;&amp; RecordType.Name =&apos;Customer Care&apos;  &amp;&amp; Contact.Email!=&apos;customercare@ihsmarkit.com&apos;  &amp;&amp; Contact.Email!=&apos;support@markit.com&apos;  &amp;&amp; Contact.Email!=&apos;support@ihsmarkit.com&apos;  &amp;&amp; Contact.Email!=&apos;customercare@ihs.com&apos;  &amp;&amp; DoNotNotify__c=false  &amp;&amp; DoNotSurvey__c=false</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CustomerCaseColdCase</fullName>
        <active>true</active>
        <description>SFDC1-5513:When a case is assigned to queue and was not modified for more than a month then this workflow should trigger.</description>
        <formula>AND(  	RecordType.Name == &apos;Customer Care&apos;, 	 	LEFT(OwnerId,3) = &apos;00G&apos; ,NOT(IsClosed), 	 	NOT(ISPICKVAL(AdditionalFields__r.LongTermProjectType__c ,&apos;Yes&apos;)), 	 	NOT(OR(ISPICKVAL( Subtype__c ,&apos;Bug Report&apos;),ISPICKVAL( Subtype__c ,&apos;Product Enhancement&apos;))), 	NOT(Owner:Queue.DeveloperName==&apos;FMMSERV&apos;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>DoNotSurveyReasonUpdate</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>DoNotSurveyToFalse</name>
                <type>FieldUpdate</type>
            </actions>
            <actions>
                <name>SetStatusToAutoClosed</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.LastModifiedDate</offsetFromField>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>MarkitWire CPS Onboarding Field Update</fullName>
        <actions>
            <name>UpdatingCaseOwner</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdatingCaseRecordType</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>equals</operation>
            <value>prmtmapp@mtmprodappg3.mserv.local</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>equals</operation>
            <value>Errored Dealer&apos;s trades for PIMCO due to trading permissions for the day</value>
        </criteriaItems>
        <description>SFDC1-3608:This is a field update to ensure that any case that has been raised from &apos;prmtmapp@mtmprodappg3.mserv.local&apos; and has a subject of &apos;Errored Dealer&apos;s trades for PIMCO due to trading permissions for the day&apos; is auto-updated.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Move PIN Related Cases to Queue</fullName>
        <actions>
            <name>UpdatePINEmailCaseOwner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>equals</operation>
            <value>noreply@cti.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>equals</operation>
            <value>Electronic Signature PIN</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>equals</operation>
            <value>PIN de firma electronica</value>
        </criteriaItems>
        <description>SFDC1-4145: Change the PIN emails case owner</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>New Case Comment Email</fullName>
        <actions>
            <name>NewCaseCommentEmailNotification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>SFDC1-6294
Sends an email to the Case Owner when a new case comment is created.</description>
        <formula>ISCHANGED( LatestCaseCommentDate__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>NotifyCustomerWhenSalesforceSuggestionCaseOPEN</fullName>
        <actions>
            <name>SalesforceSuggestionCaseOPENEmailAlert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Salesforce - Suggestion</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <description>SFDC1-9849 Auto-Email Response - Salesforce Suggestion Case OPEN</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>NotifyFinanceFormsTeamForCaseCreation</fullName>
        <actions>
            <name>NotifyFinanceFormsTeamForCaseCreation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Response Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Sales | Finance Forms</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@markit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>customercare@ihs.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>customercare@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DoNotNotify__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>SFDC-1465 Notify Finance Forms team for case creation</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>NotifyQueueMembers</fullName>
        <actions>
            <name>NotifyQueueForNewCase</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3</booleanFilter>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>FM | MarkitHub</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>FM | Markit Research Manager</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.AssignToQueue__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>SFDC-1280 Notify queue members when case assigned to their queue</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>NotifyWhenChannelPartnerCaseStatusIsCreated</fullName>
        <actions>
            <name>NotifyCaseCreatorandContactsofNewChannelPartnerCase</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>SFDC-2290: Notify contact and creator when a Channel Partner case is created</description>
        <formula>AND(  	 	Owner:Queue.DeveloperName = &quot;CPChannelPartnerOperations&quot;,  	RecordType.DeveloperName = &apos;SalesSupport&apos;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>NotifyWhenContractManagementCaseIsCreated</fullName>
        <actions>
            <name>NotifywhenContractManagementCaseIsCreated</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Contract Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@markit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>customercare@ihs.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>customercare@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DoNotNotify__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>SFDC-464 - Must have - Auto response notification email for Contract Management and Sales Operations</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>NotifyWhenCustomerCareCaseStatusIsClosed</fullName>
        <actions>
            <name>NotifyCreatorAndContactsClosedCustomerCareCase</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>SFDC1-3643: Notify  contact and creator when Customer Care case status is &quot;Closed&quot;
SFDC1-9588: updated rule criteria
SFDC-236: Close Case without Survey Link Email
SFDC-744: SFDC-744 Bug fix to include a check on &quot;Do not Survey&quot;</description>
        <formula>(     ISNEW()      ||     (         ISCHANGED(IsClosed)         &amp;&amp; IsClosed         &amp;&amp; PRIORVALUE(IsClosed)=false     ) ) &amp;&amp; CONTAINS(TEXT(Status), &apos;Closed&apos;) &amp;&amp; NOT(ISPICKVAL(Status,&apos;Auto-Closed – No Action Taken&apos;)) &amp;&amp; RecordType.Name =&apos;Customer Care&apos;  &amp;&amp; Contact.Email!=&apos;customercare@ihsmarkit.com&apos;  &amp;&amp; Contact.Email!=&apos;support@markit.com&apos;  &amp;&amp; Contact.Email!=&apos;support@ihsmarkit.com&apos;  &amp;&amp; Contact.Email!=&apos;customercare@ihs.com&apos;  &amp;&amp; DoNotNotify__c=false  &amp;&amp; DoNotSurvey__c=true &amp;&amp; OriginQueueName__c!=&apos;PD | Partner-Inquiries&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>NotifyWhenCustomerCareCaseStatusIsCreated</fullName>
        <actions>
            <name>NotifyCreatorAndContactNewCustomerCareCase</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Customer Care</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@markit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>customercare@ihs.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>customercare@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DoNotNotify__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>notEqual</operation>
            <value>PD | Partner-Inquiries</value>
        </criteriaItems>
        <description>SFDC1-3643: Notify contact and creator when Customer Care case is created</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>NotifyWhenCustomerCareCaseStatusIsReopened</fullName>
        <actions>
            <name>NotifyCreatorAndContactsReopenedCustomerCareCase</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Re-opened</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Customer Care</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@markit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>customercare@ihs.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>customercare@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DoNotNotify__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>SFDC1-3643: Notify contact and creator when Customer Care case status is &quot;Re-opened&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>NotifyWhenCustomerExperienceCaseIsClosed</fullName>
        <actions>
            <name>NotifyCreatorAndContactsClosedCustomerCareClosed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>SFDC-4998- Notify When Customer Experience Case is closed</description>
        <formula>( ISNEW() || ( ISCHANGED(IsClosed) &amp;&amp; IsClosed &amp;&amp; PRIORVALUE(IsClosed)=false ) ) &amp;&amp;  CONTAINS(TEXT(Status), &apos;Closed&apos;) &amp;&amp;  RecordType.Name =&apos;Customer Experience&apos; &amp;&amp; Contact.Email!=&apos;customerexperience@ihsmarkit.com&apos; &amp;&amp; DoNotNotify__c=false</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>NotifyWhenCustomerExperienceCaseIsCreated</fullName>
        <actions>
            <name>NotifyWhenCustomerExperienceCaseIsCreated</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Customer Experience</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>SFDC-4998- Notify When Customer Experience Case is created</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>NotifyWhenCustomerMasterDataCaseIsCreated</fullName>
        <actions>
            <name>NotifyCaseContactsofNewCustomerMasterDataCase</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Customer Master Data</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@markit.com,support@ihsmarkit.com,customercare@ihs.com,customercare@ihsmarkit.com</value>
        </criteriaItems>
        <description>SFDC-3962: Notify contact and creator when Customer Master Data case is created</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>NotifyWhenCustomerMasterDataCaseStatusIsClosed</fullName>
        <actions>
            <name>NotifyCaseContactsofClosedCustomerMasterDataCase</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed - Canceled,Closed - Resolved by Customer,Closed - Resolved by IHS Markit</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Customer Master Data</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@markit.com,support@ihsmarkit.com,customercare@ihs.com,customercare@ihsmarkit.com</value>
        </criteriaItems>
        <description>SFDC-3962: Notify contact and creator when Customer Master Data case status is &quot;Closed&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>NotifyWhenImplementaionCaseStatusIsClosed</fullName>
        <actions>
            <name>ImplementationAdditionalEmailNotificationsRequestedbyDeliveryTeamSFDC_2414</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>SFDC-2414 - Additional Email Notifications Requested by Delivery Team</description>
        <formula>AND( CONTAINS(TEXT(Status), &apos;Close&apos;), RecordType.Name = &apos;Implementation&apos;, CONTAINS(ContactEmail__c, &apos;ihsmarkit.com&apos;), LoadingGroupOnboarding__r.LoadingGroupCategory__c = &apos;IHS&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>NotifyWhenOMDHCaseStatusIsClosed</fullName>
        <actions>
            <name>OMDHAdditionalEmailNotificationsRequestedbyDeliveryTeamSFDC</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4</booleanFilter>
        <criteriaItems>
            <field>Case.TeamSelect__c</field>
            <operation>equals</operation>
            <value>Delivery</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed - Canceled,Closed - Resolved,Closed - Referral,Closed - Resolved by 3rd Party,Closed - Resolved by Customer,Closed - Resolved by IHS Markit,Resolved/Completed,Resolved/No Response,Rejected</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Order Management/Delivery Help Desk</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail__c</field>
            <operation>contains</operation>
            <value>@ihsmarkit.com</value>
        </criteriaItems>
        <description>SFDC - 2414 - Additional Email Notifications Requested by Delivery Team</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>NotifyWhenOnboardingCaseIsCreated</fullName>
        <actions>
            <name>NotifyCreatorAndContactNewOnboardingCase</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Onboarding</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@markit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>customercare@ihs.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>customercare@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DoNotNotify__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>SFDC1-3643: Notify contact and creator when Onboarding case is created</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>NotifyWhenOnboardingCaseStatusIsClosed</fullName>
        <actions>
            <name>NotifyCreatorAndContactsClosedOnboardingCase</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Auto-Closed – No Action Taken</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>contains</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Onboarding</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@markit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>customercare@ihs.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>customercare@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DoNotNotify__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>SFDC1-3643: Notify contact and creator when Onboarding case status is &quot;Closed&quot;
SFDC1-9588: updated rule criteria to avoid delete and duplicate status</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>NotifyWhenOnboardingCaseStatusIsReopened</fullName>
        <actions>
            <name>NotifyCreatorAndContactsReopenedOnboardingCase</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Re-opened</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Onboarding</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@markit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>customercare@ihs.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>customercare@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DoNotNotify__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>SFDC1-3643: Notify  contact and creator when Onboarding case status is &quot;Re-opened&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>NotifyWhenPartnerInquiriesCaseStatusIsClosed</fullName>
        <actions>
            <name>SFDC_3843_Notify_Case_Contact_of_Partner_Inquiries_Closed_Case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>SFDC-3834 :Separate case flow for Partner Inquiries</description>
        <formula>(     ISNEW()      ||     (         ISCHANGED(IsClosed)         &amp;&amp; IsClosed         &amp;&amp; PRIORVALUE(IsClosed)=false     ) ) &amp;&amp; CONTAINS(TEXT(Status), &apos;Closed&apos;) &amp;&amp; NOT(ISPICKVAL(Status,&apos;Auto-Closed – No Action Taken&apos;)) &amp;&amp; RecordType.Name =&apos;Customer Care&apos;  &amp;&amp; Contact.Email!=&apos;customercare@ihsmarkit.com&apos;  &amp;&amp; Contact.Email!=&apos;support@markit.com&apos;  &amp;&amp; Contact.Email!=&apos;support@ihsmarkit.com&apos;  &amp;&amp; Contact.Email!=&apos;customercare@ihs.com&apos;  &amp;&amp; DoNotNotify__c=false  &amp;&amp; DoNotSurvey__c=true &amp;&amp;  OriginQueueName__c=&apos;PD | Partner-Inquiries&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>NotifyWhenPartnerInquiriesCaseStatusIsCreated</fullName>
        <actions>
            <name>SFDC_3843_Notify_Case_Contact_of_Partner_Inquiries_Case</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Customer Care</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>PD | Partner-Inquiries</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@markit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail__c</field>
            <operation>notEqual</operation>
            <value>support@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail1__c</field>
            <operation>notEqual</operation>
            <value>customercare@ihs.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>customercare@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DoNotNotify__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>SFDC-3834 :Separate case flow for Partner Inquiries</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>NotifyWhenResponseManagementCaseIsCreated</fullName>
        <actions>
            <name>NotifyCreatorAndContactNewResponseManagementCase</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8 AND (9 OR 10 OR 11 OR 12 OR 13 OR 14 OR 15 OR 16 OR 17 OR 18 OR 19 OR 20 OR 21 OR 22)</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Response Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@markit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>customercare@ihs.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>customercare@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DoNotNotify__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>notEqual</operation>
            <value>Sales | Finance Forms</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>contains</operation>
            <value>@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>contains</operation>
            <value>@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>contains</operation>
            <value>@markit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>contains</operation>
            <value>@markit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>contains</operation>
            <value>@mserv.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>contains</operation>
            <value>@mserv.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>contains</operation>
            <value>@ipreo.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>contains</operation>
            <value>@ipreo.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>contains</operation>
            <value>@polk.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>contains</operation>
            <value>@polk.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>contains</operation>
            <value>@ihs.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>contains</operation>
            <value>@ihs.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>contains</operation>
            <value>@automotivemastermind.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>contains</operation>
            <value>@automotivemastermind.com</value>
        </criteriaItems>
        <description>SFDC1-3643: Notify  contact and creator when Response Management case is created.
SFDC-1465 should not run for Finance Forms team</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>NotifyWhenResponseManagementCaseIsCreatedforExternalUser</fullName>
        <actions>
            <name>NotifyCreatorAndContactNewResponseManagementCaseforExternalUser</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8 AND 9 AND 10 AND 11 AND 12 AND 13 AND 14 AND 15 AND 16 AND 17 AND 18 AND 19 AND 20 AND 21 AND 22</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Response Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@markit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>customercare@ihs.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>customercare@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DoNotNotify__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>notEqual</operation>
            <value>Sales | Finance Forms</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notContain</operation>
            <value>@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notContain</operation>
            <value>@automotivemastermind.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notContain</operation>
            <value>@ihs.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notContain</operation>
            <value>@polk.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notContain</operation>
            <value>@ipreo.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notContain</operation>
            <value>@mserv.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notContain</operation>
            <value>@markit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>notContain</operation>
            <value>@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>notContain</operation>
            <value>@automotivemastermind.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>notContain</operation>
            <value>@ihs.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>notContain</operation>
            <value>@polk.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>notContain</operation>
            <value>@ipreo.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>notContain</operation>
            <value>@mserv.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.SuppliedEmail</field>
            <operation>notContain</operation>
            <value>@markit.com</value>
        </criteriaItems>
        <description>SFDC-4579 - Response Management Team Enhancements - Part 2</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>NotifyWhenResponseManagementCaseStatusIsClosed</fullName>
        <actions>
            <name>NotifyCreatorAndContactsClosedResponseManagementCaseInternal</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>UpdateInternalforContact</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateInternalforWeb</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7 AND 8</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>notEqual</operation>
            <value>Auto-Closed – No Action Taken</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>contains</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Response Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@markit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>customercare@ihs.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>customercare@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DoNotNotify__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>SFDC1-3643: Notify  contact and creator when Response Management case status is &quot;Closed&quot;
SFDC1-9588: updated rule criteria to avoid delete and duplicate status</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>NotifyWhenResponseManagementCaseStatusIsReopened</fullName>
        <actions>
            <name>NotifyCreatorAndContactsClosedResponseManagementCaseInsertReopen</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>UpdateInternalforContact</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateInternalforWeb</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Re-opened</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Response Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@markit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>customercare@ihs.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>customercare@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DoNotNotify__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>SFDC1-3643: Notify  contact and creator when Response Management case status is &quot;Re-opened&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>NotifyWhenResponseManagementCaseStatusIsReopenedforExternalUser</fullName>
        <actions>
            <name>NotifyCreatorAndContactsClosedResponseManagementCaseInsertReopenforExternalUser</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>UpdateExternalforContact</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateExternalforWeb</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND 6 AND 7</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Re-opened</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Response Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@markit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>customercare@ihs.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>customercare@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DoNotNotify__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>SFDC-4579 - Response Management Team Enhancements - Part 2</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>NotifyWhenSalesforceHelpdeskCaseIsCreated</fullName>
        <actions>
            <name>NotifyCaseContactsOfNewSalesforceHelpdeskCase</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5</booleanFilter>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Salesforce Helpdesk</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@markit.com,support@ihsmarkit.com,customercare@ihs.com,customercare@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DoNotNotify__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>notContain</operation>
            <value>Request Intake Form</value>
        </criteriaItems>
        <description>SFDC1-9013: Notify contact and creator when Salesforce Helpdesk case is created</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>NotifyWhenSalesforceHelpdeskCaseStatusIsClosed</fullName>
        <actions>
            <name>NotifyCaseContactsOfClosedSalesforceHelpdeskCase</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 AND 2) AND 3 AND 4 AND 5 AND 6 AND 7 AND 8</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed - Canceled,Closed - Referral,Closed - Resolved,Closed - Resolved by 3rd Party,Closed - Resolved by Customer,Closed - Resolved by IHS Markit</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Salesforce Helpdesk</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@markit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>support@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>customercare@ihs.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.ContactEmail</field>
            <operation>notEqual</operation>
            <value>customercare@ihsmarkit.com</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.DoNotNotify__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <description>SFDC1-9013: Notify contact and creator when Salesforce Helpdesk case status is &quot;Closed&quot;
SFDC1-9588: Updated criteria</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PopulateQueueName</fullName>
        <actions>
            <name>PopulateOriginalQueueName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.AssignToQueue__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Customer Care</value>
        </criteriaItems>
        <description>SFDC-1469 Email-to-Case queue name used in the initial case creation</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>RunCustomAssignmentRule</fullName>
        <actions>
            <name>RunCustomCaseAssignmentLogic</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC1-7574 When the standard case assignment rule assigns case to &apos;To Be Assigned&apos; queue, this workflow checks the custom checkbox field on case and executes the custom code.</description>
        <formula>CONTAINS (OwnerId ,$Label.ToBeAssignedQueueId )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SFDC Helpdesk Case Assignment</fullName>
        <actions>
            <name>SFDCHelpdeskCaseAssignment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>SFDC Helpdesk</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <description>SFDC1-7866.
Because the Case assignment rule does not run off of quick actions a workflow rule will assign the newly created case to the SFDC Helpdesk queue.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Sales Support Queue assignment APAC</fullName>
        <actions>
            <name>AssignmentGlobalSalesSupportAPAC</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC-1989 When the User Region on the created by User record is APAC then the case needs to go to the Global Sales Support - APAC queue</description>
        <formula>AND(  	 	NOT(Owner:Queue.DeveloperName = &quot;CPChannelPartnerOperations&quot;), 	ISPICKVAL(CreatedBy.UserRegion__c, &apos;APAC&apos;),  	RecordType.DeveloperName = &apos;SalesSupport&apos; 	, 	NOT(CONTAINS($Profile.Name, &quot;Admin&quot;)))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Sales Support Queue assignment Americas</fullName>
        <actions>
            <name>AssignmentGlobalSalesSupportAmericas</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC-1989 When the User Region on the created by User record is Americas then the case needs to go to the Global Sales Support - Americas queue</description>
        <formula>AND(  	 	NOT(Owner:Queue.DeveloperName = &quot;CPChannelPartnerOperations&quot;), 	ISPICKVAL(CreatedBy.UserRegion__c, &apos;Americas&apos;),  	RecordType.DeveloperName = &apos;SalesSupport&apos; 	, 	NOT(CONTAINS($Profile.Name, &quot;Admin&quot;)))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Sales Support Queue assignment EMEA</fullName>
        <actions>
            <name>AssignmentGlobalSalesSupportEMEA</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC-1989 When the User Region on the created by User record is EMEA then the case needs to go to the Global Sales Support - EMEA queue</description>
        <formula>AND(  	 	NOT(Owner:Queue.DeveloperName = &quot;CPChannelPartnerOperations&quot;), 	ISPICKVAL(CreatedBy.UserRegion__c, &apos;EMEA&apos;),  	RecordType.DeveloperName = &apos;SalesSupport&apos; 	, 	NOT(CONTAINS($Profile.Name, &quot;Admin&quot;)))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Sales support - Email notification on Create</fullName>
        <actions>
            <name>Notificationforasalespersonwhenemailinquiryisturnedintoacase</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>notEqual</operation>
            <value>Internal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Sales Operations,Sales Support</value>
        </criteriaItems>
        <description>SFDC1-6027:  A sales person to be notified when my email inquiry is turned into a case. SFDC1-9677: Changing record type</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Sales support - Email notification on resolution</fullName>
        <actions>
            <name>NotifyasalespersonwhencasestatusisClosedORResolved</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Sales Operations</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>contains</operation>
            <value>Closed</value>
        </criteriaItems>
        <description>SFDC1-6028: A sales person to be notified when a case is closed. SFDC1-9677. Renaming record type</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Salesforce Helpdesk Case Assignment</fullName>
        <actions>
            <name>CaseOwnerUpdateToSalesforceHelpdesk</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Salesforce Helpdesk</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>notContain</operation>
            <value>Request Intake Form</value>
        </criteriaItems>
        <description>SFDC1-8267
Assigns cases created from the global action to the Salesforce Helpdesk queue.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SalesforceSuggestioncases</fullName>
        <actions>
            <name>SalesforceSuggestionQueueUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Salesforce - Suggestion</value>
        </criteriaItems>
        <description>SFDC1-8978; cases need to go in Salesforce Suggestion queue by global action button</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send Email to Data Lake team</fullName>
        <actions>
            <name>NotifyDataLakeTeamToReviewClient</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Data Lake</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Waiting - Sales Team</value>
        </criteriaItems>
        <description>SFDC-4144 Send Email to Data Lake team</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SetStatusFromNewToInProgress</fullName>
        <actions>
            <name>OMDHStatusUpdatetoInProgress</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SetStatusToInProgress</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC1-5339, When the case is in status NEW and the owner is changed from a queue to an individual, the case status changes to IN PROGRESS. SFDC1-10630: Remove Customer care and Contract management record types</description>
        <formula>AND(  	Not( 					RecordType.DeveloperName = &apos;CustomerCare&apos;), 	ISCHANGED(OwnerId),  	LEFT(PRIORVALUE(OwnerId), 3) = &apos;00G&apos;,  	LEFT(OwnerId, 3) = &apos;005&apos;, 	TEXT(Status) = &apos;New&apos; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UpdateCasePriorityForOutageAndLoginIssues</fullName>
        <actions>
            <name>SetCasePrioritytoHigh</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND (4 OR 5 OR 6 OR 7 OR 8)</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Customer Care</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>notEqual</operation>
            <value>DeleteQueue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>notEqual</operation>
            <value>DuplicateQueue</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>Outage</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>Password Reset</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>Login not Working</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>Locked Account</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>contains</operation>
            <value>Login Issue</value>
        </criteriaItems>
        <description>SFDC1-1378: When a case is generated with subject containing, Outage/Password/Login then change the case priority.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>UpdateCaseWhenOwnerSetsToSalesforceHelpdesk</fullName>
        <actions>
            <name>UpdateRecordTypeToSalesforceHelp</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateStatusToNew</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>FM | Salesforce Helpdesk</value>
        </criteriaItems>
        <description>SFDC1-5799, set the Record Type to Salesforce Help and status to New whenever owner is Salesforce Helpdesk queue.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UpdateCurrentQueueAndPreviousQueueFields</fullName>
        <actions>
            <name>UpdateCurrentQueue</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdatePreviousOwner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC1-1389, This rule is to update two fields on case and hence we can track the previous queue owner on case record</description>
        <formula>OR(ISNEW(), ISCHANGED(OwnerId))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UpdateDataGovernanceCaseStatuswhenAccountAssociated</fullName>
        <actions>
            <name>UpdateCaseStatustoInProgress</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC1-5258 This workflow will automatically update the status of a Data Governance&apos;s New Account case from &quot;New&quot; to &quot;In Progress&quot; once the &quot;Account Created/Associated&quot; field is populated.
SFDC1-7673 update logic for Case record type change</description>
        <formula>AND( ISPICKVAL(Type,&apos;Customer Master Data&apos;), ISPICKVAL(Subtype__c, &apos;New Account&apos;), NOT(ISBLANK(AccountCreated__c)) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UpdateMergedCaseOwner</fullName>
        <actions>
            <name>CaseOwnerToMergedQueue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Merged</value>
        </criteriaItems>
        <description>SFDC-2961: Update case owner when case status equals Merged.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UpdateOMDStatusOrderManagementHelpdeskCase</fullName>
        <actions>
            <name>SetOMDStatusToNew</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Order Management/Delivery Help Desk</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.OMDStatus__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>SFDC1-9432 Update OMD Status for Order Management/Delivery Help Desk case to &quot;New&quot;</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>UpdateOrderManagementDeliveryHelpdeskCaseRecordType</fullName>
        <actions>
            <name>UpdateCaseRecordType</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC1-6470 update case&apos;s record type to Order Management/Delivery Help Desk when Customer Care Initiate is true, and Team Select is &quot;Order Management&quot; or &quot;Delivery&quot;</description>
        <formula>CustomerCareInitiated__c = TRUE &amp;&amp; ( ISPICKVAL(TeamSelect__c, &apos;Order Management&apos;) || ISPICKVAL(TeamSelect__c, &apos;Delivery&apos;) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>UpdateRecordTypeToContractManagement</fullName>
        <actions>
            <name>UpdateRecordTypeToContractManagement</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>CM | Contract Management</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Contract Management</value>
        </criteriaItems>
        <description>SFDC1-10602: Update record type to Contract Management when case owners equals CM | Contract Management</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UpdateRecordTypeToSalesOps</fullName>
        <actions>
            <name>UpdateRecordTypeToSalesOps</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Sales | Sales Operations</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Sales Operations</value>
        </criteriaItems>
        <description>SFDC1-10602: Update record type to Sales Ops when case owners equals Sales | Sales Operations</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UpdateRecordTypeToSalesforceHelpdesk</fullName>
        <actions>
            <name>UpdateRecordTypeToSalesforceHelpdesk</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Salesforce Helpdesk</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>notEqual</operation>
            <value>Salesforce Helpdesk</value>
        </criteriaItems>
        <description>SFDC1-10602: Update record type to Salesforce Helpdesk when case owners equals Salesforce Helpdesk</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UpdateWebChatCaseSubjectandDescription</fullName>
        <actions>
            <name>UpdateWebChatCaseDescription</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateWebChatCaseSubject</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC1-3537 Update Web Chat Case Subject and Description when contact is known to &quot;Web Chat – &lt;FirstName&gt; &lt;LastName&gt; at &lt;Account Name&gt;&quot;</description>
        <formula>(TEXT(Origin) = &apos;Web Chat&apos;) &amp;&amp;  (RecordType.DeveloperName = &apos;CustomerCare&apos;) &amp;&amp;  (Contact.Id &lt;&gt; null)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>