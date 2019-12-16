@isTest
private class Fon_SalesOrderLineItemBatchSchedulerTest{
    static testmethod void schedulerTest(){
        String CRON_EXP = '0 0 0 15 3 ? *';
        Test.startTest();
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new Fon_SalesOrderLineItemBatchScheduler());
        Test.stopTest();
    }
}