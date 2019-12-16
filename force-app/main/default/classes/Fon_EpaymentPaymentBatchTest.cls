@isTest 
public class Fon_EpaymentPaymentBatchTest {
    @isTest
    public static void method1(){
        Account acct = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert acct;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false);
        insert con;
        
        OrderApi__Business_Group__c bg = (OrderApi__Business_Group__c)Fon_TestDataFactory.createSObject('OrderApi__Business_Group__c', false);
        insert bg;
        
        
        OrderApi__Payment_Gateway__c pg = (OrderApi__Payment_Gateway__c)Fon_TestDataFactory.createSObject('OrderApi__Payment_Gateway__c', false);
        insert pg;
        
        OrderApi__Payment_Method__c pm = (OrderApi__Payment_Method__c)Fon_TestDataFactory.createSObject('OrderApi__Payment_Method__c', false); 
        pm.OrderApi__Contact__c= con.Id;
        insert pm;
        
        
        OrderApi__Item_Class__c itemClass = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        insert itemClass;
        
        OrderApi__Item__c itemdata = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itemdata.OrderApi__Item_Class__c = itemClass.Id;
        insert itemdata;
        
        Fon_Membership_Staging__c ms = (Fon_Membership_Staging__c)Fon_TestDataFactory.createSObject('Fon_Membership_Staging__c', false);
        ms.Fon_Contact__c=con.Id;
        ms.Fon_Staging_Status__c='Approved';
        ms.Fon_Membership_Type__c='Resident';
        ms.Fon_Membership_State__c = 'Virginia';
        ms.Fon_Membership_Local__c= 'VA Northern Virginia';
        ms.Fon_Residency_Program_Graduation_Date__c=system.today();
        ms.Fon_Dues_Paid_by_Residency_Program__c=false;
		ms.Fon_Foundation_Contribution_Information__c=50;
        ms.Fon_PAC_Contribution_Information__c=60;
        ms.Fon_AAFP_Subscription_Plan_Picklist__c = 'Installment';
        insert ms;
        
        OrderApi__Sales_Order__c SO = (OrderApi__Sales_Order__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order__c', false);
        SO.OrderApi__Contact__c=con.Id;
        SO.OrderApi__Posting_Entity__c='Invoice';
        SO.Fon_Membership_Staging__c= ms.Id;
        insert SO;
        
        OrderApi__Sales_Order_Line__c  SOLI = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false);
        SOLI.OrderApi__Item__c =itemdata.Id;
        SOLI.OrderApi__Sales_Order__c= SO.id;
        SOLI.OrderApi__Is_Subscription__c=true;
        SOLI.OrderApi__Activation_Date__c=System.today();
        SOLI.OrderApi__End_Date__c=System.today()+30;
        insert SOLI;
        
        OrderApi__EPayment__c ePayment = (OrderApi__EPayment__c)Fon_TestDataFactory.createSObject('OrderApi__EPayment__c', false); 
        ePayment.OrderApi__Business_Group__c = bg.Id;
        ePayment.OrderApi__Contact__c=con.Id;
        ePayment.OrderApi__Total__c = 300;
        ePayment.Fon_IsPaymentProcessBatch__c=true;
        ePayment.OrderApi__Payment_Gateway__c =pg.Id;
        ePayment.OrderApi__Succeeded__c=true;
        ePayment.OrderApi__Sales_Order__c=SO.id;
        insert ePayment;
        
        OrderApi__EPayment_Line__c ePaymentLine = (OrderApi__EPayment_Line__c)Fon_TestDataFactory.createSObject('OrderApi__EPayment_Line__c', false); 
        ePaymentLine.OrderApi__EPayment__c= ePayment.Id;
        ePaymentLine.OrderApi__Sales_Order_Line__c=SOLI.Id;
        insert ePaymentLine;
        
        
        Test.startTest();
        
        Fon_EpaymentPaymentBatch batchable = new Fon_EpaymentPaymentBatch();
        DataBase.executeBatch(batchable,1);
        System.AssertEquals(database.countquery('SELECT COUNT() FROM OrderApi__EPayment__c '),1);
        Test.stopTest();
    }
}