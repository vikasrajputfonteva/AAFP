@isTest
public class Fon_TotalNumberOfMembershipBatchTest {
    @isTest
    public static void method1(){
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        insert con;
        
        
        OrderApi__Subscription_Plan__c plan = (OrderApi__Subscription_Plan__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription_Plan__c', false); 
        plan.OrderApi__Type__c='Lifetime';
        plan.OrderApi__Is_Active__c=true;
        insert plan;
        
        OrderApi__Item_Class__c itmClass = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClass.OrderApi__Is_Subscription__c = true;
        itmClass.OrderApi__Is_Active__c = true;
        itmClass.Fon_Is_Main_Membership__c=true;
        insert itmClass;
        
        OrderApi__Item__c itm = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm.OrderApi__Is_Subscription__c = true;
        itm.OrderApi__Is_Active__c=true;
        itm.OrderApi__Item_Class__c = itmClass.Id;
        itm.OrderApi__Price__c = 100;
        insert itm;
        
        
        
        OrderApi__Subscription__c objSubscription1 = (OrderApi__Subscription__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription__c', false);
        objSubscription1.OrderApi__Contact__c = con.Id;
        objSubscription1.OrderApi__Activated_Date__c = system.today();
        objSubscription1.OrderApi__Item__c = itm.Id;
        objSubscription1.OrderApi__Status__c='Active';
        objSubscription1.OrderApi__Subscription_Plan__c=plan.Id;
        insert objSubscription1;
        
        Test.startTest();
        Fon_TotalNumberOfMembershipBatch batchable= new Fon_TotalNumberOfMembershipBatch();
        Database.executeBatch(batchable,1);
        Fon_TotalNumberOfMembershipSchedule.scheduleIt();
       
        System.AssertEquals(database.countquery('SELECT COUNT() FROM OrderApi__Subscription__c'),1);
        
        Test.stopTest();  
    }
    
}