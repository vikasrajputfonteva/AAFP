/**
* Domain class for the Fon_RenewalTriggerHandler SObjectType
**/
global class Fon_RenewalTriggerDomain extends Framework.Domain{
    public Fon_RenewalTriggerDomain(List<OrderApi__Renewal__c> sObjectList) {
        super(sObjectList);
    }
    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new Fon_RenewalTriggerDomain(sObjectList);
        }
    }
    public override void afterInsert(){
        new Fon_RenewalTriggerHandler().updateReinstatedDate( (List<OrderApi__Renewal__c>) Trigger.new); 
        new Fon_SubscriptionTriggerHandler().calcTotalMonthOfMembership((List<OrderApi__Renewal__c>) Trigger.new);
    }
    /* Need to un-comment the code if term is paid later after creation
    public override void afterUpdate(Map<Id,SObject> oldMap){
        new Fon_RenewalTriggerHandler().updateReinstatedDate( (List<OrderApi__Renewal__c>) Trigger.new); 
    }
    */
}