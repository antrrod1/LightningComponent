trigger QuoteTrigger on Quote (before insert , after insert, after update) {
    
    UMH_InterfaceExecutionSettings__c cs = UMH_InterfaceExecutionSettings__c.getInstance(); 
    
     if((trigger.IsBefore && trigger.isInsert) && cs.EnableApexTriggers__c) {
        QuoteTriggerHelper.updateisPrimaryBeforeinsert(trigger.new);
    }
    
     
     if( (trigger.IsAfter&& trigger.isUpdate) && cs.EnableApexTriggers__c ) {
        QuoteTriggerHelper.updateisPrimaryAfterUpdate(trigger.new);
        QuoteTriggerHelper.updateOptyStageAfterUpdate(trigger.new);         
    }
        
     if( (trigger.IsAfter&& trigger.isInsert) && cs.EnableApexTriggers__c) {
        QuoteTriggerHelper.updateisPrimaryAfterInsert(trigger.new);
    }
        
        

}