public class AccountTriggerHandler {
    
   /* public static void prepopulateFields(List<Account> Acclist){            
        for(account a: Acclist){
              a.Type = a.Type_of_Account__c;               
            }
        
        
    }*/
    
     public static void prepopulateFields(List<Account> Acclist){
         
         
          Set<Id> AccOwnerIds= new  Set<Id>();
           Map<ID, User> userDataMap = new Map<ID, User> ();
             
        for(Account Acc: Acclist){
            
            Map<Id,String> AccOwnerCodeMap = new  Map<Id,String>();
            
             String ownerIdStr = Id.valueOf(Acc.OwnerId);
                     if(ownerIdStr.startsWith('005') ){
                        AccOwnerIds.add(Acc.OwnerId);
                    }

        }
         
         if(AccOwnerIds!=null && AccOwnerIds.size()>0){
          	userDataMap = new Map<ID, User>([SELECT Id, User_Business_Code__c FROM User where Id IN :AccOwnerIds]);
         }
         
         
          for(Account Acc:Acclist){                        
                     Acc.Type = Acc.Type_of_Account__c;  
              
                    if ( Acc.OwnerId != null && userDataMap!=null) {
                        if(userDataMap.containskey(Acc.OwnerId)){
                            String salespersoncode = userDataMap.get(Acc.OwnerId).User_Business_Code__c;
                             Acc.Salesperson_Code__c = salespersoncode;
                        }
                    } 
                
          }
        
       
    }
}