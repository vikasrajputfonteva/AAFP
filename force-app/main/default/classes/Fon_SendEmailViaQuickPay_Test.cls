@isTest 
public class Fon_SendEmailViaQuickPay_Test 
{
    static testMethod void testMethod1() 
    {
        OrderApi__Receipt__c rec = new OrderApi__Receipt__c();
        insert rec;
        
        Test.StartTest(); 
        PageReference pageRef = Page.Fon_PaymentConfirmation;
        pageRef.getParameters().put('id', String.valueOf(rec.Id));
        Test.setCurrentPage(pageRef);
        Fon_SendEmailViaQuickPay ff = new Fon_SendEmailViaQuickPay();
        Test.StopTest();
    }
}