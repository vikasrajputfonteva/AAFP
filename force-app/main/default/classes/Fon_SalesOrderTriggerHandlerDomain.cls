/**
* Domain class for the Fon_SalesOrderTriggerHandler SObjectType
**/
global class Fon_SalesOrderTriggerHandlerDomain extends Framework.Domain{
    public Fon_SalesOrderTriggerHandlerDomain(List<OrderApi__Sales_Order__c> sObjectList) {
        super(sObjectList);
    }
    
    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new Fon_SalesOrderTriggerHandlerDomain(sObjectList);
        }
    }
    
    public override void afterUpdate(Map<Id,SObject> oldMap){
        Framework.Log.push(Fon_SalesOrderTriggerHandlerDomain.class.getName(),'beforeUpdate'); 
        Fon_SalesOrderTriggerHandler.initAction((OrderApi__Sales_Order__c[])records , (Map<Id,OrderApi__Sales_Order__c>) oldMap); 
        Framework.Log.pop();
    }
}