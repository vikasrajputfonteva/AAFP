global class Fon_SalesOrderLineItemBatchScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        Fon_SalesOrderLineItemManagerBatch objSOLIBatch = new Fon_SalesOrderLineItemManagerBatch();
        Database.executeBatch(objSOLIBatch); 
    }
}