@isTest
public class Fon_SelfServiceConfirmationEmailTest {
   static testMethod void testMethod1() 
    {
        Decimal totalAmount=100;
        OrderApi__Receipt__c rec = (OrderApi__Receipt__c)Fon_TestDataFactory.createSObject('OrderApi__Receipt__c', false);
        insert rec;
        
        Test.StartTest(); 
        PageReference pageRef = Page.Fon_SelfServiceConfirmationEmailTemplate;
        pageRef.getParameters().put('id', String.valueOf(rec.Id));
        pageRef.getParameters().put('totalAmount', String.valueOf(totalAmount));
        Test.setCurrentPage(pageRef);
        Fon_SelfServiceConfirmationEmailTemplate ff = new Fon_SelfServiceConfirmationEmailTemplate();
        Test.StopTest();
    }
}