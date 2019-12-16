@isTest
public class Fon_SubscriptionPlanCtrlTest {
    @isTest
    public static void method1(){
        
        Account ac= new Account();
        ac.Name='testAccount';
        Insert ac;
        
        
        Contact con= new Contact();
        con.AccountId= ac.Id;
        con.LastName= 'testLast';
      
        con.Fon_Total_Months_of_Membership__c=10;
        con.Fon_Chapter_Change_Needed__c=true;
        con.Fon_Current_Membership_Status__c='Inactive';
        insert con;
        
        OrderApi__Item_Class__c itmClassMain= new OrderApi__Item_Class__c();
        itmClassMain.Fon_Is_Main_Membership__c=true;
        itmClassMain.OrderApi__Is_Active__c=true;
        insert itmClassMain;
        
        OrderApi__Item__c itm1 = new OrderApi__Item__c();
        itm1.Name='Membership testLocal Dues';
        itm1.OrderApi__Item_Class__c=itmClassMain.Id;
        insert itm1;
        
        OrderApi__Subscription_Plan__c plan1= new OrderApi__Subscription_Plan__c();
        plan1.OrderApi__Type__c='Calendar';
        plan1.OrderApi__Is_Active__c=true;
        insert plan1;
        
        OrderApi__Subscription_Plan__c newPlan= new OrderApi__Subscription_Plan__c();
        newPlan.OrderApi__Type__c='Lifetime';
        newPlan.OrderApi__Is_Active__c=true;
        newPlan.OrderApi__Enable_Schedule__c=true;
        insert newPlan;
        
        OrderApi__Subscription_Plan__c plan= new OrderApi__Subscription_Plan__c();
        plan.OrderApi__Type__c='Lifetime';
        plan.OrderApi__Is_Active__c=true;
        plan.OrderApi__Enable_Schedule__c=true;
        insert plan;
        
        OrderApi__Subscription__c sub = new OrderApi__Subscription__c();
        sub.OrderApi__Contact__c=con.Id;
        sub.OrderApi__Is_Active__c=true;
        sub.OrderApi__Item__c=itm1.Id;
        sub.OrderApi__Status__c='Active';
        sub.OrderApi__Subscription_Plan__c=plan.Id;
        insert sub;
        
        OrderApi__Subscription__c sub1 = new OrderApi__Subscription__c();
        sub1.OrderApi__Contact__c=con.Id;
        sub1.OrderApi__Is_Active__c=true;
        sub1.OrderApi__Item__c=itm1.Id;
        sub1.OrderApi__Status__c='Active';
        sub1.OrderApi__Subscription_Plan__c=plan1.Id;
        insert sub1;
        
        Fon_Membership_Staging__c ms = new Fon_Membership_Staging__c();
        ms.Fon_Contact__c=con.Id;
        ms.Fon_Staging_Status__c='Active';
        ms.Fon_Membership_Type__c='Resident';
        ms.Fon_Membership_State__c = 'Virginia';
        ms.Fon_Membership_Local__c= 'VA Northern Virginia';
      //  ms.Fon_Dues_Paid_by_Chapter__c=5;
       // ms.Fon_Dues_Paid_by_Residency_Program__c=4;
        ms.Fon_Membership_Activation_Date__c=system.today();
        ms.Fon_Join_Date__c=system.today();
        ms.Fon_Chapter_Join_Date__c=system.today();
        ms.Fon_Residency_Program_Graduation_Date__c=system.today();
        insert ms;
        
        OrderApi__Sales_Order__c salesOrder = new OrderApi__Sales_Order__c();
        salesOrder.OrderApi__Status__c='Open';
        salesOrder.OrderApi__Posting_Entity__c='Invoice';
        salesOrder.OrderApi__Contact__c=con.Id;
        insert salesOrder;
        
        OrderApi__Sales_Order_Line__c SOLI = new OrderApi__Sales_Order_Line__c();
        SOLI.OrderApi__Item__c=itm1.Id;
        SOLI.OrderApi__Subscription_Plan__c = plan.Id;
        SOLI.OrderApi__Sales_Order__c=salesOrder.Id;
        SOLI.OrderApi__Is_Renewal__c=true;
        insert SOLI;
        
        sub1.OrderApi__Sales_Order_Line__c=SOLI.id;
        update sub1;
        
        salesOrder.OrderApi__Status__c='Closed';
        update salesOrder;
        
        OrderApi__Invoice__c inv = new OrderApi__Invoice__c();
        inv.OrderApi__Invoice_Date__c=System.today();
        inv.OrderApi__Contact__c=con.id;
        inv.OrderApi__Sales_Order__c=salesOrder.id;
        inv.OrderApi__Amount_Paid__c=50;
        insert inv;
        
        OrderApi__Payment_Method__c pm = new OrderApi__Payment_Method__c();
        insert pm;
        
        OrderApi__Scheduled_Payment__c sp =new OrderApi__Scheduled_Payment__c();
        sp.OrderApi__Invoice__c=inv.id;
        sp.OrderApi__Payment_Method__c=pm.id;
            insert sp;
        
          OrderApi__Item_Subscription_Plan__c isp= new OrderApi__Item_Subscription_Plan__c();
        isp.OrderApi__Item__c=itm1.Id;
        isp.OrderApi__Subscription_Plan__c=plan.Id;
        insert isp;
        
        
        Test.startTest();
        Fon_SubscriptionPlanCtrl.fetchAllSuscriptionPlan(sub.Id);
        Fon_SubscriptionPlanCtrl.updatingSubscriptionPlan(con.Id,ms.Id,sub1.Id,sub.Id);
        Fon_SubscriptionPlanCtrl.changeSubscriptionPlan(con.Id,sub1,newPlan.Id);
        Fon_SubscriptionPlanCtrl.changePlanFullToInstallment(con.Id,plan.Id);
        Fon_SubscriptionPlanCtrl.changePlanInstallmentToFull(con.Id);
        Fon_SubscriptionPlanCtrl.CreateNewInvoice(salesOrder.id,con.id);
        Fon_SubscriptionPlanCtrl.CreateNewInvoiceLine(inv.Id,itm1.id,52);
        Test.stopTest();          
        
    }
    
    
    
}