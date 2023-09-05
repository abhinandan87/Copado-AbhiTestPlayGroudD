/**
* @author: Vaishali Jain
* @date: 29 Sep 2021
* @description: This class contains Campaign Member after-insert method calls
*/

public class CampaignMemberAfterInsertHandler extends TriggerHandlerBase {
    public override void mainEntry(TriggerParameters tp) {
        System.debug('Inside===CampaignMemberAfterInsertHandler');
        CampaignMemberMethods.updateCampaignNameCampaignNumber(tp);
    }
}