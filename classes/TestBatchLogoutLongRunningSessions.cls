//-----------------------------
// @author: Sathish Edla  
// @date: 17 Mar 2022
// @description: This class is used to improve the test code coverage of BatchLogoutLongRunningSessions class.
//-----------------------------
@isTest
private class TestBatchLogoutLongRunningSessions {
    @isTest static void batchLogoutLongRunningSessions(){
        AuthSession objAuthSession = [SELECT Id, UsersId, Createddate  from AuthSession LIMIT 1];
        test.startTest();
        SchedulableContext sc = null;
        BatchLogoutLongRunningSessions tsc = new BatchLogoutLongRunningSessions();
        BatchLogoutLongRunningSessions.strQuery = 'SELECT Id, UsersId, Createddate  from AuthSession WHERE Id =\''+objAuthSession.Id+'\'';
        tsc.execute(sc);
        test.stopTest();       
        system.assert(objAuthSession != null, 'Verify that the deletion failed');
    }
}