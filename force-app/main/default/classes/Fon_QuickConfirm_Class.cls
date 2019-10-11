public without sharing class Fon_QuickConfirm_Class {
    @AuraEnabled  
    public static list<OrderApi__Receipt_Line__c> receiptLineData(list<String> lstReceiptId,String receiptName,String amount){
        String customerEmail='';
        list<OrderApi__Receipt_Line__c> receiptLineList=[select OrderApi__Sales_Order_Line__r.OrderApi__Contact__r.Name,OrderApi__Sales_Order_Line__r.OrderApi__Contact__r.Email,OrderApi__Sales_Order_Line__r.OrderApi__Contact__c,OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__r.Fon_Payee_Email__c,OrderApi__Contact__c,OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__r.Name,id,Name,OrderApi__Invoice__r.Fon_Payee_Email__c,OrderApi__Contact__r.Email,OrderApi__Receipt__r.OrderApi__Sales_Order__r.Name,OrderApi__Item__r.Name,OrderApi__Total__c,OrderApi__Contact__r.Name from OrderApi__Receipt_Line__c where OrderApi__Receipt__c in:lstReceiptId];
        if(receiptLineList.size()>0){
            //  List<OrderApi__Receipt__c> receiptList = [select OrderApi__Sales_Order__r.Fon_Payee_Email__c from OrderApi__Receipt__c where id=:lstReceiptId];
            customerEmail = receiptLineList[0].OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__r.Fon_Payee_Email__c;
            SendEmailViaQuickPay(amount,receiptName,receiptLineList,customerEmail);
        }
        return receiptLineList;
    }
    
    public static void SendEmailViaQuickPay(String am,String cn,list<OrderApi__Receipt_Line__c> receiptLineList,String customerEmail){
        Map<Id,String> contactVSemail = new Map<Id,String>();
        Map<Id,String> contactVSrl = new Map<Id,String>();
        Set<Id> contactIds = new Set<Id>();
        String consolidateReceiptLineIds;
        Boolean isDuplicateEmail=false;
         Map<Id,Decimal> contactVStotalAmount = new Map<Id,Decimal>();
      
        if(receiptLineList.size()>0){
            for(OrderApi__Receipt_Line__c obj:receiptLineList){
                
                
                if(!contactIds.contains(obj.OrderApi__Sales_Order_Line__r.OrderApi__Contact__c)){
                    contactIds.add(obj.OrderApi__Sales_Order_Line__r.OrderApi__Contact__c);
                    if(obj.OrderApi__Sales_Order_Line__r.OrderApi__Contact__r.Email!=null){
                        contactVSemail.put(obj.OrderApi__Sales_Order_Line__r.OrderApi__Contact__c,obj.OrderApi__Sales_Order_Line__r.OrderApi__Contact__r.Email);
                    }
                    contactVStotalAmount.put(obj.OrderApi__Sales_Order_Line__r.OrderApi__Contact__c,obj.OrderApi__Total__c);
                    contactVSrl.put(obj.OrderApi__Sales_Order_Line__r.OrderApi__Contact__c,obj.Id);
                }
                else{
                    Decimal tempAmount = contactVStotalAmount.get(obj.OrderApi__Sales_Order_Line__r.OrderApi__Contact__c);
                    contactVStotalAmount.put(obj.OrderApi__Sales_Order_Line__r.OrderApi__Contact__c,obj.OrderApi__Total__c+tempAmount);
                    String tempStr =  contactVSrl.get(obj.OrderApi__Sales_Order_Line__r.OrderApi__Contact__c);
                    contactVSrl.put(obj.OrderApi__Sales_Order_Line__r.OrderApi__Contact__c,obj.Id+','+tempStr);
                }
                
                if(String.isNotBlank(consolidateReceiptLineIds)){
                    consolidateReceiptLineIds = consolidateReceiptLineIds+','+obj.Id;
                }
                else{
                    consolidateReceiptLineIds = obj.Id;
                }
            }
        }
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        for(Id conId : contactIds){
            if(!contactVSemail.isEmpty() && contactVSemail.get(conId)!=null){
                if(String.isNotBlank(customerEmail)){
                    String eml = contactVSemail.get(conId);
                    if(eml.equalsIgnoreCase(customerEmail)){
                        isDuplicateEmail=true;
                        continue;
                    }
                }
               
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                PageReference pg = new PageReference('/apex/Fon_PaymentConfirmation?id='+contactVSrl.get(conId)+'&amount='+contactVStotalAmount.get(conId)+'&number='+cn);
                pg.setRedirect(true);
                String pageAsString ;
                if(!Test.isRunningTest() ){
                    Blob b = pg.getContent();
                    pageAsString = pg.getContent().tostring();
                }else{
                    Blob b = blob.valueOf('Test');
                    pageAsString = 'test';
                }
                email.setSubject(Label.Fon_PaymentConfirmation);
                email.setHtmlBody(pageAsString);
                email.settoAddresses(new List<String>{contactVSemail.get(conId)});
               
                mails.add(email);
            }
            
        }
        if(String.isNotBlank(customerEmail) || isDuplicateEmail){               
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            PageReference pg = new PageReference('/apex/Fon_PaymentConfirmation?id='+consolidateReceiptLineIds+'&amount='+am+'&number='+cn);
            pg.setRedirect(true);
            String pageAsString ;
            if(!Test.isRunningTest() ){
                Blob b = pg.getContent();
                pageAsString = pg.getContent().tostring();
            }else{
                Blob b = blob.valueOf('Test');
                pageAsString = 'test';
            }
            email.setSubject(Label.Fon_PaymentConfirmation);
            email.setHtmlBody(pageAsString);
            email.settoAddresses(new List<String>{customerEmail});
            mails.add(email);
        }
        
        Messaging.sendEmailResult[] sendingEmail = Messaging.sendEmail(mails); 
    }
}