<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>SetProductName</fullName>
        <description>SFDC-99 Set product name field equal to Associated Product name</description>
        <field>Name</field>
        <formula>LEFT(AssociatedProduct__r.Name,80)</formula>
        <name>SetProductName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetProductNameOnCLI</fullName>
        <description>SFDC-99 Sync product name text field with Associated product lookup field</description>
        <field>Name</field>
        <formula>LEFT(AssociatedProduct__r.Name,80)</formula>
        <name>SetProductNameOnCLI</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateEndDate</fullName>
        <description>SFDC1-4582 Set Contract Line Item End Date to Contract End Date</description>
        <field>EndDate__c</field>
        <formula>Contract__r.EndDate</formula>
        <name>UpdateEndDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateMaterialCodeOnCLI</fullName>
        <description>SFDC - 3362 User Support - Request edit rights to Pricing section of Contract Line item, relates to SFDC-3161</description>
        <field>MaterialCode__c</field>
        <formula>AssociatedProduct__r.MaterialCode__c</formula>
        <name>UpdateMaterialCodeOnCLI</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateStartDate</fullName>
        <description>SFDC1-4582 Set Contract Line Item Start Date equal to Contract Start Date</description>
        <field>StartDate__c</field>
        <formula>Contract__r.StartDate</formula>
        <name>UpdateStartDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>PopulateContractLineItem</fullName>
        <actions>
            <name>UpdateEndDate</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateStartDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>ContractLineItem__c.StartDate__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>ContractLineItem__c.EndDate__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>SFDC1-4582 Workflow rule to populate Contract Line Item start date and end date</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>UpdateCLIProductNameMaterialCode</fullName>
        <actions>
            <name>SetProductNameOnCLI</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateMaterialCodeOnCLI</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC - 3362 User Support - Request edit rights to Pricing section of Contract Line item, relates to SFDC-3161</description>
        <formula>(ISNEW() || ISCHANGED(AssociatedProduct__c))   &amp;&amp;  NOT(ISNULL(AssociatedProduct__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>