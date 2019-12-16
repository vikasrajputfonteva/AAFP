public class Fon_deleteTransactionBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    Set<Id> creditMemoIds = new Set<Id>();
    Set<Id> oldTransactionIds = new Set<Id>();
    public Fon_deleteTransactionBatch(Set<Id> cmIds,Set<Id> oldTrnsctionIds){
        creditMemoIds.addAll(cmIds);
        oldTransactionIds.addAll(oldTrnsctionIds);
    }
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'select id from OrderApi__Transaction__c where OrderApi__Credit_Memo__c In:creditMemoIds And Id Not In :oldTransactionIds AND OrderApi__Receipt__c=NULL';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<OrderApi__Transaction__c> scope){
        if(scope.size()>0){
            delete scope;
        }
    }
    public void finish(Database.BatchableContext BC) {
    }
}