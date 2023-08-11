//-----------------------------
// @author: Harshit Singhal
// @date: 06 Apr 2020
// @param: TriggerParameters
// @description: SFDC-2752 BeforeDelete dispatcher event handler class that calls the functions in MeetingNoteMethods.
// @return: NA
//-----------------------------
public class EventBeforeDeleteHandler extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {
        EventMethods.enforceDeleteValidations(tp);
    }
}