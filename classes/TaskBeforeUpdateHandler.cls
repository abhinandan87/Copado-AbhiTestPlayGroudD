//-----------------------------
// @author: Akshay Dogra
// @date: 07 Jun 2021
// @param: TriggerParameters
// @description: SFDC-3979 Notes / Comments Added Checkbox on Tasks.
// @return: NA
//-----------------------------
public class TaskBeforeUpdateHandler extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {        
        TaskMethods.notesCheckbox(tp);
    }
}