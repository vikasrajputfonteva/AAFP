/*
    Note: This class has been depricated as per new logic update, Need to remove from Routing Rule configuration setting as well.
*/
@isTest
public class Fon_SubscriptionTriggerHandlerTest {
    public static testMethod void method(){
        Fon_TestDataFactory.install('Fon_SubscriptionTriggerDomain','OrderApi__Subscription__c');
       
        
        Account acct = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert acct;
    
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        insert con;
    

        OrderApi__Item_Class__c itmClass = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClass.OrderApi__Enable_Assignments__c = false;
        itmClass.OrderApi__Is_Active__c = true;
        insert itmClass;

        OrderApi__Item__c itm = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        itm.Name='2019 National Active';
        itm.OrderApi__Item_Class__c = itmClass.Id;
        itm.OrderApi__Is_Active__c = true;
        itm.OrderApi__Price__c = 15;
        insert itm;
 
        
        OrderApi__Subscription_Plan__c subPlan = (OrderApi__Subscription_Plan__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription_Plan__c', false);
        subPlan.OrderApi__Type__c = 'Termed';
        subPlan.OrderApi__Initial_Term_Months__c = 12;
        subPlan.OrderApi__Renewal_Term_Months__c = 12;
        subPlan.OrderApi__Is_Active__c = true;
        insert subPlan;

        OrderApi__Subscription__c sub = (OrderApi__Subscription__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription__c', false);
        sub.OrderApi__Subscription_Plan__c=subPlan.Id;
        sub.OrderApi__Contact__c=con.Id;
        sub.OrderApi__Item__c=itm.Id;
        insert sub;
        
        sub.OrderApi__Status__c='Cancelled';
        sub.OrderApi__Cancelled_Date__c=system.today();
        
        test.startTest();
        update sub;
        Contact contact=[select id,Fon_Total_Months_of_Membership__c from Contact where Id=:con.Id];
        system.assertEquals(sub.OrderApi__Contact__c, contact.Id);
        test.stopTest();

        
    }

}