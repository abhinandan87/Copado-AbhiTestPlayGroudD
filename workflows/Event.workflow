<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>PopulateParentId</fullName>
        <field>ParentId__c</field>
        <formula>CASESAFEID(Id)</formula>
        <name>PopulateParentId</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>PopulateParentId</fullName>
        <actions>
            <name>PopulateParentId</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC-3331 capturing event id so that it will be available on the child events to show correct meeting notes</description>
        <formula>AND (NOT(IsChild),  ISBLANK(ParentId__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>