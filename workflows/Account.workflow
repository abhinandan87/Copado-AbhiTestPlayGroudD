<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>AccountOwnerChangeNotificationEmailAlert</fullName>
        <description>Account Owner Change Notification Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <field>PreviousOwner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/AccountOwnerChangeNotificationEmail</template>
    </alerts>
    <fieldUpdates>
        <fullName>ClearStateOfIncorporation</fullName>
        <description>SFDC1-5766, This clears out the &quot;State of Incorporation&quot; field when the &quot;Incorporated in&quot; field get changed from &quot;United States&quot; into something else (or empty)</description>
        <field>StateOfIncorporation__c</field>
        <name>ClearStateOfIncorporation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateRelationshipProspect</fullName>
        <description>SFDC1-775 set relationship as &apos;Prospect&apos; on account creation</description>
        <field>Relationship__c</field>
        <formula>&quot;Prospect&quot;</formula>
        <name>Update Relationship: Prospect</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>VCSetScreeningTrueNonIHSAccount</fullName>
        <description>SFDC-1923 Visual Compliance. Bypass IHS migrated data</description>
        <field>VCScreeningTrigger__c</field>
        <literalValue>1</literalValue>
        <name>VCSetScreeningTrueNonIHSAccount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>VCUpdateRPSStatusNAAccount</fullName>
        <description>SFDC-1923 Visual Compliance. Update RPS status as Not required on IHS Accounts</description>
        <field>VCRestrictedPartyScreeningStatus__c</field>
        <formula>&quot;Not Required&quot;</formula>
        <name>VCUpdateRPSStatusNAAccount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ClearStateOfIncorporation</fullName>
        <actions>
            <name>ClearStateOfIncorporation</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC1-5814, This clears out the &quot;State of Incorporation&quot; field when the &quot;Incorporated in&quot; field get changed from &quot;United States&quot; into something else (or empty).</description>
        <formula>IncorporatedIn__r.Name != &apos;United States&apos; &amp;&amp;   NOT(ISBLANK(TEXT(StateOfIncorporation__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SetAccountAsProspect</fullName>
        <actions>
            <name>UpdateRelationshipProspect</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC1-775 set account relationship as prospect when account is created</description>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SetScreeningTrueNonIHSAccounts</fullName>
        <actions>
            <name>VCSetScreeningTrueNonIHSAccount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC-1923 Visual Compliance. Bypass IHS migrated data</description>
        <formula>TEXT(LegacySystem__c)!=&apos;IHS_MSCRM&apos; &amp;&amp; (ISNEW() || ISCHANGED(Name) || ISCHANGED(BillingCountry) || ISCHANGED(BillingState) || ISCHANGED(BillingCity))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UpdateRPSStatusOnAccount</fullName>
        <actions>
            <name>VCUpdateRPSStatusNAAccount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC-1923 Visual Compliance. Update RPS Status on Account</description>
        <formula>TEXT(LegacySystem__c)=&apos;IHS_MSCRM&apos; &amp;&amp; (ISNEW() || ISCHANGED(Name) || ISCHANGED(BillingCountry) || ISCHANGED(BillingState) || ISCHANGED(BillingCity))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>