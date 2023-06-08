/************************************************************************************************************************************
* @Name         :OrderService 
* @Date         :04/05/2022
* @Group        :Altokk Software Solutions
* @Description  :This class is service class for a trigger when a order is created.
*************************************************************************************************************************************/

public class OrderService {
 public static List<OrderItem> getOrderItems(String OrderId){
           List<OrderItem>  OrderItems = [SELECT Id, PricebookEntryId, Product2Id, OrderId,Quantity,IsDeleted FROM OrderItem where OrderId= :OrderId];
           return OrderItems;
 }
    
    public static List<Product2> getProducts(List<String> ProductIds){
     List<Product2> products = [SELECT Id,Name,IsActive,Quantity_Available__c FROM Product2 where ID IN : ProductIds];
        return products;
    }
    /* public static Product2 getClonedProducts(String productName){
     Product2 clonedProduct = [SELECT Id, Name, Serial_Number__c, Unique_Product__c, Number_in_Inventory__c, TOR_Hub__c, MTL_Hub__c, Toronto_Showroom__c, Montreal_Showroom__c, Toronto__c, Montreal__c, Quantity_Available__c FROM Product2 where Unique_Product__c =: productName];
        return clonedProduct;
    }*/
}