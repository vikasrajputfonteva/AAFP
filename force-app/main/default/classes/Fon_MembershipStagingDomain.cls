/**
* Domain class for the Fon_MembershipStagingTriggerHandler SObjectType
**/
global class Fon_MembershipStagingDomain extends Framework.Domain{
    public Fon_MembershipStagingDomain(List<Fon_Membership_Staging__c> sObjectList) {
        super(sObjectList);
    }
    
    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new Fon_MembershipStagingDomain(sObjectList);
        }
    }
    
    public override void afterInsert(){
        Framework.Log.push(Fon_MembershipStagingDomain.class.getName(),'afterInsert'); 
        initMembershipActivation((List<Fon_Membership_Staging__c>) records);
        Framework.Log.pop();
    }
    
    public override void afterUpdate(Map<Id,SObject> mapIdToObjMembership){
        Framework.Log.push(Fon_MembershipStagingDomain.class.getName(),'afterUpdate'); 
        initMembershipActivation((List<Fon_Membership_Staging__c>) records);
        Framework.Log.pop();
    }
    
    public void initMembershipActivation(List<Fon_Membership_Staging__c> records){
        Set<Id> memberStageIdSet = new Set<Id>();
        for(Fon_Membership_Staging__c eachMember : records){
           memberStageIdSet.add(eachMember.Id);
        }
        if(!memberStageIdSet.isEmpty()){
           Fon_MembershipStagingBatch bachable = new Fon_MembershipStagingBatch(memberStageIdSet);
           Database.executeBatch(bachable,50);
        }
    }
    
}