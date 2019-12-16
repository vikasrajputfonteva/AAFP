@isTest
public class Fon_TransactionServiceTest {
   
    @isTest
    public static void method1(){

        Fon_TestDataFactory.install('Fon_TransactionServiceDomain','OrderApi__Transaction__c');
        Fon_TestDataFactory.dispatcher();
        
        OrderApi__Credit_Memo__c cm = (OrderApi__Credit_Memo__c)Fon_TestDataFactory.createSObject('OrderApi__Credit_Memo__c', false); 
        insert cm;
        
        
        
        OrderApi__Batch__c batch = (OrderApi__Batch__c)Fon_TestDataFactory.createSObject('OrderApi__Batch__c', false); 
        insert batch;
        
        OrderApi__Invoice__c inv = (OrderApi__Invoice__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice__c', false); 
        insert inv;		
        
        
        OrderApi__Credit_Memo_Line__c cmline = (OrderApi__Credit_Memo_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Credit_Memo_Line__c', false); 
        cmline.Fon_Batch__c=batch.Id;
        cmline.OrderApi__Credit_Memo__c=cm.Id;
        cmline.OrderApi__Invoice__c=inv.Id;
        cmline.OrderApi__Status__c='Posted';
        insert cmline;
        
        
        OrderApi__Receipt__c receipt = (OrderApi__Receipt__c)Fon_TestDataFactory.createSObject('OrderApi__Receipt__c', false); 
        receipt.Fon_Credit_Memo__c=cm.Id;
        insert receipt;
        
        
        
        OrderApi__Transaction__c tr = (OrderApi__Transaction__c)Fon_TestDataFactory.createSObject('OrderApi__Transaction__c', false); 
        tr.OrderApi__Receipt__c=receipt.Id;
        tr.OrderApi__Credit_Memo__c= cm.Id;
        tr.OrderApi__Invoice__c=inv.Id;
        
        
        
        Test.startTest();
        try{
            insert tr;
            OrderApi__Transaction__c tr1=[select id ,OrderApi__Batch__c from OrderApi__Transaction__c where Id=:tr.Id];
            system.assertEquals(batch.Id, tr1.OrderApi__Batch__c);
        }
        catch (Exception e) {
            String exceptionMessage = e.getMessage();
        }
        Test.stopTest();
    }
}