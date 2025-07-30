import { LightningElement, api, wire } from 'lwc';
//import getRelatedFilesByRecordId from '@salesforce/apex/filePreviewAndDownloadController.getRelatedFilesByRecordId'
import getRelatedFilesByRecordId from '@salesforce/apex/filePreviewAndDownloadController.getRelatedFilesOF'
import linkFiles from '@salesforce/apex/filePreviewAndDownloadController.linkFilesWithRecord'
import removeFileRecord from '@salesforce/apex/filePreviewAndDownloadController.removeFileRecord'
import {NavigationMixin} from 'lightning/navigation'
export default class FilePreviewAndDownloads extends NavigationMixin(LightningElement) {

    //@api recordId='a0Udy0000001vyjEAA'
    filesList = [];
    @api recordtoretrieve;

    @api get recId(){
        return this.recordtoretrieve;
    }
    set recId( aValue){
        if(this.recordtoretrieve != aValue){
            this.recordtoretrieve = aValue;
            getRelatedFilesByRecordId({recordId: this.recordtoretrieve})
            .then(result => {
                if(result){
                   console.log(result);
                   this.filesList = result;
                   /*
                   this.filesList = Object.keys(result).map(item=>({"label":result[item],
                     "value": item,"extension":item.FileExtension,
                     "url":`/sfc/servlet.shepherd/document/download/${item}`
                    })) 
                    */
                }
            })
            .catch(error => {
                //alert('ERROR: '+error);
            })    
        }
    }    
    
    previewHandler(event){
        console.log(event.target.dataset.id)
        this[NavigationMixin.Navigate]({ 
            type:'standard__namedPage',
            attributes:{ 
                pageName:'filePreview'
            },
            state:{ 
                selectedRecordId: event.target.dataset.id
            }
        })
    }

    handleUploadFinished(event){
        const uploadedFiles = event.detail.files;
        //console.log('ploadFinished uploadedFiles:'+uploadedFiles);
        var fileIds = [];
        uploadedFiles.forEach((element) => fileIds.push(element.documentId));
        //console.log('fileIds:'+fileIds);

        linkFiles({recordId: this.recordtoretrieve, fileIdsToLink: fileIds })
            .then(result => {
                if(result){
                   //console.log(result);
                   this.filesList = result;
                   //console.log('result: '+result);
                }
            })
            .catch(error => {
                //console.log('ERROR');
                //console.log(error);
            })
    }

    onRemoveFileClicked(event){
        //alert(event.target.value);
        const docToDelete = event.target.value;
        //console.log(docToDelete);
        removeFileRecord({recordId: this.recordtoretrieve, fileId: docToDelete })
            .then(result => {
                if(result){
                   this.filesList = result;
                   //console.log('result: '+result);
                }
            })
            .catch(error => {
                console.log('ERROR');
                console.log(error);
            })
            
    }
}