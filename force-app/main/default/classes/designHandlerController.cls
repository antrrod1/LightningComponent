public without sharing class designHandlerController {
        
    @AuraEnabled(cacheable=false)
    public static Design__c GetDesignFrom(Id anOpportunityId){
        try{
            return [SELECT ID, Design_Stage__c FROM Design__c WHERE Opportunity__c =: anOpportunityId LIMIT 1];
        }catch(Exception e){System.Debug(e.getMessage()+' - '+e.getStackTraceString());return null;}
    }

    @AuraEnabled(cacheable=false)
    public static Id UpdateDesignStage(Id recordId, String aNewStage){
        try{
            Design__c design = [SELECT Design_Stage__c FROM Design__c WHERE ID =: recordId LIMIT 1];
            design.Design_Stage__c = aNewStage;
            update design;
            return design.Id;
        }catch(Exception e){System.Debug(e.getMessage()+' - '+e.getStackTraceString());return null;}
    }
/*
    public class DesignHistory{
        @AuraEnabled public string changeDate;
        @AuraEnabled public string changedBy;

        @AuraEnabled public string field;

        @AuraEnabled public String valueOld;
        @AuraEnabled public String valueNew;
        
        public DesignHistory(Design__History histRec){
            changeDate = histRec.CreatedDate.month()+'/'+histRec.CreatedDate.day()+'/'+histRec.CreatedDate.year()+' '+histRec.CreatedDate.hour()+':'+histRec.CreatedDate.minute();
            changedBy = histRec.createdBy.Name;
            valueOld = ''+histRec.OldValue;
            valueNew = ''+histRec.NewValue;
            field = histRec.Field;
            //System.Debug(this);
        }

        public DesignHistory(Design__History histRec, String fieldName){
            changeDate = histRec.CreatedDate.month()+'/'+histRec.CreatedDate.day()+'/'+histRec.CreatedDate.year()+' '+histRec.CreatedDate.hour()+':'+histRec.CreatedDate.minute();
            changedBy = histRec.createdBy.Name;
            valueOld = ''+histRec.OldValue;
            valueNew = ''+histRec.NewValue;
            field = fieldName;
            //System.Debug(this);
        }

    }

    @AuraEnabled(cacheable=false)
    public static List<DesignHistory> GetLatestHistoryFromOpportunity(Id anOpportunityId){
        List<DesignHistory> result = new List<DesignHistory>();

        try{
            Design__c design = [SELECT Id, (SELECT Field, NewValue, OldValue, CreatedDate, CreatedBy.Name FROM Histories ORDER BY CreatedDate DESC) FROM Design__c WHERE Opportunity__c =: anOpportunityId LIMIT 1];
            Map<String,Schema.SObjectField>  apiFieldNameToFieldNameMap = Schema.Design__c.SObjectType.getDescribe().fields.getMap();
            for(Design__History histRec : design.Histories){
                if(histRec.Field != 'created'){
                    result.Add(new DesignHistory(histRec, apiFieldNameToFieldNameMap.get(histRec.Field).getDescribe().getLabel() ));
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


    public class DesignHistoryGroup{
        @AuraEnabled public string changeDate;
        @AuraEnabled public string changedBy;

        @AuraEnabled public List<DesignHistoryGroupItem> items;
        
        public DesignHistoryGroup(String createdDate, String changedByName, List<DesignHistoryGroupItem> newItems){
            changeDate = createdDate;
            changedBy = changedByName;
            items = newItems;
        }

    }

    public class DesignHistoryGroupItem{

        @AuraEnabled public String field;
        @AuraEnabled public String valueOld;
        @AuraEnabled public String valueNew;
        
        public DesignHistoryGroupItem(String fieldName, String oldValue, String newValue){
            field = fieldName;
            valueOld = oldValue;
            valueNew = newValue;
        }

    }

    @AuraEnabled(cacheable=false)
    public static List<DesignHistoryGroup> GetLatestHistoryGroupFromOpportunity(Id anOpportunityId){
        List<DesignHistoryGroup> result = new List<DesignHistoryGroup>();
        String dateStr;
        String mapKey;

        try{
            Design__c design = [SELECT Id, (SELECT Field, NewValue, OldValue, CreatedDate, CreatedBy.Name FROM Histories ORDER BY CreatedDate DESC) FROM Design__c WHERE Opportunity__c =: anOpportunityId LIMIT 1];
            Map<String,Schema.SObjectField>  apiFieldNameToFieldNameMap = Schema.Design__c.SObjectType.getDescribe().fields.getMap();
            Map<String,List<DesignHistoryGroupItem>> groupMap = new Map<String,List<DesignHistoryGroupItem>>();
            for(Design__History histRec : design.Histories){
                if(histRec.Field != 'created'){
                    dateStr = histRec.CreatedDate.month()+'/'+histRec.CreatedDate.day()+'/'+histRec.CreatedDate.year()+' '+histRec.CreatedDate.hour()+':'+histRec.CreatedDate.minute();
                    mapKey = histRec.createdBy.Name+'|'+dateStr;
                    if(!groupMap.ContainsKey(mapKey)){groupMap.put(mapKey,new List<DesignHistoryGroupItem>());}
                    groupMap.get(mapKey).Add(new DesignHistoryGroupItem(''+apiFieldNameToFieldNameMap.get(histRec.Field).getDescribe().getLabel(),''+histRec.OldValue, ''+histRec.NewValue));
                }
            }

            for(String definedKey : groupMap.keySet()){result.Add(new DesignHistoryGroup(definedKey.substringAfter('|'),definedKey.substringBefore('|'),groupMap.get(definedKey)));}


        }catch(Exception e){
            System.Debug(e.getMessage()+' - '+e.getStackTraceString());
        }
        return result;
    }

}