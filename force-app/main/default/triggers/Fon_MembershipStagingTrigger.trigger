trigger Fon_MembershipStagingTrigger on Fon_Membership_Staging__c (before insert, before update, before delete,after insert, after update, after delete) {
   

   Framework.Dispatcher.dispatchTrigger();
   
  
   
}