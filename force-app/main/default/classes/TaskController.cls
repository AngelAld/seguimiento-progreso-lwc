public with sharing class TaskController {
    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getTaskStats(Id contactId) {
        Integer total = [
            SELECT COUNT() FROM Task  
            WHERE WhoId  = :contactId    
        ];
        Integer completados = [
            SELECT COUNT() FROM Task 
            WHERE WhoId  = :contactId AND Status = 'Completed'
        ];
        
        return new Map<String, Integer>{
            'total' => total,
            'completados' => completados
        };
    }
}