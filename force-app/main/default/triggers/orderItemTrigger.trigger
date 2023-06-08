trigger orderItemTrigger on OrderItem (after insert,after update,after delete) {
	
    if(Trigger.isAfter){
        if(Trigger.IsInsert || Trigger.isUpdate){
            orderItemTriggerHandler.updateHiddenFieldsInOrderForTaland(Trigger.New);
        }
        else if(Trigger.isDelete){
            orderItemTriggerHandler.updateHiddenFieldsInOrderForTaland(Trigger.Old);
        }
    }
}