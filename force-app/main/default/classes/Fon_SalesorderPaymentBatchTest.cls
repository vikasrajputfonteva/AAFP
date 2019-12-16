@isTest 
public class Fon_SalesorderPaymentBatchTest{
    
    static testMethod void executeBatchMethod(){
        
        OrderApi__Business_Group__c bg = (OrderApi__Business_Group__c)Fon_TestDataFactory.createSObject('OrderApi__Business_Group__c', false); 
        insert bg;
        
        Account acct = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert acct;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        insert con;
        
        Set<Id> msId = new Set<Id>();
        
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
        ms.Fon_AAFP_Subscription_Plan_Picklist__c='Auto Full Pay';
        insert ms;
        
        msId.add(ms.Id);
        
        OrderApi__Credit_Memo__c cm = (OrderApi__Credit_Memo__c)Fon_TestDataFactory.createSObject('OrderApi__Credit_Memo__c', false); 
        cm.OrderApi__Contact__c = con.id;
        cm.OrderApi__Amount__c  = 200;
        cm.Fon_Suggested_Usage__c = 'Memberships';
        cm.Fon_Required__c = true;
        insert cm;
        
        OrderApi__Subscription_Plan__c subPlan = (OrderApi__Subscription_Plan__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription_Plan__c', false); 
        subPlan.OrderApi__Type__c = 'Termed';
        subPlan.OrderApi__Initial_Term_Months__c = 12;
        subPlan.OrderApi__Renewal_Term_Months__c = 12;
        subPlan.OrderApi__Bill_Cycle__c = 'AUTO';
        subPlan.OrderApi__Auto_Renew_Option__c = 'Enabled';
        subPlan.OrderApi__Is_Active__c = true;
        subPlan.OrderApi__Enable_Schedule__c = true;
        subPlan.OrderApi__Schedule_Frequency__c = 'Annually';
        insert subPlan;
        
        OrderApi__Item_Class__c itmClass = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClass.OrderApi__Is_Subscription__c = true;
        itmClass.OrderApi__Is_Active__c = true;
        itmClass.Fon_Is_Main_Membership__c=true;
        insert itmClass;
        
        OrderApi__Item__c[] items = new List<OrderApi__Item__c>();
        
        OrderApi__Item__c itm = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm.OrderApi__Is_Subscription__c = true;
        itm.OrderApi__Item_Class__c = itmClass.Id;
        itm.OrderApi__Is_Active__c = false;
        itm.OrderApi__Price__c = 100;
        itm.Is_Foundation_Donation__c = true;
        items.add(itm); 
        
        OrderApi__Item__c itm1 = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        itm1.OrderApi__Is_Subscription__c = true;
        itm1.OrderApi__Item_Class__c = itmClass.Id;
        itm1.OrderApi__Is_Active__c = false;
        itm1.OrderApi__Price__c = 100;
        items.add(itm1); 
        
        insert items;
        
        
        OrderApi__Payment_Method__c pm = (OrderApi__Payment_Method__c)Fon_TestDataFactory.createSObject('OrderApi__Payment_Method__c', false);
        pm.OrderApi__Contact__c= con.Id;
        insert pm;
        
        OrderApi__Sales_Order__c so = (OrderApi__Sales_Order__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order__c', false);
        so.OrderApi__Account__c = acct.id;
        so.OrderApi__Contact__c = con.id;
        so.OrderApi__Entity__c = 'Account';
        so.OrderApi__Posting_Entity__c = 'Invoice';
        so.Fon_isPaymentProcess__c = true;
        so.Fon_is_Dues_Paid_by_Chapter_Residency__c= false;
        so.OrderApi__Payment_Method__c = pm.Id;
        so.Fon_Salesorder_Type__c='Donation';
        so.Fon_Membership_Staging__c=ms.Id;
        insert so;
        
        OrderApi__Sales_Order_Line__c sol = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false);
        sol.OrderApi__Sales_Order__c = so.id;
        sol.OrderApi__Account__c = acct.id;
        sol.OrderApi__Contact__c = con.id;
        sol.OrderApi__Item__c = itm.id;
        sol.OrderApi__Is_Subscription__c = true;
        sol.OrderApi__Subscription_Plan__c = subPlan.id;
        sol.OrderApi__Quantity__c = 1;
        sol.OrderApi__Sale_Price__c = 100;
        sol.OrderApi__Price_Override__c = true;
        insert sol;
        
        so.OrderApi__Status__c = 'Closed';
        update so;
        
        OrderApi__Subscription__c objSubscription = (OrderApi__Subscription__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription__c', false);
        objSubscription.OrderApi__Account__c = acct.Id;
        objSubscription.OrderApi__Contact__c = con.Id;
        objSubscription.OrderApi__Subscription_Plan__c = subPlan.Id;
        objSubscription.OrderApi__Item__c = itm.Id;
        objSubscription.OrderApi__Sales_Order_Line__c = sol.Id;
        insert objSubscription;
        
        so.OrderApi__Posting_Status__c='Posted';
        update so;
        
        Set<Id> invIDS= new Set<Id>();
        OrderApi__Invoice__c inv1 = (OrderApi__Invoice__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice__c', false);
        inv1.OrderApi__Invoice_Date__c=System.today();
        inv1.OrderApi__Contact__c=con.id;
        inv1.OrderApi__Sales_Order__c=so.id;
        inv1.OrderApi__Entity__c = 'Account';
        inv1.OrderApi__Business_Group__c=bg.Id;
        inv1.OrderApi__Account__c= acct.id;
        insert inv1;
        invIDS.add(inv1.Id);
        
        
        OrderApi__Invoice_Line__c invline1 = (OrderApi__Invoice_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice_Line__c', false);
        invline1.OrderApi__Invoice__c=inv1.Id;
        invline1.OrderApi__Item__c=itm.Id;
        invline1.OrderApi__Quantity__c = 1;
        invline1.OrderApi__Sale_Price__c = 100;
        invline1.OrderApi__Balance_Due__c = 100;
        invline1.OrderApi__Price_Override__c = true;
        invline1.OrderApi__Total__c = 100;
        insert invline1; 
        
        inv1.OrderApi__Status__c='Posted';
        update inv1;
        
        
        
        decimal amount=5;
        
        
        
        Test.startTest();
        
        Fon_SalesorderPaymentBatch batchable = new Fon_SalesorderPaymentBatch(msId);
        DataBase.executeBatch(batchable,1);
        //OrderApi__Credit_Memo_Line__c cmline = batchable.createInstanceOfCreditMemoLine(cm.Id,inv1.Id,amount,invline1.Id);
        OrderApi__Credit_Memo_Line__c cmline = Fon_SalesorderPaymentBatch.createInstanceOfCreditMemoLine(cm.Id,inv1.Id,amount,invline1.Id);
       
        System.assert(cmline!=null);     
        System.AssertEquals(database.countquery('SELECT COUNT() FROM OrderApi__Sales_Order__c '),1);
        Test.stopTest();
        
    } 
    


    
    
    static testMethod void executeBatchMethod2(){
        
        OrderApi__Business_Group__c bg = (OrderApi__Business_Group__c)Fon_TestDataFactory.createSObject('OrderApi__Business_Group__c', false); 
        insert bg;
        
        Account acct = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert acct;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        insert con;
        
        Set<Id> msId = new Set<Id>();
        
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
        ms.Fon_AAFP_Subscription_Plan_Picklist__c='Auto Full Pay';
    insert ms;
        msId.add(ms.Id);
        
        
        
        OrderApi__Subscription_Plan__c subPlan = (OrderApi__Subscription_Plan__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription_Plan__c', false); 
        subPlan.OrderApi__Type__c = 'Termed';
        subPlan.OrderApi__Initial_Term_Months__c = 12;
        subPlan.OrderApi__Renewal_Term_Months__c = 12;
        subPlan.OrderApi__Bill_Cycle__c = 'AUTO';
        subPlan.OrderApi__Auto_Renew_Option__c = 'Enabled';
        subPlan.OrderApi__Is_Active__c = true;
        subPlan.OrderApi__Enable_Schedule__c = true;
        subPlan.OrderApi__Schedule_Frequency__c = 'Annually';
        insert subPlan;
        
        OrderApi__Item_Class__c itmClass = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClass.OrderApi__Is_Subscription__c = true;
        itmClass.OrderApi__Is_Active__c = true;
        itmClass.Fon_Is_Main_Membership__c=true;
        insert itmClass;
        
        OrderApi__Item__c[] items = new List<OrderApi__Item__c>();
        
        OrderApi__Item__c itm = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm.OrderApi__Is_Subscription__c = true;
        itm.OrderApi__Item_Class__c = itmClass.Id;
        itm.OrderApi__Is_Active__c = false;
        itm.OrderApi__Price__c = 100;
        itm.Is_Foundation_Donation__c = true;
        items.add(itm); 
        
        OrderApi__Item__c itm1 = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        itm1.OrderApi__Is_Subscription__c = true;
        itm1.OrderApi__Item_Class__c = itmClass.Id;
        itm1.OrderApi__Is_Active__c = false;
        itm1.OrderApi__Price__c = 100;
        items.add(itm1); 
        
        insert items;
        
        
        OrderApi__Payment_Method__c pm = (OrderApi__Payment_Method__c)Fon_TestDataFactory.createSObject('OrderApi__Payment_Method__c', false);
        pm.OrderApi__Contact__c= con.Id;
        insert pm;
        
        OrderApi__Sales_Order__c so = (OrderApi__Sales_Order__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order__c', false);
        so.OrderApi__Account__c = acct.id;
        so.OrderApi__Contact__c = con.id;
        so.OrderApi__Entity__c = 'Account';
        so.Fon_isPaymentProcess__c = true;
        so.Fon_is_Dues_Paid_by_Chapter_Residency__c= false;
        so.OrderApi__Payment_Method__c = pm.Id;
        so.Fon_Salesorder_Type__c='Donation';
        so.Fon_Membership_Staging__c=ms.Id;
       
        insert so;
        
        OrderApi__Sales_Order_Line__c sol = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false);
        sol.OrderApi__Sales_Order__c = so.id;
        sol.OrderApi__Account__c = acct.id;
        sol.OrderApi__Contact__c = con.id;
        sol.OrderApi__Item__c = itm.id;
        sol.OrderApi__Is_Subscription__c = true;
        sol.OrderApi__Subscription_Plan__c = subPlan.id;
        sol.OrderApi__Quantity__c = 1;
        sol.OrderApi__Sale_Price__c = 100;
        sol.OrderApi__Total__c =100;
        sol.OrderApi__Price_Override__c = true;
        insert sol;
        
        so.OrderApi__Status__c = 'Closed';
        update so;
        
        
        

        Test.startTest();
        
        Fon_SalesorderPaymentBatch batchable = new Fon_SalesorderPaymentBatch(msId);
        DataBase.executeBatch(batchable,1);
    
        System.AssertEquals(database.countquery('SELECT COUNT() FROM OrderApi__Sales_Order__c '),1);
        Test.stopTest();
        
    } 
static testMethod void executeBatchMethod3(){
        
        OrderApi__Business_Group__c bg = (OrderApi__Business_Group__c)Fon_TestDataFactory.createSObject('OrderApi__Business_Group__c', false); 
        insert bg;
        
        Account acct = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert acct;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        insert con;
        
        Set<Id> msId = new Set<Id>();
        
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
        ms.Fon_AAFP_Subscription_Plan_Picklist__c='Auto Full Pay';
    insert ms;
        msId.add(ms.Id);
        
        
        
        OrderApi__Subscription_Plan__c subPlan = (OrderApi__Subscription_Plan__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription_Plan__c', false); 
        subPlan.OrderApi__Type__c = 'Termed';
        subPlan.OrderApi__Initial_Term_Months__c = 12;
        subPlan.OrderApi__Renewal_Term_Months__c = 12;
        subPlan.OrderApi__Bill_Cycle__c = 'AUTO';
        subPlan.OrderApi__Auto_Renew_Option__c = 'Enabled';
        subPlan.OrderApi__Is_Active__c = true;
        subPlan.OrderApi__Enable_Schedule__c = true;
        subPlan.OrderApi__Schedule_Frequency__c = 'Annually';
        insert subPlan;
        
        OrderApi__Item_Class__c itmClass = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClass.OrderApi__Is_Subscription__c = true;
        itmClass.OrderApi__Is_Active__c = true;
        itmClass.Fon_Is_Main_Membership__c=true;
        insert itmClass;
        
        OrderApi__Item__c[] items = new List<OrderApi__Item__c>();
        
        OrderApi__Item__c itm = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm.OrderApi__Is_Subscription__c = true;
        itm.OrderApi__Item_Class__c = itmClass.Id;
        itm.OrderApi__Is_Active__c = false;
        itm.OrderApi__Price__c = 100;
        itm.Is_Foundation_Donation__c = true;
        items.add(itm); 
        
        OrderApi__Item__c itm1 = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        itm1.OrderApi__Is_Subscription__c = true;
        itm1.OrderApi__Item_Class__c = itmClass.Id;
        itm1.OrderApi__Is_Active__c = false;
        itm1.OrderApi__Price__c = 100;
        items.add(itm1); 
        
        insert items;
        
        
        OrderApi__Payment_Method__c pm = (OrderApi__Payment_Method__c)Fon_TestDataFactory.createSObject('OrderApi__Payment_Method__c', false);
        pm.OrderApi__Contact__c= con.Id;
        insert pm;
        
        OrderApi__Sales_Order__c so = (OrderApi__Sales_Order__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order__c', false);
        so.OrderApi__Account__c = acct.id;
        so.OrderApi__Contact__c = con.id;
        so.OrderApi__Entity__c = 'Account';
        so.Fon_isPaymentProcess__c = true;
        so.Fon_is_Dues_Paid_by_Chapter_Residency__c= false;
        so.OrderApi__Payment_Method__c = pm.Id;
        so.Fon_Salesorder_Type__c='Dues';
        so.Fon_Membership_Staging__c=ms.Id;
       
        insert so;
        
        OrderApi__Sales_Order_Line__c sol = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false);
        sol.OrderApi__Sales_Order__c = so.id;
        sol.OrderApi__Account__c = acct.id;
        sol.OrderApi__Contact__c = con.id;
        sol.OrderApi__Item__c = itm.id;
        sol.OrderApi__Is_Subscription__c = true;
        sol.OrderApi__Subscription_Plan__c = subPlan.id;
        sol.OrderApi__Quantity__c = 1;
        sol.OrderApi__Sale_Price__c = 100;
        sol.OrderApi__Total__c =100;
        sol.OrderApi__Price_Override__c = true;
        insert sol;
        
        so.OrderApi__Status__c = 'Closed';
        update so;
        
        
        

        Test.startTest();
        
        Fon_SalesorderPaymentBatch batchable = new Fon_SalesorderPaymentBatch(msId);
        DataBase.executeBatch(batchable,1);

        System.AssertEquals(database.countquery('SELECT COUNT() FROM OrderApi__Sales_Order__c '),1);
        Test.stopTest();
        
    } 
    static testMethod void executeBatchMethod4(){
        
        OrderApi__Business_Group__c bg = (OrderApi__Business_Group__c)Fon_TestDataFactory.createSObject('OrderApi__Business_Group__c', false); 
        insert bg;
        
        Account acct = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert acct;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        insert con;
        
        Set<Id> msId = new Set<Id>();
        
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
        ms.Fon_AAFP_Subscription_Plan_Picklist__c='Auto Full Pay';
    insert ms;
        msId.add(ms.Id);
        
        
        
        OrderApi__Subscription_Plan__c subPlan = (OrderApi__Subscription_Plan__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription_Plan__c', false); 
        subPlan.OrderApi__Type__c = 'Termed';
        subPlan.OrderApi__Initial_Term_Months__c = 12;
        subPlan.OrderApi__Renewal_Term_Months__c = 12;
        subPlan.OrderApi__Bill_Cycle__c = 'AUTO';
        subPlan.OrderApi__Auto_Renew_Option__c = 'Enabled';
        subPlan.OrderApi__Is_Active__c = true;
        subPlan.OrderApi__Enable_Schedule__c = true;
        subPlan.OrderApi__Schedule_Frequency__c = 'Annually';
        insert subPlan;
        
        OrderApi__Item_Class__c itmClass = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClass.OrderApi__Is_Subscription__c = true;
        itmClass.OrderApi__Is_Active__c = true;
        itmClass.Fon_Is_Main_Membership__c=true;
        insert itmClass;
        
        OrderApi__Item__c[] items = new List<OrderApi__Item__c>();
        
        OrderApi__Item__c itm = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm.OrderApi__Is_Subscription__c = true;
        itm.OrderApi__Item_Class__c = itmClass.Id;
        itm.OrderApi__Is_Active__c = false;
        itm.OrderApi__Price__c = 100;
        itm.Is_Foundation_Donation__c = true;
        items.add(itm); 
        
        OrderApi__Item__c itm1 = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        itm1.OrderApi__Is_Subscription__c = true;
        itm1.OrderApi__Item_Class__c = itmClass.Id;
        itm1.OrderApi__Is_Active__c = false;
        itm1.OrderApi__Price__c = 100;
        items.add(itm1); 
        
        insert items;
        
        
        OrderApi__Payment_Method__c pm = (OrderApi__Payment_Method__c)Fon_TestDataFactory.createSObject('OrderApi__Payment_Method__c', false);
        pm.OrderApi__Contact__c= con.Id;
        insert pm;
        
        OrderApi__Sales_Order__c so = (OrderApi__Sales_Order__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order__c', false);
        so.OrderApi__Account__c = acct.id;
        so.OrderApi__Contact__c = con.id;
        so.OrderApi__Entity__c = 'Account';
        so.Fon_isPaymentProcess__c = true;
        so.Fon_is_Dues_Paid_by_Chapter_Residency__c= false;
        so.OrderApi__Payment_Method__c = pm.Id;
        so.Fon_Salesorder_Type__c='Dues';
        so.Fon_Membership_Staging__c=ms.Id;
       
        insert so;
        
        OrderApi__Sales_Order_Line__c sol = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false);
        sol.OrderApi__Sales_Order__c = so.id;
        sol.OrderApi__Account__c = acct.id;
        sol.OrderApi__Contact__c = con.id;
        sol.OrderApi__Item__c = itm.id;
        sol.OrderApi__Is_Subscription__c = true;
        sol.OrderApi__Subscription_Plan__c = subPlan.id;
        sol.OrderApi__Quantity__c = 1;
        sol.OrderApi__Sale_Price__c = 100;
        sol.OrderApi__Total__c =100;
        sol.OrderApi__Price_Override__c = true;
        insert sol;
        
        so.OrderApi__Status__c = 'Closed';
        update so;
        
        OrderApi__Credit_Memo__c cm = (OrderApi__Credit_Memo__c)Fon_TestDataFactory.createSObject('OrderApi__Credit_Memo__c', false); 
        cm.OrderApi__Contact__c = con.id;
        cm.OrderApi__Amount__c  = 200;
        cm.Fon_Suggested_Usage__c = 'Memberships';
        cm.Fon_Required__c = true;
        insert cm;
        
        
        OrderApi__Credit_Memo_Line__c cmLine =(OrderApi__Credit_Memo_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Credit_Memo_Line__c', false); 
        cmLine.OrderApi__Amount__c=50;
        cmLine.OrderApi__Credit_Memo__c=cm.Id;
        insert cmLine;
        
        cm.OrderApi__Status__c='Posted';
        
        OrderApi__Invoice__c inv1 = (OrderApi__Invoice__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice__c', false);
        inv1.OrderApi__Invoice_Date__c=System.today();
        inv1.OrderApi__Contact__c=con.id;
        inv1.OrderApi__Sales_Order__c=so.id;
        inv1.OrderApi__Entity__c = 'Account';
        inv1.OrderApi__Business_Group__c=bg.Id;
        inv1.OrderApi__Account__c= acct.id;
        insert inv1;
        
        
        OrderApi__Invoice_Line__c invline1 = (OrderApi__Invoice_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice_Line__c', false);
        invline1.OrderApi__Invoice__c=inv1.Id;
        invline1.OrderApi__Item__c=itm.Id;
        invline1.OrderApi__Quantity__c = 1;
        invline1.OrderApi__Sale_Price__c = 100;
        invline1.OrderApi__Balance_Due__c = 100;
        invline1.OrderApi__Price_Override__c = true;
        invline1.OrderApi__Total__c = 100;
        insert invline1; 
        
        inv1.OrderApi__Status__c='Posted';
        update inv1;

        Test.startTest();
        
        Fon_SalesorderPaymentBatch batchable = new Fon_SalesorderPaymentBatch(msId);
        DataBase.executeBatch(batchable,1);

        System.AssertEquals(database.countquery('SELECT COUNT() FROM OrderApi__Sales_Order__c '),1);
        Test.stopTest();
        
    } 
    static testMethod void executeBatchMethod5(){
        
        OrderApi__Business_Group__c bg = (OrderApi__Business_Group__c)Fon_TestDataFactory.createSObject('OrderApi__Business_Group__c', false); 
        insert bg;
        
        Account acct = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert acct;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        insert con;
        
        Set<Id> msId = new Set<Id>();
        
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
        ms.Fon_AAFP_Subscription_Plan_Picklist__c='Auto Full Pay';
    insert ms;
        msId.add(ms.Id);
        
        
        
        OrderApi__Subscription_Plan__c subPlan = (OrderApi__Subscription_Plan__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription_Plan__c', false); 
        subPlan.OrderApi__Type__c = 'Termed';
        subPlan.OrderApi__Initial_Term_Months__c = 12;
        subPlan.OrderApi__Renewal_Term_Months__c = 12;
        subPlan.OrderApi__Bill_Cycle__c = 'AUTO';
        subPlan.OrderApi__Auto_Renew_Option__c = 'Enabled';
        subPlan.OrderApi__Is_Active__c = true;
        subPlan.OrderApi__Enable_Schedule__c = true;
        subPlan.OrderApi__Schedule_Frequency__c = 'Annually';
        insert subPlan;
        
        OrderApi__Item_Class__c itmClass = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClass.OrderApi__Is_Subscription__c = true;
        itmClass.OrderApi__Is_Active__c = true;
        itmClass.Fon_Is_Main_Membership__c=true;
        insert itmClass;
        
        OrderApi__Item__c[] items = new List<OrderApi__Item__c>();
        
        OrderApi__Item__c itm = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm.OrderApi__Is_Subscription__c = true;
        itm.OrderApi__Item_Class__c = itmClass.Id;
        itm.OrderApi__Is_Active__c = false;
        itm.OrderApi__Price__c = 100;
        itm.Is_Foundation_Donation__c = true;
        items.add(itm); 
        
        OrderApi__Item__c itm1 = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        itm1.OrderApi__Is_Subscription__c = true;
        itm1.OrderApi__Item_Class__c = itmClass.Id;
        itm1.OrderApi__Is_Active__c = false;
        itm1.OrderApi__Price__c = 100;
        items.add(itm1); 
        
        insert items;
        
        
        OrderApi__Payment_Method__c pm = (OrderApi__Payment_Method__c)Fon_TestDataFactory.createSObject('OrderApi__Payment_Method__c', false);
        pm.OrderApi__Contact__c= con.Id;
        insert pm;
        
        OrderApi__Sales_Order__c so = (OrderApi__Sales_Order__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order__c', false);
        so.OrderApi__Account__c = acct.id;
        so.OrderApi__Contact__c = con.id;
        so.OrderApi__Entity__c = 'Account';
        so.Fon_isPaymentProcess__c = true;
        so.Fon_is_Dues_Paid_by_Chapter_Residency__c= false;
        so.OrderApi__Payment_Method__c = pm.Id;
        so.Fon_Salesorder_Type__c='Dues';
        so.Fon_Membership_Staging__c=ms.Id;
       
        insert so;
        
        OrderApi__Sales_Order_Line__c sol = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false);
        sol.OrderApi__Sales_Order__c = so.id;
        sol.OrderApi__Account__c = acct.id;
        sol.OrderApi__Contact__c = con.id;
        sol.OrderApi__Item__c = itm.id;
        sol.OrderApi__Is_Subscription__c = true;
        sol.OrderApi__Subscription_Plan__c = subPlan.id;
        sol.OrderApi__Quantity__c = 1;
        sol.OrderApi__Sale_Price__c = 100;
        sol.OrderApi__Total__c =100;
        sol.OrderApi__Price_Override__c = true;
        insert sol;
        
        so.OrderApi__Status__c = 'Closed';
        update so;
        
        OrderApi__Credit_Memo__c cm = (OrderApi__Credit_Memo__c)Fon_TestDataFactory.createSObject('OrderApi__Credit_Memo__c', false); 
        cm.OrderApi__Contact__c = con.id;
        cm.OrderApi__Amount__c  = 150;
        cm.Fon_Suggested_Usage__c = 'Memberships';
        cm.Fon_Required__c = true;
        insert cm;
        
        
        OrderApi__Credit_Memo_Line__c cmLine =(OrderApi__Credit_Memo_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Credit_Memo_Line__c', false); 
        cmLine.OrderApi__Amount__c=50;
        cmLine.OrderApi__Credit_Memo__c=cm.Id;
        insert cmLine;
        
        cm.OrderApi__Status__c='Posted';
        
        OrderApi__Invoice__c inv1 = (OrderApi__Invoice__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice__c', false);
        inv1.OrderApi__Invoice_Date__c=System.today();
        inv1.OrderApi__Contact__c=con.id;
        inv1.OrderApi__Sales_Order__c=so.id;
        inv1.OrderApi__Entity__c = 'Account';
        inv1.OrderApi__Business_Group__c=bg.Id;
        inv1.OrderApi__Account__c= acct.id;
        insert inv1;
        
        
        OrderApi__Invoice_Line__c invline1 = (OrderApi__Invoice_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice_Line__c', false);
        invline1.OrderApi__Invoice__c=inv1.Id;
        invline1.OrderApi__Item__c=itm.Id;
        invline1.OrderApi__Quantity__c = 1;
        invline1.OrderApi__Sale_Price__c = 100;
        invline1.OrderApi__Balance_Due__c = 100;
        invline1.OrderApi__Price_Override__c = true;
        invline1.OrderApi__Total__c = 100;
        insert invline1; 
        
        inv1.OrderApi__Status__c='Posted';
        update inv1;

        Test.startTest();
        
        Fon_SalesorderPaymentBatch batchable = new Fon_SalesorderPaymentBatch(msId);
        DataBase.executeBatch(batchable,1);

        System.AssertEquals(database.countquery('SELECT COUNT() FROM OrderApi__Sales_Order__c '),1);
        Test.stopTest();
        
    } 
     static testMethod void executeBatchMethod6(){
        
        OrderApi__Business_Group__c bg = (OrderApi__Business_Group__c)Fon_TestDataFactory.createSObject('OrderApi__Business_Group__c', false); 
        insert bg;
        
        Account acct = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert acct;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        insert con;
        
        Set<Id> msId = new Set<Id>();
        
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
        ms.Fon_AAFP_Subscription_Plan_Picklist__c='Auto Full Pay';
    insert ms;
        msId.add(ms.Id);
        
        
        
        OrderApi__Subscription_Plan__c subPlan = (OrderApi__Subscription_Plan__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription_Plan__c', false); 
        subPlan.OrderApi__Type__c = 'Termed';
        subPlan.OrderApi__Initial_Term_Months__c = 12;
        subPlan.OrderApi__Renewal_Term_Months__c = 12;
        subPlan.OrderApi__Bill_Cycle__c = 'AUTO';
        subPlan.OrderApi__Auto_Renew_Option__c = 'Enabled';
        subPlan.OrderApi__Is_Active__c = true;
        subPlan.OrderApi__Enable_Schedule__c = true;
        subPlan.OrderApi__Schedule_Frequency__c = 'Annually';
        insert subPlan;
        
        OrderApi__Item_Class__c itmClass = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClass.OrderApi__Is_Subscription__c = true;
        itmClass.OrderApi__Is_Active__c = true;
        itmClass.Fon_Is_Main_Membership__c=true;
        insert itmClass;
        
        OrderApi__Item__c[] items = new List<OrderApi__Item__c>();
        
        OrderApi__Item__c itm = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm.OrderApi__Is_Subscription__c = true;
        itm.OrderApi__Item_Class__c = itmClass.Id;
        itm.OrderApi__Is_Active__c = false;
        itm.OrderApi__Price__c = 100;
        itm.Is_Foundation_Donation__c = true;
        items.add(itm); 
        
        OrderApi__Item__c itm1 = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        itm1.OrderApi__Is_Subscription__c = true;
        itm1.OrderApi__Item_Class__c = itmClass.Id;
        itm1.OrderApi__Is_Active__c = false;
        itm1.OrderApi__Price__c = 100;
        items.add(itm1); 
        
        insert items;
        
        
        OrderApi__Payment_Method__c pm = (OrderApi__Payment_Method__c)Fon_TestDataFactory.createSObject('OrderApi__Payment_Method__c', false);
        pm.OrderApi__Contact__c= con.Id;
        insert pm;
        
        OrderApi__Sales_Order__c so = (OrderApi__Sales_Order__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order__c', false);
        so.OrderApi__Account__c = acct.id;
        so.OrderApi__Contact__c = con.id;
        so.OrderApi__Entity__c = 'Account';
        so.Fon_isPaymentProcess__c = true;
        so.Fon_is_Dues_Paid_by_Chapter_Residency__c= false;
        so.OrderApi__Payment_Method__c = pm.Id;
        so.Fon_Salesorder_Type__c='Dues';
        so.Fon_Membership_Staging__c=ms.Id;
        
        insert so;
        
        OrderApi__Sales_Order_Line__c sol = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false);
        sol.OrderApi__Sales_Order__c = so.id;
        sol.OrderApi__Account__c = acct.id;
        sol.OrderApi__Contact__c = con.id;
        sol.OrderApi__Item__c = itm.id;
        sol.OrderApi__Is_Subscription__c = true;
        sol.OrderApi__Subscription_Plan__c = subPlan.id;
        sol.OrderApi__Quantity__c = 1;
        sol.OrderApi__Sale_Price__c = 100;
        sol.OrderApi__Total__c =100;
        sol.OrderApi__Price_Override__c = true;
        insert sol;
        
        so.OrderApi__Status__c = 'Closed';
        update so;
        
        OrderApi__Credit_Memo__c cm = (OrderApi__Credit_Memo__c)Fon_TestDataFactory.createSObject('OrderApi__Credit_Memo__c', false); 
        cm.OrderApi__Contact__c = con.id;
        cm.OrderApi__Amount__c  = 100;
        cm.Fon_Suggested_Usage__c = 'Memberships';
        cm.Fon_Required__c = true;
        insert cm;
        
        
        OrderApi__Credit_Memo_Line__c cmLine =(OrderApi__Credit_Memo_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Credit_Memo_Line__c', false); 
        cmLine.OrderApi__Amount__c=50;
        cmLine.OrderApi__Credit_Memo__c=cm.Id;
        insert cmLine;
        
        cm.OrderApi__Status__c='Posted';
        
        OrderApi__Invoice__c inv1 = (OrderApi__Invoice__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice__c', false);
        inv1.OrderApi__Invoice_Date__c=System.today();
        inv1.OrderApi__Contact__c=con.id;
        inv1.OrderApi__Sales_Order__c=so.id;
        inv1.OrderApi__Entity__c = 'Account';
        inv1.OrderApi__Business_Group__c=bg.Id;
        inv1.OrderApi__Account__c= acct.id;
        insert inv1;
        
        
        OrderApi__Invoice_Line__c invline1 = (OrderApi__Invoice_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice_Line__c', false);
        invline1.OrderApi__Invoice__c=inv1.Id;
        invline1.OrderApi__Item__c=itm.Id;
        invline1.OrderApi__Quantity__c = 1;
        invline1.OrderApi__Sale_Price__c = 100;
        invline1.OrderApi__Balance_Due__c = 100;
        invline1.OrderApi__Price_Override__c = true;
        invline1.OrderApi__Total__c = 100;
        insert invline1; 
        
        inv1.OrderApi__Status__c='Posted';
        update inv1;
         
    
        Test.startTest();
        
        Fon_SalesorderPaymentBatch batchable = new Fon_SalesorderPaymentBatch(msId);
        DataBase.executeBatch(batchable,1);
        

        System.AssertEquals(database.countquery('SELECT COUNT() FROM OrderApi__Sales_Order__c '),1);
        Test.stopTest();
        
    } 
    static testMethod void executeBatchMethod7(){
        
        OrderApi__Business_Group__c bg = (OrderApi__Business_Group__c)Fon_TestDataFactory.createSObject('OrderApi__Business_Group__c', false); 
        insert bg;
        
        Account acct = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert acct;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        insert con;
        
        Set<Id> msId = new Set<Id>();
        
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
        ms.Fon_AAFP_Subscription_Plan_Picklist__c='Installment';
        insert ms;
        
        msId.add(ms.Id);
        
        
        
        OrderApi__Subscription_Plan__c subPlan = (OrderApi__Subscription_Plan__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription_Plan__c', false); 
        subPlan.OrderApi__Type__c = 'Termed';
        subPlan.OrderApi__Initial_Term_Months__c = 12;
        subPlan.OrderApi__Renewal_Term_Months__c = 12;
        subPlan.OrderApi__Bill_Cycle__c = 'AUTO';
        subPlan.OrderApi__Auto_Renew_Option__c = 'Enabled';
        subPlan.OrderApi__Is_Active__c = true;
        subPlan.OrderApi__Enable_Schedule__c = true;
        subPlan.OrderApi__Schedule_Frequency__c = 'Annually';
        insert subPlan;
        
        OrderApi__Item_Class__c itmClass = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClass.OrderApi__Is_Subscription__c = true;
        itmClass.OrderApi__Is_Active__c = true;
        itmClass.Fon_Is_Main_Membership__c=true;
        insert itmClass;
        
        OrderApi__Item__c[] items = new List<OrderApi__Item__c>();
        
        OrderApi__Item__c itm = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm.OrderApi__Is_Subscription__c = true;
        itm.OrderApi__Item_Class__c = itmClass.Id;
        itm.OrderApi__Is_Active__c = false;
        itm.OrderApi__Price__c = 100;
        itm.Is_Foundation_Donation__c = true;
        items.add(itm); 
        
        OrderApi__Item__c itm1 = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        itm1.OrderApi__Is_Subscription__c = true;
        itm1.OrderApi__Item_Class__c = itmClass.Id;
        itm1.OrderApi__Is_Active__c = false;
        itm1.OrderApi__Price__c = 100;
        items.add(itm1); 
        
        insert items;
        
        
        OrderApi__Payment_Method__c pm = (OrderApi__Payment_Method__c)Fon_TestDataFactory.createSObject('OrderApi__Payment_Method__c', false);
        pm.OrderApi__Contact__c= con.Id;
        insert pm;
        
        OrderApi__Sales_Order__c so = (OrderApi__Sales_Order__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order__c', false);
        so.OrderApi__Account__c = acct.id;
        so.OrderApi__Contact__c = con.id;
        so.OrderApi__Entity__c = 'Account';
        so.Fon_isPaymentProcess__c = true;
        so.Fon_is_Dues_Paid_by_Chapter_Residency__c= false;
        so.OrderApi__Payment_Method__c = pm.Id;
        so.Fon_Salesorder_Type__c='Donation';
        so.Fon_Membership_Staging__c=ms.Id;
       
        insert so;
        
        OrderApi__Sales_Order_Line__c sol = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false);
        sol.OrderApi__Sales_Order__c = so.id;
        sol.OrderApi__Account__c = acct.id;
        sol.OrderApi__Contact__c = con.id;
        sol.OrderApi__Item__c = itm.id;
        sol.OrderApi__Is_Subscription__c = true;
        sol.OrderApi__Subscription_Plan__c = subPlan.id;
        sol.OrderApi__Quantity__c = 1;
        sol.OrderApi__Activation_Date__c=system.today();
        sol.OrderApi__End_Date__c=system.today()+365;
        sol.OrderApi__Sale_Price__c = 100;
        sol.OrderApi__Total__c =100;
        sol.OrderApi__Price_Override__c = true;
        insert sol;
        
        so.OrderApi__Status__c = 'Closed';
        update so;
        
        OrderApi__Credit_Memo__c cm = (OrderApi__Credit_Memo__c)Fon_TestDataFactory.createSObject('OrderApi__Credit_Memo__c', false); 
        cm.OrderApi__Contact__c = con.id;
        cm.OrderApi__Amount__c  = 100;
        cm.Fon_Suggested_Usage__c = 'Memberships';
        cm.Fon_Required__c = true;
        insert cm;
        
        
        OrderApi__Credit_Memo_Line__c cmLine =(OrderApi__Credit_Memo_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Credit_Memo_Line__c', false); 
        cmLine.OrderApi__Amount__c=50;
        cmLine.OrderApi__Credit_Memo__c=cm.Id;
        insert cmLine;
        
        cm.OrderApi__Status__c='Posted';
        
        OrderApi__Invoice__c inv1 = (OrderApi__Invoice__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice__c', false);
        inv1.OrderApi__Invoice_Date__c=System.today();
        inv1.OrderApi__Contact__c=con.id;
        inv1.OrderApi__Sales_Order__c=so.id;
        inv1.OrderApi__Entity__c = 'Account';
        inv1.OrderApi__Business_Group__c=bg.Id;
        inv1.OrderApi__Account__c= acct.id;
        insert inv1;
        
        
        OrderApi__Invoice_Line__c invline1 = (OrderApi__Invoice_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice_Line__c', false);
        invline1.OrderApi__Invoice__c=inv1.Id;
        invline1.OrderApi__Item__c=itm.Id;
        invline1.OrderApi__Quantity__c = 1;
        invline1.OrderApi__Sale_Price__c = 100;
        invline1.OrderApi__Balance_Due__c = 100;
        invline1.OrderApi__Price_Override__c = true;
        invline1.OrderApi__Total__c = 100;
        insert invline1; 
        
        inv1.OrderApi__Status__c='Posted';
        update inv1;

        Test.startTest();
        Fon_SalesorderPaymentBatch.soAndInstallments(so.ID);
        Test.stopTest();
        
    } 
    
    static testMethod void executeBatchMethod_Installment(){
        
        OrderApi__Business_Group__c bg = (OrderApi__Business_Group__c)Fon_TestDataFactory.createSObject('OrderApi__Business_Group__c', false); 
        insert bg;
        
        Account acct = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert acct;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        insert con;
        
        Set<Id> msId = new Set<Id>();
        
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
        ms.Fon_AAFP_Subscription_Plan_Picklist__c='Installment';
        insert ms;
        
        msId.add(ms.Id);
        
        
        
        OrderApi__Subscription_Plan__c subPlan = (OrderApi__Subscription_Plan__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription_Plan__c', false); 
        subPlan.OrderApi__Type__c = 'Termed';
        subPlan.OrderApi__Initial_Term_Months__c = 12;
        subPlan.OrderApi__Renewal_Term_Months__c = 12;
        subPlan.OrderApi__Bill_Cycle__c = 'AUTO';
        subPlan.OrderApi__Auto_Renew_Option__c = 'Enabled';
        subPlan.OrderApi__Is_Active__c = true;
        subPlan.OrderApi__Enable_Schedule__c = true;
        subPlan.OrderApi__Schedule_Frequency__c = 'Annually';
        insert subPlan;
        
        OrderApi__Item_Class__c itmClass = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClass.OrderApi__Is_Subscription__c = true;
        itmClass.OrderApi__Is_Active__c = true;
        itmClass.Fon_Is_Main_Membership__c=true;
        insert itmClass;
        
        OrderApi__Item__c[] items = new List<OrderApi__Item__c>();
        
        OrderApi__Item__c itm = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm.OrderApi__Is_Subscription__c = true;
        itm.OrderApi__Item_Class__c = itmClass.Id;
        itm.OrderApi__Is_Active__c = false;
        itm.OrderApi__Price__c = 100;
        //itm.Is_Foundation_Donation__c = true;
        
        items.add(itm); 
        
        OrderApi__Item__c itm1 = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        itm1.OrderApi__Is_Subscription__c = true;
        itm1.OrderApi__Item_Class__c = itmClass.Id;
        itm1.OrderApi__Is_Active__c = false;
        itm1.OrderApi__Price__c = 100;
        items.add(itm1); 
        
        insert items;
        
        
        OrderApi__Payment_Method__c pm = (OrderApi__Payment_Method__c)Fon_TestDataFactory.createSObject('OrderApi__Payment_Method__c', false);
        pm.OrderApi__Contact__c= con.Id;
        insert pm;
        
        OrderApi__Sales_Order__c so = (OrderApi__Sales_Order__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order__c', false);
        so.OrderApi__Account__c = acct.id;
        so.OrderApi__Contact__c = con.id;
        so.OrderApi__Entity__c = 'Account';
        so.Fon_isPaymentProcess__c = true;
        so.Fon_is_Dues_Paid_by_Chapter_Residency__c= false;
        so.OrderApi__Payment_Method__c = pm.Id;
        so.Fon_Salesorder_Type__c='Dues';
        so.Fon_Membership_Staging__c=ms.Id;
        so.OrderApi__Posting_Entity__c='Invoice';
        so.OrderApi__Schedule_Type__c='Simple Invoice';
        insert so;
        
        OrderApi__Sales_Order_Line__c sol = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false);
        sol.OrderApi__Sales_Order__c = so.id;
        sol.OrderApi__Account__c = acct.id;
        sol.OrderApi__Contact__c = con.id;
        sol.OrderApi__Item__c = itm.id;
        sol.OrderApi__Is_Subscription__c = true;
        sol.OrderApi__Subscription_Plan__c = subPlan.id;
        sol.OrderApi__Quantity__c = 1;
        sol.OrderApi__Activation_Date__c=system.today();
        sol.OrderApi__End_Date__c=system.today()+365;
        sol.OrderApi__Sale_Price__c = 100;
        sol.OrderApi__Total__c =100;
        sol.OrderApi__Price_Override__c = true;
        insert sol;
        
        so.OrderApi__Status__c = 'Closed';
        update so;
        
        OrderApi__Credit_Memo__c cm = (OrderApi__Credit_Memo__c)Fon_TestDataFactory.createSObject('OrderApi__Credit_Memo__c', false); 
        cm.OrderApi__Contact__c = con.id;
        cm.OrderApi__Amount__c  = 100;
        cm.Fon_Suggested_Usage__c = 'Memberships';
        cm.Fon_Required__c = true;
        insert cm;
        
        
        OrderApi__Credit_Memo_Line__c cmLine =(OrderApi__Credit_Memo_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Credit_Memo_Line__c', false); 
        cmLine.OrderApi__Amount__c=50;
        cmLine.OrderApi__Credit_Memo__c=cm.Id;
        insert cmLine;
        
        cm.OrderApi__Status__c='Posted';
        
        OrderApi__Invoice__c inv1 = (OrderApi__Invoice__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice__c', false);
        inv1.OrderApi__Invoice_Date__c=System.today();
        inv1.OrderApi__Contact__c=con.id;
        inv1.OrderApi__Sales_Order__c=so.id;
        inv1.OrderApi__Entity__c = 'Account';
        inv1.OrderApi__Business_Group__c=bg.Id;
        inv1.OrderApi__Account__c= acct.id;
        insert inv1;
        
        
        OrderApi__Invoice_Line__c invline1 = (OrderApi__Invoice_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice_Line__c', false);
        invline1.OrderApi__Invoice__c=inv1.Id;
        invline1.OrderApi__Item__c=itm.Id;
        invline1.OrderApi__Quantity__c = 1;
        invline1.OrderApi__Sale_Price__c = 100;
        invline1.OrderApi__Balance_Due__c = 100;
        invline1.OrderApi__Price_Override__c = true;
        invline1.OrderApi__Total__c = 100;
        invline1.OrderApi__Sales_Order_Line__c = sol.Id;
        insert invline1; 
        
        inv1.OrderApi__Status__c='Posted';
        update inv1; 

        Test.startTest();
            //Fon_SalesorderPaymentBatch.soAndInstallments(so.ID);
            Fon_SalesorderPaymentBatch batchable = new Fon_SalesorderPaymentBatch(msId);
            DataBase.executeBatch(batchable,1);
        Test.stopTest();
        
    }
    
}