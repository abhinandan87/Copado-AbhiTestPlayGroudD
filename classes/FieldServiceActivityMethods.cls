//*********************************************************************************************************************
// @author Vaishali Jain
// @date 29th July 2021
// @description Class created to add common methods to be used by FSA trigger handler classes
//*********************************************************************************************************************

public class FieldServiceActivityMethods {
    
    /**
     * @author Vaishali Jain
     * @date 29th July 2021
     * @description when the FSA Attendee is updated,
     * To check FSA Status when FSA is updated and send an email to FSA Attendees
     */
    public static void updateFSAAttendeeUsers(TriggerParameters tp) {
        WorkOrder workOrd;
        Set<Id> FSAIdSet = new Set<Id>();
        for(WorkOrder fsa : (List<WorkOrder>)tp.newList) {
            System.debug('===19===FSA Send Mail=== '+fsa);
            workOrd = (WorkOrder)tp.oldMap.get(fsa.Id);
            if(fsa.Status != workOrd.Status && fsa.Status == 'Delivered') {
                FSAIdSet.add(fsa.Id);
            }
        }
    
        List<FieldServiceActivityAttendee__c> ListFSAAttendee = [SELECT IsFSADeliveryStatus__c FROM FieldServiceActivityAttendee__c WHERE FieldServiceActivity__c IN: FSAIdSet AND IsFSADeliveryStatus__c != true];
        List<FieldServiceActivityAttendee__c> FSAUpdateList = new List<FieldServiceActivityAttendee__c>();
      /*  List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'TrainingAssessmentSurveyResponseTemplate'];
        for(FieldServiceActivityAttendee__c fsa : ListFSAAttendee){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(fsa.Contact__c); 
            message.setSenderDisplayName('IHS Support'); 
            message.setReplyTo('no-reply@company.com');
            message.setUseSignature(false); 
            message.setBccSender(false); 
            message.setSaveAsActivity(false); 
            message.setTemplateID(emailTemplate.Id); 
            //message.setWhatId(fsa.AccountId__c); 
            message.toAddresses = new String[] {fsa.Email__c};
            System.debug('===40===FSAEMAIL=== '+fsa.Email__c);
            System.debug('===41===messagesToAddress=== '+message.toAddresses);
            //Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            Messaging.sendEmail(new Messaging.Email[] {message});
            //messages.add(message);
            System.debug('===44===messages=== '+messages);
        }
        if(messages.size()>0 && messages != null){
            System.debug('===47===messagesSendEmail=== '+Messaging.sendEmail(messages));
            //Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            //Messaging.sendEmail(messages);
        }*/
        for(FieldServiceActivityAttendee__c fsa : ListFSAAttendee){
            fsa.IsFSADeliveryStatus__c = true;
            FSAUpdateList.add(fsa);
        }
        if(FSAUpdateList.size()>0 && FSAUpdateList != null){
            update FSAUpdateList;
        }
    }
}