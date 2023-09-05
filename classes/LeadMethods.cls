//-----------------------------
// @author : Paras Dhingra
// @date : 8th Aug 2017
// @description : SFDC1-1081 common class for Lead trigger
// @companyname : IHS Markit
//-----------------------------
public class LeadMethods {
    
      //-----------------------------
      // @author : Paras Dhingra
      // @date : 8th Aug 2017
      // @description : SFDC1-1081 update Country lookup 
      //             based on the OOB country picklist
      // @param : TriggerParameters
      // @return : void
      // @companyname :IHS Markit
      // @lastupdated : SFDC1-192 : Mohit Modi : Updated the complete logic to move from after events to before updates as it was causing the issue 
      // Validation rule created newly.Country field will be updated in before insert and after Events.
      //-----------------------------
      
    public static void updateCountryLookup(TriggerParameters tp) {
          
        if (tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert || tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {

            Map<Id, Lead> oldMap = (Map<Id, Lead>)tp.oldMap;

            for(lead newlead : (list<lead>)tp.newList)
            {
                // Checking if it is Insert or Update Event
                if(oldMap == NULL || (oldMap != NULL && newlead.CountryCode != oldMap.get(newlead.id).CountryCode))
                {
                    if(newlead.CountryCode != NULL)
                    {
                        Country__c country = UtilityClass.getCountryByIsoCode(newlead.CountryCode);
                        System.debug('country-----'+country);
                        // Adding the Country if found else keep the blank value.
                        newlead.Country__c = country!=null ? country.Id : NULL ;
                    }
                    else {
                        // Clearing the Country field if Country is removed.
                        newlead.Country__c = NULL;
                    }
                }
            }
        }   
    }
    
    
      //-----------------------------
      // @author : Anjani Shukla
      // @date : 14th May 2018
      // @description : SFDC1-6570 : This Method will update Lead Description 
      //                on opportunity after lead conversion process.
      //              : SFDC1-8536 - Move all Lead object related Process Builder logic in the trigger.
      //              : PB Story - 4551 -IsConvertedLeads() && IsConvertedOpportunityId not NULL Only,Update Oportunity 
      //              : Closed Date - Original to Today() + 60;
      //              : ClosedDate - Today() + 60 
      // @param : TriggerParameters
      // @return : void
      // @companyname :Vertiba
      //-----------------------------
      
    public static void updateLeadDescriptionOnOpty(TriggerParameters tp) {
        
        if (tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
            //Get Details for Leads and Converted Opportunity
            Map<Id, Lead> oldMap = (Map<Id, Lead>)tp.oldMap;
            Map<Id, Lead> newMap = (Map<Id, Lead>)tp.newMap;
            list<opportunity> lstopportunity = new list<Opportunity>();
            for(lead newlead : (list<lead>)tp.newList) {
                if(newlead.IsConverted && !oldMap.get(newlead.id).IsConverted && newlead.ConvertedOpportunityId != null) {
                    Opportunity objOpp = new Opportunity (id = newlead.ConvertedOpportunityid, 
                                                          Description = newLead.Description,
                                                         CloseDateOriginal__c = System.today() + 60,
                                                          CloseDate = System.today() +60,
                        								 SourceSystem__c = 'Lead Generated');
                    system.debug('objOpp-->'+objOpp);
                    lstopportunity.add(objOpp);
                }    
            }
            
            // Update Opportunity
            if(!lstopportunity.isEmpty()) {
                system.debug('lstopportunity-->'+lstopportunity);
                update lstopportunity;
            }
            
        }   
    }
    
      //-----------------------------
      // @author : Anjani Shukla
      // @date : 06 Jun 2018
      // @description : SFDC1-8536 - Move all Lead object related Process Builder logic in the trigger.
      //              : PB Story - SFDC1-2305 - IsNew() Only,Update to Lead Source field (Marketing Profile - Marketing Generated,
      //              : Sales Profile - Rep Generated,Customer Care profile - Customer Care)
      //              : SFDC1-192 : Setting LeadStatus based on LoggedinUser Profile
      // @param : TriggerParameters
      // @return : void
      // @companyname :vertiba
      // @lastupdatedby : Mohit Modi
      // @lastupdateddescription : SFDC1-9490 , Updated the Code for correct PicklistValues.
      //-----------------------------
      
    public static void updatetoNewLeadSourcefield(TriggerParameters tp) {
        List<Lead> newLeadList = (List<Lead>)tp.newList;
        
        if (tp.tEvent == TriggerParameters.TriggerEvent.BeforeInsert) {
            Id profileId = UserInfo.getProfileId();
            String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
            system.debug('profileName==>'+profileName);
            //Validate Criteria
            for(Lead leadObj: newLeadList) { 
                // If created by Marketing User, then update Lead Source to Marketing Generated & Status to Pre-Sales Working.
                if(profileName.contains('IHSMarkit Sales: Marketing') || profileName.contains('Marketing')) {
                    leadObj.LeadSource = 'Marketing Generated';
                    leadObj.Status = 'Pre-SalesWorking';
                }
                // If created by Sales User, then update Lead Source to Rep Generated & Status to Sales Working.
                else if(profileName.contains('IHSMarkit Sales: General') || profileName.contains('General')) {
                    leadObj.LeadSource = 'Rep Generated';
                    leadObj.Status = 'SalesWorking';
                }
                // If created by Sales User, then update Lead Source to Rep Generated & Status to Sales Working.
                else if(profileName.contains('Customer Care')) {
                    leadObj.LeadSource = 'Customer Care';
                }
            }
        }    
    }       
    
    
    //-----------------------------
    // @author: Anjani Shukla
    // @date: 04 July 2018
    // @param:  Lead Object and converted Opportunity Id 
    // @description: SFDC1-8326 Update Campaign Influence to Work with OoB Lead Conversion and for Equal Attribution
    // @return: NA
    // @Company: Vertiba
    //------------------------------    
    public static void campaignFromLeadToOpportunity(TriggerParameters tp) {        
      try {  
        if (tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
            //Get Details for Leads and Converted Opportunity
            Map<Id, Lead> oldMap = (Map<Id, Lead>)tp.oldMap;
            Map<Id, Lead> newMap = (Map<Id, Lead>)tp.newMap;
            Set<Id> leadIds = new Set<Id>();
			
			//SFDC-4424
			Set<Id> setOpportunityId=new Set<Id>();
            Set<Id> setCampaignId=new Set<Id>();
            
            //get Campaign Influence Model 
            List<CampaignInfluenceModel> CampaignModelLst = [select Id from CampaignInfluenceModel where IsDefaultModel= true limit 1];
            
            Id CampaignModel = CampaignModelLst[0].id;
            
            
            //get converted lead id details.
            
            for(lead newlead : (list<lead>)tp.newList) {
                if(newlead.IsConverted && !oldMap.get(newlead.id).IsConverted && newlead.ConvertedOpportunityId != null) {
                    leadIds.add(newlead.id);    
                }
            }
            
            Map<id,CampaignMember> campMembers;
            
            if(leadIds != null && !leadIds.isEmpty()) {
                //get Campaign details for converted lead.
                campMembers = new Map<id,CampaignMember>([select Id,CampaignId,CompanyOrAccount,ContactId,
                                                         LeadId,Lead.convertedOpportunityid,LeadOrContactId from CampaignMember
                                                         where LeadId IN: leadIds]);
            }    
            
            Set<id> campIds = new Set<Id>();
            //Map contains key as leadid and values as list of campaign members 
            Map<Id,List<CampaignMember>> leadCampaignMemberMap = new Map<Id,List<CampaignMember>>();
            if(campMembers != null && !leadIds.isEmpty()) {
                for (CampaignMember cm : campMembers.values()) {
                    List<CampaignMember> campMemberLst = leadCampaignMemberMap.get(cm.LeadId);
                    if (campMemberLst == null) {
                        campMemberLst = new List<CampaignMember>();
                    }
                    campMemberLst.add(cm);
                    leadCampaignMemberMap.put(cm.Leadid, campMemberLst);
					
					//SFDC-4424
					setCampaignId.add(cm.CampaignId);
                    setOpportunityId.add(cm.Lead.convertedOpportunityid);
                }
                
            }    
            //List for campaign influence record.
            List<CampaignInfluence> campaignInfluenceList = new List<CampaignInfluence>();
			
			//SFDC-4424
			Map<String,CampaignInfluence> mapCampaignInfluence=new Map<String,CampaignInfluence>();
            if(!setCampaignId.IsEmpty() &&  !setOpportunityId.IsEmpty()) {
                for(CampaignInfluence  cmpInf:[Select Id ,OpportunityId,CampaignId from CampaignInfluence where OpportunityId IN:setOpportunityId and CampaignId IN:setCampaignId ]) {
                    mapCampaignInfluence.put(cmpInf.OpportunityId+' '+cmpInf.CampaignId,cmpInf);
                }
            }
            
            
            //check if lead has campaigns
            if(leadCampaignMemberMap != null && !leadCampaignMemberMap.isEmpty()) {
                for(Id leadObj :newMap.keyset()) {
                    for(CampaignMember campaignMembers: leadCampaignMemberMap.get(leadObj)) {
						//below if condition added for SFDC-4424
						if( mapCampaignInfluence.IsEmpty() || (!mapCampaignInfluence.IsEmpty() && !mapCampaignInfluence.containsKey(campaignMembers.Lead.convertedOpportunityid +' '+ campaignMembers.CampaignId))) {
							CampaignInfluence campInfluence = new CampaignInfluence();
							campInfluence.OpportunityId = campaignMembers.Lead.convertedOpportunityid;
							campInfluence.CampaignId = campaignMembers.CampaignId;
							campInfluence.ModelId = CampaignModel;
							campInfluence.Influence = (Double)0;
							campaignInfluenceList.add(campInfluence);
						}
                    }                        
                }   
            }
            
            if(!campaignInfluenceList.isEmpty()) {
                    insert campaignInfluenceList;
            }
        }
      } catch(Exception ex) {
            //UtilityClass.createApexLogRecord(ex,'LeadMethods','campaignFromLeadToOpportunity'); 
            ApexLogger.logandAddError(new LogMessage('LeadMethods','campaignFromLeadToOpportunity',ex,tp.newList.get(0),null ));  
      }  
    }
    
      //-----------------------------
      // @author: Tran-Vu Tran
      // @date: 12th Sep 2018
      // @description: SFDC1-8827 after a lead is created, check if the Lead was converted from a Customer Care case
      //                and if there is an Account Governance case generated from that Customer Care case 
      //                then update the Lead Reference on that Account Governance case with the Id of this Lead record
      // @param: TriggerParameters
      // @return: void
      //-----------------------------
      
    public static void updateAccountGovernanceCaseLeadReference(TriggerParameters tp) {
        try {
            if (tp.tEvent == TriggerParameters.TriggerEvent.afterInsert) {
                // retrieving all source cases for the new Leads
                Map<Id, Id> leadSourceCaseMap = new Map<Id, Id>();
                For (Lead newlead : (List<Lead>)tp.newList) {
                    If (newlead.SourceCase__c != null) {
                        leadSourceCaseMap.put(newlead.SourceCase__c, newlead.Id);
                    }
                }
                //System.debug('---------- leadSourceCaseMap: ' + leadSourceCaseMap);
    
                if (leadSourceCaseMap.size() > 0) {
                    
                    // retrieving all Account Govenance cases that were generated from the source cases above
                    List<Case> accountGovnCases = new List<Case>(
                        [Select Id, CaseReference__c, LeadReference__c from Case where CaseReference__c in : leadSourceCaseMap.KeySet()]
                    );
                    //System.debug('---------- accountGovnCases: ' + accountGovnCases);
                    
                    // updating the Lead Reference values for these Account Govenance cases
                    For (Case agCase : accountGovnCases) {
                        agCase.LeadReference__c = leadSourceCaseMap.get(agCase.CaseReference__c);
                    }
                    //System.debug('---------- accountGovnCases: ' + accountGovnCases);
                    
                    update accountGovnCases;
                }
                
            }   
        }
		catch(Exception ex) {
            //UtilityClass.createApexLogRecord(ex, 'LeadMethods', 'updateAccountGovernanceCaseLeadReference');
            ApexLogger.logandAddError(new LogMessage('LeadMethods','updateAccountGovernanceCaseLeadReference',ex,tp.newList.get(0),null ));  
        }
    }

    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 16 Sep 2018
    // @description: SFDC1-9416 default to using Assignment Rules for Leads converted from Customer Care cases
    // @param: TriggerParameters
    // @return: void
	// @Last Modified By : DigVijay Singh
	// @Last Modified Date : 05 Jan 2022
	// @Last Modified Description : SFDC-4829 Added SPG Record type to run lead assignment rule
	// @Last Modified By : DigVijay Singh
	// @Last Modified Date : 14 Feb 2022
	// @Last Modified Description : SFDC-5532 Added Lead Source = Transfer to run the assignment rule
    //-----------------------------
    public static void useDefaultAssignmentRule(TriggerParameters tp) {
        try {
             if (tp.tEvent == TriggerParameters.TriggerEvent.AfterInsert) {
                // since DML Options does not work for before-insert, we need to apply the logic for after-insert
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.assignmentRuleHeader.useDefaultRule = true; // use leadAssignment rules when updating
				Id leadSPGrefRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('SPG Referral Leads').getRecordTypeId();
                
                List<Lead> leadsToUpdate = new List<Lead>();
                for(Lead newLead: (List<Lead>)tp.newList) { 
                    if (newLead.LeadSource == 'Customer Care' || newLead.LeadSource=='SPG Referral' || newLead.RecordTypeId == leadSPGrefRecordTypeId || newLead.LeadSource=='Transfer') {
                        Lead leadObj = new Lead(Id = newLead.Id);
                        leadObj.setOptions(dmo);
                        leadsToUpdate.add(leadObj);
                    }
                }
                
                if (leadsToUpdate.size() > 0) {
                    update leadsToUpdate;
                }
            }
        }
        catch(Exception ex) {
            //UtilityClass.createApexLogRecord(ex, 'LeadMethods', 'useDefaultAssignmentRule');
            ApexLogger.logandAddError(new LogMessage('LeadMethods','useDefaultAssignmentRule',ex,tp.newList.get(0),null ));  
            
        }
    }           
	
	//-----------------------------
    // @author: Sruti Srivastava
    // @date: 21 Sep 2018
    // @description: SFDC1-8820: Populating Named Account on Lead with Domain of the lead's email and region match
    // @param: TriggerParameters
    // @return: void
    //-----------------------------
    public static void populateNamedAccountOnLead(TriggerParameters tp) {
        try {
	        if (tp.tEvent == TriggerParameters.TriggerEvent.BeforeInsert || 
                tp.tEvent == TriggerParameters.TriggerEvent.BeforeUpdate) {
                Set<String> emailDomains = new Set<String>();
                //Querying country values
				Map<String, Country__c> countryMap = UtilityClass.countryIdMap;
                
                //Storing Email Domains
				for (Lead objLead : (List<Lead>)tp.newList) {
					if(objLead.Email != null && objLead.Email.contains('@')) {
						emailDomains.add(objLead.Email.split('@').get(1));
					}	
				}
                    
				if (!emailDomains.isEmpty()) {
					Map<String, NamedAccountDomain__c> emailDomainToAccountMap = new Map<String, NamedAccountDomain__c>();
					//Querying values from NamedAccountDomain to compare with the domail on lead
					for (NamedAccountDomain__c objNamedDomain : [ Select Domain__c, Region__c, BusinessLine__c, BusinessLine__r.Name 
                                                                 from NamedAccountDomain__c 
                                                                 where Domain__c IN: emailDomains]) {
						emailDomainToAccountMap.put(objNamedDomain.Domain__c, objNamedDomain);
					}   
					
					if(!emailDomainToAccountMap.isEmpty()) {
						for (Lead objLead : (List<Lead>)tp.newList) {
                            String leadRegion = (!String.isBlank(objLead.Country__c) && countryMap.containsKey(objLead.Country__c))
                                					? countryMap.get(objLead.Country__c).Region__c : '';
							
                            String leadDomain = (objLead.Email != null && objLead.Email.contains('@')) ? 
                                					objLead.Email.split('@').get(1) : '';
                            String region = (emailDomainToAccountMap.containsKey(leadDomain) && !String.isBlank(emailDomainToAccountMap.get(leadDomain).Region__c)) ? 
                                                 emailDomainToAccountMap.get(leadDomain).Region__c : '';
                            set<String> setRegions = new set<String>();
                            
                            if(!String.isBlank(region)) {
                            	setRegions.addAll(region.split(';'));
                            }
                            
                            //If region is All, it will be a Named Account
                            if(!setRegions.isEmpty() && setRegions.contains('ALL')) {
								objLead.NamedAccount__c = 'Named Account' ;       
							} 
							//else compare region, domain and business line matches to populate "Named Account" value
							else if(!String.isBlank(leadDomain) && 
								emailDomainToAccountMap.containskey(leadDomain) &&
                                (string.isBlank(leadRegion) || 
                                 (!string.isBlank(leadRegion) &&
                                 setRegions.contains(leadRegion))) && 
                              	(string.isBlank(objLead.BusinessLineInterest__c ) ||
                                 (!string.isBlank(objLead.BusinessLineInterest__c) && 
                                 objLead.BusinessLineInterest__c.equalsIgnoreCase(emailDomainToAccountMap.get(leadDomain).BusinessLine__r.Name)))) {
                                
								if(!String.isBlank(leadRegion)) {
									objLead.NamedAccount__c = 'Named Account ' +objLead.BusinessLineInterest__c+ ' ' + leadRegion;  
								}
								else {
									objLead.NamedAccount__c = 'Named Account ' +objLead.BusinessLineInterest__c+ ' null';  
								}
							}
							else {
								objLead.NamedAccount__c = 'No';
							}
						}
					}
				}
				//For other leads with no email or No Named Account record in the org, it should be populated as "No"
				for (Lead objLead : (List<Lead>)tp.newList) {
					if(String.isBlank(objLead.NamedAccount__c)) {
						objLead.NamedAccount__c = 'No';
					}
				}
            }
        }
        catch(Exception ex) {
            //UtilityClass.createApexLogRecord(ex, 'LeadMethods', 'populateNamedAccountOnLead');
            ApexLogger.logandAddError(new LogMessage('LeadMethods','populateNamedAccountOnLead',ex,tp.newList.get(0),null ));  
            
        }
    } 
    //-----------------------------
    // @author: Akshay Dogra
    // @date: 08 Jun 2021
    // @description: SFDC-4046: Lead Time Enhancement Request
    // @param: TriggerParameters
    // @return: void
    //-----------------------------
    public static void LeadTime(TriggerParameters tp) {
        
        if (tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {
            
            Map<Id, Lead> oldMap = (Map<Id, Lead>)tp.oldMap;
            List<String> SDRLeadQueue = Label.SDRLeadQueue.split(',');
            List<String> SalesRepLeadQueue = Label.SalesRepLeadQueue.split(',');
            List<String> LMTLeadQueue = Label.LMTLeadQueue.split(',');
            
            for(lead newlead : (list<lead>)tp.newList) {  
                Long leadDate;
                Decimal diffMilliSecs;
                Decimal dDays;
                Long diff;
                Long createdDateTime = newlead.CreatedDate.getTime();
                
                //setting default value of few fields to zero
                LeadMethods.settingDefaultValues(newlead);
                
                if(newlead.OwnerId != oldMap.get(newlead.id).OwnerId && SDRLeadQueue.contains(newlead.OwnerId)) {
                    
                    leadDate = dateTime.now().getTime();
                    newlead.SDRQueueassignment__c = String.valueOf(leadDate);    
                    diffMilliSecs = Decimal.valueOf(long.valueOf(newlead.SDRQueueassignment__c) - createdDateTime);
                    dDays = (diffMilliSecs/1000/60/60/24).setScale(2);
                    newlead.SDRAssignmentTime__c = dDays<0 ? '0.00':String.valueOf(dDays);
                } 
                else if(newlead.Status != oldMap.get(newlead.id).Status && newlead.Status == 'Pre-SalesWorking') {
                    
                    leadDate = dateTime.now().getTime();
                    newlead.PreSalesWorking__c = String.valueOf(leadDate);
                    if(newlead.SDRQueueassignment__c == '0') {
                        newlead.SDRQueueassignment__c = String.valueOf(createdDateTime);
                    }
                    diff = long.valueOf(newlead.PreSalesWorking__c) - long.valueOf(newlead.SDRQueueassignment__c);
                    diffMilliSecs = Decimal.valueOf(diff);
                    dDays = (diffMilliSecs/1000/60/60/24).setScale(2);
                    newlead.SDRTimetoPickup__c = dDays<0 ? '0.00':String.valueOf(dDays);
                }
                else if(newlead.Status != oldMap.get(newlead.id).Status && (newlead.Status == 'Pre-SalesQualified' || newlead.Status == 'Disqualify') && oldMap.get(newlead.id).Status == 'Pre-SalesWorking') {
                    
                    leadDate = dateTime.now().getTime();
                    newlead.PreSalesQualifiedDisqualified__c = String.valueOf(leadDate);
                    if(newlead.PreSalesWorking__c == '0') {
                        newlead.PreSalesWorking__c = String.valueOf(createdDateTime);
                    }
                    diff = long.valueOf(newlead.PreSalesQualifiedDisqualified__c) - long.valueOf(newlead.PreSalesWorking__c);
                    diffMilliSecs = Decimal.valueOf(diff);
                    dDays = (diffMilliSecs/1000/60/60/24).setScale(2);
                    newlead.SDRQualificationTime__c = dDays<0 ? '0.00':String.valueOf(dDays);
                }
                else if(newlead.OwnerId != oldMap.get(newlead.id).OwnerId && !SalesRepLeadQueue.contains(newlead.OwnerId) && LMTLeadQueue.contains(oldMap.get(newlead.id).OwnerId) &&
                        (newlead.Status == 'Pre-SalesQualified' || newlead.Status == 'Disqualify') && newlead.Status == oldMap.get(newlead.id).Status) {
                            
                            leadDate = dateTime.now().getTime();
                            newlead.FirstSalesRepQueueAssignment__c = String.valueOf(leadDate);
                            newlead.LastSalesRepQueueAssignment__c = String.valueOf(leadDate);
                            if(newlead.PreSalesQualifiedDisqualified__c == '0') {
                                newlead.PreSalesQualifiedDisqualified__c = String.valueOf(createdDateTime);
                            }
                            diff = long.valueOf(newlead.FirstSalesRepQueueAssignment__c) - long.valueOf(newlead.PreSalesQualifiedDisqualified__c);
                            diffMilliSecs = Decimal.valueOf(diff);
                            dDays = (diffMilliSecs/1000/60/60/24).setScale(2);
                            newlead.LMTAssignmentTime__c = dDays<0 ? '0.00':String.valueOf(dDays);
                        }
                else if(newlead.OwnerId != oldMap.get(newlead.id).OwnerId && !SalesRepLeadQueue.contains(newlead.OwnerId) &&
                        (newlead.Status == 'Pre-SalesQualified' || newlead.Status == 'Disqualify' || newlead.Status == 'Prioritized' || newlead.Status == 'Pre-SalesWorking') && 
                        newlead.Status == oldMap.get(newlead.id).Status && newlead.FirstSalesRepQueueAssignment__c != '') {
                            
                            leadDate = dateTime.now().getTime();
                            newlead.LastSalesRepQueueAssignment__c = String.valueOf(leadDate);
                            if(newlead.FirstSalesRepQueueAssignment__c == '0') {
                                newlead.FirstSalesRepQueueAssignment__c = String.valueOf(createdDateTime);
                            }
                            diff = long.valueOf(newlead.LastSalesRepQueueAssignment__c) - long.valueOf(newlead.FirstSalesRepQueueAssignment__c);
                            diffMilliSecs = Decimal.valueOf(diff);
                            dDays = (diffMilliSecs/1000/60/60/24).setScale(2);
                            newlead.SalesAssignmentTime__c = dDays<0 ? '0.00':String.valueOf(dDays);
                        }
                else if(newlead.Status != oldMap.get(newlead.id).Status && newlead.Status == 'SalesWorking') {
                    
                    leadDate = dateTime.now().getTime();
                    newlead.SalesWorking__c = String.valueOf(leadDate);
                    if(newlead.LastSalesRepQueueAssignment__c == '0') {
                        newlead.LastSalesRepQueueAssignment__c = String.valueOf(createdDateTime);
                    }
                    diff = long.valueOf(newlead.SalesWorking__c) - long.valueOf(newlead.LastSalesRepQueueAssignment__c);
                    diffMilliSecs = Decimal.valueOf(diff);
                    dDays = (diffMilliSecs/1000/60/60/24).setScale(2);
                    newlead.SalesTimetoPickup__c = dDays<0 ? '0':String.valueOf(dDays);
                }
                else if(newlead.Status != oldMap.get(newlead.id).Status && oldMap.get(newlead.id).Status != 'Pre-SalesWorking' && (newlead.Status == 'Converted' || newlead.Status == 'Disqualify')) {
                    
                    leadDate = dateTime.now().getTime();
                    newlead.SalesConvertedDisqualified__c = String.valueOf(leadDate);
                    if(newlead.SalesWorking__c == '0') {
                        newlead.SalesWorking__c = String.valueOf(createdDateTime);
                    }
                    if(oldMap.get(newlead.id).Status == 'SalesWorking') {
                        diff = long.valueOf(newlead.SalesConvertedDisqualified__c) - long.valueOf(newlead.SalesWorking__c);
                    }
                    else if(oldMap.get(newlead.id).Status == 'Prioritized') {
                        diff = long.valueOf(newlead.SalesConvertedDisqualified__c) - long.valueOf(String.valueOf(createdDateTime)); 
                    }
                    else {
                        diff = long.valueOf(newlead.SalesConvertedDisqualified__c) - long.valueOf(newlead.LastSalesRepQueueAssignment__c);    
                    }
                    diffMilliSecs = Decimal.valueOf(diff);
                    dDays = (diffMilliSecs/1000/60/60/24).setScale(2);
                    newlead.SalesQualificationTime__c = dDays<0 ? '0.00':String.valueOf(dDays);
                } 
            } 
        }   
    }
    //-----------------------------
    // @author: Akshay Dogra
    // @date: 23 Jun 2021
    // @description: SFDC-4046: to set '0' as the default value for the below mentioned fields
    //-----------------------------
    public static lead settingDefaultValues(Lead newlead) {
        if(newlead.SDRQueueassignment__c == null) {
            newlead.SDRQueueassignment__c = '0';
        }
        if(newlead.PreSalesWorking__c == null) {
            newlead.PreSalesWorking__c = '0';
        }  
        if(newlead.PreSalesQualifiedDisqualified__c == null) {
            newlead.PreSalesQualifiedDisqualified__c = '0';
        }
        if(newlead.FirstSalesRepQueueAssignment__c == null) {
            newlead.FirstSalesRepQueueAssignment__c = '0';
        }
        if(newlead.LastSalesRepQueueAssignment__c == null) {
            newlead.LastSalesRepQueueAssignment__c = '0';
        }
        if(newlead.SalesWorking__c == null) {
            newlead.SalesWorking__c = '0';
        }        
        return newlead;
    }

    //-----------------------------
      // @author : Digvijay Singh
      // @date :  14th March 2022
      // @description : SFDC-5523 : If “Synergy” Lead is converted to an existing Renewal Oppy then the oppy will be 
      //                tagged as “Synergy”=Yes
      // @param : TriggerParameters
      // @return : void
      //-----------------------------
      
      public static void updateSynergyFlagonOpportunity(TriggerParameters tp) {
        
        if (tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
            //Get Details for Leads and Converted Opportunity
            Map<Id, Lead> oldMap = (Map<Id, Lead>)tp.oldMap;
            Map<Id, Lead> newMap = (Map<Id, Lead>)tp.newMap;
            list<opportunity> lstopportunity = new list<Opportunity>();
            for(lead newlead : (list<lead>)tp.newList) {

                //Check if the Lead is converted and ConvertedOpportunityId is Not Null
                if(newlead.IsConverted && !oldMap.get(newlead.id).IsConverted && newlead.ConvertedOpportunityId != null) {
                    Opportunity objOpp = new Opportunity (id = newlead.ConvertedOpportunityid, 
                                                         Synergy1__c = newLead.Synergy__c
                                                         );
                    lstopportunity.add(objOpp);
                }    
            }
            System.debug('updateSynergyFlagonOpportunity...'+lstopportunity);
            // Update Opportunity
            if(!lstopportunity.isEmpty()) {
                update lstopportunity;
            }
            
        }   
    }
    
}