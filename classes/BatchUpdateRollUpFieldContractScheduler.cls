//-----------------------------
// @author: Neelam Agrawal
// @date: 10 Feb 2022
// @description:  SFDC-5361  Scheduler class for BatchUpdateRollUpFieldOnParent batch class for Contract Object. 
//-----------------------------
public class BatchUpdateRollUpFieldContractScheduler implements Schedulable {        
    public void execute(SchedulableContext ctx) {        
        BatchUpdateRollUpFieldOnParent obj= new BatchUpdateRollUpFieldOnParent(new batchParameter('Contract','ContractLineItem__c','Contract__c',' Order by AccountId','AND Status__c!=\'Lost\''));
        Database.executeBatch(obj,200);
    }
}