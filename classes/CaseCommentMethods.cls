//-------------------------------------
//@author: Digvijay Singh
//@date: 23 March 2021
//@description: SFDC-3511, When Case Comment is Inserted update "Last Modified Date for Comments and Email" on Case. 
//-------------------------------------

public class CaseCommentMethods {
//-------------------------------------
// @author: Digvijay Singh
// @date: 23 March 2021
// @param: Trigger parameters
// @description: SFDC-3511: update Field on Case.
//-------------------------------------------

   public static void updateFieldOnCaseOnNewComment(TriggerParameters tp) {
        //get the List of New records
      /*  List<CaseComment> listNewCaseComment = (List<CaseComment>) tp.newList;
        Map<Id,Case> mapCasetoUpdate = new Map<Id,Case>();
        Map<Id,CaseComment> mapOldCaseComment;
        
        try{
            //populate old records Map in case of Update event
            if(tp.tEvent == TriggerParameters.TriggerEvent.afterUpdate) {
                mapOldCaseComment = (Map<Id,CaseComment>) tp.oldMap;
            }

            for(CaseComment objCaseComment : listNewCaseComment) {
                //for Insert Event
                if(tp.tEvent == TriggerParameters.TriggerEvent.afterInsert) {
                          Case objCase = new Case(Id = objCaseComment.ParentId, LastModifiedDateForRelatedData__c = System.Now());
                          mapCasetoUpdate.put(objCase.Id, objCase);
                }
                else {
                    //for Update Event check for Comment Content update
                    if(mapOldCaseComment != null && mapOldCaseComment.containskey(objCaseComment.Id)) {
                        CaseComment oldcasecomment = mapOldCaseComment.get(objCaseComment.Id);
                        if(oldcasecomment != null && objCaseComment.CommentBody != oldcasecomment.CommentBody) {
                            Case objCase = new Case(Id = objCaseComment.ParentId, LastModifiedDateForRelatedData__c = System.Now());
                            mapCasetoUpdate.put(objCase.Id, objCase);
                        }
                    }   
                }
            }

            //Updating cases
            if(!mapCasetoUpdate.isEmpty()) {
                update mapCasetoUpdate.values();
            }
        
        }
        catch (Exception e) {
            throw new TriggerException(e.getMessage());
            //UtilityClass.createApexLogRecord(e,'CaseCommentMethods','updateFieldOnCaseOnNewComment');
        }
    */
    }
}