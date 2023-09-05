/**
*@author: Digvijay Singh
*@date: 11-Aug-2021
*@description: one of the Core class for Apex logging framework, contains  methods to log transaction details.
*@companyname : IHS Markit 
**/
public with sharing class ApexLogEventBuilder {

    private final SetApexLoggerEvent__e apexLogEvent;

    /**
     * @description Used by 'Apex Logger' to instantiate a new instance of 'ApexLogEventBuilder'
     * @return                   The new instance of 'ApexLogEventBuilder'
     */
    public ApexLogEventBuilder() {
        this.apexLogEvent = new SetApexLoggerEvent__e(UserId__c=UserInfo.getUserId());
        Database.DmlOptions dmlOptions = new Database.DmlOptions();
        dmlOptions.allowFieldTruncation = true;
        this.apexLogEvent.setOptions(dmlOptions);
    }

    /**
     * @description Sets the log entry event's message field
     * @param  logMessage The instance of `LogMessage` to use to set the entry's message field
     * @return            The same instance of `LogEntryEventBuilder`, useful for chaining methods
     */
    public ApexLogEventBuilder setlogMessagedetails(LogMessage logMessage) {

        if(logMessage!=null) {
            this.apexLogEvent.errorMessage__c=logMessage.getmessage();
            this.apexLogEvent.className__c = logMessage.getclassName();
            this.apexLogEvent.errorMessage__c = logMessage.getmessage();
            this.apexLogEvent.methodName__c = logMessage.getmethodName();
           
            if(logMessage.getrecord()!=null) {
                this.apexLogEvent.recordId__c=logMessage.getrecord().Id;
                this.apexLogEvent.recordJson__c=JSON.serializePretty(logMessage.getrecord());
            }

            if(logMessage.getrecords()!=null) {
                this.apexLogEvent.recordJson__c=JSON.serializePretty(logMessage.getrecords());
            }

            if(logMessage.getException()!=null) {
                this.setExceptionDetails(logMessage.getException());
            }

        }
        return this;
    }
    
    

       /**
     * @description Sets the log entry event's exception fields
     * @param  apexException The instance of an `Exception` to use.
     * @return               The same instance of `ApexLogEventBuilder`, useful for chaining methods
     */
    public ApexLogEventBuilder setExceptionDetails(Exception apexException) {
       
        if(String.IsBlank(this.apexLogEvent.errorMessage__c)) {
            this.apexLogEvent.errorMessage__c = apexException.getMessage();
        }
        this.apexLogEvent.ExceptionType__c = apexException.getTypeName();
        this.apexLogEvent.StackTrace__c = apexException.getStackTraceString();
        return this;
    }
    

     /**
     * @description Returns the 'SetApexLoggerEvent__e' record for this instance of LogEntryEventBuilder
     * @return   The 'SetApexLoggerEvent__e' record
     */
    public SetApexLoggerEvent__e getapexLogEvent() {
        return this.apexLogEvent;
    }

}