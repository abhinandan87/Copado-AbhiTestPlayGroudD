//-----------------------------
// @author: Neelam Agrawal
// @date: 10 Feb 2022
// @description:  SFDC-5361 Parameter class for BatchUpdateRollUpFieldOnParent, contains field which will be passed to batch 
// 
public class BatchParameter {
    //Parent object name
	private String parentObject;
    //Child object name
    private String childObject;
    //Relationship field that bind child object to parent
    private String relationshipField;
    //Parent Object conditons
    private String parentWhereClause;
    //Child object conditions
    private String childWhereClause;
    
    public BatchParameter(String parentObject,String childObject,String relationshipField,String parentWhereClause,String childWhereClause){
        this.parentObject=parentObject;
        this.childObject=childObject;
        this.relationshipField=relationshipField;
        this.parentWhereClause=parentWhereClause;
        this.childWhereClause=childWhereClause;      
    }
    public BatchParameter(String parentObject,String childObject,String relationshipField){
        this.parentObject=parentObject;
        this.childObject=childObject;
        this.relationshipField=relationshipField;      
    } 
    
    
    // @description getter for  parentObject class Variable
    // @return String
    
    public String getParentObjectName(){
        return this.parentObject;
    }   
    
    // @description getter for  childObject class Variable
    // @return String
    public String getchildObject(){
        return this.childObject;
    }
    
    // @description getter for  relationshipField class Variable
    // @return String
    public String getrelationshipField(){
        return this.relationshipField;
    }
    // @description getter for  parentWhereClause class Variable
    // @return String
    public String getparentWhereClause(){
        return this.parentWhereClause;
    }
    
    // @description getter for childWhereClause class Variable
    // @return String
     public String getchildWhereClause(){
        return this.childWhereClause;
    }
}