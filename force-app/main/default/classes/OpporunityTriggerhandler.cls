public class OpporunityTriggerhandler {
    
    public static void checkOpprecordsToShare(List<Opportunity> newList, Map<Id,Opportunity> oldMap) {
       
        Map<Id,Id> mapOppBusDevToShare = new Map<Id,Id>();
        Map<Id,Id> mapOppBusDevToUnShare = new Map<Id,Id>();
           for(Opportunity oppRecord: newList){ 
               if(oldMap!=null && oppRecord.Business_Developer__c != oldMap.get(oppRecord.Id).Business_Developer__c && oldMap.get(oppRecord.Id).Business_Developer__c!=null){  
                  mapOppBusDevToShare.put(oppRecord.Id , oppRecord.Business_Developer__c);
                  mapOppBusDevToUnShare.put(oppRecord.Id , oldMap.get(oppRecord.Id).Business_Developer__c);
               }else if(oldMap!=null && oppRecord.Business_Developer__c!=null && oppRecord.Business_Developer__c != oldMap.get(oppRecord.Id).Business_Developer__c){
                    mapOppBusDevToShare.put(oppRecord.Id , oppRecord.Business_Developer__c);
               }else { //if(oldMap==null && oppRecord.Business_Developer__c!=null)
                    mapOppBusDevToShare.put(oppRecord.Id , oppRecord.Business_Developer__c);
               }  
           } 
        system.debug('mapOppBusDevToShare');
        system.debug(mapOppBusDevToShare);
         system.debug('mapOppBusDevToUnShare');
        system.debug(mapOppBusDevToUnShare);
        
        if(mapOppBusDevToShare!=null){
            OpporunityTriggerhandler.shareOppRecords(mapOppBusDevToShare);
        }
         if(mapOppBusDevToUnShare!=null){
            OpporunityTriggerhandler.unShareOppRecords(mapOppBusDevToUnShare);
        }
        
    } 
    
     public static void shareOppRecords(Map<Id,Id> mapOppBusDevToShare){
         
         List<OpportunityShare> oppShareList = new  List<OpportunityShare> ();
         for (Id oppId : mapOppBusDevToShare.keySet()) {
             if(oppId!=null && mapOppBusDevToShare.get(oppId)!=null){
                OpportunityShare Share_Record = new OpportunityShare();
                /* Object Record Id- Refer to standard share objects fields */
                Share_Record.OpportunityId = oppId;
                Share_Record.UserOrGroupId = mapOppBusDevToShare.get(oppId); //user or group Id whom to share record
                Share_Record.OpportunityAccessLevel = 'Edit';// these only for account object
                Share_Record.RowCause = Schema.OpportunityShare.RowCause.Manual; // reason
                oppShareList.add(Share_Record);
                 }
   
            }
         
        try{
            if(oppShareList!=null){
             insert oppShareList;
            }
        }catch(exception e){
            
        }
         
         
     }
    
    public static void unShareOppRecords(Map<Id,Id> mapOppBusDevToUnShare){
        
        List<OpportunityShare> oppShareToDelete = new  List<OpportunityShare> ();
        List<OpportunityShare> oppShareQueryList = new  List<OpportunityShare> ();
        Set<id> Oppids = mapOppBusDevToUnShare.keySet();
        oppShareQueryList = [SELECT Id,OpportunityId  ,UserOrGroupId      FROM OpportunityShare
                                                WHERE OpportunityId IN :oppIds
                                                AND RowCause = 'Manual'];
                if(!oppShareQueryList.isEmpty()){
                    for(OpportunityShare oppShareObj: oppShareQueryList){
                        if(oppShareObj.UserOrGroupId ==  mapOppBusDevToUnShare.get(oppShareObj.OpportunityId)){
                            oppShareToDelete.add(oppShareObj);
                        }
                    }
                    try{                        
                        Database.Delete(oppShareToDelete, false);                        
                    }catch(exception e){
                        system.debug('Exception while deleting OpportunityShare records'+e);
                    }
                }
         
         
     }
    
   /* public static void shareOpporunityRecords(List<Opportunity> oppList){
        
        List<OpportunityShare> oppShareList = new  List<OpportunityShare> ();
        for(Opportunity oppObj:oppList){
            if(oppObj.Business_Developer__c!=null){
                OpportunityShare Share_Record = new OpportunityShare();              
                Share_Record.OpportunityId = oppObj.id;
                Share_Record.UserOrGroupId = oppObj.Business_Developer__c; //user or group Id whom to share record
                Share_Record.OpportunityAccessLevel = 'Edit';// these only for account object
                Share_Record.RowCause = Schema.OpportunityShare.RowCause.Manual; // reason
                oppShareList.add(Share_Record);
            }
        }
        
        try{
            insert oppShareList;
        }catch(exception e){
            
        }
    }
    */
    
     public static void prepopulateFields(List<Opportunity> oppList){
        
        List<OpportunityShare> oppShareList = new  List<OpportunityShare> ();
        Set<Id> OptyOwnerIds= new  Set<Id>();
        Map<ID, User> userDataMap = new Map<ID, User> ();
        Set<Id> AccIds= new  Set<Id>();
        List<Account> AccList= new  List<Account>();       
             
        for(Opportunity oppObj:oppList){
            AccIds.add(oppObj.AccountId);
            if(oppObj.Opportunity_Type__c!=null){
                
                String OptyType = oppObj.Opportunity_Type__c;
                Id optyRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OptyType).getRecordTypeId();
                if(optyRecordTypeId!=null){
                oppObj.recordTypeId = optyRecordTypeId;
                }
               
            }
            
            Map<Id,String> OptyOwnerCodeMap = new  Map<Id,String>();
             
            
             String ownerIdStr = Id.valueOf(oppObj.OwnerId);
                     String bussOwnerIdStr = '';
                    if(oppObj.Business_Developer__c!=null){
                         bussOwnerIdStr = Id.valueOf(oppObj.Business_Developer__c);
                    }
                        
                    if(ownerIdStr.startsWith('005') ){
                        OptyOwnerIds.add(oppObj.OwnerId);
                    }
                    if(bussOwnerIdStr!='' &&  bussOwnerIdStr.startsWith('005')){
                        OptyOwnerIds.add(oppObj.Business_Developer__c);
                    }
            
           
                    
                      
        }
         
         Map<Id,Account> AccountMap = new Map<ID, Account>([Select id,Lead_Source__c from Account Where Id IN :AccIds ]);       
         
         if(OptyOwnerIds!=null && OptyOwnerIds.size()>0){
          userDataMap = new Map<ID, User>([SELECT Id, User_Business_Code__c FROM User where Id IN :OptyOwnerIds]);
         }
         
         
          for(Opportunity oppObj:oppList){
            //if(oppObj.Opportunity_Type__c!=null){                
                    
                    if ( oppObj.OwnerId != null && userDataMap!=null) {
                        if(userDataMap.containskey(oppObj.OwnerId)){
                            String salespersoncode = userDataMap.get(oppObj.OwnerId).User_Business_Code__c;
                             oppObj.Salesperson_Code__c = salespersoncode;
                        }
                    } 
                  
                    if ( oppObj.Business_Developer__c != null  && userDataMap!=null) {
                        if(userDataMap.containskey(oppObj.Business_Developer__c)){
                            String businessDevelopercode = userDataMap.get(oppObj.Business_Developer__c).User_Business_Code__c;
                             oppObj.Business_Development_Code__c = businessDevelopercode;
                        }
                    }    
                // }
              if(AccountMap!=null){
                  if(AccountMap.containsKey(oppObj.AccountId)){
                  			oppObj.LeadSource = AccountMap.get(oppObj.AccountId).Lead_Source__c;
                      }
              } 
                
          }
        
       
    }
    
    
    
    
    
     public static void overrideProbability(List<Opportunity> newList, Map<Id,Opportunity> oldMap) {
         
          String oldStage;
   		  Decimal oldProb;

    //get the StageNames and default percentages into a Map
    Map<String,Decimal> defaultProbabilities = new Map<String,Decimal>();

        for (OpportunityStage s : [SELECT ApiName, DefaultProbability 
                             FROM OpportunityStage
                             WHERE IsActive = TRUE] ) {
            defaultProbabilities.put(s.ApiName,s.DefaultProbability);                             
        }

    for (Opportunity o : newList) {
        oldStage = oldMap.get(o.Id).StageName;
        oldProb =  oldMap.get(o.Id).Probability;

        // if we're not changing the stage, no need to do anything
        if (o.StageName == oldStage) {
            continue;
        }

        // if the Opp used the default Probability before, do nothing
        if (oldProb == defaultProbabilities.get(oldStage) ) {
            continue;
        }

        // if the Opp is closing, best to use the default Probability
        if (o.IsClosed) {
            continue;
        } 

        // Opp is open and had a custom probability before, so put it back
            o.Probability = oldProb;
        }
         
         
         
         
     }
}