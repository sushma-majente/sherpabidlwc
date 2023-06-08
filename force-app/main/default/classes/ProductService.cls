/************************************************************************************************************************************
* @Name         ProductService 
* @Date         03/05/2022
* @Group        Altokk Software Solutions
* @Description  This class is triggered when a product is created.
* @Dependencies ProductTriggerHandler
*************************************************************************************************************************************/
public class ProductService {
    //Finding out if there is any record already with triggered product name as its unique name.
    public static List<Product2> getProductsNotMatched(String productName ){
        List<Product2> productsNotMatched = [SELECT Id,Name,Unique_Product__c FROM Product2 where Unique_Product__c=:productName];
        return productsNotMatched;
    }
     public static List<Product2> getAllproductsMatched(String productName ){
        List<Product2> productsAllreadyThere = [SELECT Id, Name, Montreal__c, Toronto__c, Number_in_Inventory__c, Toronto_Showroom__c, Montreal_Showroom__c, MTL_Hub__c, TOR_Hub__c, Quantity_Available__c, Serial_Number__c FROM Product2 where Serial_Number__c !=NULL AND Name=:productName];
        return productsAllreadyThere;
    }
 
}