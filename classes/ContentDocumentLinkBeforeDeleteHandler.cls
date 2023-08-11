//-----------------------------
// @author: Sharique Iqbal
// @date: 18 Aug 2021
// @param: TriggerParameters
// @description:  BeforeDelete dispatcher event handler class that calls the functions in ContentDocumentLinkMethods.
// @return: NA

public class ContentDocumentLinkBeforeDeleteHandler extends TriggerHandlerBase {
    
  public override void mainEntry(TriggerParameters tp) {
      ContentDocumentLinkMethods.beforeDeleteOperations(tp);
  }
}