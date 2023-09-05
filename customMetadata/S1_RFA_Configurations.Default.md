<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Default</label>
    <protected>false</protected>
    <values>
        <field>Division_Name__c</field>
        <value xsi:type="xsd:string">IHS</value>
    </values>
    <values>
        <field>Email_Body_Prefix__c</field>
        <value xsi:type="xsd:string">Hi,

{{jobname}} job processed with the following description:

{{mailContent}}

Thank you,
Admin</value>
    </values>
    <values>
        <field>Email_Subject__c</field>
        <value xsi:type="xsd:string">S1 request Job status (IHS EA)</value>
    </values>
    <values>
        <field>Filter_String__c</field>
        <value xsi:type="xsd:string">Push_Updates__c = true</value>
    </values>
    <values>
        <field>From_Email_Address__c</field>
        <value xsi:type="xsd:string">no-replysfdc@ihsmarkit.com</value>
    </values>
    <values>
        <field>Request_Fields__c</field>
        <value xsi:type="xsd:string">Id, Account__c, Account_CAPIQ_ID__c,Account_Name__c, Account_country__c, createdById, External_id__c, Opportunity__c, Opportunity_name__c, Requestor_Email__c,Requested_by__c, Description__c, Status__c, OwnerId, Industry__c, division__c, category__c, Completed_Date__c</value>
    </values>
    <values>
        <field>Request_Object_API__c</field>
        <value xsi:type="xsd:string">S1_Request__c</value>
    </values>
    <values>
        <field>Response_Child_API__c</field>
        <value xsi:type="xsd:string">S1_Response__r</value>
    </values>
    <values>
        <field>Response_Fields__c</field>
        <value xsi:type="xsd:string">Id, createdById, Description__c, External_id__c, S1_Request__c, Status__c, Owner__c, Owner_Email__c, Type__c</value>
    </values>
    <values>
        <field>Response_Object_API__c</field>
        <value xsi:type="xsd:string">S1_Response__c</value>
    </values>
    <values>
        <field>Send_Email_Notification__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>Sub_Divisions__c</field>
        <value xsi:type="xsd:string">Automotive, Mobility, ENR, Financial Services, Engineering Solutions, IHS</value>
    </values>
    <values>
        <field>To_Email_Address__c</field>
        <value xsi:type="xsd:string">akash.punera@spglobal.com, pankhuri.jain2@spglobal.com, abhishek.mittal@spglobal.com</value>
    </values>
</CustomMetadata>
