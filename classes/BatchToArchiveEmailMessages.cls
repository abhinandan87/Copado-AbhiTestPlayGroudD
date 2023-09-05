//-----------------------------
// @author: Amrender Singh
// @date: 12 oct 2021
// @description: SFDC-4755(Storing Email Message data against File Storage: implementation) This batch class will be used to archive email message records from case.
//------------------------------
public with sharing class BatchToArchiveEmailMessages implements Database.Batchable<sObject> {
    public final String whereClause;
    public final Boolean runNextBatch;
    public BatchToArchiveEmailMessages(String c, Boolean nb) {
        this.whereClause = c;
        this.runNextBatch = nb;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> caseCloseStatus = system.label.ClosedCaseStatusValues.split(',');
        List<String> toEmailAddresses = system.label.EmailAddressToNotifyArchival!=null ? system.label.EmailAddressToNotifyArchival.split(';'): new List<String>();
         String query = '';
        if(String.isEmpty(this.whereClause)) {
			String clause = 'Status IN '+caseCloseStatus;
            query = 'SELECT Id, ActivityId, BccAddress, CcAddress, CreatedById, CreatedDate, FromAddress, FromName, ' +
                                         'HasAttachment, Headers,Incoming, IsDeleted, LastModifiedById, LastModifiedDate, LegacyIDUnique__c,' +
                                         'LegacyID__c, Status, LegacySystem__c, MessageDate, MessageIdentifier, PKIDEmailMessage__c,ParentId, RelatedToId, ' +
                                         'ReplyToEmailMessageId, Subject, SystemModstamp, ThreadIdentifier, ToAddress, ValidatedFromAddress, HtmlBody, ' +
                                         'EmailTemplateId,FirstOpenedDate,IsBounced,IsExternallyVisible,IsOpened,IsTracked,LastOpenedDate,IsClientManaged ' +
                                         'FROM EmailMessage WHERE '+
                                         'ParentId IN(SELECT Id FROM Case WHERE isClosed=true OR Status IN:caseCloseStatus)';
        }
        else {
            query = 'SELECT Id, ActivityId, BccAddress, CcAddress, CreatedById, CreatedDate, FromAddress, FromName, ' +
                                         'HasAttachment, Headers,Incoming, IsDeleted, LastModifiedById, LastModifiedDate, LegacyIDUnique__c,' +
                                         'LegacyID__c, Status, LegacySystem__c, MessageDate, MessageIdentifier, PKIDEmailMessage__c,ParentId, RelatedToId, ' +
                                         'ReplyToEmailMessageId, Subject, SystemModstamp, ThreadIdentifier, ToAddress, ValidatedFromAddress, HtmlBody, ' +
                                         'EmailTemplateId,FirstOpenedDate,IsBounced,IsExternallyVisible,IsOpened,IsTracked,LastOpenedDate,IsClientManaged ' +
                                         'FROM EmailMessage WHERE '+ this.whereClause;       
        }
        
        if(!toEmailAddresses.isEmpty()) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.toAddresses = toEmailAddresses;
            Organization org =[SELECT Id FROM Organization];
            mail.subject = 'Archive Email Messages job started on org: '+org.Id;
            mail.plainTextBody= 'BatchToArchiveEmailMessages batch job started. JobId : '+bc.getJobId();
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {mail});
        }
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<EmailMessage> scope) {
        try 
        {
            Map<Id,ArchivedEmailMessage__c> mapOfEmailIdVsArchiveRcd = new Map<Id,ArchivedEmailMessage__c>();
            Map<Id,Attachment> mapOfEmailMIdVsAttachments = new Map<Id,Attachment>();
            List<Attachment> lstOfAttchmentToInsert = new List<Attachment>();
            List<Attachment> lstOfEmailMessageRelationRecordsCsv = new List<Attachment>();
            List<ContentDocumentLink> lstContDoclinks = new List<ContentDocumentLink>();
            Map<String,String> emailIdVsArchiveMessId = new Map<String, String>();
            List<String> emailMessageIds = new List<String>();
            for(EmailMessage em:scope){
                emailMessageIds.add(em.Id);
            }
            for(ArchivedEmailMessage__c aem:[Select Id,LegacyID__c from ArchivedEmailMessage__c where LegacyID__c IN:emailMessageIds ]){
                emailIdVsArchiveMessId.put(aem.LegacyID__c, aem.Id);
            }
            /**Creating ArchivedEmailMessage object record and from emailMessage**/
            if(!scope.isEmpty() && scope.size()>0) {
                for(EmailMessage em:scope)
                {
                    if(em != null && !emailIdVsArchiveMessId.containsKey(em.Id)) {
                        ArchivedEmailMessage__c archiveEmail = new ArchivedEmailMessage__c(
                            Name = String.isNotBlank(em.Subject)? em.Subject.Length()>80 ? em.Subject.substring(0, 80) : em.Subject : '',
                            Case__c = em.ParentId,
                            LegacyID__c = em.Id,
                            BccAddress__c = em.BccAddress,
                            CcAddress__c = em.CcAddress,
                            FirstOpenedDate__c = em.FirstOpenedDate,
                            FromAddress__c = em.FromAddress,
                            FromName__c = em.FromName,
                            HasAttachment__c = em.HasAttachment,
                            Headers__c = em.Headers,
                            Incoming__c = em.Incoming,
                            IsExternallyVisible__c = em.IsExternallyVisible,
                            MessageDate__c = em.messagedate.year()<1700?em.createddate:em.messagedate,
                            PKIDEmailMessage__c = em.PKIDEmailMessage__c,
                            Status__c = em.Status,
                            Subject__c =em.Subject,
                            ToAddress__c = em.ToAddress,
                            LegacyIDUnique__c = em.LegacyIDUnique__c,
                            LegacySystem__c = em.LegacySystem__c,
                            MessageIdentifier__c = em.MessageIdentifier,
                            ReplyToEmailMessageId__c = em.ReplyToEmailMessageId,
                            ValidatedFromAddress__c = em.ValidatedFromAddress,
                            EmailTemplateId__c = em.EmailTemplateId,
                            IsOpened__c = em.IsOpened,
                            IsTracked__c = em.IsTracked,
                            LastOpenedDate__c = em.LastOpenedDate,
                            IsClientManaged__c = em.IsClientManaged,
                            ThreadIdentifier__c = em.ThreadIdentifier,
                            IsBounced__c = em.IsBounced,
                            EmailMessage_CreatedBy__c = em.CreatedById,
                            EmailMessage_CreatedDate__c = em.CreatedDate,
                            EmailMessage_LastModifiedBy__c = em.LastModifiedById,
                            EmailMessage_LastModifiedDate__c = em.LastModifiedDate
                        );
                        Attachment htmlBody = new Attachment(Name= String.isNotBlank(em.Subject)? em.Subject.Length()>245 ? em.Subject.substring(0,245):em.Subject+'.html':'blank__.html',Body = em.HtmlBody!=null?Blob.valueOf(em.HtmlBody):Blob.valueOf('Html body is Empty.'));
                        mapOfEmailMIdVsAttachments.put(em.Id,htmlBody);
                        mapOfEmailIdVsArchiveRcd.put(em.Id, archiveEmail);
                    }
                }
            }
            //Inserting ArchivedEmailMessage__c object records.
            if(!mapOfEmailIdVsArchiveRcd.isEmpty()){
                database.insert(mapOfEmailIdVsArchiveRcd.values(),false);
            }
            /**Adding ParentId to Attachments. start **/
            for(ArchivedEmailMessage__c aem:mapOfEmailIdVsArchiveRcd.values()){
                if(mapOfEmailMIdVsAttachments.containsKey(aem.LegacyID__c) && aem.Id!=null){
                    Attachment attach =mapOfEmailMIdVsAttachments.get(aem.LegacyID__c);
                    attach.ParentId = aem.Id;
                    lstOfAttchmentToInsert.add(attach);
                } 
            }
            /**Adding ParentId to Attachments. end **/
            if(!mapOfEmailIdVsArchiveRcd.isEmpty()){
                lstContDoclinks              		=  cloneContentDocumentLinks(mapOfEmailIdVsArchiveRcd);
                lstOfEmailMessageRelationRecordsCsv = cloneEmailMessageRelationRecordsCsv(mapOfEmailIdVsArchiveRcd);
                if(!lstOfAttchmentToInsert.isEmpty()) {
                    database.insert(lstOfAttchmentToInsert,false);
                }               
                if(!lstContDoclinks.isEmpty()) {
                    database.insert(lstContDoclinks, false);
                }
                if(!lstOfEmailMessageRelationRecordsCsv.isEmpty()) {
                     database.insert(lstOfEmailMessageRelationRecordsCsv,false);
                }
            }
            
        } catch(Exception ex) {
            UtilityClass.createApexLogRecord(ex, 'BatchToArchiveEmailMessages', 'execute'); 
        } 
    }
    
    public void finish(Database.BatchableContext bc){
        
        List<String> toEmailAddresses = system.label.EmailAddressToNotifyArchival!=null ? system.label.EmailAddressToNotifyArchival.split(';'): new List<String>();
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                              TotalJobItems, CreatedBy.Email, ExtendedStatus
                              FROM AsyncApexJob WHERE Id =:BC.getJobId()];
        if(!toEmailAddresses.isEmpty()) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.toAddresses = toEmailAddresses;
            Organization org =[SELECT Id FROM Organization];
            mail.subject = 'Archive Email Messages job ended on org: '+org.Id;
            mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
                                       ' batches with '+ a.NumberOfErrors + ' failures. BatchToArchiveEmailMessages batch job ended. JobId : '+bc.getJobId());
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        }
        if(a.NumberOfErrors>0 && a.ExtendedStatus.contains('Apex heap size too large')){
            database.executeBatch(new BatchToArchiveEmailMessages( this.whereClause ,this.runNextBatch ),30);
        }
        if(a.NumberOfErrors == 0 && this.runNextBatch){
        	database.executeBatch(new BatchToCloneAttachments('',true),2);
        }
    }
    
    private static List<Attachment> cloneEmailMessageRelationRecordsCsv(Map<Id,ArchivedEmailMessage__c> mapOfEmailIdVsArchiveRcd ) {
        /**Cloning all EmailMessageRelation records csv to archival record. start**/
        List<Attachment> lstOfAttchmentToInsert = new  List<Attachment>();    
        Map<String, List<String>> mapOfEmailMIdVsLstOfERelationRcd = new Map<String, List<String>>();
        List<ContentDocumentLink> lstContDoclinks = new List<ContentDocumentLink>();
        for(EmailMessageRelation emr:[Select Id, CreatedById, CreatedDate, EmailMessageId, IsDeleted, RelationAddress, RelationId, 
                                      RelationObjectType, RelationType, SystemModstamp 
                                      From EmailMessageRelation 
                                      where EmailMessageId IN:mapOfEmailIdVsArchiveRcd.keyset()])
        {
            List<String> csvRowdata= new List<String>{emr.Id, emr.CreatedById, emr.CreatedDate.format('M/d/yyyy h:mm:ss a z'), emr.EmailMessageId,string.valueOf(emr.IsDeleted), emr.RelationAddress, emr.RelationId,
                emr.RelationObjectType, emr.RelationType, emr.SystemModstamp.format('M/d/yyyy h:mm:ss a z')};
                    String csvRcdString = String.join(csvRowdata,',');
            csvRcdString = csvRcdString.replace('\n',' ');
            if(mapOfEmailMIdVsLstOfERelationRcd.containsKey(emr.EmailMessageId)){
                mapOfEmailMIdVsLstOfERelationRcd.get(emr.EmailMessageId).add(csvRcdString);
            }else{
                mapOfEmailMIdVsLstOfERelationRcd.put(emr.EmailMessageId, new List<String>{csvRcdString});
            }
        }        
        for(String emailMessageId: mapOfEmailMIdVsLstOfERelationRcd.keySet()){
            if(mapOfEmailIdVsArchiveRcd.get(emailMessageId).Id!=null){
                List<String> emailRelationRcdLst = mapOfEmailMIdVsLstOfERelationRcd.get(emailMessageId);
                String csvHeader = 'Id, CreatedById, CreatedDate, EmailMessageId, IsDeleted, RelationAddress, RelationId, RelationObjectType, RelationType, SystemModstamp \n';
                String csvFileBody = csvHeader + String.join(emailRelationRcdLst,'\n');
                Attachment csvFile = new Attachment(ParentId=mapOfEmailIdVsArchiveRcd.get(emailMessageId).Id,Name ='EmailMessageRelation_'+emailMessageId+'.csv', Body = Blob.valueOf(csvFileBody));
                lstOfAttchmentToInsert.add(csvFile);
            }
        }
        return lstOfAttchmentToInsert; 
        /**Cloning all EmailMessageRelation records csv to archival record. end**/
    } 
    private static List<ContentDocumentLink> cloneContentDocumentLinks(Map<Id,ArchivedEmailMessage__c> mapOfEmailIdVsArchiveRcd ){
        /**Cloning all email messages ContentDocumentLink into arvhive email records. Start**/
        List<ContentDocumentLink> lstOfContentDocLinkToInsert = new List<ContentDocumentLink>();
        Map<String,List<String>> mapOfParentIdVsAttachmentCsvRcds = new Map<String,List<String>>();
        for(ContentDocumentLink doc:[SELECT Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility 
                                     FROM 
                                     ContentDocumentLink 
                                     WHERE LinkedEntityId IN:mapOfEmailIdVsArchiveRcd.keyset()])
        {
            if(mapOfEmailIdVsArchiveRcd.get(doc.LinkedEntityId).Id!=null){
                ContentDocumentLink cloneDocLink = doc.clone(false, true, true, true);
                cloneDocLink.LinkedEntityId = mapOfEmailIdVsArchiveRcd.get(doc.LinkedEntityId).Id;
                lstOfContentDocLinkToInsert.add(cloneDocLink);
            }
        }
        return lstOfContentDocLinkToInsert;
        /**Cloning all email messages ContentDocumentLink into arvhive email records. end**/
    }
}