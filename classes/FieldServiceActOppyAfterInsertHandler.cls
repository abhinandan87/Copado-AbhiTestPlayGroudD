/**
* @author: Shikhar Singh
* @date: 06 June 2022
* @description: SFDC-5786. After insert dispatcher event handler class that calls the functions in FSAOMethods.
*/
public class FieldServiceActOppyAfterInsertHandler extends TriggerHandlerBase {
    /** 
  * @author: Shikhar Singh
  * @date: 06 June 2022
  * @description: SFDC-5786. Handler class called by the trigger framework to carry out the specific actions on
  *    Field Service Activity Opportunity object after insert
  * @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got created.
  * @return: void
  */
  public override void mainEntry(TriggerParameters tp) {
        FieldServiceActivityOpportunityMethods.updateOpportunityOnFsa(tp);
  }
}