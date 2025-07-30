trigger ContactTrigger on Contact (before insert, before update, after insert, after update) {
    
     UMH_InterfaceExecutionSettings__c cs = UMH_InterfaceExecutionSettings__c.getInstance(); 
    
    if(Trigger.isInsert && trigger.IsAfter && Trigger.new.size()<2 && !System.isfuture() && !System.isBatch() && cs.EnableApexTriggers__c ){
         if(NAV_SyncData_Callout.ContactAvoidRecursion){
             NAV_SyncData_Callout.ContactAvoidRecursion=false;  
             NAV_SyncData_Callout.ContactPostRequest(trigger.newmap.keyset()); 
             //While inserting account - contact will be automatically inserted through callout class, hence no api call required
         }
    }
    
     if(trigger.IsAfter && (trigger.isUpdate|| trigger.isInsert) && cs.EnableApexTriggers__c) {      
          ContactTriggerhandler.checkConrecordsToShare(trigger.new, trigger.oldMap);
    }
    
     if(Trigger.isUpdate && Trigger.isAfter && Trigger.new.size()<2 && !System.isfuture() && !System.isBatch() && cs.EnableApexTriggers__c ){         
         
         if(NAV_SyncData_Callout.ContactAvoidRecursion){
             NAV_SyncData_Callout.ContactAvoidRecursion=false;  
             if(!Test.isRunningTest()){
                 NAV_SyncData_Callout.ContactPostRequest(trigger.newmap.keyset()); 
             }
            
         }
    }
    
         if(trigger.IsBefore && (trigger.isUpdate|| trigger.isInsert)  && cs.EnableApexTriggers__c) {      
         	 ContactTriggerhandler.prepopulateFields(trigger.new);
    }
 
}