public with sharing class BidHandler {
    @AuraEnabled
    public static List<Account> getAccountById(String id) {
        try {
            return [SELECT ID, Name, Discount__c FROM ACCOUNT WHERE ID=:id WITH SECURITY_ENFORCED];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}