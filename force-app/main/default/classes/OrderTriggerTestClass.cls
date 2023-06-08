/************************************************************************************************************************************
* @Name         :OrderTriggerTestClass 
* @Date         :04/05/2022
* @Group        :Altokk Software Solutions
* @Description  :This is test class for  trigger when a order is created.
*************************************************************************************************************************************/

@isTest
public class OrderTriggerTestClass {
    
    @TestSetup
    public static void createOrder() {
        Account account = new Account();
        account.Name ='testAccount';
        account.Account_Number__c ='123456';
        insert account;
         
        
        Order order = new Order();
        order.status = 'Draft';
        order.Order_Type__c ='Open Order';
        order.AccountId =account.Id;
        order.EffectiveDate =system.today();
        order.Pricebook2Id =test.getStandardPricebookId();
        insert order;
        

        Product2 product = new Product2();
        product.Name = 'Product1';
        product.Serial_Number__c ='123456';
        product.Unique_Product__c ='un';
        product.Quantity_Available__c=20;
        product.IsActive=true;
        insert product;
               
        PricebookEntry priceBookEntry = new PricebookEntry();
        priceBookEntry.Pricebook2Id = test.getStandardPricebookId();
        priceBookEntry.UnitPrice =22.00;
        priceBookEntry.Product2Id=product.Id;
        priceBookEntry.Pricebook_Unique__c ='123';
        insert priceBookEntry;
        
        OrderItem orderitem = new OrderItem();
        orderItem.OrderId=order.Id;
        orderItem.Product2Id =product.Id;
        orderItem.PricebookEntryId=priceBookEntry.Id;
        orderItem.UnitPrice =22.00;
        orderItem.Quantity=1;
        insert OrderItem;
    }
    
    @isTest
    public static void cloneProductsTest() {
        List<Order> order = [SELECT Id,status from Order];
        for(order o: order )
        {
        o.status ='Activated';
        }
       Test.startTest();
        update order;
        Test.stopTest();
        
    }
    
    @isTest
    public static void updateOrderType(){
        List<Order> order = [SELECT Id,Order_Type__c from Order];
        for(order o: order )
        {
            o.Order_Type__c ='Order';
        }
        Test.startTest();
        update order;
        Test.stopTest();
    }
}