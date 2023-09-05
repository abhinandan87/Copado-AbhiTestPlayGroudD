import {LightningElement, api} from 'lwc';
import chartjs from '@salesforce/resourceUrl/chartjs';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {loadScript} from 'lightning/platformResourceLoader';
import getProductFamily from '@salesforce/apex/AccountLandingPageController.getProductFamily';
import getAccountActivities from '@salesforce/apex/ActivityController.getAccountActivities';
import getActivityMoreAccounts from '@salesforce/apex/ActivityController.getActivityMoreAccounts';
import getStatuses from '@salesforce/apex/ActivityController.getStatuses';
import debugQuery from '@salesforce/apex/ActivityController.debugQuery';
import DIVISION_TOOLTIP from '@salesforce/label/c.Division_Filter_Tooltip';
import sendErrorEmail from '@salesforce/apex/AccountLandingPageController.sendErrorEmail';

export default class ActivityTab extends LightningElement {
    currentUrl = '';
    @api accountId;
    showMore = false;
    remainingRecords;
    accountIdsToNameMap;
    showMore = false;
    isChartJsInitialized;
    chartRecord;
    productFamilies = [];
    statuses = [];
    displayActivity = true;
    divisionTooltip = DIVISION_TOOLTIP;
    selectedFrame = 'Current Year';
    selectedStatus = 'All Types';
    selectedProductFamilies = [{'value': 'All Divisions', 'field': 'All Fields', 'orgId': 'All Divisions'}];
    allOption = {'value': 'All Divisions', 'field': 'All Fields', 'orgId': 'All Divisions'};
    ESGOption = {'label': 'ESG', 'value': 'Sustainable1_Sustainable1_ESG', 'orgId': 'Sustainable1', 'field': 'Sustainable1_ESG'};
    timeFrames = [{'label': 'Current Year', 'value': 'Current Year'},
        {'label': 'Current Quarter', 'value': 'Current Quarter'},
        {'label': 'Next Year', 'value': 'Next Year'},
        {'label': 'Next Quarter', 'value': 'Next Quarter'},
        {'label': 'Next Two Years', 'value': 'Next Two Years'}];

    onTimeFrameChange(event) {

        this.selectedFrame = event.detail.value;
        this.getAccountActivities(true);

    }

    onStatusChange(event) {

        this.selectedStatus = event.detail.value;
        this.getAccountActivities(true);

    }

    onProductFamilyChange(event) {
        this.selectedProductFamilies = event.detail;
        this.getAccountActivities(true);

    }

    // To get the product family
    getProductFamily() {
        let options = [];
        // By default add 'All Divisions' to product family filter
        options.push({
            'label': 'All Divisions',
            'value': 'All Divisions',
            'field': 'All Fields',
            'orgId': 'All Divisions'
        });
        getProductFamily()
            .then(data => {
                for (let i = 0; i < data.length; i++) {
                    options.push({
                        'label': data[i].Filter_Display_Name__c,
                        'value': data[i].Filter_Value__c + '_' + data[i].Label,
                        'orgId': data[i].Filter_Value__c,
                        'field': data[i].Label
                    });
                }

                this.productFamilies = options;
            });
    }

    // To get the status options
    getStatuses() {
        let options = [];
        options.push({'label': 'All Types', 'value': 'All Types'});

        getStatuses()
            .then(data => {

                for (let i = 0; i < data.length; i++) {
                    options.push({'label': data[i].Filter_Name__c, 'value': data[i].Filter_Value__c});

                }

                this.statuses = options;
            });
    }

    connectedCallback() {
        this.currentUrl = window.location.href;
        this.getProductFamily();
        this.getStatuses();

    }

    renderedCallback() {
        if (this.isChartJsInitialized) {
            return;
        }

        // load chartjs from the static resource
        Promise.all([loadScript(this, chartjs)])
            .then(() => {
                this.getAccountActivities();
                this.isChartJsInitialized = true;

            })
            .catch(error => {
                console.log('error' + error.message);
            });
    }

    getAccountActivities() {
        this.displayActivity = true;
        getAccountActivities({
            AccountId: this.accountId,
            selectedTimeframe: this.selectedFrame,
            selectedStatus: this.selectedStatus,
            selectedProductFamilies: this.selectedProductFamilies,
            windowUrl: this.currentUrl
        })
            .then(data => {
                if (data && data.data !== null && data.data.length > 0 && Object.keys(data).length !== 0) {
                    this.displayActivity = true;
                    this.parseChartData(data, false);
                } else {
                    console.log('No activity data present for selected account.');
                    this.displayActivity = false;
                    if(this.chartRecord){
                        this.chartRecord = null;
                    }
                }
            })
            .catch(error => {
                let errorMap = this.generateErrorMap(error);
                sendErrorEmail({errorObject: errorMap});
                console.log('Error in getting account activities', error);
            })
    }

    //To get more account activity records
    showMoreRecords(event) {

        getActivityMoreAccounts({
            completeAccountMap: this.remainingRecords,
            accountIdsToNameMap: this.accountIdsToNameMap
        })
            .then(data => {

                this.parseChartData(data);

            })
            .catch(error => {
                console.log('Error in getting more activity records', error);
            })
    }

    parseChartData(data) {
        var height = 400;

        for(let i = 1; i < data.labels.length; i++){
            height += 100;
        }

        this.template.querySelector(`[data-id=chartBoxActivity]`).style = "height: " + height + 'px';

        this.showMore = data.moreRecords;
        this.remainingRecords = data.remainingRecords;
        this.accountIdsToNameMap = data.accountIdsToNameMap;

        if (this.chartRecord) {
            this.chartRecord.destroy();
        }

        const ctx = this.template.querySelector('canvas.barChart');
        if(ctx){
            ctx.getContext('2d');
        }

        let formattedLabels = [];

        for(let i = 0; i < data.labels.length; i++){
            formattedLabels.push(this.formatLabel(data.labels[i], 30));
        }

        var configData = {
            labels: formattedLabels,
            datasets: data.dataSetsList
        };

        this.chartRecord = new Chart(ctx, {
            type: 'horizontalBar',
            data: configData,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                tooltips: {
                    mode: 'label',

                    callbacks: {
                        title: function (tooltipItems) {
                            let label = tooltipItems[0].yLabel[0];
                            for(let i = 1; i < tooltipItems[0].yLabel.length; i++){
                                label += ' ' + tooltipItems[0].yLabel[i];
                            }
                            return label + ' Activities';
                        },

                        label: function (tooltipItem, configData) {
                            return configData.datasets[tooltipItem.datasetIndex].label + "\n: " + tooltipItem.xLabel;
                        },
                        footer: (tooltipItems, data) => {
                            let count = tooltipItems.reduce((a, e) => a + parseInt(e.xLabel), 0);
                            return 'Count: ' + count;
                        }
                    }
                },

                legend: {
                    align: 'start',
                    labels: {
                        boxWidth: 10
                    }
                },

                scales: {
                    yAxes: [{
                        maxBarThickness: 100,
                        ticks: {min: 0,},
                        stacked: true,
                    }],
                    xAxes: [{
                        maxBarThickness: 100,
                        position: "top",
                        ticks: {min: 0,},
                        stacked: true,
                    }],
                }

            }
        });
    }

    formatLabel(str, maxwidth){
        var sections = [];
        var words = str.split(" ");
        var temp = "";

        words.forEach(function(item, index){
            if(temp.length > 0)
            {
                var concat = temp + ' ' + item;

                if(concat.length > maxwidth){
                    sections.push(temp);
                    temp = "";
                }
                else{
                    if(index == (words.length-1))
                    {
                        sections.push(concat);
                        return;
                    }
                    else{
                        temp = concat;
                        return;
                    }
                }
            }

            if(index == (words.length-1))
            {
                sections.push(item);
                return;
            }

            if(item.length < maxwidth) {
                temp = item;
            }
            else {
                sections.push(item);
            }

        });

        return sections;
    }

    generateErrorMap(error){
        let errorMap = {
            'Url': this.currentUrl,
            'Error': error.body.message,
            'StatusCode': 'Callout not made.'
        }

        return errorMap;
    }

}