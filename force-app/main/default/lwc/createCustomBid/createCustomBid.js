import { api, LightningElement, wire,track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getAccountById from '@salesforce/apex/BidHandler.getAccountById';

export default class CreateCustomBid extends LightningElement {
    @api recordId;
    @track keyIndex = 0;
    @track accountRecord;
    @track createBidList = [
        {
            AccountId: '',
            Quantity: '',
            ListPrice: '',
            Discount: '',
            TotalPrice: ''
        }
    ];

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    connectedCallback() {
        try {
            getAccountById({id : this.recordId})
            .then(accountResult => {
                console.info('accountResult', accountResult);
                this.accountRecord = accountResult[0];

                // Assigning Values for 0th Index
                this.createBidList[this.keyIndex].AccountId = this.accountRecord.Id;
                this.createBidList[this.keyIndex].Discount = this.accountRecord.Discount__c;

                }).catch(error => {
                console.error(error);
            })
        }
        catch (error) {
            console.error(error);
        }
    }

    createNewItem() {
        this.keyIndex + 1;
        this.createBidList.push({
            AccountId: this.accountRecord.Id,
            Quantity: '',
            ListPrice: '',
            Discount: this.accountRecord.Discount__c,
            TotalPrice: ''
        });
    }

    addRow() {
        this.createNewItem();
    }
}