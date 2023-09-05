//-------------------------------------
//@author: Sruti Srivastava
//@date: 27 June 2018
//@param: Trigger events
//@description: EmailMessage trigger
//@lastmodifiedby : Mohit Modi
//@lastmodifiedDate : 21 Aug 2018
//@lastmodifiedDescription : SFDC1-9218 , Added before delete Event
//-----------------------------

Trigger EmailMessageTrigger on EmailMessage (after insert,before delete) {
    //call trigger factory to create EmailMessage trigger dispatcher
    TriggerFactory.createTriggerDispatcher(EmailMessage.sObjectType);
}