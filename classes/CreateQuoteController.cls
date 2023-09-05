/*
* @author : Manish Kumar
* @date : 23 Nov 2021
* @description : SFDC-4969 Method to get the Opportunity details and Session Id
* @param : String
* @return : Wrapper Class
* @companyname : IHS Markit
*/
public class CreateQuoteController {
    @auraEnabled
    public static wrapperClass getOptyAndSessionId (string oppyId) {
        wrapperClass wrpCon = new wrapperClass();
        Opportunity oppy = [Select legalEntity__c, ExceptionStatus__c, AccountId from Opportunity where id = :oppyId];
        wrpCon.oppy=oppy;
        wrpCon.sessionid=System.UserInfo.getSessionId();
        return wrpCon; 
    }
    
    public class wrapperClass{
    	 @AuraEnabled public Opportunity oppy{ get; set;}
         @AuraEnabled public String sessionid{ get; set;}
    }
}