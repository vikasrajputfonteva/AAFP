@isTest
public class Fon_SalesOrderCreditRefundCtrlTest {
    public static testMethod void method() {
        
        
        Account acct = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert acct;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        insert con;
        
        
        OrderApi__Sales_Order__c so = (OrderApi__Sales_Order__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order__c', false); 
        so.OrderApi__Account__c = acct.id;
        so.OrderApi__Contact__c = con.id;
        so.OrderApi__Posting_Entity__c = 'Invoice';
        insert so;
        
        so.OrderApi__Status__c='Closed';
        update so;
        
        
        OrderApi__Item_Class__c itmClass = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClass.OrderApi__Enable_Assignments__c = false;
        itmClass.OrderApi__Is_Active__c = true;
        insert itmClass;
        
        
        OrderApi__Item__c itm = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm.OrderApi__Item_Class__c = itmClass.Id;
        itm.OrderApi__Is_Active__c = true;
        itm.OrderApi__Price__c = 15;
        insert itm;
        
        OrderApi__Sales_Order_Line__c soli = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false); 
        soli.OrderApi__Sales_Order__c = so.id;
        soli.OrderApi__Account__c = acct.id;
        soli.OrderApi__Contact__c = con.id;
        soli.OrderApi__Item__c = itm.id;
        insert soli;
        
        
        OrderApi__Receipt__c rec = (OrderApi__Receipt__c)Fon_TestDataFactory.createSObject('OrderApi__Receipt__c', false);
        rec.OrderApi__Type__c='Payment';
        rec.OrderApi__Is_Posted__c=true;
        rec.OrderApi__Is_Payment__c = true;
        rec.OrderApi__Sales_Order__c=so.Id;
        rec.OrderApi__Contact__c=con.Id;
        insert rec;
        
        
        OrderApi__Receipt_Line__c lines = (OrderApi__Receipt_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Receipt_Line__c', false); 
        lines.OrderApi__Receipt__c=rec.Id;
        lines.OrderApi__Item__c=itm.Id;
        lines.Fon_Refund_Quantity__c=2;
        lines.Fon_Refund_Amount__c=10;
        insert lines;
        
        
        
        OrderApi__Invoice__c inv = (OrderApi__Invoice__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice__c', false); 
        inv.OrderApi__Contact__c=con.id;
        inv.OrderApi__Sales_Order__c=so.id;      
        inv.OrderApi__Is_Posted__c=true;
        insert inv;
        
        
        OrderApi__Invoice_Line__c invline = (OrderApi__Invoice_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice_Line__c', false); 
        invline.OrderApi__Invoice__c=inv.Id;
        invline.OrderApi__Item__c=itm.Id;
        invline.OrderApi__Sale_Price__c=50;
        invline.OrderApi__Quantity__c=1;
        insert invline;
        
        
        inv.OrderApi__Amount_Paid__c=50;
        update inv;       
        
        Test.startTest();
        Fon_SalesOrderCreditRefundCtrl.fetchSOByCreditAndRefundLine(so.Id);
        
        
        List<String> receiptlinesIds = new List<String>();
        receiptlinesIds.add(invline.Id);
        
        List<OrderApi__Invoice_Line__c> invLine1 = new List<OrderApi__Invoice_Line__c>();
        invLine1.add(invline);
        
        
        List<String> receiptlinesIds1 = new List<String>();
        receiptlinesIds1.add(lines.Id);
        
        List<OrderApi__Receipt_Line__c> receiptLine = new List<OrderApi__Receipt_Line__c>();
        receiptLine.add(lines);
        
        Fon_SalesOrderCreditRefundCtrl.refundInvoiceLine(receiptlinesIds,true,true,invLine1);
        OrderApi__Receipt_Line__c rec1=[select id,Fon_Refund_Quantity__c from OrderApi__Receipt_Line__c where id=:lines.Id];
        system.assertEquals(2, rec1.Fon_Refund_Quantity__c);
        Fon_SalesOrderCreditRefundCtrl.ReceiptLineItemWrapper clt1 = new Fon_SalesOrderCreditRefundCtrl.ReceiptLineItemWrapper(lines);
        system.assert(clt1!=null);
        Fon_SalesOrderCreditRefundCtrl.refundReceiptLine(receiptlinesIds1,true,true,receiptLine);
        
        Test.stopTest();
    }
    
    public static testMethod void method1() {
        
        Account acct = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert acct;
        
        set<Id> contactID= new Set<Id>();
        
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
        insert so;
        
        
        OrderApi__Sales_Order__c so1 = (OrderApi__Sales_Order__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order__c', false); 
        so1.OrderApi__Account__c = acct.id;
        so1.OrderApi__Contact__c = con.id;
        so1.OrderApi__Posting_Entity__c = 'Receipt';
        insert so1;
        
        so1.OrderApi__Status__c='Closed';
        update so1;
        
        
        OrderApi__Sales_Order_Line__c sol1 = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false); 
        sol1.OrderApi__Sales_Order__c = so.id;
        sol1.OrderApi__Account__c = acct.id;
        sol1.OrderApi__Contact__c = con.id;
        sol1.OrderApi__Item__c = itm.id;
        sol1.OrderApi__Is_Subscription__c = true;       
        sol1.OrderApi__Is_Renewal__c=true;
        insert sol1;
        
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
        
        so.OrderApi__Status__c='Closed';
        so.OrderApi__Schedule_Type__c='Installment';
        update so;
        
        
        OrderApi__Invoice__c inv = (OrderApi__Invoice__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice__c', false); 
        inv.OrderApi__Contact__c=con.id;
        inv.OrderApi__Sales_Order__c=so.id;      
        inv.OrderApi__Amount_Paid__c=50;
        inv.OrderApi__Status__c='Draft';
        insert inv;
        
        list<OrderApi__Invoice_Line__c> invlist = new list<OrderApi__Invoice_Line__c>();
        
        OrderApi__Invoice_Line__c invline = (OrderApi__Invoice_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice_Line__c', false); 
        invline.OrderApi__Invoice__c=inv.Id;
        invline.OrderApi__Item__c=itm.Id;
        invlist.add(invline);
        insert invlist;
        
        
        OrderApi__Receipt__c rec = (OrderApi__Receipt__c)Fon_TestDataFactory.createSObject('OrderApi__Receipt__c', false);
        rec.OrderApi__Type__c='Payment';
        rec.OrderApi__Is_Posted__c=true;
        rec.OrderApi__Is_Payment__c = true;
        rec.OrderApi__Sales_Order__c=so1.Id;
        rec.OrderApi__Contact__c=con.Id;
        insert rec; 
        
        
        list<string> receiptlinesIds = new list<string>();
        
        OrderApi__Receipt_Line__c lines = (OrderApi__Receipt_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Receipt_Line__c', false); 
        lines.OrderApi__Receipt__c=rec.Id;
        lines.OrderApi__Item__c=itm.Id;
        lines.Fon_Refund_Quantity__c=2;
        lines.Fon_Refund_Amount__c=10;
        insert lines;
        receiptlinesIds.add(lines.Id);
        
        OrderApi__Receipt__c receipt = (OrderApi__Receipt__c)Fon_TestDataFactory.createSObject('OrderApi__Receipt__c', false);
        receipt.OrderApi__Type__c='Payment';
        receipt.Is_Credit_Memo_Existed__c=true;
        receipt.OrderApi__Is_Payment__c = true;
        insert receipt;  
        
        
        OrderApi__Receipt_Line__c receiptline = (OrderApi__Receipt_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Receipt_Line__c', false); 
        receiptline.OrderApi__Receipt__c=receipt.Id;
        insert receiptline; 
        
        
        OrderApi__Receipt__c receipt1 = (OrderApi__Receipt__c)Fon_TestDataFactory.createSObject('OrderApi__Receipt__c', false); 
        receipt1.OrderApi__Type__c='Refund';
        receipt1.OrderApi__Receipt__c = receipt.Id; 
        insert receipt1;
        
        
        OrderApi__Credit_Memo__c cmem = (OrderApi__Credit_Memo__c)Fon_TestDataFactory.createSObject('OrderApi__Credit_Memo__c', false); 
        cmem.Fon_Receipt__c = receipt.id;
        insert cmem;
        
        cmem.OrderApi__Status__c = 'Posted';
        update cmem;
        
        
        OrderApi__Transaction__c trans = (OrderApi__Transaction__c)Fon_TestDataFactory.createSObject('OrderApi__Transaction__c', false);
        trans.OrderApi__Credit_Memo__c = cmem.id;
        insert trans;
        
        Set<Id> cmIds = new Set<Id>();
        cmIds.add(cmem.id);
        
       Set<Id> oldTrans =new Set<Id>();
        
        OrderApi__Transaction__c trans1 = (OrderApi__Transaction__c)Fon_TestDataFactory.createSObject('OrderApi__Transaction__c', false);
        insert trans1;
        oldTrans.add(trans1.Id);
        
        
        Test.startTest();
        Boolean isValue ;
        isValue = Fon_CreateCreditAndRefund.getReceipts(receiptlinesIds,true,true);
        system.assertEquals(true, isValue);
        isValue = Fon_CreateCreditAndRefund.getReceipts(receiptlinesIds,true,false);
        system.assertEquals(true, isValue);
        Fon_deleteTransactionSchedule batch=new Fon_deleteTransactionSchedule(cmem.id,oldTrans);
        //Database.executeBatch(batch,1);
       // system.assertEquals(1, [select count() from OrderApi__Transaction__c where OrderApi__Credit_Memo__c =:cmem.ID]);
        Test.stopTest();
        
    }
}