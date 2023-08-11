//-----------------------------
// @author: Harshit Singhal
// @date: 09 Apr 2020
// @param: TriggerParameters
// @description: SFDC-2748 AfterDelete dispatcher event handler class that calls the functions in EventMethods.
// @return: NA
//-----------------------------
public class EventAfterDeleteHandler extends TriggerHandlerBase {
    
    public override void mainEntry(TriggerParameters tp) {
        EventMethods.deleteRelatedMeetingNote(tp);
    }
}