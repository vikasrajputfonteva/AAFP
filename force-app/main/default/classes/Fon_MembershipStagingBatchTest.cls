@isTest
public class Fon_MembershipStagingBatchTest {
    
    
    @isTest
    public static void method_AutoFullPay_Donation(){
        set<Id> memberStageIdSet=new set<Id>();
        
        Account acct = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert acct;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        insert con;
        
        OrderApi__Payment_Method__c payment = (OrderApi__Payment_Method__c)Fon_TestDataFactory.createSObject('OrderApi__Payment_Method__c', false); 
        insert payment;
        
        OrderApi__Item_Class__c itmClassMain = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClassMain.OrderApi__Is_Active__c = true;
        itmClassMain.Fon_Is_Main_Membership__c = true;
        insert itmClassMain;
        
        
        
        OrderApi__Item__c ActiveMembershipItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        ActiveMembershipItem.Name='2019 National Resident ';
        ActiveMembershipItem.OrderApi__Item_Class__c=itmClassMain.Id;
        ActiveMembershipItem.OrderApi__Is_Subscription__c=true;
        ActiveMembershipItem.OrderApi__Price__c=500;
        ActiveMembershipItem.OrderApi__Is_Active__c=true;
        insert ActiveMembershipItem;
        
        OrderApi__Item_Class__c itmClassMain1 = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false);
        itmClassMain1.OrderApi__Is_Active__c = true;
        itmClassMain1.Fon_Is_State_Membership__c = true;
        insert itmClassMain1;
        
        OrderApi__Item__c StateMembershipItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        StateMembershipItem.Name='2019 National Resident Virginia';
        StateMembershipItem.OrderApi__Item_Class__c=itmClassMain1.Id;
        StateMembershipItem.OrderApi__Is_Subscription__c=true;
        StateMembershipItem.OrderApi__Price__c=500;
        StateMembershipItem.OrderApi__Is_Active__c=true;
        insert StateMembershipItem;
        
        OrderApi__Item_Class__c itmClassMain2 = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false);
        itmClassMain2.OrderApi__Is_Active__c = true;
        itmClassMain2.Fon_Is_Local_Membership__c = true;
        insert itmClassMain2;
        
        OrderApi__Item__c LocalMembershipItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        LocalMembershipItem.Name='2019 National Resident Virginia VA Northern Virginia';
        LocalMembershipItem.OrderApi__Item_Class__c=itmClassMain2.Id;
        LocalMembershipItem.OrderApi__Is_Subscription__c=true;
        LocalMembershipItem.OrderApi__Price__c=500;
        LocalMembershipItem.OrderApi__Is_Active__c=true;
        insert LocalMembershipItem;
        
        
        OrderApi__Item_Class__c itmClassMain3 = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false);
        itmClassMain3.OrderApi__Is_Active__c = true;
        insert itmClassMain3;
        
        OrderApi__Item__c pacItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        pacItem.Name='2019 National Resident Virginia VA Northern Virginia';
        pacItem.OrderApi__Item_Class__c=itmClassMain3.Id;
        pacItem.OrderApi__Price__c=500;
        pacItem.OrderApi__Is_Active__c=true;
        pacItem.Fon_Is_PAC_Item__c=true;
        insert pacItem;
        
        OrderApi__Item__c foundationItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        foundationItem.Name='2019 National Resident Virginia VA Northern Virginia';
        foundationItem.OrderApi__Item_Class__c=itmClassMain3.Id;
        foundationItem.OrderApi__Price__c=500;
        foundationItem.OrderApi__Is_Active__c=true;
        foundationItem.Is_Foundation_Donation__c=true;
        insert foundationItem;
        
        Fon_Membership_Staging__c ms = (Fon_Membership_Staging__c)Fon_TestDataFactory.createSObject('Fon_Membership_Staging__c', false);
        ms.Fon_Contact__c=con.Id;
        ms.Fon_Staging_Status__c='Approved';
        ms.Fon_Membership_Type__c='Resident';
        ms.Fon_Membership_State__c = 'Virginia';
        ms.Fon_Membership_Local__c= 'VA Northern Virginia';
        ms.Fon_Residency_Program_Graduation_Date__c=system.today();
        ms.Fon_Dues_Paid_by_Residency_Program__c=false;
        ms.Fon_Payment_Method_Id__c=payment.Id;
        ms.Fon_Foundation_Contribution_Information__c=50;
        ms.Fon_PAC_Contribution_Information__c=60;
        ms.Fon_AAFP_Subscription_Plan_Picklist__c = 'Auto Full Pay';
        insert ms;
        
        
        memberStageIdSet.add(ms.Id);
        list<Fon_Membership_Staging__c> lstmem=new list<Fon_Membership_Staging__c>();
        lstmem.add(ms);
        Test.startTest();
        Fon_MembershipStagingBatch batch=new Fon_MembershipStagingBatch(memberStageIdSet);
        //Fon_MembershipStagingBatch batchable=new Fon_MembershipStagingBatch();
        
        Database.executeBatch(batch,1);
        // Fon_MembershipStagingTriggerHandler memstag=new Fon_MembershipStagingTriggerHandler();
        // List<OrderApi__Sales_Order__c> lstSalesOrder=memstag.initializeMembershipStage(lstmem);
        // system.assert(lstSalesOrder.size()>0);
        
        Test.stopTest();
        
        system.assertEquals(2, [Select Id From OrderApi__Sales_Order__c Where Fon_Membership_Staging__c!=NULL].size(), 'Wrong No of SO got created');
        system.assertEquals(2, [Select Id From OrderApi__Sales_Order__c Where Fon_Membership_Staging__c!=NULL AND OrderApi__Posting_Entity__c='Receipt'].size(), 'Wrong No of SO got created');
        system.assertEquals(1, [Select Id From OrderApi__Sales_Order__c Where Fon_Membership_Staging__c!=NULL AND Fon_Salesorder_Type__c='Donation'].size(), 'DOnation SO is missing');
    }
    
    @isTest
    public static void method_AutoFullPay_NODonation(){
        set<Id> memberStageIdSet=new set<Id>();
        
        Account acct = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert acct;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        insert con;
        
        OrderApi__Payment_Method__c payment = (OrderApi__Payment_Method__c)Fon_TestDataFactory.createSObject('OrderApi__Payment_Method__c', false); 
        insert payment;
        
        OrderApi__Item_Class__c itmClassMain = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClassMain.OrderApi__Is_Active__c = true;
        itmClassMain.Fon_Is_Main_Membership__c = true;
        insert itmClassMain;
        
        
        
        OrderApi__Item__c ActiveMembershipItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        ActiveMembershipItem.Name='2019 National Resident ';
        ActiveMembershipItem.OrderApi__Item_Class__c=itmClassMain.Id;
        ActiveMembershipItem.OrderApi__Is_Subscription__c=true;
        ActiveMembershipItem.OrderApi__Price__c=500;
        ActiveMembershipItem.OrderApi__Is_Active__c=true;
        insert ActiveMembershipItem;
        
        OrderApi__Item_Class__c itmClassMain1 = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false);
        itmClassMain1.OrderApi__Is_Active__c = true;
        itmClassMain1.Fon_Is_State_Membership__c = true;
        insert itmClassMain1;
        
        OrderApi__Item__c StateMembershipItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        StateMembershipItem.Name='2019 National Resident Virginia';
        StateMembershipItem.OrderApi__Item_Class__c=itmClassMain1.Id;
        StateMembershipItem.OrderApi__Is_Subscription__c=true;
        StateMembershipItem.OrderApi__Price__c=500;
        StateMembershipItem.OrderApi__Is_Active__c=true;
        insert StateMembershipItem;
        
        OrderApi__Item_Class__c itmClassMain2 = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false);
        itmClassMain2.OrderApi__Is_Active__c = true;
        itmClassMain2.Fon_Is_Local_Membership__c = true;
        insert itmClassMain2;
        
        OrderApi__Item__c LocalMembershipItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        LocalMembershipItem.Name='2019 National Resident Virginia VA Northern Virginia';
        LocalMembershipItem.OrderApi__Item_Class__c=itmClassMain2.Id;
        LocalMembershipItem.OrderApi__Is_Subscription__c=true;
        LocalMembershipItem.OrderApi__Price__c=500;
        LocalMembershipItem.OrderApi__Is_Active__c=true;
        insert LocalMembershipItem;
        
        
        OrderApi__Item_Class__c itmClassMain3 = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false);
        itmClassMain3.OrderApi__Is_Active__c = true;
        insert itmClassMain3;
        
        OrderApi__Item__c pacItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        pacItem.Name='2019 National Resident Virginia VA Northern Virginia';
        pacItem.OrderApi__Item_Class__c=itmClassMain3.Id;
        pacItem.OrderApi__Price__c=500;
        pacItem.OrderApi__Is_Active__c=true;
        pacItem.Fon_Is_PAC_Item__c=true;
        insert pacItem;
        
        OrderApi__Item__c foundationItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        foundationItem.Name='2019 National Resident Virginia VA Northern Virginia';
        foundationItem.OrderApi__Item_Class__c=itmClassMain3.Id;
        foundationItem.OrderApi__Price__c=500;
        foundationItem.OrderApi__Is_Active__c=true;
        foundationItem.Is_Foundation_Donation__c=true;
        insert foundationItem;
        
        Fon_Membership_Staging__c ms = (Fon_Membership_Staging__c)Fon_TestDataFactory.createSObject('Fon_Membership_Staging__c', false);
        ms.Fon_Contact__c=con.Id;
        ms.Fon_Staging_Status__c='Approved';
        ms.Fon_Membership_Type__c='Resident';
        ms.Fon_Membership_State__c = 'Virginia';
        ms.Fon_Membership_Local__c= 'VA Northern Virginia';
        ms.Fon_Residency_Program_Graduation_Date__c=system.today();
        ms.Fon_Dues_Paid_by_Residency_Program__c=false;
        ms.Fon_Payment_Method_Id__c=payment.Id;
        ms.Fon_AAFP_Subscription_Plan_Picklist__c = 'Auto Full Pay';
        insert ms;
        
        
        memberStageIdSet.add(ms.Id);
        list<Fon_Membership_Staging__c> lstmem=new list<Fon_Membership_Staging__c>();
        lstmem.add(ms);
        Test.startTest();
        Fon_MembershipStagingBatch batch=new Fon_MembershipStagingBatch(memberStageIdSet);
        //Fon_MembershipStagingBatch batchable=new Fon_MembershipStagingBatch();
        
        Database.executeBatch(batch,1);
        // Fon_MembershipStagingTriggerHandler memstag=new Fon_MembershipStagingTriggerHandler();
        // List<OrderApi__Sales_Order__c> lstSalesOrder=memstag.initializeMembershipStage(lstmem);
        // system.assert(lstSalesOrder.size()>0);
        
        Test.stopTest();
        
        system.assertEquals(1, [Select Id From OrderApi__Sales_Order__c Where Fon_Membership_Staging__c!=NULL AND OrderApi__Posting_Entity__c='Receipt'].size(), 'Wrong No of SO got created');
        system.assertEquals(0, [Select Id From OrderApi__Sales_Order__c Where Fon_Membership_Staging__c!=NULL AND Fon_Salesorder_Type__c='Donation'].size(), 'Donation SO should not be created');
    }
    
    @isTest
    public static void method_AutoFullPay_Donation_Paid_by_Residency(){
        set<Id> memberStageIdSet=new set<Id>();
        
        Account acct = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert acct;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        insert con;
        
        OrderApi__Payment_Method__c payment = (OrderApi__Payment_Method__c)Fon_TestDataFactory.createSObject('OrderApi__Payment_Method__c', false); 
        insert payment;
        
        OrderApi__Item_Class__c itmClassMain = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClassMain.OrderApi__Is_Active__c = true;
        itmClassMain.Fon_Is_Main_Membership__c = true;
        insert itmClassMain;
        
        
        
        OrderApi__Item__c ActiveMembershipItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        ActiveMembershipItem.Name='2019 National Resident ';
        ActiveMembershipItem.OrderApi__Item_Class__c=itmClassMain.Id;
        ActiveMembershipItem.OrderApi__Is_Subscription__c=true;
        ActiveMembershipItem.OrderApi__Price__c=500;
        ActiveMembershipItem.OrderApi__Is_Active__c=true;
        insert ActiveMembershipItem;
        
        OrderApi__Item_Class__c itmClassMain1 = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false);
        itmClassMain1.OrderApi__Is_Active__c = true;
        itmClassMain1.Fon_Is_State_Membership__c = true;
        insert itmClassMain1;
        
        OrderApi__Item__c StateMembershipItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        StateMembershipItem.Name='2019 National Resident Virginia';
        StateMembershipItem.OrderApi__Item_Class__c=itmClassMain1.Id;
        StateMembershipItem.OrderApi__Is_Subscription__c=true;
        StateMembershipItem.OrderApi__Price__c=500;
        StateMembershipItem.OrderApi__Is_Active__c=true;
        insert StateMembershipItem;
        
        OrderApi__Item_Class__c itmClassMain2 = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false);
        itmClassMain2.OrderApi__Is_Active__c = true;
        itmClassMain2.Fon_Is_Local_Membership__c = true;
        insert itmClassMain2;
        
        OrderApi__Item__c LocalMembershipItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        LocalMembershipItem.Name='2019 National Resident Virginia VA Northern Virginia';
        LocalMembershipItem.OrderApi__Item_Class__c=itmClassMain2.Id;
        LocalMembershipItem.OrderApi__Is_Subscription__c=true;
        LocalMembershipItem.OrderApi__Price__c=500;
        LocalMembershipItem.OrderApi__Is_Active__c=true;
        insert LocalMembershipItem;
        
        
        OrderApi__Item_Class__c itmClassMain3 = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false);
        itmClassMain3.OrderApi__Is_Active__c = true;
        insert itmClassMain3;
        
        OrderApi__Item__c pacItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        pacItem.Name='2019 National Resident Virginia VA Northern Virginia';
        pacItem.OrderApi__Item_Class__c=itmClassMain3.Id;
        pacItem.OrderApi__Price__c=500;
        pacItem.OrderApi__Is_Active__c=true;
        pacItem.Fon_Is_PAC_Item__c=true;
        insert pacItem;
        
        OrderApi__Item__c foundationItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        foundationItem.Name='2019 National Resident Virginia VA Northern Virginia';
        foundationItem.OrderApi__Item_Class__c=itmClassMain3.Id;
        foundationItem.OrderApi__Price__c=500;
        foundationItem.OrderApi__Is_Active__c=true;
        foundationItem.Is_Foundation_Donation__c=true;
        insert foundationItem;
        
        Fon_Membership_Staging__c ms = (Fon_Membership_Staging__c)Fon_TestDataFactory.createSObject('Fon_Membership_Staging__c', false);
        ms.Fon_Contact__c=con.Id;
        ms.Fon_Staging_Status__c='Approved';
        ms.Fon_Membership_Type__c='Resident';
        ms.Fon_Membership_State__c = 'Virginia';
        ms.Fon_Membership_Local__c= 'VA Northern Virginia';
        ms.Fon_Residency_Program_Graduation_Date__c=system.today();
        ms.Fon_Dues_Paid_by_Residency_Program__c=true;
        ms.Fon_Payment_Method_Id__c=payment.Id;
        ms.Fon_Foundation_Contribution_Information__c=50;
        ms.Fon_PAC_Contribution_Information__c=60;
        ms.Fon_AAFP_Subscription_Plan_Picklist__c = 'Auto Full Pay';
        insert ms;
        
        
        memberStageIdSet.add(ms.Id);
        list<Fon_Membership_Staging__c> lstmem=new list<Fon_Membership_Staging__c>();
        lstmem.add(ms);
        Test.startTest();
        Fon_MembershipStagingBatch batch=new Fon_MembershipStagingBatch(memberStageIdSet);
        //Fon_MembershipStagingBatch batchable=new Fon_MembershipStagingBatch();
        
        Database.executeBatch(batch,1);
        // Fon_MembershipStagingTriggerHandler memstag=new Fon_MembershipStagingTriggerHandler();
        // List<OrderApi__Sales_Order__c> lstSalesOrder=memstag.initializeMembershipStage(lstmem);
        // system.assert(lstSalesOrder.size()>0);
        
        Test.stopTest();
        
        system.assertEquals(2, [Select Id From OrderApi__Sales_Order__c Where Fon_Membership_Staging__c!=NULL ].size(), 'Wrong No of SO got created');
        system.assertEquals(1, [Select Id From OrderApi__Sales_Order__c Where Fon_Membership_Staging__c!=NULL AND Fon_Salesorder_Type__c='Donation' AND OrderApi__Posting_Entity__c='Receipt'].size(), 'Donation SO should be created');
        system.assertEquals(1, [Select Id From OrderApi__Sales_Order__c Where Fon_Membership_Staging__c!=NULL AND  OrderApi__Posting_Entity__c ='Invoice'].size(), 'Only one Invoice SO should created');
    }
    
    @isTest
    public static void method_AutoFullPay_NoDonation_Paid_by_Residency(){
        set<Id> memberStageIdSet=new set<Id>();
        
        Account acct = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert acct;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        insert con;
        
        OrderApi__Payment_Method__c payment = (OrderApi__Payment_Method__c)Fon_TestDataFactory.createSObject('OrderApi__Payment_Method__c', false); 
        insert payment;
        
        OrderApi__Item_Class__c itmClassMain = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClassMain.OrderApi__Is_Active__c = true;
        itmClassMain.Fon_Is_Main_Membership__c = true;
        insert itmClassMain;
        
        
        
        OrderApi__Item__c ActiveMembershipItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        ActiveMembershipItem.Name='2019 National Resident ';
        ActiveMembershipItem.OrderApi__Item_Class__c=itmClassMain.Id;
        ActiveMembershipItem.OrderApi__Is_Subscription__c=true;
        ActiveMembershipItem.OrderApi__Price__c=500;
        ActiveMembershipItem.OrderApi__Is_Active__c=true;
        insert ActiveMembershipItem;
        
        OrderApi__Item_Class__c itmClassMain1 = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false);
        itmClassMain1.OrderApi__Is_Active__c = true;
        itmClassMain1.Fon_Is_State_Membership__c = true;
        insert itmClassMain1;
        
        OrderApi__Item__c StateMembershipItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        StateMembershipItem.Name='2019 National Resident Virginia';
        StateMembershipItem.OrderApi__Item_Class__c=itmClassMain1.Id;
        StateMembershipItem.OrderApi__Is_Subscription__c=true;
        StateMembershipItem.OrderApi__Price__c=500;
        StateMembershipItem.OrderApi__Is_Active__c=true;
        insert StateMembershipItem;
        
        OrderApi__Item_Class__c itmClassMain2 = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false);
        itmClassMain2.OrderApi__Is_Active__c = true;
        itmClassMain2.Fon_Is_Local_Membership__c = true;
        insert itmClassMain2;
        
        OrderApi__Item__c LocalMembershipItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        LocalMembershipItem.Name='2019 National Resident Virginia VA Northern Virginia';
        LocalMembershipItem.OrderApi__Item_Class__c=itmClassMain2.Id;
        LocalMembershipItem.OrderApi__Is_Subscription__c=true;
        LocalMembershipItem.OrderApi__Price__c=500;
        LocalMembershipItem.OrderApi__Is_Active__c=true;
        insert LocalMembershipItem;
        
        
        OrderApi__Item_Class__c itmClassMain3 = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false);
        itmClassMain3.OrderApi__Is_Active__c = true;
        insert itmClassMain3;
        
        OrderApi__Item__c pacItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        pacItem.Name='2019 National Resident Virginia VA Northern Virginia';
        pacItem.OrderApi__Item_Class__c=itmClassMain3.Id;
        pacItem.OrderApi__Price__c=500;
        pacItem.OrderApi__Is_Active__c=true;
        pacItem.Fon_Is_PAC_Item__c=true;
        insert pacItem;
        
        OrderApi__Item__c foundationItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        foundationItem.Name='2019 National Resident Virginia VA Northern Virginia';
        foundationItem.OrderApi__Item_Class__c=itmClassMain3.Id;
        foundationItem.OrderApi__Price__c=500;
        foundationItem.OrderApi__Is_Active__c=true;
        foundationItem.Is_Foundation_Donation__c=true;
        insert foundationItem;
        
        Fon_Membership_Staging__c ms = (Fon_Membership_Staging__c)Fon_TestDataFactory.createSObject('Fon_Membership_Staging__c', false);
        ms.Fon_Contact__c=con.Id;
        ms.Fon_Staging_Status__c='Approved';
        ms.Fon_Membership_Type__c='Resident';
        ms.Fon_Membership_State__c = 'Virginia';
        ms.Fon_Membership_Local__c= 'VA Northern Virginia';
        ms.Fon_Residency_Program_Graduation_Date__c=system.today();
        ms.Fon_Dues_Paid_by_Residency_Program__c=true;
        ms.Fon_Payment_Method_Id__c=payment.Id;
        //ms.Fon_Foundation_Contribution_Information__c=50;
        //ms.Fon_PAC_Contribution_Information__c=60;
        ms.Fon_AAFP_Subscription_Plan_Picklist__c = 'Auto Full Pay';
        insert ms;
        
        
        memberStageIdSet.add(ms.Id);
        list<Fon_Membership_Staging__c> lstmem=new list<Fon_Membership_Staging__c>();
        lstmem.add(ms);
        Test.startTest();
        Fon_MembershipStagingBatch batch=new Fon_MembershipStagingBatch(memberStageIdSet);
        //Fon_MembershipStagingBatch batchable=new Fon_MembershipStagingBatch();
        
        Database.executeBatch(batch,1);
        // Fon_MembershipStagingTriggerHandler memstag=new Fon_MembershipStagingTriggerHandler();
        // List<OrderApi__Sales_Order__c> lstSalesOrder=memstag.initializeMembershipStage(lstmem);
        // system.assert(lstSalesOrder.size()>0);
        
        Test.stopTest();
        
        system.assertEquals(1, [Select Id From OrderApi__Sales_Order__c Where Fon_Membership_Staging__c!=NULL ].size(), 'Wrong No of SO got created');
        system.assertEquals(0, [Select Id From OrderApi__Sales_Order__c Where Fon_Membership_Staging__c!=NULL AND Fon_Salesorder_Type__c='Donation' AND OrderApi__Posting_Entity__c='Receipt'].size(), 'Donation SO should NOT be created');
        system.assertEquals(1, [Select Id From OrderApi__Sales_Order__c Where Fon_Membership_Staging__c!=NULL AND  OrderApi__Posting_Entity__c ='Invoice'].size(), 'Only one Invoice SO should created');
    }
    // cover generate new invoice scenario
    @isTest
    public static void method_AutoFullPay_GenerateNewInvoice(){
        set<Id> memberStageIdSet=new set<Id>();
        
        Account acct = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert acct;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        insert con;
        
        OrderApi__Payment_Method__c payment = (OrderApi__Payment_Method__c)Fon_TestDataFactory.createSObject('OrderApi__Payment_Method__c', false); 
        insert payment;
        
        OrderApi__Item_Class__c itmClassMain = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClassMain.OrderApi__Is_Active__c = true;
        itmClassMain.Fon_Is_Main_Membership__c = true;
        insert itmClassMain;
        
        
        
        OrderApi__Item__c ActiveMembershipItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        ActiveMembershipItem.Name='2019 National Resident ';
        ActiveMembershipItem.OrderApi__Item_Class__c=itmClassMain.Id;
        ActiveMembershipItem.OrderApi__Is_Subscription__c=true;
        ActiveMembershipItem.OrderApi__Price__c=500;
        ActiveMembershipItem.OrderApi__Is_Active__c=true;
        insert ActiveMembershipItem;
        
        OrderApi__Item_Class__c itmClassMain1 = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false);
        itmClassMain1.OrderApi__Is_Active__c = true;
        itmClassMain1.Fon_Is_State_Membership__c = true;
        insert itmClassMain1;
        
        OrderApi__Item__c StateMembershipItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        StateMembershipItem.Name='2019 National Resident Virginia';
        StateMembershipItem.OrderApi__Item_Class__c=itmClassMain1.Id;
        StateMembershipItem.OrderApi__Is_Subscription__c=true;
        StateMembershipItem.OrderApi__Price__c=500;
        StateMembershipItem.OrderApi__Is_Active__c=true;
        insert StateMembershipItem;
        
        OrderApi__Item_Class__c itmClassMain2 = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false);
        itmClassMain2.OrderApi__Is_Active__c = true;
        itmClassMain2.Fon_Is_Local_Membership__c = true;
        insert itmClassMain2;
        
        OrderApi__Item__c LocalMembershipItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        LocalMembershipItem.Name='2019 National Resident Virginia VA Northern Virginia';
        LocalMembershipItem.OrderApi__Item_Class__c=itmClassMain2.Id;
        LocalMembershipItem.OrderApi__Is_Subscription__c=true;
        LocalMembershipItem.OrderApi__Price__c=500;
        LocalMembershipItem.OrderApi__Is_Active__c=true;
        insert LocalMembershipItem;
        
        
        OrderApi__Item_Class__c itmClassMain3 = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false);
        itmClassMain3.OrderApi__Is_Active__c = true;
        insert itmClassMain3;
        
        OrderApi__Item__c pacItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        pacItem.Name='2019 National Resident Virginia VA Northern Virginia';
        pacItem.OrderApi__Item_Class__c=itmClassMain3.Id;
        pacItem.OrderApi__Price__c=500;
        pacItem.OrderApi__Is_Active__c=true;
        pacItem.Fon_Is_PAC_Item__c=true;
        insert pacItem;
        
        OrderApi__Item__c foundationItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        foundationItem.Name='2019 National Resident Virginia VA Northern Virginia';
        foundationItem.OrderApi__Item_Class__c=itmClassMain3.Id;
        foundationItem.OrderApi__Price__c=500;
        foundationItem.OrderApi__Is_Active__c=true;
        foundationItem.Is_Foundation_Donation__c=true;
        insert foundationItem;
        
        Fon_Membership_Staging__c ms = (Fon_Membership_Staging__c)Fon_TestDataFactory.createSObject('Fon_Membership_Staging__c', false);
        ms.Fon_Contact__c=con.Id;
        ms.Fon_Staging_Status__c='Approved';
        ms.Fon_Membership_Type__c='Resident';
        ms.Fon_Membership_State__c = 'Virginia';
        ms.Fon_Membership_Local__c= 'VA Northern Virginia';
        ms.Fon_Residency_Program_Graduation_Date__c=system.today();
        ms.Fon_Dues_Paid_by_Residency_Program__c=true;
        ms.Fon_Payment_Method_Id__c=payment.Id;
        //ms.Fon_Foundation_Contribution_Information__c=50;
        //ms.Fon_PAC_Contribution_Information__c=60;
        ms.Fon_Generate_New_Invoice__c = true;
        ms.Fon_AAFP_Subscription_Plan_Picklist__c = 'Auto Full Pay';
        insert ms;
        
        
        memberStageIdSet.add(ms.Id);
        list<Fon_Membership_Staging__c> lstmem=new list<Fon_Membership_Staging__c>();
        lstmem.add(ms);
        Test.startTest();
        Fon_MembershipStagingBatch batch=new Fon_MembershipStagingBatch(memberStageIdSet);
        //Fon_MembershipStagingBatch batchable=new Fon_MembershipStagingBatch();
        
        Database.executeBatch(batch,1);
        // Fon_MembershipStagingTriggerHandler memstag=new Fon_MembershipStagingTriggerHandler();
        // List<OrderApi__Sales_Order__c> lstSalesOrder=memstag.initializeMembershipStage(lstmem);
        // system.assert(lstSalesOrder.size()>0);
        
        Test.stopTest();
        
        system.assertEquals(1, [Select Id From OrderApi__Sales_Order__c Where Fon_Membership_Staging__c!=NULL ].size(), 'Wrong No of SO got created');
        system.assertEquals(0, [Select Id From OrderApi__Sales_Order__c Where Fon_Membership_Staging__c!=NULL AND Fon_Salesorder_Type__c='Donation' AND OrderApi__Posting_Entity__c='Receipt'].size(), 'Donation SO should NOT be created');
        system.assertEquals(1, [Select Id From OrderApi__Sales_Order__c Where Fon_Membership_Staging__c!=NULL AND  OrderApi__Posting_Entity__c ='Invoice'].size(), 'Only one Invoice SO should created');
    }
    // Cover Installment scenario including DOnation Item
    @isTest
    public static void method_Installment_Donation(){
        set<Id> memberStageIdSet=new set<Id>();
        
        Account acct = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert acct;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        insert con;
        
        OrderApi__Business_Group__c bg = (OrderApi__Business_Group__c)Fon_TestDataFactory.createSObject('OrderApi__Business_Group__c', false); 
        insert bg;
        
        OrderApi__Payment_Method__c payment = (OrderApi__Payment_Method__c)Fon_TestDataFactory.createSObject('OrderApi__Payment_Method__c', false); 
        insert payment;
        
        OrderApi__Item_Class__c itmClassMain = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClassMain.OrderApi__Is_Active__c = true;
        itmClassMain.Fon_Is_Main_Membership__c = true;
        insert itmClassMain;
        
        OrderApi__Subscription_Plan__c subPlan = (OrderApi__Subscription_Plan__c) Fon_TestDataFactory.createSObject('OrderApi__Subscription_Plan__c', false);
        subPlan.Name = '9.9 Installments Autorenew';
        subPlan.OrderApi__Type__c = 'Calendar';
        subPlan.OrderApi__Is_Active__c = true;
        subPlan.OrderApi__Business_Group__c = bg.Id;
        subPlan.OrderApi__Enable_Schedule__c = TRUE;
        subPlan.OrderApi__Schedule_Type__c = 'Invoice';
        subPlan.OrderApi__Schedule_Frequency__c = 'Monthly';
        subPlan.OrderApi__Calendar_End_Day__c = '12';
        subPlan.OrderApi__Calendar_End_Month__c = '12 - December';
        insert subPlan;
        
        // Item subscription plan
        List<OrderApi__Item_Subscription_Plan__c> subPlans = new List<OrderApi__Item_Subscription_Plan__c>();
        
        
        OrderApi__Item__c ActiveMembershipItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        ActiveMembershipItem.Name='2019 National Resident ';
        ActiveMembershipItem.OrderApi__Item_Class__c=itmClassMain.Id;
        ActiveMembershipItem.OrderApi__Is_Subscription__c=true;
        ActiveMembershipItem.OrderApi__Price__c=500;
        ActiveMembershipItem.OrderApi__Is_Active__c=true;
        insert ActiveMembershipItem;
        
        OrderApi__Item_Subscription_Plan__c ActiveMemPLan = new OrderApi__Item_Subscription_Plan__c(OrderApi__Is_Default__c=true,OrderApi__Subscription_Plan__c = subPlan.Id,
                                                                                                    OrderApi__Item__c=ActiveMembershipItem.id); 
        subPlans.add(ActiveMemPLan); 
        
        OrderApi__Item_Class__c itmClassMain1 = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false);
        itmClassMain1.OrderApi__Is_Active__c = true;
        itmClassMain1.Fon_Is_State_Membership__c = true;
        insert itmClassMain1;
        
        
        
        OrderApi__Item__c StateMembershipItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        StateMembershipItem.Name='2019 National Resident Virginia';
        StateMembershipItem.OrderApi__Item_Class__c=itmClassMain1.Id;
        StateMembershipItem.OrderApi__Is_Subscription__c=true;
        StateMembershipItem.OrderApi__Price__c=500;
        StateMembershipItem.OrderApi__Is_Active__c=true;
        insert StateMembershipItem;
        
        OrderApi__Item_Subscription_Plan__c StateMemPLan = new OrderApi__Item_Subscription_Plan__c(OrderApi__Is_Default__c=true,OrderApi__Subscription_Plan__c = subPlan.Id,
                                                                                                   OrderApi__Item__c=StateMembershipItem.id); 
        subPlans.add(StateMemPLan); 
        
        OrderApi__Item_Class__c itmClassMain2 = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false);
        itmClassMain2.OrderApi__Is_Active__c = true;
        itmClassMain2.Fon_Is_Local_Membership__c = true;
        insert itmClassMain2;
        
        OrderApi__Item__c LocalMembershipItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        LocalMembershipItem.Name='2019 National Resident Virginia VA Northern Virginia';
        LocalMembershipItem.OrderApi__Item_Class__c=itmClassMain2.Id;
        LocalMembershipItem.OrderApi__Is_Subscription__c=true;
        LocalMembershipItem.OrderApi__Price__c=500;
        LocalMembershipItem.OrderApi__Is_Active__c=true;
        insert LocalMembershipItem;
        
        OrderApi__Item_Subscription_Plan__c LocalMemPLan = new OrderApi__Item_Subscription_Plan__c(OrderApi__Is_Default__c=true,OrderApi__Subscription_Plan__c = subPlan.Id,
                                                                                                   OrderApi__Item__c=LocalMembershipItem.id); 
        subPlans.add(LocalMemPLan); 
        
        insert subPlans;
        
        OrderApi__Item_Class__c itmClassMain3 = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false);
        itmClassMain3.OrderApi__Is_Active__c = true;
        insert itmClassMain3;
        
        OrderApi__Item__c pacItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        pacItem.Name='2019 National Resident Virginia VA Northern Virginia';
        pacItem.OrderApi__Item_Class__c=itmClassMain3.Id;
        pacItem.OrderApi__Price__c=500;
        pacItem.OrderApi__Is_Active__c=true;
        pacItem.Fon_Is_PAC_Item__c=true;
        insert pacItem;
        
        OrderApi__Item__c foundationItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        foundationItem.Name='2019 National Resident Virginia VA Northern Virginia';
        foundationItem.OrderApi__Item_Class__c=itmClassMain3.Id;
        foundationItem.OrderApi__Price__c=500;
        foundationItem.OrderApi__Is_Active__c=true;
        foundationItem.Is_Foundation_Donation__c=true;
        insert foundationItem;
        
        Fon_Membership_Staging__c ms = (Fon_Membership_Staging__c)Fon_TestDataFactory.createSObject('Fon_Membership_Staging__c', false);
        ms.Fon_Contact__c=con.Id;
        ms.Fon_Staging_Status__c='Approved';
        ms.Fon_Membership_Type__c='Resident';
        ms.Fon_Membership_State__c = 'Virginia';
        ms.Fon_Membership_Local__c= 'VA Northern Virginia';
        ms.Fon_Residency_Program_Graduation_Date__c=system.today();
        ms.Fon_Dues_Paid_by_Residency_Program__c=false;
        ms.Fon_Payment_Method_Id__c=payment.Id;
        ms.Fon_Foundation_Contribution_Information__c=50;
        ms.Fon_PAC_Contribution_Information__c=60;
        ms.Fon_AAFP_Subscription_Plan_Picklist__c = 'Installment';
        ms.Fon_Subscription_Plan__c = '9.9 Installments Autorenew';
        insert ms;
        
        
        memberStageIdSet.add(ms.Id);
        list<Fon_Membership_Staging__c> lstmem=new list<Fon_Membership_Staging__c>();
        lstmem.add(ms);
        Test.startTest();
        Fon_MembershipStagingBatch batch=new Fon_MembershipStagingBatch(memberStageIdSet);
        //Fon_MembershipStagingBatch batchable=new Fon_MembershipStagingBatch();
        
        Database.executeBatch(batch,1);
        // Fon_MembershipStagingTriggerHandler memstag=new Fon_MembershipStagingTriggerHandler();
        // List<OrderApi__Sales_Order__c> lstSalesOrder=memstag.initializeMembershipStage(lstmem);
        // system.assert(lstSalesOrder.size()>0);
        
        Test.stopTest();
        
        system.assertEquals(2, [Select Id From OrderApi__Sales_Order__c Where Fon_Membership_Staging__c!=NULL].size(), 'Wrong No of SO got created');
        system.assertEquals(1, [Select Id From OrderApi__Sales_Order__c Where Fon_Membership_Staging__c!=NULL AND OrderApi__Posting_Entity__c='Invoice'].size(), 'Wrong Invoice SO got created');
        system.assertEquals(1, [Select Id From OrderApi__Sales_Order__c Where Fon_Membership_Staging__c!=NULL AND Fon_Salesorder_Type__c='Donation'].size(), 'DOnation SO is missing');
    }
    
    // Cover Installment scenario excluding DOnation Item, but Convience SO should be there
    @isTest
    public static void method_Installment_NODonation(){
        set<Id> memberStageIdSet=new set<Id>();
        
        Account acct = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert acct;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        insert con;
        
        OrderApi__Business_Group__c bg = (OrderApi__Business_Group__c)Fon_TestDataFactory.createSObject('OrderApi__Business_Group__c', false); 
        insert bg;
        
        OrderApi__Payment_Method__c payment = (OrderApi__Payment_Method__c)Fon_TestDataFactory.createSObject('OrderApi__Payment_Method__c', false); 
        insert payment;
        
        OrderApi__Item_Class__c itmClassMain = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClassMain.OrderApi__Is_Active__c = true;
        itmClassMain.Fon_Is_Main_Membership__c = true;
        insert itmClassMain;
        
        OrderApi__Subscription_Plan__c subPlan = (OrderApi__Subscription_Plan__c) Fon_TestDataFactory.createSObject('OrderApi__Subscription_Plan__c', false);
        subPlan.Name = '9.9 Installments Autorenew';
        subPlan.OrderApi__Type__c = 'Calendar';
        subPlan.OrderApi__Is_Active__c = true;
        subPlan.OrderApi__Business_Group__c = bg.Id;
        subPlan.OrderApi__Enable_Schedule__c = TRUE;
        subPlan.OrderApi__Schedule_Type__c = 'Invoice';
        subPlan.OrderApi__Schedule_Frequency__c = 'Monthly';
        subPlan.OrderApi__Calendar_End_Day__c = '12';
        subPlan.OrderApi__Calendar_End_Month__c = '12 - December';
        insert subPlan;
        
        // Item subscription plan
        List<OrderApi__Item_Subscription_Plan__c> subPlans = new List<OrderApi__Item_Subscription_Plan__c>();
        
        
        OrderApi__Item__c ActiveMembershipItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        ActiveMembershipItem.Name='2019 National Resident ';
        ActiveMembershipItem.OrderApi__Item_Class__c=itmClassMain.Id;
        ActiveMembershipItem.OrderApi__Is_Subscription__c=true;
        ActiveMembershipItem.OrderApi__Price__c=500;
        ActiveMembershipItem.OrderApi__Is_Active__c=true;
        insert ActiveMembershipItem;
        
        OrderApi__Item_Subscription_Plan__c ActiveMemPLan = new OrderApi__Item_Subscription_Plan__c(OrderApi__Is_Default__c=true,OrderApi__Subscription_Plan__c = subPlan.Id,
                                                                                                    OrderApi__Item__c=ActiveMembershipItem.id); 
        subPlans.add(ActiveMemPLan); 
        
        OrderApi__Item_Class__c itmClassMain1 = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false);
        itmClassMain1.OrderApi__Is_Active__c = true;
        itmClassMain1.Fon_Is_State_Membership__c = true;
        insert itmClassMain1;
        
        
        
        OrderApi__Item__c StateMembershipItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        StateMembershipItem.Name='2019 National Resident Virginia';
        StateMembershipItem.OrderApi__Item_Class__c=itmClassMain1.Id;
        StateMembershipItem.OrderApi__Is_Subscription__c=true;
        StateMembershipItem.OrderApi__Price__c=500;
        StateMembershipItem.OrderApi__Is_Active__c=true;
        insert StateMembershipItem;
        
        OrderApi__Item_Subscription_Plan__c StateMemPLan = new OrderApi__Item_Subscription_Plan__c(OrderApi__Is_Default__c=true,OrderApi__Subscription_Plan__c = subPlan.Id,
                                                                                                   OrderApi__Item__c=StateMembershipItem.id); 
        subPlans.add(StateMemPLan); 
        
        OrderApi__Item_Class__c itmClassMain2 = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false);
        itmClassMain2.OrderApi__Is_Active__c = true;
        itmClassMain2.Fon_Is_Local_Membership__c = true;
        insert itmClassMain2;
        
        OrderApi__Item__c LocalMembershipItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        LocalMembershipItem.Name='2019 National Resident Virginia VA Northern Virginia';
        LocalMembershipItem.OrderApi__Item_Class__c=itmClassMain2.Id;
        LocalMembershipItem.OrderApi__Is_Subscription__c=true;
        LocalMembershipItem.OrderApi__Price__c=500;
        LocalMembershipItem.OrderApi__Is_Active__c=true;
        insert LocalMembershipItem;
        
        OrderApi__Item_Subscription_Plan__c LocalMemPLan = new OrderApi__Item_Subscription_Plan__c(OrderApi__Is_Default__c=true,OrderApi__Subscription_Plan__c = subPlan.Id,
                                                                                                   OrderApi__Item__c=LocalMembershipItem.id); 
        subPlans.add(LocalMemPLan); 
        
        insert subPlans;
        
        OrderApi__Item_Class__c itmClassMain3 = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false);
        itmClassMain3.OrderApi__Is_Active__c = true;
        insert itmClassMain3;
        
        OrderApi__Item__c pacItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        pacItem.Name='2019 National Resident Virginia VA Northern Virginia';
        pacItem.OrderApi__Item_Class__c=itmClassMain3.Id;
        pacItem.OrderApi__Price__c=500;
        pacItem.OrderApi__Is_Active__c=true;
        pacItem.Fon_Is_PAC_Item__c=true;
        insert pacItem;
        
        OrderApi__Item__c foundationItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        foundationItem.Name='2019 National Resident Virginia VA Northern Virginia';
        foundationItem.OrderApi__Item_Class__c=itmClassMain3.Id;
        foundationItem.OrderApi__Price__c=500;
        foundationItem.OrderApi__Is_Active__c=true;
        foundationItem.Is_Foundation_Donation__c=true;
        insert foundationItem;
        
        OrderApi__Item__c convenienceItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        convenienceItem.Name= String.valueOf(System.Today().Year())+' ' + 'Convenience Fee';
        convenienceItem.OrderApi__Item_Class__c=itmClassMain3.Id;
        convenienceItem.OrderApi__Price__c=500;
        convenienceItem.OrderApi__Is_Active__c=true;
        insert convenienceItem;
        
        Fon_Membership_Staging__c ms = (Fon_Membership_Staging__c)Fon_TestDataFactory.createSObject('Fon_Membership_Staging__c', false);
        ms.Fon_Contact__c=con.Id;
        ms.Fon_Staging_Status__c='Approved';
        ms.Fon_Membership_Type__c='Resident';
        ms.Fon_Membership_State__c = 'Virginia';
        ms.Fon_Membership_Local__c= 'VA Northern Virginia';
        ms.Fon_Residency_Program_Graduation_Date__c=system.today();
        ms.Fon_Dues_Paid_by_Residency_Program__c=false;
        ms.Fon_Payment_Method_Id__c=payment.Id;
        //ms.Fon_Foundation_Contribution_Information__c=50;
        //ms.Fon_PAC_Contribution_Information__c=60;
        ms.Fon_AAFP_Subscription_Plan_Picklist__c = 'Installment';
        ms.Fon_Subscription_Plan__c = '9.9 Installments Autorenew';
        //ms.Fon_Convenience_Fee__c = String.valueOf(System.Today().Year())+' ' + 'Convenience Fee';
        insert ms;
        
        
        memberStageIdSet.add(ms.Id);
        list<Fon_Membership_Staging__c> lstmem=new list<Fon_Membership_Staging__c>();
        lstmem.add(ms);
        Test.startTest();
        Fon_MembershipStagingBatch batch=new Fon_MembershipStagingBatch(memberStageIdSet);
        //Fon_MembershipStagingBatch batchable=new Fon_MembershipStagingBatch();
        
        Database.executeBatch(batch,1);
        // Fon_MembershipStagingTriggerHandler memstag=new Fon_MembershipStagingTriggerHandler();
        // List<OrderApi__Sales_Order__c> lstSalesOrder=memstag.initializeMembershipStage(lstmem);
        // system.assert(lstSalesOrder.size()>0);
        
        Test.stopTest();
        
        system.assertEquals(2, [Select Id From OrderApi__Sales_Order__c Where Fon_Membership_Staging__c!=NULL].size(), 'Wrong No of SO got created');
        system.assertEquals(1, [Select Id From OrderApi__Sales_Order__c Where Fon_Membership_Staging__c!=NULL AND OrderApi__Posting_Entity__c='Invoice'].size(), 'Wrong Invoice SO got created');
        system.assertEquals(1, [Select Id From OrderApi__Sales_Order__c Where Fon_Membership_Staging__c!=NULL AND Fon_Salesorder_Type__c='Donation'].size(), 'DOnation SO is missing');
    }
    
    @isTest
    public static void method2(){
        set<Id> memberStageIdSet=new set<Id>();
        Account acct = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert acct;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        insert con;
        
        OrderApi__Payment_Method__c payment = (OrderApi__Payment_Method__c)Fon_TestDataFactory.createSObject('OrderApi__Payment_Method__c', false); 
        insert payment;  
        
        OrderApi__Item_Class__c itmClassMain = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false);
        itmClassMain.OrderApi__Is_Active__c = true;
        itmClassMain.Fon_Is_Main_Membership__c = true;
        insert itmClassMain;
        
        OrderApi__Item__c ActiveMembershipItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false);
        ActiveMembershipItem.Name='2019 National Resident ';
        ActiveMembershipItem.OrderApi__Item_Class__c=itmClassMain.Id;
        ActiveMembershipItem.OrderApi__Is_Subscription__c=true;
        ActiveMembershipItem.OrderApi__Price__c=500;
        ActiveMembershipItem.OrderApi__Is_Active__c=true;
        insert ActiveMembershipItem;
        
        
        Fon_Membership_Staging__c ms = (Fon_Membership_Staging__c)Fon_TestDataFactory.createSObject('Fon_Membership_Staging__c', false);
        ms.Fon_Contact__c=con.Id;
        ms.Fon_Staging_Status__c='Approved';
        ms.Fon_Membership_Type__c='Resident';
        ms.Fon_Membership_State__c = 'Virginia';
        ms.Fon_Membership_Local__c= 'VA Northern Virginia';
        ms.Fon_Residency_Program_Graduation_Date__c=system.today();
        ms.Fon_Payment_Method_Id__c=payment.Id;
        
        ms.Fon_Dues_Paid_by_Residency_Program__c=true;
        ms.Fon_Generate_New_Invoice__c=true;  
        insert ms;
        ms.Fon_Is_New__c=false;
        update ms;
        
        memberStageIdSet.add(ms.Id);
        
        list<Fon_Membership_Staging__c> lstmem=new list<Fon_Membership_Staging__c>();
        lstmem.add(ms);
        Test.startTest();
        Fon_MembershipStagingBatch batch=new Fon_MembershipStagingBatch(memberStageIdSet);
        Fon_MembershipStagingBatch batchable=new Fon_MembershipStagingBatch();
        try{
            Database.executeBatch(batchable);
            Map<String,OrderApi__Subscription_Plan__c> mapNameToObjSubscriptionPlan = new Map<String,OrderApi__Subscription_Plan__c>();
            Fon_MembershipStagingTriggerHandler memstag=new Fon_MembershipStagingTriggerHandler();
           // Fon_MembershipStagingTriggerHandler.createSOL(ActiveMembershipItem ,ms,mapNameToObjSubscriptionPlan);
           // List<OrderApi__Sales_Order__c> lstSalesOrder=memstag.initializeMembershipStage_FDService(lstmem);
          //  List<OrderApi__Sales_Order__c> lstSalesOrder1=memstag.initializeMembershipStage_Direct(lstmem);
        //    system.assert(lstSalesOrder.size()>0);
        }
        catch(Exception e){
            String exceptionMessage = e.getMessage(); 
        }
        Test.stopTest();
    }
}