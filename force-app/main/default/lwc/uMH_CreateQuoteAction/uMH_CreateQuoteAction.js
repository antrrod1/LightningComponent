// createQuoteButton.js
import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord,getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin  } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';
import { updateRecord } from 'lightning/uiRecordApi';
import { RefreshEvent } from 'lightning/refresh';
import {  getRecordNotifyChange } from 'lightning/uiRecordApi'; 
import NAV_PostCallOut from '@salesforce/apex/NAV_SyncData_Callout.QuotePOSTRequest';

const FIELDS = ["Opportunity.Name", "Opportunity.LeadSource","Opportunity.AccountId", "Opportunity.ContactId","Opportunity.Contact__c", "Opportunity.Account.NAV_ID__c", "Opportunity.Contact__r.NAV_ID__c", "Opportunity.Ship_To_Address__r.NAV_Id__c ", "Opportunity.Business_Development_Code__c", "Opportunity.Salesperson_Code__c",  "Opportunity.Customer_Service_Code__c","Opportunity.Description", "Opportunity.Designer_Code__c","Opportunity.Inside_Sales_Code__c", "Opportunity.Drawing_Reference__c" ,"Opportunity.Ship_To_Address__c" ];
//"Opportunity.Ship_To_Address_Lookup__c"
export default class CreateQuoteButton extends NavigationMixin(LightningElement) {
 
   _recordId;
    // @api recordId;;
    stoprecursion = false;

    @api set recordId(value) {        
    this._recordId = value;    
    
}

get recordId() {
      console.log( this._recordId);
    return this._recordId;
}



connectedCallback() {       
      console.log( 'connectedCallback'+  this._recordId);
}

   
@wire(getRecord, { recordId:'$recordId', fields: FIELDS })
    loadFields({error, data}){
        if(error){
                 console.log(error);
        }else if(data){
             console.log('stoprecursion'+this.stoprecursion);
            if(!this.stoprecursion){
                console.log(data);
                    console.log(data.fields);
                    console.log('oppid' + data.id);
                this.createQuote(data.id, data.fields);
                this.stoprecursion = true;
            }
        }
    }


    createQuote(oppId, oppdata) {

         let accNavid,conNavid,shipToNavid = null ; 

       if(oppdata.Account.value!=null){ 
            accNavid = oppdata.Account.value.fields.NAV_ID__c;
       }
       if(oppdata.Contact__r.value!=null){ 
            conNavid = oppdata.Contact__r.value.fields.NAV_ID__c;
       }
       if(oppdata.Ship_To_Address__r.value!=null){ 
            shipToNavid = oppdata.Ship_To_Address__r.value.fields.NAV_ID__c;
       }
             

      //  if(accNavid!=null && conNavid!=null && shipToNavid!=null){

            let accid,conid;
            if(oppdata.AccountId!=null){
             accid =  oppdata.AccountId.value;
            }
            if(oppdata.Contact__r!=null){
                 if(oppdata.Contact__r.value!=null){
                conid =  oppdata.Contact__r.value.id;
                 }
            }             
              console.log('accid');
            console.log(accid);
             console.log(conid);
                console.log('oppdata.LeadSource.value'+oppdata.LeadSource.value);
            //, Ship_To_Address__c : oppdata.Ship_To_Address_Lookup__c.value 
        const fields = { OpportunityId: oppId ,  Name: oppdata.Name.value ,  Account__c: accid ,Contact__c: conid,  Business_Development_Code__c: oppdata.Business_Development_Code__c.value, Salesperson_Code__c:  oppdata.Salesperson_Code__c.value, Customer_Service_Code__c: oppdata.Customer_Service_Code__c.value , Description: oppdata.Description.value , Designer_Code__c: oppdata.Designer_Code__c.value , Drawing_Reference__c: oppdata.Drawing_Reference__c.value , Inside_Sales_Code__c: oppdata.Inside_Sales_Code__c.value , Ship_To_Address__c: oppdata.Ship_To_Address__c.value, LeadSource__c : oppdata.LeadSource.value   };
        const recordInput = { apiName: 'Quote', fields };

        createRecord(recordInput)
            .then(response => {
                 window.console.log(' quote create response');
                  window.console.log(' quote create response2');
                   window.console.log(response);
                   window.console.log(response.fields);
               // window.console.log(response.fields.QuoteNumber.value);
                let quotenumber;
                
                    if(response.fields.QuoteNumber.value != '' && response.fields.QuoteNumber.value!=null){
                        quotenumber = response.fields.QuoteNumber.value;
                    }
                
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Quote created successfully' + ', Ref: '+quotenumber,
                        variant: 'success',
                    })
                );
               
               this.postAPICalltoNAV(response.id, response, oppId);
           
              
               
            })
            .catch((error) => {
                window.console.log('error');
                window.console.log(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating Quote',
                        message: error.statusText + ': '+ error.body.message,
                        variant: 'error',
                    })
                );
                 this.dispatchEvent(new CloseActionScreenEvent());
            });
       /* }else{

           this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Kindly check if the related objects data is in sync with NAV ',
                        message: 'Verify NAV ID in Account,Contact,Shiptoaddress',
                        variant: 'error',
                    })
                );
                 this.dispatchEvent(new CloseActionScreenEvent());
      }*/
            
    }
     
      navigateToQuotePage(quoteId, oppId) {
         
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: oppId,
                objectApiName: 'Opportunity',
                actionName: 'view'
            }
        });
          
          // updateRecord({ fields: { Id:oppId }})  
         
             this.dispatchEvent(new CloseActionScreenEvent()); 
              
               this.dispatchEvent(new RefreshEvent());
                this.event1 = setTimeout(() => {                  
                           getRecordNotifyChange([{recordId: oppId}]); 
                             
                 }, 10000);
      }
  

            
               
     


    async postAPICalltoNAV(quoteId, quote, oppId){
        console.log('inside postAPICalltoNAV');
      console.log(quote);
      let quotefields = quote.fields;
       console.log(quotefields);
               /* let NavPostBody = { 
                    Document_Type:'Quote', 
                    SalesForceID : quote.id,
                    SF_Opportunity_No : quotefields.OpportunityId.value,                        
                    Sell_to_Customer_No:quotefields.Sell_to_Customer_No__c.value,
                    WC_Sell_to_Contact_No: quotefields.Sell_to_Contact_No__c.value,                    
                    Salesperson_Code: quotefields.Salesperson_Code__c.value,
                    Drawing_Reference: quotefields.Drawing_Reference__c.value,
                    Lead_Source: quotefields.LeadSource__c.value,                  
                    ShipToSalesForceID: quotefields.Ship_To_Address__c.value,
                    Business_Development_Code: quotefields.Business_Development_Code__c.value,
                    Customer_Service_Code: quotefields.Customer_Service_Code__c.value,
                    Designer_Code: quotefields.Designer_Code__c.value,
                    Inside_Sales_Code: quotefields.Inside_Sales_Code__c.value,
                 }; */

                  let NavPostBodyJsonData = JSON.stringify(
                    {   
                    Document_Type:'Quote',
                    Sell_to_Customer_No:quotefields.Sell_to_Customer_No__c.value,                   
                    SF_Opportunity_No : quotefields.OpportunityId.value,                        
                    SalesForceID : quote.id,
                    WC_Sell_to_Contact_No: quotefields.Sell_to_Contact_No__c.value,
                    ShipToSalesForceID: quotefields.Ship_To_Address__c.value,                    
                    Salesperson_Code: quotefields.Salesperson_Code__c.value,
                    Lead_Source: quotefields.LeadSource__c.value,                  
                    Inside_Sales_Code: quotefields.Inside_Sales_Code__c.value,
                    Drawing_Reference: quotefields.Drawing_Reference__c.value,
                    Designer_Code: quotefields.Designer_Code__c.value,
                    Customer_Service_Code: quotefields.Customer_Service_Code__c.value,
                    Business_Development_Code: quotefields.Business_Development_Code__c.value
                    }
                );
                 // SF_Opportunity_No:quoteId,
            //TODO -  "SF_Quote_No": "1234567890123", 

            console.log('Sell_to_Customer_No'+quotefields.Sell_to_Customer_No__c.value);
            console.log('Sell_to_Contact_No'+quotefields.Sell_to_Contact_No__c.value);  
            console.log('NavPostBody');
            console.log(NavPostBodyJsonData);
                return new Promise(async (resolve, reject) =>{
                console.log('2');
                var result = await NAV_PostCallOut({'navbodyparam': NavPostBodyJsonData, 'AccId':quotefields.Account__c.value });
                 console.log(result);
                console.log('3');
                resolve(result);
                // Navigate to the newly created record page 
                if(result.Statuscode == '200' || result.Statuscode == '201'){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Successfully generated a New Quote in NAV with Id :'+result.No,
                            variant: 'success',
                        })
                    );
                }else {
                     this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error While syncing Quote information with NAV',
                        message: 'Please connect with system administrator',
                        variant: 'error',
                    })
                );
                 this.dispatchEvent(new CloseActionScreenEvent());
                }
            console.log('inside postAPICalltoNAV redirecting to navigateToQuotePage');
             this.navigateToQuotePage(quoteId,oppId);
            });

           
    }

   
}