trigger OpportunityTrigger on Opportunity (before insert , after insert, before update,  after update) {
   
    //String Enable_Triggers = System.Label.EnableApexTriggers;
    UMH_InterfaceExecutionSettings__c cs = UMH_InterfaceExecutionSettings__c.getInstance(); 
    
    if(trigger.IsAfter && (trigger.isUpdate|| trigger.isInsert) && cs.EnableApexTriggers__c) {
       // OpporunityTriggerhandler.shareOpporunityRecords(trigger.new);
       	  OpporunityTriggerhandler.checkOpprecordsToShare(trigger.new, trigger.oldMap);
    }
    
     if(trigger.IsBefore && (trigger.isUpdate|| trigger.isInsert)  && cs.EnableApexTriggers__c) {
      
        OpporunityTriggerhandler.prepopulateFields(trigger.new);
    }
    
    
   if(trigger.IsBefore && (trigger.isUpdate)  && cs.EnableApexTriggers__c) {
      
        OpporunityTriggerhandler.overrideProbability(trigger.new, trigger.oldMap);
    }
    
    

}