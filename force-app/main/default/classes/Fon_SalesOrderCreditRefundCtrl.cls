public class Fon_SalesOrderCreditRefundCtrl{
    static String invoicePaidStatus = 'Paid';
    static String paymentType = 'Payment';
    final static String strRefund = 'Refund';
    
    public Fon_SalesOrderCreditRefundCtrl(){}
    
    @AuraEnabled
    public static SalesOrderCreditRefundWrapper fetchSOByCreditAndRefundLine(String recordId){
        Set<Id> receiptIdsss = new  Set<Id> ();
        SalesOrderCreditRefundWrapper objSalesOrderWrap = new SalesOrderCreditRefundWrapper();
        objSalesOrderWrap.lstReceiptLineItem = new List<ReceiptLineItemWrapper>();
        objSalesOrderWrap.lstInvoice = new List<InvoiceWrapper>();
        objSalesOrderWrap.lstReceipt = new List<receiptWrapper>();
        
        List<OrderApi__Sales_Order__c> lstSalesOrder = [SELECT Id,
                                                        Name,
                                                        OrderApi__Contact__r.Id,
                                                        OrderApi__Contact__r.Name,
                                                        OrderApi__Contact__r.AAFP_ID__c,
                                                        (SELECT Id,Name FROM OrderApi__Receipts__r WHERE OrderApi__Type__c =:paymentType AND OrderApi__Is_Posted__c =:true ) 
                                                        FROM OrderApi__Sales_Order__c
                                                        WHERE Id =:recordId];
        Set<Id> invoiceIdSet = new Set<Id>();
        Set<Id> receiptIdSet = new Set<Id>();
        for(OrderApi__Sales_Order__c eachSalesOrder : lstSalesOrder){
            for(OrderApi__Receipt__c eachReceipt : eachSalesOrder.OrderApi__Receipts__r){
                receiptIdSet.add(eachReceipt.Id);
            }
        }
        Map<Id,Boolean> mapRceiptIdToRefundStatus = refundReceiptAgainstReceipt(receiptIdSet);
        
        if(!lstSalesOrder.isEmpty()){
            objSalesOrderWrap.customerName = lstSalesOrder[0].OrderApi__Contact__r.Name;
            objSalesOrderWrap.aafpId = lstSalesOrder[0].OrderApi__Contact__r.AAFP_ID__c;
            
        }
        Set<Id> idSetOfItem = new Set<Id>();
        
        //For Receipt Line
        if(!receiptIdSet.isEmpty()){
            List<OrderApi__Receipt_Line__c> receiptLineList = [SELECT Id,Name,
                                                               OrderApi__Sale_Price__c,Fon_Net_Amount__c,Fon_Amount_Refunded__c,
                                                               OrderApi__Quantity__c,
                                                               OrderApi__Total__c,OrderApi__Receipt__c,OrderApi__Receipt__r.Name,
                                                               Fon_Item_Name__c,
                                                               OrderApi__Item__c,
                                                               OrderApi__Item__r.OrderApi__Item_Class__r.Fon_Is_Main_Membership__c,
                                                               OrderApi__Item__r.OrderApi__Item_Class__r.Fon_Is_State_Membership__c,
                                                               OrderApi__Item__r.OrderApi__Item_Class__r.Fon_Is_Local_Membership__c,
                                                               OrderApi__Item__r.OrderApi__Is_Subscription__c,
                                                               OrderApi__Sales_Order_Line__r.Fon_Net_Amount__c,
                                                               OrderApi__Sales_Order_Line__r.Fon_Amount_Refunded__c                                                              
                                                               FROM OrderApi__Receipt_Line__c WHERE OrderApi__Receipt__c IN :receiptIdSet];
            if(receiptLineList.size()>0){
                for(OrderApi__Receipt_Line__c eachReceiptLine : receiptLineList){
                    //Checking TC-020605 for non-memebrship item
                    Boolean isNonMembershipItem=false;
                    if(!eachReceiptLine.OrderApi__Item__r.OrderApi__Item_Class__r.Fon_Is_Main_Membership__c && !eachReceiptLine.OrderApi__Item__r.OrderApi__Item_Class__r.Fon_Is_State_Membership__c
                       && !eachReceiptLine.OrderApi__Item__r.OrderApi__Item_Class__r.Fon_Is_Local_Membership__c && eachReceiptLine.OrderApi__Item__r.OrderApi__Is_Subscription__c){
                           isNonMembershipItem=true;
                           system.debug('jmd---isNonMembershipItem');
                       }
                    //Checking TC-020605 for non-memebrship item
                    List<ReceiptLineItemWrapper> temp = new List<ReceiptLineItemWrapper>();
                    if(!receiptIdsss.contains(eachReceiptLine.OrderApi__Receipt__c)){
                        objSalesOrderWrap.lstReceipt.add(new receiptWrapper(eachReceiptLine.OrderApi__Receipt__r.Name,temp));
                        receiptIdsss.add(eachReceiptLine.OrderApi__Receipt__c); 
                    }
                    objSalesOrderWrap.lstReceiptLineItem.add(new ReceiptLineItemWrapper(eachReceiptLine,eachReceiptLine.Fon_Net_Amount__c,eachReceiptLine.Fon_Amount_Refunded__c,isNonMembershipItem,eachReceiptLine.OrderApi__Receipt__r.Name,eachReceiptLine.Id));
                    /*  if(idSetOfItem.contains(eachReceiptLine.OrderApi__Item__c)){
for(ReceiptLineItemWrapper objRecWrap : objSalesOrderWrap.lstReceiptLineItem){
if(Id.valueOf(objRecWrap.objReceiptLine.OrderApi__Item__c) == Id.valueOf(eachReceiptLine.OrderApi__Item__c)){
objRecWrap.refundAmount = objRecWrap.refundAmount + eachReceiptLine.OrderApi__Total__c;
objRecWrap.total = objRecWrap.total + eachReceiptLine.OrderApi__Total__c;
}
}
}
else{
//Adding receipt line in the wrapper
objSalesOrderWrap.lstReceiptLineItem.add(new ReceiptLineItemWrapper(eachReceiptLine));
//idSetOfItem.add(eachReceiptLine.OrderApi__Item__c);
}  */
                    
                    //Adding logic to show Refund alert
                    if(mapRceiptIdToRefundStatus.containsKey(eachReceiptLine.OrderApi__Receipt__c)){
                        objSalesOrderWrap.isRefundReceiptExist = mapRceiptIdToRefundStatus.get(eachReceiptLine.OrderApi__Receipt__c);
                    }
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
        @AuraEnabled public List<receiptWrapper> lstReceipt;
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
    
    public class receiptWrapper{
        @AuraEnabled public String receiptName;
        @AuraEnabled public List<ReceiptLineItemWrapper> lstReceiptLine ;
        public receiptWrapper(String receiptName,List<ReceiptLineItemWrapper> lstReceiptLine){
            this.receiptName=receiptName;
            this.lstReceiptLine=lstReceiptLine;
        }
        public receiptWrapper(){}
    }
    
    public class ReceiptLineItemWrapper{
        @AuraEnabled public Boolean isChecked;
        @AuraEnabled public OrderApi__Receipt_Line__c objReceiptLine;
        @AuraEnabled public Decimal refundAmount;
        @AuraEnabled public Decimal quantity;
        @AuraEnabled public Decimal total;
        @AuraEnabled public Boolean isNotValidQuantity;
        @AuraEnabled public Boolean isNotValidRefund;
        @AuraEnabled public Decimal netAmount;
        @AuraEnabled public Boolean isNonMembershipItem;
        @AuraEnabled public Boolean fullyRefunded;
        @AuraEnabled public String txt;
        @AuraEnabled public String receiptLineId;
        
        
        public receiptLineItemWrapper(OrderApi__Receipt_Line__c objReceiptLine,Decimal netAmount,Decimal refundedAmount,Boolean isNonMembershipItem,String txt,String receiptLineId){
            this.receiptLineId=receiptLineId;
            this.txt= txt;
            system.debug('jmd------'+isNonMembershipItem);
            this.isNonMembershipItem=isNonMembershipItem;
            this.objReceiptLine = objReceiptLine;
            this.isChecked = false;
            this.quantity = objReceiptLine.OrderApi__Quantity__c;
            if(refundedAmount== objReceiptLine.OrderApi__Total__c){
                fullyRefunded= true;
            }
            if(netAmount>0 ||  refundedAmount == objReceiptLine.OrderApi__Total__c){
                this.refundAmount = netAmount;
                this.netAmount = netAmount;
                
            }
            else{
                this.refundAmount= objReceiptLine.OrderApi__Total__c;
                this.netAmount= objReceiptLine.OrderApi__Total__c;
            }
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
        if(!lstRecpLine.isEmpty()){
            update lstRecpLine;
        }
        //  Fon_CreateCreditAndRefund.getReceipts(lstId,isReceiptLine,isCreateCredit);
    }
    
    @AuraEnabled
    public static void refundReceiptLine(List<String> lstId, Boolean isReceiptLine,Boolean isCreateCredit, List<OrderApi__Receipt_Line__c> lstReceiptLine,Map<String,String> receiptLineIdVScancelSubscription){
        if(!lstReceiptLine.isEmpty()){
            update lstReceiptLine;
        }
        Fon_CreateCreditAndRefund.getReceipts(lstId,isReceiptLine,isCreateCredit,receiptLineIdVScancelSubscription);
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