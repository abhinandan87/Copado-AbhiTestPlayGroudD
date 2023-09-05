//-----------------------------
// @author: Harshit Singhal
// @date: 31 Mar 2020
// @param: TriggerParameters
// @description: SFDC-2748 AfterUpdate dispatcher event handler class that calls the functions in EventMethods.
// @return: NA
//-----------------------------
public class EventAfterUpdateHandler extends TriggerHandlerBase {
    
    public override void mainEntry(TriggerParameters tp) {
        EventMethods.createMeetingNote(tp);
        EventMethods.syncMeetingNoteWithEvent(tp);
        EventMethods.changeActivityCreatedCheckboxOnOpportunity(tp);
        
        EventMethods.publishSetupEventPlatformEvents(tp);//Should be the last method to be called in this methods list
    }
}