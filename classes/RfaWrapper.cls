/*  @author: Akash Punera
*   @date: 31 Oct 2022
*   @description: Wrapper class to parse response from webservice
*/
public class RfaWrapper {
      
    /*  @author: Akash Punera
    *   @date: 31 Oct 2022
    *   @description: Wrapper class to parse Request and Response fields
    */
    public class RecordData
    {
        public S1Responses s1Response;
        public string account;        
        public string accountCountry;        
        public string accountName;
        public string accountCapiqId;
        public string category;
        public string completedDate;
        public string createdById;
        public string description;
        public string division;
        public string divisionSentFrom;
        public string externalId;
        public string industry;
        public string opportunity;
        public string opportunityName;
        public string owner;
        public string ownerEmail;
        public string recordTypeId;
        public string requestedBy;
        public string requestorEmail;
        public string s1Request;
        public string status;
        public string type;
        public string id;
        
    }
    
    public class S1Responses
    {
        public List<RecordData> records;
    }

    /*  @author: Akash Punera
    *   @date: 31 Oct 2022
    *   @description: Wrapper to parse and generate response from API callout
    */
    public class RfaRestResponse
    {
        public Id recordId;
        public string status;
        public string message;
        public string type;

        public rfaRestResponse(Id recordID, String status, String message, String type) {
            this.recordId = recordID;
            this.status = status;
            this.message = message;
            this.type = type;
        }
    }
}