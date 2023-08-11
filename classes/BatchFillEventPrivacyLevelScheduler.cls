//-----------------------------
// @author: Harshit Singhal
// @date: 12 Jun 2020
// @description: SFDC-2761 Scheduler to call BatchCreateMeetingNoteForEvent batch class. Main purpose is to create automated meeting notes for outlook synced events.
//------------------------------
public class BatchFillEventPrivacyLevelScheduler implements Schedulable {    
    public String q='';
    public String email='';
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new BatchFillEventPrivacyLevel(q, email));
    }
}