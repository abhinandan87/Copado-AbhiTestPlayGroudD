public class FieldServiceActivityOpportunityMethods {

    /*-----------------------------
    @Author: Shikhar Singh
    @Date: 03 June 2022
    @Description: FDC-5786 Update Opportunity on FSA based on linked FSAOpportunity with highest value
    @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    @return: Void
    -----------------------------*/
    public static void updateOpportunityOnFsa(TriggerParameters tp) {
        Set<Id> fsaIds = new Set<Id>();
        for(FieldServiceActivityOpportunity__c fsao: (List<FieldServiceActivityOpportunity__c>)tp.newList) {
            fsaIds.add(fsao.FieldServiceActivity__c);
        }
        
        // Get all FSA records idenitified above and fetch their highest value oppy
        List<WorkOrder> listOfFsaRecords = [Select Id,(SELECT Id,Opportunity__c from FieldServiceActivityOpportunities__r ORDER BY Opportunity__r.FirstYearValue__c DESC LIMIT 1)
                                            FROM WorkOrder WHERE ID IN: fsaIds];
        
        System.debug(listOfFsaRecords);
        
        //Create a Map of ID,ID with FSAId and OppyID
        Map<Id,Id> mapOfFsaFsao = new Map<Id,Id>();
        for(WorkOrder wo: listOfFsaRecords) {
            mapOfFsaFsao.put(wo.Id,wo.FieldServiceActivityOpportunities__r[0].Opportunity__c);
        }
  
        //Iterate over that map and update FSA record with highest value oppy
        List<WorkOrder> listOfWorkOrders = new List<WorkOrder>();
        for(Id mapIt1: mapOfFsaFsao.keySet()) {
        		listOfWorkOrders.add((new WorkOrder(Id= mapIt1,PrimaryOpportunityName__c=mapOfFsaFsao.get(mapIt1))));    
        }
        
        if(listOfWorkOrders.size()>0) {
            update listOfWorkOrders;
        }        
    }
    
    /*-----------------------------
    @Author: Shikhar Singh
    @Date: 03 June 2022
    @Description: SFDC-5786 Update Opportunity on FSA based on linked FSAOpportunity with highest value after deletion of FSAO Record
    @param: TriggerParameters Contains the trigger parameters which includes the record(s) that got updated.
    @return: Void
    -----------------------------*/
    public static void deleteOpportunityOnFsa(TriggerParameters tp) {
        Set<Id> fsaIds = new Set<Id>();
        for(FieldServiceActivityOpportunity__c fsao: (List<FieldServiceActivityOpportunity__c>)tp.oldList) {
            fsaIds.add(fsao.FieldServiceActivity__c);
        }
        
        // Get all FSA records idenitified above and fetch their highest value oppy
        List<WorkOrder> listOfFsaRecords = [Select Id,(SELECT Id,Opportunity__c from FieldServiceActivityOpportunities__r ORDER BY Opportunity__r.FirstYearValue__c DESC LIMIT 1)
                                            FROM WorkOrder WHERE ID IN: fsaIds];
        
        System.debug(listOfFsaRecords);
        
        //Create a Map of ID,ID with FSAId and OppyID
        Map<Id,Id> mapOfFsaFsao = new Map<Id,Id>();
        //Create a List to capture records with 0 FSAO left
        List<Id> blankWorkOrders = new List<Id>();
   		
        //Iterate over list of records and add to map or list accordingly as per above mentioned criteria
        for(WorkOrder wo: listOfFsaRecords) {
           	if(wo.FieldServiceActivityOpportunities__r.size()>0) {
            	mapOfFsaFsao.put(wo.Id,wo.FieldServiceActivityOpportunities__r[0].Opportunity__c);
            } else if (wo.FieldServiceActivityOpportunities__r.size() == 0) {
				blankWorkOrders.add(wo.Id);                
            }
        }    
  
        //Iterate over that map and update FSA record with highest value oppy
        List<WorkOrder> listOfWorkOrders = new List<WorkOrder>();
        for(Id mapIt1: mapOfFsaFsao.keySet()) {
        		listOfWorkOrders.add((new WorkOrder(Id= mapIt1,PrimaryOpportunityName__c=mapOfFsaFsao.get(mapIt1))));    
        }
        
        //Iterate over the list of blank records and update FSA record with blank oppy
        for(Id workO: blankWorkOrders) {
        		listOfWorkOrders.add((new WorkOrder(Id= workO,PrimaryOpportunityName__c=null)));    
        }
       
        if(listOfWorkOrders.size()>0) {
            update listOfWorkOrders;
        }        
    }

}