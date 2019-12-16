@isTest
public class Fon_SelectPaymentMethodTest {
    @isTest
    public static void method1(){
        
        Account ac= new Account();
        ac.Name='testAccount';
        insert ac;
        
        Contact con = new Contact();
        con.AccountId=ac.Id;
        con.LastName='testCon';
        
        insert con;
        
        OrderApi__Payment_Method__c pm = new OrderApi__Payment_Method__c();
        pm.OrderApi__Contact__c= con.Id;
        pm.OrderApi__Is_Active__c= true;
        pm.OrderApi__Is_Valid__c= true;
        pm.OrderApi__Year__c = 2019;
        pm.OrderApi__Month__c = 06;        
        pm.OrderApi__Card_Type__c = 'visa';
        pm.OrderApi__Number__c='1010-0101-1010-1010';
        insert pm;
        
        Test.startTest();
        Fon_SelectPaymentMethod.validPaymentMethod(con.Id);
        Test.stopTest();
    }
}