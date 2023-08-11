<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>AlertFeedbackCreatorWhenFeedbackIsCreated</fullName>
        <description>SFDC-4199 Send Email to Feedback creator when a feeback is created</description>
        <protected>false</protected>
        <recipients>
            <field>EmailAddress__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replysfdc@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CSCustomerCare/WhenFeedbackRecordIsCreated</template>
    </alerts>
    <alerts>
        <fullName>SendEmailToFeedbackCreatorWhentsStausIsEitherCompletedO</fullName>
        <description>SFDC-4199 Send Email to Feedback creator when its staus is either Completed or Rejected</description>
        <protected>false</protected>
        <recipients>
            <field>EmailAddress__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>no-replysfdc@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CSCustomerCare/WhenFeedbackRecordIsCompletedRejected</template>
    </alerts>
    <rules>
        <fullName>AlertWhenFeedbackIsCreated</fullName>
        <actions>
            <name>AlertFeedbackCreatorWhenFeedbackIsCreated</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Feedback__c.Status__c</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <description>SFDC-4199 Send email to feedback creator when feedback record is created</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>AlertWhenFeedbackStatusIsCompleted-Rejected</fullName>
        <actions>
            <name>SendEmailToFeedbackCreatorWhentsStausIsEitherCompletedO</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>SFDC-4199 Send email to feedback creator when feedback status is completed or rejected</description>
        <formula>AND( ISCHANGED(Status__c), OR( Text(Status__c) = &apos;Completed&apos;, Text(Status__c) = &apos;Rejected&apos; ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>