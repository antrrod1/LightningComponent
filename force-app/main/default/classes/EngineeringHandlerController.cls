public without sharing class EngineeringHandlerController {

    @AuraEnabled(cacheable=false)
    public static Engineering__c GetEngineeringFrom(Id anOpportunityId){
        try{
            return [SELECT ID, Stage__c FROM Engineering__c WHERE Opportunity__c =: anOpportunityId LIMIT 1];
        }catch(Exception e){System.Debug(e.getMessage()+' - '+e.getStackTraceString());return null;}
    }

    @AuraEnabled(cacheable=false)
    public static Id UpdateEngineeringStage(Id recordId, String aNewStage){
        try{
            Engineering__c engineering = [SELECT Stage__c FROM Engineering__c WHERE ID =: recordId LIMIT 1];
            engineering.Stage__c = aNewStage;
            update engineering;
            System.Debug('Engineering status update ok '+engineering);
            return engineering.Id;
        }catch(Exception e){System.Debug(e.getMessage()+' - '+e.getStackTraceString());return null;}
    }

/*
    public class EngineeringHistory{
        @AuraEnabled public string changeDate;
        @AuraEnabled public string changedBy;

        @AuraEnabled public string field;

        @AuraEnabled public String valueOld;
        @AuraEnabled public String valueNew;
        
        public EngineeringHistory(Engineering__History histRec){
            changeDate = histRec.CreatedDate.month()+'/'+histRec.CreatedDate.day()+'/'+histRec.CreatedDate.year()+' '+histRec.CreatedDate.hour()+':'+histRec.CreatedDate.minute();
            changedBy = histRec.createdBy.Name;
            valueOld = ''+histRec.OldValue;
            valueNew = ''+histRec.NewValue;
            field = histRec.Field;
            //System.Debug(this);
        }

        public EngineeringHistory(Engineering__History histRec, String fieldName){
            changeDate = histRec.CreatedDate.month()+'/'+histRec.CreatedDate.day()+'/'+histRec.CreatedDate.year()+' '+histRec.CreatedDate.hour()+':'+histRec.CreatedDate.minute();
            changedBy = histRec.createdBy.Name;
            valueOld = ''+histRec.OldValue;
            valueNew = ''+histRec.NewValue;
            field = fieldName;
            //System.Debug(this);
        }

    }

    @AuraEnabled(cacheable=false)
    public static List<EngineeringHistory> GetLatestHistoryFromOpportunity(Id anOpportunityId){
        List<EngineeringHistory> result = new List<EngineeringHistory>();

        try{
            Engineering__c engineering = [SELECT Id, (SELECT Field, NewValue, OldValue, CreatedDate, CreatedBy.Name FROM Histories ORDER BY CreatedDate DESC) FROM Engineering__c WHERE Opportunity__c =: anOpportunityId LIMIT 1];
            Map<String,Schema.SObjectField>  apiFieldNameToFieldNameMap = Schema.Engineering__c.SObjectType.getDescribe().fields.getMap();
            for(Engineering__History histRec : engineering.Histories){
                if(histRec.Field != 'created'){
                    result.Add(new EngineeringHistory(histRec, apiFieldNameToFieldNameMap.get(histRec.Field).getDescribe().getLabel() ));
                }
            }

        }catch(Exception e){
            System.Debug(e.getMessage()+' - '+e.getStackTraceString());
        }
        return result;
    }
*/
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    public class EngineeringHistoryGroup{
        @AuraEnabled public string changeDate;
        @AuraEnabled public string changedBy;

        @AuraEnabled public List<EngineeringHistoryGroupItem> items;
        
        public EngineeringHistoryGroup(String createdDate, String changedByName, List<EngineeringHistoryGroupItem> newItems){
            changeDate = createdDate;
            changedBy = changedByName;
            items = newItems;
        }

    }

    public class EngineeringHistoryGroupItem{

        @AuraEnabled public String field;
        @AuraEnabled public String valueOld;
        @AuraEnabled public String valueNew;
        
        public EngineeringHistoryGroupItem(String fieldName, String oldValue, String newValue){
            field = fieldName;
            valueOld = oldValue;
            valueNew = newValue;
        }

    }

    @AuraEnabled(cacheable=false)
    public static List<EngineeringHistoryGroup> GetLatestHistoryGroupFromOpportunity(Id anOpportunityId){
        List<EngineeringHistoryGroup> result = new List<EngineeringHistoryGroup>();
        String dateStr;
        String mapKey;

        try{
            Engineering__c engineering = [SELECT Id, (SELECT Field, NewValue, OldValue, CreatedDate, CreatedBy.Name FROM Histories ORDER BY CreatedDate DESC) FROM Engineering__c WHERE Opportunity__c =: anOpportunityId LIMIT 1];
            Map<String,Schema.SObjectField>  apiFieldNameToFieldNameMap = Schema.Engineering__c.SObjectType.getDescribe().fields.getMap();
            Map<String,List<EngineeringHistoryGroupItem>> groupMap = new Map<String,List<EngineeringHistoryGroupItem>>();
            for(Engineering__History histRec : engineering.Histories){
                if(histRec.Field != 'created'){
                    dateStr = histRec.CreatedDate.month()+'/'+histRec.CreatedDate.day()+'/'+histRec.CreatedDate.year()+' '+histRec.CreatedDate.hour()+':'+histRec.CreatedDate.minute();
                    mapKey = histRec.createdBy.Name+'|'+dateStr;
                    if(!groupMap.ContainsKey(mapKey)){
                        groupMap.put(mapKey,new List<EngineeringHistoryGroupItem>());
                    }
                    groupMap.get(mapKey).Add(new EngineeringHistoryGroupItem(''+apiFieldNameToFieldNameMap.get(histRec.Field).getDescribe().getLabel(),''+histRec.OldValue, ''+histRec.NewValue));
                }
            }

            for(String definedKey : groupMap.keySet()){result.Add(new EngineeringHistoryGroup(definedKey.substringAfter('|'),definedKey.substringBefore('|'),groupMap.get(definedKey)));}


        }catch(Exception e){System.Debug(e.getMessage()+' - '+e.getStackTraceString());}
        return result;
    }

}