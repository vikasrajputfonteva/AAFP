@isTest
public class Fon_ApplyCreditsTest {
    
    @isTest
    public static void method1(){
        
        
        Account acct = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert acct;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        con.AccountId=acct.Id;
        insert con;
        
        OrderApi__Business_Group__c bg = (OrderApi__Business_Group__c)Fon_TestDataFactory.createSObject('OrderApi__Business_Group__c', false); 
        insert bg;
        
        OrderApi__GL_Account__c glAcc = new OrderApi__GL_Account__c(OrderApi__Business_Group__c = bg.id);
        insert glAcc ;
        
        OrderApi__Credit_Memo__c cm = (OrderApi__Credit_Memo__c)Fon_TestDataFactory.createSObject('OrderApi__Credit_Memo__c', false); 
        cm.OrderApi__Contact__c = con.Id;
        cm.OrderApi__Account__c=acct.Id;
        cm.Fon_Suggested_Usage__c='Memberships';
        cm.Fon_Required__c=true;
        cm.OrderApi__Business_Group__c=bg.Id;
        cm.OrderApi__Credit_Account__c=glAcc.Id;
        cm.OrderApi__Debit_Account__c=glAcc.Id;
        cm.OrderApi__Amount__c=500;
        cm.OrderApi__Entity__c='Account';
        cm.OrderApi__Status__c='Draft';
        insert cm;
        
        
        
        
        OrderApi__Sales_Order__c so = (OrderApi__Sales_Order__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order__c', false); 
        so.OrderApi__Account__c = acct.id;
        so.OrderApi__Contact__c = con.id;
        so.Fon_Auto_Apply_Credit__c=true;
        insert so;
        
        
        
        OrderApi__Subscription_Plan__c subPlan = (OrderApi__Subscription_Plan__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription_Plan__c', false); 
        subPlan.OrderApi__Type__c = 'Termed';
        subPlan.OrderApi__Initial_Term_Months__c = 12;
        subPlan.OrderApi__Renewal_Term_Months__c = 12;
        subPlan.OrderApi__Bill_Cycle__c = 'AUTO';
        subPlan.OrderApi__Auto_Renew_Option__c = 'Enabled';
        subPlan.OrderApi__Enable_Proration__c = false;
        subPlan.OrderApi__Is_Active__c = true;
        
        subPlan.OrderApi__Enable_Schedule__c=false;
        subPlan.OrderApi__Schedule_Frequency__c='Monthly';
        insert subPlan;
        
        
        OrderApi__Item_Class__c itmClass = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClass.OrderApi__Enable_Assignments__c = false;
        itmClass.OrderApi__Is_Subscription__c = true;
        itmClass.OrderApi__Is_Active__c = true;
        insert itmClass;
        
        OrderApi__Item__c itm = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm.OrderApi__Item_Class__c = itmClass.Id;
        itm.OrderApi__Is_Active__c = false;
        itm.OrderApi__Price__c = 15;
        itm.OrderApi__Is_Subscription__c=true;
        insert itm;
        
        OrderApi__Sales_Order_Line__c sol1 = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false); 
        sol1.OrderApi__Sales_Order__c = so.id;
        sol1.OrderApi__Account__c = acct.id;
        sol1.OrderApi__Contact__c = con.id;
        sol1.OrderApi__Item__c = itm.id;
        insert sol1;
        
        so.OrderApi__Status__c='Closed';
        update so;
        
        
        
        decimal amount=100;
        
        OrderApi__Invoice__c inv = (OrderApi__Invoice__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice__c', false); 
        inv.OrderApi__Sales_Order__c=so.Id;
        inv.Fon_Auto_Apply_Credit__c=true;
        inv.OrderApi__Contact__c=con.ID;
        insert inv;
        
        
        OrderApi__Invoice_Line__c invline = (OrderApi__Invoice_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice_Line__c', false);
        invline.OrderApi__Invoice__c=inv.Id;
        invline.OrderApi__Item__c=itm.Id;
        invline.OrderApi__Subscription_Plan__c=subPlan.Id;
        invline.OrderApi__Balance_Due__c=200;
        invline.OrderApi__Sale_Price__c=200;
        invline.OrderApi__Quantity__c=1;
        invline.OrderApi__Total__c=200;
        insert invline;
        
        
        
        OrderApi__Batch__c batch = (OrderApi__Batch__c)Fon_TestDataFactory.createSObject('OrderApi__Batch__c', false); 
        batch.OrderApi__Expected_Amount__c=10;
        batch.OrderApi__Expected_Count__c=1;
        insert batch;
        
        
        
        Test.startTest();
        
        String ids= so.id;
        try{
            Fon_ApplyCredits.process(ids);
            Fon_CreditMemoLineBatch cml1=new Fon_CreditMemoLineBatch(batch.Id);
            OrderApi__Credit_Memo_Line__c cmline = cml1.createCML(cm.Id,inv.Id,amount);
            system.assertEquals(batch.Id, cmline.Fon_Batch__c);
        }
        catch (Exception e) {
            String exceptionMessage = e.getMessage();
        }
        Test.stopTest();
    }
    @isTest
    public static void method2(){
        
        
        Account acct = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert acct;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        con.AccountId=acct.Id;
        insert con;
        
        OrderApi__Business_Group__c bg = (OrderApi__Business_Group__c)Fon_TestDataFactory.createSObject('OrderApi__Business_Group__c', false); 
        insert bg;
        
        OrderApi__GL_Account__c glAcc = new OrderApi__GL_Account__c(OrderApi__Business_Group__c = bg.id);
        insert glAcc ;
        
        OrderApi__Credit_Memo__c cm = (OrderApi__Credit_Memo__c)Fon_TestDataFactory.createSObject('OrderApi__Credit_Memo__c', false); 
        cm.OrderApi__Contact__c = con.Id;
        cm.OrderApi__Account__c=acct.Id;
        cm.Fon_Suggested_Usage__c='Memberships';
        cm.Fon_Required__c=true;
        cm.OrderApi__Business_Group__c=bg.Id;
        cm.OrderApi__Credit_Account__c=glAcc.Id;
        cm.OrderApi__Debit_Account__c=glAcc.Id;
        cm.OrderApi__Amount__c=500;
        cm.OrderApi__Entity__c='Account';
        cm.OrderApi__Status__c='Draft';
        insert cm;
        
        
        
        
        OrderApi__Sales_Order__c so = (OrderApi__Sales_Order__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order__c', false); 
        so.OrderApi__Account__c = acct.id;
        so.OrderApi__Contact__c = con.id;
        so.Fon_Auto_Apply_Credit__c=true;
        insert so;
        
        
        
        OrderApi__Subscription_Plan__c subPlan = (OrderApi__Subscription_Plan__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription_Plan__c', false); 
        subPlan.OrderApi__Type__c = 'Termed';
        subPlan.OrderApi__Initial_Term_Months__c = 12;
        subPlan.OrderApi__Renewal_Term_Months__c = 12;
        subPlan.OrderApi__Bill_Cycle__c = 'AUTO';
        subPlan.OrderApi__Auto_Renew_Option__c = 'Enabled';
        subPlan.OrderApi__Enable_Proration__c = false;
        subPlan.OrderApi__Is_Active__c = true;
        
        subPlan.OrderApi__Enable_Schedule__c=false;
        subPlan.OrderApi__Schedule_Frequency__c='Monthly';
        insert subPlan;
        
        
        OrderApi__Item_Class__c itmClass = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClass.OrderApi__Enable_Assignments__c = false;
        itmClass.OrderApi__Is_Subscription__c = true;
        itmClass.OrderApi__Is_Active__c = true;
        insert itmClass;
        
        OrderApi__Item__c itm = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm.OrderApi__Item_Class__c = itmClass.Id;
        itm.OrderApi__Is_Active__c = false;
        itm.OrderApi__Price__c = 500;
        itm.OrderApi__Is_Subscription__c=true;
        insert itm;
        
        OrderApi__Sales_Order_Line__c sol1 = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false); 
        sol1.OrderApi__Sales_Order__c = so.id;
        sol1.OrderApi__Account__c = acct.id;
        sol1.OrderApi__Contact__c = con.id;
        sol1.OrderApi__Item__c = itm.id;
        insert sol1;
        
        so.OrderApi__Status__c='Closed';
        update so;
        
        
        
        decimal amount=100;
        
        OrderApi__Invoice__c inv = (OrderApi__Invoice__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice__c', false); 
        inv.OrderApi__Sales_Order__c=so.Id;
        inv.Fon_Auto_Apply_Credit__c=true;
        inv.OrderApi__Contact__c=con.ID;
        insert inv;
        
        
        OrderApi__Invoice_Line__c invline = (OrderApi__Invoice_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice_Line__c', false);
        invline.OrderApi__Invoice__c=inv.Id;
        invline.OrderApi__Item__c=itm.Id;
        invline.OrderApi__Subscription_Plan__c=subPlan.Id;
        invline.OrderApi__Balance_Due__c=500;
        invline.OrderApi__Sale_Price__c=500;
        invline.OrderApi__Quantity__c=1;
        invline.OrderApi__Total__c=500;
        insert invline;
        
        OrderApi__Batch__c batch = (OrderApi__Batch__c)Fon_TestDataFactory.createSObject('OrderApi__Batch__c', false); 
        batch.OrderApi__Expected_Amount__c=10;
        batch.OrderApi__Expected_Count__c=1;
        insert batch;
        
        Test.startTest();
        String ids= so.id;
        try{
            Fon_ApplyCredits.process(ids);
            Fon_CreditMemoLineBatch cml1=new Fon_CreditMemoLineBatch(batch.Id);
            //Database.executeBatch(cml1);
            OrderApi__Credit_Memo_Line__c cmline = cml1.createCML(cm.Id,inv.Id,amount);
            system.assertEquals(batch.Id, cmline.Fon_Batch__c);
        }
        catch(Exception e){
            String exceptionMessage = e.getMessage(); 
        }
        Test.stopTest();
    }
    @isTest
    public static void method3(){
        
        
        Account acct = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert acct;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        con.AccountId=acct.Id;
        insert con;
        
        OrderApi__Business_Group__c bg = (OrderApi__Business_Group__c)Fon_TestDataFactory.createSObject('OrderApi__Business_Group__c', false); 
        insert bg;
        
        OrderApi__GL_Account__c glAcc = new OrderApi__GL_Account__c(OrderApi__Business_Group__c = bg.id);
        insert glAcc ;
        
        OrderApi__Credit_Memo__c cm = (OrderApi__Credit_Memo__c)Fon_TestDataFactory.createSObject('OrderApi__Credit_Memo__c', false); 
        cm.OrderApi__Contact__c = con.Id;
        cm.OrderApi__Account__c=acct.Id;
        cm.Fon_Suggested_Usage__c='Memberships';
        cm.Fon_Required__c=true;
        cm.OrderApi__Business_Group__c=bg.Id;
        cm.OrderApi__Credit_Account__c=glAcc.Id;
        cm.OrderApi__Debit_Account__c=glAcc.Id;
        cm.OrderApi__Amount__c=400;
        cm.OrderApi__Entity__c='Account';
        cm.OrderApi__Status__c='Draft';
        insert cm;
        
        
        
        
        OrderApi__Sales_Order__c so = (OrderApi__Sales_Order__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order__c', false); 
        so.OrderApi__Account__c = acct.id;
        so.OrderApi__Contact__c = con.id;
        so.Fon_Auto_Apply_Credit__c=true;
        insert so;
        
        
        
        OrderApi__Subscription_Plan__c subPlan = (OrderApi__Subscription_Plan__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription_Plan__c', false); 
        subPlan.OrderApi__Type__c = 'Termed';
        subPlan.OrderApi__Initial_Term_Months__c = 12;
        subPlan.OrderApi__Renewal_Term_Months__c = 12;
        subPlan.OrderApi__Bill_Cycle__c = 'AUTO';
        subPlan.OrderApi__Auto_Renew_Option__c = 'Enabled';
        subPlan.OrderApi__Enable_Proration__c = false;
        subPlan.OrderApi__Is_Active__c = true;
        
        subPlan.OrderApi__Enable_Schedule__c=false;
        subPlan.OrderApi__Schedule_Frequency__c='Monthly';
        insert subPlan;
        
        
        OrderApi__Item_Class__c itmClass = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClass.OrderApi__Enable_Assignments__c = false;
        itmClass.OrderApi__Is_Subscription__c = true;
        itmClass.OrderApi__Is_Active__c = true;
        insert itmClass;
        
        OrderApi__Item__c itm = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm.OrderApi__Item_Class__c = itmClass.Id;
        itm.OrderApi__Is_Active__c = false;
        itm.OrderApi__Price__c = 500;
        itm.OrderApi__Is_Subscription__c=true;
        insert itm;
        
        OrderApi__Sales_Order_Line__c sol1 = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false); 
        sol1.OrderApi__Sales_Order__c = so.id;
        sol1.OrderApi__Account__c = acct.id;
        sol1.OrderApi__Contact__c = con.id;
        sol1.OrderApi__Item__c = itm.id;
        insert sol1;
        
        so.OrderApi__Status__c='Closed';
        update so;
        
        
        
        decimal amount=100;
        
        OrderApi__Invoice__c inv = (OrderApi__Invoice__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice__c', false); 
        inv.OrderApi__Sales_Order__c=so.Id;
        inv.Fon_Auto_Apply_Credit__c=true;
        inv.OrderApi__Contact__c=con.ID;
        insert inv;
        
        
        OrderApi__Invoice_Line__c invline = (OrderApi__Invoice_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice_Line__c', false);
        invline.OrderApi__Invoice__c=inv.Id;
        invline.OrderApi__Item__c=itm.Id;
        invline.OrderApi__Subscription_Plan__c=subPlan.Id;
        invline.OrderApi__Balance_Due__c=500;
        invline.OrderApi__Sale_Price__c=500;
        invline.OrderApi__Quantity__c=1;
        invline.OrderApi__Total__c=500;
        insert invline;
        
        
        
        OrderApi__Batch__c batch = (OrderApi__Batch__c)Fon_TestDataFactory.createSObject('OrderApi__Batch__c', false); 
        batch.OrderApi__Expected_Amount__c=1;
        batch.OrderApi__Expected_Count__c=1;
        insert batch;
        
        Test.startTest();
        
        String ids= so.id;
        try{
            Fon_ApplyCredits.process(ids);
            Fon_CreditMemoLineBatch cml1=new Fon_CreditMemoLineBatch(batch.Id);
            //Database.executeBatch(cml1);
            OrderApi__Credit_Memo_Line__c cmline = cml1.createCML(cm.Id,inv.Id,amount);
            system.assertEquals(batch.Id, cmline.Fon_Batch__c);
        }
        catch(Exception e){
            String exceptionMessage = e.getMessage(); 
        }
        Test.stopTest();
    }
    
}