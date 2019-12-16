public class Fon_ActivationCodeForPaymentId {
    
    public static void separateSalesOrder(Set<Id> salesOrderIds){
        Set<Id> invoiceIds = new Set<Id>();
        if(!salesOrderIds.isEmpty()){
            List<OrderApi__Sales_Order__c> salesOrderList = [select id,OrderApi__Posting_Entity__c,OrderApi__Posting_Status__c,(select id from OrderApi__Invoices__r where OrderApi__Invoice_Date__c=:System.today() limit 1) from OrderApi__Sales_Order__c where is_Dues_Paid_by_Chapter_Residency__c=false And OrderApi__Payment_Method__c !=Null And OrderApi__Total__c>0 And Id In :salesOrderIds];
            if(salesOrderList.size()>0){
                for(OrderApi__Sales_Order__c objSO:salesOrderList){
                    if(objSO.OrderApi__Posting_Entity__c=='Invoice' && objSO.OrderApi__Posting_Status__c=='Posted'){
                        List<OrderApi__Invoice__c> invoiceList = objSO.OrderApi__Invoices__r;
                        if(invoiceList.size()>0){
                            for(OrderApi__Invoice__c objInv:invoiceList){
                                invoiceIds.add(objInv.Id);
                            }
                            createEpaymentRecordForInvoice(invoiceIds);
                        }
                    }
                }
            }
        }
    }
    public static void createEpaymentRecordForInvoice(Set<Id> invoiceIds){
        if(!invoiceIds.isEmpty()){//Creating Epayment Records of Invoice
            OrderApi.EPayment epaymentObj = new OrderApi.EPayment();
            List<OrderApi__Invoice__c> invoices = (List<OrderApi__Invoice__c>) new Framework.Selector(OrderApi__Invoice__c.SObjectType,OrderApi__Invoice_Line__c.OrderApi__Invoice__c).selectById(invoiceIds);
            if(invoices.size()>0){
                epaymentObj.buildEpayment(invoices);
                epaymentObj.constructEPayment();
                ID jobID = System.enqueueJob(new Fon_ProcessEpaymentPaymentQueueable(invoiceIds));
            }
        }  
    }
}