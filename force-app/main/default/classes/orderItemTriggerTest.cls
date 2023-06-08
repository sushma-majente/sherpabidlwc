@isTest
public class orderItemTriggerTest {
	@isTest
    public static void createOrder() {
        // Insert Account
   		Account account = new Account();
        account.Name ='testAccount';
        account.Account_Number__c ='123456';
        account.Discount__c = 10;
        insert account;
        
        Product2 productA = new Product2();
        productA.Name = 'ProductA';
        productA.Serial_Number__c ='123456';
        productA.Unique_Product__c ='un';
        productA.IsActive=true;
        insert productA;
        
        Product2 productB = new Product2();
        productB.Name = 'ProductB';
        productB.Unique_Product__c ='uni';
        productB.IsActive=true;
        insert productB;
        
        Id pricebookId = Test.getStandardPricebookId();
  		PricebookEntry priceBookEntryA = new PricebookEntry();
        priceBookEntryA.Pricebook2Id =pricebookId;//'01s5f000001oxN5AAI';
        priceBookEntryA.UnitPrice =22.00;
        priceBookEntryA.Product2Id=productA.Id;
        PriceBookEntryA.Pricebook_Unique__c ='Test';
        insert priceBookEntryA;
        
        PricebookEntry priceBookEntryB = new PricebookEntry();
        priceBookEntryB.Pricebook2Id =pricebookId;//'01s5f000001oxN5AAI';
        priceBookEntryB.UnitPrice =22.00;
        priceBookEntryB.Product2Id=productB.Id;
        PriceBookEntryB.Pricebook_Unique__c ='Test1';
        insert priceBookEntryB;
        
        
        Order orderA = new Order();      
        orderA.status = 'Draft';
        orderA.Order_Type__c ='Open Order';
        orderA.AccountId =account.Id;
        orderA.EffectiveDate =system.today();
        orderA.Pricebook2Id =pricebookId;//'01s5f000001oxN5AAI';
        insert orderA;
        
        Order orderB = new Order();      
        orderB.status = 'Draft';
        orderB.Order_Type__c ='Order';
        orderB.AccountId =account.Id;
        orderB.EffectiveDate =system.today();
        orderB.Pricebook2Id =pricebookId;//'01s5f000001oxN5AAI';
        insert orderB;

        OrderItem orderitem1 = new OrderItem();
        orderItem1.OrderId=orderA.Id;
        orderItem1.Product2Id =productA.Id;
        orderItem1.PricebookEntryId=priceBookEntryA.Id;
        orderItem1.UnitPrice =22.00;
        orderItem1.Quantity=1;
        insert OrderItem1;
        
        OrderItem orderitem2 = new OrderItem();
        orderitem2.OrderId=orderB.Id;
        orderitem2.Product2Id =productB.Id;
        orderitem2.PricebookEntryId=priceBookEntryB.Id;
        orderitem2.UnitPrice =22.00;
        orderitem2.Quantity=1;
        insert orderitem2;
        
        delete orderitem2;
        
    }
}