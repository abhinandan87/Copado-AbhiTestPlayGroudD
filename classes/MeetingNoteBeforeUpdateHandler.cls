//-----------------------------
// @author: Harshit Singhal
// @date: 27 Mar 2020
// @param: TriggerParameters
// @description: SFDC-2752 BeforeUpdate dispatcher event handler class that calls the functions in MeetingNoteMethods.
// @return: NA
//-----------------------------
public class MeetingNoteBeforeUpdateHandler extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {        
        MeetingNoteMethods.markNotesCompleted(tp);
        MeetingNoteMethods.meetingNoteValidations(tp);
    }
}