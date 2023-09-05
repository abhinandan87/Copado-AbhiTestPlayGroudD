import { LightningElement ,api,wire,track} from 'lwc';
import getOrderReqRecords from '@salesforce/apex/OperationsQueue.getOrderReqRecords';
import { refreshApex } from '@salesforce/apex';

const columns = [    
    {
        label: 'Submitted Date/Time', fieldName: 'SubmittedDateTime__c', type: 'date',
        typeAttributes: {
            year: "numeric", month: "numeric", day: "numeric", hour: "2-digit",
            minute: "2-digit", hour12: "false"
        }
    },  
    {
        label: 'Order Request',
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
    { label: 'Status', fieldName: 'OrderRequestStatus__c', type: 'text',initialWidth :'120' },
    { 
        label: 'Owner', 
        fieldName: 'ownerUrl', 
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'OwnerName' },
            target: '_self'
        },
        initialWidth :'120',
        sortable: true
     }
]   ;

    //Order Requested Date added for PAS SFDC-4664 
    const columnsPAS = [        
        {
            label: 'Submitted Date/Time', fieldName: 'SubmittedDateTime__c', type: 'date',
            typeAttributes: {
                year: "numeric", month: "numeric", day: "numeric", hour: "2-digit",
                minute: "2-digit", hour12: "false"
            }
        },  
        {
            label: 'Order Request',
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
        { label: 'Order Requested Date', fieldName: 'OrderRequestedDate__c', type: 'date-local'}, //SFDC-4927 Moved Order Requested Date column after Work Request
        { label: 'Status', fieldName: 'OrderRequestStatus__c', type: 'text',initialWidth :'120' },
        { 
            label: 'Owner', 
            fieldName: 'ownerUrl', 
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'OwnerName' },
                target: '_self'
            },
            initialWidth :'120',
            sortable: true
         }
]   ;

export default class OrderRequestQueue extends LightningElement {
    @api value='All';     
    @track orderReq;
    @track wiredOrderReqFList=[];
    columns = columns;    
    @track title;
    @track tableH = 70;

    get tableHeight() {
        return 'height: '+this.tableH+'px;';
    }
    
    
    @wire(getOrderReqRecords, {selectedQueue : '$value'})
    orderReqRecord(result) {        
        this.wiredOrderReqFList = result;
        if (result.data) {
            //To get dynamic height based on the result length. Adjusting length to 2 to get minimum height.
            let len = result.data.length <= 1 ? 2 : result.data.length; 
            this.tableH = len <= 7 ? len * 70 : 500;
            this.title = "Order Requests - "+this.value;
            let nameUrl;
            let ownerUrl;
            let WorkRequestFormUrl;
            let WorkRequestForm;
            this.orderReq = result.data.map(row => {
                nameUrl = '';
                ownerUrl = '';
                WorkRequestFormUrl = '';
                WorkRequestForm = '';
                nameUrl = `/${row.Id}`;
                if(row.OwnerId.startsWith('00G')){
                ownerUrl = '/lightning/setup/Queues/page?address=%2Fp%2Fown%2FQueue%2Fd%3Fid%3D'+row.OwnerId;
                }
                else{
                    ownerUrl = '/'+row.OwnerId;
                }
                let OwnerName = row.Owner.Name;
                if(row.WorkRequestForm__r){
                    WorkRequestFormUrl = '/'+row.WorkRequestForm__c;
                    WorkRequestForm = row.WorkRequestForm__r.Name;
                }
                return { ...row, nameUrl,ownerUrl,OwnerName,WorkRequestFormUrl,WorkRequestForm}
            })
            this.error = null;
            
        } else if (result.error) {
            this.error = error;
        }
    }
    @api refreshOR(){
       return refreshApex(this.wiredOrderReqFList );
    }
    //Added condition on selecting PAS SFDC-4664
    renderedCallback(){
        if(this.value==='PAS'){
            this.columns = columnsPAS;
        }
        else{
            this.columns = columns;
        }
    }
    
}