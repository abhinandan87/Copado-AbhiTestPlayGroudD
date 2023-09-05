//-----------------------------
// @author: Manish Kumar
// @date: 29 July 2021
// @param: NA
// @description: SFDC-4232  Class to hold trigger methods 
// @return: NA
//-----------------------------
public class SurveyResponseMethods {
    // Static reference to "Corporate" Survey Response Record Type Id
    public static Id corporateRecordTypeId {
        get {
            if (corporateRecordTypeId == null) {
                corporateRecordTypeId = Schema.Sobjecttype.SurveyResponse__c.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
            }
            return corporateRecordTypeId;
        }
        
        set;
    }
    // Static reference to "Transactional" Survey Response Record Type Id
    public static Id TransactionalRecordTypeId {
        get {
            if (TransactionalRecordTypeId == null) {
                TransactionalRecordTypeId = Schema.Sobjecttype.SurveyResponse__c.getRecordTypeInfosByDeveloperName().get('CustomerCare').getRecordTypeId();
            }
            return TransactionalRecordTypeId;
        }
        
        set;
    }
    // Static reference to "Training" Survey Response Record Type Id
    public static Id TrainingRecordTypeId {
        get {
            if (TrainingRecordTypeId == null) {
                TrainingRecordTypeId = Schema.Sobjecttype.SurveyResponse__c.getRecordTypeInfosByDeveloperName().get('Training').getRecordTypeId();
            }
            return TrainingRecordTypeId;
        }
        
        set;
    }
    
    //-----------------------------
    // @author: Manish Kumar
    // @date: 29 July 2021
    // @param: TriggerParameters tp
    // @description: SFDC-4232 SurveyResponse__c BEFORE INSERT - called from SurveyResponseTrigger
    //               if the Recipient Email field has been populated on the SurveyResponse__c then populate the Account 
    //               and Contact Lookup fields on Survey Response record.
    // @return: None
    //------------------------------
    
        public static void populateExistingAccountAndContactLookup(TriggerParameters tp) {
            List<string> emailOfRecipients = New List<string>();
            Id srCorpRecordTypeId = Schema.Sobjecttype.SurveyResponse__c.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
            for(SurveyResponse__c sr : (List<SurveyResponse__c>)tp.newlist){
                if(sr.RecordTypeId == srCorpRecordTypeId && sr.RecipientEmail__c != Null && (sr.Account__c == Null || sr.Contact__c == Null)){
                    string recipientEmail = string.valueOf(sr.RecipientEmail__c);
                    emailOfRecipients.add(recipientEmail);
                }
            }
            if(!emailofRecipients.isEmpty()){
                List<Contact> listOfContacts = [Select id, AccountId, Email from Contact where email in :emailOfRecipients];
                if(!listOfContacts.isEmpty()){
                    for(Contact contactObj : listOfContacts){
                        for(SurveyResponse__c sr : (List<SurveyResponse__c>)tp.newlist){
                            if(sr.RecipientEmail__c == contactObj.Email){
                                sr.Contact__c = contactObj.id;
                                sr.Account__c = contactObj.AccountId;
                            }
                        }     
                    }
                }
            }        
        }
    
    //-----------------------------
    // @author: Manish Kumar
    // @date: 29 July 2021
    // @param: TriggerParameters tp
    // @description: SFDC-4232 SurveyResponse__c AFTER INSERT - called from SurveyResponseTrigger
    //               if the Contact record not present for Recipient Email then create a new contact record and populate 
    //               the Account and Contact Lookup fields on Survey Response record.
    // @LastModifiedby: Neelam Agrawal	
    // @ModifiedDate: 08 Oct 2021
    // @description: SFDC-4888 Moved logic from afterinsert to beforeinsert trigger and updated logic
    // @return: None
    //------------------------------
        public static void populateNewAccountAndContactLookup(TriggerParameters tp) {
            List<Contact> contactsToInsert = New List<Contact>();
            List<string> emailOfRecipients = New list<String>();
            Map<String,Id> mapContactEmailandId = new Map<String,Id>();
            List<SurveyResponse__c> surveyResponseToUpdate = New list<SurveyResponse__c>();
            Id srCorpRecordTypeId = SurveyResponseMethods.corporateRecordTypeId;
            for(SurveyResponse__c sr : (List<SurveyResponse__c>)tp.newlist){
                if(sr.RecordTypeId == srCorpRecordTypeId && sr.RecipientEmail__c != Null && (sr.Account__c == Null || sr.Contact__c == Null)){
                    string recipientEmail = string.valueOf(sr.RecipientEmail__c);
                    emailOfRecipients.add(recipientEmail);
                }
            }
            List<Contact> listOfContacts = [Select id, AccountId, Email from Contact where email in :emailOfRecipients];
            for(Contact con:listOfContacts){
                mapContactEmailandId.put(con.Email,con.Id);
            }
            for(SurveyResponse__c sr : (List<SurveyResponse__c>)tp.newlist){
                if(sr.RecordTypeId == srCorpRecordTypeId && sr.RecipientEmail__c != Null && (sr.Account__c == Null || sr.Contact__c == Null) && !mapContactEmailandId.containskey(sr.RecipientEmail__c)){
                    contact contactObj = New Contact();
                    contactObj.AccountId = System.Label.AccountIdForContact;
                    contactObj.Email = sr.RecipientEmail__c;
                    contactObj.FirstName = sr.RecipientFirstName__c;
                    contactObj.LastName = sr.RecipientLastName__c;
                    contactsToInsert.add(contactObj);
                }
            }
            //Insert new Contact record based on Recipient Email if not present
            if(!contactsToInsert.isEmpty()){
                insert contactsToInsert;
            }
        }

    //-----------------------------
    // @author: Vaishali Jain
    // @date: 04 Aug 2021
    // @param: TriggerParameters tp
    // @description: SFDC#4339: IHSM CEP - New Rollup summary fields required for reporting on Contact and Account
    // @return: None
    // @Modified By: Neelam Agrawal
    // @Modified Date: 25 Oct 2021
    // @Modifief description: Fixing bug SFDC-4821 Update Rollup summary field on Account/Contact Change
    // @Modified By: Neelam Agrawal
    // @Modified Date: 09 Nov 2021
    // @Modifief description: SFDC-4884 IHSM CEP - Amendments to Rollups calculations
    //------------------------------
   
    public static void updateRollupFields(TriggerParameters tp) {

        List<Account> updateAccountList = new List<Account>();
        List<Contact> updateContactList = new List<Contact>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> contactIdSet= new Set<Id>();

            if(tp.tEvent == TriggerParameters.TriggerEvent.afterInsert || tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                for(SurveyResponse__c sr:(List<SurveyResponse__c>) tp.newList) {  
                    System.debug('checkvalue' + sr.Account__c +sr.Contact__C);
                    if(!String.isBlank(sr.Account__c)) 
                       {
                          accountIdSet.add(sr.Account__c);
                       } 
                       if(!String.isBlank(sr.Contact__C)){                        
                           contactIdSet.add(sr.Contact__C);
                       }
                    }
                }
             
            if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate){
                for(SurveyResponse__c sr:(List<SurveyResponse__c>) tp.oldList) {                
                    if(!String.isBlank(sr.Account__c)) 
                       {
                          accountIdSet.add(sr.Account__c);
                       } 
                       if(!String.isBlank(sr.Contact__C)){                        
                           contactIdSet.add(sr.Contact__C);
                       }
                    }
            }

            if(accountIdSet != Null && accountIdSet.size()>0) {
                updateAccountList=SurveyResponseMethods.updateAccountRollupFields(accountIdSet);
            }
           
            try {
                if(updateAccountList != Null && updateAccountList.size() > 0){
                    update updateAccountList;
                }
            }
            catch (DMLException ex) {
                ApexLogger.logError(new LogMessage('SurveyResponseMethods','updateRollupFields',ex,tp.newList.get(0),null));
            }

            if(contactIdSet != Null && contactIdSet.size()>0) {
                updateContactList=SurveyResponseMethods.updateContactRollupFields(contactIdSet);
            }
            try {
                if(updateContactList != Null && updateContactList.size() > 0){
                    update updateContactList;
                }
            }
            catch (DMLException ex) {
                ApexLogger.logError(new LogMessage('SurveyResponseMethods','updateRollupFields',ex,tp.newList.get(0),null));
            }
            
        }

    
    //-----------------------------
    // @author: Vaishali Jain
    // @date: 09 Aug 2021
    // @param: TriggerParameters tp
    // @description: AlertType based on score calculation
    // @return: None
    //------------------------------
    
        public static void scoreAlertType(TriggerParameters tp) {
            Id srCorpRecordTypeId = Schema.Sobjecttype.SurveyResponse__c.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
            Id srTransRecordTypeId = Schema.Sobjecttype.SurveyResponse__c.getRecordTypeInfosByDeveloperName().get('CustomerCare').getRecordTypeId();
            Id srTrainingRecordTypeId = Schema.Sobjecttype.SurveyResponse__c.getRecordTypeInfosByDeveloperName().get('Training').getRecordTypeId();  
        
            for(SurveyResponse__c sr : (List<SurveyResponse__c>)tp.newlist) {
                if(sr.RecordTypeId == srCorpRecordTypeId) {
                    if((sr.NPSScore__c >=0 && sr.NPSScore__c <=4) || (sr.LikelihoodToRenew__c >=1 && sr.LikelihoodToRenew__c <=3)|| (sr.ExperienceQuestion__c>=1 && sr.ExperienceQuestion__c <=3)|| (sr.ProductsServicesMeetNeed__c >=1 && sr.ProductsServicesMeetNeed__c <=3)) {
                        sr.AlertType__c = 'Hot Alert';
                        sr.AlertStatus__c = 'New';
                        break;
                    }
                    if((sr.NPSScore__c >=5 && sr.NPSScore__c <=8) || (sr.LikelihoodToRenew__c >=4 && sr.LikelihoodToRenew__c <=5)|| (sr.ExperienceQuestion__c >=4 && sr.ExperienceQuestion__c <=5)|| (sr.ProductsServicesMeetNeed__c >=4 && sr.ProductsServicesMeetNeed__c <=5)) {
                        sr.AlertType__c = 'Neutral';
                        sr.AlertStatus__c = 'New';
                        break;
                    }
                    if((sr.NPSScore__c >=9 && sr.NPSScore__c <=10)|| (sr.LikelihoodToRenew__c >=6 && sr.LikelihoodToRenew__c <=7)|| (sr.ExperienceQuestion__c >=6 && sr.ExperienceQuestion__c<=7)|| (sr.ProductsServicesMeetNeed__c >=6 && sr.ProductsServicesMeetNeed__c <=7)) {
                        sr.AlertType__c = 'Commendation';
                        sr.AlertStatus__c = 'New';
                        break;
                    }
                }
                else if(sr.RecordTypeId == srTransRecordTypeId) {
                    if((sr.NPSScore__c >=0 && sr.NPSScore__c <=4) || (sr.CESScore__c >=1 && sr.CESScore__c <=3) || (sr.RSSScore__c >=1 && sr.RSSScore__c <=3) || (sr.TESScore__c >=1 && sr.TESScore__c <=3) || (sr.LikelihoodToRenew__c >=1 && sr.LikelihoodToRenew__c <=3)) {
                        sr.AlertType__c = 'Hot Alert';
                        sr.AlertStatus__c = 'New';
                        break;
                    }
                    if((sr.NPSScore__c >=5 && sr.NPSScore__c <=8) || (sr.CESScore__c >=4 && sr.CESScore__c <=5) || (sr.RSSScore__c >=4 && sr.RSSScore__c <=5) || (sr.TESScore__c >=4 && sr.TESScore__c <=5) || (sr.LikelihoodToRenew__c >=4 && sr.LikelihoodToRenew__c <=5)) {
                        sr.AlertType__c = 'Neutral';
                        break;
                    }
                    if((sr.NPSScore__c >=9 && sr.NPSScore__c <=10) || (sr.CESScore__c >=6 && sr.CESScore__c <=7) || (sr.RSSScore__c >=6 && sr.RSSScore__c <=7) || (sr.TESScore__c >=6 && sr.TESScore__c <=7) || (sr.LikelihoodToRenew__c >=6 && sr.LikelihoodToRenew__c <=7)) {
                        sr.AlertType__c = 'Commendation';
                        break;
                    }
                }
                else if(sr.RecordTypeId == srTrainingRecordTypeId) {
                    if((sr.NPSScore__c >=0 && sr.NPSScore__c <=4) || (sr.TrainingMetNeeds__c >=1 && sr.TrainingMetNeeds__c <=3)) {
                        sr.AlertType__c = 'Hot Alert';
                        sr.AlertStatus__c = 'New';
                        break;
                    }
                    if((sr.NPSScore__c >=5 && sr.NPSScore__c <=8) || (sr.TrainingMetNeeds__c >=4 && sr.TrainingMetNeeds__c <=5)) {
                        sr.AlertType__c = 'Neutral';
                        break;
                    }
                    if((sr.NPSScore__c >=9 && sr.NPSScore__c <=10)|| (sr.TrainingMetNeeds__c >=6 && sr.TrainingMetNeeds__c <=7)) {
                        sr.AlertType__c = 'Commendation';
                        break;
                    }
                }
            }
        }
    
    //------------------------------
    // @author: Vaishali Jain
    // @date: 18th Aug 2021
    // @param: TriggerParameters tp
    // @description: SFDC-4232 SurveyResponse__c Before Insert - called from SurveyResponseTrigger
    //               Update the Owner of Survey Response
    // @return: None
	// @Modified By: Neelam Agrawal
    // @Modified Date: 25 Oct 2021
    // @Modified description: Fixing bug SFDC-5074 Update owner when case/fsa owner is not user
    //------------------------------
        public static void updateSurveyResponseOwner(TriggerParameters tp) { 
            Id srTransRecordTypeId = Schema.Sobjecttype.SurveyResponse__c.getRecordTypeInfosByDeveloperName().get('CustomerCare').getRecordTypeId();
            Id srTrainingRecordTypeId = Schema.Sobjecttype.SurveyResponse__c.getRecordTypeInfosByDeveloperName().get('Training').getRecordTypeId();
            for(SurveyResponse__c sr : (List<SurveyResponse__c>)tp.newlist) {
                if(sr.RecordTypeId == srTransRecordTypeId && (sr.AlertType__c == 'Neutral' || sr.AlertType__c == 'Commendation')) {
                    if(string.valueOf(sr.CaseOwnerId__c).startsWith('005')) {
                    	sr.OwnerId = sr.CaseOwnerId__c;   
                    }
                    else if(string.valueOf(sr.CaseOwnerId__c).startsWith('00G')) {
                        sr.OwnerId = System.label.CustomerExperienceTeam;
                    }
                }
                if(sr.RecordTypeId == srTrainingRecordTypeId && (sr.AlertType__c == 'Neutral' || sr.AlertType__c == 'Commendation')) {
                    if(string.valueOf(sr.FSAOwnerId__c).startsWith('005')) {
                    	sr.OwnerId = sr.FSAOwnerId__c;   
                    }
                    else if(string.valueOf(sr.FSAOwnerId__c).startsWith('00G')) {
                        sr.OwnerId = System.label.CustomerExperienceTeam;
                    }
                }
            }
        }

    //-----------------------------
    // @author: Neelam Agrawal
    // @date: 20 Oct 2021
    // @param: Contact Id
    // @description: SFDC#4821: IHSM CEP - Calulates rollup field for Contacts
    // @return: List<Contact>
    //------------------------------
        public static List<Contact> updateContactRollupFields(Set<Id> contactIdSet){
            Map<Id,List<SurveyResponse__c>> conSurveyMap = New Map <Id,List<SurveyResponse__c>>();
            List<Contact> updatedContactList = new List<Contact>();
            Set<Id> contactIdWithoutSR= contactIdSet;
            Id srCorpRecordTypeId = SurveyResponseMethods.corporateRecordTypeId;
            Id srTransRecordTypeId = SurveyResponseMethods.TransactionalRecordTypeId;
            Id srTrainingRecordTypeId = SurveyResponseMethods.TrainingRecordTypeId;
            List<SurveyResponse__c> surveyList = [SELECT Id,Contact__c,RecordTypeId, CESScore__c,CSATScore__c,TrainingMetNeeds__c,NPSScore__c, SurveyVersion__c FROM SurveyResponse__c WHERE Contact__c IN: contactIdSet];
            for(SurveyResponse__c sr : surveyList) {
                If (!conSurveyMap.keyset().contains(sr.Contact__c) && sr.Contact__c != Null) {
                    conSurveyMap.put(sr.Contact__c, New List<SurveyResponse__c>());
                }
                conSurveyMap.get(sr.Contact__c).add(sr);
            }
            contactIdWithoutSR.removeAll(conSurveyMap.keySet());
            for(Id contactId: conSurveyMap.keySet()) {
                Contact con=new Contact();
                con.Id=contactId;
                Double averageCES = 0;    
                Double averageCSAT = 0;  
                Double averageTrainingMetNeeds = 0; 
                Double averageNPS = 0;
                //SFDC-5347 Change Start
            	Double corporateDetractors = 0;
            	Double corporatePromoters = 0;
	    		Double transactionalDetractors = 0;
            	Double transactionalPromoters = 0;
	    		Double trainingDetractors = 0;
            	Double trainingPromoters = 0;
            	//SFDC-5347 Change End
                Double NumberOfRespondents = 0;
                Integer totalCESTransactionalSurveyRecords = 0;
                Integer totalCSATransactionalSurveyRecords = 0;
                Integer totalTrainingSurveyRecords = 0;
                Integer totalCorporateSurveyRecords = 0;
                //SFDC-5347 Change Start
            	Integer totalNPSTrainingSurveyRecords = 0;
            	Integer totalNPSTransactionalSurveyRecords = 0;
            	//SFDC-5347 Change End
                //Integer totalSurveyRecords = conSurveyMap.get(con.Id).size();
                If (conSurveyMap.get(con.Id) != null) {
                    for(SurveyResponse__c sr: conSurveyMap.get(con.Id)) {
                        if(sr.RecordTypeId == srTransRecordTypeId){
                            totalCESTransactionalSurveyRecords += 1;
                            if(sr.CESScore__c != null) {
                                averageCES = averageCES + sr.CESScore__c;
                            }
                            //SFDC-5347 Change Start
							if(sr.NPSScore__c != null && sr.SurveyVersion__c != null){
                            	if(sr.NPSScore__c >=0 && sr.NPSScore__c <7){
                                	transactionalDetractors += 1;
                                	totalNPSTransactionalSurveyRecords += 1;
                            	}
                            	if(sr.NPSScore__c > 8 && sr.NPSScore__c <=10){
                                	transactionalPromoters += 1;
                                	totalNPSTransactionalSurveyRecords += 1;
                            	}
                        	}
                        	//SFDC-5347 Change End
                        }
                        if(sr.CSATScore__c != null && sr.RecordTypeId == srTransRecordTypeId){
                            averageCSAT = averageCSAT + sr.CSATScore__c;
                            totalCSATransactionalSurveyRecords += 1;
                        }
                        if(sr.RecordTypeId == srTrainingRecordTypeId){
                            totalTrainingSurveyRecords += 1;
                            if(sr.TrainingMetNeeds__c != null){
                                averageTrainingMetNeeds = averageTrainingMetNeeds + sr.TrainingMetNeeds__c;
                            }
                            //SFDC-5347 Change Start
							if(sr.NPSScore__c != null && sr.SurveyVersion__c != null){
                            	if(sr.NPSScore__c >=0 && sr.NPSScore__c <7){
                                	trainingDetractors += 1;
                                	totalNPSTrainingSurveyRecords += 1;
                            	}
                            	if(sr.NPSScore__c > 8 && sr.NPSScore__c <=10){
                                	trainingPromoters += 1;
                                	totalNPSTrainingSurveyRecords += 1;
                            	}
                        	}
                        	//SFDC-5347 Change End
                        }
                        if(sr.RecordTypeId == srCorpRecordTypeId){
                            if(sr.NPSScore__c != null){
                                if(sr.NPSScore__c >=0 && sr.NPSScore__c <7){
                                    corporateDetractors += 1;
                                    totalCorporateSurveyRecords += 1;
                                }
                                if(sr.NPSScore__c > 8 && sr.NPSScore__c <=10){
                                    corporatePromoters += 1;
                                    totalCorporateSurveyRecords += 1;
                                }
                            }
                            //totalCorporateSurveyRecords += 1;
                        }
                    }    
                }
                con.CCCES__c = totalCESTransactionalSurveyRecords==0?0:(averageCES/totalCESTransactionalSurveyRecords); 
                if(con.CCCES__c == 0){
                    con.CCCES__c = null;
                }
                con.CCCSAT__c = totalCSATransactionalSurveyRecords==0?0:(averageCSAT/totalCSATransactionalSurveyRecords); 
                if(con.CCCSAT__c == 0){
                    con.CCCSAT__c = null;
                }
                con.TrainingTrainingMetNeeds__c = totalTrainingSurveyRecords==0?0:(averageTrainingMetNeeds/totalTrainingSurveyRecords); 
                if(con.TrainingTrainingMetNeeds__c == 0){
                    con.TrainingTrainingMetNeeds__c = null;
                }
                if(totalCorporateSurveyRecords != 0){
                    con.CorporateNPS__c = totalCorporateSurveyRecords==0?0:((corporatePromoters - corporateDetractors)/totalCorporateSurveyRecords*100);
                }
                else{
                    con.CorporateNPS__c = null;
                }
                //SFDC-5347 Change Start
	    		if(totalNPSTransactionalSurveyRecords != 0){
                	con.TransactionalNPS__c = totalNPSTransactionalSurveyRecords==0?0:((TransactionalPromoters - TransactionalDetractors)/totalNPSTransactionalSurveyRecords*100);
            	}
            	else{
                	con.TransactionalNPS__c = null;
            	}
	    		if(totalNPSTrainingSurveyRecords != 0){
                	con.TrainingNPS__c = totalNPSTrainingSurveyRecords==0?0:((TrainingPromoters - TrainingDetractors)/totalNPSTrainingSurveyRecords*100);
            	}
            	else{
                	con.TrainingNPS__c = null;
            	}
            	//SFDC-5347 Change End
                updatedContactList.add(con);
            }
            if(!contactIdWithoutSR.isEmpty()){
                for(Id contactId:contactIdWithoutSR){
                    Contact con=new Contact();
                    con.Id=contactId;
                    con.CCCES__c = null;
                    con.CCCSAT__c = null;
                    con.TrainingTrainingMetNeeds__c = null;
                    con.CorporateNPS__c = null;
                    //SFDC-5347 Change Start
					con.TransactionalNPS__c = null;
					con.TrainingNPS__c = null;
                	//SFDC-5347 Change End
                    updatedContactList.add(con);
                }
            }
            return updatedContactList;
            
        }
    
    //-----------------------------
    // @author: Neelam Agrawal
    // @date: 20 Oct 2021
    // @param: Account Id
    // @description: SFDC#4821: IHSM CEP - Calulates rollup field for Accounts
    // @return: List<Account>
    //------------------------------
    	
    public static List<Account> updateAccountRollupFields(Set<Id> accountIdSet){
        Map<Id,List<SurveyResponse__c>> conSurveyMap = New Map <Id,List<SurveyResponse__c>>();
        List<Account> updatedAccountList = new List<Account>();
        Set<Id> accountIdWithoutSR= accountIdSet;
        Id srCorpRecordTypeId = SurveyResponseMethods.corporateRecordTypeId;
        Id srTransRecordTypeId = SurveyResponseMethods.TransactionalRecordTypeId;
        Id srTrainingRecordTypeId = SurveyResponseMethods.TrainingRecordTypeId;
        List<SurveyResponse__c> surveyList = [SELECT Id,Account__c,RecordTypeId, CESScore__c,CSATScore__c,TrainingMetNeeds__c,NPSScore__c FROM SurveyResponse__c WHERE Account__c IN: accountIdSet];
        for(SurveyResponse__c sr : surveyList) {
            If (!conSurveyMap.keyset().contains(sr.Account__c) && sr.Account__c != Null) {
                conSurveyMap.put(sr.Account__c, New List<SurveyResponse__c>());
            }
            conSurveyMap.get(sr.Account__c).add(sr);
        }
        accountIdWithoutSR.removeAll(conSurveyMap.keySet());
        for(Id accountId: conSurveyMap.keySet()) {
            Account acc= new Account();
            acc.Id=accountId;
            Double averageCES = 0;    
            Double averageCSAT = 0;  
            Double averageTrainingMetNeeds = 0; 
            Double averageNPS = 0;
            //SFDC-5347 Change Start
            Double corporateDetractors = 0;
            Double corporatePromoters = 0;
	    	Double transactionalDetractors = 0;
            Double transactionalPromoters = 0;
	    	Double trainingDetractors = 0;
            Double trainingPromoters = 0;
            //SFDC-5347 Change End
            Double NumberOfRespondents = 0;
            Integer totalCESTransactionalSurveyRecords = 0;
            Integer totalCSATransactionalSurveyRecords = 0;
            Integer totalTrainingSurveyRecords = 0;
            Integer totalCorporateSurveyRecords = 0;
            //SFDC-5347 Change Start
            Integer totalNPSTrainingSurveyRecords = 0;
            Integer totalNPSTransactionalSurveyRecords = 0;
            //SFDC-5347 Change End
            //Integer totalSurveyRecords = conSurveyMap.get(acc.Id).size();
            If (conSurveyMap.get(acc.Id) != null) {
                for(SurveyResponse__c sr: conSurveyMap.get(acc.Id)) {
                    if(sr.RecordTypeId == srTransRecordTypeId){
                        totalCESTransactionalSurveyRecords += 1;
                        if(sr.CESScore__c != null) {
                            averageCES = averageCES + sr.CESScore__c;
                        }
                        //SFDC-5347 Change Start
						if(sr.NPSScore__c != null){
                            if(sr.NPSScore__c >=0 && sr.NPSScore__c <7){
                                transactionalDetractors += 1;
                                totalNPSTransactionalSurveyRecords += 1;
                            }
                            if(sr.NPSScore__c > 8 && sr.NPSScore__c <=10){
                                transactionalPromoters += 1;
                                totalNPSTransactionalSurveyRecords += 1;
                            }
                        }
                        //SFDC-5347 Change End
                    }
                    if(sr.CSATScore__c != null && sr.RecordTypeId == srTransRecordTypeId){
                        averageCSAT = averageCSAT + sr.CSATScore__c;
                        totalCSATransactionalSurveyRecords += 1;
                    }
                    if(sr.RecordTypeId == srTrainingRecordTypeId){
                        totalTrainingSurveyRecords += 1;
                        if(sr.TrainingMetNeeds__c != null){
                            averageTrainingMetNeeds = averageTrainingMetNeeds + sr.TrainingMetNeeds__c;
                        }
                        //SFDC-5347 Change Start
						if(sr.NPSScore__c != null){
                            if(sr.NPSScore__c >=0 && sr.NPSScore__c <7){
                                trainingDetractors += 1;
                                totalNPSTrainingSurveyRecords += 1;
                            }
                            if(sr.NPSScore__c > 8 && sr.NPSScore__c <=10){
                                trainingPromoters += 1;
                                totalNPSTrainingSurveyRecords += 1;
                            }
                        }
                        //SFDC-5347 Change End
                    }
                    if(sr.RecordTypeId == srCorpRecordTypeId){
                        if(sr.NPSScore__c != null){
                            if(sr.NPSScore__c >=0 && sr.NPSScore__c <7){
                                corporateDetractors += 1;
                                totalCorporateSurveyRecords += 1;
                            }
                            if(sr.NPSScore__c > 8 && sr.NPSScore__c <=10){
                                corporatePromoters += 1;
                                totalCorporateSurveyRecords += 1;
                            }
                        }
                        //totalCorporateSurveyRecords += 1;
                    }
                }    
            }
            acc.CCCES__c = totalCESTransactionalSurveyRecords==0?0:(averageCES/totalCESTransactionalSurveyRecords); 
            if(acc.CCCES__c == 0){
                acc.CCCES__c = null;
            }
            acc.CCCSAT__c = totalCSATransactionalSurveyRecords==0?0:(averageCSAT/totalCSATransactionalSurveyRecords); 
            if(acc.CCCSAT__c == 0){
                acc.CCCSAT__c = null;
            } 
            acc.TrainingTrainingMetNeeds__c = totalTrainingSurveyRecords==0?0:(averageTrainingMetNeeds/totalTrainingSurveyRecords);
            if(acc.TrainingTrainingMetNeeds__c == 0){
                acc.TrainingTrainingMetNeeds__c = null;
            }
            if(totalCorporateSurveyRecords != 0){
                acc.CorporateNPS__c = totalCorporateSurveyRecords==0?0:((corporatePromoters - corporateDetractors)/totalCorporateSurveyRecords*100);
            }
            else{
                acc.CorporateNPS__c = null;
            }
            //SFDC-5347 Change Start
	    	if(totalNPSTransactionalSurveyRecords != 0){
                acc.TransactionalNPS__c = totalNPSTransactionalSurveyRecords==0?0:((TransactionalPromoters - TransactionalDetractors)/totalNPSTransactionalSurveyRecords*100);
            }
            else{
                acc.TransactionalNPS__c = null;
            }
	    	if(totalNPSTrainingSurveyRecords != 0){
                acc.TrainingNPS__c = totalNPSTrainingSurveyRecords==0?0:((TrainingPromoters - TrainingDetractors)/totalNPSTrainingSurveyRecords*100);
            }
            else{
                acc.TrainingNPS__c = null;
            }
            //SFDC-5347 Change End
            updatedAccountList.add(acc);
        }
        if(!accountIdWithoutSR.isEmpty()){
            for(Id accountId:accountIdWithoutSR){
                Account acc=new Account();
                acc.Id=accountId;
                acc.CCCES__c = null;
                acc.CCCSAT__c = null;
                acc.TrainingTrainingMetNeeds__c = null;
                acc.CorporateNPS__c = null;
                //SFDC-5347 Change Start
				acc.TransactionalNPS__c = null;
				acc.TrainingNPS__c = null;
                //SFDC-5347 Change End
                updatedAccountList.add(acc);
            }
        }
        return updatedAccountList;
    }
}