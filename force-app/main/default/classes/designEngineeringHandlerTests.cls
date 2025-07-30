@isTest
public with sharing class designEngineeringHandlerTests {
    
	@testSetup static void setup() {
        Opportunity opp = new Opportunity();
		opp.Name = 'Opp1';
		opp.StageName = 'Qualification';
		opp.CloseDate = Date.today();
		insert opp;

		Design__c newDesign = new Design__c();
		newDesign.Accessories_For_Project__c = 'Pallet Stops';
		newDesign.Additional_Information_For_Project__c = '-';
		newDesign.AutoCad_Saved_in_Quote_Folder__c = 'Yes';
		newDesign.BCH_Unit_of_Measurement__c = 'Feet';
		newDesign.Beam_Length__c = 10;
		newDesign.BL_Unit_of_Measurement__c = 'Feet';
		newDesign.Building_Clear_Height__c = 10;
		newDesign.Design_Due_Date__c = Date.Today().AddDays(10);
		newDesign.Name = 'Some Design';
		newDesign.Design_Stage__c = 'New';
		newDesign.FD_Unit_of_Measurement__c = 'Feet';
		newDesign.Forklift_Type__c = 'Reach Truck';
		newDesign.Frame_Depth__c = 10;
		newDesign.MaxAW_Unit_of_Measurement__c = 'Feet';
		newDesign.Maximum_Aisle_Width__c = 10;
		newDesign.MinAW_Unit_of_Measurement__c = 'Feet';
		newDesign.Minimum_Aisle_Width__c = 10;
		newDesign.Number_of_Pallet_Positions_Required__c = 10;
		newDesign.Opportunity__c = opp.Id;
		newDesign.Pallet_Depth__c = 10;
		newDesign.Pallet_Height__c = 10;
		newDesign.Pallet_Over_Hang__c = 10;
		newDesign.Pallet_Type__c = 'Chep Pallet';
		newDesign.Pallet_Weight__c = 10;
		newDesign.PD_Unit_of_Measurement__c = 'Feet';
		newDesign.Permits_For_Project__c = 'Yes';
		newDesign.PH_Unit_of_Measurement__c = 'Feet';
		newDesign.POH_Unit_of_Measurement__c = 'Feet';
		newDesign.Products_To_Be_Stored__c = '-';
		newDesign.PW_Unit_of_Measurement__c = 'Feet';
		newDesign.Required_Rack_Height__c = 10;
		newDesign.RRH_Unit_of_Measurement__c = 'Feet';
		newDesign.Sprinkler_Information__c = 'nah';
		newDesign.Target_Go_Live_Date_For_Custumer__c = Date.Today().AddDays(15);
		insert newDesign;          

		Engineering__c newEngineering = new Engineering__c();
		newEngineering.Calculation_Type__c	= 'Final Calculations';
		newEngineering.Design__c = newDesign.Id;
		newEngineering.Due_Date__c = newDesign.Design_Due_Date__c;
		newEngineering.Name = 'Doe';
		newEngineering.Opportunity__c = opp.Id;
		newEngineering.Stage__c = 'New';
		insert newEngineering;
    }

    @isTest
    public static  void designHandlerTest(){
    	Design__c design = [SELECT ID, Design_Stage__c, Opportunity__c FROM Design__c LIMIT 1];
    	Design__c designFound = designHandlerController.GetDesignFrom(design.Opportunity__c);
    	System.assertEquals(design.Id,designFound.Id);

    	String newStage = 'In Progress';
    	designHandlerController.UpdateDesignStage(design.Id,newStage);
    	design = [SELECT ID, Design_Stage__c, Opportunity__c FROM Design__c WHERE ID =: design.Id LIMIT 1];
    	System.assertEquals(design.Design_Stage__c,newStage);

    	List<designHandlerController.DesignHistoryGroup> result = designHandlerController.GetLatestHistoryGroupFromOpportunity(design.Opportunity__c);
    	designHandlerController.DesignHistoryGroupItem item = new designHandlerController.DesignHistoryGroupItem('aField', '0', '1');
    	List<designHandlerController.DesignHistoryGroupItem> myList = new List<designHandlerController.DesignHistoryGroupItem>{item};
    	designHandlerController.DesignHistoryGroup historyGroup = new designHandlerController.DesignHistoryGroup( 'March', 'John Doe', myList);
    }

    @isTest
    public static  void engineeringHandlerTest(){
    	Engineering__c engineering = [SELECT ID, Stage__c, Opportunity__c FROM Engineering__c LIMIT 1];
    	Engineering__c engineeringFound = EngineeringHandlerController.GetEngineeringFrom(engineering.Opportunity__c);
    	System.assertEquals(engineering.Id,engineeringFound.Id);

    	String newStage = 'In Progress';
    	EngineeringHandlerController.UpdateEngineeringStage(engineering.Id,newStage);
    	engineering = [SELECT ID, Stage__c, Opportunity__c FROM Engineering__c LIMIT 1];
    	System.assertEquals(engineering.Stage__c,newStage);

    	List<EngineeringHandlerController.EngineeringHistoryGroup> result = EngineeringHandlerController.GetLatestHistoryGroupFromOpportunity(engineering.Opportunity__c);
    	EngineeringHandlerController.EngineeringHistoryGroupItem item = new EngineeringHandlerController.EngineeringHistoryGroupItem('aField', '0', '1');
    	List<EngineeringHandlerController.EngineeringHistoryGroupItem> myList = new List<EngineeringHandlerController.EngineeringHistoryGroupItem>{item};
    	EngineeringHandlerController.EngineeringHistoryGroup historyGroup = new EngineeringHandlerController.EngineeringHistoryGroup( 'March', 'John Doe', myList);
    }

    @isTest
    public static  void filesTest(){
    	Design__c design = [SELECT ID, Design_Stage__c, Opportunity__c FROM Design__c LIMIT 1];
    	Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the');
    	ContentVersion contentVersion = new ContentVersion(
            Title='SampleTitle', 
            PathOnClient ='SampleTitle.jpg',
            VersionData = bodyBlob, 
            origin = 'H'
        );
        insert contentVersion;
        contentVersion = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];
        List<filePreviewAndDownloadController.File> res = filePreviewAndDownloadController.linkFilesWithRecord(design.Id, new List<String>{contentVersion.ContentDocumentId});
        filePreviewAndDownloadController.getRelatedFilesOF(design.Id);
        filePreviewAndDownloadController.removeFileRecord(design.Id,contentVersion.ContentDocumentId);


    }

}