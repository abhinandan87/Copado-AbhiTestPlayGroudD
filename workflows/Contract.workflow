<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>EmailAlertOppOwnerEmailonContractRejection</fullName>
        <description>SFDC1-8759 - Email Alert  to Opportunity Owner Email on Contract Rejection</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <field>OpptyOwnerEmail__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>no-replysfdc@ihsmarkit.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/OpportunityOwnerEmailonContractRejection</template>
    </alerts>
    <alerts>
        <fullName>SendEmailtoOpportunityOwneronContractCancellation</fullName>
        <description>SendEmailtoOpportunityOwneronContractCancellation</description>
        <protected>false</protected>
        <recipients>
            <field>OpptyOwnerEmail__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/OpptyOwnerEmailonContractCancellation</template>
    </alerts>
    <fieldUpdates>
        <fullName>ContractDefaultNamingForNDAAndMasterAgre</fullName>
        <description>SFDC1-7518: Update Name on Contract for NDA and MasterAgreement Contracts
SFDC1-7582: Updating date format to include month in text value.
SFDC1-8270: limiting characters to 80
SFDC1-8523: updated formula to show blank for blank date</description>
        <field>Name</field>
        <formula>LEFT(Account.Name + &apos; &apos; + RecordType.Name +&apos; &apos;+ IF(NOT(ISBLANK(EffectiveDate__c )), (TEXT(DAY(EffectiveDate__c ))+&apos;-&apos;+(CASE(MONTH(EffectiveDate__c ), 
1, &quot;Jan&quot;, 
2, &quot;Feb&quot;, 
3, &quot;Mar&quot;, 
4, &quot;Apr&quot;, 
5, &quot;May&quot;, 
6, &quot;Jun&quot;, 
7, &quot;Jul&quot;, 
8, &quot;Aug&quot;, 
9, &quot;Sep&quot;, 
10, &quot;Oct&quot;, 
11, &quot;Nov&quot;, 
12, &quot;Dec&quot;, 
&quot;None&quot;))+&apos;-&apos;+TEXT(YEAR(EffectiveDate__c ))), &apos;&apos;), 80)</formula>
        <name>ContractDefaultNamingForNDAAndMasterAgre</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ContractNameUpdate</fullName>
        <description>SFDC1-5827: Populate contract name field on contracts by default
SFDC1-7582: Updating date format to include month in text value.
SFDC1-8270: limiting characters to 80
SFDC1-8523: updated formula to show blank for blank date</description>
        <field>Name</field>
        <formula>LEFT(Account.Name + &apos; &apos; + RecordType.Name +&apos; &apos;+ IF(NOT(ISBLANK(StartDate)), (TEXT(DAY(StartDate))+&apos;-&apos;+(CASE(MONTH(StartDate), 
1, &quot;Jan&quot;, 
2, &quot;Feb&quot;, 
3, &quot;Mar&quot;, 
4, &quot;Apr&quot;, 
5, &quot;May&quot;, 
6, &quot;Jun&quot;, 
7, &quot;Jul&quot;, 
8, &quot;Aug&quot;, 
9, &quot;Sep&quot;, 
10, &quot;Oct&quot;, 
11, &quot;Nov&quot;, 
12, &quot;Dec&quot;, 
&quot;None&quot;))+&apos;-&apos;+TEXT(YEAR(StartDate))), &apos;&apos;), 80)</formula>
        <name>ContractNameUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ContractProductGroupToProductGroupShort</fullName>
        <description>SFDC-208 Moves 255 characters of the product group field to the product group short field.
SFDC-897 Include only the first 255 characters when copying &quot;Product Group&quot; value to &quot;Product Group (Short)&quot;</description>
        <field>ProductGroupShort__c</field>
        <formula>LEFT(ProductGroup__c, 255)</formula>
        <name>ContractProductGroupToProductGroupShort</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ContractStatusUpdateToSubmitted</fullName>
        <description>SFDC1-8018:Update Contract Status to Submitted when Stage is moved to “Ready for Processing”</description>
        <field>ContractStatus__c</field>
        <literalValue>Submitted</literalValue>
        <name>ContractStatusUpdateToSubmitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>OrderFormDeliveredtoCustomer</fullName>
        <description>SFDC-29 - Contract Status Updates</description>
        <field>ContractStatus__c</field>
        <literalValue>Delivered to Customer</literalValue>
        <name>OrderFormDeliveredtoCustomer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PopulateDefaultEmailBodyOnContLetter</fullName>
        <description>SFDC-117: Workflow field update to populate default email body on continuation letter contract</description>
        <field>EmailBody__c</field>
        <formula>&quot;Please note that your subscription is about to expire. In order to prevent your access from being discontinued, please find attached the IHS Markit Continuation Letter. Request you to please sign the letter electronically. If you have any questions, please do not hesitate to contact us.&quot;</formula>
        <name>PopulateDefaultEmailBodyOnContLetter</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PopulateDefaultSubjectOnContLetter</fullName>
        <description>SFDC-117: Workflow field update to populate default subject on continuation letter contract</description>
        <field>Subject__c</field>
        <formula>Account.Name + &apos; - Continuation Letter &apos;+ ContractNumber</formula>
        <name>PopulateDefaultSubjectOnContLetter</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetChannelPartnerAccountName</fullName>
        <description>SFDC-1785 copy channel partner name from related opportunity</description>
        <field>ChannelPartnerName__c</field>
        <formula>Opportunity__r.ChannelPartner__r.Name</formula>
        <name>SetChannelPartnerAccountName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetChannelPartnerAddressCity</fullName>
        <description>SFDC-1358 Set channel partner address city from related opportunity channel partner</description>
        <field>GlobalAllianceAddressCity__c</field>
        <formula>Opportunity__r.ChannelPartner__r.BillingCity</formula>
        <name>SetChannelPartnerAddressCity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetChannelPartnerAddressCountry</fullName>
        <description>SFDC-1785 Set the channel partner address country from related opportunity</description>
        <field>GlobalAllianceAddressCountry__c</field>
        <formula>Opportunity__r.ChannelPartner__r.BillingCountry</formula>
        <name>SetChannelPartnerAddressCountry</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetChannelPartnerAddressState</fullName>
        <description>SFDC-1785 Channel partner address state populated from related opportunity channel partner</description>
        <field>GlobalAllianceAddressStateProvince__c</field>
        <formula>Opportunity__r.ChannelPartner__r.BillingState</formula>
        <name>SetChannelPartnerAddressState</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetChannelPartnerAddressStreet</fullName>
        <description>SFDC-1785 Channel partner address street from related opportunity channel partner account</description>
        <field>GlobalAllianceAddressStreet__c</field>
        <formula>Opportunity__r.ChannelPartner__r.BillingStreet</formula>
        <name>SetChannelPartnerAddressStreet</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetChannelPartnerAddressZip</fullName>
        <description>SFDC-1785 Set channel partner zip code from related opportunity channel partner</description>
        <field>GlobalAllianceAddressPostalZipCode__c</field>
        <formula>Opportunity__r.ChannelPartner__r.BillingPostalCode</formula>
        <name>SetChannelPartnerAddressZip</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetContractStageAsComplete</fullName>
        <description>SFDC1-8533 Convert Process Builder flow 1) &quot;Contract Update&quot; created in SFDC1-6503 on Contract object to a trigger/workflow. Status Field Update.</description>
        <field>Status</field>
        <literalValue>Complete</literalValue>
        <name>SetContractStageAsComplete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetContractStageAsCreation</fullName>
        <description>SFDC1-8533 Convert Process Builder flow &quot;UpdateContractStagebasedOnContractStatus&quot; created in SFDC1-5403+SFDC1-7187 on Contract object to a trigger/workflow. Field Update.</description>
        <field>Status</field>
        <literalValue>Creation</literalValue>
        <name>SetContractStageAsCreation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetContractStatusToExpired</fullName>
        <description>SFDC-1397 set Contract Status to &quot;Expired&quot;</description>
        <field>ContractStatus__c</field>
        <literalValue>Expired</literalValue>
        <name>SetContractStatusToExpired</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetCumulativeContractValueOnContract</fullName>
        <description>SFDC1-8533: Convert Process Flow &quot;Update Cumulative Contract Field with Default To Total Contract Value&quot; to trigger/Workflow. Parent Story SFDC1-5864. Field update to set Cumulative Contract Value on contract.</description>
        <field>AllAssociatedTotalOpportunityValue__c</field>
        <formula>TotalContractValue__c</formula>
        <name>SetCumulativeContractValueOnContract</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SetStageTo11</fullName>
        <description>SFDC 2037 : Update the stage field on contract to 11</description>
        <field>Status</field>
        <literalValue>Complete</literalValue>
        <name>Set stage to 11</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>StatusUpdateMasterAgreement</fullName>
        <description>SFDC-1453 - Master Agreement: Process Updates</description>
        <field>Status</field>
        <literalValue>ReadyForProcessing</literalValue>
        <name>StatusUpdateMasterAgreement</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>StatusUpdateTPA</fullName>
        <description>SFDC - 1087 - Third Party Processor Agreement</description>
        <field>ContractStatus__c</field>
        <literalValue>Validated</literalValue>
        <name>StatusUpdateTPA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>StatusUpdateTPA1</fullName>
        <description>SFDC - 1087 - Third Party Processor Agreement</description>
        <field>Status</field>
        <literalValue>Complete</literalValue>
        <name>StatusUpdateTPA1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateAgreementEffectiveDate</fullName>
        <description>SFDC1-5851 If &quot;General Agreement&quot; is populated on order form contract pull effective date from that contract and populate as &quot;Agreement Effective date&quot; on order form</description>
        <field>GeneralAgreementDate__c</field>
        <formula>GeneralAgreement__r.EffectiveDate__c</formula>
        <name>UpdateAgreementEffectiveDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateContractRejectionPastDueCheck</fullName>
        <description>SFDC1-7488 : Update ContractRejectionPastDue__c checkbox</description>
        <field>ContractRejectionPastDue__c</field>
        <literalValue>1</literalValue>
        <name>Update Contract Rejection Past Due Check</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateContractStatus</fullName>
        <description>SFDC1-6504 Update the Contract Status to &quot;Sent to OM/Delivery&quot;
SFDC1-7584 Update the Contract Status to &quot;Submitted&quot;</description>
        <field>ContractStatus__c</field>
        <literalValue>Submitted</literalValue>
        <name>UpdateContractStatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateContractStatusToValidated</fullName>
        <description>SFDC-1429 Update Contract Status to &quot;Validated&quot;</description>
        <field>ContractStatus__c</field>
        <literalValue>Validated</literalValue>
        <name>UpdateContractStatusToValidated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateFlagSalesOpsRecog</fullName>
        <description>SFDC 674 Sales Recognition Flag fields</description>
        <field>RecognitionFlagDate__c</field>
        <formula>now()</formula>
        <name>UpdateFlagSalesOpsRecog</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateFlagSalesOpsRecog2</fullName>
        <description>SFDC 674 Sales Recognition Flag fields</description>
        <field>RecognitionFlagDate__c</field>
        <name>UpdateFlagSalesOpsRecog2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateGlobalAllianceCity</fullName>
        <description>SFDC1-8533 Convert Process Builder flow &quot;Update Global Alliance Information on Contract&quot; on Contract object created in SFDC1-5260(Update Global Alliance Information on Contract from Opportunity Channel Partner) to a trigger/workflow. Field update.</description>
        <field>GlobalAllianceAddressCity__c</field>
        <formula>Opportunity__r.ChannelPartner__r.BillingCity</formula>
        <name>UpdateGlobalAllianceCity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateGlobalAllianceCountry</fullName>
        <description>SFDC1-8533 Convert Process Builder flow &quot;Update Global Alliance Information on Contract&quot; on Contract object created in SFDC1-5260(Update Global Alliance Information on Contract from Opportunity Channel Partner) to a trigger/workflow. Field update.</description>
        <field>GlobalAllianceAddressCountry__c</field>
        <formula>Opportunity__r.ChannelPartner__r.BillingCountry</formula>
        <name>UpdateGlobalAllianceCountry</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateGlobalAllianceState</fullName>
        <description>SFDC1-8533 Convert Process Builder flow &quot;Update Global Alliance Information on Contract&quot; on Contract object created in SFDC1-5260(Update Global Alliance Information on Contract from Opportunity Channel Partner) to a trigger/workflow. Field update.</description>
        <field>GlobalAllianceAddressStateProvince__c</field>
        <formula>Opportunity__r.ChannelPartner__r.BillingState</formula>
        <name>UpdateGlobalAllianceState</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateGlobalAllianceStreet</fullName>
        <description>SFDC1-8533 Convert Process Builder flow &quot;Update Global Alliance Information on Contract&quot; on Contract object created in SFDC1-5260(Update Global Alliance Information on Contract from Opportunity Channel Partner) to a trigger/workflow. Field update.</description>
        <field>GlobalAllianceAddressStreet__c</field>
        <formula>Opportunity__r.ChannelPartner__r.BillingStreet</formula>
        <name>UpdateGlobalAllianceStreet</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateGlobalAllianceZipcode</fullName>
        <description>SFDC1-8533 Convert Process Builder flow &quot;Update Global Alliance Information on Contract&quot; on Contract object created in SFDC1-5260(Update Global Alliance Information on Contract from Opportunity Channel Partner) to a trigger/workflow. Field update.</description>
        <field>GlobalAllianceAddressPostalZipCode__c</field>
        <formula>Opportunity__r.ChannelPartner__r.BillingPostalCode</formula>
        <name>UpdateGlobalAllianceZipcode</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateStageToCompleted</fullName>
        <description>SFDC-1429 Update Contract Stage to &quot;11-Completed&quot;</description>
        <field>Status</field>
        <literalValue>Complete</literalValue>
        <name>UpdateStageToCompleted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>setChannelParnterBPNumber</fullName>
        <description>SFDC-1785 Set channel partner BP number from related opportunity channel partner</description>
        <field>ChannelPartnerBPNumber__c</field>
        <formula>Opportunity__r.ChannelPartner__r.BP__c</formula>
        <name>setChannelParnterBPNumber</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Contract Rejection Past Due Check</fullName>
        <active>true</active>
        <booleanFilter>(1 OR 4) AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Contract.RecordTypeId</field>
            <operation>equals</operation>
            <value>Order Form</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.ContractRejectionPastDue__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.ContractStatus__c</field>
            <operation>equals</operation>
            <value>Rejected</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.RecordTypeId</field>
            <operation>equals</operation>
            <value>Consulting</value>
        </criteriaItems>
        <description>SFDC1-7488 # : count # of days since Contract Status = Rejected, SFDC1-8959 Adding Consulting record type</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>UpdateContractRejectionPastDueCheck</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>10</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>ContractDefaultNaming</fullName>
        <actions>
            <name>ContractNameUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC1-5827: Populate contract name field on contracts by default
SFDC1-7518:  Skip default naming for NDA and MasterAgreement Contracts
SFDC1-8523: Skipping for DPA Contract</description>
        <formula>AND(NOT(ISBLANK(RecordTypeId)), NOT(CONTAINS(RecordType.DeveloperName, &quot;NDA&quot;)),  NOT(CONTAINS(RecordType.DeveloperName, &quot;DPA&quot;)),  NOT(CONTAINS(RecordType.DeveloperName, &quot;MasterAgreement&quot;)), NOT(CONTAINS(RecordType.DeveloperName, &quot;ManagedServiceTerms&quot;)))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ContractDefaultNamingForNDAAndMasterAgreement</fullName>
        <actions>
            <name>ContractDefaultNamingForNDAAndMasterAgre</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC1-7518: Default naming for NDA and MasterAgreement Contracts
SFDC1-8523: Added default naming for DPA contract</description>
        <formula>AND(NOT(ISBLANK(RecordTypeId)), OR(CONTAINS(RecordType.DeveloperName, &quot;NDA&quot;), CONTAINS(RecordType.DeveloperName, &quot;MasterAgreement&quot;),   CONTAINS(RecordType.Name, &quot;DPA&quot;),   CONTAINS(RecordType.DeveloperName, &quot;ManagedServiceTerms&quot;)))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ContractStatusUpdateToSubmitted</fullName>
        <actions>
            <name>ContractStatusUpdateToSubmitted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC1-8018:Update Contract Status to Submitted when Stage is moved to “Ready for Processing”</description>
        <formula>IF( ISCHANGED(Status) &amp;&amp; ISPICKVAL(Status,&apos;ReadyForProcessing&apos;),  IF(OR(ISPICKVAL(ContractStatus__c,&apos;Sent to Customer&apos;),ISPICKVAL(ContractStatus__c,&apos;Signed By Customer&apos;)),false,true),   false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>MoveContractToCompleted</fullName>
        <actions>
            <name>UpdateContractStatusToValidated</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateStageToCompleted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contract.RecordTypeId</field>
            <operation>equals</operation>
            <value>Master Agreement,Trial,Master Agreement Exhibit</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.CountersignatureStatus__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <description>SFDC 1453 - Master Agreement: Process Updates 
SFDC-1429 - Trial: Update process that moves Stage to 11-Completed</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>NotifyOppOwnerContractChangedToRejected</fullName>
        <actions>
            <name>EmailAlertOppOwnerEmailonContractRejection</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Contract.ContractStatus__c</field>
            <operation>equals</operation>
            <value>Rejected</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.RecordTypeId</field>
            <operation>equals</operation>
            <value>Order Form,Consulting</value>
        </criteriaItems>
        <description>SFDC1-8759: Sending email notification to Opportunity Owner when Contract status is changed to Rejected.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>OrderFormContractStatusUpdate</fullName>
        <actions>
            <name>UpdateContractStatus</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC1-6504 When an &apos;Order Form&apos; stage is put to Ready for Processing, update the &apos;Status&apos; to &apos;Sent to OM/Delivery&apos;</description>
        <formula>AND ( RecordType.Name == &apos;Order Form&apos;, ISCHANGED(Status), ISPICKVAL(Status, &apos;ReadyForProcessing&apos;)  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>OrderFormDeliveredtoCustomer</fullName>
        <actions>
            <name>OrderFormDeliveredtoCustomer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contract.RecordTypeId</field>
            <operation>equals</operation>
            <value>Order Form</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.SAPPGId__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <description>SFDC 29 - Contract Status Updates</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>PopulateAgreementEffectiveDateOnOrderForm</fullName>
        <actions>
            <name>UpdateAgreementEffectiveDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC1-5851 If &quot;General Agreement&quot; is populated on order form contract pull effective date from that contract and populate as &quot;Agreement Effective date&quot; on order form</description>
        <formula>AND ( OR (RecordType.Name == &apos;Order Form&apos;, RecordType.Name == &apos;Master Agreement Exhibit&apos; ), NOT(ISBLANK(GeneralAgreement__c )), OR ( ISCHANGED(GeneralAgreement__c), ISNEW()) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>PopulateChannelPartnerAccountFields</fullName>
        <actions>
            <name>SetChannelPartnerAccountName</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SetChannelPartnerAddressCity</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SetChannelPartnerAddressCountry</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SetChannelPartnerAddressState</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SetChannelPartnerAddressStreet</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>SetChannelPartnerAddressZip</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>setChannelParnterBPNumber</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC-1785 Populate order-form based on the information from channel partner on related channel  partner account</description>
        <formula>AND( RecordTypeName__c == &apos;Order Form&apos;,       NOT (ISNULL (Opportunity__r.ChannelPartner__c)) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>PopulateDefaultSubjectAndEmailBodyOnContinuationLetter</fullName>
        <actions>
            <name>PopulateDefaultEmailBodyOnContLetter</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>PopulateDefaultSubjectOnContLetter</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contract.RecordTypeName__c</field>
            <operation>equals</operation>
            <value>Continuation Letter</value>
        </criteriaItems>
        <description>SFDC-117: Workflow to populate default subject and email body on continuation letter contract creation</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>ProductGroupToProductGroupShort</fullName>
        <actions>
            <name>ContractProductGroupToProductGroupShort</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC-208. Moves 255 characters of the product group to the product group (short) field.</description>
        <formula>OR(  ISNEW(),  ISCHANGED(ProductGroup__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SendEmailToOppOwnerOnContractCancellationRule</fullName>
        <actions>
            <name>SendEmailtoOpportunityOwneronContractCancellation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>SFDC1-8533 Convert Process Builder flow &quot;SendNotificationtoOpportunityOwneronContractCancellation&quot; on Contract object created in SFDC1-802 to a trigger. This workflow sends email to Opp Owner.</description>
        <formula>AND( NOT(ISNULL( Opportunity__c )), NOT(ISNULL( CancelRequestReceivedDate__c )),  ISCHANGED(CancelRequestReceivedDate__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SetContractStageCompleteRule</fullName>
        <actions>
            <name>SetContractStageAsComplete</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Contract.ContractStatus__c</field>
            <operation>equals</operation>
            <value>Executed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.RecordTypeId</field>
            <operation>equals</operation>
            <value>NDA,Master Agreement</value>
        </criteriaItems>
        <description>SFDC1-8533 Convert Process Builder flow 1) &quot;Contract Update&quot; created in SFDC1-6503 on Contract object to a trigger/workflow.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SetStatusToExpiredForNonRecurringContract</fullName>
        <active>true</active>
        <description>SFDC-1397 set Contract Status to &quot;Expired&quot; for non-recurring contract</description>
        <formula>ISPICKVAL(RenewalTerm__c, &apos;One-time Expiring&apos;)  &amp;&amp; ISPICKVAL(Status, &apos;Complete&apos;) &amp;&amp; NOT(ISPICKVAL(ContractStatus__c, &apos;Expired&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>SetContractStatusToExpired</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Contract.EndDate</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>StatusUpdateTPA</fullName>
        <actions>
            <name>StatusUpdateTPA</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>StatusUpdateTPA1</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contract.RecordTypeName__c</field>
            <operation>equals</operation>
            <value>Third Party Processor Agreement</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.CountersignatureStatus__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <description>SFDC - 1087 - Third Party Processor Agreement</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UpdateContractStageOnContractRejectionRule</fullName>
        <actions>
            <name>SetContractStageAsCreation</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC1-8533 Convert Process Builder flow &quot;UpdateContractStagebasedOnContractStatus&quot; created in SFDC1-5403+SFDC1-7187 on Contract object to a trigger/workflow.</description>
        <formula>AND(  RecordType.DeveloperName = &quot;OrderForm&quot;,    ISPICKVAL(ContractStatus__c, &quot;Rejected&quot;),   OR(   Opportunity__r.RecordType.DeveloperName = &quot;NewBusiness&quot;,   Opportunity__r.RecordType.DeveloperName = &quot;Renewal&quot;  ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UpdateCumulativeContractValue</fullName>
        <actions>
            <name>SetCumulativeContractValueOnContract</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC1-8533: Convert Process Flow &quot;Update Cumulative Contract Field with Default To Total Contract Value&quot; to trigger/Workflow. Parent Story SFDC1-5864. Workflow rule to update Cumulative Contract Value on contract.</description>
        <formula>AND(    AutoRenewal__c,    ISPICKVAL(Status, &quot;Creation&quot;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UpdateFlagSalesOpsRecog</fullName>
        <actions>
            <name>UpdateFlagSalesOpsRecog</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contract.SalesRecognitionFlag__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>SFDC 674 - Sales Recognition Flag fields</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UpdateFlagSalesOpsRecog2</fullName>
        <actions>
            <name>UpdateFlagSalesOpsRecog2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contract.SalesRecognitionFlag__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>SFDC 674 Sales Recognition Flag fields</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UpdateGlobalAllianceInfoOnContractRule</fullName>
        <actions>
            <name>UpdateGlobalAllianceCity</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateGlobalAllianceCountry</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateGlobalAllianceState</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateGlobalAllianceStreet</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>UpdateGlobalAllianceZipcode</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>SFDC1-8533 Convert Process Builder flow &quot;Update Global Alliance Information on Contract&quot; on Contract object created in SFDC1-5260(Update Global Alliance Information on Contract from Opportunity Channel Partner) to a trigger/workflow.</description>
        <formula>AND(   NOT(ISNULL( Opportunity__c )),   ISPICKVAL( Opportunity__r.SubType__c , &quot;Global Alliance&quot;),   NOT(ISNULL( Opportunity__r.ChannelPartner__c )) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>UpdateStageTo11ForContinuation</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Contract.RecordTypeId</field>
            <operation>equals</operation>
            <value>Continuation Letter</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contract.Status</field>
            <operation>equals</operation>
            <value>ReadyForProcessing</value>
        </criteriaItems>
        <description>SFDC - 2037 : One day after Contract is moved to Stage 10 - Ready for Processing set the stage to 11.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>SetStageTo11</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>