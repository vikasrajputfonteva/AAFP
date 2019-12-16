@isTest
public class Fon_SelfServiceSelectPaymentTest {
    @isTest
    public static void method1(){
        Account ac = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert ac;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        con.AccountId=ac.Id;
        insert con;
        
        OrderApi__Payment_Method__c pm = (OrderApi__Payment_Method__c)Fon_TestDataFactory.createSObject('OrderApi__Payment_Method__c', false); 
        pm.OrderApi__Contact__c= con.Id;
        pm.OrderApi__Is_Active__c= true;
        pm.OrderApi__Is_Valid__c= true;
        pm.OrderApi__Year__c = 2019;
        pm.OrderApi__Month__c = 06;        
        pm.OrderApi__Card_Type__c = 'visa';
        pm.OrderApi__Number__c='1010-0101-1010-1010';
        insert pm;
        
        OrderApi__Payment_Gateway__c pg = (OrderApi__Payment_Gateway__c)Fon_TestDataFactory.createSObject('OrderApi__Payment_Gateway__c', false); 
        pg.OrderApi__Is_Test__c=true;
        pg.OrderApi__Is_Enabled__c=true;
        pg.OrderApi__Token__c='kk';
        insert pg;
        
        OrderApi__Payment_Gateway__c pg1 = (OrderApi__Payment_Gateway__c)Fon_TestDataFactory.createSObject('OrderApi__Payment_Gateway__c', false); 
        pg1.OrderApi__Is_Test__c=false;
        pg1.OrderApi__Is_Enabled__c=true;
        pg1.OrderApi__Token__c='kk';
        insert pg1;
        
        Profile p = [SELECT Id FROM Profile where Name='Fonteva Customer Community Login User'];
        User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com',ContactId=con.Id,
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='newuser@testorg.com');
        
        System.runAs(u2){
            Test.startTest();
            Fon_SelfServiceSelectPayment.getPaymentMethod();
            Fon_SelfServiceSelectPayment.getContactInfo();
            Fon_SelfServiceSelectPayment.isSandboxOrg=true;
            Fon_SelfServiceSelectPayment.getTokenInfo();
            Fon_SelfServiceSelectPayment.isSandboxOrg=false;
            Fon_SelfServiceSelectPayment.getTokenInfo();
            Fon_SelfServiceSelectPayment.isvalidPaymentMethodAvailable(con.Id);
            Test.stopTest();
        }
    }
        @isTest
    public static void method2(){
        OrderApi__Payment_Gateway__c pg=new OrderApi__Payment_Gateway__c();
        test.startTest();
        try{
          Fon_SelfServiceSelectPayment.getTokenInfo();
            insert pg;
        }
        catch (Exception ex) {
        }
        test.stopTest();
    }
}