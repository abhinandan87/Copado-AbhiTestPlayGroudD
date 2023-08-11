<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>NameAccountdomainNameUpdate</fullName>
        <description>SFDC1-8819; Name field updated by rule</description>
        <field>Name</field>
        <formula>BusinessLine__r.Name + &quot; &quot;+ Domain__c + &quot; &quot; + 
IF(INCLUDES( Region__c , &quot;AMER&quot;), &quot;AMER&quot;, NULL) +&quot; &quot; + IF(INCLUDES( Region__c , &quot;APAC&quot;), &quot;APAC&quot;, NULL) +&quot; &quot;+IF(INCLUDES( Region__c , &quot;EMEA&quot;), &quot;EMEA&quot;, NULL)</formula>
        <name>NameAccountdomainNameUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>NamedAccountDomainnNamePopulationRule</fullName>
        <actions>
            <name>NameAccountdomainNameUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC1-8819;This rule auto populates name field for this object</description>
        <formula>1=1</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>