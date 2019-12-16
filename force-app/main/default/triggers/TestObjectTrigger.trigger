trigger TestObjectTrigger on Fon_Test_Object__c(before insert, before update, before delete,
                                  after insert, after update, after delete) {
   Framework.Dispatcher.dispatchTrigger();
}