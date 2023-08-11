/**
 * @CreatedBy: Manish Kumar
 * @CreatedDate : 24th March 2022
 * @Description: SFDC-5500 Email Service handler class to process product selection exception approval inbound emails
 */
global class UpdateExceptionStatusFromEmail implements Messaging.InboundEmailHandler {
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        System.Debug('Email Service called successfully');
        String inputString= email.subject;
		String sub1 = inputString.substringAfter('Opportunity');
		String sub2 = sub1.substringBefore('has');
		String oppyId = sub2.trim();
        String sub3 = inputString.substringAfter('been');
        String decision = sub3.trim();
        Opportunity oppy = [Select ExceptionStatus__c from Opportunity where id = :oppyId limit 1];
        If(decision == 'Approved' && oppy.ExceptionStatus__c == 'Exception Requested') {
            oppy.ExceptionStatus__c = 'Exception Request Approved';
            update oppy;
            result.success = true;
        }
        else if(decision == 'Rejected' && oppy.ExceptionStatus__c == 'Exception Requested') {
            oppy.ExceptionStatus__c = 'Exception Request Denied';
            update oppy;
            result.success = true;
        }
        return result;
    }
}