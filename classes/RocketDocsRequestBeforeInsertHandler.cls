public class RocketDocsRequestBeforeInsertHandler  extends TriggerHandlerBase{    
    public override void mainEntry (TriggerParameters tp) {
       RocketDocsRequestMethods.prepopulateFieldsValues(tp);    
    }
}