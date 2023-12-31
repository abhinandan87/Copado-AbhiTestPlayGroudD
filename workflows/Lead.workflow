<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EmailAlertForLeadAssignment</fullName>
        <description>Email Alert For Lead Assignment</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>no-replysfdc@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CorporateMailTemplates/LeadAssignmentTemplateforFlowsv2</template>
    </alerts>
    <alerts>
        <fullName>NotifyLeadOwnerOfAccountCreation</fullName>
        <description>SFDC1-965 Notify lead owner of account creation</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/LeadIsReadyToConvert</template>
    </alerts>
    <fieldUpdates>
        <fullName>RatingField1</fullName>
        <description>SFDC1-998; Rating field is populated with 1</description>
        <field>Rating</field>
        <literalValue>1</literalValue>
        <name>RatingField1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RatingField2</fullName>
        <description>SFDC1-998; Rating field is populated with 2</description>
        <field>Rating</field>
        <literalValue>2</literalValue>
        <name>RatingField2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RatingField3</fullName>
        <description>SFDC1-998; Rating field is populated with 3</description>
        <field>Rating</field>
        <literalValue>3</literalValue>
        <name>RatingField3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RatingField4</fullName>
        <description>SFDC1-998; Rating field is populated with 4</description>
        <field>Rating</field>
        <literalValue>4</literalValue>
        <name>RatingField4</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>RatingPopulated5</fullName>
        <description>SFDC1-998; Rating field is populated by 5</description>
        <field>Rating</field>
        <literalValue>5</literalValue>
        <name>RatingPopulated5</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateFirstTouchPreSales</fullName>
        <description>SFDC1-1759 Update current date time in First Touch - Pre-Sales field</description>
        <field>FirstTouchPreSales__c</field>
        <formula>Now()</formula>
        <name>Update First Touch - Pre-Sales</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateFirstTouchSales</fullName>
        <description>SFDC1-1759 Update current date time in First Touch - Sales field</description>
        <field>FirstTouchSales__c</field>
        <formula>NOW()</formula>
        <name>Update First Touch Sales</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>LeadRatingStarMapping1</fullName>
        <actions>
            <name>RatingField1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR (2 AND (3 OR 4))</booleanFilter>
        <criteriaItems>
            <field>Lead.LDScriptScore__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.RequestedInteraction__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.CallToActionType__c</field>
            <operation>equals</operation>
            <value>Event Registration,Newsletter Subscribe,Other</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.CallToActionType__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>SFDC1-998 Star Rating field is populated by different criteria with lead fields
SFDC-1444 Bug fixes: when CTA Type is Null, Rating should be set to 1;
also when CTA Type is &quot;Watch Recorded Webcast&quot;, Rating should be set to 2, not 1</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LeadRatingStarMapping2</fullName>
        <actions>
            <name>RatingField2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR (2 AND 3)</booleanFilter>
        <criteriaItems>
            <field>Lead.LDScriptScore__c</field>
            <operation>equals</operation>
            <value>2</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.RequestedInteraction__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.CallToActionType__c</field>
            <operation>equals</operation>
            <value>Download Sample Report/Data/Map,Download Whitepaper/Case Study,Internal Form Submission - Cool,Watch Recorded Webcast</value>
        </criteriaItems>
        <description>SFDC1-998 Star Rating field is populated by different criteria with lead fields</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LeadRatingStarMapping3</fullName>
        <actions>
            <name>RatingField3</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR (2 AND 3)</booleanFilter>
        <criteriaItems>
            <field>Lead.LDScriptScore__c</field>
            <operation>equals</operation>
            <value>3</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.RequestedInteraction__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.CallToActionType__c</field>
            <operation>equals</operation>
            <value>Analyst/Research Submissions,Internal Form Submission,Request for Information</value>
        </criteriaItems>
        <description>SFDC1-998 Star Rating field is populated by different criteria with lead fields</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LeadRatingStarMapping4</fullName>
        <actions>
            <name>RatingField4</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR (2 AND 4) OR (5 AND 3)</booleanFilter>
        <criteriaItems>
            <field>Lead.LDScriptScore__c</field>
            <operation>equals</operation>
            <value>4</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.RequestedInteraction__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.RequestedInteraction__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.CallToActionType__c</field>
            <operation>equals</operation>
            <value>Contact Analyst/Expert,Contact Sales or Request Quote/Exploratory Meeting,Contact Us Request,Internal Form Submission - Hot,Request Free Trial or Demo</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.LDScriptScore__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>SFDC1-998 Star Rating field is populated by different criteria with lead fields</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LeadRatingStarMapping5</fullName>
        <actions>
            <name>RatingPopulated5</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.LDScriptScore__c</field>
            <operation>equals</operation>
            <value>5</value>
        </criteriaItems>
        <description>SFDC1-998 Star Rating field is populated by different criteria with lead fields</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>NotifyLeadOwnerOnAccountFieldPopulation</fullName>
        <actions>
            <name>NotifyLeadOwnerOfAccountCreation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>SFDC1-965 Notify Account owner when the Account field gets populated on case closure</description>
        <formula>AND(Account__c &lt;&gt; NULL, PRIORVALUE(Account__c)==NULL)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PopulateFirstTouchPreSalesOnStatusChange</fullName>
        <actions>
            <name>UpdateFirstTouchPreSales</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC1-1759 First Touch Pre-sales should be populated the first time the Status is changed by someone with the Marketing Profile.</description>
        <formula>AND( NOT(ISNEW()), ISCHANGED(Status), ISBLANK(FirstTouchPreSales__c), ($Profile.Name == &apos;IHSMarkit Sales: Marketing&apos;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PopulateFirstTouchSalesOnStatusChange</fullName>
        <actions>
            <name>UpdateFirstTouchSales</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC1-1759 First Touch Sales should be populated the first time the Status is changed by someone with the Sales Ops Profile.</description>
        <formula>AND( 	NOT(ISNEW()), 	ISCHANGED(Status), 	ISBLANK(FirstTouchSales__c), 	CONTAINS($Profile.Name, &apos;IHSMarkit&apos;),         CONTAINS($Profile.Name, &apos;Sales&apos;), 	OR( 	CONTAINS($Profile.Name, &apos;Global Account Manager&apos;), 	CONTAINS($Profile.Name, &apos;General&apos;) 	) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>