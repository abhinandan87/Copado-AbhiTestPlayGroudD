//-------------------------------------
//@author: Digvijay Singh
//@date: 8 Nov  2021
//@description: SFDC-4820, This class has the logic for executing the condition's defined in Rule Entry Object . This Functionlaity
//              is built as part of SPGI Day 1 project , the code is generic and can be used for other business requirments as well. 
//@companyname: IHS Markit
//-------------------------------------
public with sharing class RuleEngineLogic {

     public static RuleDefinition__c parentruleobj;
     public static Boolean rulesatisfied=false;
     public static Map<String, RuleEntry__c> ruleIdtoRuleEntry;
     public static RuleEntry__c defaultrule;
     public static String key='Id';
     
     
    //-----------------------------
    // @author: Digvijay Singh
    // @date:   2 Feb 2022
    // @param: String,String,List,Map
    // @description: SFDC-4820,Primary Method to run rules , takes main object(on which rules need to run) data and related data as input
    // @return: List<Sobject> - List of Sobject after all rules have run.
    //------------------------------
     public static List<Sobject> runtheBusinessLogic(String sobjectAPI , String functionaity, List<Sobject> lstSobjects, Map<String,Map<Id,Sobject>> mapofrelatedRecords,String mapkey) {
          ruleIdtoRuleEntry =new Map<String, RuleEntry__c> ();
          key=mapkey;
         parentruleobj=[Select Id  , RuleObject__c   from RuleDefinition__c where BusinessFunctionality__c=:functionaity ];
         for(RuleEntry__c  obj : [Select RuleId__c  , DefaultRule__c,CriteriaCondition__c,OutputColumns__c  from RuleEntry__c where RuleDefinition__c =:parentruleobj.Id order by Order__c, RuleId__c  ASC]) {
             ruleIdtoRuleEntry.put(obj.RuleId__c, obj);
             if(obj.DefaultRule__c) {
                 defaultrule=obj;
             }
             
             
         }
         Integer icount=0;
         for(Sobject sobj:lstSobjects) {
             rulesatisfied=false;
             setOutputValues(sobj,defaultrule);
             for(RuleEntry__c obj : ruleIdtoRuleEntry.values()) {
             icount++;
                 rulesatisfied=executeRule(obj,sobj,mapofrelatedRecords);
                 if(rulesatisfied==true) {
                     setOutputValues(sobj,obj);
                     break;
                 }
             }
         }
         return lstSobjects;
     }
 
     //-----------------------------
    // @author: Digvijay Singh
    // @date:   2 Feb 2022
    // @param: Sobject,RuleEntry__c 
    // @description: SFDC-4820,Method to set output values  after a matching rule is found.
    // @return: Void  - List of Sobject after all rules have run.
    //------------------------------
     public static void setOutputValues(Sobject sobj, RuleEntry__c ruleobj) {
         List<String> lstoutputvalues=new List<String>();
         if(ruleobj!=null && !String.IsEmpty(ruleobj.OutputColumns__c)) {
             lstoutputvalues=ruleobj.OutputColumns__c.split('\\|');
         }
 
         for(String str: lstoutputvalues) {
             list<String> lstcriteriaparam=str.split('=');
             sobj.put(lstcriteriaparam[0].trim(),lstcriteriaparam[1].trim());
          }
 
     }
    
    //-----------------------------
    // @author: Digvijay Singh
    // @date:   2 Feb 2022
    // @param: RuleEntry__c ,Sobject,Map
    // @description: SFDC-4820,Method to execute Rules one by one
    // @return: Boolean  
    //------------------------------
     public static Boolean executeRule(RuleEntry__c ruleobj, Sobject sobj, Map<String,Map<Id,Sobject>> mapofrelatedRecords) {
         List<String> lstcritera=new List<String>();
         Boolean ruleoutCome=false;
          if(ruleobj!=null && !String.IsEmpty(ruleobj.CriteriaCondition__c)) {
             lstcritera=ruleobj.CriteriaCondition__c.split('\\|');
          }
          for(String str: lstcritera) {
             ruleoutCome=evaluateCriteria(str,sobj,mapofrelatedRecords);
             if(ruleoutCome==false) {
                 break;
             }
          }
         return ruleoutCome;
     }
 
    //-----------------------------
    // @author: Digvijay Singh
    // @date:   2 Feb 2022
    // @param: String,Sobject,Map
    // @description: SFDC-4820,Method to evaluate Rule  Condition 
    // @return: Boolean  
    //------------------------------
     public static Boolean evaluateCriteria(String strCriteria,Sobject sobj , Map<String,Map<Id,Sobject>> mapofrelatedRecords) {
         list<String> lstcriteriaparam;//=strCriteria.split('=');
         String stroperator;
         String fieldvalue;
         String sobjectfield;
         List<String> listfieldValues;
         if(strCriteria.Contains('=')) {
            lstcriteriaparam=strCriteria.split('=');
            stroperator='=';
            fieldvalue=lstcriteriaparam[1];
            sobjectfield=lstcriteriaparam[0];
         } else if(strCriteria.Contains('IN:')) {
            lstcriteriaparam=strCriteria.split('IN:');
            stroperator='IN';
            sobjectfield=lstcriteriaparam[0];
            if(lstcriteriaparam[1]!=null) {
                listfieldValues=new List<String>();
                for(String st: lstcriteriaparam[1].split(',') ) {
                    listfieldValues.add(st.trim());
                }
            }
         }else if(strCriteria.Contains('StartsWith')) {
            lstcriteriaparam=strCriteria.split('StartsWith');
            stroperator='StartsWith';
            fieldvalue=lstcriteriaparam[1];
            sobjectfield=lstcriteriaparam[0];
         }else if(strCriteria.Contains('!StartingWith')) {
            lstcriteriaparam=strCriteria.split('!StartingWith');
            stroperator='!StartingWith';
            fieldvalue=lstcriteriaparam[1];
            sobjectfield=lstcriteriaparam[0];
         }else if(strCriteria.Contains('Contains:')) {
            lstcriteriaparam=strCriteria.split('Contains:');
            stroperator='Contains:';
            fieldvalue=lstcriteriaparam[1];
            sobjectfield=lstcriteriaparam[0];
         }
          
         Map<Id,Sobject> mapofrelatedData=new Map<Id,Sobject>();
         if(sobjectfield.contains('.')) {
             String mapkey=sobjectfield.split('\\.')[0];
            // System.debug('mapkey..'+mapkey);
             mapofrelatedData=mapofrelatedRecords.get(mapkey.trim());
             Sobject sobjrelated=mapofrelatedData.get((Id)sobj.get(key));
             String fieldname=(sobjectfield.split('\\.')[1]).trim();
             if(sobjrelated!=null && sobjrelated.get(fieldname)!=null ) {
             // System.debug('here..6.2'+sobjrelated.get(sobjectfield.split('\\.')[1]));
                 String val=(String)sobjrelated.get(fieldname);
                 if(stroperator=='=' && (val.trim()==fieldvalue.trim() || (fieldvalue.trim().equalsIgnoreCase('n/a')|| fieldvalue.trim().equalsIgnoreCase('all')))) {
                     return true;
                 } else if(stroperator=='IN' && listfieldValues.contains(val.trim())) {
                     return true;
                 }else if(stroperator=='StartsWith' && val.trim().StartsWith(fieldvalue.trim())) {
                    return true;
                 }else if(stroperator=='!StartingWith' && !val.trim().StartsWith(fieldvalue.trim())) {
                    return true;
                 }else if(stroperator=='Contains:' && val.trim().containsIgnoreCase(fieldvalue.trim())) {
                    return true;
                 }
             }
 
         }else {
              if(sobj.get(sobjectfield)!=null && sobj.get(sobjectfield)==fieldvalue) {
                  return true;
              }
         }
          return false;
     }
     
     
 }