@isTest
private class Fon_EpaymentPaymentSchedulabelTest{
    static testmethod void schedulerTest(){
        String CRON_EXP = '0 0 0 15 3 ? *';
        Test.startTest();
        String jobId = System.schedule('Fon_EpaymentPaymentSchedulabelTest',  CRON_EXP, new Fon_EpaymentPaymentSchedulabel());
        Test.stopTest();
    }
}