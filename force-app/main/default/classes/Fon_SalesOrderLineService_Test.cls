@isTest
public class Fon_SalesOrderLineService_Test {
    public static Boolean isInstalled = false;
    static Account acct = new Account();
    static Contact con = new Contact();
    static OrderApi__Subscription_Plan__c subPlan = new OrderApi__Subscription_Plan__c();
    static OrderApi__Payment_Method__c pm = new OrderApi__Payment_Method__c();
    static OrderApi__Business_Group__c bg = new OrderApi__Business_Group__c();
    static OrderApi__Item_Class__c itmClass = new OrderApi__Item_Class__c();
    static OrderApi__Item__c itm = new OrderApi__Item__c();
    static OrderApi__Item__c itm1 = new OrderApi__Item__c();
    
    private static void install() {
        if (!isInstalled) {
            //Fon_PackageScripts.install();
            Framework.Installer.install();
            PagesApi.PackageScripts.install();
            OrderApi.PackageScripts.install();
            EventApi.PackageScripts.install();
            
            // Create a routing rule for SalesOrderLine
            Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
            Framework.RoutingRule cons = new Framework.RoutingRule();
            cons.apexClass = Fon_SalesOrderLineDomain.class.getName();
            cons.namespace = '';
            cons.isEnabled = true;
            cons.sObjectName = 'OrderApi__Sales_Order_Line__c';
            cons.executionOrder = 0;
            rules.add(cons);
            Framework.Config.push(rules);               
            
            isInstalled = true;
            
        }
    }
    
    @isTest
    public static void method1(){
        install();     
        acct = new Account();
        acct.Name = 'Test Account';
        insert acct;
        
        con = new Contact();
        con.LastName = 'LASTNAME';
        con.AccountId = acct.Id;
        con.Email ='testemail@testemail.com';
        con.MailingPostalCode = '22209';
        con.Fon_Total_Months_of_Membership__c=10;
        con.Fon_Current_Membership_Status__c='Active';
        insert con;
       
        bg = new OrderApi__Business_Group__c();
        bg.Name = 'Test BG';
        insert bg;
        
        OrderApi__GL_Account__c glAcc = new OrderApi__GL_Account__c(OrderApi__Business_Group__c = bg.id);
        insert glAcc ;
        
        subPlan = new OrderApi__Subscription_Plan__c();
        subPlan.Name = 'test subscription plan';
        subPlan.OrderApi__Type__c = 'Termed';
        subPlan.OrderApi__Initial_Term_Months__c = 12;
        subPlan.OrderApi__Renewal_Term_Months__c = 12;
        subPlan.OrderApi__Bill_Cycle__c = 'AUTO';
        subPlan.OrderApi__Auto_Renew_Option__c = 'Enabled';
        subPlan.OrderApi__Enable_Proration__c = false;
        subPlan.OrderApi__Is_Active__c = true;
        subPlan.OrderApi__Business_Group__c = bg.Id;
        subPlan.OrderApi__Enable_Schedule__c=true;
        subPlan.OrderApi__Schedule_Frequency__c='Monthly';
        insert subPlan;
        
        itmClass = new OrderApi__Item_Class__c();
        itmClass.Name = 'Test Class';
        itmClass.OrderApi__Enable_Assignments__c = false;
        itmClass.OrderApi__Is_Subscription__c = true;
        itmClass.OrderApi__Assignment_SObject__c = 'TEST__C';
        itmClass.OrderApi__Is_Active__c = false;
        itmClass.OrderApi__Business_Group__c = bg.Id;
        itmClass.OrderApi__Is_Active__c = true;
        itmClass.Fon_Is_Main_Membership__c=true;
        insert itmClass;
        
        OrderApi__Item__c[] items = new List<OrderApi__Item__c>();
        
        itm = new OrderApi__Item__c();
        itm.Name = 'Convenience fee';
        itm.OrderApi__Is_Subscription__c = true;
        itm.OrderApi__Business_Group__c = bg.Id;
        itm.OrderApi__Item_Class__c = itmClass.Id;
        itm.OrderApi__Is_Active__c = false;
        itm.OrderApi__Price__c = 15;
        itm.OrderApi__Income_Account__c = glAcc.id;
        itm.OrderApi__Adjustment_Account__c = glAcc.id;
        itm.OrderApi__Refund_Account__c = glAcc.id;
        items.add(itm); 
        
        itm1 = new OrderApi__Item__c();
        itm1.Name = 'Donation';
        itm1.OrderApi__Is_Subscription__c = true;
        itm1.OrderApi__Business_Group__c = bg.Id;
        itm1.OrderApi__Item_Class__c = itmClass.Id;
        itm1.OrderApi__Is_Active__c = false;
        itm1.OrderApi__Price__c = 20;
        itm1.Is_Foundation_Donation__c=true;
        itm1.OrderApi__Income_Account__c = glAcc.id;
        itm1.OrderApi__Adjustment_Account__c = glAcc.id;
        itm1.OrderApi__Refund_Account__c = glAcc.id;
        items.add(itm1); 
        insert items;
        
        
        OrderApi__Item_Subscription_Plan__c it = new OrderApi__Item_Subscription_Plan__c();
        it.OrderApi__Is_Default__c=true;
        it.OrderApi__Item__c=itm.Id;
        it.OrderApi__Subscription_Plan__c=subPlan.Id;
        insert it;
        
        OrderApi__Item_Subscription_Plan__c sp = new OrderApi__Item_Subscription_Plan__c();
        sp.OrderApi__Is_Default__c=true;
        sp.OrderApi__Item__c=itm1.Id;
        sp.OrderApi__Subscription_Plan__c=subPlan.Id;
        insert sp;
      
        OrderApi__Subscription__c sub = new OrderApi__Subscription__c();
        sub.OrderApi__Account__c=acct.id;
        sub.OrderApi__Contact__c=con.id;
        sub.OrderApi__Subscription_Plan__c=subPlan.id;
        sub.OrderApi__Item__c=itm1.Id;
        //  sub.OrderApi__Sales_Order_Line__c = sol1.id;
        insert sub;
        
        OrderApi__Subscription_Line__c subLine = new OrderApi__Subscription_Line__c();
        subLine.OrderApi__Subscription__c = sub.Id;
        subLine.OrderApi__Item__c = itm.id;
        subLine.OrderApi__Is_Amendment__c= true;
        insert subLine;
        
        OrderApi__Sales_Order__c so = new OrderApi__Sales_Order__c();
        so.OrderApi__Account__c = acct.id;
        so.OrderApi__Contact__c = con.id;
        so.OrderApi__Entity__c = 'Account';
        so.OrderApi__Posting_Entity__c = 'Receipt';
        insert so;
        
        OrderApi__Sales_Order_Line__c sol = new OrderApi__Sales_Order_Line__c();
        sol.OrderApi__Sales_Order__c = so.id;
        sol.OrderApi__Account__c = acct.id;
        sol.OrderApi__Contact__c = con.id;
        sol.OrderApi__Item_Class__c = itm.OrderApi__Item_Class__c;
        sol.OrderApi__Item__c = itm.id;
        sol.OrderApi__Is_Subscription__c = true;       
        sol.OrderApi__Is_Renewal__c=true;
        sol.OrderApi__Subscription__c=sub.Id;
        insert sol;
        
        
        
        OrderApi__Item__c[] items1 = new List<OrderApi__Item__c>();
        itm.OrderApi__Is_Active__c=true;
        itm1.OrderApi__Is_Active__c=true;
        items1.add(itm);
        items1.add(itm1);
        //   update items1;
        
    }
}