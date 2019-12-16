/*
    Note: This class has been depricated as per new logic update, Need to remove from Routing Rule configuration setting as well.
*/
/**
*     Domain class for the Fon_SubscriptionTriggerHandler SObjectType
    @Description: No use of code as per new logic change to calculate total month of active membership
**/
global class Fon_SubscriptionTriggerDomain extends Framework.Domain{
    public Fon_SubscriptionTriggerDomain(List<OrderApi__Subscription__c> sObjectList) {
        super(sObjectList);
    }
    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new Fon_SubscriptionTriggerDomain(sObjectList);
        }
    }
    public override void afterUpdate(Map<Id,SObject> oldMap){
        /* 
        Framework.Log.push(Fon_SubscriptionTriggerDomain.class.getName(),'afterUpdate'); 
        new Fon_SubscriptionTriggerHandler().initSubscription( (List<OrderApi__Subscription__c>) Trigger.new, (Map<Id,OrderApi__Subscription__c>) oldMap); 
        Framework.Log.pop();
        */
    }
}