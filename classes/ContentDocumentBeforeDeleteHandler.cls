//-----------------------------
// @author: Sharique Iqbal
// @date: 18 Aug 2021
// @param: TriggerParameters
// @description:  BeforeDelete dispatcher event handler class that calls the functions in ContentDocumentMethods.
// @return: NA

public class ContentDocumentBeforeDeleteHandler extends TriggerHandlerBase {
    
  public override void mainEntry(TriggerParameters tp) {
      ContentDocumentMethods.beforeDeleteOperations(tp);
  }
}