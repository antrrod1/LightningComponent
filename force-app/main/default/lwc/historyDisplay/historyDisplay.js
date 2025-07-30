import { LightningElement, api } from 'lwc';
//import getDesignHistory from '@salesforce/apex/designHandlerController.GetLatestHistoryFromOpportunity';
import GetLatestHistoryGroupFromOpportunity_Design from '@salesforce/apex/designHandlerController.GetLatestHistoryGroupFromOpportunity';
//import getEngineeringHistory from '@salesforce/apex/EngineeringHandlerController.GetLatestHistoryFromOpportunity';
import GetLatestHistoryGroupFromOpportunity_Engineering from '@salesforce/apex/EngineeringHandlerController.GetLatestHistoryGroupFromOpportunity';
export default class HistoryDisplay extends LightningElement {

    @api recordId; //this component is meant to be sued in the Opportunity record page. Thus, recordId will be the opp id
    @api designHistoryRetrieved = false;
    @api designHistoryRecords = [];
    @api engineeringHistoryRetrieved = false;
    @api engineeringHistoryRecords = [];

    activeSection = [];

    renderedCallback() {
        if(!this.designHistoryRetrieved){
            this.fetchDesignHistory();
        }
        if(!this.engineeringHistoryRetrieved){
            this.fetchEngineeringHistory();
        }

    }

    fetchDesignHistory(){
        /*
        getDesignHistory({ anOpportunityId: this.recordId })
		.then(result => {
            this.designHistoryRetrieved = true;
			this.designHistoryRecords = result;
		})
		.catch(error => {
			alert('ERROR: '+error);
            this.designHistoryRetrieved = false;
			this.designHistoryRecords = [];
		})
        */
        GetLatestHistoryGroupFromOpportunity_Design({ anOpportunityId: this.recordId })
        .then(result => {
            this.designHistoryRetrieved = true;
            this.designHistoryRecords = result;
        })
        .catch(error => {
            alert('ERROR: '+error);
            this.designHistoryRetrieved = false;
            this.designHistoryRecords = [];
        })
    }

    fetchEngineeringHistory(){
        /*
        getEngineeringHistory({ anOpportunityId: this.recordId })
		.then(result => {
            this.engineeringHistoryRetrieved = true;
			this.engineeringHistoryRecords = result;
		})
		.catch(error => {
			alert('ERROR: '+error);
            this.engineeringHistoryRetrieved = false;
			this.engineeringHistoryRecords = [];
		})
        */
        GetLatestHistoryGroupFromOpportunity_Engineering({ anOpportunityId: this.recordId })
        .then(result => {
            this.engineeringHistoryRetrieved = true;
            this.engineeringHistoryRecords = result;
        })
        .catch(error => {
            alert('ERROR: '+error);
            this.engineeringHistoryRetrieved = false;
            this.engineeringHistoryRecords = [];
        })
    }


}