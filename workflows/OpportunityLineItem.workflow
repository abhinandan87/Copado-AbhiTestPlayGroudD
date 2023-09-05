<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>ServiceDelDateEqualToContrStart</fullName>
        <description>SFDC-1819
Sets the Service Delivery Date to the Contract Start Date</description>
        <field>ServiceDeliveryDate__c</field>
        <formula>Opportunity.ContractStartDate__c</formula>
        <name>Service Del Date Equal to Contr Start</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetPricingCodeTo1000</fullName>
        <description>SFDC1-292 set price reason code to 1000 for Opportunity product</description>
        <field>PriceReasonCode__c</field>
        <formula>&quot;1000&quot;</formula>
        <name>Set Pricing Code to 1000</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetProbabilityOnOpportunityProduct</fullName>
        <description>SFDC - 1924 : Set probability on opportunity product  from opportunity on the creation of record.</description>
        <field>Probability__c</field>
        <formula>Opportunity.Probability</formula>
        <name>SetProbabilityOnOpportunityProduct</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Service Delivery Date on Creation</fullName>
        <actions>
            <name>ServiceDelDateEqualToContrStart</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC-1819
Auto populated the Service Delivery Date on creation with the Contract Start Date from the lookup opportunity.</description>
        <formula>ISBLANK(ServiceDeliveryDate__c)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SetProbabilityonOpportunityProduct</fullName>
        <actions>
            <name>SetProbabilityOnOpportunityProduct</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC - 1924 : This workflow will  update the probability on opportunity product from opportunity on creation of a record.</description>
        <formula>NOT(ISBLANK(OpportunityId)) &amp;&amp; ISNULL(Probability__c)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>UpdatePricingCodeOnCreateUpdate</fullName>
        <actions>
            <name>SetPricingCodeTo1000</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC1-292 Set pricing code to 1000 whenever a non service account updates records
SFDC1-7919 remove exception for user and add for profiles instead</description>
        <formula>AND (NOT(CONTAINS($Profile.Name, &quot;System Administrator&quot;)),NOT(CONTAINS($Profile.Name, &quot;API&quot;)),NOT(CONTAINS($Profile.Name, &quot;IHSMarkit System Admin&quot;)),   	OR(	 		ISNEW(), ISCHANGED( UnitPrice),  ISCHANGED( Quantity), ISCHANGED( DiscountPercentage__c ) 	)   )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>