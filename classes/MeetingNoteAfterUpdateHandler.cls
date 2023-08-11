//-----------------------------
// @author: Harshit Singhal
// @date: 27 Mar 2020
// @param: TriggerParameters
// @description: SFDC-2748 AfterUpdate dispatcher event handler class that calls the functions in MeetingNoteMethods.
// @return: NA
//-----------------------------
public class MeetingNoteAfterUpdateHandler extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {
        MeetingNoteMethods.createDefaultRelatedOpportunity(tp);
    }
}