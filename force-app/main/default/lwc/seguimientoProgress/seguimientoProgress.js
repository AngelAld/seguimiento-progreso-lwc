import getSeguimientoStats from '@salesforce/apex/SeguimientoController.getSeguimientoStats';
import { LightningElement, api, wire } from 'lwc';



export default class SeguimientoProgress extends LightningElement {
    @api recordId;
    porcentaje = 0;
    completados = 0;
    total = 0;
    error;

    @wire(getSeguimientoStats, { contactId: '$recordId' })
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
