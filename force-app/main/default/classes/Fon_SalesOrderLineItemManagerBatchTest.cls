@isTest 
public class Fon_SalesOrderLineItemManagerBatchTest 
{
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
            //cons.apexClass = Fon_SalesOrderLine_Trigger.class.getName();
            cons.namespace = '';
            cons.isEnabled = true;
            cons.sObjectName = 'OrderApi__Sales_Order_Line__c';
            cons.executionOrder = 0;
            rules.add(cons);
            Framework.Config.push(rules);               
            
            isInstalled = true;
           
        }
    }
    
    static testMethod void executeBatchMethodFirst(){
        Test.startTest();
        install();
        Test.stopTest();
    }
    
    static testMethod void executeBatchMethod(){
        
        acct = new Account();
        acct.Name = 'Test Account';
        insert acct;

        con = new Contact();
        con.LastName = 'LASTNAME';
        con.AccountId = acct.Id;
        con.Email ='testemail@testemail.com';
        con.MailingPostalCode = '22209';
        con.Fon_Total_Months_of_Membership__c = 1122;
        con.Fon_Current_Membership_Status__c = 'Active';
        
        insert con;
        bg = new OrderApi__Business_Group__c();
        bg.Name = 'Test BG';
        insert bg;
        
        OrderApi__GL_Account__c glAcc = new OrderApi__GL_Account__c(OrderApi__Business_Group__c = bg.id); //, GL_CODE_UNITED__c='00-00-0000-0000-3'
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
        subPlan.OrderApi__Enable_Schedule__c = true;
        subPlan.OrderApi__Schedule_Frequency__c = 'Annually';
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
        itm.Name = 'College Services';
        itm.OrderApi__Is_Subscription__c = true;
        itm.OrderApi__Business_Group__c = bg.Id;
        itm.OrderApi__Item_Class__c = itmClass.Id;
        itm.OrderApi__Is_Active__c = false;
        itm.OrderApi__Price__c = 160;
        itm.OrderApi__Income_Account__c = glAcc.id;
        itm.OrderApi__Adjustment_Account__c = glAcc.id;
        itm.OrderApi__Refund_Account__c = glAcc.id;
        itm.Is_Foundation_Donation__c = true;
        items.add(itm); 
        
        itm1 = new OrderApi__Item__c();
        itm1.Name = 'Individual Membership - College Services Head Coach';
        itm1.OrderApi__Is_Subscription__c = true;
        itm1.OrderApi__Business_Group__c = bg.Id;
        itm1.OrderApi__Item_Class__c = itmClass.Id;
        itm1.OrderApi__Is_Active__c = false;
        itm1.OrderApi__Price__c = 0;
        itm1.OrderApi__Income_Account__c = glAcc.id;
        itm1.OrderApi__Adjustment_Account__c = glAcc.id;
        itm1.OrderApi__Refund_Account__c = glAcc.id;
        items.add(itm1); 
        
        insert items;
        
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
        sol.OrderApi__Subscription_Plan__c = subPlan.id;
        insert sol;
        
        OrderApi__Subscription__c objSubscription = new OrderApi__Subscription__c();
        objSubscription.OrderApi__Account__c = acct.Id;
        objSubscription.OrderApi__Contact__c = con.Id;
        objSubscription.OrderApi__Subscription_Plan__c = subPlan.Id;
        objSubscription.OrderApi__Item__c = itm1.Id;
        objSubscription.OrderApi__Sales_Order_Line__c = sol.Id;
        
        insert objSubscription;
        
        OrderApi__Sales_Order_Line__c sol1 = new OrderApi__Sales_Order_Line__c();
        sol1.OrderApi__Sales_Order__c = so.id;
        sol1.OrderApi__Account__c = acct.id;
        sol1.OrderApi__Contact__c = con.id;
        sol1.OrderApi__Item_Class__c = itm1.OrderApi__Item_Class__c;
        sol1.OrderApi__Item__c = itm1.id;
        sol1.OrderApi__Is_Subscription__c = true;
        sol1.OrderApi__Subscription_Plan__c = subPlan.id;
        sol1.OrderApi__Is_Renewal__c = true;
        sol1.OrderApi__Subscription__c = objSubscription.Id;
        
        insert sol1;
        
        Profile p = [select Id, Name from Profile where Name IN ('Fonteva Customer Community Login User') limit 1];
        
        User newUser = new User(
             profileId = p.id,
             username = 'newUser@yahoo.com',
             emailencodingkey = 'UTF-8',
             localesidkey = 'en_US',
             languagelocalekey = 'en_US',
             timezonesidkey = 'America/Los_Angeles',
             alias='nuser',
             lastname='lastname',
             contactId = con.id
        );
        newUser.Email = 'test1@email.com';
        insert newUser;
        System.runAs(newUser){
            /*
            Test.startTest();
            delete sol;
            Test.stopTest();
            */
        }
        
        Test.startTest();
            Fon_SalesOrderLineItemManagerBatch batchable = new Fon_SalesOrderLineItemManagerBatch();
            DataBase.executeBatch(batchable);
        Test.stopTest();
    }
}