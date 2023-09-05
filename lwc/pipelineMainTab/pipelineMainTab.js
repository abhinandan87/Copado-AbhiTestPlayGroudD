import {LightningElement, api} from 'lwc';
import chartjs from '@salesforce/resourceUrl/chartjs';
import {loadScript} from 'lightning/platformResourceLoader';
import getPipelineAccounts from '@salesforce/apex/PipelineController.getPipelineAccounts';
import getPipelineMoreAccounts from '@salesforce/apex/PipelineController.getPipelineMoreAccounts';
import getProductFamily from '@salesforce/apex/AccountLandingPageController.getProductFamily';
import debugQuery from '@salesforce/apex/PipelineController.debugQuery';
import DIVISION_TOOLTIP from '@salesforce/label/c.Division_Filter_Tooltip';
import sendErrorEmail from '@salesforce/apex/AccountLandingPageController.sendErrorEmail';

export default class PipelinMainTab extends LightningElement {

    @api accountId;
    currentUrl = '';
    showMore = false;
    remainingRecords;
    isChartJsInitialized;
    recordCountMap;
    chartRecord;
    productFamilies = [];
    displayPipeline = true;
    divisionTooltip = DIVISION_TOOLTIP;
    selectedFrame = 'Current Year';
    selectedProbability = '100';
    selectedProductFamilies = [{'value': 'All Divisions', 'field': 'All Fields', 'orgId': 'All Divisions'}];
    allOption = {'value': 'All Divisions', 'field': 'All Fields', 'orgId': 'All Divisions'};
    ESGOption = {'label': 'ESG', 'value': 'Sustainable1_ESG_ESG_Product_Amount__c', 'orgId': 'Sustainable1_ESG', 'field': 'ESG_Product_Amount__c'};
    // Time Frames options
    timeFrames = [{'label': 'Current Year', 'value': 'Current Year'},
        {'label': 'Current Quarter', 'value': 'Current Quarter'},
        {'label': 'Next Year', 'value': 'Next Year'},
        {'label': 'Next Quarter', 'value': 'Next Quarter'},
        {'label': 'Next Two Years', 'value': 'Next Two Years'}];

    // Probability options
    probability = [{'label': '100%', 'value': '100'},
        {'label': '>75%', 'value': '75'},
        {'label': '>50%', 'value': '50'},
        {'label': '>25%', 'value': '25'},
        {'label': '>0%', 'value': '0'}];


    /* on time frame filter change */
    onTimeFrameChange(event) {
        this.selectedFrame = event.detail.value;
        this.getAccounts(true);
    }

    /* on probability filter change */
    onProbabilityChange(event) {
        this.selectedProbability = event.detail.value;
        this.getAccounts(true);
    }

    /* on product family filter change */
    onProductFamilyChange(event) {
        this.selectedProductFamilies = event.detail;
        this.getAccounts(true);
    }


    /* Get product family picklist values */
    getProductFamily() {
        let options = [];
        // By default add 'All Divisions' to product family filter
        options.push({'label': 'All Divisions', 'value': 'All Divisions', 'field': 'All Fields', 'orgId': 'All Divisions'});
        getProductFamily()
            .then(data => {
                for (let i = 0; i < data.length; i++) {
                    options.push({
                        'label': data[i].Filter_Display_Name__c,
                        'value': data[i].Label + '_' + data[i].Opportunity_Amount_Field__c,
                        'orgId':data[i].Label,
                        'field': data[i].Opportunity_Amount_Field__c});
                }

                this.productFamilies = options;
            });
    }

    connectedCallback() {
        this.currentUrl = window.location.href;
        this.getProductFamily();
    }

    renderedCallback() {
        if (this.isChartJsInitialized) {
            return;
        }
        // load chartjs from the static resource
        Promise.all([loadScript(this, chartjs)])
            .then(() => {
                this.getAccounts();
                this.isChartJsInitialized = true;

            })
            .catch(error => {
                console.log('error'+error.message);
            });
    }

    clear(){
        let multiSelectPicklist = this.template.querySelector('c-multi-select-pick-list');
        if (multiSelectPicklist) {
            multiSelectPicklist.clear();
        }
    }

    // To fetch the accounts with opportunity amounts to display in the chart
    getAccounts() {
        this.displayPipeline = true;
        getPipelineAccounts({
            AccountId: this.accountId,
            selectedTimeframe: this.selectedFrame,
            selectedProbability: this.selectedProbability,
            selectedProductFamilies: this.selectedProductFamilies,
            windowUrl: this.currentUrl
        })
            .then(data => {

                if (data && data.data !== null && data.data.length > 0 && Object.keys(data).length !== 0) {
                    this.displayPipeline = true;
                    this.recordCountMap = data.recordCountMap;
                    this.parseChartData(data);
                } else {
                    console.log('No opportunity data present for selected account.');
                    this.displayPipeline = false;
                    if(this.chartRecord) {
                        this.chartRecord = null;
                    }
                }
            })
            .catch(error => {
                let errorMap = this.generateErrorMap(error);
                sendErrorEmail({errorObject: errorMap});
                console.log('Error when getting accounts', error);
            })
    }

    // To get more records
    showMoreRecords(event) {
        getPipelineMoreAccounts({completeAccountMap: this.remainingRecords})
            .then(data => {
                if (data) {
                    this.parseChartData(data);
                }
            })
            .catch(error => {
                console.log('getMustGatherDetails error', error);
            })
    }

    // To parse the chart data
    parseChartData(data) {

        var height = 400;

        for(let i = 1; i < data.labels.length; i++){
            height += 100;
        }

        this.template.querySelector(`[data-id=chartBox]`).style = "height: " + height + 'px';
        this.showMore = data.moreRecords;
        this.remainingRecords = data.remainingRecords;

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
            datasets: data.dataSetsList,
            recordCountMap: this.recordCountMap,
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

                            return label + ' Opportunities';
                        },

                        label: function (tooltipItem, configData) {
                            const formatter = new Intl.NumberFormat('en-US', {
                                style: 'currency',
                                currency: 'USD',
                                minimumFractionDigits: 0,
                            })

                            let label = tooltipItem.yLabel[0];
                            for(let i = 1; i < tooltipItem.yLabel.length; i++){
                                label += ' ' + tooltipItem.yLabel[i];
                            }
                            let countMap = configData.recordCountMap[label];
                            let yy = countMap[configData.datasets[tooltipItem.datasetIndex].orgId] ? countMap[configData.datasets[tooltipItem.datasetIndex].orgId] : 0;

                            return configData.datasets[tooltipItem.datasetIndex].label + "\n: " + formatter.format(tooltipItem.xLabel) + ' Opportunity Count : ' + yy;
                        },

                        footer: (tooltipItems, data) => {
                            const formatter = new Intl.NumberFormat('en-US', {
                                style: 'currency',
                                currency: 'USD',
                                minimumFractionDigits: 0
                            })
                            let total = tooltipItems.reduce((a, e) => a + parseInt(e.xLabel), 0);

                            let label = tooltipItems[0].yLabel[0];
                            for(let i = 1; i < tooltipItems[0].yLabel.length; i++){
                                label += ' ' + tooltipItems[0].yLabel[i];
                            }
                            let countMap = this.recordCountMap[label];
                            let count = 0;
                            for(let key in countMap){
                                count += countMap[key];
                            }
                            let summary = ['Total: ' + formatter.format(total)];
                            summary.push('Count: ' + count);
                            return summary;
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