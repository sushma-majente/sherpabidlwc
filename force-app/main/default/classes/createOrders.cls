public class createOrders {
    
    @InvocableMethod(label='Create Orders with Bid Line Items')
    public static void createOrdersWithBidLineItems(list<list<String>> parameterLists){
        list<String> parameterList = parameterLists[0];
        String existingBidId = parameterList[0];
        String referencePONumber = parameterList[1];
		String specialComments = parameterList[2];
        Quote queryQuote = [SELECT Id, Name,
                                      (SELECT Id,Quantity,UnitPrice,QuoteId,Product2Id,PricebookEntryId 
                                       FROM QuoteLineItems),
                                  CreatedDate, OpportunityId, Pricebook2Id, ContactId, QuoteNumber, Status, AccountId
                                  FROM Quote
                                  WHERE ID = :existingBidId];
        createOrder(queryQuote,referencePONumber,specialComments);
    }
    
    public static void createOrder(Quote bid , String referencePONumber, String specialComments){
        	list<Order> ordersToBeInserted = new list<Order>();
        	
        
        //Create Order
        		Order ord = new Order();
                ord.EffectiveDate = Date.valueOf(bid.CreatedDate);
                ord.AccountId = bid.AccountId;
        		ord.QuoteId = bid.Id;
                ord.Status = 'Draft';
        		ord.Order_Type__c = 'Order';
        		ord.OpportunityId = bid.OpportunityId;
        		ord.ShipToContactId = bid.ContactId;
        		ord.Reference__c = referencePONumber;
        		ord.Special_Comments__c = specialComments;
                if(Test.isRunningTest()){
                    ord.Pricebook2Id = Test.getStandardPricebookId(); 
                }
                else {
                    Pricebook2 priceBook = [SELECT ID,Name FROM Pricebook2 WHERE Name = 'Standard Price Book'];
                    ord.Pricebook2Id = priceBook.Id;
                } 
                ordersToBeInserted.add(ord);
                system.debug('ordersToBeInserted' + ordersToBeInserted);
        // Insert Orders
        		Database.SaveResult[] lsr = Database.insert(ordersToBeInserted, false);
        		Id orderId = lsr[0].getId();
        
        //Looping through inserted results
        		for(Database.SaveResult dsr : lsr){
                    if(!dsr.isSuccess()){
                        for(Database.Error err : dsr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                }
        
        // Create Order Items for created order
        	list<OrderItem> orderItemsToBeInserted = new list<OrderItem>();
            for(QuoteLineItem item : bid.QuoteLineItems){
                    OrderItem ordItem = new OrderItem();
                    ordItem.OrderId = orderId;
                    ordItem.Product2Id = item.Product2Id;
                    ordItem.Quantity = item.Quantity;
                    ordItem.UnitPrice = item.UnitPrice;
                    ordItem.PricebookEntryId = item.PricebookEntryId;
                	orderItemsToBeInserted.add(ordItem);
            }
        
            if(orderItemsToBeInserted != null){
				System.debug('Order Items ::' + orderItemsToBeInserted);
                Database.SaveResult[] orderItemResults = Database.insert(orderItemsToBeInserted, false);
            }
     
    }

}