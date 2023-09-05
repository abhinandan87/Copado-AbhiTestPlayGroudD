/**
 * @Author:  Paras Dhingra
 * @Date:    08th April 2020
 * @description: SFDC-2734 wrapper class for Meeting Notes
**/
public with sharing class MeetingNotesWrapper {
    @AuraEnabled
    public String name {get;set;}

    @AuraEnabled
    public String email {get;set;}

    @AuraEnabled
    public string cellCSS {get;set;}

    public MeetingNotesWrapper(String name, String email, Boolean isBlocked) {
        this.name = name;
        this.email = email;
        this.cellCSS = '';
        if(isBlocked) {
            this.cellCSS = 'slds-theme_warning';
        }
        System.debug('--Name--'+name);
        System.debug('--Isblocked--'+isBlocked);
    }
}