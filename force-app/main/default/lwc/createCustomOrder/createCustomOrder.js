import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getAccountById from '@salesforce/apex/BidHandler.getAccountById';
import getUnitPriceByProductId from '@salesforce/apex/BidHandler.getUnitPriceByProduct';
import { loadStyle } from "lightning/platformResourceLoader";
import modal from "@salesforce/resourceUrl/CreateBidCss";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import SaveOrders from '@salesforce/apex/OrderHandler.SaveOrders';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';

import ORDER_TYPE_FIELD from '@salesforce/schema/Order.Order_Type__c';
import SHIPPING_METHOD_FIELD from '@salesforce/schema/Order.Shipping_Method__c';


import ORDER from '@salesforce/schema/Order';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class CreateCustomOrder extends NavigationMixin(LightningElement) {

    @api recordId;
    @track keyIndex = 0;
    @track accountRecord;
    @track isRequired = true;
    @track OrdersList = [];
    @track referencePONumber;
    @track splInstructions;
    @track selectedOrderType;
    @track selectedShippingType;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    @wire(getObjectInfo, { objectApiName: ORDER })
    OrderInfo;

    @wire(getPicklistValues,
        {
            recordTypeId: '$OrderInfo.data.defaultRecordTypeId',
            fieldApiName: ORDER_TYPE_FIELD
        }
    ) orderSourceValues;

    @wire(getPicklistValues,
        {
            recordTypeId: '$OrderInfo.data.defaultRecordTypeId',
            fieldApiName: SHIPPING_METHOD_FIELD
        }
    ) shippingSourceValues;

    connectedCallback() {
        try {
            loadStyle(this, modal);
            this.totalListValue = 0;
            this.totalPriceValue = 0;
            getAccountById({ id: this.recordId })
                .then(accountResult => {
                    this.accountRecord = accountResult[0];
                    this.OrdersList.push({
                        ProductId: '',
                        AccountId: this.accountRecord.Id,
                        Quantity: '',
                        ListPrice: '',
                        Discount: this.accountRecord.Discount__c,
                        TotalPrice: '',
                        CostPrice : '',
                        DiscountAmount: 0
                    });

                }).catch(error => {
                    alert(error);
                })
        }
        catch (error) {
            alert(error);
        }
    }

    handleValueSelectedOnAccount(event) {
        getUnitPriceByProductId({
            product2Id: event.detail.selectedRecord.id
            , pricebookname: 'Standard Price Book'
        })
            .then(result => {
                // console.log(`Result is ${result}`);
                this.OrdersList[event.detail.selectedRecord.index].ProductId = event.detail.selectedRecord.id;
                this.OrdersList[event.detail.selectedRecord.index].ListPrice = result != undefined && result.length > 0 ? result[0].UnitPrice : 0;
                this.OrdersList[event.detail.selectedRecord.index].PriceBookEntryId = result[0].Id;
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
        this.OrdersList.push({
            ProductId: '',
            AccountId: this.accountRecord.Id,
            Quantity: '',
            ListPrice: '',
            Discount: this.accountRecord.Discount__c,
            TotalPrice: '',
            CostPrice : '',
            DiscountAmount: 0
        });
    }

    removeDynamicRow(event) {
        // console.info('Before remove Index :: ', event.target.accessKey);
        const index = parseInt(event.target.accessKey);

        if (this.OrdersList.length > 1) {
            this.OrdersList.splice(index, 1);
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
                message: 'Atleast One Order Line is Mandatory',
                variant: 'warning',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
    }

    handlePONumberChange(event) {
        this.referencePONumber = event.target.value;
    }

    handleOrderTypeChange(event) {
        this.selectedOrderType = event.target.value;
    }

    handleSpecialInstructions(event) {
        this.splInstructions = event.target.value;
    }

    handleShippingType(event) {
        this.selectedShippingType = event.target.value;
    }

    handleChange(event) {
        this.totalListValue = 0;
        this.totalPriceValue = 0;
        if (event.target.name == 'orderQuantity') {
            this.OrdersList[event.target.accessKey].Quantity = event.target.value;
            this.calculateListPrice(event.target.accessKey);
        }
        if (event.target.name == 'orderDiscount') {
            this.OrdersList[event.target.accessKey].Discount = event.target.value;
            this.calculateListPrice(event.target.accessKey);
        }
        if (event.target.name == 'orderTotalPrice') {
            this.OrdersList[event.target.accessKey].TotalPrice = event.target.value;
        }
        if (event.target.name == 'orderListPrice') {
            this.OrdersList[event.target.accessKey].ListPrice = event.target.value;
        }
        if (event.target.name == 'orderDiscountAmount') {
            this.OrdersList[event.target.accessKey].DiscountAmount = event.target.value;
            this.calculateListPrice(event.target.accessKey);
        }

        this.aggregateValues();
    }

    calculateListPrice(currentIndex) {
        let totalValue = (this.OrdersList[currentIndex].Quantity * this.OrdersList[currentIndex].ListPrice);
        let discountedValue = totalValue * (this.OrdersList[currentIndex].Discount / 100);
        let discountAmount = this.OrdersList[currentIndex].DiscountAmount != undefined && this.OrdersList[currentIndex].DiscountAmount != '' ? this.OrdersList[currentIndex].DiscountAmount : 0;
        this.OrdersList[currentIndex].TotalPrice = Math.round((parseFloat((totalValue - discountedValue) - discountAmount) + Number.EPSILON) * 100) / 100;
        this.OrdersList[currentIndex].CostPrice =  this.OrdersList[currentIndex].TotalPrice/this.OrdersList[currentIndex].Quantity;
    }

    aggregateValues() {
        for (let index = 0; index < this.OrdersList.length; index++) {
            const element = this.OrdersList[index];
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

    handleCreateOrder(event) {
        let canByPassToSave = true;
        const userInputs = this.template.querySelectorAll("c-product-reusable-lookup");
        for (let index = 0; index < userInputs.length; index++) {
            const element = userInputs[index];
            if (element.selectedRecordId == undefined || element.selectedRecordId == '') {
                canByPassToSave = false;
                break;
            }
        }


        for (let index = 0; index < this.OrdersList.length; index++) {
            const element = this.OrdersList[index];
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
            // SAVE Ticket
            SaveOrders({
                jsonString: JSON.stringify(this.OrdersList), accountId: this.recordId, poNumber: this.referencePONumber,
                specialComments: this.splInstructions, orderType: this.selectedOrderType, shippingType: this.selectedShippingType
            })
                .then(result => {
                    let OrderNumber = result.OrderNumber;
                    let orderId = result.Id;
                    this.showSuccessToast(OrderNumber, orderId);
                }).catch(error => {
                    console.error(error);
                });
        }
    }

    showSuccessToast(OrderNumber, orderId) {
        const evt = new ShowToastEvent({
            title: `Order : ${OrderNumber} created successful`,
            message: 'Record Saved sucessful',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
        this.closeQuickAction();
        this.navigateToRecordPage(orderId);
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    navigateToRecordPage(orderId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: orderId,
                objectApiName: 'Order',
                actionName: 'view'
            }
        });
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
}