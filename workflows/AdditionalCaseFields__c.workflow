<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>PopulateACFValidatedInCase</fullName>
        <description>SFDC1-9276 : update Case &amp;apos;Is ACF Validated ?&amp;apos; when ACF is Updated.This will validate ACF before Case Closure</description>
        <field>IsACFValidated__c</field>
        <literalValue>1</literalValue>
        <name>PopulateACFValidatedInCase</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>Case__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PopulateLastDateAssigned</fullName>
        <description>SFDC-1852 Last Date Assigned populated</description>
        <field>LastDateAssigned__c</field>
        <formula>now()</formula>
        <name>PopulateLastDateAssigned</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PopulateTimeSpentByContactOnCase</fullName>
        <description>SFDC-1852 Populating time spent by Contact on case to close</description>
        <field>TimewithProviderHrs__c</field>
        <formula>TEXT(FLOOR((now() - LastDateAssigned__c)*24))&amp;&quot; Hours &quot; &amp;
TEXT(ROUND(MOD((now()- LastDateAssigned__c)*1440,60),0) 
) &amp;&quot; Mins &quot;</formula>
        <name>PopulateTimeSpentByContactOnCase</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RemoveProductVersion</fullName>
        <description>SFDC1-6721: Remove Product Version when Delivery Mechanism is File, Adapter, API, Web and record type is Legacy Distribution</description>
        <field>ProductVersion__c</field>
        <name>Remove Product Version</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateCaseWithACFLastModifiedDate</fullName>
        <description>SFDC1-5513: When additional Case field is modified and is satisfying certain conditions, then update Last ACF Modified Date with current time.</description>
        <field>LastACFModifiedDate__c</field>
        <formula>NOW()</formula>
        <name>Update Case With ACF Last Modified Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>Case__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateEnvironment</fullName>
        <description>SFDC1-3444: Update Environment to Production as default value</description>
        <field>Environment__c</field>
        <literalValue>Production</literalValue>
        <name>UpdateEnvironment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CalculatingTimeSpentByProvider</fullName>
        <actions>
            <name>PopulateTimeSpentByContactOnCase</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC-1852 Calculating Time spent by provider</description>
        <formula>AND(  NOT(ISBLANK(ThirdPartyContact__c)), ThirdPartyCompletedTask__c = TRUE )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CustomerCaseColdCaseACFChange</fullName>
        <actions>
            <name>UpdateCaseWithACFLastModifiedDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC1:5513- When ACF and case satisfies a certain criteria and any field in the ACF gets changed, then Last modified date in case should be updated. So, that time based WF will be updated.</description>
        <formula>AND( Case__r.RecordType.Name == &apos;Customer Care&apos;, LEFT( Case__r.OwnerId,3) = &apos;00G&apos; , NOT(Case__r.IsClosed), NOT(ISPICKVAL(LongTermProjectType__c ,&apos;Yes&apos;)), NOT(OR( ISPICKVAL( Case__r.Subtype__c ,&apos;Bug Report&apos;), ISPICKVAL( Case__r.Subtype__c ,&apos;Product Enhancement&apos;))))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>DefaultEnvironmentValue</fullName>
        <actions>
            <name>UpdateEnvironment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>AdditionalCaseFields__c.Environment__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>SFDC1-3444: Set default value of Environment field to Production</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PopulateLastDateAssigned</fullName>
        <actions>
            <name>PopulateLastDateAssigned</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC-1852 Last Date Assigned populated when Provider Contact entered</description>
        <formula>AND( ISCHANGED(ThirdPartyContact__c), NOT(ISBLANK(ThirdPartyContact__c)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>RemoveProductVersionForFewDeliveryMechanism</fullName>
        <actions>
            <name>RemoveProductVersion</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>AdditionalCaseFields__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Legacy Distribution</value>
        </criteriaItems>
        <criteriaItems>
            <field>AdditionalCaseFields__c.DeliveryMechanism__c</field>
            <operation>contains</operation>
            <value>Adaptors,API,File,Web</value>
        </criteriaItems>
        <description>SFDC1-6721:Product Version should not appear for some Delivery Mechanisms in Legacy Distribution</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>UpdateCaseIsACFValidatedOnACFUpdate</fullName>
        <actions>
            <name>PopulateACFValidatedInCase</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC1-9276 : update Case &amp;apos;Is ACF Validated ?&amp;apos; when ACF is Updated.This will validate ACF before Case Closure</description>
        <formula>NOT(ISNEW()) &amp;&amp;  NOT(Case__r.IsClosed)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>