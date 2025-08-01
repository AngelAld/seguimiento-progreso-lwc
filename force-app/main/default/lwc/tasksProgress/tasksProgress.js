import getTaskStats from '@salesforce/apex/TaskController.getTaskStats';
import { LightningElement, api, wire } from 'lwc';

export default class TasksProgress extends LightningElement {
    @api recordId;
    porcentaje = 0;
    completados = 0;
    total = 0;
    error;

    @wire(getTaskStats, { contactId: '$recordId' })
    wiredStats({ error, data }) {
        if (data) {
            this.total = data.total;
            this.completados = data.completados;
            this.porcentaje = this.total > 0 ? Math.round((this.completados / this.total) * 100) : 0;
        } else if (error) {
            this.error = error;
        }
    }
}