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
            // alert(this.template.querySelectorAll("c-product-reusable-lookup").length);

            // const userInputs = this.template.querySelectorAll("c-product-reusable-lookup")[event.target.accessKey];
            let table = document.querySelector("table");
            table.deleteRow(index);

            // alert(userInputs.selectedRecordName);
            // userInputs.handleCommit();
            
            this.keyIndex - 1;
            // var table = document.getElementById('newtable');
            // this.template.querySelector("tr").deleteRow(event.target.accessKey);
            // const local = this.template.querySelectorAll("tr")[event.target.accessKey];
            // this.template.querySelectorAll("tr").removeChild(local);
            // this.template.querySelectorAll("c-product-reusable-lookup").removeChild(userInputs);
        }
    }

    handleChange(event) {
        if (event.target.name == 'bidQuantity') {
            this.createBidList[event.target.accessKey].Quantity = event.target.value;
        }
        if (event.target.name == 'bidDiscount') {
            this.createBidList[event.target.accessKey].Discount = event.target.value;
        }
        if (event.target.name == 'bidTotalPrice') {
            this.createBidList[event.target.accessKey].TotalPrice = event.target.value;
        }
        if (event.target.name == 'bidListPrice') {
            this.createBidList[event.target.accessKey].ListPrice = event.target.value;
        }
    }
}