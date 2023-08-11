//-----------------------------
// @author: Harshit Singhal
// @date: 04 Sep 2019
// @param: NA
// @description: SFDC-1808 Generate custom relationship in order to group line items in multi-year order form contracts in drawloop document
// @company: IHS Markit
// @return: None
//------------------------------
global class OrderFormMultiYearData implements Loop.IApexDataSource {
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 04 Sep 2019
    // @param: void
    // @description: SFDC-1808 Method to declare objects for Drawloop
    // @company: IHS Markit
    // @return: Set<String> Set of objects setup for Drawloop
    //------------------------------
    public Set<string> getGlobalDescribe() {
        return new Set<String>{'Totals','LineItemDetails'};
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 04 Sep 2019
    // @param: List <string >objNames list of objects to be defined
    // @description: SFDC-1808 Method to create definition of Totals and LineItemDetails objects for Drawloop declared above
    // @company: IHS Markit
    // @return: List <Loop.ExternalData.DataObject > a list of objects defined using loop api
    //------------------------------
    public List<Loop.ExternalData.DataObject> describeObjects(List<string> objNames) {
        List<Loop.ExternalData.DataObject> output = new List<Loop.ExternalData.DataObject>();

        for (string objName : objNames) {
            List<Loop.ExternalData.FieldInfo> outputFields = new List<Loop.ExternalData.FieldInfo>();
            if(objName == 'Totals') {                
                outputFields.add(new Loop.ExternalData.FieldInfo('Id', Schema.DisplayType.ID));
                outputFields.add(new Loop.ExternalData.FieldInfo('NumberOfYears', Schema.DisplayType.INTEGER));
                
                Loop.ExternalData.FieldInfo year1TotalPriceOutputInfo = new Loop.ExternalData.FieldInfo('Year1TotalPrice', Schema.DisplayType.CURRENCY);
                year1TotalPriceOutputInfo.scale = 2;
                outputFields.add(year1TotalPriceOutputInfo);
                
                Loop.ExternalData.FieldInfo year2TotalPriceOutputInfo = new Loop.ExternalData.FieldInfo('Year2TotalPrice', Schema.DisplayType.CURRENCY);
                year2TotalPriceOutputInfo.scale = 2;
                outputFields.add(year2TotalPriceOutputInfo);
                
                Loop.ExternalData.FieldInfo year3TotalPriceOutputInfo = new Loop.ExternalData.FieldInfo('Year3TotalPrice', Schema.DisplayType.CURRENCY);
                year3TotalPriceOutputInfo.scale = 2;
                outputFields.add(year3TotalPriceOutputInfo);
                
                Loop.ExternalData.FieldInfo year4TotalPriceOutputInfo = new Loop.ExternalData.FieldInfo('Year4TotalPrice', Schema.DisplayType.CURRENCY);
                year4TotalPriceOutputInfo.scale = 2;
                outputFields.add(year4TotalPriceOutputInfo);
                
                Loop.ExternalData.FieldInfo year5TotalPriceOutputInfo = new Loop.ExternalData.FieldInfo('Year5TotalPrice', Schema.DisplayType.CURRENCY);
                year5TotalPriceOutputInfo.scale = 2;
                outputFields.add(year5TotalPriceOutputInfo);
                
                Loop.ExternalData.FieldInfo allYearsTotalPriceOutputInfo = new Loop.ExternalData.FieldInfo('AllYearsTotalPrice', Schema.DisplayType.CURRENCY);
                allYearsTotalPriceOutputInfo.scale = 2;
                outputFields.add(allYearsTotalPriceOutputInfo);
                
                outputFields.add(new Loop.ExternalData.FieldInfo('CurrencyIsoCode', Schema.DisplayType.STRING));
            }
            else if(objName == 'LineItemDetails') {
                outputFields.add(new Loop.ExternalData.FieldInfo('ProductName', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('ProductCode', Schema.DisplayType.STRING));
                outputFields.add(new Loop.ExternalData.FieldInfo('StartDate', Schema.DisplayType.DATE));
                                
                Loop.ExternalData.FieldInfo year1PriceOutputInfo = new Loop.ExternalData.FieldInfo('Year1Price', Schema.DisplayType.CURRENCY);
                year1PriceOutputInfo.scale = 2;
                outputFields.add(year1PriceOutputInfo);
                
                Loop.ExternalData.FieldInfo year2PriceOutputInfo = new Loop.ExternalData.FieldInfo('Year2Price', Schema.DisplayType.CURRENCY);
                year2PriceOutputInfo.scale = 2;
                outputFields.add(year2PriceOutputInfo);
                                
                Loop.ExternalData.FieldInfo year3PriceOutputInfo = new Loop.ExternalData.FieldInfo('Year3Price', Schema.DisplayType.CURRENCY);
                year3PriceOutputInfo.scale = 2;
                outputFields.add(year3PriceOutputInfo);
                
                Loop.ExternalData.FieldInfo year4PriceOutputInfo = new Loop.ExternalData.FieldInfo('Year4Price', Schema.DisplayType.CURRENCY);
                year4PriceOutputInfo.scale = 2;
                outputFields.add(year4PriceOutputInfo);
                
                Loop.ExternalData.FieldInfo year5PriceOutputInfo = new Loop.ExternalData.FieldInfo('Year5Price', Schema.DisplayType.CURRENCY);
                year5PriceOutputInfo.scale = 2;
                outputFields.add(year5PriceOutputInfo);
                
                Loop.ExternalData.FieldInfo cliAllYearsTotalPriceOutputInfo = new Loop.ExternalData.FieldInfo('AllYearsTotalPrice', Schema.DisplayType.CURRENCY);
                cliAllYearsTotalPriceOutputInfo.scale = 2;
                outputFields.add(cliAllYearsTotalPriceOutputInfo);
                
                outputFields.add(new Loop.ExternalData.FieldInfo('CurrencyIsoCode', Schema.DisplayType.STRING));

                Loop.ExternalData.FieldInfo referenceOutputInfo = new Loop.ExternalData.FieldInfo('TotalsReference', Schema.DisplayType.REFERENCE);
                referenceOutputInfo.referenceTo = 'Totals';                
                outputFields.add(referenceOutputInfo);
            }
            output.add(new Loop.ExternalData.DataObject(objName, outputFields));
        }
        return output;
    }
	
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 04 Sep 2019
    // @param: String Objectname object name for which children object are to be fetched
    // @description: SFDC-1808 Method to establish parent-child relationship between Totals and LineItemDetails objects
    // @company: IHS Markit
    // @return: Set<String> return a list of children object related to an object defined via Loop API
    //------------------------------
    public Set<string> getChildRelationships(string objectName) {
        Set<string> childObjectNames = new Set<string>();
        if (objectName == 'Totals') {
            childObjectNames.add('LineItemDetails');
        }            
        return childObjectNames;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 04 Sep 2019
    // @param: Loop.ExternalData.QueryRequestInfo requestInfo loop request param
    // @description: SFDC-1808 Method to query data from Salesforce and add it to custom drawloop objects Totals and LineItemDetails
    // @company: IHS Markit
    // @return: Loop.ExternalData.QueryResultSet resultset contains all the data required to establish relationship
    //------------------------------
    public Loop.ExternalData.QueryResultSet query(Loop.ExternalData.QueryRequestInfo requestInfo) {
        System.debug('requestInfo='+requestInfo);
        Loop.ExternalData.QueryResultSet results = new Loop.ExternalData.QueryResultSet();
        
        Loop.ExternalData.QueryResult qrTotals = new Loop.ExternalData.QueryResult('Totals', new List<string> { 'Id', 'NumberOfYears', 'Year1TotalPrice', 'Year2TotalPrice', 'Year3TotalPrice', 'Year4TotalPrice', 'Year5TotalPrice', 'AllYearsTotalPrice', 'CurrencyIsoCode' });
        Loop.ExternalData.QueryResult qrLineItemDetails = new Loop.ExternalData.QueryResult('LineItemDetails', new List<string> { 'ProductName', 'ProductCode', 'StartDate', 'Year1Price', 'Year2Price', 'Year3Price', 'Year4Price', 'Year5Price', 'AllYearsTotalPrice', 'CurrencyIsoCode', 'TotalsReference' });
        
        if(string.valueOf(requestInfo.RecordId).startswith(Schema.sObjectType.Contract.keyprefix)) {
            //Prepare Year and year counter map
            Map<String, Integer> yearCounterMap = new Map<String, Integer>();
            Integer yearCounter = 0;
            for(AggregateResult ar: [SELECT InstallmentYear__c 
                                     FROM ContractLineItemSchedule__c WHERE Contract__c = :requestInfo.RecordId
                                     Group By InstallmentYear__c
                                     Order By InstallmentYear__c ASC]) {                                                          
                                         yearCounter++;
                                         yearCounterMap.put(String.valueOf(ar.get('InstallmentYear__c')), yearCounter);                                                          
            }
            System.debug('yearCounterMap='+yearCounterMap);
            
            //Prepare Totals Wrapper object
            TotalsWrapper totWrpObj = new TotalsWrapper(requestInfo.RecordId, yearCounterMap.size());
            
            //Prepare LineItemWrapper map
            Map<Id,LineItemDetailsWrapper> cliIdItemDetailsMap = new Map<Id,LineItemDetailsWrapper>();
            for(ContractLineItemSchedule__c clisObj: [SELECT Id, InstallmentYear__c, Contract__c, Contract__r.CurrencyIsoCode, ContractLineItem__c, ContractLineItem__r.Name, ContractLineItem__r.MaterialCode__c, ContractLineItem__r.StartDate__c, SalesPrice__c, CurrencyIsoCode
                                                      FROM ContractLineItemSchedule__c WHERE Contract__c = :requestInfo.RecordId 
                                                      ORDER BY ContractLineItem__r.Name, InstallmentYear__c ASC]) {                                                          
                                                          LineItemDetailsWrapper liWrapObj = cliIdItemDetailsMap.containsKey(clisObj.ContractLineItem__c) ? cliIdItemDetailsMap.get(clisObj.ContractLineItem__c) : new LineItemDetailsWrapper(clisObj.Contract__c, clisObj.ContractLineItem__c, clisObj.ContractLineItem__r.Name, clisObj.ContractLineItem__r.MaterialCode__c, clisObj.ContractLineItem__r.StartDate__c, clisObj.CurrencyIsoCode); 
                                                          //Set Respective Year Price
                                                          setRespectiveYearPrice(totWrpObj, liWrapObj, clisObj.InstallmentYear__c, clisObj.SalesPrice__c, yearCounterMap);
                                                          cliIdItemDetailsMap.put(clisObj.ContractLineItem__c, liWrapObj);
                                                          
                                                          totWrpObj.currencyIsoCode = clisObj.Contract__r.CurrencyIsoCode;
                                                      }
            
            //Setup data in docgen queryResults
            if(totWrpObj!=null) {
                qrTotals.rows.add(new List<String> { String.valueOf(totWrpObj.contractId), String.valueOf(totWrpObj.numOfYears), String.valueOf(totWrpObj.year1TotalPrice), String.valueOf(totWrpObj.year2TotalPrice), String.valueOf(totWrpObj.year3TotalPrice), String.valueOf(totWrpObj.year4TotalPrice), String.valueOf(totWrpObj.year5TotalPrice), String.valueOf(totWrpObj.ctrctTotalPrice), totWrpObj.currencyIsoCode });
            }
            for(LineItemDetailsWrapper wrObj: cliIdItemDetailsMap.values()) {
                qrLineItemDetails.rows.add(new List<String> { wrObj.prodName, wrObj.prodCode, String.valueOf(wrObj.startDate), String.valueOf(wrObj.year1Price), String.valueOf(wrObj.year2Price), String.valueOf(wrObj.year3Price), String.valueOf(wrObj.year4Price), String.valueOf(wrObj.year5Price), String.valueOf(wrObj.totalCLIPrice), wrObj.currencyIsoCode, wrObj.ctrctId });
            }
        }
        //Setup Apex Results
        for (string objectName : requestInfo.GetObjectNames()) {
            System.debug('objectName='+objectName);
            if (objectName == 'Totals') {
                results.add(qrTotals);
            }                
            if (objectName == 'LineItemDetails') {
                System.debug('qrLineItemDetails='+qrLineItemDetails);
                results.add(qrLineItemDetails);
            }                
        }
        System.debug('Apex Data Results='+results);
        
        return results;
    }
	
	//-----------------------------
    // @author: Harshit Singhal
    // @date: 04 Sep 2019
    // @param: TotalsWrapper class instance, LineItemDetailsWrapper class instance, instalment year of CLI schedule, price of CLI schedule, Map of Year and year counter
    // @description: SFDC-1808 Helper Method to initialise price variables in TotalsWrapper and LineItemDetailsWrapper classes
    // @company: IHS Markit
    // @return: null
    //------------------------------    
    public void setRespectiveYearPrice(TotalsWrapper totObj, LineItemDetailsWrapper liObj, String instYear, Decimal price, Map<String, Integer> yrCounterMap) {
        if(liObj!=null && yrCounterMap.containsKey(instYear) && price!=null) {
            switch on yrCounterMap.get(instYear) {
                when 1 {                    
                    liObj.year1Price = price;
                    totObj.year1TotalPrice = totObj.year1TotalPrice==null ? price : totObj.year1TotalPrice+price;
                }
                when 2 {
                    liObj.year2Price = price;
                    totObj.year2TotalPrice = totObj.year2TotalPrice==null ? price : totObj.year2TotalPrice+price;
                }
                when 3 {
                    liObj.year3Price = price;
                    totObj.year3TotalPrice = totObj.year3TotalPrice==null ? price : totObj.year3TotalPrice+price;
                }
                when 4 {
                    liObj.year4Price = price;
                    totObj.year4TotalPrice = totObj.year4TotalPrice==null ? price : totObj.year4TotalPrice+price;
                }
                when 5 {
                    liObj.year5Price = price;
                    totObj.year5TotalPrice = totObj.year5TotalPrice==null ? price : totObj.year5TotalPrice+price;
                }
            }
        }
    }
    
    //Wrapper class to store totals of all products
    public class TotalsWrapper {
        Id contractId;
        Integer numOfYears;
        public Decimal year1TotalPrice,year2TotalPrice,year3TotalPrice,year4TotalPrice,year5TotalPrice;
        public Decimal ctrctTotalPrice {
            get {
                Decimal tempPrice = 0.0;
                if(year1TotalPrice != null) {
                    tempPrice += year1TotalPrice;
                }
                if(year2TotalPrice != null) {
                    tempPrice += year2TotalPrice;
                }
                if(year3TotalPrice != null) {
                    tempPrice += year3TotalPrice;
                }
                if(year4TotalPrice != null) {
                    tempPrice += year4TotalPrice;
                }
                if(year5TotalPrice != null) {
                    tempPrice += year5TotalPrice;
                }
                return tempPrice;                
            }
            set;
        }
        public String currencyIsoCode;
        public TotalsWrapper(Id ctrctId, Integer yearNum) {
            contractId = ctrctId;
            numOfYears = yearNum;
        }
    }
    
    //Wrapper class to store details of each product
	public class LineItemDetailsWrapper {
        Id ctrctId, cliId;
        String prodName, prodCode, currencyIsoCode;
        Date startDate;
        public Decimal year1Price,year2Price,year3Price,year4Price,year5Price,cliTotalPrice;
        public Integer yearCounter = 0;
        public Decimal totalCLIPrice {
            get {
                Decimal tempPrice = 0.0;
                if(year1Price != null) {
                    tempPrice += year1Price;
                }
                if(year2Price != null) {
                    tempPrice += year2Price;
                }
                if(year3Price != null) {
                    tempPrice += year3Price;
                }
                if(year4Price != null) {
                    tempPrice += year4Price;
                }
                if(year5Price != null) {
                    tempPrice += year5Price;
                }
                return tempPrice;
            }
            set;
        }
        public LineItemDetailsWrapper(Id ctrtId, Id lineItemId, String prdName, String prdCode, Date strtDate, String currencyCode) {
            ctrctId=ctrtId;
            cliId=lineItemId;
            prodName=prdName;
            prodCode=prdCode;
            startDate=strtDate;
            currencyIsoCode=currencyCode;
        }
    }   

}