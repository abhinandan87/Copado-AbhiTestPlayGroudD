import { LightningElement, api } from 'lwc';

export default class AccountMainHeader extends LightningElement {
    @api recordName;
    @api headerLogo;
    @api recordUltimateParent;
}