<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>AlerttoApprovedOrderRequestOwner</fullName>
        <description>Alert to Approved Order Request Owner</description>
        <protected>false</protected>
        <recipients>
            <field>Requestor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>WRFPLCTemplates/OrderRequestApproved</template>
    </alerts>
    <alerts>
        <fullName>AlerttoNewOrderRequestOwner</fullName>
        <description>Alert to New Order Request Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>WRFPLCTemplates/OrderRequestOwnerChange</template>
    </alerts>
    <rules>
        <fullName>OrderRequestApproved</fullName>
        <actions>
            <name>AlerttoApprovedOrderRequestOwner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>OrderRequest__c.OrderRequestStatus__c</field>
            <operation>equals</operation>
            <value>Approved,Approved without Job,Rejected</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>OrderRequestOwnerIsChanged</fullName>
        <actions>
            <name>AlerttoNewOrderRequestOwner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>OwnerId  &lt;&gt; PRIORVALUE(OwnerId )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>