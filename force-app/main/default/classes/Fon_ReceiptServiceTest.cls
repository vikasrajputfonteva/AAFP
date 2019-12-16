@isTest
public class Fon_ReceiptServiceTest {
    
 
    @isTest
    public static void method1(){
        Fon_TestDataFactory.install('Fon_ReceiptDomain','OrderApi__Receipt__c');
        Fon_TestDataFactory.dispatcher();
        
        OrderApi__Business_Group__c bg = (OrderApi__Business_Group__c)Fon_TestDataFactory.createSObject('OrderApi__Business_Group__c', false); 
        insert bg;
        
        
        OrderApi__GL_Account__c glAcc = (OrderApi__GL_Account__c)Fon_TestDataFactory.createSObject('OrderApi__GL_Account__c', false); 
        glAcc.OrderApi__Business_Group__c=bg.Id;
        insert glAcc;
        
        bg.Accounts_Payable_Account__c=glAcc.Id;
        update bg;
        
        OrderApi__Receipt__c rec = (OrderApi__Receipt__c)Fon_TestDataFactory.createSObject('OrderApi__Receipt__c', false); 
        rec.OrderApi__Type__c='Refund';
        rec.OrderApi__Payment_Type__c='Check';
        rec.OrderApi__Business_Group__c=bg.Id;
        
        
        Test.startTest();
        try{
            insert rec;
            
            List<OrderApi__Receipt__c> recp=[select OrderApi__Deposit_Account__c from OrderApi__Receipt__c where id=:rec.Id];
            system.assertEquals(bg.Accounts_Payable_Account__c, recp[0].OrderApi__Deposit_Account__c);
        }
        catch (Exception e) {
            String exceptionMessage = e.getMessage();
        }
        Test.stopTest();       
    }
}