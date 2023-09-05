import {LightningElement, api, track} from 'lwc';

export default class MultiSelectPicklist extends LightningElement {
    /*
      component receives the following params:
      label - String with label name;
      disabled - Boolean value, enable or disable Input;
      options - Array of objects [{label:'option label', value: 'option value'},{...},...];

      to clear the value call clear() function from parent:
      let multiSelectPicklist = this.template.querySelector('c-multi-select-pick-list');
      if (multiSelectPicklist) {
         multiSelectPicklist.clear();
      }

      to get the value receive "valuechange" event in parent;
      returned value is the array of strings - values of selected options;
      example of usage:
      <c-multi-select-picklist options={Options}
                                 onvaluechange={handleValueChange}
                                 label="Picklist Name">
      </c-multi-select-picklist>
      handleValueChange(event){
          console.log(JSON.stringify(event.detail));
      }
  */


    @api label = "Default label";
    _disabled = false;
    @api
    get disabled(){
        return this._disabled;
    }
    set disabled(value){
        this._disabled = value;
        this.handleDisabled();
    }
    @track inputOptions;
    allOption;
    allOptionSelector;
    ESGOption;
    ESGOptionSelector;
    @api labelTooltip;
    @track inputValue;
    @api
    get options() {
        return this.inputOptions.filter(option => option.value !== this.allOption.value);
    }
    set options(value) {
        let options = [];
        this.inputOptions = options.concat(value);
    }
    @api
    clear(){
        this.handleAllOption();
    }

    @api
    get allOptionValue(){
        return this.allOption.value;
    }
    set allOptionValue(value){
        if(!value){
            return;
        }
        this.allOption = value;
        this.inputValue = value.value;
        this.allOptionSelector = `[data-id='${value.value}']`;
    }

    @api
    get ESGOptionValue(){
        return this.ESGOption.value;
    }
    set ESGOptionValue(value){
        if(!value){
            return;
        }

        this.ESGOption = value;
        this.ESGOptionSelector = `[data-id='${value.value}']`;
    }
    value = [];
    hasRendered;
    renderedCallback() {
        if (!this.hasRendered) {
            //  we coll the logic once, when page rendered first time
            this.handleDisabled();
        }
        this.hasRendered = true;
        if(!this.labelTooltip){
            let tooltipText = this.template.querySelector(`[data-id='tooltip-text']`);
            tooltipText.classList.remove('tooltiptext');
        }
    }
    handleDisabled(){
        let input = this.template.querySelector("input");
        if (input){
            input.disabled = this.disabled;
        }
    }
    comboboxIsRendered;
    handleClick() {
        let sldsCombobox = this.template.querySelector(".slds-combobox");
        sldsCombobox.classList.toggle("slds-is-open");
        if (!this.comboboxIsRendered){
            let allOption = this.template.querySelector(this.allOptionSelector);
            allOption.firstChild.classList.add("slds-is-selected");
            this.comboboxIsRendered = true;
        }
    }
    handleSelection(event) {
        let value = event.currentTarget.dataset.value;
        if (value === this.allOption.value) {
            this.handleAllOption();
        } else if(value === this.ESGOption.value){
            this.handleESGOption();
        } else {
            this.handleOption(event, value);
        }
        let input = this.template.querySelector("input");
        input.focus();
        this.sendValues();
    }
    sendValues(){
        let values = [];
        for (const valueObject of this.value) {
            if (valueObject.value && valueObject.field && valueObject.orgId) {
                values.push({'value': valueObject.value, 'field': valueObject.field, 'orgId': valueObject.orgId});
            }
        }
        if(values.length == 0){
            let ESGOptionBox = this.template.querySelector(this.ESGOptionSelector)
            if(ESGOptionBox.firstChild.classList.contains("slds-is-selected")){
                values.push(this.ESGOption);
            } else {
                values.push(this.allOption);
            }
        }

        let picklistEvent = new CustomEvent("valuechange", {detail: values});
        this.dispatchEvent(picklistEvent);
    }
    handleAllOption(){
        this.value = [];
        this.inputValue = this.allOption.value;
        let listBoxOptions = this.template.querySelectorAll('.slds-is-selected');
        for (let option of listBoxOptions) {
            option.classList.remove("slds-is-selected");
        }
        let allOption = this.template.querySelector(this.allOptionSelector);
        allOption.firstChild.classList.add("slds-is-selected");
        this.closeDropbox();
    }
    handleESGOption(){
        this.value = [];
        this.inputValue = this.ESGOption.label;
        let listBoxOptions = this.template.querySelectorAll('.slds-is-selected');
        for (let option of listBoxOptions) {
            option.classList.remove("slds-is-selected");
        }
        let esgOption = this.template.querySelector(this.ESGOptionSelector);
        esgOption.firstChild.classList.add("slds-is-selected");
        this.closeDropbox();
    }
    handleOption(event, value){
        let listBoxOption = event.currentTarget.firstChild;
        let esgOptionBox = this.template.querySelector(this.ESGOptionSelector);
        console.log('listboxoption: ', listBoxOption);
        if (listBoxOption.classList.contains("slds-is-selected")) {
            this.value = this.value.filter(option => option.value !== value);
        }
        else {
            let allOption = this.template.querySelector(this.allOptionSelector);
            if(esgOptionBox.firstChild.classList.contains("slds-is-selected")){
                allOption = esgOptionBox;
            }
            allOption.firstChild.classList.remove("slds-is-selected");
            let option = this.options.find(option => option.value === value);
            this.value.push(option);
        }

        if (this.value.length > 1) {
            this.inputValue = this.value.length + ' options selected';
        }
        else if (this.value.length === 1) {
            this.inputValue = this.value[0].label;
        }
        else {
            this.inputValue = this.allOption.value;
            let allOption = this.template.querySelector(this.allOptionSelector);
            allOption.firstChild.classList.add("slds-is-selected");
        }
        listBoxOption.classList.toggle("slds-is-selected");
    }
    dropDownInFocus = false;
    handleBlur() {
        if (!this.dropDownInFocus) {
            this.closeDropbox();
        }
    }
    handleMouseleave() {
        this.dropDownInFocus = false;
    }
    handleMouseEnter() {
        this.dropDownInFocus = true;
    }
    closeDropbox() {
        let sldsCombobox = this.template.querySelector(".slds-combobox");
        sldsCombobox.classList.remove("slds-is-open");
    }
}