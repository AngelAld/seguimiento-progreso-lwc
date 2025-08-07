trigger SeguimientoLimitTrigger on Seguimiento__c (before insert, before update, after insert) {
    
    // Validación de límite - BEFORE
    if (Trigger.isBefore) {
        for (Seguimiento__c seguimiento : Trigger.new) {
            if (seguimiento.Etapa__c == 'Pendiente') {
                Integer count = [SELECT COUNT() FROM Seguimiento__c 
                                 WHERE Contacto__c = :seguimiento.Contacto__c 
                                 AND Etapa__c = 'Pendiente'];
                if (count >= 5) {
                    seguimiento.addError('Este contacto ya tiene 5 seguimientos pendientes. No se pueden crear más.');
                }
            }
        }
    }
    
    // Llamada al servicio del clima - AFTER INSERT
    if (Trigger.isAfter && Trigger.isInsert) {
        Set<Id> seguimientoIds = new Set<Id>();
        for (Seguimiento__c seguimiento : Trigger.new) {
            if (String.isNotBlank(seguimiento.Ubicacion__c)) {
                seguimientoIds.add(seguimiento.Id);
            }
        }
        
        if (!seguimientoIds.isEmpty()) {
            SeguimientoClima.obtenerClimaParaSeguimientos(seguimientoIds);
        }
    }
}