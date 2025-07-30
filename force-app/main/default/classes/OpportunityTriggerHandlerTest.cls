@isTest
private class OpportunityTriggerHandlerTest {
    
    @isTest
    static void testShareOpportunityRecords() {
        
        UMH_InterfaceExecutionSettings__c setupdataObj = new UMH_InterfaceExecutionSettings__c();
        setupdataObj.EnableApexTriggers__c = true;
        setupdataObj.EnableNavInterface__c = true;
        insert setupdataObj;
        
        // Create test Opportunities with Business Developer assigned
        List<Opportunity> testOpportunities = new List<Opportunity>();
        for(Integer i = 0; i < 3; i++) {
            Opportunity opportunityToCreate = new Opportunity();
            opportunityToCreate.StageName = 'Sourcing Demand';
       		opportunityToCreate.CloseDate = Date.parse('01/01/2024');
      		opportunityToCreate.Name = 'Test Opportunity Triggers';
            opportunityToCreate.Business_Developer__c = UserInfo.getUserId();
            
            testOpportunities.add(opportunityToCreate);
        }
        insert testOpportunities;

        Test.startTest();        
      //  OpporunityTriggerhandler.shareOpporunityRecords(testOpportunities);
        OpporunityTriggerhandler.checkOpprecordsToShare(testOpportunities, null);
        Test.stopTest();

        // Perform assertions
        List<OpportunityShare> opportunityShares = [SELECT Id,UserOrGroupId,OpportunityAccessLevel FROM OpportunityShare WHERE OpportunityId IN :testOpportunities];
        System.assertEquals(3, opportunityShares.size());
        for(OpportunityShare share : opportunityShares) {
            System.assertEquals(UserInfo.getUserId(), share.UserOrGroupId);
           // System.assertEquals('Edit', share.OpportunityAccessLevel);
            //System.assertEquals(Schema.OpportunityShare.RowCause.Manual, share.RowCause);
        }
    }

    @isTest
    static void testPrepopulateFields() {
        UMH_InterfaceExecutionSettings__c setupdataObj = new UMH_InterfaceExecutionSettings__c();
        setupdataObj.EnableApexTriggers__c = true;
        setupdataObj.EnableNavInterface__c = true;
        insert setupdataObj;
        
        // Create test Opportunities with Opportunity Type and Owners
        List<Opportunity> testOpportunities = new List<Opportunity>();
        for(Integer i = 0; i < 3; i++) {
            
            Opportunity opportunityToCreate = new Opportunity();
            opportunityToCreate.StageName = 'Sourcing Demand';
       		opportunityToCreate.CloseDate = Date.parse('01/01/2024');
      		opportunityToCreate.Name = 'Test Opportunity Triggers';
            opportunityToCreate.Business_Developer__c = UserInfo.getUserId();
            opportunityToCreate.OwnerId = UserInfo.getUserId();
            opportunityToCreate.Opportunity_Type__c = 'Product';
            
            testOpportunities.add(opportunityToCreate);
        }
        insert testOpportunities;
		Map<Id,Id> mapOppBusDevToUnShare = new Map<Id,Id>();
        
        Test.startTest();       
        OpporunityTriggerhandler.prepopulateFields(testOpportunities);
        //OpporunityTriggerhandler.UnshareOpporunityRecords(testOpportunities);        
        for(Opportunity oppObj :testOpportunities){
            mapOppBusDevToUnShare.put(oppObj.Id , oppObj.Business_Developer__c);
        }
         OpporunityTriggerhandler.ShareOppRecords(mapOppBusDevToUnShare);
         OpporunityTriggerhandler.unShareOppRecords(mapOppBusDevToUnShare);
        
        testOpportunities[0].Probability = 90;
        update testOpportunities;
        Test.stopTest();

        // Perform assertions
        for(Opportunity opp : testOpportunities) {
            System.assertNotEquals(null, opp.recordTypeId);
           // System.assertNotEquals(null, opp.Salesperson_Code__c);
           // System.assertNotEquals(null, opp.Business_Development_Code__c);
        }
    }
}