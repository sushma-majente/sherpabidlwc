import { api, LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getAccountById from '@salesforce/apex/BidHandler.getAccountById';
import { loadStyle } from "lightning/platformResourceLoader";
import modal from "@salesforce/resourceUrl/CreateBidCss";


export default class CreateCustomBid extends LightningElement {
    @api recordId;
    @track keyIndex = 0;
    @track accountRecord;
    @track isRequired = true;
    @track createBidList = [
        {
            ProductId: '',
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
            loadStyle(this, modal);
            getAccountById({ id: this.recordId })
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
        this.keyIndex = this.keyIndex + 1;
        this.createBidList.push({
            ProductId: '',
            AccountId: this.accountRecord.Id,
            Quantity: '',
            ListPrice: '',
            Discount: this.accountRecord.Discount__c,
            TotalPrice: ''
        });
    }

    handleBidNameChange(event) {
        this.numberFieldValue = event.target.value;
    }

    handleValueSelectedOnAccount(event) {
        // console.log(event.detail.selectedRecord.mainField);
        // console.log(event.detail.selectedRecord.index);
        this.createBidList[event.detail.selectedRecord.index].ProductId = event.detail.selectedRecord.id;
    }

    addRow() {
        this.createNewItem();
    }

    removeDynamicRow(event) {
        console.info('Index :: ', event.target.accessKey);
        const index = event.target.accessKey;
        if (this.createBidList.length >= 1) {
            this.createBidList.splice(index, 1);
            // this.keyIndex = this.keyIndex - 1;
            // const userInputs = this.template.querySelectorAll("c-product-reusable-lookup")[event.target.accessKey];
            // userInputs.handleCommit();
            // this.template.querySelectorAll("c-product-reusable-lookup").removeChild(userInputs);
        }
    }

    handleQuantityChange(event) {
        console.log(event.target.name);
        if (event.target.name == 'bidQuantity') {
            this.createBidList[event.target.accessKey].Quantity = event.target.value;
        }
        if (event.target.name == 'bidDiscount') {
            this.createBidList[event.target.accessKey].Discount = event.target.value;
        }
    }
}