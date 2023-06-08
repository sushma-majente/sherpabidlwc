public class orderItemTriggerHandler {
    
    public static void updateHiddenFieldsInOrderForTaland(list<OrderItem> newOrderItemList){
        Integer orderNumber;
        Integer openOrderNumber;
        Set<ID> orderIdSet = new Set<ID>();
        list<Order> orderList = new list<Order>();
        list<Order> ordersToBeUpdated = new list<Order>();
        Map<Id,Integer> orderIdSerialCountMap = new Map<Id,Integer>();
        for(OrderItem eachItem : newOrderItemList){
            orderIdSet.add(eachItem.OrderId); 
        } 
        
        orderList = [SELECT Id,Order_Type__c,Order_LI__c,Open_Order_LI__c,
                     (SELECT ID,Product2Id,Product2.Serial_Number__c,Product2.Name 
                      FROM OrderItems)
                     FROM Order
                     WHERE ID IN:orderIdSet];
/*
        for(Order ord : orderList){
            if(ord.Order_Type__c == 'Open Order'){
                Integer items = 0;
                Map<String,list<String>> productSerialNumbersMap = new Map<String,list<String>>();
                for(OrderItem ordItem : ord.OrderItems){
                    if(productSerialNumbersMap.containsKey(ordItem.Product2.Name)){
                        productSerialNumbersMap.get(ordItem.Product2.Name).add(ordItem.Product2.Serial_Number__c);
                    }
                    else{
                        list<String> temp = new list<String>();
                        temp.add(ordItem.Product2.Serial_Number__c);
                        productSerialNumbersMap.put(ordItem.Product2.Name,temp);
                    }
                }
                if(productSerialNumbersMap.keySet().Size() > 0){
                    for(String eachId : productSerialNumbersMap.keySet()){
                        items += productSerialNumbersMap.get(eachId).size() + 1;
                    }
                }
                orderIdSerialCountMap.put(ord.Id,items);
            }
        }
        
*/        
        for(Order ord : orderList){
            if(ord.Order_Type__c == 'Order'){
                ord.Order_LI__c = ord.orderItems.size();
                ord.Open_Order_LI__c = null;
                ordersToBeUpdated.add(ord);
                orderNumber = ord.orderItems.size();
            }
            else if(ord.Order_Type__c == 'Open Order'){
                ord.Open_Order_LI__c = ord.orderItems.size();
                ord.Order_LI__c = null;
                ordersToBeUpdated.add(ord);
                openOrderNumber = ord.orderItems.size();
            }
        }
        try{
           update ordersToBeUpdated; 
        }
        catch(Exception ex){
            if(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
               newOrderItemList[0].addError('The order cannot be edited once it is in activated status.'); 
            } 
        }
    }
}