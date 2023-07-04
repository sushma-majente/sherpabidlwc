import { api, LightningElement, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getAccountById from '@salesforce/apex/BidHandler.getAccountById';
import getUnitPriceByProductId from '@salesforce/apex/BidHandler.getUnitPriceByProduct';
import SaveMultipleBids from '@salesforce/apex/BidHandler.SaveMultipleBids';
import { loadStyle } from "lightning/platformResourceLoader";
import modal from "@salesforce/resourceUrl/CreateBidCss";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import LightningConfirm from "lightning/confirm";


export default class CreateCustomBid extends NavigationMixin(LightningElement) {
    @api recordId;
    @track keyIndex = 0;
    @track accountRecord;
    @track isRequired = true;
    @track bidName;
    @track createBidList = [];
    @track currentPageRecord = "Account";
    @track opportunityId = '';


    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    connectedCallback() {
        try {
            loadStyle(this, modal);
            if (this.recordId.startsWith('006')) {
                this.currentPageRecord = 'Oppportunity';
                this.opportunityId = this.recordId;
            }
            else {
                this.currentPageRecord = 'Account';
            }
            // If Current Page Record is Opportunity then recordId is Opportunity
            getAccountById({ id: this.recordId, isAccountRecord: this.currentPageRecord })
                .then(accountResult => {
                    // console.info('accountResult', accountResult);
                    this.accountRecord = accountResult[0];
                    this.createBidList.push({
                        ProductId: '',
                        AccountId: this.accountRecord.Id,
                        Quantity: '',
                        ListPrice: '',
                        Discount: this.accountRecord.Discount__c,
                        TotalPrice: '',
                        CostPrice: '',
                        DiscountAmount: 0,
                    });

                }).catch(error => {
                    console.log(error);
                })
        }
        catch (error) {
            // console.error(error);
        }
    }

    handleBidNameChange(event) {
        this.bidName = event.target.value;
    }

    handleValueSelectedOnAccount(event) {
        getUnitPriceByProductId({
            product2Id: event.detail.selectedRecord.id
            , pricebookname: 'Standard Price Book'
        })
            .then(result => {
                // console.log(`Result is ${result}`);
                this.createBidList[event.detail.selectedRecord.index].ProductId = event.detail.selectedRecord.id;
                this.createBidList[event.detail.selectedRecord.index].ListPrice = result != undefined && result.length > 0 ? result[0].UnitPrice : 0;
                this.createBidList[event.detail.selectedRecord.index].PriceBookEntryId = result[0].Id;
                this.calculateListPrice(event.detail.selectedRecord.index);
            })
            .catch(error => {
                // console.info(error);
            });
    }

    addRow() {
        this.createNewItem();
    }

    createNewItem() {
        this.keyIndex + 1;
        this.createBidList.push({
            ProductId: '',
            AccountId: this.accountRecord.Id,
            Quantity: '',
            ListPrice: '',
            Discount: this.accountRecord.Discount__c,
            TotalPrice: '',
            CostPrice: '',
            DiscountAmount: 0
        });
        // console.log(this.keyIndex ,'==>', this.createBidList);
    }

    removeDynamicRow(event) {
        // console.info('Before remove Index :: ', event.target.accessKey);
        const index = parseInt(event.target.accessKey);

        if (this.createBidList.length > 1) {
            this.createBidList.splice(index, 1);
            this.keyIndex - 1;
            const userInputs = this.template.querySelectorAll("c-product-reusable-lookup")[index];
            const totalComponents = this.template.querySelectorAll("c-product-reusable-lookup");

            for (let i = index; i < totalComponents.length; i++) {
                const element = this.template.querySelectorAll("c-product-reusable-lookup")[i];
                element.selectedRecordId = this.template.querySelectorAll("c-product-reusable-lookup")[i + 1].selectedRecordId;
                element.selectedRecordName = this.template.querySelectorAll("c-product-reusable-lookup")[i + 1].selectedRecordName;
            }
            userInputs.handleCommit();
        }
        else {
            const evt = new ShowToastEvent({
                title: `Warning`,
                message: 'Atleast One Quote Line is Mandatory',
                variant: 'warning',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
    }

    handleChange(event) {
        this.totalListValue = 0;
        this.totalPriceValue = 0;
        if (event.target.name == 'bidQuantity') {
            this.createBidList[event.target.accessKey].Quantity = event.target.value;
            this.calculateListPrice(event.target.accessKey);
        }
        if (event.target.name == 'bidDiscount') {
            this.createBidList[event.target.accessKey].Discount = event.target.value;
            this.calculateListPrice(event.target.accessKey);
        }
        if (event.target.name == 'bidTotalPrice') {
            this.createBidList[event.target.accessKey].TotalPrice = event.target.value;
        }
        if (event.target.name == 'bidListPrice') {
            this.createBidList[event.target.accessKey].ListPrice = event.target.value;
        }
        if (event.target.name == 'bidDiscountAmount') {
            this.createBidList[event.target.accessKey].DiscountAmount = event.target.value;
            this.calculateListPrice(event.target.accessKey);
        }

        this.aggregateValues();
    }

    calculateListPrice(currentIndex) {
        let totalValue = (this.createBidList[currentIndex].Quantity * this.createBidList[currentIndex].ListPrice);
        let discountedValue = totalValue * (this.createBidList[currentIndex].Discount / 100);
        let discountAmount = this.createBidList[currentIndex].DiscountAmount != undefined && this.createBidList[currentIndex].DiscountAmount != '' ? this.createBidList[currentIndex].DiscountAmount : 0;
        this.createBidList[currentIndex].TotalPrice = Math.round((parseFloat((totalValue - discountedValue) - discountAmount) + Number.EPSILON) * 100) / 100;
        this.createBidList[currentIndex].CostPrice = this.createBidList[currentIndex].TotalPrice / this.createBidList[currentIndex].Quantity;
    }

    async saveOrderToDB() {
        const result = await LightningConfirm.open({
            message: "Are you sure you want to Save?",
            label: "Save",
            theme: "success"
        });
        if (result) {
            this.handleCreateBid(null);
        } else {
            //do something else 
        }
    }

    async closewindow() {
        const result = await LightningConfirm.open({
            message: "Are you sure you want to Cancel this?",
            theme: "warning",
            label: "Warning"
        });
        if (result) {
            this.dispatchEvent(new CloseActionScreenEvent());
        } else {
            //do something else 
        }
    }


    handleCreateBid(event) {
        //
        let canByPassToSave = true;
        const userInputs = this.template.querySelectorAll("c-product-reusable-lookup");

        for (let index = 0; index < userInputs.length; index++) {
            const element = userInputs[index];
            if (element.selectedRecordId == undefined || element.selectedRecordId == '') {
                canByPassToSave = false;
                break;
            }
        }


        for (let index = 0; index < this.createBidList.length; index++) {
            const element = this.createBidList[index];
            if (element.Quantity == undefined || element.Quantity == '' || element.Discount == undefined || element.Discount == '') {
                canByPassToSave = false;
                break;
            }
        }

        let isQuoteNameValid = this.isInputValid();

        if (!isQuoteNameValid) {
            canByPassToSave = false;
        }

        if (!canByPassToSave) {
            this.showValidationToast();
        }
        else {
            this.saveQuoteLineItems();
        }
    }

    saveQuoteLineItems() {
        SaveMultipleBids({
            jsonString: JSON.stringify(this.createBidList),
            QuoteName: this.bidName,
            optyId : this.opportunityId
        })
            .then(saveResult => {
                let quoteName = saveResult.Name;
                let quoteId = saveResult.Id;
                this.showSuccessToast(quoteName, quoteId);
            }).catch(error => {
                // console.error(`Errrr ::  ${error}`);
            });
    }

    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }

    showValidationToast() {
        const evt = new ShowToastEvent({
            title: `Validation`,
            message: 'Please fill all Mandatory field(s).',
            variant: 'warning',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    showSuccessToast(quoteName, quoteId) {
        const evt = new ShowToastEvent({
            title: `Bid ${quoteName} created successful`,
            message: 'Opearion sucessful',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
        this.closeQuickAction();
        this.navigateToRecordPage(quoteId);
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    navigateToRecordPage(quoteId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: quoteId,
                objectApiName: 'Quote',
                actionName: 'view'
            }
        });
    }

    @track totalListValue = 0;
    @track totalPriceValue = 0;

    aggregateValues() {
        for (let index = 0; index < this.createBidList.length; index++) {
            const element = this.createBidList[index];
            if (element.ListPrice != undefined && element.ListPrice != '') {
                this.totalListValue += parseInt(element.Quantity) * parseFloat(element.ListPrice);
            }
            if (element.TotalPrice != undefined && element.TotalPrice != '') {
                this.totalPriceValue += this.getTwoDigitNumber(parseFloat(element.TotalPrice));
            }
        }
    }

    getTwoDigitNumber(num) {
        return Math.round((num + Number.EPSILON) * 100) / 100
    }

}