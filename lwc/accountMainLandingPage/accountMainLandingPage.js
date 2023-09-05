import {LightningElement, api} from 'lwc';
import {loadStyle} from 'lightning/platformResourceLoader';
import localAccount from '@salesforce/apex/AccountLandingPageController.getLocalAccount';
import divisions from '@salesforce/apex/AccountLandingPageController.getDivisions';
import getAccount from '@salesforce/apex/AccountLandingPageController.getAccount';
import getDataSyncSummaryDate from '@salesforce/apex/AccountLandingPageController.getDataSyncSummaryDate';
import headerLogo from '@salesforce/resourceUrl/SPGlobal_Logo';
import accountStyles from '@salesforce/resourceUrl/accountStyles';
import FOOTNOTE_MESSAGE from '@salesforce/label/c.Divisional_View_Summary_Tab_Footnote';
import sendErrorEmail from '@salesforce/apex/AccountLandingPageController.sendErrorEmail';

export default class AccountMainLandingPage extends LightningElement {
    currentUrl = '';
    @api recordId;
    divisionRecords = [];
    headerLogo;
    isLoaded = false;
    accountMap = {};
    connectionSuccess = false;
    connectionError = false;
    isPageLoading = true;
    footnoteMessage = FOOTNOTE_MESSAGE;
    @api lastSyncedDate;
    lastSyncedDateExists = false;
    label = {
        footnoteMessage: FOOTNOTE_MESSAGE
    };

    get hasFootnote() {
        if (this.label.footnoteMessage == 'N/A') {
            return false;
        }
        return true;
    }

    connectedCallback() {
        this.currentUrl = window.location.href;
        loadStyle(this, accountStyles);
        this.headerLogo = headerLogo;
        this.isPageLoading = true;

        console.log(this.currentUrl);
        localAccount({accountId: this.recordId})
            .then(data => {
                if (data) {
                    // Get the divisions
                    this.divisions();

                    // Get the account from target org using SP_CIQ_Company_ID__c
                    this.getAccount(data);
                } else {
                    this.isPageLoading = false;
                }
            })
            .catch(error => {
                console.log('Getting local Account', error.message);
            })
            .finally(() => {
            });

        getDataSyncSummaryDate({windowUrl: this.currentUrl})
            .then((data) => {
                this.lastSyncedDate = data;
                if (this.lastSyncedDate && this.lastSyncedDate.length > 0) {
                    this.lastSyncedDateExists = true;
                } else {
                    this.lastSyncedDateExists = false;
                }
            })
            .catch(error => {
                this.lastSyncedDateExists = false;
                console.log(error);
            });
    }

    // Get the dvisions from the custom metadatatype
    divisions() {
        divisions()
            .then(data => {
                if (data) {
                    this.divisionRecords = data;
                }
            })
            .catch(error => {
                console.log('Get divisions error', error);
                this.connectionError = true;
                let errorMap = this.generateErrorMap(error);
                sendErrorEmail({errorObject: errorMap});
            })
    }

    // To get the account from target org based on SP_CIQ_Company_ID__c
    getAccount(SPCIQCompanyId) {
        getAccount({SPCIQCompanyId: SPCIQCompanyId, windowUrl: this.currentUrl})
            .then(data => {
                if (data) {
                    this.accountMap = JSON.parse(JSON.stringify(data));
                    this.isLoaded = true;
                    if (this.accountMap['Name']) {
                        this.connectionSuccess = true;
                        this.connectionError = false;
                    } else if(this.accountMap['Error']){
                        this.connectionError = true;
                        sendErrorEmail({errorObject: this.accountMap});
                    }
                };
            })
            .catch(error => {
                console.log('Get account from target system error', error);
                this.connectionError = true;
                let errorMap = this.generateErrorMap(error);
                sendErrorEmail({errorObject: errorMap});
            })
            .finally(() => {
                this.isPageLoading = false;
            });
    }

    generateErrorMap(error){
        let errorMap = {
            'Url': this.currentUrl,
            'Error': error.body.message,
            'StatusCode': 'Callout not made.'
        }

        return errorMap;
    }
}