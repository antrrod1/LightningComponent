import { LightningElement, api } from 'lwc';
import getDesign from '@salesforce/apex/designHandlerController.GetDesignFrom';
import updateDesignStage from '@salesforce/apex/designHandlerController.UpdateDesignStage';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';

export default class DesignHandler extends LightningElement {

    @api recordId; //this component is meant to be sued in the Opportunity record page. Thus, recordId will be the opp id
    @api designId;

    currentStatus;
    reocrdRetrieved = false; 
    newStatus;
    designIdTmp;

    editMode = false;

    currentDesignTab = ["DesignInformation","Measurements"];

    recordUrl;

    stepPressed(event) {
        this.currentStatus = event.currentTarget.value;
        //this.reocrdRetrieved = false;
        
        updateDesignStage({ recordId: this.designId, aNewStage: this.currentStatus })
		.then(result => {
            //this.reocrdRetrieved = true;
            notifyRecordUpdateAvailable([{recordId: this.designId}]);
		})
		.catch(error => {
			//alert('ERROR: '+error);
            this.reocrdRetrieved = false;
		})
    }

    fetchDesign(){
        if(!this.reocrdRetrieved){
            getDesign({ anOpportunityId: this.recordId })
            .then(result => {
                if(result){
                    this.reocrdRetrieved = true;
                    this.designId = result.Id;
                    this.currentStatus = result.Design_Stage__c;
                    this.recordUrl = ''+window.location.origin+'/'+result.Id;

                    //this.template.querySelector("c-file-preview-and-downloads").fetchFilesFor();
                    //this.refs.filesComponent.fetchFilesFor();
                }else{
                    this.reocrdRetrieved = false;    
                }
            })
            .catch(error => {
                //alert('ERROR: '+error);
                this.reocrdRetrieved = false;
            })
        }
    }

    renderedCallback() {
        //alert('HI '+this.recordId);
        this.fetchDesign();
    }

    enterEditMode(event){
        this.editMode = true;
    }
    exitEditMode(event){
        this.editMode = false;
    }

    submitDesign(event){
        this.refs.designEditForm.submit();
        notifyRecordUpdateAvailable([{recordId: this.designId}]);
        this.editMode = false;
    }
   
}