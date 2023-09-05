import { LightningElement, api } from 'lwc';
export default class SummaryMainField extends LightningElement {

    @api recordMap = {};
    @api fieldName;
    @api styleField;
    @api isParent;
    @api isEmail = false;
    @api isPhone = false;
    @api isName = false;
    @api parentName;
    @api phoneField;
    fieldValue;
    styleValue;
    emailBody;
    phoneNumber;
    displayEmail = false;
    displayPhone = false;
    displayName = false;
    teamsBody;


    connectedCallback() {

        if (this.isParent) {

            let parentName = this.parentName;

            if (parentName != null && parentName.includes('__c')){
                parentName = parentName.replace('__c', '__r');
            }

            this.fieldName = parentName + '_' + this.fieldName;
        }

        if (this.fieldName && this.recordMap[this.fieldName]){
            this.fieldValue = this.recordMap[this.fieldName];
        }

        if (this.styleField){
            this.styleValue = "color: " + this.recordMap[this.styleField];
        }

        if (this.isEmail && this.fieldValue) {
            this.displayEmail = true;
            this.emailBody = 'mailto:' + this.fieldValue + '?subject=RE: ' + this.recordMap['Name'];
            this.teamsBody = 'https://teams.microsoft.com/l/chat/0/0?users=' + this.fieldValue + '&topicName=<>&message=RE: ' + this.recordMap['Name'];
        }
        
        if(this.isPhone && this.fieldValue){
            this.fieldValue = this.formatPhoneNumber(this.fieldValue);
            this.displayPhone = true;
        }

        if(this.isName && this.fieldValue){
            this.displayName = true;
        }

    }
    get nameFontSize(){
        if(!this.displayName){
            return;
        }
        const length = this.fieldValue.length;
        if(length > 14){
            return 'long-name_font';
        }

        return 'slds-text-body_small';
    }

    formatPhoneNumber(phone){
        if(phone.charAt(0) == '+'){
            return phone;
        }
        //normalize string and remove all unnecessary characters
        phone = phone.replace(/[^\d]/g, "");

        //check if number length equals to 10
        if (phone.length == 10) {
            //reformat and return phone number
            return phone.replace(/(\d{3})(\d{3})(\d{4})/, "($1) $2-$3");
        }

        if(phone.length > 10 && phone.length <= 12){
            return phone.replace(/(\d{1}|\d{2})(\d{3})(\d{3})(\d{4})/, "+$1 ($2) $3-$4");
        }

        return phone;
    }
}