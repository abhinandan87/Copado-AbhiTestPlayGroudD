public class changeOpportunityCurrencyQueuable implements Queueable{
   Private Opportunity oppRecord;
   Private string pricebookId;
   Private string newOppId;
   Private string originalCurrency;
   Private string expectedCurrency;
   Private boolean isBeingCloned;
   
    public changeOpportunityCurrencyQueuable(Opportunity oppRecord, string pricebookId, string newOppId,string originalCurrency, string expectedCurrency, boolean isBeingCloned){
        this.oppRecord = oppRecord;
        this.pricebookId = pricebookId;
        this.newOppId=newOppId;
        this.originalCurrency=originalCurrency;
        this.expectedCurrency=expectedCurrency;
        this.isBeingCloned=isBeingCloned;
    }
    
    public void execute(QueueableContext context) {
       Savepoint spForCurrencychangeOpportunityCurrencyQueable = Database.setSavepoint();
        try{
            CloneOpportunityWithProducts.cloneOpportunityProducts(oppRecord,pricebookId,newOppId,originalCurrency,expectedCurrency,isBeingCloned);   
            Notification__e event = new Notification__e();
            event.message__c = 'Your Opportunity has been updated.';
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
            
            if(errMessage.containsIgnoreCase('pricebook entry is inactive'))
                errMessage = 'One of Opportunity price book entry is inactive.';       
            system.debug('Inside Catch');
            Database.rollback(spForCurrencychangeOpportunityCurrencyQueable);
            Notification__e event = new Notification__e();
            event.message__c = errMessage;
            event.recordId__c = oppRecord.Id;
            event.ErrorStatus__c = 'Error';
            EventBus.publish(event);
            
            //
         //   System.debug('Error, method changeOpportunityCurrency, class CloneOpportunityWithProducts '+ e.getMessage());
            ApexLogger.logError(new LogMessage('changeOpportunityCurrencyQueuable','changeOpportunityCurrency',e));
        }      
    }
}