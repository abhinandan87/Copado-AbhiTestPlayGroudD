import { LightningElement,api,wire,track } from 'lwc';
import getProductDetails from '@salesforce/apex/WorkRequestFormController.getProductDetails';

const columns = [
    {
        label: 'Product Family', fieldName: 'productfamily', type: 'text'
        
    },  
    {
        label: 'Product Name', fieldName: 'productName', type: 'text'
        
    },
    {
        label: 'Quantity', fieldName: 'Quantity', type: 'number'
        
    },
    {
        label: 'Pricebook List Price', fieldName: 'unitPrice', type: 'number'
        
    },
    {
        label: 'List Price', fieldName: 'ListPrice', type: 'number'
        
    },
];
export default class OpportunityProductDetails extends LightningElement {
    @api recordId ;
    opportunityName;
    productDeatils = [];
    columns = columns;
    @track title;
    @wire(getProductDetails, {recordId : '$recordId'})
    lineItem(result) {
        if (result.data) {
            let productfamily;
            let productName;
            let unitPrice;
            this.productDeatils = result.data.map(row=>{
                this.opportunityName = row.Opportunity.Name;
                if(row.PricebookEntry){
                    unitPrice = row.PricebookEntry.UnitPrice;
                }
                if(row.PricebookEntry.Product2.Family__r){
                    productfamily = row.PricebookEntry.Product2.Family__r.Name;
                }
                if(row.PricebookEntry.Product2){
                    productName = row.PricebookEntry.Product2.Name;
                }
                return{...row, productfamily, productName,unitPrice}
            })
            this.title = "Opportunity Product Detail(s) for "+this.opportunityName;
            this.error = null;
        }else if (result.error) {
            this.error = error;
            console.log(JSON.stringify(error));
    
        }
    }
}