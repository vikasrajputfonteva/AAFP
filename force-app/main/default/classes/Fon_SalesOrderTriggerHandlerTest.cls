@isTest
public class Fon_SalesOrderTriggerHandlerTest {
    @isTest
    public static void method1(){
        Fon_TestDataFactory.install('Fon_SalesOrderTriggerHandlerDomain','OrderApi__Sales_Order__c');
        Account acct = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert acct;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        insert con;
        
        OrderApi__Item_Class__c itmClass = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClass.OrderApi__Is_Active__c = true;
        itmClass.Fon_Is_Main_Membership__c=true;
        insert itmClass;
        
        OrderApi__Item__c itm = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm.Name = 'Convenience fee';
        itm.OrderApi__Item_Class__c = itmClass.Id;
        itm.OrderApi__Is_Active__c = true;
        itm.OrderApi__Price__c = 15;
        insert itm;
        
        OrderApi__Subscription_Plan__c subPlan = (OrderApi__Subscription_Plan__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription_Plan__c', false); 
        subPlan.OrderApi__Auto_Renew_Option__c = 'Enabled';
        subPlan.OrderApi__Type__c = 'Termed';
        subPlan.OrderApi__Initial_Term_Months__c = 12;
        subPlan.OrderApi__Renewal_Term_Months__c = 12;
        subPlan.OrderApi__Is_Active__c = true;
        subPlan.OrderApi__Enable_Schedule__c=true;
        subPlan.OrderApi__Schedule_Frequency__c='Monthly';
        insert subPlan;
        
        OrderApi__Subscription__c sub = (OrderApi__Subscription__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription__c', false); 
        sub.OrderApi__Account__c=acct.id;
        sub.OrderApi__Contact__c=con.id;
        sub.OrderApi__Subscription_Plan__c=subPlan.id;
        sub.OrderApi__Item__c=itm.Id;
        insert sub;
        
        
        
        OrderApi__Sales_Order__c so = new OrderApi__Sales_Order__c();
        so.OrderApi__Account__c = acct.id;
        so.OrderApi__Contact__c = con.id;
        insert so;
        so.OrderApi__Status__c= 'Closed';
        update so;
        
        OrderApi__Sales_Order_Line__c sol = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false); 
        sol.OrderApi__Sales_Order__c = so.id;
        sol.OrderApi__Account__c = acct.id;
        sol.OrderApi__Contact__c = con.id;
        sol.OrderApi__Item__c = itm.id;
        sol.OrderApi__Is_Renewal__c=true;
        sol.OrderApi__Is_Subscription__c = true;       
        sol.OrderApi__Is_Renewal__c=true;
        sol.OrderApi__Subscription__c=sub.Id;
        insert sol;
        
        Test.startTest();
        so.OrderApi__Posting_Status__c= 'Posted';
        update so;
        Test.stopTest();
    }
}