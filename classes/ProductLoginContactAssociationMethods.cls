//-----------------------------
// @author: Vishnu Vardhan Chowdary
// @date: 17 Dec 2018
// @description: Class to hold Product Login Contact Association trigger methods 
//-----------------------------
public class ProductLoginContactAssociationMethods {
    //-----------------------------
    // @author: Vishnu Vardhan Chowdary
    // @date: 17 Dec 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-10703 Whenever there is an insert or update on this record then populate unique key field.
    // @return: None
    //------------------------------
    public static void populateUniqueProductLoginContactId(TriggerParameters tp) {
        // Map of old values and new values
        Map<Id,ProductLoginContactAssociation__c> mapOldPLCA = (Map<Id,ProductLoginContactAssociation__c>) tp.oldMap;
        
        for(ProductLoginContactAssociation__c newPLCA : (List <ProductLoginContactAssociation__c>) tp.newList) {
            ProductLoginContactAssociation__c oldPLCA = new ProductLoginContactAssociation__c();
            if(tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {
                oldPLCA = mapOldPLCA.get(newPLCA.Id);
            }
            if(newPLCA.Contact__c != oldPLCA.Contact__c) {
                newPLCA.UniqueProductContactId__c = newPLCA.ProductLogin__c + '' + newPLCA.Contact__c;
            }
        }
    }
}