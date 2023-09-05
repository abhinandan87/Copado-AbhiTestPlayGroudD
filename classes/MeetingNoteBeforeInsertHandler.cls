//-----------------------------
// @author: Harshit Singhal
// @date: 27 Mar 2020
// @param: TriggerParameters
// @description: SFDC-2752 BeforeInsert dispatcher event handler class that calls the functions in MeetingNoteMethods.
// @return: NA
//-----------------------------
public class MeetingNoteBeforeInsertHandler extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {
        MeetingNoteMethods.markNotesCompleted(tp);
    }
}