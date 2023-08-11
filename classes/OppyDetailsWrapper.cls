//Wrapper Class for Oppy Details Sorting
global class OppyDetailsWrapper implements Comparable {

    public String oppyId ;
    public Date oppyContractStartDate;

    public enum SORT_BY {
        ByOppyId,
		ByOppyContractStartDate
        }
 
    //Variable to decide the member on which sorting should be performed
    public static SORT_BY sortBy = SORT_BY.ByOppyContractStartDate;
 
    public OppyDetailsWrapper(Id opId, Date csDate)
    {
        oppyId = opId;
        oppyContractStartDate = csDate;
    }

    global Integer compareTo(Object objToCompare) {
        //Sort by Contract Start Date
        if(sortBy == SORT_BY.ByOppyContractStartDate)
        {
            if(oppyContractStartDate > ((OppyDetailsWrapper)objToCompare).oppyContractStartDate) {
                return 1;
            } else if(oppyContractStartDate < ((OppyDetailsWrapper)objToCompare).oppyContractStartDate) {
                return -1;
            } else {
                return 0;
            }
        }
        else //Sort by Oppy Id
        {
            return oppyId.compareTo(((OppyDetailsWrapper)objToCompare).oppyId);
        }
    }
}