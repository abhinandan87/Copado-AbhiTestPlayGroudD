import { LightningElement ,api,wire,track} from 'lwc';
import getchangeLogRecords from '@salesforce/apex/OperationsQueue.getchangeLogRecords';
import { refreshApex } from '@salesforce/apex';
const columns = [
    {
        label: 'Submitted Date/Time', fieldName: 'SubmittedDateTime__c', type: 'date',
        typeAttributes: {
            year: "numeric", month: "numeric", day: "numeric", hour: "2-digit",
            minute: "2-digit", hour12: "false"
        },
        initialWidth :'140'
    },  
    {
        label: 'Change Log',
        fieldName: 'nameUrl',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'Name' },
            target: '_self'
        },
        initialWidth :'120',
        sortable: true
    },
    { 
        label: 'Requestor',
         fieldName: 'RequestorUrl', 
         type: 'url' ,
         typeAttributes: {
             label: { fieldName: 'RequestorName' },
             target: '_self'
         },
         initialWidth :'120',
         sortable: true
        },
    { 
        label: 'Work Request',
         fieldName: 'WorkRequestFormUrl', 
         type: 'url' ,
         typeAttributes: {
             label: { fieldName: 'WorkRequestForm' },
             target: '_self'
         },
         wrapText : true,
         sortable: true
        },
    { label: 'Request Status', fieldName: 'RequestStatus__c', type: 'text', initialWidth :'120' },
    { 
        label: 'Owner',
         fieldName: 'OwnerUrl', 
         type: 'url' ,
         typeAttributes: {
             label: { fieldName: 'OwnerName' },
             target: '_self'
         },
         initialWidth :'120',
         sortable: true
        },
        { label: 'Description', fieldName: 'ChangeDescription__c', type: 'text', wrapText : true, }
];  

export default class ChangeLogQueue extends LightningElement {
    @api value = 'All';
    @track changeLog;
    @track title;
    @track wiredChangeLogList = [];
    columns = columns;
    

    renderedCallback() {
        this.isLoaded = true;
    }
    @wire(getchangeLogRecords, {selectedQueue : '$value'})
    changeLogRecord(result) {
        this.wiredChangeLogList = result;
        if (result.data) {
            this.title = "Change Logs - "+this.value;
            let nameUrl;
            let RequestorUrl;
            let RequestorName;
            let OwnerUrl ;
            let WorkRequestFormUrl;
            let WorkRequestForm;
            this.changeLog = result.data.map(row => {
                nameUrl = '';
                RequestorUrl = '';
                RequestorName = '';
                OwnerUrl = '';
                WorkRequestFormUrl = '';
                WorkRequestForm = '';
                nameUrl = `/${row.Id}`;
                if(row.ChangeDocumentedBy__r){
                    RequestorUrl = '/'+row.ChangeDocumentedBy__c;
                    RequestorName = row.ChangeDocumentedBy__r.Name;
                }
                if(row.WorkRequestForm__r){
                    WorkRequestFormUrl = '/'+row.WorkRequestForm__c;
                    WorkRequestForm = row.WorkRequestForm__r.Name;
                }
                if(row.OwnerId.startsWith('00G')){
                OwnerUrl = '/lightning/setup/Queues/page?address=%2Fp%2Fown%2FQueue%2Fd%3Fid%3D'+row.OwnerId;
                }
                else{
                    OwnerUrl = '/'+row.OwnerId;
                }
                let OwnerName = row.Owner.Name;
                return { ...row, nameUrl,RequestorUrl,RequestorName,WorkRequestFormUrl,WorkRequestForm,OwnerUrl,OwnerName}
            })
            this.error = null;
            
        } else if (result.error) {
            this.error = error;
        }
    }

    @api refreshOR(){
        return refreshApex(this.wiredChangeLogList);
    }
}