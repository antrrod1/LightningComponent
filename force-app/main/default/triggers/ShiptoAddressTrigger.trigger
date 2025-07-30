trigger ShiptoAddressTrigger on Ship_To_Address__c (before insert, after insert, after update) {
    
      UMH_InterfaceExecutionSettings__c cs = UMH_InterfaceExecutionSettings__c.getInstance(); 
    
    if(Trigger.isInsert && Trigger.isAfter && Trigger.new.size()<2  && cs.EnableApexTriggers__c){
    
     if(NAV_SyncData_Callout.ShipAddressAvoidRecursion){
        NAV_SyncData_Callout.ShipAddressAvoidRecursion=false;     // Avoid recursion.
        NAV_SyncData_Callout.ShipAddressPostRequest(trigger.newmap.keyset()); // Passing ids of records.
     }
    }
    
     if(Trigger.isUpdate && Trigger.isAfter && Trigger.new.size()<2 && !System.isfuture()  && cs.EnableApexTriggers__c){
         if(NAV_SyncData_Callout.ShipAddressAvoidRecursion){
             NAV_SyncData_Callout.ShipAddressAvoidRecursion=false;              
           	 NAV_SyncData_Callout.ShipAddressPostRequest(trigger.newmap.keyset()); 
         }
    }
    
     if(Trigger.isInsert && Trigger.isbefore && Trigger.new.size()<2  && cs.EnableApexTriggers__c){
         
         Set<id> accountIds = new Set<id> ();
         List<String> shiptoaddressuniquekeys = new List<String> ();
         	for (Ship_To_Address__c shipObj: Trigger.new){
                accountIds.add(shipObj.Account__c);
            }
         
        	 for(Ship_To_Address__c obj: [Select id,ShiptoaddressUniqueKey__c from Ship_To_Address__c where Account__c IN :accountIds]){
             shiptoaddressuniquekeys.add(obj.ShiptoaddressUniqueKey__c);
         }
			         
    		for (Ship_To_Address__c shipObj: Trigger.new){
                shipObj.ShiptoaddressUniqueKey__c = shipObj.Account__c+'-'+shipObj.Code__c; 
                if(shiptoaddressuniquekeys.contains( shipObj.ShiptoaddressUniqueKey__c)){
                		shipObj.addError('Duplicate Error : Account & Code fields combination should be unique');
                }
       }
     
    }

}