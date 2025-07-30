public class LeadTriggerHandler {
    public static void checkActivityTask(List<Lead> LeadList) {
        Set<id> LeadIds = new  Set<id>();
        Map<id,Boolean> MapLeadtoTask = new  Map<id,Boolean>();
         for (Lead leadObj : LeadList) {
             LeadIds.add(leadObj.Id);
         }
           system.debug('LeadIds');
             system.debug(LeadIds);
               system.debug(LeadList);
        
        List<Task> TaskList = [SELECT Id,WhoId FROM Task LIMIT 100];
          system.debug('TaskList');
            system.debug(TaskList);
         for (Task TaskObj : TaskList) {
             MapLeadtoTask.put(TaskObj.WhoId, true);
              system.debug(TaskObj.WhoId);
         }
        try{
             if(LeadList.size()>0) {
                for (Lead leadObj : LeadList) {
                    system.debug('leadObj.status'+leadObj.status);
                     system.debug(MapLeadtoTask);
                     system.debug(leadObj.Id);
                     system.debug(MapLeadtoTask.containsKey(leadObj.Id));
                      system.debug(MapLeadtoTask);
                    if (leadObj.status == 'Qualified'  &&  !MapLeadtoTask.containsKey(leadObj.Id)) {
                        //leadObj.addError('This Lead  cannot be Converted, Kindly create atleast one Task');
                    }
                }
            }
        } catch(Exception e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            System.debug('The following Line : ' + e.getLineNumber());
        }
    }
    
    
     public static void prepopulateFields(List<Lead> LeadList) {
         Map<Id,String> leadOwnerCodeMap = new  Map<Id,String>();
         Set<Id> leadOwnerIds= new  Set<Id>();
         //Set<Id> bussOwnerIds= new  Set<Id>();
         if(LeadList.size()>0) {
                for (Lead leadObj : LeadList) { 
                    String ownerIdStr = Id.valueOf(leadObj.OwnerId);
                     String bussOwnerIdStr = '';
                    if(leadObj.Business_Developer__c!=null){
                         bussOwnerIdStr = Id.valueOf(leadObj.Business_Developer__c);
                    }
                        
                    if(ownerIdStr.startsWith('005') ){
                        leadOwnerIds.add(leadObj.OwnerId);
                    }
                    if(bussOwnerIdStr!='' &&  bussOwnerIdStr.startsWith('005')){
                        leadOwnerIds.add(leadObj.Business_Developer__c);
                    }
                   
                    if (leadObj.LeadSource != '' && leadObj.LeadSource != null) {
                        leadObj.Lead_Source__c = leadObj.LeadSource;
                    }
              
                    Map<ID, User> userDataMap = new Map<ID, User>([SELECT Id, User_Business_Code__c FROM User where Id IN :leadOwnerIds]);
                    
                    if ( leadObj.OwnerId != null) {
                        if(userDataMap.containskey(leadObj.OwnerId)){
                            String salespersoncode = userDataMap.get(leadObj.OwnerId).User_Business_Code__c;
                             leadObj.Salesperson_Code__c = salespersoncode;
                        }
                    } 
                  
                    if ( leadObj.Business_Developer__c != null) {
                        if(userDataMap.containskey(leadObj.Business_Developer__c)){
                            String businessDevelopercode = userDataMap.get(leadObj.Business_Developer__c).User_Business_Code__c;
                             leadObj.Business_Development_Code__c = businessDevelopercode;
                        }
                    }                     
                    
                }
            }
     }
}