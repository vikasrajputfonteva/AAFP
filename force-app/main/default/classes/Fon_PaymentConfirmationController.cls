public class Fon_PaymentConfirmationController {
    
    public String salesOrderId{get;set;}
    public list<OrderApi__Sales_Order_Line__c> salesOrderLine{get;set;}
    public Fon_PaymentConfirmationController (){
        
        salesOrderId=apexpages.currentpage().getparameters().get('id');
        system.debug('salesOrderId'+salesOrderId);
        list<String> salesOrderIds = salesOrderId.split(',');
        
        salesOrderLine=[select OrderApi__Sales_Order__r.Name,OrderApi__Item__r.name,OrderApi__Contact__r.name,OrderApi__Total__c from OrderApi__Sales_Order_Line__c where OrderApi__Sales_Order__c IN :salesOrderIds ];
        system.debug('salesOrderLine'+salesOrderLine);
    }
}