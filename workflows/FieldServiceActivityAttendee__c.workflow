<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>FSASurveyEmailTemplate</fullName>
        <description>FSASurveyEmailTemplate</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CSCustomerCare/TrainingAssessmentSurveyResponseTemplate</template>
    </alerts>
    <rules>
        <fullName>FSAAttendeesSurveyResponseTemplate</fullName>
        <actions>
            <name>FSASurveyEmailTemplate</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>FieldServiceActivityAttendee__c.IsFSADeliveryStatus__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.ActivityType__c</field>
            <operation>equals</operation>
            <value>Customer Training</value>
        </criteriaItems>
        <criteriaItems>
            <field>WorkOrder.DoNotSendSurvey__c</field>
            <operation>notEqual</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>