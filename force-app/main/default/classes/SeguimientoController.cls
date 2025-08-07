public with sharing class SeguimientoController {
    
    public SeguimientoController() {
        
    }
    
    @AuraEnabled
    public static SeguimientoData getSeguimientoStats(Id contactId) {
        try {
            SeguimientoData data = new SeguimientoData();
            
            // Obtener seguimientos del contacto
            List<Seguimiento__c> seguimientos = [
                SELECT Id, Name, Etapa__c, Clima_Actual__c, CreatedDate
                FROM Seguimiento__c 
                WHERE Contacto__c = :contactId
                ORDER BY CreatedDate DESC
                LIMIT 200
            ];
            
            if (!seguimientos.isEmpty()) {
                // Seguimiento más reciente
                data.nombreSeguimientoReciente = seguimientos[0].Name;
                data.climaActual = seguimientos[0].Clima_Actual__c;
                
                // Contar por etapas
                for (Seguimiento__c seg : seguimientos) {
                    switch on seg.Etapa__c {
                        when 'Pendiente' {
                            data.pendientes++;
                        }
                        when 'En Proceso' {
                            data.enProceso++;
                        }
                        when 'Completado' {
                            data.completados++;
                        }
                    }
                }
                
                data.total = seguimientos.size();
            }
            
            return data;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error al obtener datos de seguimiento: ' + e.getMessage());
        }
    }
    
    public class SeguimientoData {
        @AuraEnabled public String nombreSeguimientoReciente { get; set; }
        @AuraEnabled public String climaActual { get; set; }
        @AuraEnabled public Integer pendientes { get; set; }
        @AuraEnabled public Integer enProceso { get; set; }
        @AuraEnabled public Integer completados { get; set; }
        @AuraEnabled public Integer total { get; set; }
        
        public SeguimientoData() {
            this.nombreSeguimientoReciente = 'Sin seguimientos';
            this.climaActual = 'No disponible';
            this.pendientes = 0;
            this.enProceso = 0;
            this.completados = 0;
            this.total = 0;
        }
    }
}