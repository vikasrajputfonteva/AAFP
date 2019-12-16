public class Fon_ApplyCredits {
    
    @AuraEnabled 
    public static void process(String soIds){
        Set<String> finalSo = new Set<String>();
        Set<String> salesOrderIds;
        String temString = soIds.replace('[','');
        String FinalString = temString.replace(']','');
        if(String.isNotBlank(FinalString)){
            List<String> splitSalesOrderIds = FinalString.split(',');
            salesOrderIds = new Set<String>(splitSalesOrderIds);
        }
        for(String ss:salesOrderIds){
            finalSo.add(ss.trim());
        }
        if(!finalSo.isEmpty()){
            String newBatchRecordId = createBatchRecord(system.today());
            Database.executeBatch(new Fon_UpdateInvoiceBatch(finalSo,newBatchRecordId),1);
        }
    }
    public static String createBatchRecord(Date currentDate){
        String BatchName =Label.Fon_AutoAppliedCreditMemoBatch;
        OrderApi__Batch__c newBatch = new OrderApi__Batch__c();
        newBatch.Name= BatchName+currentDate;
        newBatch.OrderApi__Expected_Count__c=1;
        newBatch.OrderApi__Expected_Amount__c=1;
        insert newBatch;
        return newBatch.Id;
    }
}