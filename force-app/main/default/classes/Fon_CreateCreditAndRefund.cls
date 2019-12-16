public class Fon_CreateCreditAndRefund {
    //Requirement TC-014010 & TC-014009 Start 
    final static String strRefund = 'Refund';
    public static Set<Id> containsParentReceiptLine = new Set<Id>();
    Public static Set<String> selectedReceiptLine = new Set<String>();
    
    @AuraEnabled
    public static Boolean getReceipts(List<String> listOfIds, Boolean isReceiptLine,Boolean isCreateCredit,Map<String,String> receiptLineIdVScancelSubscription){
        List<OrderApi__Receipt_Line__c> refundReceiptLineList = new List<OrderApi__Receipt_Line__c>();
        Set<Id> receiptIds = new Set<Id>();
        if(isReceiptLine && !listOfIds.isEmpty()){//Receipt Line
            selectedReceiptLine.addAll(listOfIds);
            //refundReceiptLineList = [select id,OrderApi__Receipt__c from OrderApi__Receipt_Line__c where Id In:listOfIds];
            refundReceiptLineList  = (List<OrderApi__Receipt_Line__c>)FDService.SearchRequest.getInstance().fields('id,OrderApi__Receipt__c')
                .filter(' Id  IN ({0})',new List<Object>{listOfIds}).executeQuery(OrderApi__Receipt_Line__c.SObjectType);               
            if(refundReceiptLineList.size()>0){
                for(OrderApi__Receipt_Line__c RL:refundReceiptLineList){
                    receiptIds.add(RL.OrderApi__Receipt__c);
                } 
                if(!receiptIds.isEmpty()){
                    if(isCreateCredit){
                        createCredit(receiptIds,receiptLineIdVScancelSubscription);
                    }
                    else{
                        createRefund(receiptIds,receiptLineIdVScancelSubscription); 
                    }
                }
            }
        }
        else{//Invoice Line
            //refundReceiptLineList = [select id,OrderApi__Receipt__c from OrderApi__Receipt_Line__c where OrderApi__Invoice_Line__c In:listOfIds];
            refundReceiptLineList = (List<OrderApi__Receipt_Line__c>)FDService.SearchRequest.getInstance().fields('id,OrderApi__Receipt__c').filter(' OrderApi__Invoice_Line__c  IN ({0})',new List<Object>{listOfIds})
                .executeQuery(OrderApi__Receipt_Line__c.SObjectType);
            
            if(refundReceiptLineList.size()>0){
                for(OrderApi__Receipt_Line__c RL:refundReceiptLineList){
                    receiptIds.add(RL.OrderApi__Receipt__c);
                    selectedReceiptLine.add(RL.Id);
                } 
                if(!receiptIds.isEmpty()){
                    if(isCreateCredit){
                        createCredit(receiptIds,receiptLineIdVScancelSubscription);
                    }
                    else{
                        createRefund(receiptIds,receiptLineIdVScancelSubscription); 
                    }
                }
            }
        }
        return true;
    }
    
    public static void createCredit(Set<Id> receiptIds,Map<String,String> receiptLineIdVScancelSubscription){
        List<OrderApi__Credit_Memo__c> lstCreditMemorecord = new List<OrderApi__Credit_Memo__c>();        
        List<OrderApi__Receipt_Line__c> receiptLineList = new List<OrderApi__Receipt_Line__c>();
        List<OrderApi__Receipt__c> refundReceiptList = new List<OrderApi__Receipt__c>();
        List<OrderApi__Receipt_Line__c> refundReceiptLineList = new List<OrderApi__Receipt_Line__c>();
        List<OrderApi__Receipt_Line__c> nonPackageReceiptLineList = new List<OrderApi__Receipt_Line__c>();
        List<OrderApi__Invoice__c> lstInvoice = new List<OrderApi__Invoice__c>();
        Map<Id,Id> oldReceiptVSnewReceipt = new  Map<Id,Id>();
        Map<Id,Id> newReceiptVSoldReceipt = new  Map<Id,Id>();
        Map<Id,Id> oldReceiptLineIdVSnewCreditMemoId = new Map<Id,Id>();
        Set<Id> invoiceIdSet = new Set<Id>();
        
        Map<Id,Decimal> receiptLineVSrefundAmount = new Map<Id,Decimal>();
        Set<Id> salesorderLineIds = new Set<Id>();
        
        String flds='Id,OrderApi__Applied_Amount__c,OrderApi__Is_Posted__c,OrderApi__Deposit_Account__c,OrderApi__Entity__c,OrderApi__Business_Group__c,OrderApi__Payment_Gateway__c,OrderApi__Contact__c,OrderApi__Account__c,OrderApi__Payment_Method__c,OrderApi__Payment_Type__c,OrderApi__Reference_Number__c,OrderApi__Sales_Order__c,OrderApi__Billing_Contact__c,OrderApi__Billing_Street__c,OrderApi__Billing_City__c,OrderApi__Billing_State__c,OrderApi__Billing_Postal_Code__c,OrderApi__Billing_Country__c,OrderApi__Shipping_Contact__c,OrderApi__Shipping_Street__c,OrderApi__Shipping_City__c,OrderApi__Shipping_State__c,OrderApi__Shipping_Postal_Code__c,OrderApi__Shipping_Country__c,OrderApi__Calculate_Memo__c,Name,OrderApi__Calculate_Billing_Details__c';
        String addflds='(SELECT Fon_Is_Cancelled__c,Fon_Amount_Refunded__c,Fon_Amount_Paid__c,OrderApi__Sales_Order_Line__c,Fon_Refund_Quantity__c,Fon_Refund_Amount__c,Id,OrderApi__Business_Group__r.OrderApi__Credit_Memo_Account__c,OrderApi__Invoice__c,Name,OrderApi__Receipt_Line__c,OrderApi__Receipt_Line__r.Name,OrderApi__Receipt__c,OrderApi__Price_Override__c,OrderApi__Item__c,OrderApi__Price_Rule__c,OrderApi__Tax_Override__c,OrderApi__Tax_Percent__c,OrderApi__Sale_Price__c,OrderApi__Quantity__c,OrderApi__Business_Group__c,OrderApi__Subscription_Plan__c,OrderApi__Subscription__c,OrderApi__Activation_Date__c,OrderApi__End_Date__c,OrderApi__Total__c,OrderApi__Line_Description__c,OrderApi__GL_Account__c,OrderApi__Calculate_Shipping_Details__c,OrderApi__Shipping_Contact__c,OrderApi__Shipping_Street__c,OrderApi__Shipping_City__c,OrderApi__Shipping_State__c,OrderApi__Shipping_Postal_Code__c,OrderApi__Shipping_Country__c FROM OrderApi__Receipt_Lines__r)';
        List<Id> rIDs = new List<Id>(receiptIds); 
        List<OrderApi__Receipt__c> lstReceipt  = (List<OrderApi__Receipt__c>)FDService.SearchRequest.getInstance().fields(flds).additionalFields(addflds).filter(' Id  IN ({0})',new List<Object>{rIDs}).executeQuery(OrderApi__Receipt__c.SObjectType);        
        
        if(lstReceipt.size()>0){
            for(OrderApi__Receipt__c receipt: lstReceipt){
                List<OrderApi__Receipt_Line__c> tempReceiptLineList=receipt.OrderApi__Receipt_Lines__r; 
                String BusinessGroupCreditMemoAccount;
                if(tempReceiptLineList.size()>0){
                    for(OrderApi__Receipt_Line__c RL: tempReceiptLineList){
                        if(selectedReceiptLine.contains(RL.Id)){
                            salesorderLineIds.add(RL.OrderApi__Sales_Order_Line__c);
                            receiptLineVSrefundAmount.put(RL.Id,RL.Fon_Refund_Amount__c);
                            receiptLineList.add(RL);
                            //Creating new Credit Memo record instance
                            lstCreditMemorecord.add(createCreditMemo(RL, receipt));
                            if(RL.OrderApi__Invoice__c != null){
                                invoiceIdSet.add(RL.OrderApi__Invoice__c);
                            }
                            BusinessGroupCreditMemoAccount=RL.OrderApi__Business_Group__r.OrderApi__Credit_Memo_Account__c;
                        }
                    }
                }
                refundReceiptList.add(createReceipt(receipt,true,BusinessGroupCreditMemoAccount));
            }
        }
        
        //Inserting Credit Memo
        if(!lstCreditMemorecord.isEmpty()){
            system.debug('jmd  lstCreditMemorecord---'+lstCreditMemorecord.size());
            insert lstCreditMemorecord;
            Set<Id> insertedCreditMemoIds = new Set<Id>();
            if(lstCreditMemorecord.size()>0){
                for(OrderApi__Credit_Memo__c CM:lstCreditMemorecord){
                    insertedCreditMemoIds.add(CM.Id);
                    CM.OrderApi__Status__c='Posted';
                    oldReceiptLineIdVSnewCreditMemoId.put(CM.Fon_Receipt_Line__c,CM.Id);
                }
                update lstCreditMemorecord;
                if(!insertedCreditMemoIds.isEmpty()){
                    Datetime sysTime = System.now();
                    sysTime = sysTime.addSeconds(20);
                    String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
                    Fon_deleteTransactionSchedule scheduler = new Fon_deleteTransactionSchedule(insertedCreditMemoIds);
                    String name = Label.Fon_callBatch  + String.valueOf(DateTime.now());
                    //Schedule the next job, and give it the system time so name is unique
                    System.schedule(name,chron_exp,scheduler);
                }
            }
            
        }
        //Insert Refund Receipt and line
        if(refundReceiptList.size()>0){
            insert refundReceiptList;
            for(OrderApi__Receipt__c rec : refundReceiptList){
                oldReceiptVSnewReceipt.put(rec.OrderApi__Receipt__c,rec.Id);
                newReceiptVSoldReceipt.put(rec.Id,rec.OrderApi__Receipt__c);
            }
        }
        if(!oldReceiptVSnewReceipt.isEmpty()){
            for(OrderApi__Receipt__c receipt: lstReceipt){
                List<OrderApi__Receipt_Line__c> tempReceiptLineList=receipt.OrderApi__Receipt_Lines__r;                    
                if(tempReceiptLineList.size()>0){
                    for(OrderApi__Receipt_Line__c RL:tempReceiptLineList){
                        if(selectedReceiptLine.contains(RL.Id)){
                            if(RL.OrderApi__Receipt_Line__c!=null){
                                containsParentReceiptLine.add(RL.Id);
                            }
                            else{
                                refundReceiptLineList.add(createReceiptLine(RL,oldReceiptVSnewReceipt.get(RL.OrderApi__Receipt__c),Null,oldReceiptLineIdVSnewCreditMemoId.get(RL.Id)));
                            }
                        }
                    }
                }
            }
        }
        if(refundReceiptLineList.size()>0){
            insert refundReceiptLineList;
            system.debug('jmd refundReceiptLineList--'+refundReceiptLineList);
        }
        system.debug('jmd containsParentReceiptLine--'+containsParentReceiptLine);
        for(OrderApi__Receipt__c receipt: lstReceipt){
            List<OrderApi__Receipt_Line__c> tempReceiptLineList=receipt.OrderApi__Receipt_Lines__r;                    
            if(tempReceiptLineList.size()>0){
                for(OrderApi__Receipt_Line__c RL:tempReceiptLineList){
                    if(selectedReceiptLine.contains(RL.Id)){
                        if(containsParentReceiptLine.contains(RL.Id)){
                            Boolean isInsert= false;
                            for(OrderApi__Receipt_Line__c parentRL:refundReceiptLineList){
                                if(newReceiptVSoldReceipt.get(parentRL.OrderApi__Receipt__c) == RL.OrderApi__Receipt__c && parentRL.Fon_Reference_Receipt_Line__c==RL.OrderApi__Receipt_Line__r.Name){
                                    nonPackageReceiptLineList.add(createReceiptLine(RL,oldReceiptVSnewReceipt.get(RL.OrderApi__Receipt__c),parentRL.Id,oldReceiptLineIdVSnewCreditMemoId.get(RL.Id)));
                                    isInsert=true;
                                    break;
                                }
                            }
                            if(isInsert==false){
                                nonPackageReceiptLineList.add(createReceiptLine(RL,oldReceiptVSnewReceipt.get(RL.OrderApi__Receipt__c),Null,Null));
                            }
                        }
                    }
                }
            }
        }
        if(nonPackageReceiptLineList.size()>0){
            insert nonPackageReceiptLineList; 
        }
        /*  for(id eachInvoiceId : invoiceIdSet){
lstInvoice.add(new OrderApi__Invoice__c(id=eachInvoiceId,OrderApi__Is_Cancelled__c=true));
}
if(!lstInvoice.isEmpty()){
update lstInvoice;
}*/
        
        processRefund(refundReceiptList);
        
        //Updating Receiptline with refunded amount
        if(receiptLineList.size()>0){
            for(OrderApi__Receipt_Line__c objreceiptLine:receiptLineList){
                objreceiptLine.Fon_Amount_Paid__c= objreceiptLine.OrderApi__Total__c;
                if(objreceiptLine.Fon_Amount_Refunded__c>0){
                    objreceiptLine.Fon_Amount_Refunded__c= objreceiptLine.Fon_Amount_Refunded__c+receiptLineVSrefundAmount.get(objreceiptLine.Id);
                }
                else{
                    objreceiptLine.Fon_Amount_Refunded__c= receiptLineVSrefundAmount.get(objreceiptLine.Id);
                }
                if(objreceiptLine.Fon_Amount_Refunded__c==objreceiptLine.OrderApi__Total__c){
                    objreceiptLine.Fon_Is_Cancelled__c=true;
                }
            }
            update receiptLineList;
        }
        
        //Updating Salesorder line with refunded amount
        if(!salesorderLineIds.isEmpty()){
            updateSalesorderLine(salesorderLineIds,receiptLineIdVScancelSubscription);
        }
    }
    
    public static void createRefund(Set<Id> receiptIds,Map<String,String> receiptLineIdVScancelSubscription){//Overwrite create refund button functionality
        List<OrderApi__Receipt_Line__c> receiptLineList = new List<OrderApi__Receipt_Line__c>();
        List<OrderApi__Receipt__c> refundReceiptList = new List<OrderApi__Receipt__c>();
        List<OrderApi__Receipt_Line__c> refundReceiptLineList = new List<OrderApi__Receipt_Line__c>();
        List<OrderApi__Receipt_Line__c> nonPackageReceiptLineList = new List<OrderApi__Receipt_Line__c>();
        Map<Id,List<OrderApi__Receipt_Line__c>> oldReceiptVSlist = new Map<Id,List<OrderApi__Receipt_Line__c>>();
        Map<Id,Id> oldReceiptVSnewReceipt = new  Map<Id,Id>();
        Map<Id,Id> newReceiptVSoldReceipt = new  Map<Id,Id>();
        Set<Id> invoiceIdSet = new Set<Id>();
        
        Map<Id,Decimal> receiptLineVSrefundAmount = new Map<Id,Decimal>();
        Set<Id> salesorderLineIds = new Set<Id>();
        
        List<Id> rIDs = new List<Id>(receiptIds);       
        String flds= 'Id,OrderApi__Entity__c,OrderApi__Business_Group__c,OrderApi__Payment_Gateway__c,OrderApi__Contact__c,OrderApi__Account__c,OrderApi__Payment_Method__c, OrderApi__Payment_Type__c,OrderApi__Reference_Number__c, OrderApi__Sales_Order__c,OrderApi__Billing_Contact__c,OrderApi__Billing_Street__c,OrderApi__Billing_City__c,OrderApi__Billing_State__c,OrderApi__Billing_Postal_Code__c,OrderApi__Billing_Country__c,OrderApi__Shipping_Contact__c,OrderApi__Shipping_Street__c,OrderApi__Shipping_City__c,OrderApi__Shipping_State__c,OrderApi__Shipping_Postal_Code__c,OrderApi__Shipping_Country__c,OrderApi__Calculate_Memo__c, Name, OrderApi__Calculate_Billing_Details__c';        
        String query='(SELECT Fon_Is_Cancelled__c,Fon_Amount_Refunded__c,Fon_Amount_Paid__c,OrderApi__Sales_Order_Line__c,Fon_Refund_Quantity__c,Fon_Refund_Amount__c,OrderApi__Invoice__c,Id,Name,OrderApi__Receipt_Line__c,OrderApi__Receipt_Line__r.Name,OrderApi__Receipt__c,OrderApi__Price_Override__c,OrderApi__Item__c,OrderApi__Price_Rule__c,OrderApi__Tax_Override__c,OrderApi__Tax_Percent__c,OrderApi__Sale_Price__c,OrderApi__Quantity__c,OrderApi__Business_Group__c,OrderApi__Subscription_Plan__c,OrderApi__Subscription__c,OrderApi__Activation_Date__c,OrderApi__End_Date__c, OrderApi__Total__c,OrderApi__Line_Description__c,OrderApi__GL_Account__c,OrderApi__Calculate_Shipping_Details__c,OrderApi__Shipping_Contact__c,OrderApi__Shipping_Street__c,OrderApi__Shipping_City__c,OrderApi__Shipping_State__c,OrderApi__Shipping_Postal_Code__c,OrderApi__Shipping_Country__c FROM OrderApi__Receipt_Lines__r)';
        List<OrderApi__Receipt__c> paymentReceipt= (List<OrderApi__Receipt__c>)FDService.SearchRequest.getInstance().fields(flds).additionalFields(query).filter(' Id  IN ({0})',new List<Object>{rIDs}).executeQuery(OrderApi__Receipt__c.SObjectType);
        
        if(paymentReceipt.size()>0){
            for(OrderApi__Receipt__c receipt:paymentReceipt){
                refundReceiptList.add(createReceipt(receipt,false,''));
                for(OrderApi__Receipt_Line__c RL:receipt.OrderApi__Receipt_Lines__r){
                    if(selectedReceiptLine.contains(RL.Id)){
                        salesorderLineIds.add(RL.OrderApi__Sales_Order_Line__c);
                        receiptLineVSrefundAmount.put(RL.Id,RL.Fon_Refund_Amount__c);
                        receiptLineList.add(RL);
                    }
                }
            }
        }
        
        if(refundReceiptList.size()>0){
            insert refundReceiptList;
            for(OrderApi__Receipt__c rec : refundReceiptList){
                oldReceiptVSnewReceipt.put(rec.OrderApi__Receipt__c,rec.Id);
                newReceiptVSoldReceipt.put(rec.Id,rec.OrderApi__Receipt__c);
            }
            if(!oldReceiptVSnewReceipt.isEmpty()){
                for(OrderApi__Receipt__c receipt: paymentReceipt){
                    List<OrderApi__Receipt_Line__c> tempReceiptLineList=receipt.OrderApi__Receipt_Lines__r;                    
                    if(tempReceiptLineList.size()>0){
                        for(OrderApi__Receipt_Line__c RL:tempReceiptLineList){
                            if(selectedReceiptLine.contains(RL.Id)){
                                if(RL.OrderApi__Receipt_Line__c!=null){
                                    containsParentReceiptLine.add(RL.Id);
                                }
                                else{
                                    refundReceiptLineList.add(createReceiptLine(RL,oldReceiptVSnewReceipt.get(RL.OrderApi__Receipt__c),Null,Null));
                                }
                                if(RL.OrderApi__Invoice__c!=Null){
                                    invoiceIdSet.add(RL.OrderApi__Invoice__c);
                                }
                            } 
                        }
                    }
                }
            }
            if(refundReceiptLineList.size()>0){
                insert refundReceiptLineList;
            }
            for(OrderApi__Receipt__c receipt: paymentReceipt){
                List<OrderApi__Receipt_Line__c> tempReceiptLineList=receipt.OrderApi__Receipt_Lines__r;                    
                if(tempReceiptLineList.size()>0){
                    for(OrderApi__Receipt_Line__c RL:tempReceiptLineList){
                        if(selectedReceiptLine.contains(RL.Id)){
                            if(containsParentReceiptLine.contains(RL.Id)){
                                Boolean isInsert= false;
                                for(OrderApi__Receipt_Line__c parentRL:refundReceiptLineList){
                                    if(newReceiptVSoldReceipt.get(parentRL.OrderApi__Receipt__c) == RL.OrderApi__Receipt__c && parentRL.Fon_Reference_Receipt_Line__c==RL.OrderApi__Receipt_Line__r.Name){
                                        nonPackageReceiptLineList.add(createReceiptLine(RL,oldReceiptVSnewReceipt.get(RL.OrderApi__Receipt__c),parentRL.Id,Null));
                                        isInsert=true;
                                        break;
                                    }
                                }
                                if(isInsert==false){
                                    nonPackageReceiptLineList.add(createReceiptLine(RL,oldReceiptVSnewReceipt.get(RL.OrderApi__Receipt__c),Null,Null));
                                }
                            }
                        }
                    }
                }
            }
            if(nonPackageReceiptLineList.size()>0){
                insert nonPackageReceiptLineList; 
            }
            /*  List<OrderApi__Invoice__c> lstInvoice = new List<OrderApi__Invoice__c>();
if(!invoiceIdSet.isEmpty()){
for(id eachInvoiceId : invoiceIdSet){
lstInvoice.add(new OrderApi__Invoice__c(id=eachInvoiceId,OrderApi__Is_Cancelled__c=true));
}
if(!lstInvoice.isEmpty()){
update lstInvoice;
}
}*/
        }
        
        processRefund(refundReceiptList);
        
        //Updating Receiptline with refunded amount
        if(receiptLineList.size()>0){
            for(OrderApi__Receipt_Line__c objreceiptLine:receiptLineList){
                objreceiptLine.Fon_Amount_Paid__c= objreceiptLine.OrderApi__Total__c;
                if(objreceiptLine.Fon_Amount_Refunded__c>0){
                    objreceiptLine.Fon_Amount_Refunded__c= objreceiptLine.Fon_Amount_Refunded__c+receiptLineVSrefundAmount.get(objreceiptLine.Id);
                }
                else{
                    objreceiptLine.Fon_Amount_Refunded__c= receiptLineVSrefundAmount.get(objreceiptLine.Id);
                }
                if(objreceiptLine.Fon_Amount_Refunded__c==objreceiptLine.OrderApi__Total__c){
                    objreceiptLine.Fon_Is_Cancelled__c=true;
                }
            }
            update receiptLineList;
        }
        
        //Updating Salesorder line with refunded amount
        if(!salesorderLineIds.isEmpty()){
            updateSalesorderLine(salesorderLineIds,receiptLineIdVScancelSubscription);
        }
    }
    
    public static void updateSalesorderLine(Set<Id> salesorderLineIds,Map<String,String> receiptLineIdVScancelSubscription){
        Set<Id> soIds = new Set<Id>();
        Map<Id,Decimal> receiptLineVStotal = new Map<Id,Decimal>();
        Map<Id,Decimal> receiptLineVSrefundAmount = new Map<Id,Decimal>();
        List<OrderApi__Receipt_Line__c> recptLine = [select id,OrderApi__Sales_Order_Line__c,OrderApi__Total__c,Fon_Amount_Refunded__c
                                                     from OrderApi__Receipt_Line__c WHERE OrderApi__Sales_Order_Line__c In :salesorderLineIds];
        Set<id> soForSub = new Set<id>();
        
        if(recptLine.size()>0){
            for(OrderApi__Receipt_Line__c RL :recptLine){
                if(!receiptLineIdVScancelSubscription.isEmpty()){
                    if(receiptLineIdVScancelSubscription.containsKey(RL.Id)){
                        if(receiptLineIdVScancelSubscription.get(RL.Id)=='True'){
                            soForSub.add(RL.OrderApi__Sales_Order_Line__c);
                        }
                    }
                }
                if(soIds.contains(RL.OrderApi__Sales_Order_Line__c)){
                    Decimal tempAmount = receiptLineVStotal.get(RL.OrderApi__Sales_Order_Line__c);
                    receiptLineVStotal.put(RL.OrderApi__Sales_Order_Line__c,RL.OrderApi__Total__c+tempAmount);
                    Decimal tempRefund = receiptLineVSrefundAmount.get(RL.OrderApi__Sales_Order_Line__c);
                    receiptLineVSrefundAmount.put(RL.OrderApi__Sales_Order_Line__c,RL.Fon_Amount_Refunded__c+tempRefund);
                }
                else{
                    soIds.add(RL.OrderApi__Sales_Order_Line__c);
                    receiptLineVStotal.put(RL.OrderApi__Sales_Order_Line__c,RL.OrderApi__Total__c);
                    receiptLineVSrefundAmount.put(RL.OrderApi__Sales_Order_Line__c,RL.Fon_Amount_Refunded__c);
                }
            }  
        }
        List<OrderApi__Sales_Order_Line__c> soli = [select id,OrderApi__Total__c,Fon_Amount_Paid__c,Fon_Amount_Refunded__c from OrderApi__Sales_Order_Line__c where id in :salesorderLineIds];
        if(soli.size()>0){
            for(OrderApi__Sales_Order_Line__c objSoli:soli){
                objSoli.Fon_Amount_Paid__c=receiptLineVStotal.get(objSoli.Id);
                objSoli.Fon_Amount_Refunded__c= receiptLineVSrefundAmount.get(objSoli.Id);
            }
            update soli;
        }
        if(!soForSub.isEmpty()){
            List<OrderApi__Subscription__c> subList = [select id,OrderApi__Status__c from OrderApi__Subscription__c where OrderApi__Sales_Order_Line__c In:soForSub];
            if(subList.size()>0){
                for(OrderApi__Subscription__c subObj:subList){
                    subObj.OrderApi__Status__c='Cancelled';
                }
                update subList;
            }
        }
    }
    
    public static OrderApi__Credit_Memo__c createCreditMemo(OrderApi__Receipt_Line__c objReceiptLineARG, OrderApi__Receipt__c objReceipt){
        OrderApi__Credit_Memo__c objCreditMemo = new OrderApi__Credit_Memo__c();
        objCreditMemo.OrderApi__Contact__c = objReceipt.OrderApi__Contact__c;
        objCreditMemo.OrderApi__Account__c = objReceipt.OrderApi__Account__c;
        objCreditMemo.OrderApi__Entity__c = objReceipt.OrderApi__Entity__c;
        // objCreditMemo.OrderApi__Amount__c = objReceiptLineARG.OrderApi__Total__c;
        objCreditMemo.OrderApi__Amount__c = objReceiptLineARG.Fon_Refund_Amount__c;
        
        objCreditMemo.OrderApi__Business_Group__c = objReceipt.OrderApi__Business_Group__c;
        objCreditMemo.OrderApi__Debit_Account__c = objReceipt.OrderApi__Deposit_Account__c;
        objCreditMemo.Fon_Credit_Memo_Account__c = objReceiptLineARG.OrderApi__Business_Group__r.OrderApi__Credit_Memo_Account__c;        
        objCreditMemo.OrderApi__Posted_Date__c = Date.today();
        objCreditMemo.OrderApi__Status__c = 'Posted';
        objCreditMemo.Fon_Receipt_Line__c = objReceiptLineARG.Id;
        objCreditMemo.Fon_Receipt__c = objReceiptLineARG.OrderApi__Receipt__c;
        return objCreditMemo;
    }
    
    public static void processRefund(List<OrderApi__Receipt__c> refundReceipt){
        for(OrderApi__Receipt__c refundReceiptObj:refundReceipt){//Overwrite Process Refund button functionality
            refundReceiptObj.OrderApi__Process_Refund__c=true;
        }
        update refundReceipt;
    }
    
    public static OrderApi__Receipt__c createReceipt(OrderApi__Receipt__c oldReceipt, Boolean isCM,String BusinessGroupCreditMemoAccount){
        OrderApi__Receipt__c newReceipt= new OrderApi__Receipt__c();
        newReceipt.OrderApi__Type__c                 = strRefund;
        newReceipt.OrderApi__Entity__c               = oldReceipt.OrderApi__Entity__c;
        newReceipt.OrderApi__Business_Group__c       = oldReceipt.OrderApi__Business_Group__c;
        newReceipt.OrderApi__Payment_Gateway__c      = oldReceipt.OrderApi__Payment_Gateway__c;
        newReceipt.OrderApi__Contact__c              = oldReceipt.OrderApi__Contact__c;
        newReceipt.OrderApi__Account__c              = oldReceipt.OrderApi__Account__c;
        newReceipt.OrderApi__Payment_Method__c       = oldReceipt.OrderApi__Payment_Method__c;
        newReceipt.OrderApi__Payment_Type__c         = oldReceipt.OrderApi__Payment_Type__c;
        newReceipt.OrderApi__Reference_Number__c     = oldReceipt.OrderApi__Reference_Number__c;
        newReceipt.OrderApi__Sales_Order__c          = oldReceipt.OrderApi__Sales_Order__c;
        newReceipt.OrderApi__Billing_Contact__c      = oldReceipt.OrderApi__Billing_Contact__c;
        newReceipt.OrderApi__Billing_Street__c       = oldReceipt.OrderApi__Billing_Street__c;
        newReceipt.OrderApi__Billing_City__c         = oldReceipt.OrderApi__Billing_City__c;
        newReceipt.OrderApi__Billing_State__c        = oldReceipt.OrderApi__Billing_State__c;
        newReceipt.OrderApi__Billing_Postal_Code__c  = oldReceipt.OrderApi__Billing_Postal_Code__c;
        newReceipt.OrderApi__Billing_Country__c      = oldReceipt.OrderApi__Billing_Country__c;
        newReceipt.OrderApi__Shipping_Contact__c     = oldReceipt.OrderApi__Shipping_Contact__c;
        newReceipt.OrderApi__Shipping_Street__c      = oldReceipt.OrderApi__Shipping_Street__c;
        newReceipt.OrderApi__Shipping_City__c        = oldReceipt.OrderApi__Shipping_City__c;
        newReceipt.OrderApi__Shipping_State__c       = oldReceipt.OrderApi__Shipping_State__c;
        newReceipt.OrderApi__Shipping_Postal_Code__c = oldReceipt.OrderApi__Shipping_Postal_Code__c;
        newReceipt.OrderApi__Shipping_Country__c     = oldReceipt.OrderApi__Shipping_Country__c;
        newReceipt.OrderApi__Calculate_Memo__c       = oldReceipt.OrderApi__Calculate_Memo__c;
        newReceipt.OrderApi__Receipt__c              = oldReceipt.Id;
        newReceipt.OrderApi__Calculate_Billing_Details__c = true;  
        newReceipt.OrderApi__Is_Refund__c            = true;
        if(isCM){
            //newReceipt.OrderApi__Deposit_Account__c = oldReceipt.OrderApi__Business_Group__r.OrderApi__Credit_Memo_Account__c;
            newReceipt.OrderApi__Deposit_Account__c = BusinessGroupCreditMemoAccount;
            newReceipt.OrderApi__Memo__c = Label.Fon_CreditMemoCreatedFromReceipt;
        }
        else{
            newReceipt.OrderApi__Memo__c  = Label.Fon_NewRefundForReceipt+oldReceipt.Name;
        }
        return newReceipt;
    }
    
    public static OrderApi__Receipt_Line__c createReceiptLine(OrderApi__Receipt_Line__c oldReceiptLine, Id newReceiptId, Id packageReceiptLineId,Id creditMemoId){
        OrderApi__Receipt_Line__c newReceiptLine      = new OrderApi__Receipt_Line__c();
        newReceiptLine.OrderApi__Receipt__c           = newReceiptId;
        newReceiptLine.OrderApi__Price_Override__c    = true;
        newReceiptLine.OrderApi__Item__c              = oldReceiptLine.OrderApi__Item__c;
        newReceiptLine.OrderApi__Price_Rule__c        = oldReceiptLine.OrderApi__Price_Rule__c;
        newReceiptLine.OrderApi__Tax_Override__c      = oldReceiptLine.OrderApi__Tax_Override__c;
        newReceiptLine.OrderApi__Tax_Percent__c       = oldReceiptLine.OrderApi__Tax_Percent__c;
        //newReceiptLine.OrderApi__Sale_Price__c        = oldReceiptLine.OrderApi__Sale_Price__c;
        newReceiptLine.OrderApi__Quantity__c          = oldReceiptLine.OrderApi__Quantity__c;
        newReceiptLine.OrderApi__Business_Group__c    = oldReceiptLine.OrderApi__Business_Group__c;
        newReceiptLine.OrderApi__Subscription_Plan__c = oldReceiptLine.OrderApi__Subscription_Plan__c;
        newReceiptLine.OrderApi__Subscription__c      = oldReceiptLine.OrderApi__Subscription__c;
        newReceiptLine.OrderApi__Activation_Date__c   = oldReceiptLine.OrderApi__Activation_Date__c;
        newReceiptLine.OrderApi__End_Date__c          = oldReceiptLine.OrderApi__End_Date__c;
        newReceiptLine.OrderApi__Total__c             = oldReceiptLine.OrderApi__Total__c;
        newReceiptLine.OrderApi__Line_Description__c  = oldReceiptLine.OrderApi__Line_Description__c;
        newReceiptLine.OrderApi__GL_Account__c        = oldReceiptLine.OrderApi__GL_Account__c;
        newReceiptLine.OrderApi__Shipping_Contact__c  = oldReceiptLine.OrderApi__Shipping_Contact__c;
        newReceiptLine.OrderApi__Shipping_Street__c   = oldReceiptLine.OrderApi__Shipping_Street__c;
        newReceiptLine.OrderApi__Shipping_City__c     = oldReceiptLine.OrderApi__Shipping_City__c;
        newReceiptLine.OrderApi__Shipping_State__c    = oldReceiptLine.OrderApi__Shipping_State__c;
        newReceiptLine.OrderApi__Shipping_Postal_Code__c = oldReceiptLine.OrderApi__Shipping_Postal_Code__c;
        newReceiptLine.OrderApi__Shipping_Country__c     = oldReceiptLine.OrderApi__Shipping_Country__c;
        newReceiptLine.OrderApi__Calculate_Shipping_Details__c = true;
        newReceiptLine.OrderApi__Quantity__c          = oldReceiptLine.Fon_Refund_Quantity__c;
        newReceiptLine.OrderApi__Sale_Price__c        = (oldReceiptLine.Fon_Refund_Amount__c/oldReceiptLine.Fon_Refund_Quantity__c);
        
        if(creditMemoId!=Null){
            newReceiptLine.Fon_Credit_Memo__c = creditMemoId;
        }       
        if(packageReceiptLineId!=null){
            newReceiptLine.OrderApi__Receipt_Line__c = packageReceiptLineId;
        }
        else{
            newReceiptLine.Fon_Reference_Receipt_Line__c=oldReceiptLine.Name;
        }
        return newReceiptLine;
    }
    
    //Requirement  TC-014010 & TC-014009 End ##########################
}