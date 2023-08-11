//-----------------------------
// @author: Amrender Singh
// @date: 12 oct 2021
// @description: SFDC-4755(Storing Email Message data against File Storage: implementation) This batch class will be used to Clone attchemtens from email message to archive email message records.
//------------------------------
public class BatchToCloneAttachments implements Database.Batchable<sObject> {
	public final String whereClause;
    public final Boolean runNextBatch;
    
    public BatchToCloneAttachments(String c, Boolean rnb) {
        this.whereClause = c; 
        this.runNextBatch = rnb;      
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query='';
        List<String> toEmailAddresses = system.label.EmailAddressToNotifyArchival!=null ? system.label.EmailAddressToNotifyArchival.split(';'): new List<String>();
        List<String> caseCloseStatus = system.label.ClosedCaseStatusValues.split(',');
        if(String.isEmpty(this.whereClause))
        {
            query = 'SELECT Id, Name, Body, ParentId, ContentType '+                        
                        'FROM Attachment '+
                        'WHERE '+
                        'ParentId IN(SELECT ID FROM EmailMessage WHERE Parent.isClosed=true OR Parent.Status IN:caseCloseStatus) ORDER BY BodyLength ASC';
        }
        else{
            query = 'SELECT Id, Name, Body, ParentId, ContentType  '+
                        'FROM Attachment '+
                        'WHERE '+ this.whereClause+' ORDER BY BodyLength ASC';
        }        
        if(!toEmailAddresses.isEmpty()) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.toAddresses = toEmailAddresses;
            Organization org =[SELECT Id FROM Organization];
            mail.subject = 'BatchToCloneAttachments job started on org: '+org.Id;
            mail.plainTextBody= 'BatchToCloneAttachments batch job started. JobId : '+bc.getJobId();
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {mail});
        }
	  return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Attachment> scope) {
        try {
            List<Attachment> cloneNewFiles = new List<Attachment>(), oldFiles = new List<Attachment>();
            List<String> lstOfLegacyIds= new List<String>();
            Map<String,String> EmailMsgVsArchiveRcdId = new Map<String,String>();
            for(Attachment attch:scope){
                lstOfLegacyIds.add(attch.ParentId);
            }
            for(ArchivedEmailMessage__c aem:[SELECT Id,LegacyID__c FROM ArchivedEmailMessage__c 
                                                        WHERE  
                                                        LegacyID__c IN:lstOfLegacyIds]) {
                EmailMsgVsArchiveRcdId.put(aem.LegacyID__c,aem.Id);
            }
            for(Attachment attch:scope) {                 
                if(!EmailMsgVsArchiveRcdId.isEmpty() && EmailMsgVsArchiveRcdId.containsKey(attch.ParentId)) {
                    Attachment newAttch = attch.clone(false, true, true, true);
                    newAttch.ParentId = EmailMsgVsArchiveRcdId.get(attch.ParentId);
                    cloneNewFiles.add(newAttch);
                    oldFiles.add(attch);
                }
            }
            
            if(cloneNewFiles.size()>0) {
                insert cloneNewFiles;
            }
            if(oldFiles.size()>0){
                delete oldFiles;
            }
        }
        catch(Exception ex) {
           UtilityClass.createApexLogRecord(ex, 'BatchToCloneAttachments', 'execute'); 
        }
     }
    
    public void finish(Database.BatchableContext bc){
        List<String> toEmailAddresses = system.label.EmailAddressToNotifyArchival!=null ? system.label.EmailAddressToNotifyArchival.split(';'): new List<String>();
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email,ExtendedStatus
                          FROM AsyncApexJob WHERE Id =:bc.getJobId()];
        if(!toEmailAddresses.isEmpty()) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.toAddresses = toEmailAddresses;
            Organization org =[SELECT Id FROM Organization];
            mail.subject = 'BatchToCloneAttachments job ended on org: '+org.Id;
            mail.setPlainTextBody('BatchToCloneAttachments batch job ended. JobId : '+bc.getJobId()+'The batch Apex job processed ' + a.TotalJobItems +
                                  ' batches with '+ a.NumberOfErrors + ' failures.');
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        }
        if(a.NumberOfErrors>0 && a.ExtendedStatus.contains('Apex heap size too large')){
            database.executeBatch(new BatchToCloneAttachments(this.whereClause,this.runNextBatch),2);
        }      
        if(a.NumberOfErrors == 0 && this.runNextBatch){
            database.executeBatch(new BatchToDeleteEmailMessages(''),200);
        }
    }
}