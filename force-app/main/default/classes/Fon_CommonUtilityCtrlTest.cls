@isTest
public class Fon_CommonUtilityCtrlTest {
    public static testMethod void method() {
        
        Account acct = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert acct;
        
        set<Id> contactID= new set<Id>();
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        insert con;
        
        contactID.add(con.Id);
        
        
        OrderApi__Subscription_Plan__c subPlan = (OrderApi__Subscription_Plan__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription_Plan__c', false); 
        subPlan.OrderApi__Type__c = 'Calendar';
        subPlan.OrderApi__Is_Active__c = true;
        subPlan.OrderApi__Auto_Renew_Option__c = 'Enabled';
        insert subPlan;
        
        OrderApi__Item_Class__c itmClass = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClass.OrderApi__Enable_Assignments__c = false;
        itmClass.OrderApi__Is_Subscription__c = true;
        itmClass.OrderApi__Is_Active__c = false;
        itmClass.Fon_Is_Main_Membership__c=true;
        itmClass.OrderApi__Is_Active__c = true;
        insert itmClass;
        
        
        
        OrderApi__Item__c itm = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm.OrderApi__Item_Class__c = itmClass.Id;
        itm.OrderApi__Is_Active__c = true;
        itm.OrderApi__Price__c = 15;
        insert itm;
        
        
        OrderApi__Sales_Order__c so = (OrderApi__Sales_Order__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order__c', false); 
        so.OrderApi__Account__c = acct.id;
        so.OrderApi__Contact__c = con.id;
        so.OrderApi__Posting_Entity__c = 'Invoice';
        so.OrderApi__Schedule_Type__c='Installment';
        so.OrderApi__Number_of_Installments__c=5;
        insert so;
        


        
        OrderApi__Sales_Order_Line__c sol1 = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false); 
        sol1.OrderApi__Sales_Order__c = so.id;
        sol1.OrderApi__Account__c = acct.id;
        sol1.OrderApi__Contact__c = con.id;
        sol1.OrderApi__Item__c = itm.id;
        sol1.OrderApi__Is_Subscription__c = true;       
        sol1.OrderApi__Is_Renewal__c=true;
        insert sol1;
        
        
        
        so.OrderApi__Status__c='Closed';
        so.OrderApi__Is_Posted__c=true;
        update so;
        
        
        OrderApi__Invoice__c inv = (OrderApi__Invoice__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice__c', false); 
        inv.OrderApi__Contact__c=con.id;
        inv.OrderApi__Sales_Order__c=so.id;      
        inv.OrderApi__Amount_Paid__c=50;
       
        insert inv;
        
        list<OrderApi__Invoice_Line__c> invlist = new list<OrderApi__Invoice_Line__c>();
        
        OrderApi__Invoice_Line__c invline = (OrderApi__Invoice_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice_Line__c', false); 
        invline.OrderApi__Invoice__c=inv.Id;
        invline.OrderApi__Item__c=itm.Id;
        invlist.add(invline);
        insert invlist;
        
        list<OrderApi__Subscription__c> sublist=new list<OrderApi__Subscription__c>();
        OrderApi__Subscription__c sub = (OrderApi__Subscription__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription__c', false); 
        sub.OrderApi__Account__c=acct.id;
        sub.OrderApi__Contact__c=con.id;
        sub.OrderApi__Subscription_Plan__c=subPlan.id;
        sub.OrderApi__Item__c=itm.Id;
        sub.OrderApi__Status__c='Active';
        sub.OrderApi__Sales_Order_Line__c=sol1.Id;
        sublist.add(sub);
        insert sublist;
        
        
        
        
        Test.startTest();
        try{
            List<OrderApi__Subscription__c> subList1 = Fon_CommonUtilityCtrl.fetchSubscriptionBycontactIdSet(contactID); 
            
            Fon_CommonUtilityCtrl.updateSubscription(sublist,'Active');
            Fon_CommonUtilityCtrl.updatingContactStatus(contactID,'Active');
            Fon_CommonUtilityCtrl.updatingInvoiceAndScheduledPayment(sublist);
            Fon_CommonUtilityCtrl fon1=new Fon_CommonUtilityCtrl();
            fon1.createNewMembership(contactID);
            Fon_CommonUtilityCtrl fon= new Fon_CommonUtilityCtrl();
            Fon_Membership_Staging__c member= fon.fetchMembershipInstance(con);
            
            
            system.assert(subList1.size() > 0);
            system.assert(member != null);
            
            //.................
            
        }
        catch(Exception e){
            String exceptionMessage = e.getMessage();
        }
            //.................
            Test.stopTest();
        
    }
}