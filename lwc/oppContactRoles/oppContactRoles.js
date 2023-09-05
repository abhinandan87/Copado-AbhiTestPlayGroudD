import { LightningElement,wire,api } from 'lwc';
import getOppyContactRoles from '@salesforce/apex/OppyContactRolesController.getOppyContactRoles';

export default class OppContactRoles extends LightningElement {
    @api recordId;
    conRoles;

    @wire (getOppyContactRoles,{recId: '$recordId'})
	wiredAccounts({data, error}){
		if(data) {
		//	this.conRoles =data;
		//	this.error = undefined;
		let recs = [];
		for (let i = 0; i < data.length; i++) {
			let task = {};
			task.comLink = '/' + data[i].ContactId;
			task.Name = data[i].Contact.Name;
			task.Role = data[i].Role;
			task.IsPrimary = data[i].IsPrimary;
			task.Phone = data[i].Phone;
			task.Email = data[i].Email;
			task = Object.assign(task, data[i]);
			recs.push(task);
		}
		this.conRoles = recs;
		} else {
			this.conRoles =undefined;
			this.error = error;
		}
	}
}