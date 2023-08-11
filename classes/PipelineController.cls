/*******************************************************************************************
* @Name         PipelineController 
* @Author       Vijay Sidgiddi
* @Date         02/09/2021
* @Description  This class contains all service methods related to pipeline  
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Vijay     		 02/09/2021         Initial Creation                                                      
*******************************************************************************************/
public class PipelineController {
    private static Boolean ESGSelected = false;
    public static Map<String, Map<String, Integer>> remainingRecordsMap;
    public static Map<String, Map<String, Integer>> accountDivisionMap;
    public static Map<String, Map<String, Integer>> recordCountMap;
    public static Map<Integer, List<String>> totalMap;
    private static Set<String> divNames = new Set<String>();
    private static Set<String> selectedDivNames = new Set<String>();
    private static Map<String, String> divNameToOpportunityAmountField = new Map<String, String>();
    private static Map<String, String> divNameToESGAmountField = new Map<String, String>();
    private static List<Division_Settings__mdt> divisionSettingsMetadata = AccountLandingPageController.getDivisions();

    /**************************************************************************************
     * @Description  This method is to get the pipeline account query
     * @Param		N/A
     * @Return       Returns the query
     **************************************************************************************/
    public static String getPipelineQuery(String AccountId, String selectedTimeframe, String selectedProbability,
            List<Map<String, String>> selectedProductFamilies) {

        List<Division_Settings__mdt> divisionSettings = divisionSettingsMetadata;
        Set<String> amountFields = new Set<String>();
        for(Division_Settings__mdt setting : divisionSettings){
            if(!setting.Disable_Chart__c){
                if(String.isNotEmpty(setting.Opportunity_Amount_Field__c)) {
                    amountFields.add(setting.Opportunity_Amount_Field__c);
                }
                if(String.isNotEmpty(setting.ESG_Amount_Field__c)){
                    amountFields.add(setting.ESG_Amount_Field__c);
                }
            }
        }
        String querySelectClause = 'SELECT Id,Name,';
        String queryFromClause = ' FROM Account';
        String queryWhereClause = ' WHERE Id = \'' + AccountId + '\' OR parentId = \'' + AccountId + '\'';

        String oppSubquerySelect = 'SELECT Id, Name, Salesforce_Divisional_Org_ID__c, ' +
                'Salesforce_Divisional_Org_Name__c';

        for(String amountField : amountFields){
            oppSubquerySelect += ', convertCurrency(' + amountField + ')';
        }

        String oppSubqueryFrom = ' FROM Opportunities';
        String oppSubqueryWhere = ' WHERE';

        Integer count = 0;
        Integer size = selectedProductFamilies.size();
        for (Map<String, String> productFamilyConfig : selectedProductFamilies) {
            if (size > 1 && count == 0) {
                oppSubqueryWhere += ' (';
            }
            String selectedProductFamily = productFamilyConfig.get('orgId');
            String opportunityAmountField = productFamilyConfig.get('field');
            count++;
            oppSubqueryWhere += getProductFamilyFilter(selectedProductFamily, opportunityAmountField);
            if (count < size) oppSubqueryWhere += ' OR';
            if (size > 1 && count == size) {
                oppSubqueryWhere += ')';
            }
        }

        oppSubqueryWhere = oppSubqueryWhere + getTimeFrameFilter(selectedTimeframe);

        /*Filter probability*/
        if (String.isNotBlank(selectedProbability)) {
            if(Integer.valueOf(selectedProbability) != 0) {
                oppSubqueryWhere = oppSubqueryWhere + ' AND Probability >= ' + selectedProbability;
            } else {
                oppSubqueryWhere = oppSubqueryWhere + ' AND Probability > ' + selectedProbability;
            }
        }

        String combinedQuery = querySelectClause + '(' + oppSubquerySelect + oppSubqueryFrom +
                +oppSubqueryWhere + ')'
                + queryFromClause + queryWhereClause;
        return combinedQuery;
    }

    /**************************************************************************************
    * @Description  This method is to filter query based on product family
    * @Param		N/A
    * @Return       Returns the query
    **************************************************************************************/
    public Static String getProductFamilyFilter(String selectedProductFamily, String opportunityAmountField) {
        if (selectedProductFamily == 'All Divisions') {
            return ' Amount > 0';
        }

        if (selectedProductFamily == 'Sustainable1_ESG') {
            return '(' + opportunityAmountField + ' > 0)';
        }
        /*Filter product family */
        return ' (' + opportunityAmountField + ' > 0 AND Salesforce_Divisional_Org_Name__c LIKE \'%' + selectedProductFamily + '%\' )';
    }

    /**************************************************************************************
    * @Description  This method is to filter query based on time frame
    * @Param		N/A
    * @Return       Returns the query
    **************************************************************************************/
    public static String getTimeFrameFilter(String selectedTimeframe) {

        Integer yr = system.today().year();
        String startDate = '';
        String endDate = '';
        String whereQuery = '';

        SWITCH on selectedTimeframe {

            WHEN 'Next Year' {
                startDate = (yr + 1) + '-01-01';
                endDate = (yr + 1) + '-12-31';
            }

            WHEN 'Next Two Years' {
                startDate = (yr + 1) + '-01-01';
                endDate = (yr + 2) + '-12-31';
            }

            WHEN 'Next Quarter' {
                Period p = [select Id,startDate,endDate from period where type = 'Quarter' and StartDate = NEXT_FISCAL_QUARTER limit 1];
                String startMonth = p.startDate.month() < 10 ? '0' + p.startDate.month() : string.ValueOf(p.startDate.month()) ;
                String endMonth = p.endDate.month() < 10 ? '0' + p.endDate.month() : string.ValueOf(p.endDate.month()) ;
                String endDay = p.endDate.day() < 10 ? '0' + p.endDate.day() : string.ValueOf(p.endDate.day()) ;

                startDate = p.startDate.year() + '-' + startMonth + '-01';
                endDate = p.endDate.year() + '-' + endMonth + '-' + endDay;
            }

            WHEN 'Current Quarter' {
                Period p = [SELECT Id,startDate,endDate FROM period WHERE type = 'Quarter' AND StartDate = THIS_FISCAL_QUARTER LIMIT 1];
                String startMonth = p.startDate.month() < 10 ? '0' + p.startDate.month() : string.ValueOf(p.startDate.month()) ;
                String endMonth = p.endDate.month() < 10 ? '0' + p.endDate.month() : string.ValueOf(p.endDate.month()) ;
                String endDay = p.endDate.day() < 10 ? '0' + p.endDate.day() : string.ValueOf(p.endDate.day()) ;

                startDate = p.startDate.year() + '-' + startMonth + '-01';
                endDate = p.endDate.year() + '-' + endMonth + '-' + endDay;
            }

            WHEN ELSE {
                startDate = yr + '-01-01';
                endDate = yr + '-12-31';
            }
        }

        return ' AND closeDate>=' + startDate + ' AND closeDate<=' + endDate;
    }


    /**************************************************************************************
    * @Description  This method is to get the accounts and opportunities amount
    are maintained in custom metadatatype  with division and field details
    * @Param		N/A
    * @Return       barChartWrapper - Returns the list of accounts with sum of opportunity amount
    **************************************************************************************/
    @AuraEnabled
    public static barChartWrapper getPipelineAccounts(
            String AccountId, String selectedTimeframe,
            String selectedProbability,
            List<Map<String, String>> selectedProductFamilies,
            String windowUrl) {
        remainingRecordsMap = new Map<String, Map<String, Integer>>();
        accountDivisionMap = new Map<String, Map<String, Integer>>();
        recordCountMap = new Map<String, Map<String, Integer>>();
        totalMap = new Map<Integer, List<String>>();

        processDivisionFields();

        //To get the query to retrieve opportunities and accounts
        String query = getPipelineQuery(AccountId, selectedTimeframe, selectedProbability, selectedProductFamilies);

        query = EncodingUtil.urlEncode(query, 'UTF-8');
        String endPoint = AccountLandingPageController.baseEndpoint + query;

        //To perform callout to get opportunities and accounts
        List<Object> recordsList = AccountLandingPageController.performAccountCallout(endPoint, windowUrl);
        if (recordsList != null) {
            //To sum up the opportnity amount for each account
            sumOpportunityAmount(recordsList, selectedProductFamilies);

            //To sort the accounts based on opportunity amount
            Set<String> accNames = sortAccounts();

            return createBarchartWrapper(accNames, accountDivisionMap);
        }
        return null;
    }

    @AuraEnabled
    public static String debugQuery(String AccountId, String selectedTimeframe, String selectedProbability, List<Map<String, String>> selectedProductFamilies) {
        return getPipelineQuery(AccountId, selectedTimeframe, selectedProbability, selectedProductFamilies);
    }

    private static void processDivisionFields() {
        List<Division_Settings__mdt> divisionSettings = divisionSettingsMetadata;

        for (Division_Settings__mdt setting : divisionSettings) {
            if(!setting.Disable_Chart__c){
                divNames.add(setting.Label);
                divNameToOpportunityAmountField.put(setting.Label, setting.Opportunity_Amount_Field__c);
                divNameToESGAmountField.put(setting.Label, setting.ESG_Amount_Field__c);
            }
        }
    }

    /**************************************************************************************
    * @Description  This method is to sum the opportunity amount
    * @Param		N/A
    * @Return     N/A
    **************************************************************************************/
    public static void sumOpportunityAmount(List<Object> recordsList, List<Map<String, String>> selectedProductFamilies) {
        selectedDivNames = new Set<String>();
        Map<String, Integer> divIdToAmount = new Map<String, Integer>();
        Map<String, Integer> divIdToCount = new Map<String, Integer>();
        Map<String, Object> childResponse = new Map<String, Object>();
        Map<String, Object> opportunityMap = new Map<String, Object>();
        List<String> innerStringList = new List<String>();
        String divName = '';
        String accName = '';
        List<Division_Settings__mdt> pipelineSettings = divisionSettingsMetadata;


        for (Map<String, String> productFamilyConfigs : selectedProductFamilies) {
            selectedDivNames.add(productFamilyConfigs.get('orgId'));
        }

        ESGSelected = false;
        if (selectedDivNames.contains('All Divisions')) {
            selectedDivNames = divNames;
            ESGSelected = false;
        } else if (selectedDivNames.contains('Sustainable1_ESG')){
            selectedDivNames = divNames;
            ESGSelected = true;
        }

        for (Object o : recordsList) {
            Integer totalAmount = 0;
            divName = '';
            divIdToAmount = new Map<String, Integer>();
            divIdToCount = new Map<String, Integer>();
            childResponse = (Map<String, Object>) o;
            accName = String.valueOf(childResponse.get('Name'));
            opportunityMap = (Map<String, Object>) (childResponse.get('Opportunities'));

            if (opportunityMap == null) {
                continue;
            }

            for (Object opp : (List<Object>) opportunityMap.get('records')) {
                Map<String, Object> omap = (Map<String, Object>) opp;

                if (omap.get('Salesforce_Divisional_Org_Name__c') == null) {
                    continue;
                }
                divName = String.valueOf(omap.get('Salesforce_Divisional_Org_Name__c'));
                processOpportunity(omap, divName, divIdToAmount, divIdToCount, totalAmount);

            }

            if (!divIdToAmount.isEmpty()) {
                accountDivisionMap.put(accName, divIdToAmount);
                recordCountMap.put(accName, divIdToCount);
                innerStringList = new List<String>();

                if (totalMap.containsKey(totalAmount)) {
                    innerStringList = totalMap.get(totalAmount);
                }

                innerStringList.add(accName);
                totalMap.put(totalAmount, innerStringList);
            }
        }

    }


    private static void processOpportunity(Map<String, Object> omap, String divName,
            Map<String, Integer> divIdToAmount, Map<String, Integer> divIdToCount, Integer totalAmount) {

        Set<String> divNamesFromRecord = new Set<String>(divName.split(','));

        for (String selectedDivName : selectedDivNames) {

            if (!divNamesFromRecord.contains(selectedDivName)) {
                continue;
            }

            Integer count = 0;
            Integer amount = 0;
            String opportunityAmountField = divNameToOpportunityAmountField.get(selectedDivName);

            String key = generateKey(selectedDivName, opportunityAmountField);
            if(ESGSelected){
                opportunityAmountField = divNameToESGAmountField.get(selectedDivName);
            }
            if (Integer.valueOf(omap.get(opportunityAmountField)) > 0) {
                count++;
                amount += Integer.valueOf(omap.get(opportunityAmountField));
                totalAmount += amount;
            }
            if (count == 0) {
                continue;
            }
            if (divIdToAmount.containsKey(key)) {
                amount += divIdToAmount.get(key);
            }
            if (divIdToCount.containsKey(key)) {
                count += divIdToCount.get(key);
            }
            divIdToAmount.put(key, amount);
            divIdToCount.put(key, count);
        }
    }

    /**************************************************************************************
    * @Description  This method is to sort the account list based on opportnity amount
    * @Param		N/A
    * @Return     set of account names
    **************************************************************************************/
    public static set<String> sortAccounts() {

        //To sort the accounts
        List<Integer> amountsList = new List<Integer>();
        Set<String> accNames = new Set<String>();
        amountsList.addAll(totalMap.keySet());
        amountsList.sort();

        for (Integer amount = amountsList.size() - 1; amount >= 0; amount--) {
            for (String accId : totalMap.get(amountsList.get(amount))) {
                accNames.add(accId);
            }
        }
        return accNames;
    }

    /**************************************************************************************
    * @Description  This method is to create the batch wrapper
    * @Param	  Set of account names and accountMap
    * @Return     BarChartWrapper
    **************************************************************************************/
    public static barChartWrapper createBarchartWrapper(Set<String> accNames, Map<String, Map<String, Integer>> completeAccountMap) {

        Map<String, List<Integer>> FinalDataMap = new Map<String, List<Integer>>();
        List<dataSets> dataSetsList = new List<dataSets>();
        Map<String, Integer> ccmap = new Map<String, Integer>();
        List<Integer> innerList = new List<Integer>();
        List<String> labels = new List<String>();
        Boolean morerecords = false;

        Integer counter = 0;

        //Get the account divisions
        List<Division_Settings__mdt> pipelineSettings = divisionSettingsMetadata;

        for (String accName : accNames) {

            if (counter < 10) {

                counter++;
                labels.add(accName);

                ccmap = completeAccountMap.get(accName);
                for (Division_Settings__mdt ps : pipelineSettings) {
                    if(ps.Disable_Chart__c){
                        continue;
                    }
                    innerList = new List<Integer>();
                    String divName = ps.Display_Name__c;
                    String key = generateKey(ps.Label, ps.Opportunity_Amount_Field__c);
                    if (FinalDataMap.containsKey(key)) {
                        innerList = FinalDataMap.get(key);
                    }

                    if (ccmap.get(key) >= 0) {
                        innerList.add(ccmap.get(key));
                    } else {
                        innerList.add(0);
                    }

                    FinalDataMap.put(key, innerList);
                }

            } else {

                morerecords = true;
                remainingRecordsMap.put(accName, completeAccountMap.get(accName));

            }
        }


        for (Division_Settings__mdt ps : pipelineSettings) {
            if(ps.Disable_Chart__c){
                continue;
            }
            String key = generateKey(ps.Label, ps.Opportunity_Amount_Field__c);
            if (FinalDataMap.containsKey(key) && !checkEmptyData(FinalDataMap.get(key))) {

                dataSets dt = new dataSets();
                dt.label = ps.Display_Name__c;
                dt.stack = 1;
                dt.orgId = key;
                dt.backgroundColor = ps.Stack_Color__c;
                dt.data = FinalDataMap.get(key);
                dt.borderWidth = 1;
                dataSetsList.add(dt);
            }

        }

        barChartWrapper br = new barChartWrapper();
        br.labels = labels;
        br.data = FinalDataMap.values();
        br.dataSetsList = dataSetsList;
        br.moreRecords = morerecords;
        br.remainingRecords = remainingRecordsMap;
        br.recordCountMap = recordCountMap;

        return br;
    }

    private static Boolean checkEmptyData(List<Integer> data){
        Boolean empty = true;
        for(Integer datum : data){
            if(datum > 0){
                empty = false;
            }
        }
        return empty;
    }

    /**************************************************************************************
    * @Description  This method is to get more account records
    * @Param	  Set of account names and accountMap
    * @Return     BarChartWrapper
    **************************************************************************************/
    @AuraEnabled
    public static barchartWrapper getPipelineMoreAccounts(Map<String, Map<String, Integer>> completeAccountMap) {
        return createBarchartWrapper(completeAccountMap.keySet(), completeAccountMap);
    }

    private static String generateKey(String divId, String opportunityAmountField) {
        return divId + '_' + opportunityAmountField;
    }

    // Wrapper classes
    public class barchartWrapper {

        @AuraEnabled
        public List<String> labels;
        @AuraEnabled
        public List<List<Integer>> data;
        @AuraEnabled
        public List<dataSets> dataSetsList;
        @AuraEnabled
        public Boolean moreRecords;
        @AuraEnabled
        public Map<String, Map<String, Integer>> remainingRecords;
        @AuraEnabled
        public Map<String, Map<String, Integer>> recordCountMap;
    }

    public class dataSets {

        @AuraEnabled
        public String label;
        @AuraEnabled
        public String orgId;
        @AuraEnabled
        public String backgroundColor;
        @AuraEnabled
        public List<Integer> data;
        @AuraEnabled
        public List<Integer> recordCount;
        @AuraEnabled
        public Integer stack;
        @AuraEnabled
        public Integer borderWidth;
        @AuraEnabled
        public Decimal barPercentage;
        @AuraEnabled
        public Integer maxBarThickness;
        @AuraEnabled
        public Integer minBarLength;

    }
}