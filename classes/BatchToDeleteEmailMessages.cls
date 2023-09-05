//-----------------------------
// @author: Amrender Singh
// @date: 12 oct 2021
// @description: SFDC-4755(Storing Email Message data against File Storage: implementation) This batch class will be used to delete email messages which are archived successfully.
//------------------------------
public class BatchToDeleteEmailMessages implements Database.Batchable<sObject> {
    public String whereClause;
    
    public BatchToDeleteEmailMessages(String clause){
        this.whereClause = clause;
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> caseCloseStatus = system.label.ClosedCaseStatusValues.split(',');
        List<String> toEmailAddresses = system.label.EmailAddressToNotifyArchival!=null ? system.label.EmailAddressToNotifyArchival.split(';'): new List<String>();
        String query='';
        if(String.isEmpty(this.whereClause)) {
            query = 'SELECT ID, ParentId FROM EmailMessage WHERE Parent.isClosed=true OR Parent.Status IN:caseCloseStatus';
        }
        else{
            query = 'SELECT ID, ParentId FROM EmailMessage WHERE '+this.whereClause;
        }
        if(!toEmailAddresses.isEmpty()) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.toAddresses = toEmailAddresses;
            Organization org =[SELECT Id FROM Organization];
            mail.subject = 'BatchToDeleteEmailMessages job started on org: '+org.Id;
            mail.plainTextBody= 'BatchToDeleteEmailMessages batch job started. JobId : '+bc.getJobId();
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {mail});
        }
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<EmailMessage> scope) {
        try{
            List<EmailMessage> LstOfEmailToDelete = new List<EmailMessage>();
            List<String> emailIdsWithNoAttchemnts = new List<String>();
            Set<String> emailIdsWithAttchemnts = new Set<String>();
            for(Attachment attach:[SELECT Id,ParentId from Attachment Where ParentId IN:scope]){
                    emailIdsWithAttchemnts.add(attach.ParentId);
            }
            for(EmailMessage em:scope){
                if(!emailIdsWithAttchemnts.contains(em.Id)){
                    emailIdsWithNoAttchemnts.add(em.Id);
                }
            }
            for(ArchivedEmailMessage__c em:[Select Id,LegacyID__c from ArchivedEmailMessage__c where LegacyID__c IN:emailIdsWithNoAttchemnts]){
                LstOfEmailToDelete.add(new EmailMessage(Id=em.LegacyID__c));
            }
            
            If(!LstOfEmailToDelete.isEmpty()){
                delete LstOfEmailToDelete;
            }
        }
        catch(Exception ex) {
            UtilityClass.createApexLogRecord(ex, 'BatchToDeleteEmailMessages', 'execute'); 
        }
    }
    
    public void finish(Database.BatchableContext bc){
        List<String> toEmailAddresses = system.label.EmailAddressToNotifyArchival!=null ? system.label.EmailAddressToNotifyArchival.split(';'): new List<String>();
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                          TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id =:bc.getJobId()];
        if(!toEmailAddresses.isEmpty()) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.toAddresses = toEmailAddresses;
            Organization org =[SELECT Id FROM Organization];
            mail.subject = 'BatchToDeleteEmailMessages job ended on org: '+org.Id;
            mail.setPlainTextBody('BatchToDeleteEmailMessages batch job ended. JobId : '+bc.getJobId()+' The batch Apex job processed ' + a.TotalJobItems +
                                  ' batches with '+ a.NumberOfErrors + ' failures.');
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        }
    }
    
}