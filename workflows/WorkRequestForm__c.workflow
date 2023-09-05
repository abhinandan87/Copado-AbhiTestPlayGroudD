<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>APACMappingRequest</fullName>
        <ccEmails>nigel.thompson@ihs.com</ccEmails>
        <description>APAC Mapping Request.This is used in WRF POLK.</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>WRFPLCTemplates/WorkRequestFormSubmittedMapping</template>
    </alerts>
    <alerts>
        <fullName>SendEmailtoNewOwner</fullName>
        <description>Send Email to New Owner.This is used in WRF POLK.</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>WRFPLCTemplates/WRFOwnerChange</template>
    </alerts>
    <alerts>
        <fullName>SymbolApprovalrequested</fullName>
        <ccEmails>richard.glover@ihsmarkit.com</ccEmails>
        <description>Symbol Approval is being requested.This is used in WRF POLK.</description>
        <protected>false</protected>
        <recipients>
            <field>PrimarySalesContact__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>SecondarySalesContact__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>WRFPLCTemplates/SymbolApprovalRequested</template>
    </alerts>
    <alerts>
        <fullName>Symbolhasbeenapproved</fullName>
        <description>Symbol has been approved.This is used in WRF POLK.</description>
        <protected>false</protected>
        <recipients>
            <field>PrimarySalesContact__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>SecondarySalesContact__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>WRFPLCTemplates/SymbolApproved</template>
    </alerts>
    <alerts>
        <fullName>TableauVisualizationRequestNotification</fullName>
        <ccEmails>tableau.automotive@ihsmarkit.com</ccEmails>
        <description>Tableau Visualization Request Notification.This is used in WRF POLK.</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>WRFPLCTemplates/TableauVisualization</template>
    </alerts>
    <alerts>
        <fullName>WRFWRFStatusApproved</fullName>
        <description>WRF - WRF Status Form Approved.This is used in WRF POLK.</description>
        <protected>false</protected>
        <recipients>
            <field>PrimarySalesContact__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>SecondarySalesContact__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>WRFPLCTemplates/WRFApproval</template>
    </alerts>
    <alerts>
        <fullName>WRFWRFStatusRejected</fullName>
        <description>WRF - WRF Status Form Rejected.This is used in WRF POLK.</description>
        <protected>false</protected>
        <recipients>
            <field>PrimarySalesContact__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>SecondarySalesContact__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>WRFPLCTemplates/WRFRejected</template>
    </alerts>
    <alerts>
        <fullName>WRFWRFStatusSubmitted</fullName>
        <description>WRF - WRF Status Form Submitted.This is used in WRF POLK.</description>
        <protected>false</protected>
        <recipients>
            <field>PrimarySalesContact__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>SecondarySalesContact__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>WRFPLCTemplates/WRFSubmitted</template>
    </alerts>
    <fieldUpdates>
        <fullName>DateAssignedwithoutApproval</fullName>
        <description>This is used in WRF POLK.</description>
        <field>DateAssignedWithoutApproval__c</field>
        <formula>Today ()</formula>
        <name>Date Assigned without Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SubmittedDateTime</fullName>
        <description>This is used in WRF POLK.</description>
        <field>SubmittedDateTime__c</field>
        <formula>now()</formula>
        <name>Submitted Date/Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SymbolApprovalRequested</fullName>
        <description>This is used in WRF POLK.</description>
        <field>SymbolApprovalRequested__c</field>
        <literalValue>1</literalValue>
        <name>Symbol Approval Requested</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>SymbolApprovalUpdate</fullName>
        <field>SymbolApproved__c</field>
        <literalValue>1</literalValue>
        <name>SymbolApprovalUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Symbolhasbeenapproved</fullName>
        <description>This is used in WRF POLK.</description>
        <field>SymbolApprovalRequested__c</field>
        <literalValue>0</literalValue>
        <name>Symbol has been approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateDUCApprovalDate</fullName>
        <description>This is used in WRF POLK.</description>
        <field>DUCApprovalDate__c</field>
        <formula>TODAY()</formula>
        <name>Update DUC Approval Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateOwnerSubmittedAPACMapping</fullName>
        <description>Also updates the Owner to Jason Pang.This is used in WRF POLK.</description>
        <field>OwnerId</field>
        <lookupValue>APACWRF</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Update Owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateSymbolApprovalDate</fullName>
        <description>This is used in WRF POLK.</description>
        <field>SymbolsApprovedDate__c</field>
        <formula>TODAY()</formula>
        <name>Update Symbol Approval Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>OwnerIsChangedRequestStatusNotDraftOrRejected</fullName>
        <actions>
            <name>SendEmailtoNewOwner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This is used in WRF POLK.</description>
        <formula>OwnerId  &lt;&gt; PRIORVALUE(OwnerId )&amp;&amp;  ( NOT( ISPICKVAL(RequestStatus__c, &quot;Draft&quot;))|| NOT( ISPICKVAL(RequestStatus__c, &quot;Rejected&quot;)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>RequestStatusIsApprovalPending</fullName>
        <actions>
            <name>DateAssignedwithoutApproval</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkRequestForm__c.RequestStatus__c</field>
            <operation>equals</operation>
            <value>Approval Pending</value>
        </criteriaItems>
        <description>This is used in WRF POLK.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RequestStatusIsApproved</fullName>
        <actions>
            <name>WRFWRFStatusApproved</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkRequestForm__c.RequestStatus__c</field>
            <operation>equals</operation>
            <value>Approved</value>
        </criteriaItems>
        <description>This is used in WRF POLK.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RequestStatusIsRejected</fullName>
        <actions>
            <name>WRFWRFStatusRejected</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkRequestForm__c.RequestStatus__c</field>
            <operation>equals</operation>
            <value>Rejected</value>
        </criteriaItems>
        <description>This is used in WRF POLK.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RequestStatusIsSubmitted</fullName>
        <actions>
            <name>WRFWRFStatusSubmitted</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkRequestForm__c.RequestStatus__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <description>This is used in WRF POLK.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>RequestStatusNotDraft</fullName>
        <actions>
            <name>SendEmailtoNewOwner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This is used in WRF POLK.</description>
        <formula>1=1&amp;&amp; NOT( ISPICKVAL(RequestStatus__c, &quot;DRAFT&quot;))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SubmittedAPACMappingIsTrue</fullName>
        <actions>
            <name>APACMappingRequest</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>UpdateOwnerSubmittedAPACMapping</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkRequestForm__c.Mapping__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>WorkRequestForm__c.FormType__c</field>
            <operation>equals</operation>
            <value>APAC</value>
        </criteriaItems>
        <criteriaItems>
            <field>WorkRequestForm__c.RequestStatus__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <description>Email sent to Jason Pang when request type mapping is selected.This is used in WRF POLK.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SubmittedIsTrue</fullName>
        <actions>
            <name>SubmittedDateTime</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkRequestForm__c.IsSubmitted__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>This is used in WRF POLK.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SymbolApprovalRequested</fullName>
        <actions>
            <name>SymbolApprovalrequested</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkRequestForm__c.Symbols__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>WorkRequestForm__c.RequestStatus__c</field>
            <operation>equals</operation>
            <value>Symbol Approval Request</value>
        </criteriaItems>
        <description>This is used in WRF POLK.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SymbolApprovalUpdate</fullName>
        <actions>
            <name>SymbolApprovalUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkRequestForm__c.RequestStatus__c</field>
            <operation>equals</operation>
            <value>Symbol Approved</value>
        </criteriaItems>
        <description>This is used in WRF POLK.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SymbolApprovedAndSymbolApprovedDateIsNull</fullName>
        <actions>
            <name>UpdateSymbolApprovalDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets or Maintains Symbol Approval Date.This is used in WRF POLK.</description>
        <formula>IF( SymbolApproved__c &amp;&amp; ISNULL(SymbolsApprovedDate__c) ,true, false)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SymbolApprovedIsTrue</fullName>
        <actions>
            <name>Symbolhasbeenapproved</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Symbolhasbeenapproved</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkRequestForm__c.RequestStatus__c</field>
            <operation>equals</operation>
            <value>Symbol Approved</value>
        </criteriaItems>
        <description>This is used in WRF POLK.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>TableauVIsualizationIsTrueSubmittedIsTrue</fullName>
        <actions>
            <name>TableauVisualizationRequestNotification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WorkRequestForm__c.TableauVisualization__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>WorkRequestForm__c.RequestStatus__c</field>
            <operation>equals</operation>
            <value>Submitted</value>
        </criteriaItems>
        <description>This is used in WRF POLK.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>