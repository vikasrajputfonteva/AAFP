global class Fon_ContactStatusByMemberBatchScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        Fon_ContactStatusByMembershipStageBatch objMemberStageBatch = new Fon_ContactStatusByMembershipStageBatch();
        Database.executeBatch(objMemberStageBatch); 
    }
}