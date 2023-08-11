<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>NotifyOwnerOfTheRecordApproval</fullName>
        <description>SFDC1-366 Notify Owner of the Record Approval SFDC1-9950 Update of Recipient</description>
        <protected>false</protected>
        <recipients>
            <field>IHSAccountRepresentative__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/EmailOnAdClaimChangeStatus</template>
    </alerts>
    <alerts>
        <fullName>NotifyOwnerOfTheRecordRejection</fullName>
        <description>SFDC1-366 Notify Owner of the Record Rejection SFDC1-9950 Update of Recipient</description>
        <protected>false</protected>
        <recipients>
            <field>IHSAccountRepresentative__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/EmailOnAdClaimChangeStatus</template>
    </alerts>
    <fieldUpdates>
        <fullName>AdClaimOwnerChangeWhenSubmitted</fullName>
        <description>SFDC1-9795: Ad Claim and Ad Claim Owners updated to Ad Claims Approver Queue when submitted status</description>
        <field>OwnerId</field>
        <lookupValue>AdClaimsApproverQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>AdClaimOwnerChangeWhenSubmitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CheckSubmittedCheckbox</fullName>
        <description>SFDC1-366 This field prevents record from being processed by process builder when it is already approved</description>
        <field>Submitted__c</field>
        <literalValue>1</literalValue>
        <name>Check Submitted Checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateApprovedDateToToday</fullName>
        <description>SFDC1-366 The approved date is set to Today&apos;s date</description>
        <field>ApprovedDate__c</field>
        <formula>TODAY()</formula>
        <name>Update Approved Date To Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>AdClaimOwnerChangeWhenSubmitted</fullName>
        <actions>
            <name>AdClaimOwnerChangeWhenSubmitted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>AdClaim__c.ClaimsStatus__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <description>SFDC1-9795 - Ad Claim and Ad Claim Owners updated to Ad Claims Approver Queue when submitted status</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>