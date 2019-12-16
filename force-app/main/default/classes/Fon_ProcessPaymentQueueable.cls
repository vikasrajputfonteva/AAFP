global class Fon_ProcessPaymentQueueable implements Queueable,Database.AllowsCallouts{
    List<OrderApi__Sales_Order__c> lstSalesOrder = new List<OrderApi__Sales_Order__c>();
   
    global Fon_ProcessPaymentQueueable(List<OrderApi__Sales_Order__c> lstSo){
        lstSalesOrder.addAll(lstSo);        
    }   
    
    global void execute(QueueableContext context) {
        Set<Id> resultIds = (new Map<Id,OrderApi__Sales_Order__c>(lstSalesOrder)).keySet();
        Fon_ActivationCodeForPaymentId.separateSalesOrder(resultIds);
    }
}