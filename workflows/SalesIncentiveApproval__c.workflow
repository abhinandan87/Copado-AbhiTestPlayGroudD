<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EmailAlertSalesIncentiveApprovalStatusUpdate</fullName>
        <description>EmailAlertSalesIncentiveApprovalStatusUpdate</description>
        <protected>false</protected>
        <recipients>
            <field>IncentiveOwner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>no-replycrm@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/SalesIncentiveApprovalStatusUpdate</template>
    </alerts>
    <fieldUpdates>
        <fullName>OwnerUpdate</fullName>
        <field>OwnerId</field>
        <lookupValue>SalesIncentiveApprovalQueue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>OwnerUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SalesIncentiveApproved</fullName>
        <field>CommissionStatus__c</field>
        <literalValue>Approved</literalValue>
        <name>Sales Incentive Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SalesIncentiveRejected</fullName>
        <field>CommissionStatus__c</field>
        <literalValue>Declined</literalValue>
        <name>Sales Incentive Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SubmittedforApproval</fullName>
        <field>CommissionStatus__c</field>
        <literalValue>Waiting on Rep Info</literalValue>
        <name>Submitted for Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>SalesIncentiveApprovalStatusNotification</fullName>
        <actions>
            <name>EmailAlertSalesIncentiveApprovalStatusUpdate</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>SFDC-2625 Email Alert for Sales Incentive Approval Email Alert</description>
        <formula>AND( ISCHANGED(CommissionStatus__c), $Profile.Name  &lt;&gt; &apos;System Administrator&apos; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>