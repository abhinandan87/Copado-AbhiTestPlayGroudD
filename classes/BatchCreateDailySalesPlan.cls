/*  @author: Akash Punera
*   @date: 07 Mar 2022
*   @description: Batch class to Create daily Sales Plan records from monthly data
*/
public class BatchCreateDailySalesPlan implements Database.Batchable<sObject>,Database.Stateful {
    public boolean batchHasErrors = false;
    public map<String, set<String>> mapErrorRecord= new map<String, set<String>>();
    public set<String> errorLog= new set<String>();
    public String query;
    public Map<integer,integer> mapMonthToNumberOfDays;
    public Map<string,product2> mapProductGroupToProduct;
    public string subBusinesslineToExclude = system.label.SubBusinessLinesToExclude;
    
    /*  @author: Akash Punera
	*   @date: 7 Mar 2022
	*   @description: Initiate batch with Sales plan query and product map to populate hierarchy
	*/
    public Database.QueryLocator start(Database.BatchableContext BC) {
        //Map product group to product
        mapProductGroupToProduct = new map<String,product2>();
        set<String> setProductGroupsMapped = new Set<String>();
        for(Product2 objPro : [SELECT 	id, productGroup__r.name, businessLine2__r.name, SubBusinessLine__r.name, InternalBusinessSegment__c
                               FROM 	Product2
                               WHERE	isActive = true AND subbusinessline__c != null AND businessline2__c != null AND productgroup__c != null
                               ORDER BY createdDate Desc
                               LIMIT 50000]) {
                                   if(objPro.productGroup__c != null && !setProductGroupsMapped.contains(objPro.productGroup__r.name.toLowerCase()) && !subBusinesslineToExclude.containsIgnoreCase(objPro.SubBusinessLine__r.name)) {
                                       setProductGroupsMapped.add(objPro.productGroup__r.name.toLowerCase());
                                       mapProductGroupToProduct.put(objPro.productGroup__r.name.toLowerCase(), objPro);
                                   }
                               }
        //Populate MonthToNumberOfDays Map
        mapMonthToNumberOfDays = new Map<integer,integer>{ 1=>31, 2=>28, 3=>31, 4=>30, 5=>31, 6=>30, 7=>31, 8=>31, 9=>30, 10=>31, 11=>30, 12=>31};
        if(Date.isLeapYear(system.now().year())) {
           mapMonthToNumberOfDays.put(2, 29);
        }
        //Query all Sales Plan Records
        query = 'SELECT Id, Type__c, SubBusinessLine__c, Region__c, ProductGroup__c, ProductGroupName__c, Period__c, InternalBusinessSegment__c, ExternalId__c, BusinessLine__c, Amount__c FROM SalesPlan__c where MonthlySalesPlan__c = null';
        
        return Database.getQueryLocator(query);
    }
    
    /*  @author: Akash Punera
	*   @date: 7 Mar 2022
	*   @description: Batch execute to iterate on Sales plan records and process and update hierarchy
	*	@param: List of Sales Plan records to be updated
	*/
    public void execute(Database.BatchableContext BC, List<SalesPlan__c> scope) {
        try {
            List<SalesPlan__c> lstSalesPlanToUpsert = new List<SalesPlan__c>();
            for(SalesPlan__c objSp : scope) {
                lstSalesPlanToUpsert.add(updateSalesPlanFields(objSp));
                lstSalesPlanToUpsert.addAll(createDailyPlan(objSp));
            }
            
            upsertSalesPlan(lstSalesPlanToUpsert);

            
        } catch(Exception ex) {
            System.debug('Exception caught in batch'+ex.getMessage());
            UtilityClass.createApexLogRecord(ex, 'BatchCreateDailySalesPlan', 'Execute');       
        }
        
    }
    
    /*  @author: Akash Punera
	*   @date: 14 Mar 2022
	*   @description: Batch finish method to log errors if any during execution
	*/
    public void finish(Database.BatchableContext BC) { 
        System.debug(LoggingLevel.INFO, 'BatchCreateDailySalesPlan batch completed');
        if(batchHasErrors) {
            List<ApexLogger__c> apexloggerList= new List<ApexLogger__c>();
            for(String err:mapErrorRecord.keySet()) {
                List<String> errorvalues= new List<String>(mapErrorRecord.get(err));
                String recordIds=String.join(errorvalues,',').trim();
                Integer size= mapErrorRecord.get(err).size();
                String errormessage= 'Total records failed: '+size;
                ApexLogger__c apexLogRecord = new ApexLogger__c(ClassName__c='BatchCreateDailySalesPlan',ErrorDescription__c=err,LogRecordJson__c=recordIds,ErrorMessage__c=errormessage);
                apexloggerList.add(apexLogRecord);
            }
            insert apexloggerList;
            
        }
    }
    
    /*  @author: Akash Punera
	*   @date: 14 Mar 2022
	*   @description: Method to update hierarchy in Sales plan record based on hierarchy from active Product
	*	@param: Sales Plan Object to be updated with product hierarchy
	*/
    public SalesPlan__c updateSalesPlanFields(SalesPlan__c objSP) {
        if(mapProductGroupToProduct.containsKey(objSp.ProductGroupName__c.toLowerCase())) {
            Product2 pro = mapProductGroupToProduct.get(objSp.ProductGroupName__c.toLowerCase());
            objSp.BusinessLine__c = pro.businessline2__c;
            objSp.subBusinessLine__c = pro.subbusinessline__c;
            objSp.InternalBusinessSegment__c = pro.InternalBusinessSegment__c;
            objSp.ProductGroup__c = pro.ProductGroup__c;
        }
        return objSp;
    }
    
    /*  @author: Akash Punera
	*   @date: 14 Mar 2022
	*   @description: Method to Create daily sales plan from monthly plan data
	*	@param: Monthly Sales Plan Object
	*/
    public list<SalesPLan__c> createDailyPlan(SalesPlan__c objSp) {
        List<SalesPlan__c> lstSalesPlanToUpsert = new List<SalesPlan__c>();
        if(objSp.Period__c != null) {
            integer numberOfDays = mapMonthToNumberOfDays.get(objSp.Period__c.month());
            for(integer i = 1; i <= mapMonthToNumberOfDays.get(objSp.Period__c.month()) ; i++) {
                SalesPlan__c dailyPlan = new SalesPlan__c();
                dailyPlan.Type__c = objSp.type__c;
                dailyPlan.SubBusinessLine__c = objSp.SubBusinessLine__c;
                dailyPlan.Region__c = objSp.Region__c;
                dailyPlan.ProductGroup__c = objSp.ProductGroup__c;
                dailyPlan.ProductGroupName__c = objSp.ProductGroupName__c;
                dailyPlan.Period__c = Date.newInstance(objSp.Period__c.year(), objSp.Period__c.month(), i);
                dailyPlan.InternalBusinessSegment__c = objSp.InternalBusinessSegment__c;
                dailyPlan.ExternalId__c = objSp.ExternalId__c+'_'+i;
                dailyPlan.BusinessLine__c = objSp.BusinessLine__c;
                dailyPlan.Amount__c = objSp.Amount__c/numberOfDays;     
                dailyPlan.MonthlySalesPlan__c = objSp.id;
                lstSalesPlanToUpsert.add(dailyPlan);
            }
        }
        return lstSalesPlanToUpsert;
    }
    
    /*  @author: Akash Punera
	*   @date: 14 Mar 2022
	*   @description: Method to upsert Sales Plan records
	*	@param: List of Sales plan records to be upserted
	*/
    public void upsertSalesPlan(List<SalesPlan__c> lstSalesPlanToUpsert) {
        if(lstSalesPlanToUpsert.size() > 0) {
                Database.upsertResult[] urList = database.upsert(lstSalesPlanToUpsert, salesPlan__c.ExternalId__c, false);
                Integer counter=0;
                for (Database.upsertResult ur : urList) {                    
                    if (!ur.isSuccess()) {                        
                        for(Database.Error err : ur.getErrors()) {
                            String error= err.getMessage();
                            batchHasErrors = true;
                            errorLog.add(err.getMessage());
                            if(!mapErrorRecord.containsKey(error)) {
                                mapErrorRecord.put(error, new set<String>());
                            }
                            mapErrorRecord.get(error).add(lstSalesPlanToUpsert[counter].Id);
                        }
                    }
                    counter++;
                }
            }
    }
}