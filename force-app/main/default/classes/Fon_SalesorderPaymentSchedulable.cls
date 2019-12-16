public class Fon_SalesorderPaymentSchedulable implements Schedulable{
    private set<Id> membershipStaging;
    public Fon_SalesorderPaymentSchedulable(set<Id> stagingIds){
        this.membershipStaging = stagingIds;
    }
    public void execute(SchedulableContext sc){
        Fon_SalesorderPaymentBatch btch = new Fon_SalesorderPaymentBatch(membershipStaging);
        Database.executeBatch(btch,1);
        //remove from scheduled job list
        System.abortJob(sc.getTriggerID());
    }
}