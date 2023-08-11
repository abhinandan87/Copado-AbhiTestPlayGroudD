import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import NewAccountCreationMaintenance from '@salesforce/label/c.NewAccountCreationMaintenance';
export default class NavigationToPagesExample extends NavigationMixin(LightningElement) {
    connectedCallback() {
        // Navigate to a URL
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: NewAccountCreationMaintenance
            }
        },
        false
      );
    }
}