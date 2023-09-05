//-----------------------------
// @author: Harshit Singhal
// @date: 10 Jun 2020
// @param: NA
// @description: SFDC-1810 Update multi-year DEF product line items section layout. This class generates data in custom wrapper for that new concise layout.
// @company: IHS Markit
// @return: None
//------------------------------
global class DataEntryFormMultiYearData implements Loop.IApexDataSource {
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 10 Jun 2020
    // @param: void
    // @description: SFDC-1810 Method to declare objects for Drawloop
    // @company: IHS Markit
    // @return: Set<String> Set of objects setup for Drawloop
    //------------------------------
    public Set<string> getGlobalDescribe() {
        return new Set<String>{'Totals','LineItemDetails'};
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 10 Jun 2020
    // @param: List <string >objNames list of objects to be defined
    // @description: SFDC-1810 Method to create definition of Totals and LineItemDetails objects for Drawloop declared above
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
                
                outputFields.add(new Loop.ExternalData.FieldInfo('EndDate', Schema.DisplayType.DATE));                
                                
                outputFields.add(new Loop.ExternalData.FieldInfo('InstallmentYear1', Schema.DisplayType.INTEGER));
                Loop.ExternalData.FieldInfo year1ListPriceOutputInfo = new Loop.ExternalData.FieldInfo('Year1ExtListPrice', Schema.DisplayType.CURRENCY);
                year1ListPriceOutputInfo.scale = 2;
                outputFields.add(year1ListPriceOutputInfo);
                Loop.ExternalData.FieldInfo year1DiscOutputInfo = new Loop.ExternalData.FieldInfo('Year1Discount', Schema.DisplayType.CURRENCY);
                year1DiscOutputInfo.scale = 2;
                outputFields.add(year1DiscOutputInfo);
                Loop.ExternalData.FieldInfo year1PriceOutputInfo = new Loop.ExternalData.FieldInfo('Year1Price', Schema.DisplayType.CURRENCY);
                year1PriceOutputInfo.scale = 2;
                outputFields.add(year1PriceOutputInfo);
                
                outputFields.add(new Loop.ExternalData.FieldInfo('InstallmentYear2', Schema.DisplayType.INTEGER));
                Loop.ExternalData.FieldInfo year2ListPriceOutputInfo = new Loop.ExternalData.FieldInfo('Year2ExtListPrice', Schema.DisplayType.CURRENCY);
                year2ListPriceOutputInfo.scale = 2;
                outputFields.add(year2ListPriceOutputInfo);
                Loop.ExternalData.FieldInfo year2DiscOutputInfo = new Loop.ExternalData.FieldInfo('Year2Discount', Schema.DisplayType.CURRENCY);
                year2DiscOutputInfo.scale = 2;
                outputFields.add(year2DiscOutputInfo);
                Loop.ExternalData.FieldInfo year2PriceOutputInfo = new Loop.ExternalData.FieldInfo('Year2Price', Schema.DisplayType.CURRENCY);
                year2PriceOutputInfo.scale = 2;
                outputFields.add(year2PriceOutputInfo);
                
                outputFields.add(new Loop.ExternalData.FieldInfo('InstallmentYear3', Schema.DisplayType.INTEGER));
                Loop.ExternalData.FieldInfo year3ListPriceOutputInfo = new Loop.ExternalData.FieldInfo('Year3ExtListPrice', Schema.DisplayType.CURRENCY);
                year3ListPriceOutputInfo.scale = 2;
                outputFields.add(year3ListPriceOutputInfo);
                Loop.ExternalData.FieldInfo year3DiscOutputInfo = new Loop.ExternalData.FieldInfo('Year3Discount', Schema.DisplayType.CURRENCY);
                year3DiscOutputInfo.scale = 2;
                outputFields.add(year3DiscOutputInfo);
                Loop.ExternalData.FieldInfo year3PriceOutputInfo = new Loop.ExternalData.FieldInfo('Year3Price', Schema.DisplayType.CURRENCY);
                year3PriceOutputInfo.scale = 2;
                outputFields.add(year3PriceOutputInfo);
                
                outputFields.add(new Loop.ExternalData.FieldInfo('InstallmentYear4', Schema.DisplayType.INTEGER));
                Loop.ExternalData.FieldInfo year4ListPriceOutputInfo = new Loop.ExternalData.FieldInfo('Year4ExtListPrice', Schema.DisplayType.CURRENCY);
                year4ListPriceOutputInfo.scale = 2;
                outputFields.add(year4ListPriceOutputInfo);
                Loop.ExternalData.FieldInfo year4DiscOutputInfo = new Loop.ExternalData.FieldInfo('Year4Discount', Schema.DisplayType.CURRENCY);
                year4DiscOutputInfo.scale = 2;
                outputFields.add(year4DiscOutputInfo);
                Loop.ExternalData.FieldInfo year4PriceOutputInfo = new Loop.ExternalData.FieldInfo('Year4Price', Schema.DisplayType.CURRENCY);
                year4PriceOutputInfo.scale = 2;
                outputFields.add(year4PriceOutputInfo);
                
                outputFields.add(new Loop.ExternalData.FieldInfo('InstallmentYear5', Schema.DisplayType.INTEGER));
                Loop.ExternalData.FieldInfo year5ListPriceOutputInfo = new Loop.ExternalData.FieldInfo('Year5ExtListPrice', Schema.DisplayType.CURRENCY);
                year5ListPriceOutputInfo.scale = 2;
                outputFields.add(year5ListPriceOutputInfo);
                Loop.ExternalData.FieldInfo year5DiscOutputInfo = new Loop.ExternalData.FieldInfo('Year5Discount', Schema.DisplayType.CURRENCY);
                year5DiscOutputInfo.scale = 2;
                outputFields.add(year5DiscOutputInfo);
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
    // @date: 10 Jun 2020
    // @param: String Objectname object name for which children object are to be fetched
    // @description: SFDC-1810 Method to establish parent-child relationship between Totals and LineItemDetails objects
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
    // @date: 10 Jun 2020
    // @param: Loop.ExternalData.QueryRequestInfo requestInfo loop request param
    // @description: SFDC-1810 Method to query data from Salesforce and add it to custom drawloop objects Totals and LineItemDetails
    // @company: IHS Markit
    // @return: Loop.ExternalData.QueryResultSet resultset contains all the data required to establish relationship
    //------------------------------
    public Loop.ExternalData.QueryResultSet query(Loop.ExternalData.QueryRequestInfo requestInfo) {
        //System.debug('requestInfo='+requestInfo);
        //System.debug('requestInfo.RecordId='+requestInfo.RecordId);
        Id contractId;
        if(string.valueOf(requestInfo.RecordId).startswith(Schema.sObjectType.Case.keyprefix)) {
            contractId = [SELECT Contract__c FROM Case WHERE Id=:requestInfo.RecordId AND Contract__c!=null LIMIT 1].Contract__c;
        }        
        
        Loop.ExternalData.QueryResultSet results = new Loop.ExternalData.QueryResultSet();
        
        Loop.ExternalData.QueryResult qrTotals = new Loop.ExternalData.QueryResult('Totals', new List<string> { 'Id', 'NumberOfYears', 'Year1TotalPrice', 'Year2TotalPrice', 'Year3TotalPrice', 'Year4TotalPrice', 'Year5TotalPrice', 'AllYearsTotalPrice', 'CurrencyIsoCode' });
        Loop.ExternalData.QueryResult qrLineItemDetails = new Loop.ExternalData.QueryResult('LineItemDetails', new List<string> { 'ProductName', 'ProductCode', 'StartDate', 'EndDate', 'InstallmentYear1', 'Year1ExtListPrice', 'Year1Discount', 'Year1Price', 'InstallmentYear2', 'Year2ExtListPrice', 'Year2Discount', 'Year2Price', 'InstallmentYear3', 'Year3ExtListPrice', 'Year3Discount', 'Year3Price', 'InstallmentYear4', 'Year4ExtListPrice', 'Year4Discount', 'Year4Price', 'InstallmentYear5', 'Year5ExtListPrice', 'Year5Discount', 'Year5Price', 'AllYearsTotalPrice', 'CurrencyIsoCode', 'TotalsReference' });
        
        if(contractId!=null && string.valueOf(contractId).startswith(Schema.sObjectType.Contract.keyprefix)) {
            //Prepare Year and year counter map
            Map<String, Integer> yearCounterMap = new Map<String, Integer>();
            Integer yearCounter = 0;
            for(AggregateResult ar: [SELECT InstallmentYear__c 
                                     FROM ContractLineItemSchedule__c WHERE Contract__c = :contractId
                                     Group By InstallmentYear__c
                                     Order By InstallmentYear__c ASC]) {                                                          
                                         yearCounter++;
                                         yearCounterMap.put(String.valueOf(ar.get('InstallmentYear__c')), yearCounter);                                                          
            }           
            
            //Prepare Totals Wrapper object
            TotalsWrapper totWrpObj = new TotalsWrapper(contractId, yearCounterMap.size());
            
            //Prepare LineItemWrapper map
            Map<Id,LineItemDetailsWrapper> cliIdItemDetailsMap = new Map<Id,LineItemDetailsWrapper>();
            for(ContractLineItemSchedule__c clisObj: [SELECT Id, InstallmentYear__c, Contract__c, Contract__r.CurrencyIsoCode, ContractLineItem__c, ContractLineItem__r.Name, 
                                                      ContractLineItem__r.MaterialCode__c, ContractLineItem__r.StartDate__c, ContractLineItem__r.EndDate__c, ExternalListPrice__c, DiscountAmount__c, SalesPrice__c, CurrencyIsoCode
                                                      FROM ContractLineItemSchedule__c WHERE Contract__c = :contractId 
                                                      ORDER BY ContractLineItem__r.Name, InstallmentYear__c,ContractLineItem__r.LineItemNumber__c ASC]) {                                                          
                                                          //LineItemDetailsWrapper liWrapObj = cliIdItemDetailsMap.containsKey(clisObj.ContractLineItem__c) ? cliIdItemDetailsMap.get(clisObj.ContractLineItem__c) : new LineItemDetailsWrapper(clisObj.Contract__c, clisObj.ContractLineItem__c, clisObj.ContractLineItem__r.Name, clisObj.ContractLineItem__r.MaterialCode__c, clisObj.ContractLineItem__r.StartDate__c, clisObj.CurrencyIsoCode); 
                                                          LineItemDetailsWrapper liWrapObj = cliIdItemDetailsMap.containsKey(clisObj.ContractLineItem__c) ? cliIdItemDetailsMap.get(clisObj.ContractLineItem__c) : new LineItemDetailsWrapper(clisObj.Contract__c, clisObj.ContractLineItem__c, clisObj.ContractLineItem__r.Name, clisObj.ContractLineItem__r.MaterialCode__c, 
                                                                                                                                                                                                                                              clisObj.ContractLineItem__r.StartDate__c,clisObj.ContractLineItem__r.EndDate__c, clisObj.CurrencyIsoCode); 
                                                          //Set Respective Year Price
                                                          setRespectiveYearPrice(totWrpObj, liWrapObj, clisObj.InstallmentYear__c, clisObj.ExternalListPrice__c, clisObj.DiscountAmount__c, clisObj.SalesPrice__c, yearCounterMap);
                                                          cliIdItemDetailsMap.put(clisObj.ContractLineItem__c, liWrapObj);
                                                          
                                                          totWrpObj.currencyIsoCode = clisObj.Contract__r.CurrencyIsoCode;
                                                      }
            
            //Setup data in docgen queryResults
            if(totWrpObj!=null) {
                qrTotals.rows.add(new List<String> { String.valueOf(totWrpObj.contractId), String.valueOf(totWrpObj.numOfYears), String.valueOf(totWrpObj.year1TotalPrice), String.valueOf(totWrpObj.year2TotalPrice), String.valueOf(totWrpObj.year3TotalPrice), String.valueOf(totWrpObj.year4TotalPrice), String.valueOf(totWrpObj.year5TotalPrice), String.valueOf(totWrpObj.ctrctTotalPrice), totWrpObj.currencyIsoCode });
            }
            for(LineItemDetailsWrapper wrObj: cliIdItemDetailsMap.values()) {
                qrLineItemDetails.rows.add(new List<String> { wrObj.prodName, wrObj.prodCode, String.valueOf(wrObj.startDate), String.valueOf(wrObj.endDate), String.valueOf(wrObj.year1), String.valueOf(wrObj.year1ExtListPrice), String.valueOf(wrObj.year1DiscPrice), String.valueOf(wrObj.year1Price), String.valueOf(wrObj.year2), String.valueOf(wrObj.year2ExtListPrice), String.valueOf(wrObj.year2DiscPrice), String.valueOf(wrObj.year2Price), String.valueOf(wrObj.year3), String.valueOf(wrObj.year3ExtListPrice), String.valueOf(wrObj.year3DiscPrice), String.valueOf(wrObj.year3Price), String.valueOf(wrObj.year4), String.valueOf(wrObj.year4ExtListPrice), String.valueOf(wrObj.year4DiscPrice), String.valueOf(wrObj.year4Price), String.valueOf(wrObj.year5), String.valueOf(wrObj.year5ExtListPrice), String.valueOf(wrObj.year5DiscPrice), String.valueOf(wrObj.year5Price), String.valueOf(wrObj.totalCLIPrice), wrObj.currencyIsoCode, wrObj.ctrctId });
            }
        }
        //Setup Apex Results
        for (string objectName : requestInfo.GetObjectNames()) {
            System.debug('objectName='+objectName);
            if (objectName == 'Totals') {
                results.add(qrTotals);
            }                
            if (objectName == 'LineItemDetails') {
                //System.debug('qrLineItemDetails='+qrLineItemDetails);
                results.add(qrLineItemDetails);
            }                
        }
        //System.debug('Apex Data Results='+results);
        
        return results;
    }
	
	//-----------------------------
    // @author: Harshit Singhal
    // @date: 10 Jun 2020
    // @param: TotalsWrapper class instance, LineItemDetailsWrapper class instance, instalment year of CLI schedule, price of CLI schedule, Map of Year and year counter
    // @description: SFDC-1810 Helper Method to initialise price variables in TotalsWrapper and LineItemDetailsWrapper classes
    // @company: IHS Markit
    // @return: null
    //------------------------------    
    public void setRespectiveYearPrice(TotalsWrapper totObj, LineItemDetailsWrapper liObj, String instYear, Decimal extListPrice, Decimal discPrice, Decimal price, Map<String, Integer> yrCounterMap) {
        if(liObj!=null && yrCounterMap.containsKey(instYear) && price!=null) {
            switch on yrCounterMap.get(instYear) {
                when 1 {                    
                    liObj.year1 = Integer.valueOf(instYear);
                    liObj.year1ExtListPrice = extListPrice;
                    liObj.year1Price = price;
                    liObj.year1DiscPrice = discPrice;
                    totObj.year1TotalPrice = totObj.year1TotalPrice==null ? price : totObj.year1TotalPrice+price;
                }
                when 2 {
                    liObj.year2 = Integer.valueOf(instYear);
                    liObj.year2ExtListPrice = extListPrice;
                    liObj.year2Price = price;
                    liObj.year2DiscPrice = discPrice;
                    totObj.year2TotalPrice = totObj.year2TotalPrice==null ? price : totObj.year2TotalPrice+price;
                }
                when 3 {
                    liObj.year3 = Integer.valueOf(instYear);
                    liObj.year3ExtListPrice = extListPrice;
                    liObj.year3Price = price;
                    liObj.year3DiscPrice = discPrice;
                    totObj.year3TotalPrice = totObj.year3TotalPrice==null ? price : totObj.year3TotalPrice+price;
                }
                when 4 {
                    liObj.year4 = Integer.valueOf(instYear);
                    liObj.year4ExtListPrice = extListPrice;
                    liObj.year4Price = price;
                    liObj.year4DiscPrice = discPrice;
                    totObj.year4TotalPrice = totObj.year4TotalPrice==null ? price : totObj.year4TotalPrice+price;
                }
                when 5 {
                    liObj.year5 = Integer.valueOf(instYear);
                    liObj.year5ExtListPrice = extListPrice;
                    liObj.year5Price = price;
                    liObj.year5DiscPrice = discPrice;
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
        Date startDate,endDate;
        public Integer year1, year2, year3, year4, year5;        
        public Decimal year1Price,year2Price,year3Price,year4Price,year5Price,cliTotalPrice;
        public Decimal year1DiscPrice,year2DiscPrice,year3DiscPrice,year4DiscPrice,year5DiscPrice;
        public Decimal year1ExtListPrice,year2ExtListPrice,year3ExtListPrice,year4ExtListPrice,year5ExtListPrice;
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
        public LineItemDetailsWrapper(Id ctrtId, Id lineItemId, String prdName, String prdCode, Date strtDate, Date endDte, String currencyCode) {
            ctrctId=ctrtId;
            cliId=lineItemId;
            prodName=prdName;
            prodCode=prdCode;
            startDate=strtDate;
            endDate=endDte;            
            currencyIsoCode=currencyCode;
        }
    }   

}