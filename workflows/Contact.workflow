<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>EmailOptOutChangeResult</fullName>
        <description>SFDC1- 452, Read only date/time field which is changed by Emai lOpt Out</description>
        <field>EmailOptOutTimeStamp__c</field>
        <formula>Now()</formula>
        <name>EmailOptOutChangeResult</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>EmailOptOutTimeStampUpdate</fullName>
        <description>SFDC1 -452; Workflow rule helps to update the field Email Opt Out Time Stamp
 when a new contact created from Lead</description>
        <field>EmailOptOutTimeStamp__c</field>
        <name>Email Opt Out Time Stamp Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetEloquaHardBounceToBlank</fullName>
        <description>SFDC1-8576: Set EloquaHardBounce  date to blank when Email is changed</description>
        <field>EloquaHardBounce__c</field>
        <name>SetEloquaHardBounceToBlank</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetInactiveReasonToNone</fullName>
        <description>Set Inactive Reason to &quot;None&quot;</description>
        <field>InactiveReason__c</field>
        <name>Set InactiveReason To None</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateDoNotCallTimestamp</fullName>
        <description>SFDC1-9980:Update &quot;Do Not Call Timestamp&quot; when Do Not Call flag is checked or unchecked.</description>
        <field>DoNotCallTimestamp__c</field>
        <formula>NOW()</formula>
        <name>UpdateDoNotCallTimestamp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Outreach_Optout</fullName>
        <field>OutreachOptOut__c</field>
        <literalValue>1</literalValue>
        <name>Update Outreach Optout</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Outreach_Optout_to_False</fullName>
        <field>OutreachOptOut__c</field>
        <literalValue>0</literalValue>
        <name>Update Outreach Optout to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>VCSetScreeningTriggerTrue</fullName>
        <description>SFDC-1764 Set Screening trigger true</description>
        <field>VCScreeningTrigger__c</field>
        <literalValue>1</literalValue>
        <name>VCSetScreeningTriggerTrue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>VCUpdateRPSStatusPending</fullName>
        <description>SFDC-1764 Update RPS Status as blank if contact email changes from @ihsmarkit.com, @markit.com, @ihs.com, @ipreo.com, @polk.com, @mserv.com, @invalid.com to other email ID</description>
        <field>VCRestrictedPartyScreening_Status__c</field>
        <formula>&quot;Pending&quot;</formula>
        <name>VCUpdateRPSStatusPending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>VCUpdateRestrictedPartyScreeningStatus</fullName>
        <description>SFDC-1764 Update Restricted Party Screen Status</description>
        <field>VCRestrictedPartyScreening_Status__c</field>
        <formula>&quot;Not Required&quot;</formula>
        <name>VCUpdateRestrictedPartyScreeningStatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>EmailOptOutChangeResult</fullName>
        <actions>
            <name>EmailOptOutChangeResult</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC1- 452, WF rule changes the Date/time field when record created or Email Opt out changes</description>
        <formula>OR(AND(ISNEW(),NOT(ISPICKVAL(EmailOptOut__c,&quot;&quot;))), ISCHANGED( EmailOptOut__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>OutreachOptOutField update</fullName>
        <actions>
            <name>Update_Outreach_Optout</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(NOT(ISPICKVAL(EmailOptOut__c, &quot;&quot;)),OR(ISNEW(), ISCHANGED( EmailOptOut__c )))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SetEloquaHardBounceToBlankWhenEmailUpdated</fullName>
        <actions>
            <name>SetEloquaHardBounceToBlank</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC1-8576:  Set EloquaHardBounce date to &quot;blank&quot; when Email is changed</description>
        <formula>ISCHANGED(Email)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SetInactiveReasonWhenReactivateContact</fullName>
        <actions>
            <name>SetInactiveReasonToNone</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC1-400 Set InactiveReason to &quot;None&quot; when Contact is re-activated</description>
        <formula>ISPICKVAL (Status__c, &quot;Active&quot;) &amp;&amp; TEXT(InactiveReason__c) != null</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SetScreeningTrueForContacts</fullName>
        <actions>
            <name>VCSetScreeningTriggerTrue</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>VCUpdateRPSStatusPending</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC-1764 Visual Compliance Screening Override for Specific Contacts
SFDC-1723 Visual Compliance. Update Criteria for excludinh IHS contacts for screening</description>
        <formula>AND( NOT(CONTAINS(Email,&quot;@ihsmarkit.com&quot;)), NOT(CONTAINS(Email,&quot;@markit.com&quot;)), NOT(CONTAINS(Email,&quot;@ihs.com&quot;)), NOT(CONTAINS(Email,&quot;@ipreo.com&quot;)), NOT(CONTAINS(Email,&quot;@polk.com&quot;)), NOT(CONTAINS(Email,&quot;@mserv.com&quot;)), NOT(CONTAINS(Email,&quot;@invalid.com&quot;)), TEXT(LegacySystem__c)!=&apos;IHS_MSCRM&apos;, OR( ISNEW(),  ISCHANGED(Email), ISCHANGED(FirstName), ISCHANGED(LastName), ISCHANGED(MailingCountry), ISCHANGED(MailingState), ISCHANGED(MailingCity)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UpdateDoNotCallTimestampWhenDoNotCallCheckedOrUnChed</fullName>
        <actions>
            <name>UpdateDoNotCallTimestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC1-9980:Update &quot;Do Not Call Timestamp&quot; when Do Not Call flag is checked or unchecked.</description>
        <formula>OR( AND(ISNEW(),DoNotCall), AND(NOT(ISNEW()), ISCHANGED(DoNotCall)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UpdateOutreachOptOutFalse</fullName>
        <actions>
            <name>Update_Outreach_Optout_to_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISPICKVAL(EmailOptOut__c, &quot;&quot;),ISCHANGED( EmailOptOut__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UpdateRestrictedPartyScreeningStatus</fullName>
        <actions>
            <name>VCUpdateRestrictedPartyScreeningStatus</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC-1764 Update restricted Party Screen Status
SFDC-1923 Visual Compliance. Updated Rule criteria for IHS contacts</description>
        <formula>OR(  CONTAINS(Email,&quot;@ihsmarkit.com&quot;),  CONTAINS(Email,&quot;@markit.com&quot;),  CONTAINS(Email,&quot;@ihs.com&quot;),  CONTAINS(Email,&quot;@ipreo.com&quot;),  CONTAINS(Email,&quot;@polk.com&quot;),  CONTAINS(Email,&quot;@mserv.com&quot;),  CONTAINS(Email,&quot;@invalid.com&quot;), TEXT(LegacySystem__c)=&apos;IHS_MSCRM&apos; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>