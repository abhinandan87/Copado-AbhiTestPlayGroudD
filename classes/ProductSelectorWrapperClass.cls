//
// @author Paras Dhingra
// @date: 17th Aug 2017 
// @description : SFDC1-1837, SFDC1-2043 wrapper class for product selector
// @company : IHS Markit
// @author Vishnu
// @date: 08th Oct 2018 
// @description : SFDC1-9003, Adding loadingGroupId, so that the same class can be reused in lighting component.
//
public class ProductSelectorWrapperClass {
	
    @AuraEnabled public boolean isSelected;
    @AuraEnabled public String productName;
    @AuraEnabled public String productId;
    @AuraEnabled public Product2 product;
    @AuraEnabled public String loadingGroupId;
    @AuraEnabled public String deliveryTeam;
}