/************************************************************************************************************************************
* @Name         :OrderTriggerHandlerClass 
* @Date         :04/05/2022
* @Group        :Altokk Software Solutions
* @Description  :This class is handler class for a trigger when a order is created.
*************************************************************************************************************************************/

public class OrderTriggerHandlerClass {
    public static void RemoveProductFromPriceBook(List<Order> order){
        System.debug('Order received ::' +order);
        List<Product2> ProductsListToUpdate = new List<Product2>();
        List<Product2> ProductsToUpdate = new List<Product2>();
        List<string> productNames = new List<string>();
        List<String> ProductIds = new List<string>();
        for(order o: order)  
        {
            If(o.Status=='Activated')
            {
                List<OrderItem>  OrderItems = OrderService.getOrderItems(o.ID);
                for(OrderItem ord:OrderItems)
                {
                    System.debug('OrderItems::'+o);
                    ProductIds.add(ord.Product2Id);
                }
                List<Product2> products =OrderService.getProducts(ProductIds);
                
                for(Product2 p:products)
                {
                    for(OrderItem Ord:OrderItems)
                    {
                        if(p.Id == ord.Product2Id)
                        {
                            /* Product2 c =  OrderService.getClonedProducts(p.Name);
Montreal =p.Montreal__c != null?p.Montreal__c : 0;
MontrealShowroom =p.Montreal_Showroom__c != null?p.Montreal_Showroom__c : 0;
MTLHub=p.MTL_Hub__c != null?p.MTL_Hub__c : 0;
TORHub =p.TOR_Hub__c != null?p.TOR_Hub__c : 0;
Toronto =p.Toronto__c != null?p.Toronto__c : 0;
TorontoShowroom =p.Toronto_Showroom__c != null?p.Toronto_Showroom__c : 0;
NumberInInventory =p.Number_in_Inventory__c != null?p.Number_in_Inventory__c : 0;
c.Montreal__c=  c.Montreal__c-Montreal;
c.Montreal_Showroom__c=  c.Montreal_Showroom__c-MontrealShowroom;
c.MTL_Hub__c=  c.MTL_Hub__c-MTLHub;
c.TOR_Hub__c=  c.TOR_Hub__c-TORHub;
c.Toronto__c=  c.Toronto__c-Toronto;
c.Toronto_Showroom__c=  c.Toronto_Showroom__c-TorontoShowroom;
c.Number_in_Inventory__c=  c.Number_in_Inventory__c-NumberInInventory;
if(c.Quantity_Available__c != null)
{
c.Quantity_Available__c= c.Quantity_Available__c-Montreal-MontrealShowroom-MTLHub-TORHub-Toronto-TorontoShowroom-NumberInInventory;
}

ProductsListToUpdate.add(c);
System.debug('ProductsListToUpdate::'+ProductsListToUpdate);*/
                            p.Quantity_Available__c = p.Quantity_Available__c - ord.Quantity;
                            ProductsToUpdate.add(p);
                        }
                    }
                }
            }
        }
        try{
            update ProductsToUpdate;
            // update ProductsListToUpdate;
        }
        catch(exception e){
            System.debug('exception::' +e);
            
        }
        
    }
    
    public static void updateHiddenFieldsForTaland(List<Order> newOrders,Map<ID,Order> oldOrdersMap){
        list<Order> ordersList = new list<Order>();
        Set<Id> orderIdSet = new Set<ID>();
        list<Order> orderListWithOrderItems = new list<Order>();
        list<Order> ordersToBeUpdated = new list<Order>();
        for(Order eachOrder : newOrders){
            if(eachOrder.Order_Type__c != oldOrdersMap.get(eachOrder.Id).Order_Type__c){
                ordersList.add(eachOrder);
            }
        }
        if(ordersList != null && ordersList.size() > 0){
            for(Order eachOrder : ordersList){
                orderIdSet.add(eachOrder.Id);
            }
            orderListWithOrderItems = [ SELECT Id,Order_Type__c,Order_LI__c,Open_Order_LI__c,
                                       (SELECT ID,Product2Id,Product2.Serial_Number__c,Product2.Name 
                                        FROM OrderItems)
                                       FROM Order
                                       WHERE ID IN:orderIdSet];
            for(Order ord : orderListWithOrderItems){
                if(ord.Order_Type__c == 'Order'){
                    ord.Order_LI__c = ord.orderItems.size();
                    ord.Open_Order_LI__c = null;
                    ordersToBeUpdated.add(ord);
                }
                else if(ord.Order_Type__c == 'Open Order'){
                    ord.Open_Order_LI__c = ord.orderItems.size();
                    ord.Order_LI__c = null;
                    ordersToBeUpdated.add(ord);
                }
            }
            try{
                update ordersToBeUpdated; 
            }
            catch(Exception ex){
                
            }
        }
    }
}