public class NAV_SyncData_Callout {
    Public static Boolean AccountAvoidRecursion = true;
    Public static Boolean ContactAvoidRecursion = true;
    Public static Boolean ShipAddressAvoidRecursion = true;
    
    public class AccountNavPostBody {
        public  string Name {get; set;}
        public  Decimal Credit_Limit_LCY{get; set;}
        //public  string Blocked{get; set;}
        public  string Salesperson_Code {get; set;} 
        public  string Lead_Source{get; set;}
        public  string SalesForceID {get; set;}
        public string Address{get; set;}
        public  string Address_2{get; set;}
        public  string City{get; set;}
        public string County{get; set;}
        public  string Post_Code{get; set;}
        public  string Country_Region_Code{get; set;}
        public  string Phone_No{get; set;}
        public string Billing_Mobile_Phone{get; set;}
        public  string E_Mail{get; set;}
        //public  string Customer_Price_Group{get; set;}
       // public  string Payment_Terms_Code{get; set;}
        public  string Territory_Code{get; set;}
        public  string Customer_Posting_Group{get; set;}
        public  string SalesforceAccountType{get; set;}
        
    }
    
    
    
    @future(callout = true)
    public static void AccountPostRequest(Set<id> AccIdSet) {       
        
        
        Boolean isAccountCreate = false;       
        
        List<Account> AccountsToUpdate = new List<Account>();
        Set<Id> AccountsIdsToUpate = new Set<Id>();
        List<Contact> ContactsforAccount = new List<Contact>();
        
        Map<String , String> MapCountrytoRegion = new Map<String , String>();
        for( Country_Regioncodes__c  custObj: [Select id,Country_Name__c,Region_code__c from Country_Regioncodes__c]){
            MapCountrytoRegion.put(custObj.Country_Name__c , custObj.Region_code__c);
        }
        
        NAV_InterfaceLogs__c interfaceLog = new NAV_InterfaceLogs__c();
        List<NAV_APiInterfaceSettings__mdt> interfaceSettings = [Select Id,EndPoint__c,Passkey__c,UserName__c  from NAV_APiInterfaceSettings__mdt where MasterLabel = :'NAV_APIDetails' LIMIT 1];
        UMH_InterfaceExecutionSettings__c interfaceExcSettings = UMH_InterfaceExecutionSettings__c.getInstance(); 
        if (interfaceSettings != null && interfaceSettings.size() == 1 && interfaceExcSettings.EnableNavInterface__c) {
            
            string username = interfaceSettings[0].UserName__c; 
            string password =interfaceSettings[0].Passkey__c; 
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            String EndPointBaseUrl = interfaceSettings[0].EndPoint__c;
            
            for (Account Acc: [SELECT id,Name,Credit_Limit__c, Salesperson_Code__c,Lead_Source__c, Address_2__c, ShippingCity, ShippingCountry,ShippingPostalCode,BillingCity,BillingCountry,BillingPostalCode,BillingState,BillingStreet,BillingAddress, Phone, Email__c, Customer_Price_Group__c,Payment_Terms_Code__c,Territory_Code__c,Type,Type_of_Account__c,NAV_ID__c,(SELECT Id,Title,Name,FirstName,LastName,Type__c,Account.Nav_id__c ,Salesperson_Code__c,MailingAddress,MailingStreet,MailingState,MailingPostalCode,MailingCity,MailingCountry,Phone,MobilePhone,Email,Fax,NAV_ID__c,AccountId from contacts)  from Account where id IN : AccIdSet]) {
                for(contact con: acc.contacts){
                    ContactsforAccount.add(con);
                }
                
                
                HttpRequest request = new HttpRequest();
                request.setMethod('POST');     
                request.setHeader('Authorization', authorizationHeader); 
                request.setHeader('Content-Type', 'application/json; charset=UTF-8');
                
                if(Acc.NAV_ID__c !=null && Acc.NAV_ID__c !=''){                  
                    String EndPoint = EndPointBaseUrl+ '/Company(\'United%20Material%20Handling%2C%20Inc\')/Customers(' + '\'' + Acc.NAV_ID__c + '\''+ ')'; 
                    request.setEndpoint(EndPoint);
                    request.setHeader('if-Match', '*');    
                    request.setMethod('PATCH');                   
                }else{                  
                    String EndPoint = EndPointBaseUrl+'/Company(\'United%20Material%20Handling%2C%20Inc\')/Customers';
                    request.setEndpoint(EndPoint);
                    request.setMethod('POST'); 
                    isAccountCreate = true;
                }
                
                
                AccountNavPostBody bodyReq = new AccountNavPostBody();
                bodyReq.Name= Acc.Name;
                bodyReq.Credit_Limit_LCY=  Acc.Credit_Limit__c;
                bodyReq.Salesperson_Code= Acc.Salesperson_Code__c;
                bodyReq.Lead_Source = Acc.Lead_Source__c;
                bodyReq.SalesForceID = Acc.Id;
                
                if(Acc.BillingCity!=null && Acc.BillingState!=null && Acc.BillingCountry!=null ){
                    if(Acc.BillingStreet==null){Acc.BillingStreet= '';}
                    if(Acc.BillingPostalCode==null){Acc.BillingPostalCode= '';}
                    bodyReq.Address = Acc.BillingStreet;                       
                }
                
                // bodyReq.Address_2 = Acc.BillingStreet;
                bodyReq.City = Acc.BillingCity;
                bodyReq.County = Acc.BillingState;	
                bodyReq.Post_Code = Acc.BillingPostalCode;
                if(MapCountrytoRegion.containskey(Acc.BillingCountry)){
                    bodyReq.Country_Region_Code = MapCountrytoRegion.get(Acc.BillingCountry);
                }
                bodyReq.Phone_No = Acc.Phone;
                //bodyReq.Billing_Mobile_Phone = Acc.Lead_Source__c;
                bodyReq.E_Mail = Acc.Email__c;
                //bodyReq.Customer_Price_Group = Acc.Customer_Price_Group__c;
                //bodyReq.Payment_Terms_Code = Acc.Payment_Terms_Code__c;
                bodyReq.Territory_Code = Acc.Territory_Code__c;
                bodyReq.Customer_Posting_Group = 'CUST';
                bodyReq.SalesforceAccountType = Acc.Type_of_Account__c;
                
                
                request.setBody(JSON.serialize(bodyReq));
                
                //GEt Response from API          
                HttpResponse response = new HttpResponse();
                Http http = new Http();
                response = http.send(request);
                
                if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                    
                    System.debug('Response AccResult');                   
                    String respBody = '';
                    respBody = response.getBody();
                    system.debug(respBody);  
                    
                   try{
                    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(respBody);
                    system.debug('**responseMap= '+responseMap);                     
                            if(responseMap != null){                             
                                //Update Quote record with NAV Quote Id
                                if((String)responseMap.get('No') != null){
                                    Account AccObj = new Account();
                                    AccObj.Id =  (String)responseMap.get('SalesForceID');
                                    AccObj.NAV_ID__c = (String)responseMap.get('No');
                                    AccountsToUpdate.add(AccObj);
                                    AccountsIdsToUpate.add(AccObj.Id);
                                }
                                
                            }else{
                                interfaceLog.Callout_Status__c = 'Exception on desrialize response';
                            }
                         }catch(JSONException e){
                 		  interfaceLog.Callout_Status__c = 'Exception on desrialize response';                		               
                    	interfaceLog.Status__c = 'Failure';                    
                        System.debug(e.getMessage());
                   }
                    
                }else{
                    interfaceLog.Status__c = 'Failure';
                }
                
                interfaceLog.Status_Code__c = String.valueOf(response.getStatusCode());
                interfaceLog.Callout_Status__c = response.getStatus();
                interfaceLog.Full_Response__c = String.valueOf(response);
                interfaceLog.Sync_Object__c = 'Account';
                interfaceLog.Account__c = Acc.Id;
                interfaceLog.Start_Time__c = system.now();
                interfaceLog.End_Time__c = system.now();   
               
                
            }
            
            
            try{
                
                
                //update AccountsToUpate;
                String ContactReturnMessage;
                if(AccountsToUpdate.size()>0){
                    String AccNAVID = AccountsToUpdate[0].NAV_ID__c;
                    ContactReturnMessage = NAV_SyncData_Callout.ContactPostRequestAfterAccount(ContactsforAccount, AccNAVID, AccountsToUpdate, isAccountCreate);
                    if(ContactReturnMessage!=''){
                        if(interfaceLog!=null){
                            insert interfaceLog;
                        } 
                    }
                    
                }else{
                    if(interfaceLog!=null){
                        insert interfaceLog;
                    } 
                }  
                
                
                
            }
            catch(exception e){
                system.debug('Exception while updating Account'+e);
                if(interfaceLog!=null){
                    interfaceLog.Status__c = 'Failure';
                    interfaceLog.Full_Response__c = 'Exception after doing contact callout from account' + e;
                    insert interfaceLog;
                }
            }
            //   return 'Success 2';
        }
        
    }
    
    
    //////////////////////////////////////////////////////////////
    //
    public class ContactNavPostBody {
        public  string Job_Title{get; set;}
        public  string Name{get; set;}
        public  string First_Name{get; set;}
        public  string Last_Name{get; set;}    
        public  string SalesForceID{get; set;}   
        
        //public  string Blocked{get; set;}
        public  string Type {get; set;} 
        public  string Salesperson_Code{get; set;}
        public  string Address {get; set;}
        public  string Address_2{get; set;}
        public  string Post_Code{get; set;}
        public string City{get; set;}
        public  string County{get; set;}
        public  string Country_Region_Code{get; set;}
        public  string Phone_No{get; set;}
        public string Mobile_Phone_No{get; set;}
        public  string E_Mail{get; set;}
        public  string Fax_No{get; set;}        
        public  string Customer_No{get; set;}
        
    }
    
    
    @future(callout = true)
    public static void ContactPostRequest(Set <id> ConIdSet) {     
        
        
        List<Contact> ContactsToUpdate = new List<Contact>();
        NAV_InterfaceLogs__c interfaceLog = new NAV_InterfaceLogs__c();
        
        Set<Id> acctIdSet = new Set<Id>();
        Map<Id,Integer> mapAcctoContactCount = new Map<Id,Integer> ();
        for (Contact Con: [SELECT Id,Account.Nav_id__c ,AccountId  from Contact where id in: ConIdSet]) {
           acctIdSet.add(Con.AccountId);
        }
         for (AggregateResult ar : [SELECT AccountId AcctId, Count(id) ContactCount FROM Contact
                                   WHERE AccountId in: acctIdSet GROUP BY AccountId]){                                       
         	mapAcctoContactCount.put((Id) ar.get('AcctId'), Integer.valueOf(ar.get('ContactCount')));
		}        
        
            
        
        if (ConIdSet.size()>0) {
            List<NAV_APiInterfaceSettings__mdt> interfaceSettings = [Select Id,EndPoint__c,Passkey__c,UserName__c  from NAV_APiInterfaceSettings__mdt where MasterLabel = :'NAV_APIDetails' LIMIT 1];
            UMH_InterfaceExecutionSettings__c interfaceExcSettings = UMH_InterfaceExecutionSettings__c.getInstance(); 
            if (interfaceSettings != null && interfaceSettings.size() == 1 && interfaceExcSettings.EnableNavInterface__c) {
                
                string username = interfaceSettings[0].UserName__c; 
                string password =interfaceSettings[0].Passkey__c; 
                Blob headerValue = Blob.valueOf(username + ':' + password);
                String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                String EndPointBaseUrl = interfaceSettings[0].EndPoint__c;
                
                for (Contact Con: [SELECT Id,Title,Name,FirstName,LastName,Type__c,Account.Nav_id__c ,Salesperson_Code__c,MailingAddress,MailingStreet,MailingState,MailingPostalCode,MailingCity,MailingCountry,Phone,MobilePhone,Email,Fax,NAV_ID__c,AccountId  from Contact where id in: ConIdSet]) {
                    HttpRequest request = new HttpRequest();
                    request.setMethod('POST');     
                    request.setHeader('Authorization', authorizationHeader); 
                    request.setHeader('Content-Type', 'application/json; charset=UTF-8');
                    
                    if(Con.NAV_ID__c !=null && Con.NAV_ID__c !='' ){ //If contact update
                        String EndPoint = EndPointBaseUrl+ '/Company(\'United%20Material%20Handling%2C%20Inc\')/Contacts(' + '\'' + Con.NAV_ID__c + '\''+ ')';
                        request.setEndpoint(EndPoint);  
                        request.setMethod('PATCH');   
                        request.setHeader('if-Match', '*');    
                    }else{ //If contact insert
                        if(mapAcctoContactCount.containsKey(Con.AccountId)){ 
                            if(mapAcctoContactCount.get(Con.AccountId)>1){ // Insert only if its account has more than 1 contact
                                String EndPoint = EndPointBaseUrl+ '/Company(\'United%20Material%20Handling%2C%20Inc\')/Contacts';                                  
                                request.setEndpoint(EndPoint);
                                request.setMethod('POST');
                            }else{
                                return ;
                            }
                        }
                       
                    }
                    
                 if(Con.Account.Nav_id__c !='' && Con.Account.Nav_id__c !=null) {
                    ContactNavPostBody bodyReq = new ContactNavPostBody();
                    bodyReq.Job_Title= Con.Title;
                    bodyReq.Name=  Con.Name;
                    bodyReq.First_Name=  Con.FirstName;
                    bodyReq.Last_Name=  Con.LastName;
                    bodyReq.Type=  'Person';
                    bodyReq.Salesperson_Code= Con.Salesperson_Code__c;
                    if(Con.MailingCity!=null && Con.MailingState!=null &&  Con.MailingCountry!=null){
                        if(Con.MailingStreet==null){Con.MailingStreet= '';}
                        if(Con.MailingPostalCode==null){Con.MailingPostalCode= '';}
                        bodyReq.Address = Con.MailingStreet;
                        
                    }
                    
                    bodyReq.SalesForceID = Con.Id;
                    //bodyReq.Address_2 = Con.Address_2__c;
                    bodyReq.City = Con.MailingCity;
                    bodyReq.County = Con.MailingState;
                    bodyReq.Post_Code = Con.MailingPostalCode;
                    //bodyReq.Country_Region_Code = Acc.ShippingPostalCode;
                    bodyReq.Phone_No = Con.Phone;
                    bodyReq.Mobile_Phone_No = Con.MobilePhone;
                    bodyReq.E_Mail = Con.Email;
                    bodyReq.Fax_No = Con.Fax;
                    bodyReq.Customer_No = Con.Account.Nav_id__c;
                    //bodyReq.Company_No = 'C01990';
                    
                    request.setBody(JSON.serialize(bodyReq));
                    
                    
                    HttpResponse response = new HttpResponse();
                    Http http = new Http();
                    response = http.send(request);
                    System.debug('response.getStatusCode()');
                    System.debug(response.getStatusCode());
                    System.debug(response);
                    
                    
                    if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                        
                        System.debug('Response ConResult');                   
                        String respBody = '';
                        respBody = response.getBody();
                        system.debug(respBody);                          
                        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(respBody);
                        system.debug('**responseMap= '+responseMap);
                        if(responseMap != null){                             
                            //Update Quote record with NAV Quote Id
                            if((String)responseMap.get('No') != null){                                 
                                Contact ConObj = new Contact();
                                ConObj.Id = (String)responseMap.get('SalesForceID');
                                ConObj.NAV_ID__c = (String)responseMap.get('No');
                                ContactsToUpdate.add(ConObj);
                            }
                            
                        }else{
                            interfaceLog.Callout_Status__c = 'Exception on desrialize response';
                        }
                        
                    }else{
                        interfaceLog.Status__c = 'Failure';
                    }
                    
                    interfaceLog.Status_Code__c = String.valueOf(response.getStatusCode());
                    interfaceLog.Callout_Status__c = response.getStatus();
                    interfaceLog.Full_Response__c = String.valueOf(response);
                    interfaceLog.Sync_Object__c = 'Contact';
                    interfaceLog.Contact__c = Con.Id;
                    interfaceLog.Start_Time__c = system.now();
                    interfaceLog.End_Time__c = system.now(); 
                }
                    
                }
                
                                
                    try{
                         if (ContactsToUpdate.size()>0) { 
                              update ContactsToUpdate;
                         }
                        if(interfaceLog!=null){
                            insert interfaceLog;
                        } 
                    }
                    catch(exception e){
                        system.debug('Exception while updating Contact'+e);
                        if(interfaceLog!=null){
                            interfaceLog.Status__c = 'Failure';
                            interfaceLog.Full_Response__c = 'Exception after doing contact callout from Contact update' + e;
                            insert interfaceLog;
                        }
                    }
                
            }
        }
        
    }
    
    
    public static String ContactPostRequestAfterAccount(list<Contact> ContactsforAccount, String AccNAVID, List<Account> AccountsToUpdate, Boolean isAccountCreate) {
        
        
        List<Contact> ContactsToUpdate = new List<Contact>();
        NAV_InterfaceLogs__c interfaceLog = new NAV_InterfaceLogs__c();
        
        List<NAV_APiInterfaceSettings__mdt> interfaceSettings = [Select Id,EndPoint__c,Passkey__c,UserName__c  from NAV_APiInterfaceSettings__mdt where MasterLabel = :'NAV_APIDetails' LIMIT 1];
         UMH_InterfaceExecutionSettings__c interfaceExcSettings = UMH_InterfaceExecutionSettings__c.getInstance(); 
        if (interfaceSettings != null && interfaceSettings.size() == 1 && interfaceExcSettings.EnableNavInterface__c) {
            
            string username = interfaceSettings[0].UserName__c; 
            string password =interfaceSettings[0].Passkey__c; 
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            String EndPointBaseUrl = interfaceSettings[0].EndPoint__c;
            
            
            if (ContactsforAccount.size()>0) {
                for (Contact Con: ContactsforAccount) {
                    
                    HttpRequest request = new HttpRequest();       			  
                    request.setHeader('Authorization', authorizationHeader);
                    request.setHeader('Content-Type', 'application/json; charset=UTF-8');  
                    
                    if(Con.NAV_ID__c !=null && Con.NAV_ID__c !='' && !isAccountCreate){
                        String EndPoint = EndPointBaseUrl+ '/Company(\'United%20Material%20Handling%2C%20Inc\')/Contacts(' + '\'' + Con.NAV_ID__c + '\''+ ')'; 
                        //String EndPoint = 'https://sf-121593.dynamicstocloud.com:1103/ST-140283/ODataV4/Company(\'United%20Material%20Handling%2C%20Inc\')/Contacts(' + '\'' + Con.NAV_ID__c + '\''+ ')'; 
                        request.setEndpoint(EndPoint);  
                        request.setMethod('PATCH');   
                        request.setHeader('if-Match', '*');    
                    }else{
                        String EndPoint = EndPointBaseUrl+ '/Company(\'United%20Material%20Handling%2C%20Inc\')/Contacts';                                  
                        request.setEndpoint(EndPoint);  
                        //request.setEndpoint('https://sf-121593.dynamicstocloud.com:1103/ST-140283/ODataV4/Company(\'United%20Material%20Handling%2C%20Inc\')/Contacts');
                        request.setMethod('POST');    
                    }
                    
                    
                    ContactNavPostBody bodyReq = new ContactNavPostBody();
                    bodyReq.Job_Title= Con.Title;
                    bodyReq.Name=  Con.Name;
                    bodyReq.First_Name=  Con.FirstName;
                    bodyReq.Last_Name=  Con.LastName;
                    bodyReq.Type=  'Person';
                    bodyReq.Salesperson_Code= Con.Salesperson_Code__c;
                    if(Con.MailingCity!=null && Con.MailingState!=null &&  Con.MailingCountry!=null){
                        if(Con.MailingStreet==null){Con.MailingStreet= '';}
                        if(Con.MailingPostalCode==null){Con.MailingPostalCode= '';}                    
                       // bodyReq.Address = Con.MailingStreet+ Con.MailingCity + Con.MailingState + Con.MailingCountry +Con.MailingPostalCode;
                        bodyReq.Address = Con.MailingStreet;
                    }
                    
                    bodyReq.SalesForceID = Con.Id;
                    //bodyReq.Address_2 = Con.Address_2__c;
                    bodyReq.City = Con.MailingCity;
                    bodyReq.County = Con.MailingState;
                    bodyReq.Post_Code = Con.MailingPostalCode;
                    //bodyReq.Country_Region_Code = Acc.ShippingPostalCode;
                    bodyReq.Phone_No = Con.Phone;
                    bodyReq.Mobile_Phone_No = Con.MobilePhone;
                    bodyReq.E_Mail = Con.Email;
                    bodyReq.Fax_No = Con.Fax;
                    bodyReq.Customer_No = AccNAVID;
                    //bodyReq.Company_No = 'C01990';
                    
                    request.setBody(JSON.serialize(bodyReq));
                    system.debug(bodyReq);
                    system.debug('Contact Body');
                    system.debug(JSON.serialize(bodyReq));
                    
                    HttpResponse response = new HttpResponse();
                    Http http = new Http();
                    response = http.send(request);
                    System.debug('response.getStatusCode()');
                    System.debug(response.getStatusCode());
                    System.debug(response);
                    /* if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
ConResult = Nav_ContactJson2Apex.parse(response.getBody()); 
System.debug(ConResult);

}*/
                    
                    if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                        // AccResult = Nav_ContactJson2Apex.parse(response.getBody()); 
                        System.debug('Response ConResult');                   
                        String respBody = '';
                        respBody = response.getBody();
                        system.debug(respBody);                          
                        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(respBody);
                        system.debug('**responseMap= '+responseMap);
                        if(responseMap != null){                             
                            //Update Quote record with NAV Quote Id
                            if((String)responseMap.get('No') != null){                                 
                                Contact ConObj = new Contact();
                                ConObj.Id = (String)responseMap.get('SalesForceID');
                                ConObj.NAV_ID__c = (String)responseMap.get('No');
                                ContactsToUpdate.add(ConObj);
                            }
                            
                        }else{
                            interfaceLog.Callout_Status__c = 'Exception on desrialize response';
                        }                              
                        
                    }else{
                        interfaceLog.Status__c = 'Failure';
                    }
                    
                    
                    interfaceLog.Status_Code__c = String.valueOf(response.getStatusCode());
                    interfaceLog.Callout_Status__c = response.getStatus();
                    interfaceLog.Full_Response__c = String.valueOf(response);
                    interfaceLog.Sync_Object__c = 'Contact';
                    interfaceLog.Contact__c = Con.Id;
                    interfaceLog.Start_Time__c = system.now();
                    interfaceLog.End_Time__c = system.now();                        
                    
                    
                    
                }
                
                
                
                if (AccountsToUpdate.size()>0 ) {                  
                    try{
                        update AccountsToUpdate;
                        if (ContactsToUpdate.size()>0 ) {  
                            update ContactsToUpdate;
                            if(interfaceLog!=null){
                                insert interfaceLog;
                            } 
                            
                            return 'Contact Success';
                        }else{
                            if(interfaceLog!=null){
                                insert interfaceLog;
                            } 
                        }
                    }
                    catch(exception e){
                        system.debug('Exception while updating Account & Contact'+e);
                        if(interfaceLog!=null){
                            interfaceLog.Status__c = 'Failure';
                            interfaceLog.Full_Response__c = 'Exception while DML Account & Contact ' + e;
                            insert interfaceLog;
                        } 
                    }
                }  else if(ContactsToUpdate.size()>0){
                    try{                       
                        update ContactsToUpdate;
                        if(interfaceLog!=null){
                            insert interfaceLog;
                        } 
                        
                        return 'Contact Success';
                        
                    }
                    catch(exception e){
                        system.debug('Exception while updating Account & Contact'+e);
                        if(interfaceLog!=null){
                            interfaceLog.Status__c = 'Failure';
                            interfaceLog.Full_Response__c = 'Exception while DML Account & Contact ' + e;
                            insert interfaceLog;
                        }
                    }
                    
                }   
                
                
            }
            
        }
        return 'Contact Generic Output';
    }
    
    
   
    
    //////////////////////////////////////////////////////////////
    //
    public class ShipAddressNavPostBody {
        
        public  string Name{get; set;}
        public  string Customer_No{get; set;}
        public  string Address{get; set;}
        public  string Address_2{get; set;}
        public  string City{get; set;}    
        public  string SalesForceID{get; set;}   
        
        //public  string Blocked{get; set;}
        public  string County {get; set;} 
        public  string Post_Code{get; set;}
        
        public  string Country_Region_Code{get; set;}
        public  string Phone_No{get; set;}
        public  string E_Mail{get; set;}
        public  string Fax_No{get; set;} 
        public  string Code{get; set;} 
        
    }
    
    
    @future(callout = true)
    public static void ShipAddressPostRequest(Set <id> shipIdSet) {
        
        
        List<Ship_To_Address__c> shipToAddressToUpdate = new List<Ship_To_Address__c>();
        
        NAV_InterfaceLogs__c interfaceLog = new NAV_InterfaceLogs__c();
        List<NAV_APiInterfaceSettings__mdt> interfaceSettings = [Select Id,EndPoint__c,Passkey__c,UserName__c  from NAV_APiInterfaceSettings__mdt where MasterLabel = :'NAV_APIDetails' LIMIT 1];
         UMH_InterfaceExecutionSettings__c interfaceExcSettings = UMH_InterfaceExecutionSettings__c.getInstance(); 
        if (interfaceSettings != null && interfaceSettings.size() == 1 && interfaceExcSettings.EnableNavInterface__c) {
            
            string username = interfaceSettings[0].UserName__c; 
            string password =interfaceSettings[0].Passkey__c; 
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            String EndPointBaseUrl = interfaceSettings[0].EndPoint__c;
            
            
            if (shipIdSet.size()>0) {
                for (Ship_To_Address__c shipObj: [SELECT  Id,Name, Account__c, Address_2__c, Address__c, City__c,Country_Region_Code__c, Code__c, Ship_To_ID__c, State__c, ZIP_Code__c, Last_Sync_By__c, NAV_Customer_No__c, NAV_Id__c, Email__c, Phone__c, Fax__c,Tax_Area_Code__c   from Ship_To_Address__c where id in: shipIdSet]) {
                    
                    HttpRequest request = new HttpRequest();
                    request.setMethod('POST');     
                    request.setHeader('Authorization', authorizationHeader); 
                    request.setHeader('Content-Type', 'application/json; charset=UTF-8');
                    
                    if(shipObj.NAV_ID__c !=null && shipObj.NAV_ID__c !=''){
                        //String EndPoint = 'https://sf-121593.dynamicstocloud.com:1103/ST-140283/ODataV4/Company(\'United%20Material%20Handling%2C%20Inc\')/ShipToAdd(' + '\'' + shipObj.NAV_Customer_No__c + '\''  + '\'' + shipObj.NAV_ID__c + '\'' + ')'; 
                        String EndPoint = EndPointBaseUrl+ '/Company(\'United%20Material%20Handling%2C%20Inc\')/ShipToAdd(' + '\'' + shipObj.NAV_Customer_No__c + '\''  + '\'' + shipObj.NAV_ID__c + '\'' + ')'; 
                        request.setEndpoint(EndPoint);  
                        request.setMethod('PATCH');   
                        request.setHeader('if-Match', '*');    
                    }else{
                        //request.setEndpoint('https://sf-121593.dynamicstocloud.com:1103/ST-140283/ODataV4/Company(\'United%20Material%20Handling%2C%20Inc\')/ShipToAdd');
                        String EndPoint = EndPointBaseUrl+'/Company(\'United%20Material%20Handling%2C%20Inc\')/ShipToAdd';
                        request.setEndpoint(EndPoint);  
                        request.setMethod('POST');    
                    }
                    
                    
                    ShipAddressNavPostBody bodyReq = new ShipAddressNavPostBody();
                    bodyReq.SalesForceID = shipObj.Id;
                    bodyReq.Name=  shipObj.Name;
                    bodyReq.Code = shipObj.Code__c;
                    bodyReq.Customer_No=  shipObj.NAV_Customer_No__c;
                    bodyReq.Address=  shipObj.Address__c;
                    bodyReq.Address_2=  shipObj.Address_2__c;
                    bodyReq.City=  shipObj.City__c;
                    bodyReq.County=  shipObj.State__c;
                    bodyReq.Country_Region_Code=  shipObj.Country_Region_Code__c;
                    bodyReq.Phone_No=  shipObj.Phone__c;
                    bodyReq.E_Mail=  shipObj.Email__c;
                    bodyReq.Fax_No=  shipObj.Fax__c;
                    bodyReq.Post_Code = shipObj.ZIP_Code__c;
                    
                    request.setBody(JSON.serialize(bodyReq));
                    system.debug(bodyReq);
                    
                    HttpResponse response = new HttpResponse();
                    Http http = new Http();
                    response = http.send(request);
                    /*System.debug('response.getStatusCode()');
System.debug(response.getStatusCode());
System.debug(response);
System.debug(response.getBody());
System.debug(response.getStatus());*/
                    if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                        String respBody = '';
                        respBody = response.getBody();
                        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(respBody);
                        
                        if(responseMap != null){                             
                            //Update Shiptoaddress record with NAV Quote Id
                            if((String)responseMap.get('Code') != null){
                                Ship_To_Address__c shipUpdateObj = new Ship_To_Address__c();
                                shipUpdateObj.Id = (String)responseMap.get('SalesForceID');
                                shipUpdateObj.NAV_ID__c = (String)responseMap.get('Code');
                                shipToAddressToUpdate.add(shipUpdateObj);
                            }                  
                        }else{
                            interfaceLog.Callout_Status__c = 'Exception on desrialize response';
                        }
                        
                        
                    }else{
                        interfaceLog.Status__c = 'Failure';
                    }
                    
                    interfaceLog.Status_Code__c = String.valueOf(response.getStatusCode());
                    interfaceLog.Callout_Status__c = response.getStatus();
                    interfaceLog.Full_Response__c = String.valueOf(response);
                    interfaceLog.Sync_Object__c = 'ShipToAddress';
                    interfaceLog.Ship_To_Address__c = shipObj.Id;
                    interfaceLog.Start_Time__c = system.now();
                    interfaceLog.End_Time__c = system.now(); 
                    
                    
                    try{                 
                        
                        if(shipToAddressToUpdate.size()>0){
                            update shipToAddressToUpdate;                             
                        } 
                        if(interfaceLog!=null){
                                insert interfaceLog;
                            }                   
                        
                    }
                    catch(exception e){
                        system.debug('Exception while updating shiptoaddress'+e);
                        if(interfaceLog!=null){
                            interfaceLog.Status__c = 'Failure';
                            interfaceLog.Full_Response__c = 'Exception after doing shiptoaddress callout ' + e;
                            insert interfaceLog;
                        }
                    }         
                    
                    
                }
            }
            
        }
    }


     @AuraEnabled
    public static QuoteResponseWrapper QuotePOSTRequest(String navbodyparam, String AccId ) {
      
        List<Quote> QuotesToUpdate = new List<Quote>();
        Id QuoteId;
       NAV_InterfaceLogs__c interfaceLog = new NAV_InterfaceLogs__c();
       QuoteResponseWrapper result = new QuoteResponseWrapper();
        List<NAV_APiInterfaceSettings__mdt> interfaceSettings = [Select Id,EndPoint__c,Passkey__c,UserName__c  from NAV_APiInterfaceSettings__mdt where MasterLabel = :'NAV_APIDetails' LIMIT 1];
         UMH_InterfaceExecutionSettings__c interfaceExcSettings = UMH_InterfaceExecutionSettings__c.getInstance(); 
        if (interfaceSettings != null && interfaceSettings.size() == 1 && interfaceExcSettings.EnableNavInterface__c) {
            
            string username = interfaceSettings[0].UserName__c; 
            string password =interfaceSettings[0].Passkey__c; 
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            String EndPointBaseUrl = interfaceSettings[0].EndPoint__c;
               
        System.debug('navbodyparam');
         System.debug(navbodyparam);
         
         String jsonString = navbodyparam; 
       // String jsonString = JSON.serialize(navbodyparam); 
        System.debug('jsonString');
        System.debug(jsonString);
       
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');     
        request.setHeader('Authorization', authorizationHeader);                
       // request.setEndpoint('https://sf-121593.dynamicstocloud.com:1103/ST-140283/ODataV4/Company(\'United%20Material%20Handling%2C%20Inc\')/Quotes');
        String EndPoint = EndPointBaseUrl+ '/Company(\'United%20Material%20Handling%2C%20Inc\')/Quotes'; 
        request.setEndpoint(EndPoint);       
       
        request.setHeader('Content-Type', 'application/json; charset=UTF-8');        
        request.setBody(jsonString);
        
       
        HttpResponse response = new HttpResponse();
        Http http = new Http();
        response = http.send(request);
             System.debug('response.getStatusCode()');
             System.debug(response.getStatusCode());

          if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                 String respBody = '';
                 respBody = response.getBody();
                 Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(respBody);
                 if(responseMap != null){                             
                        //Update Quote record with NAV Quote Id
                        if((String)responseMap.get('No') != null){
                             Quote quoteObj = new Quote(); 
                             QuoteId = (String)responseMap.get('SalesForceID');
                             quoteObj.Id =  (String)responseMap.get('SalesForceID');
                             quoteObj.NAV_Quote_ID__c = (String)responseMap.get('No');
                             QuotesToUpdate.add(quoteObj);

                             result.No = (String)responseMap.get('No');
                             result.Statuscode = response.getStatusCode();
                        }

                     }else{
                        interfaceLog.Callout_Status__c = 'Exception on desrialize response';
                    }
             }else{
                    result.Statuscode = response.getStatusCode();
                    interfaceLog.Status__c = 'Failure';
                }
    
                interfaceLog.Status_Code__c = String.valueOf(response.getStatusCode());
                interfaceLog.Callout_Status__c = response.getStatus();
                interfaceLog.Full_Response__c = String.valueOf(response);
                interfaceLog.Sync_Object__c = 'Quote';
                if(QuoteId!=null){
                     interfaceLog.Quote__c = QuoteId;
                }
                interfaceLog.Start_Time__c = system.now();
                interfaceLog.End_Time__c = system.now();  


                 try{
                         if (QuotesToUpdate.size()>0) { 
                              update QuotesToUpdate;
                         }
                        if(interfaceLog!=null){
                            insert interfaceLog;
                        } 
                    }
                    catch(exception e){
                        system.debug('Exception while Creating Quote'+e);
                        if(interfaceLog!=null){
                            interfaceLog.Status__c = 'Failure';
                            interfaceLog.Full_Response__c = 'Exception after doing contact callout from Quote creation' + e;
                            insert interfaceLog;
                        }
                    }                      
                     
        }   
        return result; 
        
    }



     public class QuoteResponseWrapper{
		@AuraEnabled public String No{get;set;}
		@AuraEnabled public Integer Statuscode {get;set;}
   }

    

   public class QuoteNavPostBody {
       
        @AuraEnabled public  string Business_Development_Code {get; set;}
        @AuraEnabled public  string Customer_Service_Code {get; set;}
        @AuraEnabled public string Designer_Code {get; set;}
         @AuraEnabled public  string Drawing_Reference {get; set;}
        @AuraEnabled public  string Inside_Sales_Code {get; set;}
         @AuraEnabled public  string Lead_Source {get; set;}
         @AuraEnabled public  string Salesperson_Code {get; set;} 
         @AuraEnabled public string ShipToSalesForceID {get; set;}
         @AuraEnabled public  string WC_Sell_to_Contact_No {get; set;}
        @AuraEnabled public  string SalesForceID {get; set;}
          @AuraEnabled public  string SF_Opportunity_No {get; set;}
         @AuraEnabled public  string Sell_to_Customer_No {get; set;}
         @AuraEnabled public  string Document_Type {get; set;}

         public QuoteNavPostBody parse(String json){

              // QuoteNavPostBody jsonObj =  System.JSON.deserialize(json, QuoteNavPostBody.class);
                return (QuoteNavPostBody) System.JSON.deserialize(json, QuoteNavPostBody.class);


        }
    }



}