/**
*@author: Digvijay Singh
*@date: 11-Aug-2021
*@description: one of the Core class for Apex logging framework, contains  fields for additional information to be logged  and their get methods .
*@companyname : IHS Markit 
**/
public  class LogMessage {
    //Class Name to be logged for Exception
    private String className;
    //Method Name to be logged for Exception
    private String methodName;
    //Exception Object
    private Exception apexException;
    //Custom Error Message ,In case standarad Error Message need to be Overided 
    private String message;
    //Sobject Record(Stored as Json) , this will also be used for adding error to trigger Sobject records using addError Method. 
    private Sobject record;
    //In case multiple SObject records need to be Logged for Exception (Stored as Json)
    private List<SObject> records;


    public LogMessage(string className,string methodName,Exception apexException) {
        this.className=className;
        this.methodName=methodName;
        this.apexException=apexException;
    }

    public LogMessage(string className,string methodName,Exception apexException ,Sobject record,string message) {
        this.className=className;
        this.methodName=methodName;
        this.apexException=apexException;
        this.message=message;
        this.record=record;
    }
    /**
     * @description setter method  for  records class Variable
     * @return String
     */
    public void setSobjectList(List<SObject> records) {
        this.records=records;
    }
    
    /**
     * @description getter for  message class Variable
     * @return String
     */
    public String getmessage() {
        return this.message;
    }
    
    /**
     * @description getter for  apexException class Variable
     * @return String
     */
    public Exception getException() {
        return this.apexException;
    }
    
    /**
     * @description getter for  apexException class Variable
     * @return String
     */
    public String getclassName() {
        return this.className;
    }
    
    /**
     * @description getter for  methodName class Variable
     * @return String
     */
    public String getmethodName() {
        return this.methodName;
    }
    /**
     * @description getter for  record class Variable
     * @return String
     */
    public Sobject getrecord() {
        return this.record;
    }
    
    /**
     * @description getter for  records class Variable
     * @return String
     */
    public List<Sobject> getrecords() {
        return this.records;
    }
}