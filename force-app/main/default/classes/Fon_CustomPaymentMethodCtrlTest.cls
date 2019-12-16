@isTest
public class Fon_CustomPaymentMethodCtrlTest {
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
        
        OrderApi__Payment_Gateway__c pg = new OrderApi__Payment_Gateway__c();
        pg.OrderApi__Is_Test__c=true;
        pg.OrderApi__Is_Enabled__c=true;
        pg.OrderApi__Token__c='kk';
        insert pg;
        
        OrderApi__Payment_Gateway__c pg1 = new OrderApi__Payment_Gateway__c();
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
            Fon_CustomPaymentMethodCtrl.checkValidPaymentMethod(); 
            Fon_CustomPaymentMethodCtrl.getPaymentMethod();
            Fon_CustomPaymentMethodCtrl.getContactInfo();
            Fon_CustomPaymentMethodCtrl.isSandboxOrg=true;
            Fon_CustomPaymentMethodCtrl.getTokenInfo();
            Fon_CustomPaymentMethodCtrl.isSandboxOrg=false;
            Fon_CustomPaymentMethodCtrl.getTokenInfo();
            Test.stopTest();
        }
    }
}