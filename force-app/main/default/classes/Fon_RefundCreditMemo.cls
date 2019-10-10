public without sharing class Fon_RefundCreditMemo {
    public String creditMemoId;
    public List<OrderApi__Credit_Memo__c> creditMemoRecord = new List<OrderApi__Credit_Memo__c>();
    public List<OrderApi__Transaction__c> existingTransactionList= new List<OrderApi__Transaction__c>();
    Set<Id> existingTransactionIds = new Set<Id>();
    List<OrderApi__Item__c> creditMemoRefundItem = new List<OrderApi__Item__c>();
    
    public Fon_RefundCreditMemo(ApexPages.StandardController controller){
        creditMemoRefundItem= [select id from OrderApi__Item__c where Name=:Label.Fon_CreditMemoRefundItem And OrderApi__Is_Active__c=true];
        creditMemoId=controller.getId();//Current Record Id
        if(String.isNotBlank(creditMemoId)){
            creditMemoRecord=[select OrderApi__Remaining_Amount__c,
                              Fon_Receipt_Line__r.OrderApi__GL_Account__c,
                              Fon_Receipt__r.OrderApi__Contact__c,
                              Fon_Receipt__r.OrderApi__Account__c,
                              Fon_Receipt__r.OrderApi__Payment_Type__c,
                              Fon_Receipt__r.OrderApi__Business_Group__c
                              from OrderApi__Credit_Memo__c where Fon_Receipt__c!=Null And Id=:creditMemoId];
            existingTransactionList=[select id from OrderApi__Transaction__c where OrderApi__Credit_Memo__c=:creditMemoId];
            if(existingTransactionList.size()>0){
                existingTransactionIds=(new Map<Id,OrderApi__Transaction__c>(existingTransactionList)).keySet();
            }
        }
    }
    
    public PageReference createCreditMemoline(){
        Id newReceiptId;
        if(creditMemoRecord.size()>0){
            //Creating Credit Memo line
            OrderApi__Credit_Memo_Line__c cml = new OrderApi__Credit_Memo_Line__c();
            cml.OrderApi__Credit_Memo__c=creditMemoId;//Create credit Memo line will be created under the Credit Memo 
            cml.OrderApi__Amount__c=creditMemoRecord[0].OrderApi__Remaining_Amount__c;//Amount same as the remaining amount on the Credit Memo
            if(creditMemoRecord[0].Fon_Receipt_Line__r.OrderApi__GL_Account__c!=null){
                cml.OrderApi__Credit_Account__c=creditMemoRecord[0].Fon_Receipt_Line__r.OrderApi__GL_Account__c; //Liability Account as one of GL Account on the receipt lines
            }
            Insert cml;
            
            cml.OrderApi__Status__c='Posted';//The Credit Memo line will be posted 
            update cml;
            
            //The transactions created as a result of posting will be deleted
            Datetime sysTime = System.now();
            sysTime = sysTime.addSeconds(15);
            String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            Fon_deleteTransactionSchedule scheduler = new Fon_deleteTransactionSchedule(creditMemoId,existingTransactionIds);
            String name = Label.Fon_callBatch  + String.valueOf(DateTime.now());
            //Schedule the next job, and give it the system time so name is unique
            System.schedule(name,chron_exp,scheduler);
            //A new Refund receipt will be created from this receipt
            newReceiptId=createRefundReceipt(creditMemoRecord[0].OrderApi__Remaining_Amount__c);            
        }
        PageReference pr;
        if(newReceiptId!=Null){
            pr= new PageReference('/'+newReceiptId);
        }
        else{
            pr= new PageReference('/'+creditMemoId);
        }
        
        pr.setRedirect(true);
        return pr;
    }
    
    public Id createRefundReceipt(Decimal remainingAmountOfCreditMemo){
        OrderApi__Receipt__c receipt = new OrderApi__Receipt__c();
        receipt.OrderApi__Type__c='Refund';
        receipt.OrderApi__Contact__c=creditMemoRecord[0].Fon_Receipt__r.OrderApi__Contact__c;
        receipt.OrderApi__Account__c=creditMemoRecord[0].Fon_Receipt__r.OrderApi__Account__c;
        receipt.OrderApi__Business_Group__c=creditMemoRecord[0].Fon_Receipt__r.OrderApi__Business_Group__c;
        receipt.OrderApi__Memo__c=Label.Fon_CreditMemoRefunded;//The Memo field on the receipt will be populated as ‘Credit Memo Refunded’
        receipt.Fon_Credit_Memo__c=creditMemoId;
        receipt.OrderApi__Total__c=remainingAmountOfCreditMemo;
        receipt.OrderApi__Payment_Type__c=creditMemoRecord[0].Fon_Receipt__r.OrderApi__Payment_Type__c;
        insert receipt;
        
        receipt.OrderApi__Is_Posted__c=true;//The Receipt will be posted
        update receipt;
        
        //A new Receipt line will be created under the Receipt 
        OrderApi__Receipt_Line__c rl= new OrderApi__Receipt_Line__c();
        rl.OrderApi__Receipt__c=receipt.Id;
        rl.OrderApi__Item__c=creditMemoRefundItem[0].Id;//the lookup to the ‘Credit Memo Refund Item’ on the Item field
        rl.OrderApi__Price_Override__c=true;
        rl.OrderApi__Sale_Price__c=  remainingAmountOfCreditMemo;
        insert rl;
        
        return receipt.Id;
    }
}