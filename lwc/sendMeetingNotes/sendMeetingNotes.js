import { LightningElement,api,wire,track } from 'lwc';
import fetchMeetingNotesRecepients from '@salesforce/apex/SendMeetingNotesController.fetchMeetingNotesRecepients';
import searchContacts from '@salesforce/apex/SendMeetingNotesController.searchContacts';
import sendEmail from '@salesforce/apex/SendMeetingNotesController.sendEmail';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 /* eslint-disable no-console */
 /* eslint-disable no-alert */
 /*const actions = [
    { label: 'Delete', name: 'delete' }
];*/
const meetingColumns = [
    { label: "Name", fieldName: "name", type: "text",  cellAttributes:{
        class:{fieldName : 'cellCSS'}
    }},
    { label: "Email", fieldName:"email", type:"email",cellAttributes:{
        class:{fieldName : 'cellCSS'}
    } },
    
    { type: "button-icon",fixedWidth: 150,typeAttributes: {
        iconName:'utility:delete',
        label:'Delete',
        title:'Delete',
        name:'delete',
        variant:'base',
        disabled: false,
        },
        cellAttributes:{
            class:{fieldName : 'cellCSS'}
        }
    },
    
];
export default class SendMeetingNotes extends NavigationMixin(LightningElement) {
    @track meetingColumns = meetingColumns;
    @track lstSendEmailToMembers = [];
    @api recordId;
    //lookup utility attributes start
    isMultiEntry = false;
    initialSelection = [];
    errors = [];
    fetchErrors = [];
    showSpinner = true;
    handleSearch(event) {
        let lstEmailSelected = [];
        this.lstSendEmailToMembers.forEach(member => {
            lstEmailSelected.push(member.email);
        });
        searchContacts({searchTerm: event.detail.searchTerm, emailsAlreadySelected: lstEmailSelected})
            .then((results) => {
                console.log('--search results--'+JSON.stringify(results));
                this.template.querySelector('c-lwc-lookup-utility').setSearchResults(results);
            })
            .catch((error) => {
                this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }
    handleSelectionChange() {
        let currentItem = this.template.querySelector('c-lwc-lookup-utility').selection;
        console.log('--currentItem--'+JSON.stringify(currentItem));
        this.errors = [];
        //add to list
        console.log('--listSendEmailToMembers--'+JSON.stringify(this.lstSendEmailToMembers));
        let arrayToPush = this.lstSendEmailToMembers;
        this.lstSendEmailToMembers = [];
        arrayToPush.push({cellCSS:currentItem[0].sObjectType,
            email:currentItem[0].subtitle,
            name:currentItem[0].title,         
        });
        this.lstSendEmailToMembers=[...arrayToPush];
        this.initialSelection = [];
    }
    notifyUser(title, message, variant) {
        const toastEvent = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(toastEvent);
    }
    //lookup utility attributes stop
    @wire(fetchMeetingNotesRecepients,{eventId : '$recordId'})
    wiredMeetingNotes({ error, data }) {        
            if (data) {
                this.lstSendEmailToMembers = JSON.parse(JSON.stringify(data));;
                this.fetchErrors = undefined;
            } else if (error) {
                this.fetchErrors = error;
                this.lstSendEmailToMembers = undefined;
            }
            this.showSpinner = false;
    }
    
    get hasData() {
        if(this.lstSendEmailToMembers!==null && this.lstSendEmailToMembers!==undefined && this.lstSendEmailToMembers.length>0) {
            return true;
        }
        return false;
    }
    get doesNotHaveDate() {
        return !this.hasData;
    }
    sendNotes() {
        this.showSpinner = true;
        console.log('Send meeting Notes==> '+ JSON.stringify(this.lstSendEmailToMembers));
        let jsonStringToSend = JSON.stringify(this.lstSendEmailToMembers);
        sendEmail({eventId:this.recordId,jsonLstRecipients:jsonStringToSend})
        .then((results) => {
            console.log('--search results--'+JSON.stringify(results));
            if(results==='Success') {
                this.notifyUser('Success', 'Email sent to attendees.', 'success');
                window.setTimeout(()=>{this.goBack()},1000);
                
            } else {
                this.notifyUser('Email error', 'There was an error sending email', 'error');
                console.error('Email error', JSON.stringify(results));
                
            }
            this.showSpinner = false;
        })
        .catch((error) => {
            this.notifyUser('Email error', 'There was an error sending email', 'error');
            this.showSpinner = false;
            console.error('Email error', JSON.stringify(error));
            
        });
       
    }
    handleRowActions(event) {
        let actionName = event.detail.action.name;
        let id = event.detail.row.email;
        switch(actionName) {
            case 'delete' :
                this.lstSendEmailToMembers = this.lstSendEmailToMembers.filter(recepient => {
                    return recepient.email!==id;
                });
                break;
        }
    }
    goBack() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view'
            }
        });
    }
}