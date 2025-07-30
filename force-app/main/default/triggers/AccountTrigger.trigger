trigger AccountTrigger on Account (after insert, after update,before insert, before update) {
    
   
     UMH_InterfaceExecutionSettings__c cs = UMH_InterfaceExecutionSettings__c.getInstance(); 
    
    if(Trigger.isInsert && Trigger.isAfter && Trigger.new.size()<2 && !System.isfuture() && !System.isBatch() && cs.EnableApexTriggers__c){        
         if(NAV_SyncData_Callout.AccountAvoidRecursion){
            NAV_SyncData_Callout.AccountAvoidRecursion=false;     // Avoid recursion.
             if(!Test.isRunningTest()){
            	NAV_SyncData_Callout.AccountPostRequest(trigger.newmap.keyset()); // Passing ids of records.
             }else{
                
             }
         }
    }
    
 
       if(Trigger.isUpdate && Trigger.isAfter && Trigger.new.size()<2   && !System.isfuture() && !System.isBatch() && cs.EnableApexTriggers__c  ){
            //NAV_SyncData_Callout.AccountPostRequest(trigger.newmap.keyset()); // Passing ids of records.
         if(NAV_SyncData_Callout.AccountAvoidRecursion){
            NAV_SyncData_Callout.AccountAvoidRecursion=false;     // Avoid recursion.
           if(!Test.isRunningTest()){
            	NAV_SyncData_Callout.AccountPostRequest(trigger.newmap.keyset()); // Passing ids of records.
             }else{
                 //
             }
         }
           
          
    }
    
    
     if( ((Trigger.isUpdate && Trigger.isBefore) || ((Trigger.isBefore) && Trigger.isInsert )) && cs.EnableApexTriggers__c ){
               AccountTriggerHandler.prepopulateFields(Trigger.New); 
           }

}