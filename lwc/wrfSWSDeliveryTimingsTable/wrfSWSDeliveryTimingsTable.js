import { LightningElement, track, wire } from 'lwc';
import getSWSDeliveryTimings from '@salesforce/apex/WorkRequestFormController.getSWSDeliveryTimings';

export default class WrfSWSDeliveryTimingsTable extends LightningElement {
    @track
    columns = [
       { label: 'Product', fieldName: 'Product__c' ,type: 'text' },
       { label: 'Standard Request', fieldName: 'StandardRequest__c',type: 'text' },
       { label: 'Standard Plus add on', fieldName: 'StandardPlusaddon__c' ,type: 'text' },
       { label: 'Custom Work', fieldName: 'CustomWork__c',type: 'text' }
   ];
   @track deliveryTimingsData;
   @wire(getSWSDeliveryTimings)
   wiredDeliveryTimings({ error, data }) {
       //Check if data exists 
       if (data) {
           this.deliveryTimingsData = data;
           console.log(JSON.stringify(data));
       } else if (error) {
           console.log(error);
       } else {
           console.log('unknown error')
       }
   }

}