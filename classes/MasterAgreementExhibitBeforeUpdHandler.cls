/**
* @author Paras Dhingra
* @date 20th Jan 2020
* @description: SFDC-2198 before update handler for Master Agreement Exhibit trigger
*/
public class MasterAgreementExhibitBeforeUpdHandler extends TriggerHandlerBase {
    public override void mainEntry(TriggerParameters tp) {
        MasterAgreementExhibitMethods.validateMAERecords(tp);
    } 

}