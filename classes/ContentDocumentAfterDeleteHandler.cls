//-----------------------------
// @author: Sharique Iqbal
// @date: 18 Aug 2021
// @param: TriggerParameters
// @description:  AfterDelete dispatcher event handler class that calls the functions in ContentDocumentMethods.
// @return: NA
//-----------------------------
public class ContentDocumentAfterDeleteHandler extends TriggerHandlerBase {
    
  public override void mainEntry(TriggerParameters tp) {
      //ContractAttachmentMethods.updateFieldOnContract(tp);
      System.debug('@@@afterDeleteOperations');
      ContentDocumentMethods.afterDeleteOperations(tp);
     ContentDocumentMethods.afterVOCattachementDeleteOperations(tp);
  }
}