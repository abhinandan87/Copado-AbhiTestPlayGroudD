/*******************************************************************************************
* @Name         ActivityController 
* @Author       Vijay Sidgiddi
* @Date         02/09/2021
* @Description  This class contains all service methods related to Activity  
*******************************************************************************************/
/* MODIFICATION LOGa
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Vijay     		 02/09/2021         Initial Creation                                                      
*******************************************************************************************/
public class ActivityController {
    private static Boolean ESGSelected = false;
    public static Map<String, Map<String, Integer>> accNameToDivActivityCountRemainingMap;
    public static Map<String, Map<String, Integer>> accountNameToDivisionActivityCountMap;
    public static Map<Integer, List<String>> totalCountToAccountNamesMap;
    public static Map<String, String> accountIdToNameMap;
    private static Set<String> divisionKeys = new Set<String>();
    private static Set<String> selectedDivisionKeys = new Set<String>();
    private static List<Division_Settings__mdt> divisionSettingsMetadata = AccountLandingPageController.getDivisions();

    /**************************************************************************************
    * @Description  This method is to get the status
    * @Param		N/A
    * @Return       Returns the status list
    **************************************************************************************/
    @AuraEnabled
    public static List<Activity_Status__mdt> getStatuses() {
        return [
                SELECT Filter_Value__c, Filter_Name__c
                FROM Activity_Status__mdt
        ];
    }


    /**************************************************************************************
     * @Description  This method is to get the Activity account query
     * @Param		N/A
     * @Return       Returns the query
     **************************************************************************************/
    public static String getActivityQuery(String AccountId, String selectedTimeframe,
            String selectedStatus, List<Map<String, String>> selectedProductFamilies) {

        String querySelectClause = 'SELECT Id, Name,';
        String queryFromClause = ' FROM Account';
        String queryWhereClause = ' WHERE Id = \'' + AccountId + '\' OR parentId = \'' + AccountId + '\'';

        String activitySubquerySelect = 'SELECT Salesforce_Divisional_Org_Name__c, Salesforce_Divisional_Org_ID__c, Id, ESG_Activity__c';
        String activitySubqueryFrom = ' FROM CI_Activities__r';
        String activitySubqueryWhere = ' WHERE' + getTimeFrameFilter(selectedTimeframe);

        Integer count = 0;
        Integer size = selectedProductFamilies.size();
        String activityProductFamilyWhere = '';
        for (Map<String, String> productFamilyConfig : selectedProductFamilies) {
            if (size > 1 && count == 0) {
                activityProductFamilyWhere += ' (';
            }
            String selectedProductFamily = productFamilyConfig.get('field');
            count++;
            activityProductFamilyWhere += getProductFamilyFilter(selectedProductFamily);
            if (count < size) activityProductFamilyWhere += ' OR';
            if (size > 1 && count == size) {
                activityProductFamilyWhere += ')';
            }
        }
        if (activityProductFamilyWhere != '') {
            activityProductFamilyWhere = ' AND' + activityProductFamilyWhere;
        }
        activitySubqueryWhere += activityProductFamilyWhere;

        /*Filter Status*/
        if (selectedStatus != null && selectedStatus != 'All Types') {
            activitySubqueryWhere += ' AND Activity_Type__c=\'' + selectedStatus + '\'';
        }

        String combinedQuery = querySelectClause + '(' + activitySubquerySelect + activitySubqueryFrom +
                +activitySubqueryWhere + ')'
                + queryFromClause + queryWhereClause;

        return combinedQuery;
    }

    @AuraEnabled
    public static String debugQuery(String AccountId, String selectedTimeframe, String selectedStatus, List<Map<String, String>> selectedProductFamilies) {
        return getActivityQuery(AccountId, selectedTimeframe, selectedStatus, selectedProductFamilies);
    }

    /**************************************************************************************
    * @Description  This method is to filter query based on product family
    * @Param		N/A
    * @Return       Returns the query
    **************************************************************************************/
    public Static String getProductFamilyFilter(String selectedProductFamily) {

        if (selectedProductFamily == 'All Fields' || selectedProductFamily == 'Sustainable1_ESG') {
            return '';
        }
        /*Filter product family */
        return ' (Salesforce_Divisional_Org_Name__c LIKE \'%' + selectedProductFamily + '%\')';
    }

    /**************************************************************************************
    * @Description  This method is to filter query based on time frame
    * @Param		N/A
    * @Return       Returns the query
    **************************************************************************************/
    public static String getTimeFrameFilter(String selectedTimeframe) {

        Integer yr = System.today().year();
        String startDate = '';
        String endDate = '';
        String whereQuery = '';

        switch on selectedTimeframe {

            when 'Next Year' {
                startDate = (yr + 1) + '-01-01';
                endDate = (yr + 1) + '-12-31';
            }

            when 'Next Two Years' {
                startDate = (yr + 1) + '-01-01';
                endDate = (yr + 2) + '-12-31';
            }

            when 'Next Quarter', 'Current Quarter' {

                Period p = null;
                if (selectedTimeFrame == 'Current Quarter') {
                    p = [SELECT Id,startDate,endDate FROM period WHERE type = 'Quarter' AND StartDate = THIS_FISCAL_QUARTER LIMIT 1];
                } else {
                    p = [SELECT Id,startDate,endDate FROM period WHERE type = 'Quarter' AND StartDate = NEXT_FISCAL_QUARTER LIMIT 1];
                }

                String startMonth = p.startDate.month() < 10 ? '0' + p.startDate.month() : String.valueOf(p.startDate.month()) ;
                String endMonth = p.endDate.month() < 10 ? '0' + p.endDate.month() : String.valueOf(p.endDate.month()) ;
                String endDay = p.endDate.day() < 10 ? '0' + p.endDate.day() : String.valueOf(p.endDate.day()) ;

                startDate = p.startDate.year() + '-' + startMonth + '-01';
                endDate = p.endDate.year() + '-' + endMonth + '-' + endDay;
            }

            when ELSE {
                startDate = yr + '-01-01';
                endDate = yr + '-12-31';
            }
        }

        return ' Due_Date__c >= ' + startDate + ' AND Due_Date__c <= ' + endDate;
    }


    /**************************************************************************************
    * @Description  This method is to get the pipeline account activities
    * @Param		N/A
    * @Return       barchartWrapper - Returns the list of accounts with sum of opportunity amount
    **************************************************************************************/
    @AuraEnabled
    public static barChartWrapper getAccountActivities(String AccountId,
            String selectedTimeframe,
            String selectedStatus,
            List<Map<String, String>> selectedProductFamilies,
            String windowUrl) {
        accountNameToDivisionActivityCountMap = new Map<String, Map<String, Integer>>();
        totalCountToAccountNamesMap = new Map<integer, List<String>>();
        processDivisionKeys();

        //To get the query to retrieve ACTIVITIES and accounts
        String query = getActivityQuery(AccountId, selectedTimeframe, selectedStatus, selectedProductFamilies);
        query = EncodingUtil.urlEncode(query, 'UTF-8');
        String endPoint = AccountLandingPageController.baseEndpoint + query;


        //To perform callout to get opportunities and accounts
        List<object> recordsList = AccountLandingPageController.performAccountCallout(endpoint, windowUrl);
        if (recordsList != null) {

            //To sum up the opportnity amount for each account
            countActivities(recordsList, selectedProductFamilies);

            //To sort the accounts based on opportunity amount
            set<String> accIds = sortAccounts();

            return createBarchartWrapper(accIds, accountNameToDivisionActivityCountMap, accountIdToNameMap);
        }

        return null;
    }

    /**************************************************************************************
    * @Description  This method is to sum the opportunity amount
    * @Param		N/A
    * @Return     N/A
    **************************************************************************************/
    public static void countActivities(List<Object> recordsList, List<Map<String, String>> selectedProductFamilies) {
        Set<String> selectedDivNames = new Set<String>();
        accountIdToNameMap = new Map<String, String>();
        Map<String, Integer> divisionToActivityCountMap = new Map<String, Integer>();
        Map<String, Object> accountToActivitiesMap = new Map<String, Object>();
        Map<String, Object> fieldToActivityMap = new Map<String, Object>();
        String divName = '';
        String accId = '';
        List<Division_Settings__mdt> pipelineSettings = divisionSettingsMetadata;

        for (Map<String, String> productFamily : selectedProductFamilies) {
            selectedDivNames.add(productFamily.get('field'));
        }

        if (selectedDivNames.contains('All Fields')) {
            selectedDivisionKeys = divisionKeys;
            ESGSelected = false;
        } else if(selectedDivNames.contains('Sustainable1_ESG')){
            selectedDivisionKeys = divisionKeys;
            ESGSelected = true;
        } else {
            selectedDivisionKeys = selectedDivNames;
            ESGSelected = false;
        }

        for (Object o : recordsList) {
            List<String> innerStringList = new List<String>();
            Integer totalCount = 0;
            divName = '';
            divisionToActivityCountMap = new Map<String, Integer>();
            accountToActivitiesMap = (Map<String, Object>) o;
            accId = String.valueOf(accountToActivitiesMap.get('Id'));
            accountIdToNameMap.put(accId, String.valueOf(accountToActivitiesMap.get('Name')));

            fieldToActivityMap = (Map<String, Object>) (accountToActivitiesMap.get('CI_Activities__r'));

            if (fieldToActivityMap == null) {
                continue;
            }

            for (Object opp : (list<Object>) fieldToActivityMap.get('records')) {

                Map<String, Object> omap = (Map<String, Object>) opp;
                if (omap.get('Salesforce_Divisional_Org_Name__c') == null) {
                    continue;
                }

                divName = String.valueOf(omap.get('Salesforce_Divisional_Org_Name__c'));

                processActivity(omap, divName, divisionToActivityCountMap, totalCount);
            }


            if (!divisionToActivityCountMap.isEmpty()) {
                accountNameToDivisionActivityCountMap.put(accId, divisionToActivityCountMap);
                innerStringList = new List<String>();
                if (totalCountToAccountNamesMap.get(totalCount) != null) {
                    innerStringList = totalCountToAccountNamesMap.get(totalCount);
                }
                innerStringList.add(accId);
                totalCountToAccountNamesMap.put(totalCount, innerStringList);
            }
        }

    }

    private static void processDivisionKeys() {
        List<Division_Settings__mdt> divisionSettings = divisionSettingsMetadata;

        for (Division_Settings__mdt setting : divisionSettings) {
            if(!setting.Disable_Chart__c) {
                divisionKeys.add(setting.Label);
            }
        }
    }

    private static void processActivity(Map<String, Object> omap, String divName, Map<String, Integer> divisionToActivityCountMap, Integer totalCount) {
        Set<String> divisionNames = new Set<String>(divName.split(','));

        for (String nameField : divisionNames) {

            Integer count = 0;
            if (selectedDivisionKeys.contains(nameField)) {
                if((ESGSelected && Boolean.valueOf(omap.get('ESG_Activity__c')) == true) || !ESGSelected){
                    count++;
                    totalCount++;
                }
            }

            if (count == 0) {
                continue;
            }

            if (divisionToActivityCountMap.containsKey(nameField)) {
                count += divisionToActivityCountMap.get(nameField);
            }

            divisionToActivityCountMap.put(nameField, count);
        }
    }

    /**************************************************************************************
    * @Description  This method is to sort the account list based on opportnity amount
    * @Param		N/A
    * @Return     set of account names
    **************************************************************************************/
    public static Set<String> sortAccounts() {

        Set<Integer> totalActivityRecordsSet = totalCountToAccountNamesMap.keySet();
        List<Integer> totalRecordsList = new List<Integer>();
        totalRecordsList.addAll(totalActivityRecordsSet);
        totalRecordsList.sort();
        Set<String> accountIdsSet = new Set<String>();

        for (Integer recordCount = totalRecordsList.size() - 1; recordCount >= 0; recordCount--) {
            for (String accId : totalCountToAccountNamesMap.get(totalRecordsList.get(recordCount))) {
                accountIdsSet.add(accId);
            }
        }

        return accountIdsSet;
    }

    /**************************************************************************************
    * @Description  This method is to create the batch wrapper
    * @Param	  Set of account names and accountMap
    * @Return     BarChartWrapper
    **************************************************************************************/
    public static barchartWrapper createBarchartWrapper(Set<String> accIdsSet,
            Map<String, Map<String, Integer>> completeAccountMap,
            Map<String, String> accountIdsToNameMap) {
        accNameToDivActivityCountRemainingMap = new Map<String, Map<String, Integer>>();
        Map<String, List<Integer>> DivisionToActivityCountMap = new Map<String, List<Integer>>();
        List<dataSets> dataSetsList = new List<dataSets>();
        Map<String, Integer> DivToActivityCountMap = new Map<String, Integer>();
        List<Integer> innerList = new List<Integer>();
        List<String> labels = new List<String>();
        Boolean morerecords = false;

        Integer counter = 0;

        //Get the account divisions
        List<Division_Settings__mdt> pipelineSettings = divisionSettingsMetadata;

        for (String accId : accIdsSet) {

            if (counter < 10) {

                counter++;
                labels.add(accountIdsToNameMap.get(accId));

                DivToActivityCountMap = completeAccountMap.get(accId);
                for (Division_Settings__mdt ps : pipelineSettings) {
                    if(ps.Disable_Chart__c){
                        continue;
                    }
                    innerList = new List<Integer>();
                    String divName = ps.Display_Name__c;

                    if (DivisionToActivityCountMap.get(ps.Label) != null) {
                        innerList = DivisionToActivityCountMap.get(ps.Label);
                    }

                    if (DivToActivityCountMap.get(ps.Label) >= 0) {
                        innerList.add(DivToActivityCountMap.get(ps.Label));
                    } else {
                        innerList.add(0);
                    }

                    DivisionToActivityCountMap.put(ps.Label, innerList);
                }
            } else {

                morerecords = true;
                accNameToDivActivityCountRemainingMap.put(accId, completeAccountMap.get(accId));

            }
        }


        for (Division_Settings__mdt ps : pipelineSettings) {
            if(ps.Disable_Chart__c){
                continue;
            }
            if (DivisionToActivityCountMap.containsKey(ps.Label) && !checkEmptyData(DivisionToActivityCountMap.get(ps.Label))) {

                dataSets dt = new dataSets();
                dt.label = ps.Display_Name__c;
                dt.stack = 1;
                dt.backgroundColor = ps.Stack_Color__c;
                dt.data = DivisionToActivityCountMap.get(ps.Label);
                dt.borderWidth = 1;
                dataSetsList.add(dt);
            }

        }

        barchartWrapper br = new barchartWrapper();
        br.labels = labels;
        br.data = DivisionToActivityCountMap.values();
        br.dataSetsList = dataSetsList;
        br.moreRecords = morerecords;
        br.remainingRecords = accNameToDivActivityCountRemainingMap;
        br.accountIdsToNameMap = accountIdsToNameMap;
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
    public static barchartWrapper getActivityMoreAccounts(Map<String, Map<String, Integer>> completeAccountMap,
            Map<String, String> accountIdsToNameMap) {
        return createBarchartWrapper(completeAccountMap.keySet(), completeAccountMap, accountIdsToNameMap);
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
        public Map<String, String> accountIdsToNameMap;
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