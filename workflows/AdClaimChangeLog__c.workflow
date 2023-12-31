<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>NotifyOwnerOfTheRecordRejection</fullName>
        <description>SFDC1-460 Notify Owner of the Record Rejection SFDC1-9950 Update of Recipient</description>
        <protected>false</protected>
        <recipients>
            <field>Requester__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/EmailOnAdClaimChangeLogStatusChange</template>
    </alerts>
    <alerts>
        <fullName>NotifyOwnerOftheRecordApproval</fullName>
        <description>SFDC1-460 Notify Owner of the Record Approval,SFDC1-9950 Update of Recipient</description>
        <protected>false</protected>
        <recipients>
            <field>Requester__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/EmailOnAdClaimChangeLogStatusChange</template>
    </alerts>
    <fieldUpdates>
        <fullName>UpdateApprovedDateToToday</fullName>
        <description>SFDC1-460 The approved date is set to Today&apos;s date</description>
        <field>ApprovedDate__c</field>
        <formula>TODAY()</formula>
        <name>Update Approved Date To Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateRequestDateToTodayWhenSubmission</fullName>
        <description>SFDC1-2069 : Update the Request Date to Today when Submit for Approval.</description>
        <field>RequestDate__c</field>
        <formula>TODAY()</formula>
        <name>UpdateRequestDateToTodayWhenSubmission</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>