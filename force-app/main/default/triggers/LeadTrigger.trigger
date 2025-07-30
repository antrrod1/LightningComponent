trigger LeadTrigger on Lead (before update, before insert) {
    
     UMH_InterfaceExecutionSettings__c cs = UMH_InterfaceExecutionSettings__c.getInstance(); 
    
    if(trigger.IsBefore && trigger.isUpdate && cs.EnableApexTriggers__c) {
        LeadTriggerHandler.checkActivityTask(trigger.new);
    }
    
    if(trigger.IsBefore && (trigger.isInsert  || trigger.isUpdate) && cs.EnableApexTriggers__c){
        LeadTriggerHandler.prepopulateFields(trigger.new);
    }
    
    
}