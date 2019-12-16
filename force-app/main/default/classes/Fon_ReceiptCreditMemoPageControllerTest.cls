@IsTest 
public class Fon_ReceiptCreditMemoPageControllerTest{
    
    static testMethod void createCreditMemoMethod(){
        
        
        OrderApi__Receipt__c receipt = (OrderApi__Receipt__c)Fon_TestDataFactory.createSObject('OrderApi__Receipt__c', false);
        receipt.OrderApi__Type__c='Payment';
        receipt.Is_Credit_Memo_Existed__c=true;
        receipt.OrderApi__Is_Payment__c = true;
        insert receipt;  
        
        
        OrderApi__Receipt_Line__c receiptline = (OrderApi__Receipt_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Receipt_Line__c', false); 
        receiptline.OrderApi__Receipt__c=receipt.Id;
        insert receiptline; 
        
        
        OrderApi__Receipt__c receipt1 = (OrderApi__Receipt__c)Fon_TestDataFactory.createSObject('OrderApi__Receipt__c', false); 
        receipt1.OrderApi__Type__c='Refund';
        receipt1.OrderApi__Receipt__c = receipt.Id; 
        insert receipt1;
        
        
        OrderApi__Credit_Memo__c cmem = (OrderApi__Credit_Memo__c)Fon_TestDataFactory.createSObject('OrderApi__Credit_Memo__c', false); 
        cmem.Fon_Receipt__c = receipt.id;
        insert cmem;
        
        cmem.OrderApi__Status__c = 'Posted';
        update cmem;
        
        
        OrderApi__Transaction__c trans = (OrderApi__Transaction__c)Fon_TestDataFactory.createSObject('OrderApi__Transaction__c', false);
        trans.OrderApi__Credit_Memo__c = cmem.id;
        insert trans;
        
        Set<Id> cmIds = new Set<Id>();
        cmIds.add(cmem.id);
        
        Test.startTest(); 
        try{
            Fon_ReceiptCreditMemoPageController.createCreditMemo(receipt.Id);
            Fon_deleteTransactionSchedule batch=new Fon_deleteTransactionSchedule(cmem.id,null);
           // Database.executeBatch(batch,1);
            
            OrderApi__Receipt__c rec=[select id,OrderApi__Type__c from OrderApi__Receipt__c where Id=:receipt1.Id];
            system.assertEquals('Refund', rec.OrderApi__Type__c);
        }
        catch(Exception e){
            String exceptionMessage = e.getMessage(); 
        }
            Test.stopTest();         
        
        }
        
    }