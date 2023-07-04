public with sharing class BidHandler {
    @AuraEnabled
    public static List<Account> getAccountById(String id) {
        try {
            return [SELECT ID, Name, Discount__c FROM ACCOUNT WHERE ID=:id WITH SECURITY_ENFORCED];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<Opportunity> getAccountRecordByOpptyId(String id) {
        try {
            return [SELECT Id, AccountId, account.Name, account.Discount__c from Opportunity WHERE ID=:id WITH SECURITY_ENFORCED];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    @AuraEnabled
    public static List<PRICEBOOKENTRY> getUnitPriceByProduct(string product2Id, string pricebookname){
        try {
            return [SELECT Id, UnitPrice, PRICEBOOK2.NAME FROM PRICEBOOKENTRY where isactive = true 
                    and PRICEBOOK2.NAME =:pricebookname
                    AND Product2Id =: product2Id];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Quote SaveMultipleBids(string jsonString, string QuoteName) {
        try {
            List<BidWrapper> wrapperList = (List<BidWrapper>) JSON.deserialize(jsonString, List<BidWrapper>.class);
            Id pricebook2Id = [SELECT ID, NAME FROM PRICEBOOK2 WHERE NAME = 'Standard Price Book'].Id;
            BidWrapper product = wrapperList[0];

            Opportunity opty = new Opportunity();
            opty.Name = 'Opportunity - ' + QuoteName;
            opty.CloseDate = System.today() + 90;
            opty.StageName = 'Qualification';
            opty.AccountId = product.AccountId;
            opty.Pricebook2Id = pricebook2Id;
            insert opty;

            Quote quoteObj = new Quote();
            quoteObj.Name = QuoteName;
            quoteObj.OpportunityId = opty.Id;
            quoteObj.Pricebook2Id = pricebook2Id;
            insert quoteObj;

            List<QuoteLineItem> lstQuoteListItems = new List<QuoteLineItem>();
            for(BidWrapper bw : wrapperList) {
                QuoteLineItem qli = new QuoteLineItem();
                qli.PricebookEntryId = bw.PriceBookEntryId;
                qli.Original_Unit_Price__c = bw.ListPrice;
                qli.UnitPrice  = bw.CostPrice;
                qli.Quantity = Decimal.valueOf(bw.Quantity);
                
                qli.Discount = bw.Discount; // Validation rule stopping this.
                if(bw.DiscountAmount > 0) {
                    qli.Discount_Amount__c = bw.DiscountAmount;
                }
                qli.Cost_Price__c = bw.CostPrice; // Unit Price
                qli.quoteId = quoteObj.Id;
                lstQuoteListItems.add(qli);
            }
            insert lstQuoteListItems;
            return quoteObj;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}