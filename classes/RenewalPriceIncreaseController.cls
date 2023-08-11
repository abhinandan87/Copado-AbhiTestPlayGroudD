/**
 * @Author: Paras Dhingra
 * @Date: 19th Aug 2020
 * @Description: SFDC-3187 controller for lightning component RenewalPriceIncrease
 */
public without sharing class RenewalPriceIncreaseController {
    /**
     * @Author: Paras Dhingra
     * @Date: 19th Aug 2020
     * @Description: SFDC-3187 LDS does not allows user to by pass fls. 
     * This method helps us to bypass the FLS and update oppy
     */
    @AuraEnabled
    public static string updateOppy(Opportunity oppy) {
        String message = 'success';
        try {
            if(oppy!=null && oppy.Id!=null) {
                update oppy;
            } else {
                message = 'Opportunity not found';
            }
        }catch(DMLException ex) {
            message = ex.getDmlMessage(0);
        } catch(Exception ex) {
            message = ex.getMessage();
        }
        return message;     
    }
}