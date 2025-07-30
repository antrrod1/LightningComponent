@isTest
private class QuoteTriggerHelperTest {

    
     @isTest
    static void testUpdateQuote() {
        
          // Test data setup
        UMH_InterfaceExecutionSettings__c setupdataObj = new UMH_InterfaceExecutionSettings__c();
        setupdataObj.EnableApexTriggers__c = true;
        setupdataObj.EnableNavInterface__c = true;
        insert setupdataObj;
        
        // Create test Opportunities
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

        // Create test Quotes without existing primary quotes
        List<Quote> testQuotes = new List<Quote>();
        for(Opportunity opp : testOpportunities) {
            testQuotes.add(new Quote(Name = 'Test Quote Helper 3', OpportunityId = opp.Id));
        }

        Test.startTest();
        insert testQuotes;
        testQuotes[0].status = 'Won';
        update testQuotes;
        Test.stopTest();

    }
    
    @isTest
    static void testUpdateisPrimaryBeforeinsert() {
        // Create test Opportunities
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

        // Create test Quotes without existing primary quotes
        List<Quote> testQuotes = new List<Quote>();
        for(Opportunity opp : testOpportunities) {
            testQuotes.add(new Quote(Name = 'Test Quote Helper 3', OpportunityId = opp.Id));
        }

        Test.startTest();
        QuoteTriggerHelper.updateisPrimaryBeforeinsert(testQuotes);
        Test.stopTest();

        // Perform assertions
        for(Quote quote : testQuotes) {
            System.assertEquals(true, quote.Is_Primary__c);
        }
    }

    @isTest
    static void testUpdateisPrimaryAfterUpdate() {
        // Create test Opportunities
        List<Opportunity> testOpportunities = new List<Opportunity>();
        for(Integer i = 0; i < 3; i++) {
            
             Opportunity opportunityToCreate = new Opportunity();
            opportunityToCreate.StageName = 'Sourcing Demand';
            opportunityToCreate.CloseDate = Date.parse('01/01/2024');
            opportunityToCreate.Name = 'Test Opportunity Triggers Update'+ i +'.0';
            opportunityToCreate.Business_Developer__c = UserInfo.getUserId();
            opportunityToCreate.OwnerId = UserInfo.getUserId();
            opportunityToCreate.Opportunity_Type__c = 'Product';            
            
            testOpportunities.add(opportunityToCreate);
        }
        insert testOpportunities;

        // Create test Quotes
        List<Quote> testQuotes = new List<Quote>();
        for(Opportunity opp : testOpportunities) {
            testQuotes.add(new Quote(Name = 'Test Quote Helper 1.1', OpportunityId = opp.Id, Is_Primary__c = true, TotalAmountExclTax__c = 100));
            testQuotes.add(new Quote(Name = 'Test Quote Helper 1.2', OpportunityId = opp.Id, Is_Primary__c = true, TotalAmountExclTax__c = 100));
        }
        insert testQuotes;

        
        
        for(Quote quote : testQuotes) {
            quote.Is_Primary__c = false;
        }
        update testQuotes;

        Test.startTest();
        QuoteTriggerHelper.updateisPrimaryAfterUpdate(testQuotes);
        Test.stopTest();

        // Perform assertions
        List<Quote> updatedQuotes = [SELECT Is_Primary__c FROM Quote WHERE Id IN :testQuotes];
        System.assertEquals(6, updatedQuotes.size()); 
        for(Quote quote : updatedQuotes) {
            System.assertEquals(false, quote.Is_Primary__c);
        }

        // Perform assertions on Opportunities
        List<Opportunity> updatedOpportunities = [SELECT Amount FROM Opportunity WHERE Id = :testOpportunities[0].Id];
        //System.assertEquals(100, updatedOpportunities[0].TotalAmountExclTax__c);
    }

    @isTest
    static void testUpdateisPrimaryAfterInsert() {
        // Create test Opportunities
        List<Opportunity> testOpportunities = new List<Opportunity>();
        for(Integer i = 0; i < 3; i++) {
             Opportunity opportunityToCreate = new Opportunity();
            opportunityToCreate.StageName = 'Sourcing Demand';
            opportunityToCreate.CloseDate = Date.parse('01/01/2024');
            opportunityToCreate.Name = 'Test Opportunity Triggers  '+ i +'.0';
            opportunityToCreate.Business_Developer__c = UserInfo.getUserId();
            opportunityToCreate.OwnerId = UserInfo.getUserId();
            opportunityToCreate.Opportunity_Type__c = 'Product';
            
            testOpportunities.add(opportunityToCreate);
        }
        insert testOpportunities;

        // Create test Quotes with existing quotes
        List<Quote> testQuotes = new List<Quote>();
        for(Opportunity opp : testOpportunities) {
            testQuotes.add(new Quote(Name = 'Test Quote Helper 2.1',OpportunityId = opp.Id));
            testQuotes.add(new Quote(Name = 'Test Quote Helper 2.2',OpportunityId = opp.Id));
        }
        insert testQuotes;

        Test.startTest();
        QuoteTriggerHelper.updateisPrimaryAfterInsert(testQuotes);
        Test.stopTest();

        // Perform assertions
        List<Quote> updatedQuotes = [SELECT Is_Primary__c FROM Quote WHERE Id IN :testQuotes];
        for(Quote quote : updatedQuotes) {
            System.assertEquals(false, quote.Is_Primary__c);
        }
    }
    
    

}