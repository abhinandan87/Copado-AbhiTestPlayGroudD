/**
* @author: Paras Dhingra
* @date: 3rd August 2017
* @description: SFDC-3387 Update entity subscription records for users so that the limit of 2000 is honored
*/
global class BatchCleanupEntitySubscriptions implements Database.Batchable<sObject>, Database.Stateful {
    public Boolean batchHasErrors = false;
    public String query;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if (String.isBlank(query)) {
            query = 'Select Id from User where isActive=true' ;
        }
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<User> scope) {        
        try {
            Set<Id> userIDsToQuery = new Set<Id>();
            for(User usr: scope) {
                userIDsToQuery.add(usr.Id);
            }
            Integer daysThreshold = Integer.valueOf(System.Label.NumberOfDaysThreshold);
            Date thresholdDate = Date.today() - daysThreshold;
            List<EntitySubscription> lstUsersWithEntitySubs = [SELECT ID,ParentId,SubscriberId,Subscriber.Name FROM EntitySubscription 
                                                                WHERE
                                                                SubscriberID IN: userIDsToQuery AND
                                                                ParentId IN (Select Id from Opportunity where IsClosed = true and CloseDate <=: thresholdDate) ];
            if(lstUsersWithEntitySubs!=null && lstUsersWithEntitySubs.size()>0) {
                delete lstUsersWithEntitySubs;
            }
        } catch(Exception ex) {
            System.debug(LoggingLevel.INFO,'--Exception caught in batch--'+ex.getMessage());
            batchHasErrors = true;
            UtilityClass.createApexLogRecord(ex, 'BatchCleanupEntitySubscriptions', 'Execute');       
        }
    }
    global void finish(Database.BatchableContext BC) { 
        System.debug(LoggingLevel.INFO, 'BatchCleanupEntitySubscriptions BATCH FINISH()');
        //Send Email if Errors in batch processing
        if(batchHasErrors) {            
            String[] toAddresses = new String[] {'sfadmin@ihsmarkit.com'};
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setReplyTo(System.Label.OpptyPrimaryContactBatchEmail);            
            mail.setSubject('sfadmin@ihsmarkit.com');
            mail.setPlainTextBody('Please see Apex Log records to view errors of BatchCleanupEntitySubscriptions batch class job in detail.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}