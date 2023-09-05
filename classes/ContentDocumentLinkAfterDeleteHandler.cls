//-----------------------------
// @author: Sharique Iqbal
// @date: 18 Aug 2021
// @param: TriggerParameters
// @description:  AfterDelete dispatcher event handler class that calls the functions in ContentDocumentLinkMethods.
// @return: NA

public class ContentDocumentLinkAfterDeleteHandler extends TriggerHandlerBase {
    
  public override void mainEntry(TriggerParameters tp) {
      ContentDocumentLinkMethods.afterDeleteOperations(tp);
  }
}