//-----------------------------
// @author: Harshit Singhal
// @date: 27 Mar 2020
// @param: TriggerParameters
// @description: SFDC-2748 AfterInsert dispatcher event handler class that calls the functions in MeetingNoteMethods.
// @return: NA
//-----------------------------
public class MeetingNoteAfterInsertHandler extends TriggerHandlerBase {
    public override void mainEntry(TriggerParameters tp) {
        MeetingNoteMethods.populateMeetingNoteOnRelatedEvent(tp);
        MeetingNoteMethods.createDefaultRelatedOpportunity(tp);
    }
}