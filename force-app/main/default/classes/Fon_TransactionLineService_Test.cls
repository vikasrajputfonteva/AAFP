@isTest
public class Fon_TransactionLineService_Test {

    @isTest
    public static void method1(){
        Fon_TestDataFactory.install('Fon_TransactionLineDomain','OrderApi__Transaction_Line__c');
        List<OrderApi__Transaction_Line__c> lstTransactionLine = new List<OrderApi__Transaction_Line__c>();
       
        OrderApi__Item_Class__c itmClass = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClass.OrderApi__Is_Active__c = true;
        itmClass.Fon_Is_Main_Membership__c=true;
        insert itmClass;
        
        OrderApi__Item__c itm = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm.OrderApi__Item_Class__c = itmClass.Id;
        itm.OrderApi__Is_Active__c = true;
        itm.OrderApi__Price__c = 100;
        insert itm;
        
        OrderApi__Receipt__c receipt1 = (OrderApi__Receipt__c)Fon_TestDataFactory.createSObject('OrderApi__Receipt__c', false);
        receipt1.OrderApi__Type__c='Payment';
        
        insert receipt1;
        
        
        
        OrderApi__Receipt__c receipt2 = (OrderApi__Receipt__c)Fon_TestDataFactory.createSObject('OrderApi__Receipt__c', false);
        receipt2.OrderApi__Type__c='Refund';
        receipt2.OrderApi__Receipt__c=receipt1.Id;
        
        insert receipt2;
        
        OrderApi__Receipt_Line__c receiptLine1 = (OrderApi__Receipt_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Receipt_Line__c', false);
        receiptLine1.OrderApi__Receipt__c=receipt1.Id;
        insert receiptLine1;
        
        
        OrderApi__Receipt_Line__c receiptLine2 = (OrderApi__Receipt_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Receipt_Line__c', false);
        receiptLine2.OrderApi__Receipt__c=receipt2.Id;
        insert receiptLine2;
        
        OrderApi__Credit_Memo__c cm = new OrderApi__Credit_Memo__c();
        cm.Fon_Receipt__c=receipt1.Id;
        insert cm;
        
        OrderApi__Transaction__c tr = (OrderApi__Transaction__c)Fon_TestDataFactory.createSObject('OrderApi__Transaction__c', false); 
        tr.OrderApi__Receipt__c=receipt2.Id;
        insert tr;
        
        OrderApi__Transaction_Line__c trLine = (OrderApi__Transaction_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Transaction_Line__c', false);
        trLine.OrderApi__Transaction__c=tr.Id;
       
        insert trLine;
        
        lstTransactionLine.add(trLine);
        Test.startTest();
        try{
        Fon_TransactionLineService.filterTransactionLine(lstTransactionLine);
            OrderApi__Transaction_Line__c trans=[select id,Fon_Credit_Memo_Numbers__c from OrderApi__Transaction_Line__c where Id=:trLine.Id ];
           OrderApi__Credit_Memo__c cm1=[select name from OrderApi__Credit_Memo__c where Id=:cm.id]; 
            system.assertEquals(cm1.Name, trans.Fon_Credit_Memo_Numbers__c);
        }
         catch (Exception e) {
            String exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        
    }
}