@isTest
private class Fon_SalesorderPaymentSchedulableTest{
    static testmethod void schedulerTest(){
        Fon_Membership_Staging__c mOj =new Fon_Membership_Staging__c();
        mOj.Name='Test';
        mOj.Fon_Staging_Status__c='Active';
        mOj.Fon_Membership_State__c='Alaska';
        mOj.Fon_Membership_Type__c= 'Active';
        mOj.Fon_Year__c='2019';
        mOj.Fon_Membership_Activation_Date__c=System.today();
        mOj.Fon_Join_Date__c=System.today();
        mOj.Fon_Chapter_Join_Date__c=System.today();
        insert mOj;
        
        String CRON_EXP = '0 0 0 15 3 ? *';
        Test.startTest();
        String jobId = System.schedule('Fon_SalesorderPaymentSchedulableTest',  CRON_EXP, new Fon_SalesorderPaymentSchedulable(new Set<Id>{mOj.Id}));
        Test.stopTest();
    }
}