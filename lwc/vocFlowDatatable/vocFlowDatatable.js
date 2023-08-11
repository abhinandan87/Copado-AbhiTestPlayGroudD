import { LightningElement,api } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class VocFlowDatatable extends LightningElement {
    //{!feedbackTypestableV1.selectedRows}

@api selectedRows = [];
@api firstselectedRow ;
@api records=[];
@api fieldColumns = [
{ label: 'Name', fieldName: 'Name', type: 'text', wrapText: true},
{ label: 'Product', fieldName: 'ProductName__c'},
{ label: 'Product Group', fieldName: 'ProductGroupName__c'},
{ label: 'Customer Suggestion/Feedback', fieldName: 'CustomerSuggestionFeedback__c',type: 'text' },
{ label: 'Actionables/ActionItems', fieldName: 'ActionableActionItems__c',type: 'text'},
{ label: 'Status/ FinalComment', fieldName: 'StatusFinalComment__c',type: 'text'},
{ label: 'Concept Name', fieldName: 'ConceptName__c',type: 'text'}
];
handleRowSelection(event) {
    this.selectedRows = event.detail.selectedRows;
    this.firstselectedRow=this.selectedRows[0];
     console.log(this.selectedRows);
     const attributeChangeEvent = FlowAttributeChangeEvent(
         'selectedRows',
         this.selectedRows,
         'firstselectedRow',
         this.firstselectedRow

     );
     this.dispatchEvent(attributeChangeEvent);

}
}