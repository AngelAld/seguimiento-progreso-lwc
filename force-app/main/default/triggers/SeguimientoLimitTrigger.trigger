trigger SeguimientoLimitTrigger on Seguimiento__c (before insert, before update) {
    // Cuando alguien intente crear un nuevo Seguimiento__c con Etapa__c = 'Pendiente', el sistema verificará cuántos seguimientos pendientes ya tiene ese contacto. Si hay 5 o más, mostrará un error y cancelará la operación.

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