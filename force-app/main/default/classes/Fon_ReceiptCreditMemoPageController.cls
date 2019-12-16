public with sharing class Fon_ReceiptCreditMemoPageController{
    static String strRefund = 'Refund';
    static String strInvoiceStatusCancel = 'Cancelled';
    @AuraEnabled
    public static OrderApi__Receipt__c createCreditMemo(String receiptId){
        Set<Id> invoiceIdSet = new Set<Id>();
        List<OrderApi__Credit_Memo__c> lstCreditMemorecord = new List<OrderApi__Credit_Memo__c>();
        List<OrderApi__Receipt_Line__c> lstReceiptLine = new List<OrderApi__Receipt_Line__c>();
        OrderApi__Receipt__c objReceipt = [SELECT Id,OrderApi__Payment_Type__c,OrderApi__Deposit_Account__c,OrderApi__Memo__c,OrderApi__Is_Posted__c,OrderApi__Contact__c,OrderApi__Account__c,OrderApi__Applied_Amount__c,
                                           OrderApi__Sales_Order__c,OrderApi__Receipt__c,
                                           OrderApi__Business_Group__r.OrderApi__Credit_Memo_Account__c,OrderApi__Type__c,Is_Credit_Memo_Existed__c,OrderApi__Business_Group__c,OrderApi__Entity__c,
                                           (SELECT Id,OrderApi__Receipt__r.OrderApi__Deposit_Account__c,OrderApi__Receipt__c,
                                            OrderApi__Receipt__r.OrderApi__Business_Group__r.OrderApi__Credit_Memo_Account__c,OrderApi__Invoice__c,
                                            OrderApi__Price_Override__c,OrderApi__Price_Rule__c,OrderApi__Item__c,OrderApi__Tax_Override__c,OrderApi__Tax_Percent__c,
                                            OrderApi__Sale_Price__c,OrderApi__Quantity__c,OrderApi__Business_Group__c,OrderApi__Subscription_Plan__c,OrderApi__Activation_Date__c,
                                            OrderApi__Line_Description__c,OrderApi__GL_Account__c,OrderApi__Total__c,OrderApi__Calculate_Shipping_Details__c 
                                            FROM OrderApi__Receipt_Lines__r) FROM OrderApi__Receipt__c WHERE Id =:receiptId];
        for(OrderApi__Receipt_Line__c objReceiptLine : objReceipt.OrderApi__Receipt_Lines__r){
            lstCreditMemorecord.add(fetchCreditMemoInstance(objReceiptLine, objReceipt));
            lstReceiptLine.add(fetchReceiptLineRecords(objReceiptLine));
            if(!String.isBlank(objReceiptLine.OrderApi__Invoice__c)){
                invoiceIdSet.add(objReceiptLine.OrderApi__Invoice__c);
            }
        }
        if(!lstCreditMemorecord.isEmpty()){
            insert lstCreditMemorecord;
            Set<Id> insertedCreditMemoIds = new Set<Id>();
            if(lstCreditMemorecord.size()>0){
                for(OrderApi__Credit_Memo__c CM:lstCreditMemorecord){
                    insertedCreditMemoIds.add(CM.Id);
                    CM.OrderApi__Status__c='Posted';
                }
                update lstCreditMemorecord;
                
                if(!insertedCreditMemoIds.isEmpty()){
                    Datetime sysTime = System.now();
                    sysTime = sysTime.addSeconds(20);
                    String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
                    Fon_deleteTransactionSchedule scheduler = new Fon_deleteTransactionSchedule(insertedCreditMemoIds);
                    String name = Label.Fon_callBatch + String.valueOf(DateTime.now());
                    //Schedule the next job, and give it the system time so name is unique
                    System.schedule(name,chron_exp,scheduler);
                }
            }
        }
        OrderApi__Receipt__c objRefundReceipt = createRefundReceipt(objReceipt);
        insert objRefundReceipt;
        
        for(OrderApi__Receipt_Line__c eachReceiptLine : lstReceiptLine){
            eachReceiptLine.OrderApi__Receipt__c = objRefundReceipt.id;
        }
        if(!lstReceiptLine.isEmpty()){
            insert lstReceiptLine;
        }
        objRefundReceipt.OrderApi__Is_Posted__c = true;
        update objRefundReceipt;
        List<OrderApi__Invoice__c> lstInvoice = new List<OrderApi__Invoice__c>();
        for(id eachInvoiceId : invoiceIdSet){
            lstInvoice.add(new OrderApi__Invoice__c(id=eachInvoiceId,OrderApi__Status__c=strInvoiceStatusCancel));
        }
        if(!lstInvoice.isEmpty()){
            update lstInvoice;
        }
        return objRefundReceipt;
    }
    
    public static OrderApi__Credit_Memo__c fetchCreditMemoInstance(OrderApi__Receipt_Line__c objReceiptLineARG, OrderApi__Receipt__c objReceipt){
        OrderApi__Credit_Memo__c objCreditMemo = new OrderApi__Credit_Memo__c();
        objCreditMemo.OrderApi__Debit_Account__c = (objReceiptLineARG.OrderApi__Receipt__r != null) ? objReceiptLineARG.OrderApi__Receipt__r.OrderApi__Deposit_Account__c : null;
        objCreditMemo.Fon_Credit_Memo_Account__c = (objReceiptLineARG.OrderApi__Receipt__r != null) ? ((objReceiptLineARG.OrderApi__Receipt__r.OrderApi__Business_Group__r != null) ? 
                                                                                                       objReceiptLineARG.OrderApi__Receipt__r.OrderApi__Business_Group__r.OrderApi__Credit_Memo_Account__c : null) : null;
        
        objCreditMemo.OrderApi__Contact__c = objReceipt.OrderApi__Contact__c;
        objCreditMemo.OrderApi__Account__c = objReceipt.OrderApi__Account__c;
        objCreditMemo.OrderApi__Entity__c = objReceipt.OrderApi__Entity__c;
        objCreditMemo.OrderApi__Amount__c = objReceiptLineARG.OrderApi__Total__c;
        objCreditMemo.OrderApi__Business_Group__c = objReceipt.OrderApi__Business_Group__c;
        objCreditMemo.OrderApi__Debit_Account__c = objReceipt.OrderApi__Deposit_Account__c;
        objCreditMemo.OrderApi__Posted_Date__c = Date.today();
        objCreditMemo.Fon_Receipt_Line__c = objReceiptLineARG.Id;
        objCreditMemo.Fon_Receipt__c = objReceiptLineARG.OrderApi__Receipt__c;
        objCreditMemo.Fon_Credit_Memo_Account__c = objReceipt.OrderApi__Business_Group__r.OrderApi__Credit_Memo_Account__c;
        return objCreditMemo;
    }
    
    public static OrderApi__Receipt__c createRefundReceipt(OrderApi__Receipt__c objReceipt){
        OrderApi__Receipt__c objRefundReceipt = new OrderApi__Receipt__c();
        objRefundReceipt.OrderApi__Contact__c = objReceipt.OrderApi__Contact__c ;
        objRefundReceipt.OrderApi__Account__c = objReceipt.OrderApi__Account__c ;
        objRefundReceipt.OrderApi__Entity__c = objReceipt.OrderApi__Entity__c;
        objRefundReceipt.OrderApi__Type__c = strRefund;
        objRefundReceipt.OrderApi__Deposit_Account__c = objReceipt.OrderApi__Business_Group__r.OrderApi__Credit_Memo_Account__c;
        objRefundReceipt.OrderApi__Memo__c = Label.Fon_CreditMemoCreated;
        objRefundReceipt.OrderApi__Sales_Order__c = objReceipt.OrderApi__Sales_Order__c;
        //objRefundReceipt.OrderApi__Is_Posted__c = true;
        objRefundReceipt.OrderApi__Receipt__c = objReceipt.Id;
        objRefundReceipt.OrderApi__Payment_Type__c =objReceipt.OrderApi__Payment_Type__c;
        return objRefundReceipt;
    }
    
    public static OrderApi__Receipt_Line__c fetchReceiptLineRecords(OrderApi__Receipt_Line__c objReceiptLine){
        return objReceiptLine.clone(); 
    }
}