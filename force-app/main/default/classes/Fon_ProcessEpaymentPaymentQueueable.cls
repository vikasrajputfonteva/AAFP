global class Fon_ProcessEpaymentPaymentQueueable implements Queueable,Database.AllowsCallouts{
    Id epaymentRecordId;
    Id paymentMethodId;
    String paymentMethodToken;
    Id contactId;
    
    Set<Id> invoiceIds = new Set<Id>();
    global Fon_ProcessEpaymentPaymentQueueable(Set<Id> invoicesIds){
        invoiceIds.addAll(invoicesIds);
        
    }
    global void execute(QueueableContext context) {
        if(!invoiceIds.isEmpty()){
            processPaymemtOfEpayment(invoiceIds);
        }
    }
    global void processPaymemtOfEpayment(Set<Id> processInvoicesIds){
        Set<Id> ePaymentIds = new Set<Id>();
        Map<Id,Id> ePaymentVSContact = new Map<Id,Id>();
        Map<Id,Id> ePaymentVSPaymentMethod = new Map<Id,Id>();
        Map<Id,String> ePaymentVSPaymentMethodToken = new Map<Id,String>();
        
        List<OrderApi__EPayment_Line__c> epaymentList = [select id,OrderApi__EPayment__r.OrderApi__Sales_Order__r.OrderApi__Payment_Method__c,OrderApi__EPayment__r.OrderApi__Sales_Order__r.OrderApi__Payment_Method__r.OrderApi__Payment_Method_Token__c,OrderApi__EPayment__r.OrderApi__Sales_Order__r.OrderApi__Contact__c,OrderApi__Sale_Price__c,OrderApi__EPayment__c from OrderApi__EPayment_Line__c where OrderApi__Invoice__c in:processInvoicesIds And OrderApi__EPayment__c!=null];
        if(epaymentList.size()>0){
            for(OrderApi__EPayment_Line__c el:epaymentList){
                ePaymentIds.add(el.OrderApi__EPayment__c);     
                ePaymentVSContact.put(el.OrderApi__EPayment__c,el.OrderApi__EPayment__r.OrderApi__Sales_Order__r.OrderApi__Contact__c);
                ePaymentVSPaymentMethod.put(el.OrderApi__EPayment__c,el.OrderApi__EPayment__r.OrderApi__Sales_Order__r.OrderApi__Payment_Method__c);
                ePaymentVSPaymentMethodToken.put(el.OrderApi__EPayment__c,el.OrderApi__EPayment__r.OrderApi__Sales_Order__r.OrderApi__Payment_Method__r.OrderApi__Payment_Method_Token__c);
            }
        }
        if(!ePaymentIds.isEmpty()){
            for(Id epaymentRecordId:ePaymentIds){
                FDService.PaymentRequest objPR = FDService.PaymentRequest.getInstance();
                objPR.record = epaymentRecordId; //Epayment Record Id
                objPR.paymentGateway = null;
                objPR.paymentMethod = ePaymentVSPaymentMethod.get(epaymentRecordId);
                objPR.paymentMethodToken =ePaymentVSPaymentMethodToken.get(epaymentRecordId);
                objPR.contact = ePaymentVSContact.get(epaymentRecordId);
                FDService.OrderPaymentService.getInstance().pay(objPR);    
            }
        }
    }
}