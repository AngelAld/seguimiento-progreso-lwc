import getSeguimientoStats from '@salesforce/apex/SeguimientoController.getSeguimientoStats';
import getTaskStats from '@salesforce/apex/TaskController.getTaskStats';
import { LightningElement, api } from 'lwc';

export default class TasksProgress extends LightningElement {
    @api recordId;
    
    // Datos de tareas
    porcentaje = 0;
    completados = 0;
    total = 0;
    
    // Datos de seguimientos
    nombreSeguimientoReciente = 'Sin seguimientos';
    climaActual = 'No disponible';
    pendientes = 0;
    enProceso = 0;
    completadosSeguimientos = 0;
    totalSeguimientos = 0;
    
    error;
    isLoading = true;

    connectedCallback() {
        this.loadData();
    }
    
    async loadData() {
        this.isLoading = true;
        try {
            // Cargar datos de tareas
            const taskData = await getTaskStats({ contactId: this.recordId });
            this.total = taskData.total;
            this.completados = taskData.completados;
            this.porcentaje = this.total > 0 ? Math.round((this.completados / this.total) * 100) : 0;
            
            // Cargar datos de seguimientos
            const seguimientoData = await getSeguimientoStats({ contactId: this.recordId });
            this.nombreSeguimientoReciente = seguimientoData.nombreSeguimientoReciente;
            this.climaActual = seguimientoData.climaActual;
            this.pendientes = seguimientoData.pendientes;
            this.enProceso = seguimientoData.enProceso;
            this.completadosSeguimientos = seguimientoData.completados;
            this.totalSeguimientos = seguimientoData.total;
            
        } catch (error) {
            this.error = error;
            console.error('Error loading data:', error);
        } finally {
            this.isLoading = false;
        }
    }
}