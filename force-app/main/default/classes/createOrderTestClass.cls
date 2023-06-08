@isTest
public class createOrderTestClass {
	@testSetup
    static void setup(){
        //Create Account
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Account_Number__c = 'SampleID';
        acc.Discount__c = 10;
        insert acc;
        
        //Create Opportunity
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.id;
        opp.CloseDate = Date.today();
        opp.StageName = 'Qualification';
        insert opp;
        
        //Create Product Records

            Product2 prod = new Product2();
            prod.Name = 'ADONQNDSKL';
            prod.ProductCode = 'ADONQNDSKL';
        	prod.Unique_Product__c='sampleproduct';
            prod.IsActive = true;
        
        insert prod; 
        
        Id pricebookId = Test.getStandardPricebookId();
  		PricebookEntry priceBookEntryA = new PricebookEntry();
        priceBookEntryA.Pricebook2Id =pricebookId;//'01s5f000001oxN5AAI';
        priceBookEntryA.UnitPrice =22.00;
        priceBookEntryA.Product2Id=prod.Id;
        PriceBookEntryA.Pricebook_Unique__c ='Test';
        PriceBookEntryA.IsActive = true;
        insert priceBookEntryA;
        
        
/*        
        //Create PriceBook2 records
        PRICEBOOK2 priceBook2 = new PRICEBOOK2();
        priceBook2.Name = 'Standard Price Book';
        priceBook2.IsActive = true;
        insert priceBook2;
        
        //Create Price Book Entry Records
        
            PricebookEntry pbEntry = new PricebookEntry();            
            pbEntry.Product2Id = prod.Id;
            pbEntry.UnitPrice = 5000; 
            pbEntry.UseStandardPrice = false;
        	pbEntry.Pricebook2Id = priceBook2.Id;
//            pbEntry.Pricebook2Id = Test.getStandardPricebookId(); 
        	pbEntry.IsActive = true;
        	pbEntry.Pricebook_Unique__c ='Test';
			
        insert pbEntry;
*/        
        //Create a Quote
        Quote qt = new Quote();
        qt.Name = 'Test Quote';
        qt.OpportunityId = opp.Id;
        qt.Pricebook2Id = pricebookId;
//        qt.Pricebook2Id = Test.getStandardPricebookId();
        
		insert qt;
        
        QuoteLineItem qtLine1 = new QuoteLineItem();
        qtLine1.QuoteId = qt.Id;
        qtLine1.Product2Id = prod.Id;
        qtLine1.PricebookEntryId = priceBookEntryA.Id;
        qtLine1.UnitPrice = 5.00;
        qtLine1.Quantity = 1;
        
        insert qtLine1;
    
    }
    
    @isTest
    static void testCreateOrder(){
        list<Quote> quoteList = [SELECT ID,Name FROM Quote];
        list<String> parameterList = new list<String>();
        list<list<String>> parameters = new list<list<String>>();
        parameters.add(parameterList);
        parameterList.add(quoteList[0].id);
        parameterList.add('Sample Text');
        parameterList.add('Special Comments');
        Test.startTest();
        	createOrders.createOrdersWithBidLineItems(parameters);
        Test.stopTest();
        
    }
    
    
    
}