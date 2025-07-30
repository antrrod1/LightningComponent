@isTest
private class LeadTriggerHandlerTest {
    
    @isTest
    static void testCheckActivityTask() {
        
        //Test Data Setup
         UMH_InterfaceExecutionSettings__c setupdataObj = new UMH_InterfaceExecutionSettings__c();
        setupdataObj.EnableApexTriggers__c = true;
        setupdataObj.EnableNavInterface__c = true;
        insert setupdataObj;
        
        // Create test Lead records
        List<Lead> testLeads = new List<Lead>();
        for(Integer i = 0; i < 3; i++) {           
            testLeads.add(new Lead(Company = 'JohnMiller', LastName = 'Mike', FirstName = 'Mike', Status = 'Qualified'));
        }
        insert testLeads;

        // Create test Task records
        List<Task> testTasks = new List<Task>();
        for(Integer i = 0; i < 2; i++) {
            testTasks.add(new Task(WhoId = testLeads[i].Id));
        }
        insert testTasks;

        Test.startTest();
        LeadTriggerHandler.checkActivityTask(testLeads);
        Test.stopTest();

        // Perform assertions
        for(Integer i = 0; i < 2; i++) {
           // System.assertEquals(true, LeadTriggerHandler.MapLeadtoTask.containsKey(testLeads[i].Id));
        }
       // System.assertEquals(false, LeadTriggerHandler.MapLeadtoTask.containsKey(testLeads[2].Id));
    }

    @isTest
    static void testPrepopulateFields() {
        // Create test Lead records
        List<Lead> testLeads = new List<Lead>();
        for(Integer i = 0; i < 3; i++) {
            testLeads.add(new Lead(
                OwnerId = UserInfo.getUserId(),
                Company = 'JohnMiller', LastName = 'Mike', FirstName = 'Mike',
                Business_Developer__c = UserInfo.getUserId(),
                LeadSource = 'Source'
            ));            
        }
        insert testLeads;
		update testLeads;
        Test.startTest();
        LeadTriggerHandler.prepopulateFields(testLeads);
        Test.stopTest();

        // Perform assertions
        for(Lead lead : testLeads) {
            System.assertNotEquals(null, lead.Lead_Source__c);
           // System.assertNotEquals(null, lead.Salesperson_Code__c);
            //System.assertNotEquals(null, lead.Business_Development_Code__c);
        }
    }
}