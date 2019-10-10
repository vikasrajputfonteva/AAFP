public class Fon_SalesOrderCreditRefundCtrl{
    static String invoicePaidStatus = 'Paid';
    static String paymentType = 'Payment';
     final static String strRefund = 'Refund';
    
    public Fon_SalesOrderCreditRefundCtrl(){}
    
    @AuraEnabled
    public static SalesOrderCreditRefundWrapper fetchSOByCreditAndRefundLine(String recordId){
        SalesOrderCreditRefundWrapper objSalesOrderWrap = new SalesOrderCreditRefundWrapper();
        
        objSalesOrderWrap.lstReceiptLineItem = new List<ReceiptLineItemWrapper>();
        objSalesOrderWrap.lstInvoice = new List<InvoiceWrapper>();
        
        List<OrderApi__Sales_Order__c> lstSalesOrder = [SELECT Id,Name,OrderApi__Contact__r.Id,OrderApi__Contact__r.Name,OrderApi__Contact__r.AAFP_ID__c,
                                                        (SELECT Id,Name,OrderApi__Total__c,OrderApi__Amount_Paid__c FROM OrderApi__Invoices__r WHERE OrderApi__Is_Paid__c =:true),
                                                        (SELECT Id,Name FROM OrderApi__Receipts__r WHERE OrderApi__Type__c =:paymentType AND OrderApi__Is_Posted__c =:true ) FROM OrderApi__Sales_Order__c WHERE Id =:recordId];
        Set<Id> invoiceIdSet = new Set<Id>();
        Set<Id> receiptIdSet = new Set<Id>();
        for(OrderApi__Sales_Order__c eachSalesOrder : lstSalesOrder){
            for(OrderApi__Invoice__c eachInvoice : eachSalesOrder.OrderApi__Invoices__r){
                objSalesOrderWrap.lstInvoice.add(new InvoiceWrapper(eachInvoice));
                invoiceIdSet.add(eachInvoice.Id);
            }
            for(OrderApi__Receipt__c eachReceipt : eachSalesOrder.OrderApi__Receipts__r){
                receiptIdSet.add(eachReceipt.Id);
            }
        }
        Map<Id,Boolean> mapRceiptIdToRefundStatus = refundReceiptAgainstReceipt(receiptIdSet);
        
        if(!lstSalesOrder.isEmpty()){
            objSalesOrderWrap.customerName = lstSalesOrder[0].OrderApi__Contact__r.Name;
            objSalesOrderWrap.aafpId = lstSalesOrder[0].OrderApi__Contact__r.AAFP_ID__c;
            
        }
        List<OrderApi__Invoice__c> lstPaidInvoice = [SELECT Id,Name,OrderApi__Total__c,OrderApi__Amount_Paid__c,(SELECT Id,Name,OrderApi__Sale_Price__c,
                                                                                                                 OrderApi__Quantity__c,OrderApi__Total__c,Fon_Item_Name__c FROM OrderApi__Invoice_Lines__r ) FROM OrderApi__Invoice__c WHERE Id IN:invoiceIdSet];
        objSalesOrderWrap.lstInvoice = new List<InvoiceWrapper>();
        for(OrderApi__Invoice__c eachInvoice : lstPaidInvoice){
            InvoiceWrapper objInvoiceWrap = new InvoiceWrapper(eachInvoice);
            for(OrderApi__Invoice_Line__c eachInvoiceLine : eachInvoice.OrderApi__Invoice_Lines__r ){
                objInvoiceWrap.lstInvoiceLineItem.add(new InvoicLineItemWrapper(eachInvoiceLine));
            }
            objSalesOrderWrap.lstInvoice.add(objInvoiceWrap);
        }
        if(lstPaidInvoice.isEmpty()){
            for(OrderApi__Receipt_Line__c eachReceiptLine : [SELECT Id,Name,OrderApi__Sale_Price__c,OrderApi__Quantity__c,OrderApi__Total__c,OrderApi__Receipt__c,
                                                             Fon_Item_Name__c FROM OrderApi__Receipt_Line__c WHERE OrderApi__Receipt__c IN :receiptIdSet]){
                                                                 objSalesOrderWrap.lstReceiptLineItem.add(new ReceiptLineItemWrapper(eachReceiptLine));
                                                                 //Adding logic to show Refund Alert
                                                                 if(mapRceiptIdToRefundStatus.containsKey(eachReceiptLine.OrderApi__Receipt__c)){
                                                                     objSalesOrderWrap.isRefundReceiptExist = mapRceiptIdToRefundStatus.get(eachReceiptLine.OrderApi__Receipt__c);
                                                                 }
                                                             }
        }
        if(objSalesOrderWrap.lstInvoice.size() > 1){
            objSalesOrderWrap.isMultipleInvoiceExisted = true;
        }
        return objSalesOrderWrap;
    }
    
    public class SalesOrderCreditRefundWrapper{
        @AuraEnabled public String customerName;
        @AuraEnabled public String aafpId;
        @AuraEnabled public List<ReceiptLineItemWrapper> lstReceiptLineItem;
        @AuraEnabled public Boolean isMultipleInvoiceExisted = false;
        @AuraEnabled public List<InvoiceWrapper> lstInvoice;
        @AuraEnabled public Boolean isRefundReceiptExist = false;
    }
    
    public class InvoicLineItemWrapper{
        @AuraEnabled public Boolean isChecked;
        @AuraEnabled public OrderApi__Invoice_Line__c objInvoiceLine;
        @AuraEnabled public Decimal refundAmount;
        @AuraEnabled public Decimal quantity;
        @AuraEnabled public Decimal total;
        @AuraEnabled public Boolean isNotValidQuantity;
        @AuraEnabled public Boolean isNotValidRefund;
        public InvoicLineItemWrapper(OrderApi__Invoice_Line__c objInvoiceLine){
            this.objInvoiceLine = objInvoiceLine;
            this.isChecked = false;
            this.quantity = objInvoiceLine.OrderApi__Quantity__c;
            this.total = objInvoiceLine.OrderApi__Total__c;
            this.refundAmount = objInvoiceLine.OrderApi__Total__c;
        }
        public InvoicLineItemWrapper(){}
    }
    
    public class ReceiptLineItemWrapper{
        @AuraEnabled public Boolean isChecked;
        @AuraEnabled public OrderApi__Receipt_Line__c objReceiptLine;
        @AuraEnabled public Decimal refundAmount;
        @AuraEnabled public Decimal quantity;
        @AuraEnabled public Decimal total;
        @AuraEnabled public Boolean isNotValidQuantity;
        @AuraEnabled public Boolean isNotValidRefund;
        public receiptLineItemWrapper(OrderApi__Receipt_Line__c objReceiptLine){
            this.objReceiptLine = objReceiptLine;
            this.isChecked = false;
            this.quantity = objReceiptLine.OrderApi__Quantity__c;
            this.refundAmount = objReceiptLine.OrderApi__Total__c;
            this.total = objReceiptLine.OrderApi__Total__c;
            this.isNotValidQuantity = false;
            this.isNotValidRefund = false;
        }
    }
    
    public class InvoiceWrapper{
        @AuraEnabled public Boolean isChecked;
        @AuraEnabled public OrderApi__Invoice__c objInvoice;
        @AuraEnabled public List<InvoicLineItemWrapper> lstInvoiceLineItem ;
        public InvoiceWrapper(OrderApi__Invoice__c objInvoice){
            this.isChecked = false;
            this.objInvoice = objInvoice;
            this.lstInvoiceLineItem = new List<InvoicLineItemWrapper>();
        }
        public InvoiceWrapper(){}
    }
    
    @AuraEnabled
    public static void refundInvoiceLine(List<String> lstId, Boolean isReceiptLine,Boolean isCreateCredit, List<OrderApi__Invoice_Line__c> lstInvoiceLine){
        //System.debug('============================'+lstInvoiceLine);
        Map<Id,OrderApi__Invoice_Line__c> mapInvoicIdToObjInv;
        if(lstInvoiceLine != null){    
            mapInvoicIdToObjInv = new Map<Id,OrderApi__Invoice_Line__c>(lstInvoiceLine);
        }
        List<OrderApi__Receipt_Line__c> lstRecpLine = [SELECT Id,Fon_Refund_Quantity__c,Fon_Refund_Amount__c,OrderApi__Invoice_Line__c FROM OrderApi__Receipt_Line__c WHERE OrderApi__Invoice_Line__c IN: mapInvoicIdToObjInv.keySet()];
        for(OrderApi__Receipt_Line__c eachRecLine : lstRecpLine){
            if(mapInvoicIdToObjInv != null && mapInvoicIdToObjInv.containsKey(eachRecLine.OrderApi__Invoice_Line__c)){
                eachRecLine.Fon_Refund_Quantity__c = mapInvoicIdToObjInv.get(eachRecLine.OrderApi__Invoice_Line__c).Fon_Refund_Quantity__c;
                eachRecLine.Fon_Refund_Amount__c = mapInvoicIdToObjInv.get(eachRecLine.OrderApi__Invoice_Line__c).Fon_Refund_Amount__c;
            }
        }
        //System.debug('============================'+lstInvoiceLine);
        //System.debug('============================'+lstRecpLine);
        if(!lstRecpLine.isEmpty()){
            update lstRecpLine;
        }
        Fon_CreateCreditAndRefund.getReceipts(lstId,isReceiptLine,isCreateCredit);
    }
    
    @AuraEnabled
    public static void refundReceiptLine(List<String> lstId, Boolean isReceiptLine,Boolean isCreateCredit, List<OrderApi__Receipt_Line__c> lstReceiptLine){
        if(!lstReceiptLine.isEmpty()){
            update lstReceiptLine;
        }
        Fon_CreateCreditAndRefund.getReceipts(lstId,isReceiptLine,isCreateCredit);
    }
    
    public static Map<Id,Boolean> refundReceiptAgainstReceipt(Set<Id> receiptIdSet){
        Map<Id,Boolean> mapRceiptIdToRefundStatus = new Map<Id,Boolean>();
        for(OrderApi__Receipt__c eachReceipt : [SELECT Id,(SELECT Id FROM OrderApi__Refunds__r) FROM OrderApi__Receipt__c WHERE Id IN :receiptIdSet]){
            if(eachReceipt.OrderApi__Refunds__r != null && !eachReceipt.OrderApi__Refunds__r.isEmpty()){
                mapRceiptIdToRefundStatus.put(eachReceipt.Id,true);
            }
        }
        return mapRceiptIdToRefundStatus;
    }
    
}