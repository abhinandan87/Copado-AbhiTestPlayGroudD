global with sharing class ActivitiesEmailTemplateController {
    global string eventId {get;set;}
    global ActivitiesEmailTemplateWrapper wrapperObj {get{
        if(wrapperObj==null) {
            wrapperObj = new ActivitiesEmailTemplateWrapper(this.eventId);
        }
        return wrapperObj;
    } set;}
}