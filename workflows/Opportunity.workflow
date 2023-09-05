<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EmailAlertNotifyOwnerWhenTMCStatusIsInactive</fullName>
        <description>SFDC1-7001: Email alert to notify Opportunity owner when TMC status is inactive</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/NotifyOpportunityOwnerWhenTMCStatusIsInactive</template>
    </alerts>
    <alerts>
        <fullName>EmailAlertToOptyOwnerWhenExceptionApproved</fullName>
        <description>EmailAlertToOptyOwnerWhenExceptionApproved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/ProductSelectionExceptionApprovalEmail</template>
    </alerts>
    <alerts>
        <fullName>EmailAlertToOptyOwnerWhenExceptionDenied</fullName>
        <description>EmailAlertToOptyOwnerWhenExceptionDenied</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/ProductSelectionExceptionDenialEmail</template>
    </alerts>
    <alerts>
        <fullName>NotifyOldandNewOpportunityOwnerForOwnerChange</fullName>
        <description>NotifyOldandNewOpportunityOwnerForOwnerChange</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>PreviousOpportunityOwner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/OpportunityOwnerChangeNotificationEmail</template>
    </alerts>
    <alerts>
        <fullName>Opportunity6WEmailAlert</fullName>
        <description>Opportunity6WEmailAlert</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Alliance Lead</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>BL Leader</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Channel Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Client Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Consultant</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Contract Support</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Covering Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Executive Sponsor</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Executive in Charge</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Opportunity Owner</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Product Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Project Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Pursuit Lead</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Referred By</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Response Management Lead</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>SME</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Sales Coordinator</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Sales Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Sales Operations</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Sales Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Subject Matter Expert</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Alliance Lead</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>BL Leader</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Channel Manager</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Client Manager</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Consultant</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Contract Support</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Covering Rep</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Executive Sponsor</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Executive in Charge</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Manager</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Opportunity Owner</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Product Specialist</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Project Manager</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Pursuit Lead</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Referred By</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Response Management Lead</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>SME</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Sales Coordinator</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Sales Manager</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Sales Operations</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Sales Specialist</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Subject Matter Expert</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/ClosedWonOpportunity</template>
    </alerts>
    <alerts>
        <fullName>OpportunityClosedLostEmailAlert</fullName>
        <description>OpportunityClosedLostEmailAlert</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Alliance Lead</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>BL Leader</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Channel Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Client Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Consultant</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Contract Support</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Covering Rep</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Executive Sponsor</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Executive in Charge</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Opportunity Owner</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Product Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Project Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Pursuit Lead</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Referred By</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Response Management Lead</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>SME</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Sales Coordinator</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Sales Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Sales Operations</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Sales Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Subject Matter Expert</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Account Manager</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Alliance Lead</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>BL Leader</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Channel Manager</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Client Manager</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Consultant</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Contract Support</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Covering Rep</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Executive Sponsor</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Executive in Charge</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Manager</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Opportunity Owner</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Product Specialist</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Project Manager</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Pursuit Lead</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Referred By</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Response Management Lead</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>SME</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Sales Coordinator</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Sales Manager</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Sales Operations</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Sales Specialist</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Subject Matter Expert</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/ClosedLostOpportunity</template>
    </alerts>
    <alerts>
        <fullName>OpportunityOwnerEmailTMCActive</fullName>
        <description>SFDC1-6911;This workflow is sent when TMC team sets the Opportunity to TMC Status field to Active, this emails Oppy Owner that his/her oppy is now TMC Active (scheduled for TMC review)</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/OpportunityTMCSetToActive</template>
    </alerts>
    <alerts>
        <fullName>QuotationReviewNeededonOpportunityEmailAlert</fullName>
        <description>Quotation Review Needed on Opportunity Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>NAMRProductManagementGroup</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/QuotationReviewNeededonOpportunity</template>
    </alerts>
    <alerts>
        <fullName>SendNotificationToOpportunityAndAccountTeam</fullName>
        <description>SFDC1-1433 Send Notification To Opportunity And Account Team</description>
        <protected>false</protected>
        <recipients>
            <recipient>Contract Support</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Executive Sponsor</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Manager</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Opportunity Owner</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Product Specialist</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>SME</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Sales Coordinator</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <recipient>Contract Support</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Executive Sponsor</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Manager</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Opportunity Owner</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Product Specialist</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>SME</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <recipients>
            <recipient>Sales Coordinator</recipient>
            <type>opportunityTeam</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/AutoCloseRenewalOpportunityNotification</template>
    </alerts>
    <fieldUpdates>
        <fullName>ClosedDateSetToToday</fullName>
        <description>SFDC1-488;If the Opportunity is set to 6L and the Close Date is in the Future - the Date should update with the Current Date.</description>
        <field>CloseDate</field>
        <formula>Today()</formula>
        <name>ClosedDateSetToToday</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>NewOppySalesstage1</fullName>
        <description>SFDC1- 171; Sales Stage should default to Sales Stage 1 on New Business.</description>
        <field>StageName</field>
        <literalValue>1-Sales Qualified</literalValue>
        <name>NewOppySalesstage1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>TMCAcknowledged</fullName>
        <description>SFDC-92
Sets the TMC Acknowledged field to todays date</description>
        <field>TMCAcknowledged__c</field>
        <formula>TODAY()</formula>
        <name>TMCAcknowledged</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>TMCLastReviewOverwrite</fullName>
        <description>SFDC-189 Overwrites the Last Review field with the last review date field.</description>
        <field>LastReview__c</field>
        <formula>NextReview__c</formula>
        <name>TMCLastReviewOverwrite</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>TMCNextReviewOverwrite</fullName>
        <description>SFDC-189 
Overwrites the next review date with a Null Value</description>
        <field>NextReview__c</field>
        <name>TMCNextReviewOverwrite</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>TMCStatusReviewRequired</fullName>
        <description>SFDC-92
Sets the TMC Status field to Review Required</description>
        <field>TMCStatus__c</field>
        <literalValue>Review Required</literalValue>
        <name>TMCStatusReviewRequired</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>TotalOpptyAmountUpdate</fullName>
        <description>SFDC1-7045:Overlay spit type amount is calculated from Total Opportunity Amount field</description>
        <field>TotalOpportunityAmount__c</field>
        <formula>Amount</formula>
        <name>TotalOpptyAmountUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateBSIOnRenewalOpportunity</fullName>
        <description>SFDC - 2696 - BSI Membership # should be visible on the Order Management Case</description>
        <field>BSI__c</field>
        <formula>PreviousYearOpportunitylink__r.BSI__c</formula>
        <name>UpdateBSIOnRenewalOpportunity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>NewOppySalesstage1</fullName>
        <actions>
            <name>NewOppySalesstage1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>New Business</value>
        </criteriaItems>
        <description>SFDC1-171; Sales Stage should default to Sales Stage 1 on New Business.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>NotifyOwnerWhenTMCStatusIsInactive</fullName>
        <actions>
            <name>EmailAlertNotifyOwnerWhenTMCStatusIsInactive</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.TMCStatus__c</field>
            <operation>equals</operation>
            <value>Inactive</value>
        </criteriaItems>
        <description>SFDC1-7001:Notify Opportunity owner when TMC status is Inactive</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>OpportunityCloseDateBehaviourForLostBusiness</fullName>
        <actions>
            <name>ClosedDateSetToToday</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC1-488;If the Opportunity is set to 6L and the Close Date is in the Future - the Date should update with the Current Date.</description>
        <formula>AND(      ISCHANGED(IsClosed),     CloseDate  != Today(),     NOT(CONTAINS($Profile.Name, &apos;Admin&apos;)),      NOT(CONTAINS($Profile.Name, &apos;Sales Ops&apos;)),     NOT(CONTAINS($Profile.Name, &apos;User Support&apos;)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>OpportunityClosedLossNotification</fullName>
        <actions>
            <name>OpportunityClosedLostEmailAlert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6L-Renewal Lost,6L-Closed Lost,6L-Forecasting Placeholder</value>
        </criteriaItems>
        <description>SFDC1-468;Email Alert for Salesperson, Account Team member or Opportunity Team member when Opportunity is closed lost</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>OpportunityStage6WEmailNotification</fullName>
        <actions>
            <name>Opportunity6WEmailAlert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2 OR 3</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6W-Closed Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6W-Renewal Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>6W-Forecasting Placeholder</value>
        </criteriaItems>
        <description>SFDC1-41;Email to Owner, Opportunity Team, Account Team when Sales Stage is set to 6W</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Product Selection Exception Approval Email</fullName>
        <actions>
            <name>EmailAlertToOptyOwnerWhenExceptionApproved</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.ExceptionStatus__c</field>
            <operation>equals</operation>
            <value>Exception Request Approved</value>
        </criteriaItems>
        <description>SFDC-4731: Send an email to an user when exception for legal entity has been approved</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Product Selection Exception Denial Email</fullName>
        <actions>
            <name>EmailAlertToOptyOwnerWhenExceptionDenied</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.ExceptionStatus__c</field>
            <operation>equals</operation>
            <value>Exception Request Denied</value>
        </criteriaItems>
        <description>SFDC-4731: Send an email to an user when exception for legal entity has been denied</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SendEmailOnOppOwnerChange</fullName>
        <actions>
            <name>NotifyOldandNewOpportunityOwnerForOwnerChange</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>SFDC1-9836: Send an email to new and old opp owner on owner change.
Parent Story: SFDC1-311 : To Update the Previous Owner and Send Email Notification to Old and New Owner</description>
        <formula>ISCHANGED( OwnerId )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TMCReview Required %28US %26 EMEA%29</fullName>
        <actions>
            <name>TMCAcknowledged</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>TMCStatusReviewRequired</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 5 AND 6 AND 7 AND (8 OR 9) AND (4 OR (10 AND 11))</booleanFilter>
        <criteriaItems>
            <field>Opportunity.HasOpportunityLineItem</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.SalesRegion__c</field>
            <operation>equals</operation>
            <value>Americas,EMEA</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.FirstYearValue__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;USD 250,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>New Business</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>notEqual</operation>
            <value>1-Sales Qualified</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.ForecastCategoryName</field>
            <operation>equals</operation>
            <value>Pipeline,Best Case,Commit</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.TMCStatus__c</field>
            <operation>equals</operation>
            <value>,Review Required,Reviewed - Not Required</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.TMCStatus__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.FirstYearValue__c</field>
            <operation>greaterOrEqual</operation>
            <value>&quot;USD 100,000&quot;</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.ProductGroup__c</field>
            <operation>contains</operation>
            <value>Corporate Actions</value>
        </criteriaItems>
        <description>SFDC-92
TMC Status Field set to &quot;Review Required
TMC Acknowledged field set with Today&apos;s Date</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>TMCUpdateLastNextReview</fullName>
        <active>true</active>
        <description>SFDC-189 
Updates the last review with the next review date and then empties the first field.</description>
        <formula>NOT(ISBLANK (NextReview__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>TMCLastReviewOverwrite</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Opportunity.NextReview__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>TMCUpdateNextReview</fullName>
        <actions>
            <name>TMCNextReviewOverwrite</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC-1355 
Splits up the original workflow rule to trigger the field updates sequentially.</description>
        <formula>LastReview__c = NextReview__c</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>TotalOpptyAmountUpdateByAmount</fullName>
        <actions>
            <name>TotalOpptyAmountUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC1-7045:Overlay spit type amount is calculated from Total Opportunity Amount field</description>
        <formula>ISCHANGED( Amount )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UpdateBSIOnRenewalOpportunity</fullName>
        <actions>
            <name>UpdateBSIOnRenewalOpportunity</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC-2696 - BSI Membership # should be visible on the Order Management Case</description>
        <formula>AND( ISBLANK(BSI__c), RecordType.DeveloperName  &lt;&gt; &apos;NewBusiness&apos;, NOT(ISBLANK(PreviousYearOpportunitylink__c)), NOT(ISBLANK(PreviousYearOpportunitylink__r.BSI__c)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WorkflowsForTMCFieldsSetToActive</fullName>
        <actions>
            <name>OpportunityOwnerEmailTMCActive</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.TMCStatus__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.NextReview__c</field>
            <operation>greaterOrEqual</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>SFDC1-6911;This workflow is sent when TMC team sets the Opportunity to TMC Status field to Active, this emails Oppy Owner that his/her oppy is now TMC Active (scheduled for TMC review)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>