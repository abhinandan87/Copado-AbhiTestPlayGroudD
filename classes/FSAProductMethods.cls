//*********************************************************************************************************************
// @author Vaishali Jain
// @date 4th June 2021
// @description Class created to add common methods to be used by FSA Product trigger handler classes
//*********************************************************************************************************************

public class FSAProductMethods {
    
    /**
     * @author Vaishali Jain
     * @date 4th June 2021
     * @description when the FSA Product is updated,
     * Concatenate FSA Product name to ProductGroup on FSA when FSA Product is inserted or updated
     */
    public static void updateFSAProductGroups(TriggerParameters tp) {
    
        //create a set to store the product Group record Ids
        Set<Id> FSAIdSet = new Set<Id>();
        List<String> ProductNameList = new List<String> ();
        List<WorkOrder> fsaListUpdate = new List<WorkOrder> ();
        if (tp.tEvent == TriggerParameters.TriggerEvent.afterInsert) {
            for(FieldServiceActivityProduct__c fsaProd: (List<FieldServiceActivityProduct__c>)tp.newList) {
                if(fsaProd.FieldServiceActivity__c != null) {
                    FSAIdSet.add(fsaProd.FieldServiceActivity__c);
                }
            }
            List<WorkOrder> fsaList = [Select id, ProductGroups__c,(Select name,ProductGroup__r.Name from FieldServiceActivityProducts__r) FROM WorkOrder Where Id IN :FSAIdSet];
            System.debug(' ===fsaList 28 == '+fsaList);
            for(WorkOrder wo : fsaList) {
                for(FieldServiceActivityProduct__c fsaProd : wo.FieldServiceActivityProducts__r) {
                    ProductNameList.add(fsaProd.ProductGroup__r.Name);
                    System.debug(' ===ProductNameList 32 == '+ProductNameList);
                }
                wo.ProductGroups__c = String.join(ProductNameList,',');
                System.debug(' ===ProductGroups__c 35 == '+wo.ProductGroups__c);
                fsaListUpdate.add(wo);
            }
            
            if(fsaListUpdate.size() > 0) {
                update fsaListUpdate;
            }
        }
    }    

}