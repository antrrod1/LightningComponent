public class QuoteTriggerHelper {
    
    
       public static void updateisPrimaryBeforeinsert(List<Quote> quoteList){
           
          Set<Id> oppIdSet = new  Set<Id>();
         for(Quote quoteObj:quoteList){
             oppIdSet.add(quoteObj.OpportunityId);             
         }
         
         
         List<Opportunity> lstOpty = [select id , name,(select id,Is_Primary__c from Quotes where Is_Primary__c = true)  from Opportunity where Id IN:oppIdSet];
        
             Map<Id,Boolean> mapOfOppHavingPrimaryQuotes = new  Map<Id,Boolean>();
        
        for(Opportunity oppObj : lstOpty){
            if(oppObj.Quotes.size() >0){
                mapOfOppHavingPrimaryQuotes.put(oppObj.Id,true);
            }
        }
             
        for(Quote quoteObj : quoteList){
            if( !mapOfOppHavingPrimaryQuotes.containsKey(quoteObj.OpportunityId)){
                  quoteObj.Is_Primary__c = true;            
                
            }
        }
         
           
           
           
       }
    
     public static void updateisPrimaryAfterUpdate(List<Quote> quoteList){
         Set<Id> oppIdSet = new  Set<Id>();
         for(Quote quoteObj:quoteList){
             oppIdSet.add(quoteObj.OpportunityId);             
         }
         
         
         List<Opportunity> lstOpty = [select id , name,(select id,Is_Primary__c,OpportunityId,TotalAmountExclTax__c from Quotes)  from Opportunity where Id IN:oppIdSet];
        
         
        Map<Id,Boolean> mapOfOppHavingQuotes = new  Map<Id,Boolean>();
          Map<Id,List<Quote>> mapOfOppWithQuotes = new  Map<Id,List<Quote>>();
        
        for(Opportunity oppObj : lstOpty){
            if(oppObj.Quotes.size() >0){
                mapOfOppHavingQuotes.put(oppObj.Id,true);
                mapOfOppWithQuotes.put(oppObj.Id,oppObj.Quotes);
            }
        }
         
          List<Quote> quotestoUpdate = new List<Quote>();
         List<Opportunity> OpportunitiestoUpdate = new List<Opportunity>();
         
        for(Quote quoteObj : quoteList){
            if(quoteObj.Is_Primary__c && mapOfOppHavingQuotes.containsKey(quoteObj.OpportunityId)){
                List<Quote> quotesLstforOpty = mapOfOppWithQuotes.get(quoteObj.OpportunityId);
                for(Quote quoteOptyObj : quotesLstforOpty){
                    
                  if(quoteOptyObj.id!=quoteObj.Id && quoteOptyObj.Is_Primary__c == true){
                        Quote obj = new Quote();
                        obj.Id = quoteOptyObj.id;
                        obj.Is_Primary__c = false;
                        quotestoUpdate.add(obj);
                    }
                    else if(quoteOptyObj.id==quoteObj.Id && quoteOptyObj.Is_Primary__c == true){
                        Opportunity opp  = new Opportunity();
                        opp.Id = quoteOptyObj.OpportunityId;
                        opp.Amount = quoteOptyObj.TotalAmountExclTax__c;
                        OpportunitiestoUpdate.add(opp);
                    }
                    
                }
                
                
            }
        }
         
         try{
            
             if(quotestoUpdate.size()>0){
                 update quotestoUpdate;
             }
             if(OpportunitiestoUpdate.size()>0){
                 update OpportunitiestoUpdate;
             }
                 }catch(exception e){
                     
                 }
     }
    
    public static void updateOptyStageAfterUpdate(List<Quote> quoteList){
         Set<Id> oppIdSet = new  Set<Id>();
         for(Quote quoteObj:quoteList){
             oppIdSet.add(quoteObj.OpportunityId);             
         }
         
         
         List<Opportunity> lstOpty = [select id , name,(select id,Is_Primary__c,OpportunityId,TotalAmountExclTax__c,status from Quotes)  from Opportunity where Id IN:oppIdSet];
        
         
        Map<Id,Boolean> mapOfOppHavingQuotes = new  Map<Id,Boolean>();
          Map<Id,List<Quote>> mapOfOppWithQuotes = new  Map<Id,List<Quote>>();
        
        for(Opportunity oppObj : lstOpty){
            if(oppObj.Quotes.size() >0){
                mapOfOppHavingQuotes.put(oppObj.Id,true);
                mapOfOppWithQuotes.put(oppObj.Id,oppObj.Quotes);
            }
        }
         
          List<Quote> quotestoUpdate = new List<Quote>();
         List<Opportunity> OpportunitiestoUpdate = new List<Opportunity>();
         Set<id> OpptyUpdateIds = new  Set<id>();
         
        for(Quote quoteObj : quoteList){
            if(quoteObj.Status!=null && mapOfOppHavingQuotes.containsKey(quoteObj.OpportunityId)){
                List<Quote> quotesLstforOpty = mapOfOppWithQuotes.get(quoteObj.OpportunityId);
                Integer quotesLstforOptySize = quotesLstforOpty.size();
                Integer countDeadQuotes = 0;
                for(Quote quoteOptyObj : quotesLstforOpty){
                    
                   if(quoteOptyObj.status!=null && quoteOptyObj.status == 'Won' && !OpptyUpdateIds.contains(quoteOptyObj.OpportunityId)){
                        Opportunity opp  = new Opportunity();
                        opp.Id = quoteOptyObj.OpportunityId;
                        opp.StageName = 'Closed Won';
                        opp.Closure_Reason__c  = quoteOptyObj.status;                       
                        OpportunitiestoUpdate.add(opp);
                        OpptyUpdateIds.add(opp.Id);
                   }else if( quoteOptyObj.status!=null && quoteOptyObj.status.contains('Lost') && !OpptyUpdateIds.contains(quoteOptyObj.OpportunityId)){
                        Opportunity opp  = new Opportunity();
                        opp.Id = quoteOptyObj.OpportunityId;
                        opp.StageName = 'Closed Lost';
                        opp.Closure_Reason__c  = quoteOptyObj.status;
                        OpportunitiestoUpdate.add(opp);
                        OpptyUpdateIds.add(opp.Id);
                   }else if(quoteOptyObj.status == 'Dead'){
                       countDeadQuotes = countDeadQuotes+1;
                    }
                    
                }
                
                if(countDeadQuotes == quotesLstforOptySize ){
                   	   Opportunity opp  = new Opportunity();
                        opp.Id = quoteObj.OpportunityId;
                        opp.StageName = 'Closed Lost';
                        opp.Closure_Reason__c  = quoteObj.status;
                        OpportunitiestoUpdate.add(opp);
                        OpptyUpdateIds.add(opp.Id);
                    
                }
                
                
            }
        }
         
         try{
            
             if(OpportunitiestoUpdate.size()>0){
                 update OpportunitiestoUpdate;
             }
                 }catch(exception e){
                     
                 }
     }
    
    
      public static void updateisPrimaryAfterInsert(List<Quote> quoteList){
         Set<Id> oppIdSet = new  Set<Id>();
         for(Quote quoteObj:quoteList){
             oppIdSet.add(quoteObj.OpportunityId);             
         }
         
         
         List<Opportunity> lstOpty = [select id , name,(select id,Is_Primary__c from Quotes)  from Opportunity where Id IN:oppIdSet];
        
         
        Map<Id,Boolean> mapOfOppHavingQuotes = new  Map<Id,Boolean>();
          Map<Id,Integer> mapOfOppHavingQuotesSize = new  Map<Id,Integer>();
          Map<Id,List<Quote>> mapOfOppWithQuotes = new  Map<Id,List<Quote>>();
        
        for(Opportunity oppObj : lstOpty){
            if(oppObj.Quotes.size() >0){
                mapOfOppHavingQuotes.put(oppObj.Id,true);
                mapOfOppHavingQuotesSize.put(oppObj.Id, oppObj.Quotes.size());
                mapOfOppWithQuotes.put(oppObj.Id,oppObj.Quotes);
            }
        }
         
          List<Quote> quotestoUpdate = new List<Quote>();
         
        for(Quote quoteObj : quoteList){
            if(mapOfOppHavingQuotes.containsKey(quoteObj.OpportunityId)){
                List<Quote> quotesLstforOpty = mapOfOppWithQuotes.get(quoteObj.OpportunityId);
                if(mapOfOppHavingQuotesSize.get(quoteObj.OpportunityId)>1){
                    
                    for(Quote quoteOptyObj : quotesLstforOpty){                
                        Quote obj = new Quote();
                        obj.Id = quoteOptyObj.id;
                        obj.Is_Primary__c = false;
                        quotestoUpdate.add(obj);
                }                    
                }
              
            }
        }
         
         try{
             update quotestoUpdate;
                 }catch(exception e){
                     
                 }
     }

}