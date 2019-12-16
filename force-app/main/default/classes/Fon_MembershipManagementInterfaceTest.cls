@isTest
public class Fon_MembershipManagementInterfaceTest {

    @isTest
    public static void testMethodForUpdateRecords(){
        Test.startTest(); 
        List<OrderApi__Item_Class__c> itemClassList = new List<OrderApi__Item_Class__c>();
        List<OrderApi__Item__c> itemList = new List<OrderApi__Item__c>();
        
        Account acct = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert acct;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false);
        con.AccountId= acct.Id;
        con.Fon_Chapter_Change_Needed__c=true;
        //con.Fon_Current_Membership_Status__c='Inactive';
        insert con;

        Fon_Membership_Staging__c ms = (Fon_Membership_Staging__c)Fon_TestDataFactory.createSObject('Fon_Membership_Staging__c', true); 
        ms.Fon_Contact__c=con.Id;
        ms.Fon_Staging_Status__c='Active';
        ms.Fon_Membership_Type__c='Resident';
        ms.Fon_Membership_State__c = 'Virginia';
        ms.Fon_Membership_Local__c= 'VA Northern Virginia';
        ms.Fon_Membership_Activation_Date__c=system.today();
        ms.Fon_Join_Date__c=system.today();
        ms.Fon_Chapter_Join_Date__c=system.today();
        ms.Fon_Residency_Program_Graduation_Date__c=system.today();
        insert ms;
        
        OrderApi__Item_Class__c itmClassMain = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClassMain.Fon_Is_Main_Membership__c=true;
        itmClassMain.OrderApi__Is_Subscription__c = true;
        itmClassMain.OrderApi__Is_Active__c = true;
        itemClassList.add(itmClassMain);
  
        OrderApi__Item_Class__c itmClassState = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClassState.OrderApi__Is_Active__c = true;
        itmClassState.Fon_Is_State_Membership__c=true;
        itemClassList.add(itmClassState);       
        
        OrderApi__Item_Class__c itmClassLocal = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClassLocal.Fon_Is_Local_Membership__c=true;
        itmClassState.OrderApi__Is_Active__c = true;
        itemClassList.add(itmClassLocal); 

        OrderApi__Item_Class__c itmClass= new OrderApi__Item_Class__c();
        itemClassList.add(itmClass);
        Insert itemClassList;
        
        OrderApi__Subscription_Plan__c plan = (OrderApi__Subscription_Plan__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription_Plan__c', false); 
        plan.OrderApi__Type__c='Lifetime';
        plan.OrderApi__Is_Active__c=true;
        insert plan;
        
        OrderApi__Item__c itm = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm.Name='Active Membership - Kansas';
        itm.OrderApi__Item_Class__c=itmClass.Id;
        itemList.add(itm);
        
        OrderApi__Item__c itm1 = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm1.Name='Active Membership - Kansas City';
        itm1.OrderApi__Item_Class__c=itmClass.Id;
        itemList.add(itm1);
        
        OrderApi__Item__c itm2 = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm2.Name='state item';
        itm2.OrderApi__Item_Class__c=itmClassMain.Id;
        itm2.OrderApi__Is_Active__c=false;
        itemList.add(itm2);
        
        OrderApi__Item__c itm3 = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm3.Name='2019 Chapter Resident Kansas';
        itm3.OrderApi__Item_Class__c=itmClassState.Id;
        itm3.OrderApi__Is_Active__c=true;
        itemList.add(itm3);
        
        OrderApi__Item__c itm4 = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        itm4.Name='2019 Local Resident Kansas Kansas City';
        itm4.OrderApi__Item_Class__c=itmClassLocal.Id;
        itm4.OrderApi__Is_Active__c=true;
        itemList.add(itm4);
        Insert itemList;      
        
        OrderApi__Item_Subscription_Plan__c it = (OrderApi__Item_Subscription_Plan__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Subscription_Plan__c', false); 
        it.OrderApi__Is_Default__c=true;
        it.OrderApi__Item__c=itm2.Id;
        it.OrderApi__Subscription_Plan__c=plan.Id;
        insert it;

        itm2.OrderApi__Is_Active__c=true;
        update itm2;
        
        OrderApi__Badge_Type__c bt = (OrderApi__Badge_Type__c)Fon_TestDataFactory.createSObject('OrderApi__Badge_Type__c', false); 
        bt.Name='testType';
        insert bt;
        
        OrderApi__Badge_Workflow__c bw = (OrderApi__Badge_Workflow__c)Fon_TestDataFactory.createSObject('OrderApi__Badge_Workflow__c', false);
        bw.OrderApi__Item__c=itm.Id;
        bw.OrderApi__Badge_Type__c=bt.Id;
        insert bw;
        
        OrderApi__Badge_Workflow__c bw1 = (OrderApi__Badge_Workflow__c)Fon_TestDataFactory.createSObject('OrderApi__Badge_Workflow__c', false);
        bw1.OrderApi__Item__c=itm1.Id;
        bw1.OrderApi__Badge_Type__c=bt.Id;
        insert bw1;

        OrderApi__Sales_Order__c SO = (OrderApi__Sales_Order__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order__c', false);
        SO.OrderApi__Contact__c=con.Id;
        SO.OrderApi__Posting_Entity__c='Invoice';
        insert SO;
        
        OrderApi__Sales_Order_Line__c SOLI = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false); 
        SOLI.OrderApi__Sales_Order__c=SO.ID;
        SOLI.OrderApi__Item__c= itm2.Id;
        Insert SOLI;
        
        SO.OrderApi__Status__c='Closed';
        update SO;
        
        OrderApi__Invoice__c inv = (OrderApi__Invoice__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice__c', false); 
        inv.OrderApi__Sales_Order__c=SO.id;
        inv.OrderApi__Contact__c=con.Id;
        insert inv;
        
        OrderApi__Subscription__c sub = (OrderApi__Subscription__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription__c', false); 
        sub.OrderApi__Contact__c=con.Id;
        sub.OrderApi__Is_Active__c=true;
        sub.OrderApi__Item__c=itm2.Id;
        sub.OrderApi__Status__c='Active';
        sub.OrderApi__Subscription_Plan__c=plan.Id;
        sub.OrderApi__Sales_Order_Line__c=SOLI.Id;
        insert sub;

        OrderApi__Subscription_Line__c sl = (OrderApi__Subscription_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription_Line__c', false); 
        sl.OrderApi__Subscription__c=sub.Id;
        sl.OrderApi__Item__c=itm3.Id;
        sl.OrderApi__Is_Amendment__c=true;
        sl.OrderApi__Sales_Order_Line__c=SOLI.Id;
        Insert sl;
        
        OrderApi__Badge__c bdg = (OrderApi__Badge__c)Fon_TestDataFactory.createSObject('OrderApi__Badge__c', false); 
        bdg.OrderApi__Is_Active__c=true;
        bdg.OrderApi__Sales_Order_Line__c=SOLI.Id;
        insert bdg;
        
        Fon_MembershipManagementInterfaceCtrl.changeStateLocalMethod(con.Id,ms.Id,'Kansas','Kansas City');
        Fon_MembershipManagementInterfaceCtrl.cancelMembership(con.Id,'test',true);  
        OrderApi__Invoice__c orderInv = [Select id , OrderApi__Is_Cancelled__c From OrderApi__Invoice__c where Id =:inv.Id];
        system.assertEquals(true, orderInv.OrderApi__Is_Cancelled__c);
        Test.stopTest();
    }
    @isTest
    public static void method1(){
        

        Account acct = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert acct;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        con.AccountId= acct.Id;
        con.Fon_Chapter_Change_Needed__c=true;
        //con.Fon_Current_Membership_Status__c='Inactive';
        insert con;
        
        Contact con1 = (Contact)Fon_TestDataFactory.createSObject('Contact', false);
        con.AccountId= acct.Id;
        con.Fon_Chapter_Change_Needed__c=false;
        //con.Fon_Current_Membership_Status__c='Inactive';
        insert con1;
        
        Fon_Membership_Staging__c ms = (Fon_Membership_Staging__c)Fon_TestDataFactory.createSObject('Fon_Membership_Staging__c', true); 
        ms.Fon_Contact__c=con.Id;
        ms.Fon_Staging_Status__c='Active';
        ms.Fon_Membership_Type__c='Resident';
        ms.Fon_Membership_State__c = 'Virginia';
        ms.Fon_Membership_Local__c= 'VA Northern Virginia';
         ms.Fon_Residency_Program_Graduation_Date__c=system.today();
        insert ms;
        
        OrderApi__Item_Class__c itmClassMain = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClassMain.Fon_Is_Main_Membership__c=true;
        itmClassMain.OrderApi__Is_Active__c=true;
        insert itmClassMain;
        
         OrderApi__Item__c itm = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        
        itm.OrderApi__Item_Class__c=itmClassMain.Id;
        insert itm;
        
        OrderApi__Subscription_Plan__c plan = (OrderApi__Subscription_Plan__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription_Plan__c', false);
        plan.OrderApi__Type__c='Lifetime';
        plan.OrderApi__Is_Active__c=true;
        insert plan;
        
        OrderApi__Subscription__c subscription = (OrderApi__Subscription__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription__c', false); 
        subscription.OrderApi__Contact__c=con1.Id;
        subscription.OrderApi__Status__c='Active';
        subscription.OrderApi__Item__c=itm.Id;
        subscription.OrderApi__Subscription_Plan__c=plan.Id;
        insert subscription;
        
        OrderApi__Subscription__c subscription1 = (OrderApi__Subscription__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription__c', false); 
        subscription1.OrderApi__Contact__c=con.Id;
        subscription1.OrderApi__Status__c='Active';
        subscription1.OrderApi__Item__c=itm.Id;
        subscription1.OrderApi__Subscription_Plan__c=plan.Id;
        insert subscription1;
        
        Test.startTest();
        Boolean check=Fon_MembershipManagementInterfaceCtrl.changeStateLocal(con.Id); 
        system.assertEquals(true, check);
        Boolean check1=Fon_MembershipManagementInterfaceCtrl.changeStateLocal(con1.Id);
        system.assertEquals(false, check1);
        Fon_MembershipManagementInterfaceCtrl.fetchingActiveMembership(con.Id);
        Fon_MembershipManagementInterfaceCtrl.changeMembershipType(con.Id);
        Fon_MembershipManagementInterfaceCtrl.fetchingActiveSubscription(con1.Id);
        Fon_MembershipManagementInterfaceCtrl.updateSubscription(con1.Id);
        OrderApi__Subscription__c sub = [select Id, OrderApi__Status__c From OrderApi__Subscription__c Where Id =:subscription.Id];
        System.assertEquals('Cancelled', sub.OrderApi__Status__c);
        Test.stopTest();
    }
    
   
   
    
}