//-----------------------------
// @author: Harshit Singhal
// @date: 12 May 2020
// @param: NA
// @description: Test class for TaskRelatedListForEventController class used as apex controller for tasksRelatedListForEvent LWC component.
// @return: NA
//-----------------------------
@isTest
public class TestTaskRelatedListForEventController {
    @testSetup 
    static void createTestData() {        
        TestEventMethods.setupBasicData();
    }
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 11 May 2020
    // @param: NA
    // @description: Test method for method getEventDetails().
    // @return: NA
    //-----------------------------
    private static testMethod void testGetEventDetails() {
        //Query external contact
        Contact extContact = [SELECT Id,Account.Name FROM Contact WHERE Email like '%con1extacc1@ext.com%' LIMIT 1];
        //Create Event
        Event evt = TestUtility.createEventWithWhoId('EventInsert',extContact.Id, true);
        
        Event outputEvt = TaskRelatedListForEventController.getEventDetails(evt.Id);
        System.assertNotEquals(null, outputEvt, 'Event not returned by method.');
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 11 May 2020
    // @param: NA
    // @description: Test method for method getMeetingNoteId().
    // @return: NA
    //-----------------------------
    private static testMethod void testGetMeetingNoteId() {
        //Query external contact
        Contact extContact = [SELECT Id,Account.Name FROM Contact WHERE Email like '%con1extacc1@ext.com%' LIMIT 1];
        //Create Event
        Event evt = TestUtility.createEventWithWhoId('EventInsert',extContact.Id, true);
        
        Id outputMNId = TaskRelatedListForEventController.getMeetingNoteId(evt.Id);
        System.assertNotEquals(null, outputMNId, 'Event not returned by method.');
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 11 May 2020
    // @param: NA
    // @description: Test method for method getRelatedTasks().
    // @return: NA
    //-----------------------------
    private static testMethod void testgetRelatedTasksAndDeleteOne() {
        //Query external contact
        Contact extContact = [SELECT Id,AccountId,Account.Name FROM Contact WHERE Email like '%con1extacc1@ext.com%' LIMIT 1];
        //Create Event
        Event evt = TestUtility.createEventWithWhoId('EventInsert',extContact.Id, true);
        
        //Query event
        Event qryEvent = [SELECT Id,MeetingNote__c FROM Event WHERE Id=:evt.Id LIMIT 1];
        //Sc1: Create and query tasks - getRelatedTasks() method
        //Create tasks
        Task relatedTask1 = TestUtility.createTaskWithWhoWhatId('RelatedTask1',null,null,System.today()+2,false);
        relatedTask1.MeetingNote__c = qryEvent.MeetingNote__c;
        Task relatedTask2 = TestUtility.createTaskWithWhoWhatId('RelatedTask2',extContact.AccountId,extContact.Id,System.today()+4,false);
        relatedTask2.MeetingNote__c = qryEvent.MeetingNote__c;
        Task unrelatedTask3 = TestUtility.createTaskWithWhoWhatId('UnrelatedTask3',extContact.AccountId,null,System.today()+10,false);
        List<Task> insTaskList = new List<Task> {relatedTask1, relatedTask2, unrelatedTask3};
        insert insTaskList;
        
        List<Task> outputRelatedTasks = TaskRelatedListForEventController.getRelatedTasks(evt.Id);
        System.assertNotEquals(null, outputRelatedTasks, 'Related Tasks did not get created for event/meeting note.');
        System.assert(outputRelatedTasks.size()==2, 'No. of related tasks created for event/meeting are not correct.');
        
        //Sc2: Delete a task - deleteTask() method
        TaskRelatedListForEventController.deleteTask(unrelatedTask3.Id);
        System.assertEquals(0, [SELECT Id FROM Task WHERE Id=:unrelatedTask3.Id LIMIT 1].size(), 'Task could not be deleted.');
    }

}