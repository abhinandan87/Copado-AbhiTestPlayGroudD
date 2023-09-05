//@author: Kanika Miglani
// @date: 25th April 2023
// @description: Batch apex to update the Prior Year Oppy Link on opportunity reporting since FY 2021.
//---------------------------------------------------------------------------------------------------------------------------
global class BatchUpdatePriorYearOppyLink implements Database.Batchable<sobject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc) {   
        DateTime testingStartDate = DateTime.ValueofGmt('2022-09-01 00:02:00'); 
        DateTime testingEndDate = DateTime.ValueofGmt('2022-09-02 00:00:00'); 
        //String query = 'SELECT Id, BusinessLine__c, AverageDiscountPercentage__c,AccountId,CreatedDate,CloseDate,ContractStartDate__c,ContractBeingRenewed__c,PreviousFiscalYearOpportunityLink__c,FirstYearValue__c, DiscountOverThreshold__c, MultiYear__c,ContractBeingRenewed__r.Opportunity__c,Account.DataGovernanceStatus__c FROM Opportunity where PreviousFiscalYearOpportunityLink__c = null AND ( RecordType.name = \'Renewal\' OR RecordType.name = \'Inner Year\') AND createdDate = LAST_N_MONTHS:12';
        String query = 'SELECT Id, BusinessLine__c,AccountId,CreatedDate,CloseDate,ContractStartDate__c,ContractBeingRenewed__c,PreviousFiscalYearOpportunityLink__c,FirstYearValue__c FROM Opportunity where ( RecordType.name = \'Renewal\' OR RecordType.name = \'Inner Year\') AND ContractStartDate__c >= LAST_N_YEARS:2 AND PreviousFiscalYearOpportunityLink__c=null AND ContractBeingRenewed__c!=null';
        return Database.getQueryLocator(query);  
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> scope)  {  
        try{
            Map<Id,Map<Date,Opportunity>> contractOpportunityMap = new Map<Id,Map<Date,Opportunity>>();
            Map<id,contract> oppyInContract=new Map<id,contract>();
            list<Opportunity> listOpportunityToUpdate = new List<Opportunity>();
            set<Id> setOfOriginatingContract = new set<Id>();
             List<Contract> contractWithOpportunities = new List<Contract>();
            system.debug('scope->'+scope); 
            
            for(Opportunity opp : scope) {
                //Process only Automotive Insights Oppies
                if(opp.BusinessLine__c!=null){
                if(opp.BusinessLine__c.contains('Automotive Insights')) {
                	setOfOriginatingContract.add(opp.ContractBeingRenewed__c);
                }
                }
            }
      //      system.debug('setOfOriginatingContract---'+setOfOriginatingContract);
            if(setOfOriginatingContract!=null){    
            for(Contract lstCon : [Select Id,StartDate,ContractStatus__c,Opportunity__c,Opportunity__r.ContractStartDate__c,
                                                          (Select id,BusinessLine__c,ContractBeingRenewed__r.Opportunity__c,AverageDiscountPercentage__c,AccountId,CloseDate,ContractStartDate__c,ContractBeingRenewed__c,PreviousFiscalYearOpportunityLink__c from Opportunities2__r order by ContractStartDate__c)
                                                          from contract where ID IN:setOfOriginatingContract])
            {
            //   Contract con = new Contract(lstCon);
                 contractWithOpportunities.add(lstCon);                
                
            }
           //     system.debug('inside-->contractWithOpportunities'+contractWithOpportunities);
                if(contractWithOpportunities!=null && !contractWithOpportunities.isEmpty()){
                    for(Contract con : contractWithOpportunities){
                        if(!contractOpportunityMap.containsKey(con.Id)){
                            Map<Date,Opportunity> opportunityStartDateMap= new Map<Date,Opportunity>();
                            if(!oppyInContract.containsKey(con.Id)){
                            	oppyInContract.put(con.id,con);
                                system.debug('oppyInContract'+oppyInContract);
                            }
                            if(con.Opportunities2__r != null) {
                                system.debug('con.Opportunities2__r'+con.Opportunities2__r);
                                for(Opportunity renewalOppy : con.Opportunities2__r){
                                    if(renewalOppy.ContractStartDate__c!=null){
                                        opportunityStartDateMap.put(renewalOppy.ContractStartDate__c,renewalOppy);
                                        system.debug('opportunityStartDateMap'+opportunityStartDateMap);
                                        system.debug('renewalOppy.ContractStartDate__c'+renewalOppy.ContractStartDate__c);
                                        system.debug('renewalOppy'+renewalOppy);
                                    } 
                                }
                                if(opportunityStartDateMap!=null){
                                    contractOpportunityMap.put(con.Id,opportunityStartDateMap);
                                    system.debug('contractOpportunityMap'+contractOpportunityMap);
                                }
                            }
                        }
                        
                    }
                    
                    if(contractOpportunityMap!=null){
                      //  System.debug('inside-->contractOpportunityMap'+contractOpportunityMap);
                        for(Opportunity oppy: scope) {
                            if(oppy.BusinessLine__c!=null){
                            if(oppy.BusinessLine__c.contains('Automotive Insights')) {
                                if(oppy.PreviousFiscalYearOpportunityLink__c==null) {
                             //       system.debug('contractOpportunityMap.containsKey(oppy.ContractBeingRenewed__c)'+contractOpportunityMap.containsKey(oppy.ContractBeingRenewed__c));
                             //       system.debug('oppy.ContractBeingRenewed__c'+oppy.ContractBeingRenewed__c);
                                    if(contractOpportunityMap.containsKey(oppy.ContractBeingRenewed__c))
                                    {
                                        system.debug('inside-->contractBeingRenewed__c');
                                        Map<Date,Opportunity> opportunityContractStartDateMap= new Map<Date,Opportunity>();
                                        
                                        //wrapper list
                                         List<OppyDetailsWrapper> lstOppyDetailWrap=new List<OppyDetailsWrapper>();
                                        
                                        opportunityContractStartDateMap=contractOpportunityMap.get(oppy.ContractBeingRenewed__c);
                                        if(opportunityContractStartDateMap!=null){
                                         //   system.debug('inside-->opportunityContractStartDateMap');
                                         //   Date minDate=oppy.ContractStartDate__c;
                                          //  String OppyIdInContract='';
                                            for(Date oppyContractStartDate: opportunityContractStartDateMap.keySet()){
                                                OppyDetailsWrapper objOppyDetailWrap = new OppyDetailsWrapper(opportunityContractStartDateMap.get(oppyContractStartDate).Id,oppyContractStartDate);                               
                                                    lstOppyDetailWrap.add(objOppyDetailWrap);
         
                                            }
                                            if(oppyInContract.containsKey(oppy.ContractBeingRenewed__c) && (oppy.Id!=oppyInContract.get(oppy.ContractBeingRenewed__c).id))
                                            {
                                                OppyDetailsWrapper objOppyDetailWrap1 = new OppyDetailsWrapper(oppyInContract.get(oppy.ContractBeingRenewed__c).Opportunity__c,oppyInContract.get(oppy.ContractBeingRenewed__c).Opportunity__r.ContractStartDate__c);                               
                                                lstOppyDetailWrap.add(objOppyDetailWrap1); 
                                            }
                                            
                                              //Sorting and updating previous fiscal year oppy link
                                            
                                            if(lstOppyDetailWrap != null && !lstOppyDetailWrap.isEmpty()){
                                                lstOppyDetailWrap.sort();
                                                System.debug('wrapper-->'+lstOppyDetailWrap);
                                                integer i=0;
                                                ID previousOppyLink=null;
                                                for(OppyDetailsWrapper wrapper : lstOppyDetailWrap)
                                                {
                                                    if(i==0)
                                                    {
                                                        previousOppyLink=wrapper.oppyId;
                                                        i++;
                                                    }
                                                    else{
                                                        if(wrapper.oppyId==oppy.Id)
                                                        {
                                                            oppy.PreviousFiscalYearOpportunityLink__c=previousOppyLink;
                                                            break;
                                                        }
                                                        previousOppyLink=wrapper.oppyId;
                                                    }       
                                                }
                                            }
                                        }
                                    }
                                }
                                if(oppy.PreviousFiscalYearOpportunityLink__c!=null){
                                    listOpportunityToUpdate.add(oppy);  
                                }
                            }
                            }
                        }
                    }
                }
        }
             if(listOpportunityToUpdate!=null && !listOpportunityToUpdate.isEmpty()) {
                    Database.update(listOpportunityToUpdate,false);
                }
            }
        catch(Exception ex) {
            System.debug('Exception caught in batch' + ex.getMessage());
            UtilityClass.createApexLogRecord(ex, 'BatchUpdatePriorYearOppyLink', 'Execute');       
        }

    }
    
    global void finish(Database.BatchableContext bc) {
        System.debug(LoggingLevel.INFO, 'BatchUpdatePriorYearOppyLink batch completed');
     }
  }