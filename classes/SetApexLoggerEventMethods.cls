//-----------------------------
// @author: Digvijay Singh
// @date: 11 Aug 2021
// @param: NA
// @description:  Class to hold SetApexLoggerEvent__e platform event trigger methods 
// @return: NA
//-----------------------------
public with sharing class SetApexLoggerEventMethods {
    /**
    * @author Digvijay Singh
    * @date 11 Aug 2021
    * @description Insert apex Logger records
    * @param TriggerParameters
    * @return void
    * @companyname IHS Markit
    */
    public static void insertApexLogEntries(List<SetApexLoggerEvent__e> eventList) {
        List<ApexLogger__c> apexlogEntries = new List<ApexLogger__c>();
        for (SetApexLoggerEvent__e apexlogEntryEvent : eventList) {
            ApexLogger__c apexlogEntry = new ApexLogger__c(
                exceptionType__c = apexlogEntryEvent.exceptionType__c,  
                errorMessage__c = apexlogEntryEvent.errorMessage__c,
                logRecordId__c = apexlogEntryEvent.recordId__c,
                LogRecordJson__c = apexlogEntryEvent.recordJson__c,
                errorDescription__c = apexlogEntryEvent.stackTrace__c,
                className__c=apexlogEntryEvent.className__c,
                functionName__c=apexlogEntryEvent.methodName__c,
                user__c=apexlogEntryEvent.UserId__c,
                transactionId__c=apexlogEntryEvent.transactionId__c
            );

            apexlogEntries.add(apexlogEntry);
        }

        if(!apexlogEntries.isEmpty()) {
            insert apexlogEntries;
        }
    }
    //-----------------------------
    // @author: Sathish Edla
    // @date: 30 Mar 2022
    // @description: SFDC-5375 Extend the trigger framework to handle platform events.
    //-----------------------------
    public static void insertApexLogEntries(TriggerParameters tp) {
        List<SetApexLoggerEvent__e> eventList = (List<SetApexLoggerEvent__e>)tp.newList;
        insertApexLogEntries(eventList);
    }
}