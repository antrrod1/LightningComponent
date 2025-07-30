@isTest
private class NAV_SyncData_CalloutTest {

    @isTest
    static void testAccountPostRequest() {
        // Test data setup
        UMH_InterfaceExecutionSettings__c setupdataObj = new UMH_InterfaceExecutionSettings__c();
        setupdataObj.EnableApexTriggers__c = true;
        setupdataObj.EnableNavInterface__c = true;
        insert setupdataObj;
            
        Account acc = new Account(Name = 'Test Account', Credit_Limit__c = 1000, Salesperson_Code__c = 'SP123', Lead_Source__c = 'Web', BillingCity = 'Test City', BillingState = 'Test State', BillingCountry = 'Test Country', BillingPostalCode = '12345', Phone = '123-456-7890', Email__c = 'test@test.com', Customer_Price_Group__c = 'DIRECT', Type_of_Account__c = 'Direct', Payment_Terms_Code__c = 'Terms1', Territory_Code__c = 'Territory1');
        insert acc;
       
         Contact con = new Contact(LastName = 'Test', FirstName = 'Contact', AccountId = acc.Id, Title = 'Test Title', Type__c = 'Person', Salesperson_Code__c = 'SP123', MailingCity = 'Test City', MailingState = 'Test State', MailingCountry = 'Test Country', MailingPostalCode = '12345', Phone = '123-456-7890', MobilePhone = '123-456-7890', Email = 'test@test.com', Fax = '123-456-7890');
        insert con; 
        
        

        // Set up mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(acc.Id, 'Account'));

        Test.startTest();
        NAV_SyncData_Callout.AccountPostRequest(new Set<Id>{acc.Id});
        Test.stopTest();

        // Perform assertions
        // Add your assertions here
    }
    
     @isTest
    static void updateAccountContact() {
        // Test data setup
        UMH_InterfaceExecutionSettings__c setupdataObj = new UMH_InterfaceExecutionSettings__c();
        setupdataObj.EnableApexTriggers__c = true;
        setupdataObj.EnableNavInterface__c = true;
         insert setupdataObj;
            
        
        Account acc = new Account(Name = 'Test Account', Credit_Limit__c = 1000, Salesperson_Code__c = 'SP123', Lead_Source__c = 'Web',Type_of_Account__c = 'Direct', BillingCity = 'Test City', BillingState = 'Test State', BillingCountry = 'Test Country', BillingPostalCode = '12345', Phone = '123-456-7890', Email__c = 'test@test.com', Customer_Price_Group__c = 'DIRECT', Payment_Terms_Code__c = 'Terms1', Territory_Code__c = 'Territory1');
        insert acc;        
        
         Contact con = new Contact(LastName = 'Test', FirstName = 'Contact', AccountId = acc.Id, Title = 'Test Title', Type__c = 'Person', Salesperson_Code__c = 'SP123', MailingCity = 'Test City', MailingState = 'Test State', MailingCountry = 'Test Country', MailingPostalCode = '12345', Phone = '123-456-7890', MobilePhone = '123-456-7890', Email = 'test@test.com', Fax = '123-456-7890');
        insert con; 
        
         Test.startTest();
        NAV_SyncData_Callout.ContactAvoidRecursion = true;
         NAV_SyncData_Callout.AccountAvoidRecursion = true;
            acc.Name = 'Test Account 2';
            update acc;        
         	con.FirstName = 'Contact 2';
            update con;
        
          Test.stopTest();
       
    }


    @isTest
    static void testContactPostRequest() {
        
        UMH_InterfaceExecutionSettings__c setupdataObj = new UMH_InterfaceExecutionSettings__c();
        setupdataObj.EnableApexTriggers__c = true;
        setupdataObj.EnableNavInterface__c = true;
          insert setupdataObj;
            
         Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        Integer randomNumber = Integer.valueof((Math.random() * 10));
        String username1 = 'standardusertest1'+ randomNumber +'@testorg.com';
         String username2 = 'standardusertest2'+ randomNumber +'@testorg.com';
          User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName=username1);
         User u2 = new User(Alias = 'standt2', Email='standarduser2@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName=username2);
		insert u;
        insert u2;
        
         Account acc = new Account(Name = 'Test Account', Credit_Limit__c = 1000, Salesperson_Code__c = 'SP123', Lead_Source__c = 'Web', Type_of_Account__c = 'Direct', BillingCity = 'Test City', BillingState = 'Test State', BillingCountry = 'Test Country', BillingPostalCode = '12345', Phone = '123-456-7890', Email__c = 'test@test.com', Customer_Price_Group__c = 'DIRECT', Payment_Terms_Code__c = 'Terms1', Territory_Code__c = 'Territory1');
        insert acc;
        
        // Test data setup
        Contact con = new Contact(LastName = 'Test', FirstName = 'Contact',Business_Developer__c =  u.id, AccountId = acc.Id, Title = 'Test Title', Type__c = 'Person', Salesperson_Code__c = 'SP123', MailingCity = 'Test City', MailingState = 'Test State', MailingCountry = 'Test Country', MailingPostalCode = '12345', Phone = '123-456-7890', MobilePhone = '123-456-7890', Email = 'test@test.com', Fax = '123-456-7890');
        insert con;
        
        Contact con2 = new Contact(LastName = 'Test', FirstName = 'Contact2',Business_Developer__c =  u.id, AccountId = acc.Id, Title = 'Test Title', Type__c = 'Person', Salesperson_Code__c = 'SP123', MailingCity = 'Test City', MailingState = 'Test State', MailingCountry = 'Test Country', MailingPostalCode = '12345', Phone = '123-456-7890', MobilePhone = '123-456-7890', Email = 'test@test.com', Fax = '123-456-7890');
        insert con2;

        // Set up mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(con.Id, 'Contact'));

        Test.startTest();
        acc.Nav_id__c = '12345';
        update acc;
        NAV_SyncData_Callout.ContactPostRequest(new Set<Id>{con2.Id});
        NAV_SyncData_Callout.ContactAvoidRecursion = true;
        con.Business_Developer__c = u2.id;
        update con;
        Test.stopTest();

        // Perform assertions
        // Add your assertions here
    }
    
    
      static testMethod void testShipAddressPostRequest() {
        // Create test data
        
          UMH_InterfaceExecutionSettings__c setupdataObj = new UMH_InterfaceExecutionSettings__c();
        setupdataObj.EnableApexTriggers__c = true;
        setupdataObj.EnableNavInterface__c = true;
          insert setupdataObj;
            
           Account acc = new Account(Name = 'Test Account', Credit_Limit__c = 1000, Salesperson_Code__c = 'SP123', Lead_Source__c = 'Web',Type_of_Account__c = 'Direct',  BillingCity = 'Test City', BillingState = 'Test State', BillingCountry = 'Test Country', BillingPostalCode = '12345', Phone = '123-456-7890', Email__c = 'test@test.com', Customer_Price_Group__c = 'DIRECT', Payment_Terms_Code__c = 'Terms1', Territory_Code__c = 'Territory1');
        insert acc;
        
          Ship_To_Address__c shipObj = new Ship_To_Address__c();
          shipObj.Name = 'Test Account Ship 1';
          shipObj.Code__c = 'Test 123';
          shipObj.Account__c = acc.id;
          shipObj.Address__c = 'Test Address';
          shipObj.ZIP_Code__c = '123456';
          shipObj.ShiptoaddressUniqueKey__c='';
          insert shipObj;
        // Set up test data
        Set<Id> shipIdSet = new Set<Id>();
          shipIdSet.add(shipObj.id);
        
        // Set up mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(shipObj.Id, 'shiptoaddress'));
          
        // Call the method to be tested
        Test.startTest();
        NAV_SyncData_Callout.ShipAddressAvoidRecursion = true;
        update shipObj;       
        NAV_SyncData_Callout.ShipAddressPostRequest(shipIdSet);
        Test.stopTest();

        // Add assertions as needed to verify the behavior
        // For example:
        // System.assertEquals(expectedValue, actualValue);
    }
    
     static testMethod void testQuotePOSTRequest() {
        
         UMH_InterfaceExecutionSettings__c setupdataObj = new UMH_InterfaceExecutionSettings__c();
        setupdataObj.EnableApexTriggers__c = true;
        setupdataObj.EnableNavInterface__c = true;
         insert setupdataObj;
            
           Account acc = new Account(Name = 'Test Account', Credit_Limit__c = 1000, Salesperson_Code__c = 'SP123', Lead_Source__c = 'Web',Type_of_Account__c = 'Direct', BillingCity = 'Test City', BillingState = 'Test State', BillingCountry = 'Test Country', BillingPostalCode = '12345', Phone = '123-456-7890', Email__c = 'test@test.com', Customer_Price_Group__c = 'DIRECT', Payment_Terms_Code__c = 'Terms1', Territory_Code__c = 'Territory1');
        insert acc;
         
           List<Opportunity> testOpportunities = new List<Opportunity>();
        for(Integer i = 0; i < 3; i++) {
              Opportunity opportunityToCreate = new Opportunity();
            //Opportunity.AccountId = acc.id;
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

         insert testQuotes;

         NAV_SyncData_Callout.QuoteNavPostBody obj = new NAV_SyncData_Callout.QuoteNavPostBody();
            obj.Document_Type = '';
            obj.Sell_to_Customer_No = ''; obj.SF_Opportunity_No = ''; obj.Salesperson_Code = '';
            obj.Drawing_Reference = ''; obj.Lead_Source = ''; //obj.Ship_to_Code = '';
            obj.Business_Development_Code = ''; obj.Customer_Service_Code = ''; obj.Designer_Code = '';
            obj.Inside_Sales_Code = ''; obj.SalesForceID = '';
     
         // Set up mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(testQuotes[0].Id, 'Quote'));
          
       String jsonStr = JSON.serialize(obj);
         String accId = acc.Id;

        // Call the method to be tested
        Test.startTest();
         NAV_SyncData_Callout.QuoteResponseWrapper result = NAV_SyncData_Callout.QuotePOSTRequest(jsonStr, accId);
        Test.stopTest();

        // Add assertions as needed to verify the behavior
        // For example:
        // System.assertEquals(expectedValue, actualValue);
    }
    
    
   

    // Mock HTTP response generator class
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        
        Id  salesforceIdmock = null;
        String objectNamemock = '';
        private MockHttpResponseGenerator(Id salesforceId, String objectname){
            salesforceIdmock = salesforceId;  
            objectNamemock = objectname;
        }
        // Implement the respond method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a new HTTPResponse object
            HttpResponse res = new HttpResponse();
            // Set the status code of the response
            res.setStatusCode(200);
            // Set the response body
            res.setBody('{ "No": "C12345", "Code": "Test123",  "Name": "William Gleason","Object":"'+objectNamemock+'",  "SalesForceID": "'+ salesforceIdmock +'"}');
            //res.setBody('Mock response body');
            // Return the response
            return res;
        }
    }
}