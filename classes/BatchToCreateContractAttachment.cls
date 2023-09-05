//-----------------------------
// @author: Sharique Iqbal
// @date: 18 May 2021
// @description: SFDC-2530 This batch class is to use to create Contract Attachment record year on year
//------------------------------

global class BatchToCreateContractAttachment implements Database.Batchable<sObject>,schedulable {

    public String query;
    List<ContractAttachment__c> upsertContractAtt = new List<ContractAttachment__c>();
    List<Contract> contractsToBeUpdated = new List<Contract>();

    global Database.QueryLocator start(Database.BatchableContext BC) {
        if (String.isBlank(query)) {
            query = 'Select Id From Contract ' 
                    +'Where Active__c = True AND PORequired__c = true AND '
                    +'Recordtype.Name IN (\'Order Form\',\'Consulting\') AND ' 
                    +'Renewaldate__c > today';
        }  
        system.debug('@@query--'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contract> scope) {
        try {
            for (Contract ctrt: [Select Id, ContractNumber, StartDate, EndDate, Renewaldate__c, CACreationDate__c, POAttached__c, Active__c,Account.Name,(Select Id from ContractAttachments__r Where AttachmentType__c = 'Purchase Order') 
                                 From Contract Where Id IN :scope]) {
               
               //Scenario 1- If Contract Start date is in next 30days 
               if (ctrt.StartDate.addMonths(-1) == System.today() && ctrt.CACreationDate__c == null) {
                    
                    // If contract duration is more than 1 yr, then batch will run again as per CACreationDate__c
                    if (System.today().addMonths(13) < ctrt.Renewaldate__c) {
                        ctrt.CACreationDate__c = System.today().addYears(1);
                        contractsToBeUpdated.add(ctrt);
                    }
                    /*1st time no need to create Contract Attachment record since they will 
                      be created along with Contract creation*/
                    //createContractAttachment (ctrt);
               }    
                                     
               //Scenario 2- If CSD is in past, CED is today/future 
               else if (ctrt.StartDate < System.today() && ctrt.EndDate > System.today() && ctrt.CACreationDate__c == null) {
                    Date thisYearstartdate = date.newInstance(System.today().year(), ctrt.StartDate.Month(), ctrt.StartDate.day());
                    Date thisYearEnddate = date.newInstance(System.today().year(), ctrt.EndDate.Month(), ctrt.Enddate.day());

                    if (thisYearstartdate.addMonths(-1) == System.today() && ctrt.RenewalDate__c >= System.today().addMonths(2)) {
                        if (System.today().addMonths(13) < ctrt.RenewalDate__c) {
                            ctrt.CACreationDate__c = System.today().addYears(1); 
                        }
                        createContractAttachment (ctrt);   
                    }  
                }
                
                // Scenario-3: If CSD & CED both are at past.
                else if (ctrt.StartDate < System.today() && ctrt.EndDate < System.today() && ctrt.CACreationDate__c == null) {
                       Date thisYearEnddate = date.newInstance(System.today().year(), ctrt.EndDate.Month(), ctrt.Enddate.day());
                       if (thisYearEnddate.addMonths(-1) == System.today() && ctrt.RenewalDate__c >= System.today().addMonths(2) ) {
                           // if Enddate is less then 1 yr from today's date
                           if (System.today().addMonths(13) < ctrt.RenewalDate__c) {
                              ctrt.CACreationDate__c = System.today().addYears(1); 
                           }
                           createContractAttachment (ctrt);   
                       }  
                }
                
                //Scenario 4- If Contract Creation Date is today
                else if (ctrt.CACreationDate__c != null && ctrt.CACreationDate__c == System.today()) {
                         if (ctrt.CACreationDate__c < ctrt.EndDate && System.today().addYears(1) > ctrt.EndDate) {
                              ctrt.CACreationDate__c = ctrt.EndDate.addMonths(-1);
                         } else if (System.today().addMonths(13) < ctrt.Renewaldate__c) {
                              ctrt.CACreationDate__c = System.today().addYears(1);
                         }
                    createContractAttachment (ctrt);   
                }                  
            }
            
            for (Contract cont : contractsToBeUpdated) {
                for (ContractAttachment__c conAtt : cont.ContractAttachments__r) {
                    conAtt.CurrentPO__c = 'No';
                    upsertContractAtt.add(conAtt);
                }
            }
            
            if (upsertContractAtt.size() > 0) {
                database.upsert(upsertContractAtt);
            }
            
            if (contractsToBeUpdated.size() > 0) {
                database.update(contractsToBeUpdated);
            } 
            
        } catch(Exception ex) {
            System.debug('Exception when executing BatchToCreatePOContractAttachment: ' + ex.getMessage());
            UtilityClass.createApexLogRecord(ex, 'BatchToCreatePOContractAttachment', 'execute'); 
        }
    }
    
    public void createContractAttachment (Contract ctrt) { 
        ContractAttachment__c ctrtAtt = new ContractAttachment__c();
        ctrtAtt.Name = 'PO -'+ctrt.Account.Name+' '+System.today().format();
        ctrtAtt.Contract__c = ctrt.Id;
        ctrtAtt.AttachmentType__c = 'Purchase Order';
        ctrtAtt.CurrentPO__c = 'Yes';
        ctrtAtt.POAttached__c = 'No';
        ctrt.POAttached__c = 'No'; // Marking PO Attached as 'No' on Contract.
        upsertContractAtt.add(ctrtAtt);
        contractsToBeUpdated.add(ctrt);
                
    }    
    
    global void finish(Database.BatchableContext BC) {
      // Workflow is fired to send an Email Notifications to Contract, Opportunity, Renewal Owner for recently created Contract Attachment Records.
    }
    
    global void execute(SchedulableContext SC) {
 	  database.executebatch(new BatchToCreateContractAttachment());
    }
    
}