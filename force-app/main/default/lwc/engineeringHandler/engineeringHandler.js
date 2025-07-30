import { LightningElement, api } from 'lwc';
import getEngineering from '@salesforce/apex/EngineeringHandlerController.GetEngineeringFrom';
import updateEngineeringStage from '@salesforce/apex/EngineeringHandlerController.UpdateEngineeringStage';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';

export default class EngineeringHandler extends LightningElement {

    @api recordId; //this component is meant to be sued in the Opportunity record page. Thus, recordId will be the opp id
    @api engineeringId;
    currentStatus;
    recordRetrieved = false;
    editMode = false; 
    recordUrl;

    stepPressedEng(event) {
        this.currentStatus = event.currentTarget.value;
        updateEngineeringStage({ recordId: this.engineeringId, aNewStage: this.currentStatus })
		.then(result => {
            notifyRecordUpdateAvailable([{recordId: this.engineeringId}]);
		})
		.catch(error => {
			//alert('ERROR: '+error);
		})
    }

    fetchEngineering(){
        if(!this.recordRetrieved){
            getEngineering({ anOpportunityId: this.recordId })
            .then(result => {
                if(result){
                    this.recordRetrieved = true;
                    this.engineeringId = result.Id;
                    this.currentStatus = result.Stage__c;
                    this.recordUrl = ''+window.location.origin+'/'+result.Id;
                }else{
                    this.recordRetrieved = false;    
                }
            })
            .catch(error => {
                //alert('ERROR: '+error);
                this.recordRetrieved = false;
            })
        }
    }

    renderedCallback() {
        this.fetchEngineering();
    }

    nameClicked(event){
        alert('HI');
    }
    
    enterEditMode(event){
        this.editMode = true;
    }
    exitEditMode(event){
        this.editMode = false;
    }

    submitEngineering(event){
        this.refs.engineeringEditForm.submit();
        notifyRecordUpdateAvailable([{recordId: this.engineeringId}]);
        this.editMode = false;
    }
    

}