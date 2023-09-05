/**
* @author Hari Krishnan
* @date 07/16/2013
* @description This class has helper methods.
* @lastModifiedSprint: Sprint 12 SFDC1-710 -  Added method addBusinessDays
* @lastModifiedBy : Prachi Bhasin in Sprint 12
*/

public with sharing class UtilityClass {
    
    /**
    * @author Hari Krishnan
    * @date 07/16/2013
    * @description Gets the type name of the SObject.
    * @param SObject The SObject for which the name to be obtained.
    * @return String - The type name.
    */
    public static String getSObjectTypeName(SObject so) {
        return so.getSObjectType().getDescribe().getName();
    }

    static List<Country__c> countries {
        get {
            if(countries == null) {
                countries = new List<Country__c>([SELECT Id, Name, CountryCode__c, Region__c,CapiqCountry__c FROM Country__c]);                
            }
            return countries;
        }
        set;        
    }
        
    /**
     * @author Paras Dhingra
     * @date 26th Jun 2017
     * @description Method to return a map of all countries
     * @return Map <Name,country>
     **/

    public static Map<String,Country__c> countryMap{
         get {
             if(countryMap == null) {
                countryMap = new Map<string, Country__c>();
                for (Country__c c:countries) {
                    countryMap.put(c.Name, c);
                } 
             }
             return countryMap;
         }
    
        set;
    }
    
    /**
     * @author Neelam Agrawal
     * @date 20th Apr 2022
     * @description Method to return a map of all countries
     * @return Map <CapIQCountryName,country>
     **/

    public static Map<String,Country__c> CapIQCountryMap{
         get {
             if(CapIQCountryMap == null) {
                CapIQCountryMap = new Map<string, Country__c>();
                for (Country__c c:countries) {
                    CapIQCountryMap.put(c.CapiqCountry__c, c);
                } 
             }
             return CapIQCountryMap;
         }    
        set;
    }
    
    /**
     * @author Neelam Agrawal
     * @date 20th Apr 2022
     * @description Method to return a country object from the specified CapIQ country name
     * @param name CapIQ Country Name
     * @return Country__c
     **/
    public static Country__c getCapIQCountry(string name) {
         return CapIQCountryMap.get(name);
    }
    /**
     * @author Tran-Vu Tran
     * @date 26th Jun 2017
     * @description Method to return a country object from the specified country name
     * @param name Country Name
     * @return Country__c
     **/
    public static Country__c getCountry(string name) {
         return countryMap.get(name);
    }

    public static Map<String,Country__c> countryIdMap{
         get {
             if(countryIdMap == null) {
                countryIdMap = new Map<string, Country__c>();
                for (Country__c c:countries) {
                    countryIdMap.put(c.Id, c);
                } 
             }
             return countryIdMap;
         }
    
        set;
    }    

    /**
     * @author Tran-Vu Tran
     * @date 31st Aug 2017
     * @description Method to return a country object from the specified country Id
     * @param name Country Id
     * @return Country__c
     **/
    public static Country__c getCountryById(string Id) {
        return countryIdMap.get(Id);
    }
    
    public static Map<String,Country__c> countryCodeMap{
         get {
             if(countryCodeMap == null) {
                countryCodeMap = new Map<string, Country__c>();
                for (Country__c c:countries) {
                    countryCodeMap.put(c.CountryCode__c, c);
                } 
             }
             return countryCodeMap;
         }
        set;
    }    

    /**
     * @author Tran-Vu Tran
     * @date 12th Sep 2017
     * @description Method to return a country object from the specified country code
     * @param name Country code
     * @return Country__c
     **/
    public static Country__c getCountryByIsoCode(string code) {
        return countryCodeMap.get(code);
    }
    
    /**
     * @author Tran-Vu Tran
     * @date 18th July 2017
     * @description SFDC1-204 Get Account by Name
     */
    public static Account getAccountByName(String accountName) {
        
        List<Account> accounts = [Select Id, Name from Account where Name =: accountName];
        if (accounts != null && !accounts.isEmpty()) {
            return accounts[0];
        }
        return null;
    }
    
    // Static list of all account IDs that have Type = 'Place Holder - Unknown Account'
    public static List<String> UnknownAccountIDs {
        get {
            if (UnknownAccountIDs == null) {
                UnknownAccountIDs = new List<String>();

                List<PlaceHolderUnknownAccounts__c> UnknownAccounts = new List<PlaceHolderUnknownAccounts__c>(
                    [Select Id, AccountId__c from PlaceHolderUnknownAccounts__c]
                );
                
                for (PlaceHolderUnknownAccounts__c a : UnknownAccounts) {
                    UnknownAccountIDs.add(a.AccountId__c);
                }
            }
            
            return UnknownAccountIDs;
        }
        
        set;
    }

    // Static reference to Case Record Type "Customer Care"
    public static Id caseRecordTypeCustomerCare {
        get {
            if (caseRecordTypeCustomerCare == null) {
                caseRecordTypeCustomerCare = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Care').getRecordTypeId(); 
            }
            return caseRecordTypeCustomerCare;
        }
        
        set;
    }
    public static Id caseRecordTypeJoinerTransferLeaver {
        get {
            if (caseRecordTypeJoinerTransferLeaver == null) {
                caseRecordTypeJoinerTransferLeaver = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Joiner/Transfer/Leaver').getRecordTypeId(); 
            }
            return caseRecordTypeJoinerTransferLeaver;
        }
        
        set;
    }
    
    // Static reference to Case Record Type "Account Governance"
    public static Id caseRecordTypeAccountGovernance {
        get {
            if (caseRecordTypeAccountGovernance == null) {
                caseRecordTypeAccountGovernance = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Master Data').getRecordTypeId(); 
            }
            return caseRecordTypeAccountGovernance;
        }
        
        set;
    }

    // Static reference to Case Record Type "Order Management/Delivery Help Desk"
    public static Id caseRecordTypeOMDHelpDesk {
        get {
            if (caseRecordTypeOMDHelpDesk == null) {
                caseRecordTypeOMDHelpDesk = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Order Management/Delivery Help Desk').getRecordTypeId(); 
            }
            return caseRecordTypeOMDHelpDesk;
        }
        
        set;
    }
    
    // Static reference to Case Record Type "Sales Support"
    public static Id caseRecordTypeSalesSupport {
        get {
            if (caseRecordTypeSalesSupport == null) {
                caseRecordTypeSalesSupport = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sales Support').getRecordTypeId(); 
            }
            return caseRecordTypeSalesSupport;
        }
        
        set;
    }
    
    // Static reference to Case Record Type "Sales Operations"
    public static Id caseRecordTypeSalesOperations {
        get {
            if (caseRecordTypeSalesOperations == null) {
                caseRecordTypeSalesOperations = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sales Operations').getRecordTypeId(); 
            }
            return caseRecordTypeSalesOperations;
        }
        
        set;
    }
    
    // Static reference to Case Record Type "Sales Operations"
    public static Id caseRecordTypeContractManagement {
        get {
            if (caseRecordTypeContractManagement == null) {
                caseRecordTypeContractManagement = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Contract Management').getRecordTypeId(); 
            }
            return caseRecordTypeContractManagement;
        }
        
        set;
    }

    /**
     * @author Tran-Vu Tran
     * @date 18th July 2017
     * @description SFDC1-204 Get Contact by Email
     */
    public static Contact getContactByEmail(String contactEmail) {
        
        List<Contact> contacts = [Select Id, Name, Email, AccountId from Contact where Email =: contactEmail];
        if (contacts != null && !contacts.isEmpty()) {
            return contacts[0];
        }
        
        return null;
    }

    /**
     * @author Tran-Vu Tran
     * @date 18th July 2017
     * @description SFDC1-204 Get User by Id
     */
    public static User getUserById(String userId) {
        
        List<User> users = [Select Id, Name, Email, ADID__c from User where Id =: userId];
        if (users != null && !users.isEmpty()) {
            return users[0];
        }

        return null;
    }

    /**
     * @author Tran-Vu Tran
     * @date 20th July 2017
     * @description SFDC1-204 Get Object Record Type Id
     */
    public static String getObjectRecordTypeId(String objectTypeName, String recordTypeName) {

        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE SObjectType =: objectTypeName AND Name =: recordTypeName];
        if (recordTypes != null && !recordTypes.isEmpty()) {
            return recordTypes[0].Id;
        }
        
        return null;
    }
    
    public static String getObjectRecordTypeId(SObjectType sObjectType, String recordTypeName) {
        return getObjectRecordTypeId(sObjectType.getDescribe().getName(), recordTypeName);
    }
    
   /**
     * @author Paras Dhingra
     * @date 31st July 2017
     * @description SFDC1-1168 create apex log record using an exception
     * @param Exception
     * @return void
     * @companyname IHS Markit
     */
     public static void createApexLogRecord(Exception ex, String className, String methodName) {
         String description = '\n Cause: '+ex.getCause()+'\n Line number : '+ ex.getLineNumber()+ '\n Message: '+ ex.getMessage()+ '\n stackTrace: '+ex.getStackTraceString();
         ApexLogger__c apexLogRecord = new ApexLogger__c(ClassName__c=className,ErrorDescription__c=description,FunctionName__c=methodName);
         insert apexLogRecord;
     }
     
    /**
     * @author Paras Dhingra
     * @date 25th Sep 2017
     * @description SFDC1-4353 generic method to return picklist options of an sObject
     * @param sObject,string
     * @return List<String>
     * @companyname IHS Markit
     */
     public static List <String> getselectOptions(sObject objObject, string fld) {
      system.debug('--objObject--' + objObject);
      system.debug('--fld--' + fld);
      List < String > allOpts = new list < String > ();
      // Get the object type of the SObject.
      Schema.sObjectType objType = objObject.getSObjectType();
     
      // Describe the SObject using its object type.
      Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
     
      // Get a map of fields for the SObject
      map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
     
      // Get the list of picklist values for this field.
      list < Schema.PicklistEntry > values = fieldMap.get(fld).getDescribe().getPickListValues();
     
      // Add these values to the selectoption list.
      for (Schema.PicklistEntry a: values) {
          allOpts.add(a.getValue());
      }
      system.debug('--allOpts--' + allOpts);
      allOpts.sort();
      return allOpts;
     }
     
     /**
     * @author Paras Dhingra
     * @date 27th Sep 2017
     * @description SFDC1-4353 Method to return currency code mapping
     * @param sObject,string
     * @return List<String>
     * @companyname IHS Markit
     */
     public static Map<String,Decimal> mapCurrencyIsoCodeConversionRate {
         get {
             if(mapCurrencyIsoCodeConversionRate==null) {
                System.debug('--currency query--');
                mapCurrencyIsoCodeConversionRate = new Map<String,Decimal>();
                List<CurrencyType> lstCurrencyType = [Select Id, IsoCode, ConversionRate from CurrencyType where IsActive=true];
                if(lstCurrencyType != null && lstCurrencyType.size() > 0) {
                    for(CurrencyType currencyType : lstCurrencyType) {
                        mapCurrencyIsoCodeConversionRate.put(currencyType.IsoCode, currencyType.ConversionRate);
                    }
                }
        
             }
              return mapCurrencyIsoCodeConversionRate;
             
         }
         set;
     }
     
     /**
     * @author : Mohit Modi
     * @date : 06 Nov 2017
     * @description : SFDC1-4790 Method to return the key prefix of an Object
     * @param : string Object Name
     * @return : String Object Keyprefix
     * @companyname : Vertiba
     */
     public static String getObjectKeyPrefix(String object_name) {
            Map<String, Schema.SObjectType> m  = Schema.getGlobalDescribe() ;
            system.debug('==>m is==>'+m);
            if(m.get(object_name) != NULL) {
                Schema.SObjectType s = m.get(object_name) ;
                system.debug('==>Sobject Type is ==>'+s);
                Schema.DescribeSObjectResult r = s.getDescribe() ;
                String keyPrefix = r.getKeyPrefix();
                return keyPrefix;
            }
            return NULL;
     }
     
    /**
     * @author : Prachi Bhasin
     * @date : 10 Nov 2017
     * @description : SFDC1-710 Method to add business days to date
     * @param : date to which business days should be added
     * @param : integer NumberOfBusinessDays
     * @return : date
     * @companyname : Vertiba
     */
     public static Date addBusinessDays(Date startDate, Integer NumberOfBusinessDays) {
            Integer businessDaysAdded = 0;
            Date currentDate = startDate;
            while (businessDaysAdded < NumberOfBusinessDays) {
                currentDate = currentDate.addDays(1);
                Datetime d = datetime.newInstance(currentDate.year(), currentDate.month(),currentDate.day());
        
                if (d.format('E') != 'Sat' && d.format('E') != 'Sun') {
                    // it's a business day, so add 1 to the counter that works towards the amount of days to add
                    businessDaysAdded = businessDaysAdded + 1;
                } 
            }       
            return currentDate;
     }
     
     /**
     * @author : Mohit Modi
     * @date : 14 Nov 2017
     * @description : SFDC1-5723 Method to check the Edit access for the given user on the given Record
     * @param : User Id, Record Id
     * @return : Boolean
     * @companyname : Vertiba
     */
     public static Boolean checkRecordAccessforUser (Id usrId, id recordId) {
         system.debug('usrId----'+usrId);
         system.debug('recordId----'+recordId);
         
         list<UserRecordAccess> recordAccessVal =  [SELECT RecordId FROM UserRecordAccess
              WHERE UserId =: usrId AND RecordId =: recordId AND HasEditAccess = true ];
         system.debug('inside recordAccessVal '+recordAccessVal );    
        
         return recordAccessVal.isEmpty() ? false : true;
     }
     
          /**
     * @author : Hemant Shukla
     * @date : 15-NOV-2017
     * @description : SFDC1-5809, Method to subtract business days to date
     * @param : date to which business days should be subtracted
     * @param : integer NumberOfBusinessDays
     * @return : date
     * @companyname : Vertiba
     */
     public static Date subtractBusinessDays(Date startDate, Integer NumberOfBusinessDays) {
            Integer businessDaysRemoved = 0;
            Date currentDate = startDate;
            while (businessDaysRemoved < NumberOfBusinessDays) {
                currentDate = currentDate.addDays(-1);
                Datetime d = datetime.newInstance(currentDate.year(), currentDate.month(),currentDate.day());
        
                if (d.format('E') != 'Sat' && d.format('E') != 'Sun') {
                    // it's a business day, so add 1 to the counter that works towards the amount of days to add
                    businessDaysRemoved += 1;
                } 
            }       
            return currentDate;
     }
     
     //================================
     // @author: Paras Dhingra
     // @date: 27th Sep 2017
     // @description: SFDC1-4353 Method to return currency code mapping
     // @param: sObject,string
     // @return: List<String>
     // @companyname: IHS Markit
     //================================
      public static boolean isCommunity() {
          
        Id siteId = Site.getSiteId(); 
        if (siteId != null) {
            return true;
        }
        return false;
          
      }
     //================================
     // @author: Paras Dhingra
     // @date: 15th Feb 2018
     // @description: SFDC1-6856 This method returns a feedItemInput element to be posted using connect API
     // @param: String recordId(Id of record or group for chatter feed) 
     // @param: List<String> list of userIds/GroupIds to be @mentioned
     // @param: String Message - Message to be posted on chatter
     // @return: List<String>
     // @companyname: IHS Markit
     //================================
     public static ConnectApi.FeedItemInput getChatterFeedItemInput (String recorId, List<String> lstAtMentions, String message) {
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        textSegmentInput.text = message;
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        messageBodyInput.messageSegments.add(textSegmentInput);
        for(Id userGroupId: lstAtMentions) {
            ConnectApi.MentionSegmentInput atMentions = new ConnectApi.MentionSegmentInput();
            atMentions.Id = userGroupId;
            messageBodyInput.messageSegments.add(atMentions);
        }
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = recorId;
        return feedItemInput;
     }
     //
      // @author: Paras Dhingra
      // @date: 15th Feb 2018
      // @description: SFDC1-6856 method returns a map of split type names and ids
      // @param: null
      // @return:  Map<String,Id>
      // @companyname: IHS Markit
      //
    public static Map<String,Id> getSplitTypeIds() {
        List<OpportunitySplitType> lstOppySplitTypes = [Select Id, DeveloperName from OpportunitySplitType where IsActive=true];
        Map<String,Id> mapSplitTypes = new Map<String,Id>();
        for(OpportunitySplitType oppySplitType :lstOppySplitTypes) {
            mapSplitTypes.put(oppySplitType.DeveloperName, oppySplitType.Id);
        }
        return mapSplitTypes;
    }
    //
      // @author: Paras Dhingra
      // @date: 28th Feb 2018
      // @description: SFDC1-7048 property returns channel partner community Id
      // @param: null
      // @return:  Map<String,Id>
      // @companyname: IHS Markit
      //
    public static String ChannelPartnerId {
        get {
            if(ChannelPartnerId==null) {
                ChannelPartnerId = getCommunityNetworkId('Channel Partners');
            }
            return ChannelPartnerId;
        }
        set;
    }
     //
      // @author: Paras Dhingra
      // @date: 28th Feb 2018
      // @description: SFDC1-7048 method returns a network id of community
      // @param: null
      // @return:  Map<String,Id>
      // @companyname: IHS Markit
      //
    public static String getCommunityNetworkId(String CommunityName) {
        List<Network> lstNetwork = [Select Id, Name from Network where Name =:CommunityName limit 1];
        return lstNetwork[0].ID;
    }
    //
    // @author: Prachi Bhasin
    // @date: 3 May 2018
    // @description: SFDC1-7574 method returns a query with all fields of sobject
    // @param: String - name of object
    // @return:  String
    // @companyname: Vertiba
    //
    public static String queryBuilder(String SobjectApiName) {

        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();

        String commaSepratedFields = '';
        for(String fieldName : fieldMap.keyset()) {
            if(commaSepratedFields == null || commaSepratedFields == '') {
                commaSepratedFields = fieldName;
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + fieldName;
            }
        }

       String  queryStr = 'select ' + commaSepratedFields + ' from ' + SobjectApiName ;
       
       return queryStr;
      
    }
    //
      // @author: Paras Dhingra
      // @date: 26th Apr 2018
      // @description: SFDC1-7082 method to replicate dates360 method of excel
      // @param: DateTime StartDate, DateTime EndDate
      // @return:  Double dayCount
      // @companyname: IHS Markit
      //
    public static Double getDays360(Date startDate, Date endDate) {
        Integer startMonthDays = 0;
        Integer endMonthDays = 0;
        double diff = 0;

        Date dtStartDate = startDate;
        Date dtEndDate = endDate;

        dtStartDate = dtStartDate.AddDays(-1);

        if (Date.DaysInMonth(Integer.valueOf(dtStartDate.year()), Integer.valueOf(dtStartDate.month())) == dtStartDate.day())
        {
            startMonthDays = 0;
        }
        else if (dtStartDate.month() == 2)
        {
            if (Date.DaysInMonth(dtStartDate.year(), dtStartDate.month()) == 29 && dtStartDate.day() == 28)
            {
                startMonthDays = (30 - (dtStartDate.day() + 2));
            }
            else if (Date.DaysInMonth(dtStartDate.year(), dtStartDate.month()) == 28 && dtStartDate.day() == 27)
            {
                startMonthDays = (30 - (dtStartDate.day() + 3));
            }
            else
            {
                startMonthDays = (30 - dtStartDate.day());
            }
        }
        else
        {
            startMonthDays = (30 - dtStartDate.day());
        }

        if (Date.DaysInMonth(dtEndDate.year(), dtEndDate.month()) == dtEndDate.day())
        {
            endMonthDays = CalculateEndMonthdays(endMonthDays, dtStartDate, dtEndDate);
        }
        else
        {
            endMonthDays = dtEndDate.day();
        }

        diff = (dtEndDate.year() - dtStartDate.year()) * 360 +
                    (dtEndDate.month() - dtStartDate.month() - 1) * 30 +
                    startMonthDays + endMonthDays;

        return diff;

    }
      //
      // @author: Paras Dhingra
      // @date: 26th Apr 2018
      // @description: SFDC1-7082 helper method for day360 to calculate endmonthdays
      // @param: Integer endMonthDays, Date startDatem Dateime endDate
      // @return:  Integer endMonthDays
      // @companyname: IHS Markit
      //
    private static Integer CalculateEndMonthdays(Integer endMonthDays, Date dtStartDate, Date dtEndDate)
        {
            if (dtStartDate.day() < Date.DaysInMonth(dtStartDate.year(), dtStartDate.month()) - 1)
            {
                if (dtEndDate.month() == 2 && Date.DaysInMonth(dtEndDate.year(), dtEndDate.month()) == dtEndDate.day())
                {
                    endMonthDays = Date.DaysInMonth(dtEndDate.year(), dtEndDate.month());
                }
                else if (Date.DaysInMonth(dtEndDate.year(), dtEndDate.month()) > 30)
                {
                    endMonthDays = Date.DaysInMonth(dtEndDate.year(), dtEndDate.month());
                }
                else
                {
                    endMonthDays = dtEndDate.day();
                }
            }
            else
            {
                if (Date.DaysInMonth(dtEndDate.year(), dtEndDate.month()) == dtEndDate.day())
                {
                    endMonthDays = 30;
                }
                else
                {
                    endMonthDays = dtEndDate.day();
                }

                //// 1 day() issue 
                if (dtEndDate.day() == 31 && dtStartDate.day() == 30 && dtEndDate.month() == dtStartDate.month() && dtEndDate.year() == dtStartDate.year())
                {
                    endMonthDays = endMonthDays + 1;
                }
                else if (dtEndDate.month() == 2)
                {
                    if (Date.DaysInMonth(dtEndDate.year(), dtEndDate.month()) == 29)
                    {
                        if (dtEndDate.day() == 29 && dtStartDate.day() == 28 && dtEndDate.month() == dtStartDate.month() && dtEndDate.year() == dtStartDate.year())
                        {
                            endMonthDays = endMonthDays + 1;
                        }
                    }
                    else
                    {
                        if (dtEndDate.day() == 28 && dtStartDate.day() == 27 && dtEndDate.month() == dtStartDate.month() && dtEndDate.year() == dtStartDate.year())
                        {
                            endMonthDays = endMonthDays + 1;
                        }
                    }
                }
            }

            return endMonthDays;
        }
        //
      // @author: Paras Dhingra
      // @date: 20th Jun 2018
      // @description: SFDC1-8222 method to identify fiscal year based on date
      // @param: DateTime dateTobeCompared, Integer fiscalStartMonth
      // @return:  Integer fiscalyear
      // @companyname: IHS Markit
      //
      // @updated by: Ankush Agarwal
      // @updated date: 14 Jul 2022
      // @updated desc: SFDC-5795 To use Dec as Fiscal Start Month for date before Jan 2022. From 2022 onwards, year of the input date will be used.
      // @companyname: IHS Markit
      public static Integer calculateFYFromDate(DateTime dateToBeCompared, Integer fiscalStartMonth) {
          Integer fiscalYear=0;
          Integer dateYear = dateToBeCompared.year();
          if(dateToBeCompared!=null) {
              if(dateYear < 2022) {
              	if(dateToBeCompared.month() >= 12) {
                	fiscalYear = dateYear + 1;
                }
                if(dateToBeCompared.month() < 12) {
                	fiscalYear = dateYear;
                }
              } 
              else {
              	fiscalYear = dateYear;
              }
          }
          
          return fiscalYear;
      }
      //
      // @author: Paras Dhingra
      // @date: 20th Jun 2018
      // @description: SFDC1-8222 method to identify fiscal year based on date
      // @param: DateTime dateTobeCompared, Integer fiscalStartMonth
      // @return:  Integer fiscalyear
      // @companyname: IHS Markit
      //
      public static Integer FiscalStartMonth {
        get {
            if(FiscalStartMonth==null) {
                FiscalStartMonth = [Select FiscalYearStartMonth FROM Organization].FiscalYearStartMonth; 
            }
            return FiscalStartMonth;
        }
          set;
      }

      // @author: Paras Dhingra
      // @date: 29th Jun 2018
      // @description: SFDC1-9022 method to return overlay recordtype Id
      // @param: none
      // @return:  Id
      // @companyname: IHS Markit
	  public static Id OverlayId {
			get {
				if(OverlayId==null) {                
					List<OpportunitySplitType> lstOverlayId =  [Select Id from OpportunitySplitType where DeveloperName= 'Overlay' limit 1];
					if(lstOverlayId!=null && !lstOverlayId.isEmpty()) {
						OverlayId = lstOverlayId[0].Id;
					}
				}
				return OverlayId;
			}
			set;
	  }
		   
      // @author: Mohit Modi
      // @date: 6 Jul 2018
      // @description: SFDC1-9133 : Provides the Global State picklist Values
      // @param: NA
      // @return: Schema Picklist Entry for Global StateCode
      // @companyname: Vertiba
      public static List<Schema.PicklistEntry> GlobalStatePicklist {
        get {
            if(GlobalStatePicklist == NULL || GlobalStatePicklist.isempty()) {
                GlobalStatePicklist = new List<Schema.PicklistEntry> ();
                Schema.DescribeFieldResult fieldResult = Account.BillingStateCode.getDescribe();
                List<Schema.PicklistEntry> GlobalStatePicklist = fieldResult.getPicklistValues();
                System.debug('@@@UA GlobalStatePicklist: ' + GlobalStatePicklist);
                return GlobalStatePicklist;
                
           }
           return GlobalStatePicklist;
        }
          set;
      }
      
      // @author: Mohit Modi
      // @date: 6 Jul 2018
      // @description: SFDC1-9133 : Provides the Global State Name and Code Values in form of map
      // @param: NA
      // @return: map of StateCode and StateName
      // @companyname: Vertiba
      public static Map<String,String> mapGlobalStateCodeStateName {
        get {
            if(mapGlobalStateCodeStateName == NULL) {
                mapGlobalStateCodeStateName = new Map<String,String>();
                System.debug('GlobalStatePicklistinside-----'+GlobalStatePicklist);
                for( Schema.PicklistEntry tempPicklistEntry : GlobalStatePicklist) {
                     if(tempPicklistEntry != NULL) {
                        mapGlobalStateCodeStateName.put(tempPicklistEntry.getValue().tolowerCase(),tempPicklistEntry.getLabel().tolowerCase());
                    }
                }
                return mapGlobalStateCodeStateName;
            }
            return mapGlobalStateCodeStateName;
        }
          set;
      }
      
      // @author: Mohit Modi
      // @date: 6 Jul 2018
      // @description: SFDC1-9133 : Provides the Global State Name and Code Values in form of map
      // @param: NA
      // @return: map of StateName and StateCode
      // @companyname: Vertiba
      public static Map<String,String> mapGlobalStateNameStateCode {
        get {
            if(mapGlobalStateNameStateCode == NULL) {
                mapGlobalStateNameStateCode = new Map<String,String>();
                for( Schema.PicklistEntry tempPicklistEntry : GlobalStatePicklist) {
                   if(tempPicklistEntry != NULL) {
                        mapGlobalStateNameStateCode.put(tempPicklistEntry.getLabel().tolowerCase(),tempPicklistEntry.getValue().tolowerCase());
                   }
                }
                return mapGlobalStateNameStateCode;
            }
            return mapGlobalStateNameStateCode;
        }
          set;
      }
      
      // @author: Mohit Modi
      // @date: 6 Jul 2018
      // @description: SFDC1-9133 : This method will validate the Correct State String from the Global State Picklists
      // @param: String of State in form of StateCode or StateName
      // @return: String Value of StateName if Correct value is provided else Blank Value.
      // @companyname: Vertiba
      public static String validateAndGetStateNameValue (String stateStringValue) {
          String stateName = '';
          if(stateStringValue != '' && stateStringValue != NULL) {
              System.debug('stateStringValue------'+stateStringValue);
              System.debug('mapGlobalStateNameStateCode ------'+mapGlobalStateNameStateCode );
              System.debug('mapGlobalStateCodeStateName ------'+mapGlobalStateCodeStateName );
              if(mapGlobalStateNameStateCode != NULL && !mapGlobalStateNameStateCode.isEmpty() && mapGlobalStateNameStateCode.containskey(stateStringValue.tolowerCase())) {
                  stateName = stateStringValue;
              }
              else if(mapGlobalStateCodeStateName != NULL && !mapGlobalStateCodeStateName.isEmpty() && mapGlobalStateCodeStateName.containskey(stateStringValue.tolowerCase())) {
                  stateName = mapGlobalStateCodeStateName.get(stateStringValue.tolowerCase());
              }
          }
          return stateName;
      }
      // @author: Paras Dhingra
      // @date: 20th Jul 2018
      // @description: SFDC1-9240 creating a map to hold globalSobject describe call
      // @param: none
      // @return:  Id
      // @companyname: IHS Markit
      public static Map<String,DescribeSobjectResult> mapGlobalSObjects {
          get {
              if(mapGlobalSObjects==null) {
                  mapGlobalSObjects = new Map<String,DescribeSobjectResult>();
              }
            return mapGlobalSObjects;      
        }
          set;
      }
      // @author: Paras Dhingra
      // @date: 20th Jul 2018
      // @description: SFDC1-9240 creating a map to hold globalSobject describe call
      // @param: none
      // @return:  Id
      // @companyname: IHS Markit
      public static Schema.DescribeSobjectResult getSobjectSchema(String sobjectName) {
          if(!mapGlobalSObjects.containskey(sobjectName)) {
            String[] types = new String[] {sobjectName};
            Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
            mapGlobalSObjects.put(sobjectName,results[0]);
          }
          return mapGlobalSObjects.get(sobjectName);
      }
      // @author: Paras Dhingra
      // @date: 20th Jul 2018
      // @description: SFDC1-9240 creating a map to hold globalSobject describe call
      // @param: none
      // @return:  Id
      // 
      // @updated by: Harshit Singhal
      // @updated date: 29 Apr 2020
      // @updated desc: SFDC-2748 To avoid exception in case of transactions running from "Automated Process" user. This user's profile does not have a name.
      // @companyname: IHS Markit
      public static string LoggedInUserProfileName {
          get {
            if(String.isBlank(LoggedInUserProfileName)) {
                List<Profile> prof = [Select Id, Name from Profile where Name!=null AND Id=:UserInfo.getProfileId()];
                LoggedInUserProfileName = prof!=null && prof.size()>0 && String.isNotBlank(prof[0].Name) ? prof[0].Name : null;
            }
            return LoggedInUserProfileName;
          }
          set;
      }
      // @author: Prachi Bhasin
      // @date: 24 Jul 2018
      // @param: none
      // @return:  Id
      // @companyname: Vertiba
      public static Id OrderManagementQueueId {
          get {
            if(OrderManagementQueueId == NULL || String.isBlank(OrderManagementQueueId)) {
                //OrderManagementQueueId =[select Id from Group where DeveloperName = 'OrderManagement' and Type = 'Queue' LIMIT 1].Id;
                OrderManagementQueueId =System.Label.OrderManagementQueueId;
            }
            return OrderManagementQueueId;
          }
          set;
      }
      // @author: Jagadesh Kumar
      // @date: 03 Sep 2018
      // @param: none
      // @return:  Id
      // @companyname: Vertiba
      public static Id FMOnboardingQueueId {
          get {
            if(FMOnboardingQueueId == NULL || String.isBlank(FMOnboardingQueueId)) {
                FMOnboardingQueueId =[select Id from Group where DeveloperName = 'FMOnboarding' and Type = 'Queue' LIMIT 1].Id;
            }
            return FMOnboardingQueueId;
          }
          set;
      }
    //-----------------------------
    // @author: Paras Dhingra
    // @date: 21st July 2018
    // @param: TriggerParameters
    // @description: SFDC1-9240, SFDC1-9181 - method to get list of currency fields for give sobject
    // @return: None
    //------------------------------
    public static Set<String> getCurrencyFieldNames(String objName) {
        Set<String> setCurrencyFieldNames = new Set<String>();
        //describe the object and get it's field map
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get(objName).getDescribe().fields.getMap();
        //iterate the map and fetch currency field
        for(Schema.SObjectField sobjField : fieldMap.values()) {
            schema.describefieldresult describeField = sobjField.getDescribe();
            //check for currency type field
            if(describeField.getType()== Schema.DisplayType.Currency) {
                setCurrencyFieldNames.add(describeField.getName());
            }
        }
        return setCurrencyFieldNames;
        
    }
    //-----------------------------
    // @author: Jagadesh Kumar
    // @date: 06 Sep 2018
    // @param: None
    // @description: SFDC1-9035 OM/Delivery Help Desk 'OMD Status' to 'Status' field mapping
    //------------------------------
    public static Map<String, String> caseOMDStatusMap {
        get {
            if(caseOMDStatusMap == NULL) {
                caseOMDStatusMap = new Map<String, String>();
                for (CaseOMDStatusToStatusMapping__mdt statusMapping : [Select OMDStatus__c,Status__c From CaseOMDStatusToStatusMapping__mdt]) {
                    caseOMDStatusMap.put(statusMapping.OMDStatus__c, statusMapping.Status__c);
                    System.debug('1');
        		}
            }
            return caseOMDStatusMap;
        }
        set;
    }
    //-----------------------------
    // @author: Jagadesh Kumar
    // @date: 05 Dec 2018
    // @param: None
    // @description: SFDC1-9382 Fetch the Accounts Where Account Name = 'IHS Markit' and Account Type = "Place Holder - IHS Markit Internal Employees"
    //------------------------------
    public static List<Account> IHSMarkitAccountList {
        get {
            if(IHSMarkitAccountList==null) {
                IHSMarkitAccountList = [SELECT Id FROM Account WHERE Name =: System.Label.NewUserContactAccount and Type =: System.Label.NewUserContactAccountType]; 
            }
            return IHSMarkitAccountList;
        }
          set;
      }
    //-----------------------------
    // @author: Paras Dhingra
    // @date: 31 May 2019
    // @param: None
    // @description: SFDC-1611 Property to fetch all case statuses
    //------------------------------
    public static List<CaseStatus> CaseStatuses {
        get {
            if(CaseStatuses==null) {
                CaseStatuses = [SELECT Id, MasterLabel, ApiName, IsClosed FROM CaseStatus];
            }
            return CaseStatuses;
        }
        set;
    }
    //-----------------------------
    // @author: Paras Dhingra
    // @date: 31 May 2019
    // @param: None
    // @description: SFDC-1611 Utility to fetch all case status which are in closed status
    //------------------------------
    public static Set<String> getCaseClosedStatuses () {
        Set<String> setClosedStatus = new Set<String>();
		for(CaseStatus status: CaseStatuses) {
			if(status.IsClosed) {
				setClosedStatus.add(status.ApiName);
			}   
		}
        return setClosedStatus;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 27 Apr 2020
    // @param: None
    // @description: SFDC-2865 Utility to fetch all accounts to be treated as internal accounts from a custom setting InternalAccounts__c
    //------------------------------
    public static Set<Id> InternalAccountIds {
        get {
            if(InternalAccountIds==null) {
                InternalAccountIds = new Set<Id>();
                Set<Id> parentAccIdSet = new Set<Id>();
                for(Account acc : [SELECT Id FROM Account WHERE Name IN :InternalAccounts__c.getall().keySet()]) {
                    //InternalAccountIds.add(acc.Id);
                    parentAccIdSet.add(acc.Id);
                }
                if(parentAccIdSet.size() > 0) {
                    for(Account acc : [SELECT Id 
                                       FROM Account 
                                       WHERE Id IN :parentAccIdSet 
                                       		OR ParentId IN :parentAccIdSet
                                       		OR Parent.ParentId IN :parentAccIdSet
                                       		OR Parent.Parent.ParentId IN :parentAccIdSet
                                       		OR Parent.Parent.Parent.ParentId IN :parentAccIdSet
                                       		OR Parent.Parent.Parent.Parent.ParentId IN :parentAccIdSet
                                       		OR Parent.Parent.Parent.Parent.Parent.ParentId IN :parentAccIdSet]) {
                        InternalAccountIds.add(acc.Id);
                    }
                }                
            }
            return InternalAccountIds;
        }
        set;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 29 Apr 2020
    // @param: None
    // @description: SFDC-2748 Utility to fetch logged in user's name
    //------------------------------
    public static string LoggedInUserName {
        get {
            if(String.isBlank(LoggedInUserName)) {
                LoggedInUserName = UserInfo.getName();
            }
            return LoggedInUserName;
        }
        set;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 18 Jun 2020
    // @param: None
    // @description: SFDC-1652 Utility to case record type Ids from a custom setting
    //------------------------------
    public static List<Id> IncludedCaseRecTypes {
        get {
            if(IncludedCaseRecTypes==null) {
                List<Id> recTypes = new List<Id>();
                for(RecordType recType : [SELECT Id FROM RecordType WHERE Name IN :IncludeCaseAutoCloseReassignment__c.getall().keySet() AND SobjectType='Case' AND IsActive=true]) {
                    recTypes.add(recType.Id);
                }
                IncludedCaseRecTypes = recTypes;
            }
            return IncludedCaseRecTypes;
        }
        set;
    }
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 18 Jun 2020
    // @param: None
    // @description: SFDC-1652 Utility to fetch closed statuses in a property
    //------------------------------
    public static Set<String> ClosedCaseStatuses {
        get {
            if(ClosedCaseStatuses==null) {
                 ClosedCaseStatuses = getCaseClosedStatuses();
            }
            return ClosedCaseStatuses;
        }
        set;
    }
    //-----------------------------
    // @author: Priyanka Vyas
    // @date: 22 June 2020
    // @param: None
    // @description: SFDC-3115 Utility to set ActivityCreated__c as false on Opportunities during activity or related opportunity delete or update
    //------------------------------
    public static List<Opportunity> setCreateActivityAsFalse(Set<ID> OpportunityIDSetOld) {
        List<Opportunity> opportunityList=new List<Opportunity>();
        set<id> remainingOppIdSet = new set<id>();
        if(!OpportunityIDSetOld.isEmpty()){
            for(Task t:[Select id, WhatId from Task where WhatId in: OpportunityIDSetOld]){
                remainingOppIdSet.add(t.Whatid);
            }
            for(RelatedOpportunity__c relatedOppy:[Select id, Opportunity__c from RelatedOpportunity__c where Opportunity__c in:OpportunityIDSetOld]){
                remainingOppIdSet.add(relatedOppy.Opportunity__c);
            }
            for(Event e:[Select id, WhatId from Event where WhatId in: OpportunityIDSetOld]){
                remainingOppIdSet.add(e.WhatId);
            }
            if(!remainingOppIdSet.isEmpty()){
                OpportunityIDSetOld.removeAll(remainingOppIdSet);
            }
            if(OpportunityIDSetOld.size()>0){
                for(ID oppId:OpportunityIDSetOld){
                    Opportunity oppToUpdate = new Opportunity(id = oppId );
                    oppToUpdate.ActivityCreated__c=false;
                    opportunityList.add(oppToUpdate);
                }
            }
        }
        return opportunityList;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 01 Jul 2020
    // @param: None
    // @description: SFDC-3169 Utility method to get queue Ids from queue developer names for an object
    //------------------------------
    public static Map<String,Id> getQueueIdsFromQueueNames(List<String> queueNamesList, String sObjectName) {
        Map<String,Id> queueNameIdMap = new Map<String,Id>();
        for(QueueSObject queueObj: [SELECT Id, QueueId, SobjectType,Queue.Name,Queue.DeveloperName FROM QueueSobject WHERE SobjectType=:sObjectName AND Queue.DeveloperName IN :queueNamesList]) {
            queueNameIdMap.put(queueObj.Queue.DeveloperName, queueObj.QueueId);
        }
        return queueNameIdMap;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 01 Jul 2020
    // @param: None
    // @description: SFDC-3169 Property to store Delete and Duplicate Queue Ids of Case object
    //------------------------------
    public static List<Id> deleteDuplicateCaseQueueIds {
        get {
            if(deleteDuplicateCaseQueueIds==null) {
                List<String> queDevNames = new List<String> {'DeleteQueue','DuplicateQueue','MergedQueue'};
                deleteDuplicateCaseQueueIds = getQueueIdsFromQueueNames(queDevNames,'Case').values();
            }
            return deleteDuplicateCaseQueueIds;
        }
        set;
    }
    //-----------------------------
    // @author: Paras Dhingra
    // @date: 09 Sep 2020
    // @param: None
    // @description: SFDC-3210 Recordtype property to be called once throughout the transaction
    //------------------------------
    public static Id oppyRecordTypeRenewalId {
        get {
            if (oppyRecordTypeRenewalId == null) {
                oppyRecordTypeRenewalId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId(); 
            }
            return oppyRecordTypeRenewalId;
        }
        
        set;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 24 Sep 2020
    // @param: None
    // @description: SFDC-3210 Trial Contract Recordtype property to be called once throughout the transaction
    //------------------------------
    public static Id trialContractRecordTypeId {
        get {
            if (trialContractRecordTypeId == null) {
                trialContractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Trial').getRecordTypeId(); 
            }
            return trialContractRecordTypeId;
        }
        
        set;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 24 Sep 2020
    // @param: None
    // @description: SFDC-3210 Consulting Contract Recordtype property to be called once throughout the transaction
    //------------------------------
    public static Id consultingContractRecordTypeId {
        get {
            if (consultingContractRecordTypeId == null) {
                consultingContractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Consulting').getRecordTypeId(); 
            }
            return consultingContractRecordTypeId;
        }
        
        set;
    }
    
    //-----------------------------
    // @author: Harshit Singhal
    // @date: 24 Sep 2020
    // @param: None
    // @description: SFDC-3210 Order Form Contract Recordtype property to be called once throughout the transaction
    //------------------------------
    public static Id orderFormContractRecordTypeId {
        get {
            if (orderFormContractRecordTypeId == null) {
                orderFormContractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Order Form').getRecordTypeId(); 
            }
            return orderFormContractRecordTypeId;
        }
        
        set;
    }
    //-----------------------------
    // @author: Paras Dhingra
    // @date: 5th Feb 2021
    // @param: None
    // @description: SFDC-3903 check whether user has custom permission to bypass validations
    //------------------------------
    public static Boolean hasValidationBypassPermission {
        get {
            if(hasValidationBypassPermission==null) {
                hasValidationBypassPermission = FeatureManagement.checkPermission('ValidationByPassPermission');
            }
            return hasValidationBypassPermission;
        }
        set;
    }
    
    //-----------------------------
    // @author: Ankush Agarwal
    // @date: 24th Sep 2021
    // @param: Start Date and End Date
    // @description: SFDC-3903 calculate number of days between start date and end date
    //------------------------------
    public static Integer calculateDays360ForProRation(Date startDate, Date endDate) {
        Integer dDays = 0;
        Integer startDate_y = startDate.year();
        Integer endDate_y = endDate.year();
        Integer startDate_m = startDate.month();
        Integer endDate_m = endDate.month();
        Integer startDate_d = startDate.day();
        Integer endDate_d = endDate.day();
        //if Start Date is 31st convert it to 30
        //if (startDate_d == 31) startDate_d = 30;
        //if End Date is 31st convert it to 30
        if (endDate_d == 31) endDate_d = 30;
        //if End Date is last day of Feb convert it to 30
        if(endDate_m == 2 && endDate.addDays(1).month() == 3) {
            endDate_d = 30;
        }
        //if Start Date is last day of Feb convert it to 30
       /* if(startDate_m == 2 && startDate.addDays(1).month() == 3) {
            startDate_d = 30;
        }*/
        //If start Date is last day of month except Feb
        /*if (startDate_d == 31 && startDate.addDays(1).month() > startDate_m) {
        	startDate = startDate.addDays(1);
            startDate_y = startDate.year();
            startDate_m = startDate.month();
            startDate_d = startDate.day();
        }*/
        if((startDate.addDays(1).month() > startDate_m || (startDate.addDays(1).month() == startDate_m && startDate.addDays(2).month() > startDate_m && startDate_d == 30))
           && (endDate.addDays(1).month() == endDate_m && endDate.addDays(2).month() > endDate_m && endDate_d == 30)
              ) {
        	startDate = startDate.addDays(1);
            startDate_y = startDate.year();
            startDate_m = startDate.month();
            startDate_d = startDate.day();
        }
		
        Integer dy = endDate_y - startDate_y;
        Integer dm = endDate_m - startDate_m;
        Integer dd = endDate_d - startDate_d;
        dDays = dy * 360 + dm * 30 + dd + 1;
        return dDays;
    }  
    
    //-----------------------------
    // @author: Ankush Agarwal
    // @date: 24th Apr 2023
    // @param: None
    // @description: Dated Conversion Rate mapped with Currency
    //------------------------------
    public static Map<String,List<DatedConversionRate>> isoCurrencyDatedConversionRate {
        get {
            if(isoCurrencyDatedConversionRate==null) {
                isoCurrencyDatedConversionRate = new Map<String,List<DatedConversionRate>>();
                //Query all dated conversion rates
              //  System.debug('Dated Conversion Rate Start ' + ISOCurrencyDatedConversionRate);
                for(DatedConversionRate yearConversionFiscalRate : [Select Id, IsoCode, StartDate, NextStartDate, ConversionRate from DatedConversionRate order by IsoCode, StartDate desc]){
                     if(isoCurrencyDatedConversionRate.containsKey(yearConversionFiscalRate.IsoCode)){	
                	//	System.debug('Dated Conversion Rate Start ' + ISOCurrencyDatedConversionRate);
                        isoCurrencyDatedConversionRate.get(yearConversionFiscalRate.IsoCode).add(yearConversionFiscalRate);
                     }
                     else{
		             //   System.debug('Dated Conversion Rate else ' + ISOCurrencyDatedConversionRate);
                         List<DatedConversionRate> listISODatedConversionRate = new List<DatedConversionRate>();
                         listISODatedConversionRate.add(yearConversionFiscalRate);
                         isoCurrencyDatedConversionRate.put(yearConversionFiscalRate.IsoCode, listISODatedConversionRate);
                     }
                 } 
            //    System.debug('Dated Conversion Rate End ' + ISOCurrencyDatedConversionRate);
            }
            return isoCurrencyDatedConversionRate;
        }
        set;
    }
    
}