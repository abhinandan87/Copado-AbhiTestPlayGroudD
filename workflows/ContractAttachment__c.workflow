<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>SendEmailToContractOwnerWheneverPOContractAttachmentIsCreated</fullName>
        <description>Send Email to Contract Owner whenever PO Contract Attachment is created</description>
        <protected>false</protected>
        <recipients>
            <field>OppyOwnerEmail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>RenewalOwnerEmail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>no-replysfdc@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CSCustomerCare/NotifyContractOnwnerWhenContractAttachmentIsCreated</template>
    </alerts>
    <fieldUpdates>
        <fullName>UpdateOppyOwnerEmailFields</fullName>
        <field>OppyOwnerEmail__c</field>
        <formula>Contract__r.Opportunity__r.Owner.Email</formula>
        <name>Update Oppy Owner Email fields</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateRenewalOwnerEmailField</fullName>
        <field>RenewalOwnerEmail__c</field>
        <formula>Contract__r.RenewalOwner__r.Email</formula>
        <name>Update Renewal Owner Email field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Send Email to Contract%2C Opportunity%2C Renewal owners on Contract Attachment creation</fullName>
        <actions>
            <name>SendEmailToContractOwnerWheneverPOContractAttachmentIsCreated</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>UpdateOppyOwnerEmailFields</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateRenewalOwnerEmailField</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>ContractAttachment__c.AttachmentType__c</field>
            <operation>equals</operation>
            <value>Purchase Order</value>
        </criteriaItems>
        <criteriaItems>
            <field>ContractAttachment__c.CurrentPO__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <criteriaItems>
            <field>ContractAttachment__c.POAttached__c</field>
            <operation>equals</operation>
            <value>No</value>
        </criteriaItems>
        <criteriaItems>
            <field>ContractAttachment__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Order Form,Consulting</value>
        </criteriaItems>
        <criteriaItems>
            <field>ContractAttachment__c.Name</field>
            <operation>notContain</operation>
            <value>PO /</value>
        </criteriaItems>
        <description>Once the Contract Attachment record is created via batch, send email notification to Contract, Opportunity and Renewal Owner.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>