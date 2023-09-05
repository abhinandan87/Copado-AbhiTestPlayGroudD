//-----------------------------
// @author: Neelam Agrawal
// @date: 10 Feb 2022
// @description:  SFDC-5361  Scheduler class for BatchUpdateRollUpFieldOnParent batch class. 
//-----------------------------
public class BatchUpdateRollUpFieldOnOppyScheduler implements Schedulable {        
    public void execute(SchedulableContext ctx) {        
        BatchUpdateRollUpFieldOnParent obj= new BatchUpdateRollUpFieldOnParent(new batchParameter('Opportunity','OpportunityLineItem','OpportunityId',' Order by AccountId desc','AND Status__c!=\'Lost\''));
        Database.executeBatch(obj,200);
    }
}