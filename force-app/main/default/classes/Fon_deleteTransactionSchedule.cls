public class Fon_deleteTransactionSchedule implements Schedulable{
    Set<Id> creditMemoIds = new Set<Id>();
    Set<Id> oldTransactionIds = new Set<Id>();
    public Fon_deleteTransactionSchedule(Set<Id> cmIds){
        creditMemoIds.addAll(cmIds);
    }
    public Fon_deleteTransactionSchedule(Id creditmemoId,Set<Id> oldTransactionIds){
        creditMemoIds.add(creditmemoId);
        this.oldTransactionIds.addAll(oldTransactionIds);
    }
    public void execute(SchedulableContext sc){
        Fon_deleteTransactionBatch btch = new Fon_deleteTransactionBatch(creditMemoIds,oldTransactionIds);
        Database.executeBatch(btch,200);
        System.abortJob(sc.getTriggerID());
    }
}