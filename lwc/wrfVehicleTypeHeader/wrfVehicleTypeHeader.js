import { LightningElement, api } from 'lwc';

export default class WrfVehicleTypeHeader extends LightningElement {
    @api listVehicleTypes;
    @api geo;
    @api vehicleType;

    get rowKey() {
        return this.geo + '_' + this.vehicleType;
    }
    handleClick(event) {
        var evt = new CustomEvent("headerclick", { detail: {geo:this.geo, vehicleType: this.vehicleType }});;
        this.dispatchEvent(evt);
    }
    get rowStyleClass() {
        var cols = 3;
        if (this.listVehicleTypes) {
            cols = this.listVehicleTypes.length;
        }
        let colsString = cols.toString();
        return 'slds-size_1-of-' + colsString;
    }

}