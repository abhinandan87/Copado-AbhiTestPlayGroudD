import { LightningElement, api, track } from 'lwc';

export default class WrfCountryRegionSelection extends LightningElement {
    @api regionOptions;
    @api listRegions;
    @track selectedOptions;

    get listRegionOptions() {
        return this.prepareRegionOptions();
    }

    prepareRegionOptions() {
        var options = [];
        this.regionOptions.forEach(regionOption => {
            let option = { label: regionOption.label, value: true };
            //let option = { ...regionOption };
            options.push(option);
        });
        return options;
    }


    get hasRegions() {
        if (this.regionOptions && this.regionOptions.length > 0) {
            return true;
        } else {
            return false;
        }
    }

    updateAllRegionsToSelected() {
        this.regionOptions.forEach(regionOption => {
            regionOption.value = true;
        });

    }

    handleSelectAll(event) {
        this.selectedOptions = undefined;
        this.setSelectedOptions();
        //Adds all the picklist options
        this.prepareRegionOptions();
        this.dispatchSelectionChangeEvent();
        this.listRegionOptions;
    }

    handleDeselectAll(event) {
        this.selectedOptions = [];
        this.dispatchSelectionChangeEvent();
    }

    setSelectedOptions() {
        if (!this.selectedOptions) {
            this.selectedOptions = [];
            this.listRegions.forEach(region => {
                this.selectedOptions.push(region);
            });
        }
    }

    dispatchSelectionChangeEvent() {
        var evt = new CustomEvent("selectionchange", { detail: this.selectedOptions });;
        this.dispatchEvent(evt);
    }

    handleChange(e) {
        this.setSelectedOptions();
        if (e.target.checked) {
            this.selectedOptions.push(e.target.label);
        } else {
            let index = this.selectedOptions.indexOf(e.target.label);
            this.selectedOptions.splice(index, 1);
        }
        this.dispatchSelectionChangeEvent();
    }
}