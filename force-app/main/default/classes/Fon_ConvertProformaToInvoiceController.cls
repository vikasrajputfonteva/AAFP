public without sharing class Fon_ConvertProformaToInvoiceController {
    @AuraEnabled
    public static Map<String,String> convertProformaInvoice(Id salesOrderId){
        Map<String,String> errorVSmsg = new Map<String,String>();
        OrderApi__Sales_Order__c objSalesOrder = null;
        list<OrderApi__Sales_Order__c> lstSalesOrder = [select id,OrderApi__Status__c,OrderApi__Posting_Entity__c,OrderApi__Schedule_Type__c,
                                                        (select id from OrderApi__Sales_Order_Lines__r where OrderApi__Item__r.OrderApi__Is_Subscription__c=true
                                                         AND OrderApi__Subscription_Plan__r.OrderApi__Enable_Schedule__c=TRUE  ) 
                                                        from OrderApi__Sales_Order__c where Id=:salesOrderId AND OrderApi__Status__c='Closed' AND
                                                        OrderApi__Posting_Entity__c='Receipt' AND OrderApi__Is_Posted__c=FALSE];
        if(!lstSalesOrder.isEmpty()){
            for(OrderApi__Sales_Order__c SalesOrder : lstSalesOrder){
                if(SalesOrder.OrderApi__Sales_Order_Lines__r.size()>0){
                    errorVSmsg.put('true',System.Label.Fon_ProformaInvoice);
                }else{
                    SalesOrder.OrderApi__Status__c='Open';//Sales orders to ‘Open’ 
                    SalesOrder.OrderApi__Posting_Entity__c='Invoice';//‘Posting Entity’ equals to Invoice 
                    SalesOrder.OrderApi__Schedule_Type__c='Simple Invoice';//‘Schedule Type’ equals to ‘Simple Invoice’ 
                    objSalesOrder = SalesOrder;
                }
            }
            if(objSalesOrder != null){
                update objSalesOrder;
                objSalesOrder.OrderApi__Status__c='Closed';
                update objSalesOrder;
            }
        }else{
            errorVSmsg.put('true',System.Label.Fon_closedSalesOrder);
        }
        return errorVSmsg;
    }
}