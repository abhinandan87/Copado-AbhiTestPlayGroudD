import { LightningElement ,api,track,wire} from 'lwc';
import getWRFRecords from '@salesforce/apex/OperationsQueue.getWRFRecords';
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
        label: 'Work Request',
        fieldName: 'nameUrl',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'Name' },
            target: '_self'
        },
        wrapText : true,
        sortable: true
    },
    { 
        label: 'Primary Sales Contact', 
        fieldName: 'PrimarySalesContactUrl', type: 'url',
        typeAttributes: {
            label: { fieldName: 'ContactName' },
            target: '_self'
        },
        initialWidth :'120',
        sortable: true
     },
    { label: 'Requested Date', fieldName: 'RequestedDueDate__c', type: 'date-local',initialWidth :'120' },
    { label: 'Request Status', fieldName: 'RequestStatus__c', type: 'text',initialWidth :'120' },
    { label: 'Job Number', fieldName: 'JobNumber__c', type: 'text',initialWidth :'120' },
    { label: 'Type', fieldName: 'FormType__c', type: 'text',initialWidth :'120'},
    {
        label: 'Owner',
        fieldName: 'ownerUrl',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'ownerName' },
            target: '_self'
        },
        initialWidth :'120',
        sortable: true
    }
];

export default class WorkRequestQueue extends LightningElement {
    @api value='All';
    @track wrfs;
    @track title;
    isLoading;
    @track wiredWRFList = [];
    columns = columns;
    @track tableH = 70;
    
    get tableHeight() {
        return 'height: '+this.tableH+'px;';
    }

    @wire(getWRFRecords, {selectedQueue : '$value'})
    wrfRecord(result) {
        this.wiredWRFList = result;
        if (result.data) {
            //To get dynamic height based on the result length. Adjusting length to 2 to get minimum height.
            let len = result.data.length <= 1 ? 2 : result.data.length; 
            this.tableH = len <= 7 ? len * 70 : 500;
            this.title = "Work Request Forms - "+this.value;
            let nameUrl;
            let ownerUrl;
            let PrimarySalesContactUrl;
            let ContactName;
            this.wrfs = result.data.map(row => {
                //nameUrl = `/${row.Id}`;
                nameUrl = '';
                ownerUrl = '';
                PrimarySalesContactUrl = '';
                ContactName = '';
                nameUrl = '/'+ row.Id;
                if(row.OwnerId.startsWith('00G')){
                ownerUrl = '/lightning/setup/Queues/page?address=%2Fp%2Fown%2FQueue%2Fd%3Fid%3D'+row.OwnerId;
                }
                else{
                    ownerUrl = '/'+row.OwnerId;
                }
                let ownerName = row.Owner.Name;
                if(row.PrimarySalesContact__r){
                 PrimarySalesContactUrl = '/'+row.PrimarySalesContact__r.Id;
                 ContactName = row.PrimarySalesContact__r.Name;
                }
                return { ...row, nameUrl,ownerUrl,ownerName,PrimarySalesContactUrl,ContactName}
            })
            this.error = null;
            
        } else if (result.error) {
            this.tableH=50;
            this.error = error;
        }
    }
    @api refreshOR(){
        return refreshApex(this.wiredWRFList );
    }

}