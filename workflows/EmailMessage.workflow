<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>EmailMessageUpdateCase</fullName>
        <field>LastModifiedDateForRelatedData__c</field>
        <formula>NOW()</formula>
        <name>EmailMessageUpdateCase</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateCaseWhenEmailIsSent</fullName>
        <description>SFDC1-10607:When email is sent from a case, last modified date has to be updated. Update Subject, a Mandatory field, so that last modified date will be repopulated</description>
        <field>Subject</field>
        <formula>Subject</formula>
        <name>UpdateCaseWhenEmailIsSent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateTimeWhenEmailSent</fullName>
        <description>SFDC-867 To resolve the bug that Case subject updated on email reply</description>
        <field>UpdatedTime__c</field>
        <formula>Now()</formula>
        <name>UpdateTimeWhenEmailSent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>EmailMessageUpdateFieldonCase</fullName>
        <actions>
            <name>EmailMessageUpdateCase</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.CaseID18Character__c</field>
            <operation>notEqual</operation>
            <value>Null</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UpdateCaseWhenEmailIsSent</fullName>
        <actions>
            <name>UpdateTimeWhenEmailSent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EmailMessage.Incoming</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.CaseNumber</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>SFDC1-10607:When email is sent from a case, last modified date has to be updated. Doing this, with this rule. Checking for Outgoing Email and Case number not to be empty</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>