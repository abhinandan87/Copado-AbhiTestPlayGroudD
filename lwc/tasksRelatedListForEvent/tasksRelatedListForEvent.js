import { LightningElement, api, wire} from 'lwc';
import getRelatedTasks from '@salesforce/apex/TaskRelatedListForEventController.getRelatedTasks';
import { NavigationMixin } from 'lightning/navigation';
import deleteTask from '@salesforce/apex/TaskRelatedListForEventController.deleteTask';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import getEventDetails from '@salesforce/apex/TaskRelatedListForEventController.getEventDetails';



const actions = [
    { label: 'View', name: 'view' },
    { label: 'Delete', name: 'delete' },
];
const columns = [
    { label: 'Subject', fieldName: 'recordLink' , type: 'url',
    typeAttributes: {label: { fieldName: 'Subject' }, target: '_self'} },
    //{ label: 'WhoId', fieldName: 'WhoId' },
    { label: 'Name', fieldName: 'WhoName' },
    //{ label: 'WhatId', fieldName: 'WhatId' },
    { label: 'Related To', fieldName: 'WhatName' },
    //{ label: 'Type', fieldName: 'Type', sortable: true },
    //{ label: 'Type', fieldName: 'Type' },
    //{ label: 'Due Date', fieldName: 'ActivityDate', type: 'date', sortable: true },
    { label: 'Due Date', fieldName: 'ActivityDate', type: 'date' },
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    },
];
export default class TasksRelatedListForEvent extends NavigationMixin(LightningElement) {
    @api recordId;
    @api eventDetails;
    @api wiredTasksResult;
    columns = columns;    
    data;
    error;
    taskCount=0;
    showSpinner = false;    
    
    @wire(getRelatedTasks, {evtId: '$recordId'})
    wiredTasks( result ) {
        this.wiredTasksResult = result;
        if(result.data) {
            //console.log('wiredTasks.data='+result.data);
            //console.log('JSON wiredTasks.data='+JSON.stringify(result.data));
            //this.data = result.data;
            let currentData = [];
            result.data.forEach((row) => {
                let rowData = {};
                rowData.Id = row.Id;
                rowData.Subject = row.Subject;
                rowData.Type = row.Type;
                rowData.ActivityDate = row.ActivityDate;
                // Related To data
                if (row.WhatId) {
                    rowData.WhatId = row.WhatId;
                    rowData.WhatName = row.What.Name;
                }
                // Name data
                if (row.WhoId) {
                    rowData.WhoId = row.WhoId;
                    rowData.WhoName = row.Who.Name;
                }
                //adding url
                rowData.recordLink = '/'+row.Id;
                currentData.push(rowData);
            });
            this.data = currentData;
            this.taskCount = result.data.length;
            this.error = undefined;
            this.showSpinner = false;
        }
        else if(result.error) {
            //console.log('wiredTasks.error='+result.error);
            this.error = result.error;
            this.data = undefined;
        }
    }    

    get titleMsg() {
        return `Related Tasks (${this.taskCount})`;
    }

    get hasTasks() {
        if(this.taskCount > 0) {
            return true;
        }
        return false;
    }
    
    get eventWhatId() {
        //console.log('Inside eventWhatId() Getter');
        //console.log('JSON this.eventDetails='+JSON.stringify(this.eventDetails));
        if(this.eventDetails && this.eventDetails.WhatId) {
            //console.log('eventWhatId() Getter returns value='+this.eventDetails.WhatId);            
            return this.eventDetails.WhatId;
        }
        ////console.log('JSON this.wiredEventRecord.data='+JSON.stringify(this.wiredEventRecord.data));
        ////console.log('this.wiredEventRecord.data.WhatId='+this.wiredEventRecord.data.WhatId);
        return;
    }
    
    get eventMeetingNoteId() {
        //console.log('Inside eventMeetingNoteId() Getter');
        //console.log('JSON this.eventDetails='+JSON.stringify(this.eventDetails));
        ////console.log('JSON this.wiredEventRecord.data='+JSON.stringify(this.wiredEventRecord.data));
        ////console.log('this.wiredEventRecord.data.MeetingNote__c='+this.wiredEventRecord.data.MeetingNote__c);
        if(this.eventDetails && this.eventDetails.MeetingNote__c) {
            //console.log('eventWhatId() Getter returns value='+this.eventDetails.MeetingNote__c);
            return this.eventDetails.MeetingNote__c;
        }
        return;
    }

    handleRefresh(event) {
        console.log('handleRefresh BEGINS');
        this.showSpinner = true;
        refreshApex(this.wiredTasksResult);
        this.showSpinner = false;
        console.log('handleRefresh ENDS');
    }

    //NEW TASK CODE--BEGINS
    handleNewClick(event) {   
        //console.log('handleNewClick() BEGINS');
        this.showSpinner = true;
        event.stopPropagation();
        getEventDetails({ evtId:this.recordId })
            .then(result => {
                //console.log('getEventDetails() IMPERATIVE result='+result);
                this.eventDetails = result;
                this.openNewTaskModal();
                this.showSpinner = false;
            })
            .catch(error => {
                //console.log('getEventDetails() IMPERATIVE error='+error);
                this.eventDetails = undefined;
                this.showSpinner = false;
            });    
        //console.log('After Imperative Call');
        
        /*To redirect to another lightning component - Aura or LWC
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'c__createActivityUtilityItem'
            },
            state: {
                //backgroundContext: '/lightning/r/Event/00U290000037otdEAA/view',
                //nooverride: 1
            }
        });*/
        //console.log('handleNewClick() ENDS');
    }

    openNewTaskModal() {        
        //console.log('openNewTaskModal() BEGINS');
        //Setup default values javascript object
        //this.undefinedWhatId = '0063C0000089xNoQAI';
        let defaultValuesObj = {            
            MeetingNote__c: this.eventMeetingNoteId
        }
        if(!!this.eventWhatId) {            
            defaultValuesObj.WhatId = this.eventWhatId;
        }
        const defaultValues = encodeDefaultFieldValues(defaultValuesObj);        
        //console.log('defaultValues='+defaultValues);

        //Redirect to standard new record functionality in a modal popup. 
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Task',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues,
                //nooverride: 1,
                //backgroundContext: '/lightning/r/Event/00U290000037nhWEAQ/view',
                navigationLocation: 'LIST_VIEW'     //Used to avoid redirection to newly created task record page and stay on Event page
            }
        });
        //console.log('openNewTaskModal() ENDS');
    }
    //NEW TASK CODE ENDS------------------------------------------

    //HANDLE ROW ACTIONS CODE BEGINS
    handleRowAction(event) {        
        //console.log('handleRowAction() BEGINS');
        //console.log('event.detail='+event.detail);
        //console.log('JSON event.detail='+JSON.stringify(event.detail));
        event.stopPropagation();
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'delete':

                this.deleteRow(row);
                break;
            case 'view':
                this.navigateToRecordViewPage(row);
                break;
            default:
        }
        //console.log('handleRowAction() ENDS');
    }

    navigateToRecordViewPage(row) {
        //console.log('navigateToRecordViewPage() BEGINS');
        //console.log('JSON row='+JSON.stringify(row));
        //console.log('row.Id='+row.Id);
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: row.Id,
                objectApiName: 'Task', // objectApiName is optional
                actionName: 'view'
            }
        });
        //console.log('navigateToRecordViewPage() ENDS');
    }

    deleteRow(row) {
        alert('You are about to delete a task. Are you sure?');
        this.showSpinner = true;        //Set to false after this.wiredTasksResult is reset in @wire getRelatedTasks() method
        //console.log('deleteRow() BEGINS');
        //console.log('JSON row='+JSON.stringify(row));
        //console.log('row.Id='+row.Id);
        
        //Call Apex method imperatively
        deleteTask({ 
            taskId: row.Id 
        })
        .then((data) => {
            //console.log('JSON data='+JSON.stringify(data));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Task Record deleted',
                    variant: 'success'
                })
            );
            // Display fresh data in the form            
            return refreshApex(this.wiredTasksResult);
            
        })
        .catch(error => {
            //console.log('JSON error='+JSON.stringify(error));
            this.message = 'Error received: code' + error.errorCode + ', ' + 'message ' + error.body.message;
            //console.log('DELETE ERROR: this.message='+this.message);
            this.dispatchEvent(                
                new ShowToastEvent({
                    title: 'Error deleting task record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
        //console.log('deleteRow() ENDS');
    }

    findRowIndexById(id) {
        let ret = -1;
        this.data.some((row, index) => {
            if (row.id === id) {
                ret = index;
                return true;
            }
            return false;
        });
        return ret;
    }    
    //--------HANDLE ROW ACTIONS CODE ENDS

    //SORTING CODE BEGINS - NOT USED FOR NOW AS BLANK ROW VALUE SORTING IS NOT WORKING
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;
    
    sortBy(field, reverse, primer) {
        //console.log('sortBy() BEGINS');
        const key = primer
            ? function(x) {
                //console.log('primer(x[field])='+primer(x[field]));
                  return primer(x[field]);
              }
            : function(x) {
                //console.log('x[field]='+x[field]);
                  return x[field];
              };
        
        //console.log('field='+field);
        //console.log('reverse='+reverse);
        //console.log('primer='+primer);
        //console.log('key='+key);
        //console.log('sortBy() ENDS');
        return function(a, b) {            
            //console.log('Anonymous Closure function(a,b) BEGINS');
            //console.log('BEFORE a='+a);
            //console.log('BEFORE b='+b);
            a = key(a);
            b = key(b);
            //console.log('AFTER a='+a);
            //console.log('AFTER b='+b);
            //console.log('Anonymous Closure function(a,b) ENDS');
            return reverse * ((a > b) - (b > a));
        };
    }
    onHandleSort(event) {
        //console.log('onHandleSort() BEGINS');
        //console.log('event.detail='+event.detail);
        event.stopPropagation();
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];
        //console.log('sortedBy='+sortedBy);
        //console.log('sortDirection='+sortDirection);
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
        //console.log('this.sortDirection='+this.sortDirection);
        //console.log('this.sortedBy='+this.sortedBy);
        //console.log('onHandleSort() ENDS');
    }
    //SORTING CODE ENDS
    
}