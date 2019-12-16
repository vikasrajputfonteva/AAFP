@isTest
public class Fon_RefundCreditMemoTest {
    
    @istest
    static void method1() {
        
        OrderApi__Credit_Memo__c cm = (OrderApi__Credit_Memo__c)Fon_TestDataFactory.createSObject('OrderApi__Credit_Memo__c', false); 
        cm.OrderApi__Amount__c=100;
        insert cm;
        
        
        OrderApi__Transaction__c tr = (OrderApi__Transaction__c)Fon_TestDataFactory.createSObject('OrderApi__Transaction__c', false); 
        tr.OrderApi__Credit_Memo__c=cm.Id;
        insert tr;
        
        
        OrderApi__Receipt__c receipt = (OrderApi__Receipt__c)Fon_TestDataFactory.createSObject('OrderApi__Receipt__c', false); 
        insert receipt;
        
        
        cm.Fon_Receipt__c=receipt.Id;
        update cm;
        
        
        OrderApi__Item_Class__c itmClass = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClass.OrderApi__Enable_Assignments__c = false;
        itmClass.OrderApi__Is_Subscription__c = true;
        itmClass.OrderApi__Is_Active__c = true;
        insert itmClass;
        
        
        OrderApi__Item__c itm = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm.Name = 'Credit Memo Refund Item';
        insert itm;
        
        
        
        OrderApi__Subscription_Plan__c subPlan = (OrderApi__Subscription_Plan__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription_Plan__c', false); 
        subPlan.OrderApi__Type__c = 'Termed';
        subPlan.OrderApi__Initial_Term_Months__c = 12;
        subPlan.OrderApi__Renewal_Term_Months__c = 12;
        subPlan.OrderApi__Auto_Renew_Option__c = 'Enabled';
        subPlan.OrderApi__Enable_Proration__c = false;
        subPlan.OrderApi__Is_Active__c = true;
        subPlan.OrderApi__Enable_Schedule__c=true;
        subPlan.OrderApi__Schedule_Frequency__c='Monthly';
        insert subPlan;
        
        
        
        OrderApi__Item_Subscription_Plan__c sp = (OrderApi__Item_Subscription_Plan__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Subscription_Plan__c', false); 
        sp.OrderApi__Is_Default__c=true;
        sp.OrderApi__Item__c=itm.Id;
        sp.OrderApi__Subscription_Plan__c=subPlan.Id;
        insert sp;
        
        
        itm.OrderApi__Is_Active__c=true;      
        update itm;
        
        Test.startTest();
        
       // Fon_RefundCreditMemo rcm= new Fon_RefundCreditMemo();
        Fon_RefundCreditMemo.refundCreditMemo(cm.ID);
        try{
          //  rcm.createCreditMemoline();
          //  Id recId = rcm.createRefundReceipt(cm.OrderApi__Remaining_Amount__c);
         //   OrderApi__Receipt__c receipt1 = [select id ,OrderApi__Type__c from  OrderApi__Receipt__c where Id =: recId];
          //  system.assertEquals(receipt1.OrderApi__Type__c, 'Refund');
        }
        catch (Exception e) {
            String exceptionMessage = e.getMessage();
        }
        Test.stopTest();
    }
}