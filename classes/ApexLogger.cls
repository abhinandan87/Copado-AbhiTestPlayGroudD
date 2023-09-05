/**
*@author: Digvijay Singh
*@date: 11-Aug-2021
*@description: one of the Core class for Apex logging framework, contains public method initiate the logging.
*@companyname : IHS Markit 
**/
public  class ApexLogger {
    private static final String TRANSACTION_ID = System.Request.getCurrent().getRequestId();
    private static final List<ApexLogEventBuilder> LOG_ENTRIES_BUFFER = new List<ApexLogEventBuilder>();
    private static final Quiddity TRANSACTION_QUIDDITY = System.Request.getCurrent().getQuiddity();
    private static String  quidditytype;
     /**
     * @description Returns the unique ID for a particular transaction
     * @return String - The value of System.Request.getCurrent().getRequestId()
     */
    public static String getTransactionId() {
        return TRANSACTION_ID;
    }

    /**
     * @description Returns the Quiddity context of the current transaction.
     * @return Quiddity - The value of System.Request.getCurrent().getQuiddity()
     */
    public static Quiddity getCurrentQuiddity() {
        return TRANSACTION_QUIDDITY;
    }

     /**
     * @description creates log entry object with log details
     * @return void 
     */
    public static void logError(LogMessage logmessage) {
        ApexLogEventBuilder apexlogEventBuilder=newEntry().setlogMessagedetails(logmessage);
        saveLog();
    }

       /**
     * @description  Ovverided method for additional log details , creates log entry object with log details
     * @return void 
     */
    public static void logAndAddError(LogMessage logmessage) {
        ApexLogEventBuilder apexlogEventBuilder=newEntry().setlogMessagedetails(logmessage);
        saveLog();
        if(quidditytype!='ASYNC') {
            addError(logmessage.getrecord(),apexlogEventBuilder);
        }
    }

     /**
     * @description  Ovverided method with additional parameter for custom error message , creates log entry object with log details
     * @return void 
     */
    public static void logandthrowError(LogMessage logmessage) {
        ApexLogEventBuilder apexlogEventBuilder=newEntry().setlogMessagedetails(logmessage);
        saveLog();
        if(quidditytype!='ASYNC') {
            throwCustomException(apexlogEventBuilder.getapexLogEvent().errorMessage__c);
        }
    }

    
 
    /* @description  method to add all log entry detail to a buffer List , creates log entry object with log details
     * @return void 
     */
    private static ApexLogEventBuilder newEntry() {
        ApexLogEventBuilder apexlogEventBuilder = new ApexLogEventBuilder();
        LOG_ENTRIES_BUFFER.add(apexlogEventBuilder);
        return apexlogEventBuilder;
    }
    /* @description  publishes Platform Events or creates Apex logger records directly based on Transaction Quiddity. 
    * @return void 
    */
    public static void saveLog() {
        if (LOG_ENTRIES_BUFFER.isEmpty()) {
            return;
        }

        List<SetApexLoggerEvent__e> apexlogEntryEvents = new List<SetApexLoggerEvent__e>();
        for (ApexLogEventBuilder apexlogEventBuilder : LOG_ENTRIES_BUFFER) {
                SetApexLoggerEvent__e apexlogEvent = apexlogEventBuilder.getapexLogEvent();
                apexlogEvent.TransactionId__c = getTransactionId();
                apexlogEntryEvents.add(apexlogEvent);         
        }

        if(checkforAsyncQuiddity()!='ASYNC'&& !apexlogEntryEvents.isEmpty()) {
            List<Database.SaveResult> results = EventBus.publish(apexlogEntryEvents);
            LOG_ENTRIES_BUFFER.clear();
            System.debug('saveResults =' + results);
        }else {
            if(!apexlogEntryEvents.isEmpty()) {
                SetApexLoggerEventMethods.insertApexLogEntries(apexlogEntryEvents);
            }
        }
    }
    
    /* @description  Checks on current Transaction Quiddity.
    * @return String  
    */
    private static String checkforAsyncQuiddity() {
        switch on getCurrentQuiddity() {
            
            when FUTURE,SCHEDULED,QUEUEABLE,BATCH_ACS, BATCH_APEX, BATCH_CHUNK_PARALLEL, BATCH_CHUNK_SERIAL {
                quidditytype = 'ASYNC';
            }     
            when else {
                quidditytype = 'SYNC';
            }
        }

        return quidditytype; 
    }
    
    
    /* @description  throws Custom Exception Object 
    * @return Exception Object 
    */
    public static Exception throwCustomException(String errorMessage) {
        throw new TriggerException(errorMessage);
    }

    /* @description  throws Custom Exception Object 
    * @return Exception Object 
    */
    public static void  addError(Sobject sobj,ApexLogEventBuilder  apexLogEventBuilder) {
        if(sobj!=null) {
            sobj.addError(apexLogEventBuilder.getapexLogEvent().ErrorMessage__c);
        }
    }
}