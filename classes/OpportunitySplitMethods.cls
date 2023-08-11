//-----------------------------
// @author: Paras Dhingra
// @date: 12th Feb 2018
// @description: SFDC1-6857 Helper class for Opportunitysplit trigger
// @company: IHS Markit
//-----------------------------
public without sharing class  OpportunitySplitMethods  {

    //-----------------------------
    // @author: Tran-Vu Tran
    // @date: 12 February 2019
    // @description: SFDC-615 populate Split Country, Split Region, and Split Geography fields from Opportunity fields
    // This method will be called in before insert trigger Events.
    // @return: None
    //------------------------------
    public static void populateBeforeInsert(TriggerParameters tp) {
        
        Map<Id, Opportunity> mapOpportunity = new Map<Id, Opportunity>();
        List<OpportunitySplit> listNewOpportunitySplit = (List<OpportunitySplit>)tp.newList;
        Set<Id> setOpportunityIds = new Set<Id>();
        //Method should run on before insert
		if (tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert) {
        	try {
            	// Add all related opportunity to a set
                for (OpportunitySplit newSplit : listNewOpportunitySplit) {
					setOpportunityIds.add(newSplit.OpportunityId);
				}
                
                if (!setOpportunityIds.isEmpty()) {
                    // Querying related Opportunities
                    for (Opportunity opp : [Select Id, OpportunityCountry__c from Opportunity where Id in: setOpportunityIds]) {
                            mapOpportunity.put(opp.Id, opp);
                    }
                }
                
                for (OpportunitySplit newSplit : listNewOpportunitySplit) {
                    Opportunity opp = mapOpportunity.get(newSplit.OpportunityId);
                    if (opp != null && newSplit.SplitCountry__c == null) { // only populate SplitCountry__c if the value is null
                        newSplit.SplitCountry__c = opp.OpportunityCountry__c;
                    }
                }
            }
            
            catch(Exception e) {
                System.debug('Exception in OpportunitySplitMethods.populateBeforeInsert: ' + e.getMessage());
                UtilityClass.createApexLogRecord(e, 'OpportunitySplitMethods', 'populateBeforeInsert');
            }
        }
    }
        
    //-----------------------------
    // @author: Paras Dhingra
    // @date: 12th Feb 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-6857Method to update Opportunity team member access rights
    // @return: None
    //----------------------------
    public static final string CHANNELPARTNERNETWORKID = UtilityClass.ChannelPartnerId;
    public static void updateOpportunityTeamAccess(TriggerParameters tp) {

        List<OpportunitySplit> lstOpportunitySplitToProcess = new List<OpportunitySplit>();
         if(tp.tEvent == TriggerParameters.TriggerEvent.afterInsert) {
            lstOpportunitySplitToProcess = tp.newList;
            Set<Id> setOpportunityId = new Set<Id>();
            Set<Id> setSplitOwnerId = new Set<Id>();
            for(OpportunitySplit os : lstOpportunitySplitToProcess) {
                setOpportunityId.add(os.OpportunityId);
                setSplitOwnerId.add(os.SplitOwnerId);
            }
            if(!setOpportunityId.isEmpty() && !setSplitOwnerId.isEmpty()) {
                //query Opportunity split team access created before split creation
                List<OpportunityTeamMember> lstOpportunityTeamMember = [Select Id, OpportunityId, OpportunityAccessLevel, UserId
                                                                        from OpportunityTeamMember
                                                                        where OpportunityAccessLevel='Read' AND OpportunityId IN: setOpportunityId AND UserId IN: setSplitOwnerId];

                if(lstOpportunityTeamMember!=null && !lstOpportunityTeamMember.isEmpty()) {
                    for(OpportunityTeamMember otm : lstOpportunityTeamMember) {
                        //provide edit level access to opportunity splits added
                        otm.OpportunityAccessLevel = 'Edit';
                    }
                    update lstOpportunityTeamMember;
                }
            }
        }
    }
    //-----------------------------
    // @author: Paras Dhingra original code shared by Daniel Measures
    // @date: 13th Feb 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-6856 Method to post chatter updates on Opportunity split add/remove percentage update
    // @return: None
    // @companyname: IHS Markit, Salesforce.com
    //----------------------------
    public static void postChatterFeedItem(TriggerParameters tp) {

    Map<id,User> mUserIdToUser = new Map<id,User>();
    Set<id> userIds = new Set<Id>();
    Map<id,id> mOppIdToOwnerId = new Map<id,id>();
    Set<id> oppIds = new Set<id>();
    List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
    List<OpportunitySplit> lstOpportunitySplitToProcess = new List<OpportunitySplit>();
    // insert scenario (Note! update scenario is covered in this code without modification, if opp split user is changed the system deletes and re-creates the split)
    if(tp.tEvent == TriggerParameters.TriggerEvent.afterInsert) {
        lstOpportunitySplitToProcess = tp.newList;
        for(OpportunitySplit os : lstOpportunitySplitToProcess) {
            userIds.add(os.SplitOwnerId);
            oppIds.add(os.OpportunityId);
        }
        for(Opportunity o : [select id, OwnerId from Opportunity where id IN :oppIds]) {
            userIds.add(o.OwnerId);
            mOppIdToOwnerId.put(o.id, o.OwnerId);
        }
        if(!userIds.isEmpty()) {
            mUserIdToUser = new Map<id,User>([select id, firstname, lastname from User where id IN:userIds]);
        }
        for(OpportunitySplit os : lstOpportunitySplitToProcess) {
            String message = 'A new opportunity split has been CREATED for user ' + mUserIdToUser.get(os.SplitOwnerId).firstName + ' ' + mUserIdToUser.get(os.SplitOwnerId).lastName + ' with split percentage ' +os.SplitPercentage + '%. ';
            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(UtilityClass.getChatterFeedItemInput(os.OpportunityId,new List<String>{mOppIdToOwnerId.get(os.OpportunityId)},message));
            batchInputs.add(batchInput);
        }
    }
    // delete scenario
    if(tp.tEvent == TriggerParameters.TriggerEvent.afterDelete) {
        lstOpportunitySplitToProcess = tp.oldList;
        for(OpportunitySplit os : lstOpportunitySplitToProcess) {
            userIds.add(os.SplitOwnerId);
            oppIds.add(os.OpportunityId);
        }
        for(Opportunity o : [select id, OwnerId from Opportunity where id IN :oppIds]) {
            userIds.add(o.OwnerId);
            mOppIdToOwnerId.put(o.id, o.OwnerId);
        }
        if(!userIds.isEmpty()) {
            mUserIdToUser = new Map<id,User>([select id, firstname, lastname from User where id IN:userIds]);
        }
        for(OpportunitySplit os : lstOpportunitySplitToProcess) {
            String message = 'An opportunity split has been DELETED for user ' + mUserIdToUser.get(os.SplitOwnerId).firstName + ' ' + mUserIdToUser.get(os.SplitOwnerId).lastName + ' with split percentage ' +os.SplitPercentage + '%. ';
            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(UtilityClass.getChatterFeedItemInput(os.OpportunityId,new List<String>{mOppIdToOwnerId.get(os.OpportunityId)},message));
            batchInputs.add(batchInput);
        }
    }
    //update scenario for percentage changes
    if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
        lstOpportunitySplitToProcess = tp.newList;
        for(OpportunitySplit os : lstOpportunitySplitToProcess) {
            OpportunitySplit oldOS = (OpportunitySplit)tp.oldMap.get(os.Id);
            if(os.SplitPercentage!=oldOS.SplitPercentage) {
                userIds.add(os.SplitOwnerId);
                oppIds.add(os.OpportunityId);
            }
        }
        for(Opportunity o : [select id, OwnerId from Opportunity where id IN :oppIds]) {
            userIds.add(o.OwnerId);
            mOppIdToOwnerId.put(o.id, o.OwnerId);
        }
        if(!userIds.isEmpty()) {
            mUserIdToUser = new Map<id,User>([select id, firstname, lastname from User where id IN:userIds]);
            for(OpportunitySplit os : lstOpportunitySplitToProcess) {
                
                if(mUserIdToUser!=null && mUserIdToUser.get(os.SplitOwnerId)!=null) {
                    OpportunitySplit oldOS = (OpportunitySplit)tp.oldMap.get(os.Id);
                    System.debug('--SplitOwnerId--' + os.SplitOwnerId);
                    System.debug('--mUserIdToUser--'+mUserIdToUser.get(os.SplitOwnerId));
                    String message = 'An opportunity split has been UPDATED for user ' + mUserIdToUser.get(os.SplitOwnerId).firstName;
                    message += + ' ' + mUserIdToUser.get(os.SplitOwnerId).lastName;
                    message+= ' with split percentage from ' +oldOS.SplitPercentage;
                    message+= '% to '+ os.SplitPercentage + '%. ';
                    ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(UtilityClass.getChatterFeedItemInput(os.OpportunityId,new List<String>{mOppIdToOwnerId.get(os.OpportunityId)},message));
                    batchInputs.add(batchInput);
                }
                
            }
        }

    }
    // insert the feedItems
    if(!batchInputs.isEmpty()) {
        if(!Test.isRunningTest()) {
            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
            }
        }

    }
    //-----------------------------
    // @author: Paras Dhingra
    // @date: 27th Feb 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-7048 Method to add EntitySubscription record for Opportunity Split members
    // @lastmodifiedby : Sruti Srivastava
    // @lastmodifieddate : 23 Aug 2018
    // @lastmodifieddescription : SFDC1-9796-preventing EntitySubscription for inactive users
    // @return: None
    // @companyname: IHS Markit
    // @modifiedby: Paras Dhingra
    // @modifieddate: 17 Sep 2020
    // @modifiedDescription: SFDC-3387 suppressing the exception happening in the auto follow to prevent issues from happening
    //----------------------------
    public static void autoFollowOpportunityOnInsert(TriggerParameters tp) {
        List<OpportunitySplit> lstOpportunitySplitToProcess = new List<OpportunitySplit>();
        System.debug('--Entering auto follow of opportunity--');
        Map<String,EscapeEntitySubscriptions__c> escapeUsers = EscapeEntitySubscriptions__c.getAll();
        if(tp.tEvent == TriggerParameters.TriggerEvent.afterInsert) {
            lstOpportunitySplitToProcess = tp.newList;
            //Map of Opportunity splits and it's opportunity
            Map<Id,Set<Id>> mapOppySplitOwner = new Map<Id,Set<Id>>();
            Set<Id> setUserId = new Set<Id>();
            List<EntitySubscription> lstOppyFollowToInsert = new List<EntitySubscription>();
            //populated the map with splitowner id and it's opportunity record id
            for(OpportunitySplit os: lstOpportunitySplitToProcess) {
                if(mapOppySplitOwner.containsKey(os.OpportunityId)) {
                    mapOppySplitOwner.get(os.OpportunityId).add(os.SplitOwnerId);
    
                }
                else {
                    mapOppySplitOwner.put(os.OpportunityId,new Set<Id>{os.SplitOwnerId});
                }
                setUserId.add(os.SplitOwnerId);
            }
            
            system.debug('--mapOppySPlitOwner--'+mapOppySplitOwner);
            //query EntitySubscription record for Opportunity subscribers
            if(mapOppySplitOwner!=null && !mapOppySplitOwner.isEmpty()) {
                List<EntitySubscription> lstOppySubscribers = [Select Id,parentId, subscriberId 
                                                                from EntitySubscription 
                                                                where parentId IN: mapOppySplitOwner.keySet()];
                //update map if record already exist                                               
                if(lstOppySubscribers!=null && !lstOppySubscribers.isEmpty()) {
                    
                    for(EntitySubscription oppyFollower : lstOppySubscribers) {
                        setUserId.add(oppyFollower.subscriberId);
                        if(mapOppySplitOwner.containsKey(oppyFollower.parentId)) {
                            
                            if(mapOppySplitOwner.get(oppyFollower.parentId).contains(oppyFollower.subscriberId)) {
                                mapOppySplitOwner.get(oppyFollower.parentId).remove(oppyFollower.subscriberId);
                            }
                        }
                    }
                    
                }
                
                if(!setUserId.isEmpty()) {
                    //query community users
                    Map<Id,User> mapUsers = new Map<Id,User>(
                                                    [Select Id, IsPortalEnabled, isActive
                                                    from User where Id IN:setUserId]
                    );
                    //process map to prepare list to insert oppy subscription
                    for(Id oppyId: mapOppySplitOwner.keySet()) {
                        for(Id userId: mapOppySplitOwner.get(oppyId)) {
                            //only active users should subscribe to Opportunity
                            if(mapUsers.containsKey(userId) && mapUsers.get(userId).isActive ==  true && !escapeUsers.containsKey(userId)) {
                                EntitySubscription oppyFollow = new EntitySubscription();
                                oppyFollow.parentId = oppyId;
                                oppyFollow.subscriberId = userId;
                                //check if user is community user
                                System.debug('Channerl Partner Network Id'+CHANNELPARTNERNETWORKID);
                                System.debug('mapUsers' + mapUsers);
                                if(mapUsers.containsKey(userId) && mapUsers.get(userId).IsPortalEnabled) {
                                    oppyFollow.NetworkID = CHANNELPARTNERNETWORKID;
                                }
                                lstOppyFollowToInsert.add(oppyFollow);
                            }
                        }
                    }
                    if(lstOppyFollowToInsert!=null && !lstOppyFollowToInsert.isEmpty()) {
                        Database.SaveResult [] lstSR;
                        List<ApexLogger__c> apexLogResults = new List<ApexLogger__c>();
                        lstSR = Database.insert(lstOppyFollowToInsert, false);
                        for(Integer i=0; i<lstOppyFollowToInsert.size(); i++) {
                            Database.SaveResult sr = lstSR[i];
                            if(!sr.isSuccess()) {
                                for(Database.Error err: sr.getErrors()) {
                                    ApexLogger__c logObj = new ApexLogger__c();
                                    logObj.ClassName__c = 'OpportunitySplitMethods';
                                    logObj.ErrorDescription__c = 'Error occurred during entity subscription insertion for Subscriber=> '+lstOppyFollowToInsert[i].SubscriberId +' Error Message ===> ' + err.getMessage();
                                    logObj.FunctionName__c = 'autoFollowOpportunityOnInsert';
                                    logObj.LogRecordId__c = lstOppyFollowToInsert[i].ParentId;            
                                    apexLogResults.add(logObj);
                                }
                                
                            }
                        }
						if(apexLogResults!=null && apexLogResults.size()>0) {
							insert apexLogResults;
                        }
                    }
                }
            }
            
        }

    }
    //-----------------------------
    // @author: Jagadesh Kumar
    // @date: 20th April 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-8019 Method to validate overlay split amount for Opportunity Split members
    // @return: None
    // @companyname: Vertiba
    //----------------------------
    //SFDC1-7578-Due to limitation from SF end commenting this code for now.
    /*public static void validateOverlaySplitAmount(TriggerParameters tp) {
        Map<Id,Decimal> opptySplitOverlayMap = new Map<Id,Decimal>();
        Map<Id,OpportunitySplitType> splitTypeMap = new Map<Id,OpportunitySplitType>([SELECT DeveloperName,Id,MasterLabel,SplitField FROM OpportunitySplitType where SplitField = 'Amount']);
        set<Id> opptyIds = new set<Id>();
        //Map<opptyid,Map<splitid,splitpercentage>>
        Map<Id,Map<Id,Decimal>> opptyOverlaySplitPercentMap =  new Map<Id,Map<Id,Decimal>>();
        System.debug('---------splitTypeMap------'+splitTypeMap);
        if(tp.tEvent == TriggerParameters.TriggerEvent.beforeUpdate) {
            for(OpportunitySplit oSplit : (List<OpportunitySplit>)tp.newList) {
                opptyIds.add(oSplit.OpportunityId);
            }
            List<OpportunitySplit> splitList = [SELECT Id,OpportunityId,Split,SplitAmount,SplitNote,SplitPercentage,SplitTypeId FROM OpportunitySplit where OpportunityId in :opptyIds and SplitType.DeveloperName = 'Overlay'];
            //opptyOverlaySplitPercentMap
            for(OpportunitySplit oSplit : splitList) {
                if(opptyOverlaySplitPercentMap.get(oSplit.OpportunityId) == null) {
                    Map<Id,Decimal> spliPercentageMap = new Map<Id,Decimal>();
                    Decimal sPercentage = (Decimal)oSplit.SplitPercentage;
                    spliPercentageMap.put(oSplit.Id, sPercentage);
                    opptyOverlaySplitPercentMap.put(oSplit.OpportunityId,spliPercentageMap);
                } else {
                    Decimal sPercentage = (Decimal)oSplit.SplitPercentage;
                    opptyOverlaySplitPercentMap.get(oSplit.OpportunityId).put(oSplit.Id, sPercentage);
                }
            }
            //Update record percentage data from trigger.newList
            for(OpportunitySplit oSplit : (List<OpportunitySplit>)tp.newList) {
                if(opptyOverlaySplitPercentMap.get(oSplit.OpportunityId)!= null) {
                    String splitType = splitTypeMap.get(oSplit.SplitTypeId).DeveloperName;
                    if(splitType == 'Overlay') {
                        Decimal sPercentage = (Decimal)oSplit.SplitPercentage;
                        opptyOverlaySplitPercentMap.get(oSplit.OpportunityId).put(oSplit.Id, sPercentage);
                    }
                }
            }
            System.debug('----final Map 2 ----'+opptyOverlaySplitPercentMap);
            //Map<opptyid,totaloverlaysplitpertage>
            Map<Id,Decimal> opptyOverlayPercentMap = new Map<Id,Decimal>();
            for (Id opptyId : opptyOverlaySplitPercentMap.keySet()) {  
                for(Decimal per : opptyOverlaySplitPercentMap.get(opptyId).values()) {
                    if(opptyOverlayPercentMap.get(opptyId) == null) {
                        opptyOverlayPercentMap.put(opptyId,0.00);
                    }
                    Decimal totalPer = opptyOverlayPercentMap.get(opptyId)+per;
                    opptyOverlayPercentMap.put(opptyId,totalPer);
                }           
            }
            System.debug('-- final oppty Percentage --'+opptyOverlayPercentMap);
            for(OpportunitySplit oSplit : (List<OpportunitySplit>)tp.newList) {
                if(opptyOverlayPercentMap.get(oSplit.OpportunityId) != null && opptyOverlayPercentMap.get(oSplit.OpportunityId) != 100.00) {
                    oSplit.addError(System.Label.OpptyOverlayAmountValidationMsg);
                }
            }
        }
    }*/
    //-----------------------------
    // @author: Jagadesh Kumar
    // @date: 27th April 2018
    // @param: TriggerParameters tp
    // @description: SFDC1-7037 Roll up SplitOwner name for Fields Sales Specialists, Account Managers and Overlay 
    // @return: None
    // @companyname: Vertiba
    //----------------------------
    public static void updateOpptySplitTeamName(TriggerParameters tp) {
        set<Id> opptyIds = new set<Id>();
        if(tp.tEvent == TriggerParameters.TriggerEvent.afterInsert) {
            for(OpportunitySplit oSplit : (List<OpportunitySplit>)tp.newList) {
                opptyIds.add(oSplit.OpportunityId);
            }
        }
        // delete scenario
        if(tp.tEvent == TriggerParameters.TriggerEvent.afterDelete) {
            for(OpportunitySplit oSplit : (List<OpportunitySplit>)tp.oldList) {
                opptyIds.add(oSplit.OpportunityId);
            }
        }
        if(!opptyIds.isEmpty()) {
            List<Opportunity> opptyList = [SELECT Id,AccountManagers__c,SalesSpecialists__c,Overlay__c,
                                           (SELECT Id,SplitOwner.Name,SplitType.MasterLabel FROM OpportunitySplits ORDER BY SplitOwner.Name ASC)    
                                           FROM Opportunity where Id in :opptyIds];
            for(Opportunity opp : opptyList) {
                String salesSpecialists = '';
                String accountManagers = '';
                String overlay = '';
                for(OpportunitySplit split : opp.OpportunitySplits) {
                    if(split.SplitType.MasterLabel == 'Sales Specialists') { 
                        salesSpecialists = salesSpecialists + split.SplitOwner.Name + ', ';
                    }
                    if(split.SplitType.MasterLabel == 'Account Managers') { 
                        accountManagers = accountManagers + split.SplitOwner.Name + ', ';
                    }
                    if(split.SplitType.MasterLabel == 'Overlay') {
                        overlay = overlay + split.SplitOwner.Name + ', ';
                    }
                }
                opp.SalesSpecialists__c = salesSpecialists.removeEnd(', ');
                //opp.AccountManagers__c = accountManagers.removeEnd(', ');
                opp.AccountManagers__c = OpportunityMethods.isAccountManagersPresent ? opp.AccountManagers__c : accountManagers.removeEnd(', ');
                opp.Overlay__c = overlay.removeEnd(', '); 
            }
            System.debug('-----opptyList--'+opptyList);
            update opptyList;
        }
    }
    //-----------------------------
    // @author: Akshay Dogra
    // @date: 28 Oct 2020
    // @description: SFDC-3262 Method to populate Team Member Country
    // @param: TriggerParameters tp
    // @return: None
    //------------------------------     
    public static void teamMemberCountryPopulate(TriggerParameters tp){
        Map<Id, User> mapUser = new Map<Id, User>(); 
        List<OpportunitySplit> listNewOpportunitySplit = (List<OpportunitySplit>)tp.newList;
        Set<Id> setOpportunitySplitIds = new Set<Id>();
        Map<String, Country__c> countryMap = UtilityClass.countryMap;
        
        if (tp.tEvent == TriggerParameters.TriggerEvent.beforeInsert) {
            
            for (OpportunitySplit newSplit : listNewOpportunitySplit) {
                setOpportunitySplitIds.add(newSplit.SplitOwnerId);
            }
            
            if (!setOpportunitySplitIds.isEmpty()) {
                for (User usr : [Select Id, Country from User where Id in: setOpportunitySplitIds]) {
                    mapUser.put(usr.Id, usr);
                }
            }
            
            for (OpportunitySplit newSplit : listNewOpportunitySplit) {
                User splitusr = mapUser.get(newSplit.SplitOwnerId); 
                if (splitusr != null && newSplit.TeamMemberCountry__c == null && countryMap.containsKey(splitusr.Country)) {
                    String country = UtilityClass.countryMap.get(splitusr.Country).id;
                    if (country != null) {
                        newSplit.TeamMemberCountry__c = Country;
                    }
                    
                }
            }
        }            
    }
}