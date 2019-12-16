public class Fon_SubscriptionPlanCtrl{
    
    @AuraEnabled
    public static List<SuscriptionPlanWrapper> fetchAllSuscriptionPlan(String subscriptionId){
        Set<Id> itemIdSet = new Set<Id>();
        List<SuscriptionPlanWrapper> lstSubscribePlanWrap = new List<SuscriptionPlanWrapper>();
        
        for(OrderApi__Subscription__c eachSubscription : [SELECT Id,OrderApi__Item__c,OrderApi__Subscription_Plan__c FROM OrderApi__Subscription__c WHERE Id =:subscriptionId]){
            itemIdSet.add(eachSubscription.OrderApi__Item__c);
        }
        for(OrderApi__Item__c eachItem : [SELECT Id,(SELECT Id,OrderApi__Subscription_Plan__r.Id,OrderApi__Subscription_Plan__r.Name FROM OrderApi__Subscription_Plan_Items__r) FROM OrderApi__Item__c WHERE ID IN:itemIdSet]){
            for(OrderApi__Item_Subscription_Plan__c eachItemSubsPlan : eachItem.OrderApi__Subscription_Plan_Items__r){
                lstSubscribePlanWrap.add(new SuscriptionPlanWrapper(eachItemSubsPlan));
            }
        }
        /*
List<OrderApi__Item_Subscription_Plan__c> lstItemSubscribePlan = [SELECT Name,OrderApi__Subscription_Plan__r.Name,OrderApi__Subscription_Plan__r.Id,
OrderApi__Item__r.Name,OrderApi__Item__r.OrderApi__Item_Class__r.Name FROM OrderApi__Item_Subscription_Plan__c Where 
OrderApi__Item__r.OrderApi__Item_Class__r.Fon_Is_Main_Membership__c = true];
for(OrderApi__Item_Subscription_Plan__c eachPlan : lstItemSubscribePlan){
lstSubscribePlanWrap.add(new SuscriptionPlanWrapper(eachPlan));
}
*/
        return lstSubscribePlanWrap;
    }
    
    public class SuscriptionPlanWrapper {
        @AuraEnabled public String planName;
        @AuraEnabled public String planId;
        public SuscriptionPlanWrapper(OrderApi__Item_Subscription_Plan__c objItemPlanWrap){
            this.planName = objItemPlanWrap.OrderApi__Subscription_Plan__r.Name;
            this.planId = Id.valueOf(objItemPlanWrap.OrderApi__Subscription_Plan__r.Id);
        }
    }
    
    @AuraEnabled
    public static void updatingSubscriptionPlan(String contactId, String membershipId, String oldSubscriptionId, String newSubscriptionId){
        OrderApi__Subscription__c oldSubscription;
        OrderApi__Subscription__c newSubscription;
        Set<Id> subscrIdSet = new Set<Id>();
        subscrIdSet.add(oldSubscriptionId);
        subscrIdSet.add(newSubscriptionId);
        for(OrderApi__Subscription__c  eachSubscribe : fetchSubscription(subscrIdSet)){
            if(eachSubscribe.Id == Id.valueOf(oldSubscriptionId)){
                oldSubscription = eachSubscribe;
            }
            if(eachSubscribe.Id == Id.valueOf(newSubscriptionId)){
                newSubscription = eachSubscribe;
            }
        }
        
    }
    
    public static List<OrderApi__Subscription__c> fetchSubscription(Set<Id> subsriptionIdSet){
        return [select OrderApi__Item__c,OrderApi__Subscription_Plan__r.Name, OrderApi__Subscription_Plan__r.OrderApi__Enable_Schedule__c, 
                OrderApi__Sales_Order_Line__r.name, OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__c FROM OrderApi__Subscription__c WHERE Id IN: subsriptionIdSet];
    }
    //@currentSubscriptionID => Main actvie 
    @AuraEnabled
    public static list<OrderApi__Subscription_Plan__c> changeSubscriptionPlan(Id ContactId, OrderApi__Subscription__c OldsubPlanId, Id NewsubPlanId){
        
        list<OrderApi__Subscription_Plan__c> subscriptionPLan =  [select id,OrderApi__Enable_Schedule__c from OrderApi__Subscription_Plan__c where id=:OldsubPlanId.OrderApi__Subscription_Plan__c];
        if(!subscriptionPLan.isEmpty()){
            if(subscriptionPLan[0].OrderApi__Enable_Schedule__c){
                changePlanInstallmentToFull(ContactId);
            }else{
                changePlanFullToInstallment(ContactId,NewsubPlanId);  
            }
        }
        OldsubPlanId.OrderApi__Subscription_Plan__c = NewsubPlanId;
        update OldsubPlanId;
        return  subscriptionPLan;
    }
    public static sObject changePlanFullToInstallment(Id ContactId, Id NewsubPlanId){
        list<OrderApi__Sales_Order_Line__c> objSalesOrderLine = new list<OrderApi__Sales_Order_Line__c>();
        Set<OrderApi__Sales_Order__c> objSalesOrder = new Set<OrderApi__Sales_Order__c>();
        set<Id> salesOrderSet = new set<Id>();
        list<OrderApi__Sales_Order__c> SO = [select id,OrderApi__Status__c,(select id, OrderApi__Sales_Order__c,OrderApi__Subscription_Plan__c from OrderApi__Sales_Order_Lines__r 
                                                                            Where OrderApi__Is_Renewal__c=true) from OrderApi__Sales_Order__c where 
                                             OrderApi__Contact__c=:ContactId AND (OrderApi__Status__c='Open' OR OrderApi__Status__c='Closed') ];
        if(!SO.isEmpty()){
            for(OrderApi__Sales_Order__c salesOrder : SO){
                if(salesOrder.OrderApi__Sales_Order_Lines__r.size() > 0 && salesOrder.OrderApi__Sales_Order_Lines__r !=null) {
                    for(OrderApi__Sales_Order_Line__c SOLI : salesOrder.OrderApi__Sales_Order_Lines__r){
                        SOLI.OrderApi__Subscription_Plan__c = NewsubPlanId;
                        objSalesOrderLine.add(SOLI);
                        salesOrderSet.add(SOLI.OrderApi__Sales_Order__c);
                        if(salesOrderSet.contains(salesOrder.Id)){
                            salesOrder.OrderApi__Status__c='Closed';
                            objSalesOrder.add(salesOrder);
                        }
                    }
                }
            }
            
        }
        if(!objSalesOrderLine.isEmpty()){
            update objSalesOrderLine;
        }
        
        if(!objSalesOrder.isEmpty()){
            update new List<OrderApi__Sales_Order__c>(objSalesOrder);
        }
        return null;
    }
    
    public static sObject changePlanInstallmentToFull(Id ContactId){
        String salesOrderId = '';
        Decimal Total_Balance_Due=0;
        Set<Id> salesOrderIdSet = new Set<Id>();
        map<Id,Id> SalesOrderVSItem =new map<Id,Id>();
        //list<OrderApi__Scheduled_Payment__c> listoFSchedulePaymnts =new  list<OrderApi__Scheduled_Payment__c>();
        list<OrderApi__Invoice__c> UpdatedinvoiceList=new list<OrderApi__Invoice__c>();
        list<OrderApi__Invoice__c> invoiceList=new list<OrderApi__Invoice__c>();
        list<OrderApi__Invoice_Line__c> invoiceLineList =new  list<OrderApi__Invoice_Line__c>();
        list<OrderApi__Subscription__c> subscriptions= [select OrderApi__Item__c,OrderApi__Subscription_Plan__r.Name, OrderApi__Subscription_Plan__r.OrderApi__Enable_Schedule__c, OrderApi__Sales_Order_Line__r.name, OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__c 
                                                        from OrderApi__Subscription__c where OrderApi__Status__c='Active' AND  OrderApi__Contact__c=:ContactId AND Fon_Is_Main_Membership__c = true];
        if(!subscriptions.isEmpty()){
            for(OrderApi__Subscription__c sub : subscriptions){
                if(sub.OrderApi__Subscription_Plan__r.OrderApi__Enable_Schedule__c){
                    salesOrderIdSet.add(sub.OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__c);
                    SalesOrderVSItem.put(sub.OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__c,sub.OrderApi__Item__c);
                }
            }
        }
        list<OrderApi__Invoice__c> invoices = [select id,OrderApi__Balance_Due__c,OrderApi__Sales_Order__c, OrderApi__Is_Voided__c,
                                               (select id,OrderApi__Is_Cancelled__c from OrderApi__Scheduled_Payments__r ) 
                                               from OrderApi__Invoice__c where OrderApi__Sales_Order__c IN : salesOrderIdSet AND OrderApi__Is_Paid__c = false];
        
        if(!invoices.isEmpty()){
            for(OrderApi__Invoice__c eachInvoice :  invoices){
                eachInvoice.OrderApi__Is_Voided__c = true;
                UpdatedinvoiceList.add(eachInvoice);
                Total_Balance_Due = eachInvoice.OrderApi__Balance_Due__c+ Total_Balance_Due;
                salesOrderId = eachInvoice.OrderApi__Sales_Order__c;
                /*for(OrderApi__Scheduled_Payment__c SP : eachInvoice.OrderApi__Scheduled_Payments__r){
SP.OrderApi__Is_Cancelled__c = true;
listoFSchedulePaymnts.add(SP);
}*/
            }
        } 
        
        if(!UpdatedinvoiceList.isEmpty()){
            update UpdatedinvoiceList;
        }
        
        /* if(!listoFSchedulePaymnts.isEmpty()){
update listoFSchedulePaymnts;
}*/
        if(Total_Balance_Due > 0){
            OrderApi__Invoice__c invoice = CreateNewInvoice(salesOrderId,ContactId);
            invoiceList.add(invoice);
        }
        if(!invoiceList.isEmpty()){
            insert invoiceList;
        } 
        for(OrderApi__Invoice__c eachInvoice :  invoiceList){ 
            OrderApi__Invoice_Line__c invoiceLine = CreateNewInvoiceLine(eachInvoice.Id,SalesOrderVSItem.get(eachInvoice.OrderApi__Sales_Order__c),Total_Balance_Due); 
            invoiceLineList.add(invoiceLine);
        } 
        if(!invoiceLineList.isEmpty()){
            insert invoiceLineList;   
        }
        for(OrderApi__Invoice__c objInvoice : invoiceList){
            objInvoice.OrderApi__Status__c = 'Posted';
        }
        if(!invoiceList.isEmpty()){
            update invoiceList;
        }
        return null;
    }
    
    public static OrderApi__Invoice__c CreateNewInvoice(Id salesOrderId,Id ContactId){
        OrderApi__Invoice__c invoice =new OrderApi__Invoice__c();
        invoice.OrderApi__Contact__c=ContactId;
        invoice.OrderApi__Sales_Order__c = salesOrderId;
        return invoice; 
    }
    
    public static OrderApi__Invoice_Line__c CreateNewInvoiceLine(Id invoiceId,Id itemId,Decimal TotalBalanceDue){
        OrderApi__Invoice_Line__c invoiceLine = new OrderApi__Invoice_Line__c();
        invoiceLine.OrderApi__Invoice__c = invoiceId;
        invoiceLine.OrderApi__Item__c = itemId;
        invoiceLine.OrderApi__Price_Override__c=true;
        invoiceLine.OrderApi__Sale_Price__c=TotalBalanceDue;
        return invoiceLine;
    }   
    
    //public static void fetchInvoices
}