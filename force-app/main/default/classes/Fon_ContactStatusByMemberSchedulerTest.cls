@isTest
public class Fon_ContactStatusByMemberSchedulerTest {
static testmethod void schedulerTest(){
        String CRON_EXP = '0 0 0 15 3 ? *';
        Test.startTest();
            String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new Fon_ContactStatusByMemberBatchScheduler());
        Test.stopTest();
    }
}