/************************************************************************************************************************************
* @Name         :OrderTrigger 
* @Date         :04/05/2022
* @Group        :Altokk Software Solutions
* @Description  :This class is triggered when a order is created.
*************************************************************************************************************************************/

trigger OrderTrigger on Order (after insert, After Update) {
    
     if((Trigger.isAfter && Trigger.isInsert))
        {
              OrderTriggerHandlerClass.RemoveProductFromPriceBook(Trigger.New);
        }
    
    else if(Trigger.isAfter && Trigger.isUpdate){
        
        OrderTriggerHandlerClass.RemoveProductFromPriceBook(Trigger.New);
        OrderTriggerHandlerClass.updateHiddenFieldsForTaland(Trigger.New,Trigger.oldMap);
            
    }

}