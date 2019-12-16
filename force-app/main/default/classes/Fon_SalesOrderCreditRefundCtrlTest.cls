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
        lines.Fon_Refund_Amount__c=100;
        lines.Fon_Amount_Refunded__c=50;
        lines.OrderApi__Sales_Order_Line__c=soli.Id;
        insert lines;
        
        OrderApi__Receipt__c receipt1 = (OrderApi__Receipt__c)Fon_TestDataFactory.createSObject('OrderApi__Receipt__c', false); 
        receipt1.OrderApi__Type__c='Refund';
        receipt1.OrderApi__Receipt__c = rec.Id; 
        insert receipt1;
        
        
        
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
       
        
        Map<String,String> receiptLineIdVScancelSubscription =new Map<String,String>();
        receiptLineIdVScancelSubscription.put(lines.Id,'true');
        
        Fon_SalesOrderCreditRefundCtrl.refundInvoiceLine(receiptlinesIds,true,true,invLine1);
        OrderApi__Receipt_Line__c rec1=[select id,Fon_Refund_Quantity__c from OrderApi__Receipt_Line__c where id=:lines.Id];
        system.assertEquals(2, rec1.Fon_Refund_Quantity__c);
        Fon_SalesOrderCreditRefundCtrl.ReceiptLineItemWrapper clt1 = new Fon_SalesOrderCreditRefundCtrl.ReceiptLineItemWrapper(lines,300,200,true,'test',lines.Id);
        system.assert(clt1!=null);
        Fon_SalesOrderCreditRefundCtrl.refundReceiptLine(receiptlinesIds1,true,true,receiptLine,receiptLineIdVScancelSubscription);
         Fon_SalesOrderCreditRefundCtrl.refundReceiptLine(receiptlinesIds1,true,false,receiptLine,receiptLineIdVScancelSubscription);
        Test.stopTest();
    }

}