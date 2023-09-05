/*  @author: Neha Gupta
*   @date: 20 Jan 2021
*   @description: SFDC-3096 Class to get the contract detail associated to a contract
*/
public class ContractGenerateDocumentClass {
    @AuraEnabled
    public static wrapperClass getContractInfo(String conId){
        wrapperClass wrpCon = new wrapperClass();
        //SFDC-4575 - Added IHS Markit Legal Entity Name in SOQL
        Contract con=[select id,AccountId,Opportunity__c,RecordTypeName__c,BillingFrequency__c,
                      GeneralAgreementType__c,Fastrack__c, IHSMarkitLegalEntity__r.Name 
                      from Contract where id=:conId limit 1];
        //return con;
        wrpCon.con=con;
        wrpCon.sessionid=System.UserInfo.getSessionId();
        return wrpCon;
    }
	
    public class wrapperClass{
    	 @AuraEnabled public Contract con{ get; set;}
         @AuraEnabled public String sessionid{ get; set;}
    }
}