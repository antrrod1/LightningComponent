public class ContactTriggerHandler {
    
        public static void checkConrecordsToShare(List<Contact> newList, Map<Id,Contact> oldMap) {
       
        Map<Id,Id> mapConBusDevToShare = new Map<Id,Id>();
        Map<Id,Id> mapConBusDevToUnShare = new Map<Id,Id>();
           for(Contact conRecord: newList){ 
               if(oldMap!=null && conRecord.Business_Developer__c != oldMap.get(conRecord.Id).Business_Developer__c && oldMap.get(conRecord.Id).Business_Developer__c!=null){  
                  mapConBusDevToShare.put(conRecord.Id , conRecord.Business_Developer__c);
                  mapConBusDevToUnShare.put(conRecord.Id , oldMap.get(conRecord.Id).Business_Developer__c);
               }else if(oldMap!=null && conRecord.Business_Developer__c!=null && conRecord.Business_Developer__c != oldMap.get(conRecord.Id).Business_Developer__c){
                    mapConBusDevToShare.put(conRecord.Id , conRecord.Business_Developer__c);
               }else{ // if(oldMap==null && conRecord.Business_Developer__c!=null){
                    mapConBusDevToShare.put(conRecord.Id , conRecord.Business_Developer__c);
               }  
           } 
        
        if(mapConBusDevToShare!=null){
            ContactTriggerHandler.shareConRecords(mapConBusDevToShare);
        }
         if(mapConBusDevToUnShare!=null){
            ContactTriggerHandler.unShareConRecords(mapConBusDevToUnShare);
        }
        
    } 
    
     public static void shareConRecords(Map<Id,Id> mapConBusDevToShare){
         
         List<ContactShare> ConShareList = new  List<ContactShare> ();
         for (Id conId : mapConBusDevToShare.keySet()) {
             if(conId!=null && mapConBusDevToShare.get(conId)!=null){
                ContactShare Share_Record = new ContactShare();
                /* Object Record Id- Refer to standard share objects fields */
                Share_Record.ContactId = conId;
                Share_Record.UserOrGroupId = mapConBusDevToShare.get(conId); //user or group Id whom to share record
                Share_Record.ContactAccessLevel = 'Edit';// these only for account object
                Share_Record.RowCause = Schema.ContactShare.RowCause.Manual; // reason
                ConShareList.add(Share_Record);
                 }
   
            }
         
        try{
            if(ConShareList!=null){
             insert ConShareList;
            }
        }catch(exception e){
            
        }
         
         
     }
    
    public static void unShareConRecords(Map<Id,Id> mapConBusDevToUnShare){
        
        List<ContactShare> conShareToDelete = new  List<ContactShare> ();
        List<ContactShare> conShareQueryList = new  List<ContactShare> ();
        Set<id> Conids = mapConBusDevToUnShare.keySet();
        conShareQueryList = [SELECT Id,ContactId  ,UserOrGroupId  FROM ContactShare
                                                WHERE ContactId IN :Conids
                                                AND RowCause = 'Manual'];
                if(!conShareQueryList.isEmpty()){
                    for(ContactShare conShareObj: conShareQueryList){
                        if(conShareObj.UserOrGroupId ==  mapConBusDevToUnShare.get(conShareObj.ContactId)){
                            conShareToDelete.add(conShareObj);
                        }
                    }
                    try{                        
                        Database.Delete(conShareToDelete, false);                        
                    }catch(exception e){
                        system.debug('Exception while deleting ContactShare records'+e);
                    }
                }
         
         
     }
    
      public static void prepopulateFields(List<Contact> ConList){
         
         
          Set<Id> ConOwnerIds= new  Set<Id>();
           Map<ID, User> userDataMap = new Map<ID, User> ();
             
        for(Contact conObj: ConList){
            
            Map<Id,String> ConOwnerCodeMap = new  Map<Id,String>();
            
             String ownerIdStr = Id.valueOf(conObj.OwnerId);
                     if(ownerIdStr.startsWith('005') ){
                        ConOwnerIds.add(conObj.OwnerId);
                    }

        }
         
         if(ConOwnerIds!=null && ConOwnerIds.size()>0){
          userDataMap = new Map<ID, User>([SELECT Id, User_Business_Code__c FROM User where Id IN :ConOwnerIds]);
         }
         
         
          for(Contact conObj:conList){                        
                    
                    if ( conObj.OwnerId != null && userDataMap!=null) {
                        if(userDataMap.containskey(conObj.OwnerId)){
                            String salespersoncode = userDataMap.get(conObj.OwnerId).User_Business_Code__c;
                             conObj.Salesperson_Code__c = salespersoncode;
                        }
                    } 
                
          }
        
       
    }

}