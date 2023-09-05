//-----------------------------
// @author: Dev Aggarwal
// @date: 6 February 2020
// @description: SFDC-2588 - Delete AuthSessions for UI/Aura Sessions that have been opened for more than 24 Hours.
//------------------------------

global class BatchLogoutLongRunningSessions implements Database.Batchable<sObject>, System.Schedulable {
    @testVisible private static String strQuery;

    global Database.QueryLocator start(Database.BatchableContext bc) {
        DateTime filteringDate = System.now()-1 ;
        strQuery = Test.isRunningTest() ? strQuery : 'SELECT Id, UsersId, Createddate  from AuthSession where SessionType in ' + System.label.LongRunningSessionCriteria +'  AND createddate <  :filteringDate';
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext bc, List<AuthSession> longSessions) {
        List<ApexLogger__c> errorDetails = new List<ApexLogger__c>();
        try{
        if(longSessions != null && longSessions.size() > 0) {
                Database.DeleteResult[] results = Database.Delete(longSessions);
                Integer counter = 0;
                for(Database.DeleteResult sr : results) {
                    if(!sr.isSuccess()) {
                        for(Database.Error er : sr.getErrors()) {
                            errorDetails.add(new ApexLogger__c(ClassName__c = 'BatchLogoutLongRunningSessions', FunctionName__c = 'Execute',LogRecordId__c = longSessions[counter].id, ErrorDescription__c = er.getMessage()));
                            }
                        }
                    else {
                            ErrorDetails.add(new ApexLogger__c(ClassName__c = 'BatchLogoutLongRunningSessions', FunctionName__c = 'Execute',LogRecordId__c = longSessions[counter].UsersId, ErrorDescription__c = 'Session has been Deleted for ' + longSessions[counter].UsersId  + ' on ' + System.Now() + ' as it was Running for more than 24 Hours.'));
                        } 
                    counter++;
                    }
            try{
                    Insert errorDetails; 
               }
            catch(exception e) {
                    UtilityClass.createApexLogRecord(e, 'BatchLogoutLongRunningSessions', 'Execute');                                   
                }
        }
        }catch(Exception e){
            system.debug('Exception => '+e.getMessage());
        }
                
    }
   
    global void finish(Database.BatchableContext bc) {
        
    }
        global void execute(SchedulableContext ctx) {
        Database.executeBatch(new BatchLogoutLongRunningSessions());
        }

}