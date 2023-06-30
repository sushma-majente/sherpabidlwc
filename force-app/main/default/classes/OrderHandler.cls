public with sharing class OrderHandler {
    public OrderHandler() {

    }
    @AuraEnabled
    public static Order SaveOrders(string jsonString, string accountId, string poNumber, string specialComments,string orderType, String shippingType) {
        List<BidWrapper> wrapperList = (List<BidWrapper>) JSON.deserialize(jsonString, List<BidWrapper>.class);
        Id pricebook2Id = [SELECT ID, NAME FROM PRICEBOOK2 WHERE NAME = 'Standard Price Book'].Id;
        
        // New Order
        // New Order Details
        Order ord = new Order();
        ord.AccountId = accountId;
        ord.EffectiveDate = System.today(); 
        ord.Status = 'Draft';
        ord.PoNumber = poNumber;
        ord.Special_Comments__c = specialComments;
        ord.Order_Type__c = orderType;
        ord.Shipping_Method__c = shippingType;
        ord.Pricebook2Id = pricebook2Id;
        insert ord;
        
        List<OrderItem> lstOrderItems = new List<OrderItem>();
        
        for(BidWrapper bw : wrapperList) {
            OrderItem oli = new OrderItem();
            oli.PricebookEntryId = bw.PriceBookEntryId;
            oli.UnitPrice  = bw.ListPrice;
            oli.Quantity = Decimal.valueOf(bw.Quantity);
            // oli.Discount__c = bw.Discount; // Validation rule stopping this.
            
            oli.Discount = bw.Discount; // Validation rule stopping this.
                if(bw.DiscountAmount > 0 && Decimal.valueOf(bw.Quantity) > 0) {
                    oli.Discount_Amount__c = bw.DiscountAmount / Decimal.valueOf(bw.Quantity);
                }
            oli.Cost_Price__c = bw.CostPrice; // Unit Price
            // oli.Cost_Price__c = bw.TotalPrice;
            oli.orderId = ord.Id;
            lstOrderItems.add(oli);
        }
        
        insert lstOrderItems;
        
        return [SELECT Id, OrderNumber FROM ORDER WHERE ID =: ord.ID];
    }
}