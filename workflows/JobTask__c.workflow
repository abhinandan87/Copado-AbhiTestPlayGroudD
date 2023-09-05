<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ReassignedPLCJobTask</fullName>
        <description>Reassigned PLC Job Task</description>
        <protected>false</protected>
        <recipients>
            <field>AssignedTo__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>WRFPLCTemplates/NewPLCJobTask</template>
    </alerts>
    <fieldUpdates>
        <fullName>ActualHoursDate</fullName>
        <field>ActualHoursDate__c</field>
        <formula>Today ()</formula>
        <name>Actual Hours Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>ActualHoursNotNull</fullName>
        <actions>
            <name>ActualHoursDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>JobTask__c.ActualHours__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>AssignedToIsChanged</fullName>
        <actions>
            <name>ReassignedPLCJobTask</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Email alert to programmer that a job task has been re-assigned.</description>
        <formula>AND( OR (  ISNEW(),  ISCHANGED( AssignedTo__c  ) ), AND(   AssignedTo__c &lt;&gt; NULL,   $User.Id &lt;&gt; AssignedTo__c  ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>