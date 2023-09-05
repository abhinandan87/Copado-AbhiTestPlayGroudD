public class cloneOpportunityRecordQueuable implements Queueable{
   Private Opportunity oppRecord;
   Private string pricebookId;
   Private string newOppId;
   Private string originalCurrency;
   Private boolean isBeingCloned;
    public cloneOpportunityRecordQueuable(Opportunity oppRecord, string pricebookId, string newOppId,string originalCurrency, string expectedCurrency, boolean isBeingCloned){
        this.oppRecord = oppRecord;
        this.pricebookId = pricebookId;
        this.newOppId=newOppId;
        this.originalCurrency=originalCurrency;
        this.isBeingCloned=isBeingCloned;
    }
    public void execute(QueueableContext context) {
        Savepoint sp = Database.setSavepoint();
        try{
        CloneOpportunityWithProducts.cloneOpportunityProducts(oppRecord,pricebookId,newOppId,originalCurrency, originalCurrency, isBeingCloned);
        Notification__e event = new Notification__e();
            event.message__c = 'Your Opportunity has been Clonned Sucessfully.';
            event.recordId__c = oppRecord.Id;
            event.ErrorStatus__c = 'Success';
            EventBus.publish(event);
            system.debug('event'+event);
        }
         catch(Exception e){
            String errMessage = e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')? 
                                e.getMessage().substringAfterLast('FIELD_CUSTOM_VALIDATION_EXCEPTION,'): 
                                (e.getMessage().contains('FIELD_INTEGRITY_EXCEPTION')? 
                                e.getMessage().substringAfterLast('FIELD_INTEGRITY_EXCEPTION,')
                                :e.getMessage());
            system.debug('Inside Catch');
            Database.rollback(sp);
            Notification__e event = new Notification__e();
            event.message__c = errMessage;
            event.recordId__c = oppRecord.Id;
            event.ErrorStatus__c = 'Error';
            EventBus.publish(event);
            
            
         //   System.debug('Error, method changeOpportunityCurrency, class CloneOpportunityWithProducts '+ e.getMessage());
            ApexLogger.logError(new LogMessage('changeOpportunityCurrencyQueuable','changeOpportunityCurrency',e));
        }      
        
    }


}