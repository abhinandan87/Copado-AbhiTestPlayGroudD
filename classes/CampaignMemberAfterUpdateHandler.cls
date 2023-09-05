/**
* @author: Vaishali Jain
* @date: 29 Sep 2021
* @description: This class contains Campaign Member after-update method calls
*/

public class CampaignMemberAfterUpdateHandler extends TriggerHandlerBase {
    public override void mainEntry(TriggerParameters tp) {
        System.debug('Inside===CampaignMemberAfterUpdateHandler');
        CampaignMemberMethods.updateCampaignNameCampaignNumber(tp);
    }
}