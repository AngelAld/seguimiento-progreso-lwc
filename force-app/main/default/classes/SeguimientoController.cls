public with sharing class SeguimientoController {
    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getSeguimientoStats(Id contactId) {
        Integer total = [SELECT COUNT() FROM Seguimiento__c WHERE Contacto__c = :contactId];
        Integer completados = [
            SELECT COUNT()
            FROM Seguimiento__c
            WHERE Contacto__c = :contactId AND Etapa__c = 'Completado'
        ];

        return new Map<String, Integer>{
            'total' => total,
            'completados' => completados
        };
    }
}