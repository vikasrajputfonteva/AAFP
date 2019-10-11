@isTest
public class Fon_QuickPayMainFrameCtrl_test {
    public static testMethod void method() {
        
        Account ac = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        ac.AAFP_ID__c = '1';
        insert ac;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        con.AccountId=ac.Id;
        insert con;
        
        OrderApi__Item_Class__c itmClassMain = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClassMain.OrderApi__Is_Active__c = true;
        insert itmClassMain;
        
        OrderApi__Item__c itm = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm.OrderApi__Item_Class__c = itmClassMain.Id;
        itm.Fon_Is_PAC_Item__c=true;
        itm.OrderApi__Price__c = 15;
        insert itm; 
        
        OrderApi__Item__c itm1 = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm1.Is_Foundation_Donation__c=true;
        itm1.OrderApi__Item_Class__c=itmClassMain.Id;
        itm1.OrderApi__Price__c = 15;
        insert itm1;    
        
        OrderApi__Sales_Order__c so = (OrderApi__Sales_Order__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order__c', false); 
        so.OrderApi__Account__c = ac.id;
        so.OrderApi__Contact__c = con.id;
        so.OrderApi__Posting_Entity__c = 'Invoice';
        insert so;
        
        OrderApi__Sales_Order_Line__c sol1 = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false); 
        sol1.OrderApi__Sales_Order__c = so.id;
        sol1.OrderApi__Account__c = ac.id;
        sol1.OrderApi__Contact__c = con.id;
        sol1.OrderApi__Item__c = itm.id;
        insert sol1;
        
        so.OrderApi__Status__c='Closed';
        update so;
        
        so.OrderApi__Posting_Status__c='posted';
        update so;
        
        
        OrderApi__Sales_Order__c salesOrder=[select name from OrderApi__Sales_Order__c where Id =:so.Id];
        
        
        OrderApi__Invoice__c inv = (OrderApi__Invoice__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice__c', false); 
        inv.OrderApi__Contact__c=con.id;
        inv.OrderApi__Sales_Order__c=so.id;
        insert inv;
        
        
        
        OrderApi__Invoice_Line__c invline = (OrderApi__Invoice_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice_Line__c', false); 
        invline.OrderApi__Invoice__c=inv.Id;
        invline.OrderApi__Item__c=itm.Id;
        invline.OrderApi__Sales_Order_Line__c=sol1.Id;
        
        insert invline;
        
        
        List<OrderApi__Invoice__c> lstInvoice = new List<OrderApi__Invoice__c>();
        lstInvoice.add(inv);
        
        Test.startTest();
        Fon_SalesOrderWrapper ff=new Fon_SalesOrderWrapper(so);
        ff.lstInvoice = lstInvoice;
        Fon_SalesOrderWrapper wrapper=Fon_QuickPayMainFrameCtrl.rectifySalesOrderData(ff);
        system.assert(wrapper!=null);
        OrderApi__Sales_Order_Line__c SOLI=Fon_QuickPayMainFrameCtrl.createSoli(so.Id);
        system.assert(SOLI!=null);
        Fon_QuickPayMainFrameCtrl.fetchSalesOrderList();
        Fon_QuickPayMainFrameCtrl.fetchSalesOrder1(1,salesOrder.Name);
        Test.stopTest();
    } 
    
    @isTest
    public static void method1(){
        
        
        Account ac = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        ac.AAFP_ID__c = '1';
        insert ac;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        con.AccountId= ac.Id;
        insert con;
        
        OrderApi__Item_Class__c itmClassMain = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClassMain.OrderApi__Is_Active__c = true;
        insert itmClassMain;
        
        OrderApi__Item__c itm = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm.OrderApi__Item_Class__c = itmClassMain.Id;
        itm.Fon_Is_PAC_Item__c=true;
        itm.OrderApi__Price__c = 15;
        insert itm; 
        
        
        OrderApi__Item__c itm1 = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm1.Is_Foundation_Donation__c=true;
        itm1.OrderApi__Item_Class__c=itmClassMain.Id;
        itm1.OrderApi__Price__c = 15;
        insert itm1;    
        
        OrderApi__Price_Rule__c pacFoundation = new OrderApi__Price_Rule__c();
        pacFoundation.OrderApi__Is_Active__c=true;
        pacFoundation.OrderApi__Is_Default__c=true;
        pacFoundation.OrderApi__Item__c=itm1.Id;
        pacFoundation.OrderApi__Price__c=70;
        insert pacFoundation;
        
        
        OrderApi__Item_Class__c itmClassMain1 = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClassMain1.OrderApi__Is_Active__c = true;
        itmClassMain1.OrderApi__Is_Subscription__c=true;
        itmClassMain1.Fon_Is_Main_Membership__c=true;
        insert itmClassMain1;
        
        OrderApi__Item__c ActiveMembershipItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        ActiveMembershipItem.OrderApi__Item_Class__c=itmClassMain1.Id;
        ActiveMembershipItem.OrderApi__Is_Subscription__c=true;
        ActiveMembershipItem.OrderApi__Price__c=500;
        ActiveMembershipItem.OrderApi__Is_Active__c=true;
        insert ActiveMembershipItem;    
        
        
        OrderApi__Sales_Order__c so = (OrderApi__Sales_Order__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order__c', false); 
        so.OrderApi__Account__c = ac.id;
        so.OrderApi__Contact__c = con.id;
        so.OrderApi__Posting_Entity__c = 'Invoice';
        insert so;
        
        OrderApi__Sales_Order_Line__c soli = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false); 
        soli.OrderApi__Sales_Order__c = so.id;
        soli.OrderApi__Account__c = ac.id;
        soli.OrderApi__Contact__c = con.id;
        soli.OrderApi__Item__c = ActiveMembershipItem.id;
        soli.OrderApi__Item_Class__c=itmClassMain1.Id;
        insert soli;
        
        OrderApi__Sales_Order_Line__c soli1 = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false); 
        soli1.OrderApi__Sales_Order__c = so.id;
        soli1.OrderApi__Account__c = ac.id;
        soli1.OrderApi__Contact__c = con.id;
        soli1.OrderApi__Item__c = itm.id;
        insert soli1;
        
        OrderApi__Sales_Order_Line__c soli2 = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false); 
        soli2.OrderApi__Sales_Order__c = so.id;
        soli2.OrderApi__Account__c = ac.id;
        soli2.OrderApi__Contact__c = con.id;
        soli2.OrderApi__Item__c = itm1.id;
        insert soli2;
        
        
        OrderApi__Sales_Order__c so1 = (OrderApi__Sales_Order__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order__c', false); 
        so1.OrderApi__Account__c = ac.id;
        so1.OrderApi__Contact__c = con.id;
        so1.OrderApi__Posting_Entity__c = 'Invoice';
        insert so1;
        
        OrderApi__Sales_Order_Line__c soli3 = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false); 
        soli3.OrderApi__Sales_Order__c = so1.id;
        soli3.OrderApi__Account__c = ac.id;
        soli3.OrderApi__Contact__c = con.id;
        soli3.OrderApi__Item__c = ActiveMembershipItem.id;
        soli3.OrderApi__Item_Class__c=itmClassMain1.Id;
        insert soli3;
        
        
        
        OrderApi__Invoice__c inv = (OrderApi__Invoice__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice__c', false); 
        inv.OrderApi__Contact__c=con.id;
        inv.OrderApi__Sales_Order__c=so.id;
        insert inv;
        
        
        
        OrderApi__Invoice_Line__c invLine = (OrderApi__Invoice_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice_Line__c', false); 
        invLine.OrderApi__Invoice__c=inv.Id;
        invLine.OrderApi__Item__c=ActiveMembershipItem.id;
        invLine.OrderApi__Sale_Price__c=500;
        invLine.OrderApi__Quantity__c=1;
        insert invLine;
        
        Test.startTest();
        
        OrderApi__Sales_Order__c salesOrder=[select name from OrderApi__Sales_Order__c where Id =:so.Id];
        OrderApi__Sales_Order__c salesOrder1=[select name from OrderApi__Sales_Order__c where Id =:so1.Id];
        Fon_QuickPayMainFrameCtrl.fetchSalesOrder1(1,salesOrder.Name);
        Fon_QuickPayMainFrameCtrl.fetchSalesOrder1(1,salesOrder1.Name);
        so.OrderApi__Status__c='Closed';
        update so;
        
        so1.OrderApi__Status__c='Closed';
        update so1;
        
        OrderApi__Sales_Order__c salesOrder2=[select name from OrderApi__Sales_Order__c where Id =:so.Id];
        OrderApi__Sales_Order__c salesOrder3=[select name from OrderApi__Sales_Order__c where Id =:so1.Id];
        Fon_QuickPayMainFrameCtrl.fetchSalesOrder1(1,salesOrder2.Name);
        Fon_QuickPayMainFrameCtrl.fetchSalesOrder1(1,salesOrder3.Name);
        so.OrderApi__Posting_Status__c='Posted';
        so.OrderApi__Is_Posted__c=true;
        update so;
        
        so1.OrderApi__Posting_Status__c='Posted';
        so1.OrderApi__Is_Posted__c=true;
        update so1;
        
        OrderApi__Sales_Order__c salesOrder4=[select name from OrderApi__Sales_Order__c where Id =:so.Id];
        OrderApi__Sales_Order__c salesOrder5=[select name from OrderApi__Sales_Order__c where Id =:so1.Id];        
        Fon_QuickPayMainFrameCtrl.fetchSalesOrder1(1,salesOrder4.Name);
        Fon_QuickPayMainFrameCtrl.fetchSalesOrder1(1,salesOrder5.Name);
        Boolean value1=Fon_QuickPayMainFrameCtrl.isSingleInvoice(inv.Id);
        system.assertEquals(true, value1);
        Boolean value2=Fon_QuickPayMainFrameCtrl.isSingleInvoice('ddddd');
        system.assertEquals(false, value2);
        Boolean value3=Fon_QuickPayMainFrameCtrl.isSingleInvoice(inv.Id+','+inv.Id);
        system.assertEquals(false, value3);
        string salesId = salesOrder.id;
        salesId = '"'+salesId+'"';
        string conId = con.Id;
        conId ='"'+conId+'"';
        string itemClassID = itmClassMain.Id;
        itemClassID ='"'+itemClassID+'"';
        string itemID = ActiveMembershipItem.Id;
        itemID ='"'+itemID+'"';     
        string invId = inv.id;
        invId ='"'+invId+'"';
        string sOlID = soli.id;
        sOlID ='"'+sOlID+'"';
        string invLin = invLine.id;
        invLin ='"'+invLin+'"';
        string priceRule = pacFoundation.id;
        priceRule ='"'+priceRule+'"';
        String jsn='[{"hasBalanceDueInvoice":true,"invoicesTotalDueAmount":0,"isInvoice":false,"lstInvoice":[{"OrderApi__Sales_Order__c":'+salesId+',"Id":'+invId+',"OrderApi__Is_Posted__c":true,"OrderApi__Balance_Due__c":650}],"lstSOLI":[{"hasDonation":false,"hasPACDonation":false,"isFoundationDonation":false,"isPACItem":false,"objSOLI":{"OrderApi__Sales_Order__c":'+salesId+',"Id":'+sOlID+',"OrderApi__Item__c":'+itemID+',"OrderApi__Sale_Price__c":500,"OrderApi__Total__c":500,"OrderApi__Item_Class__c":'+itemClassID+',"OrderApi__Contact__c":'+conId+',"OrderApi__Item__r":{"Id":'+itemID+',"Name":"Active Membership","Fon_Is_PAC_Item__c":false,"Is_Foundation_Donation__c":false},"OrderApi__Item_Class__r":{"Fon_Is_Main_Membership__c":true,"Id":'+itemClassID+'},"OrderApi__Contact__r":{"Id":'+conId+',"Name":"rsi json"}},"salesPriceAmount":500,"strAccountType":"Corporate","strItemName":"Active Membership"},{"donationPACAmount":0,"hasDonation":false,"hasPACDonation":false,"isFoundationDonation":false,"isPACItem":true,"objSOLI":{"OrderApi__Sales_Order__c":'+salesId+',"OrderApi__Item__c":'+itemID+',"OrderApi__Item_Class__c":'+itemClassID+',"OrderApi__Price_Rule__c":'+priceRule+'},"salesPriceAmount":"50","strAccountType":"Corporate","strItemName":"PAC Donation","strEmployeeName":"df","strOccupation":"f"},{"hasDonation":false,"hasPACDonation":false,"isFoundationDonation":true,"isPACItem":false,"objSOLI":{"OrderApi__Sales_Order__c":'+ salesId+',"OrderApi__Item__c":'+itemID+',"OrderApi__Item_Class__c":'+itemClassID+',"OrderApi__Price_Rule__c":'+priceRule+'},"salesPriceAmount":50,"strAccountType":"Corporate","strItemName":"AAFP Foundation Voluntary Contribution"}],"objAdjustmentInvoice":'+invId+',"parentInvoiceLine":'+invLin+',"strBGColor":"whitesmoke","strSOID":'+salesId+',"strSOName":"000001597","totalAmount":600}]"';
        System.debug('jsn..'+jsn);
        Fon_QuickPayMainFrameCtrl.manageSalesOrderAndInvoice(jsn,'test@gmail.com');
        Test.stopTest();
    }
    
    @isTest
    public static void method2(){
        
         Account ac = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        ac.AAFP_ID__c = '1';
        insert ac;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        con.AccountId=ac.Id;
        insert con;
        
        
        OrderApi__Item_Class__c itmClassMain = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClassMain.OrderApi__Is_Active__c = true;
        itmClassMain.Fon_Is_Main_Membership__c=true;
        itmClassMain.OrderApi__Is_Subscription__c=true;
        
        insert itmClassMain;
        
        OrderApi__Item_Class__c itmClassMain1 = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClassMain1.OrderApi__Is_Active__c = true;
        
        insert itmClassMain1;
        
        OrderApi__Item__c ActiveMembershipItem = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        ActiveMembershipItem.OrderApi__Item_Class__c=itmClassMain.Id;
        ActiveMembershipItem.OrderApi__Is_Subscription__c=true;
        ActiveMembershipItem.OrderApi__Price__c=500;
        ActiveMembershipItem.OrderApi__Is_Active__c=true;
        insert ActiveMembershipItem;    
        
        OrderApi__Item__c itm = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm.OrderApi__Item_Class__c = itmClassMain.Id;
        itm.Fon_Is_PAC_Item__c=true;
        itm.OrderApi__Price__c = 15;
        insert itm; 
        
        OrderApi__Item__c itm1 = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm1.Is_Foundation_Donation__c=true;
        itm1.OrderApi__Item_Class__c=itmClassMain.Id;
        itm1.OrderApi__Price__c = 15;
        insert itm1;    
        
        OrderApi__Item__c itmPac = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itmPac.OrderApi__Item_Class__c = itmClassMain1.Id;
        itmPac.Fon_Is_PAC_Item__c=true;
        itmPac.OrderApi__Price__c = 15;
        insert itmPac;  
        
        
        OrderApi__Sales_Order__c so = (OrderApi__Sales_Order__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order__c', false); 
        so.OrderApi__Account__c = ac.id;
        so.OrderApi__Contact__c = con.id;
        so.OrderApi__Posting_Entity__c = 'Receipt';
        insert so;
        
        OrderApi__Sales_Order_Line__c sol1 = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false); 
        sol1.OrderApi__Sales_Order__c = so.id;
        sol1.OrderApi__Account__c = ac.id;
        sol1.OrderApi__Contact__c = con.id;
        sol1.OrderApi__Item__c = ActiveMembershipItem.id;
        sol1.OrderApi__Item_Class__c= itmClassMain.Id;
        insert sol1;
        
        
        OrderApi__Sales_Order__c so1 = (OrderApi__Sales_Order__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order__c', false); 
        so1.OrderApi__Account__c = ac.id;
        so1.OrderApi__Contact__c = con.id;
        so1.OrderApi__Posting_Entity__c = 'Receipt';
        insert so1;
        
        OrderApi__Sales_Order_Line__c soli = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false); 
        soli.OrderApi__Sales_Order__c = so1.id;
        soli.OrderApi__Account__c = ac.id;
        soli.OrderApi__Contact__c = con.id;
        soli.OrderApi__Item__c = ActiveMembershipItem.id;
        soli.OrderApi__Item_Class__c= itmClassMain.Id;
        insert soli;
        
        OrderApi__Sales_Order_Line__c sol31 = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false); 
        sol31.OrderApi__Sales_Order__c = so1.id;
        sol31.OrderApi__Account__c = ac.id;
        sol31.OrderApi__Contact__c = con.id;
        sol31.OrderApi__Item__c = itm.id;
        insert sol31;
        
        OrderApi__Sales_Order_Line__c sol4 = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false); 
        sol4.OrderApi__Sales_Order__c = so1.id;
        sol4.OrderApi__Account__c = ac.id;
        sol4.OrderApi__Contact__c = con.id;
        sol4.OrderApi__Item__c = itm1.id;
        insert sol4;
        
        OrderApi__Sales_Order_Line__c sol5 = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false); 
        sol5.OrderApi__Sales_Order__c = so1.id;
        sol5.OrderApi__Account__c = ac.id;
        sol5.OrderApi__Contact__c = con.id;
        sol5.OrderApi__Item__c = itmPac.id;
        insert sol5;
        
        OrderApi__Sales_Order__c so2 = (OrderApi__Sales_Order__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order__c', false); 
        so2.OrderApi__Account__c = ac.id;
        so2.OrderApi__Contact__c = con.id;
        so2.OrderApi__Posting_Entity__c = 'Receipt';
        insert so2;
        
        OrderApi__Sales_Order_Line__c sol6 = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false); 
        sol6.OrderApi__Sales_Order__c = so2.id;
        sol6.OrderApi__Account__c = ac.id;
        sol6.OrderApi__Contact__c = con.id;
        sol6.OrderApi__Item__c = ActiveMembershipItem.id;
        sol6.OrderApi__Item_Class__c= itmClassMain.Id;
        insert sol6;
        
        
        
        so.OrderApi__Status__c='Closed';
        update so;
        
        so.OrderApi__Posting_Status__c='Posted';
        so.OrderApi__Is_Posted__c=true;
        update so;
        
        OrderApi__Invoice__c inv = (OrderApi__Invoice__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice__c', false); 
        inv.OrderApi__Contact__c=con.id;
        inv.OrderApi__Sales_Order__c=so.id;
        inv.OrderApi__Amount_Paid__c=200;
        insert inv;
        
        
        
        OrderApi__Invoice_Line__c invLine = (OrderApi__Invoice_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice_Line__c', false); 
        invLine.OrderApi__Invoice__c=inv.Id;
        invLine.OrderApi__Item__c=ActiveMembershipItem.id;
        invLine.OrderApi__Sale_Price__c=500;
        invLine.OrderApi__Quantity__c=1;
        insert invLine;
        
        OrderApi__Receipt__c rec=(OrderApi__Receipt__c)Fon_TestDataFactory.createSObject('OrderApi__Receipt__c', false);
        rec.OrderApi__Sales_Order__c=so.Id;
        insert rec;
        
        Test.startTest();
        
        
        
        so1.OrderApi__Status__c='Closed';
        update so1;
        
        so2.OrderApi__Status__c='Closed';
        update so2;
        
        OrderApi__Sales_Order__c salesOrder1=[select name from OrderApi__Sales_Order__c where Id =:so.Id];
        OrderApi__Sales_Order__c salesOrder2=[select name from OrderApi__Sales_Order__c where Id =:so1.Id];
        OrderApi__Sales_Order__c salesOrder3=[select name from OrderApi__Sales_Order__c where Id =:so2.Id];
        Fon_SalesOrderWrapper wrapper1 = Fon_QuickPayMainFrameCtrl.fetchSalesOrder1(1,salesOrder1.Name);
        Fon_SalesOrderWrapper wrapper2 = Fon_QuickPayMainFrameCtrl.fetchSalesOrder1(1,salesOrder2.Name);
        Fon_SalesOrderWrapper wrapper3 = Fon_QuickPayMainFrameCtrl.fetchSalesOrder1(1,salesOrder3.Name);
        system.assert(wrapper1!=null);
        system.assert(wrapper2!=null);
        system.assert(wrapper3!=null);
        Fon_SalesOrderLineItemWrapper fonWrapper =new Fon_SalesOrderLineItemWrapper(invLine);
        Fon_SalesOrderLineItemWrapper fonWrapper1=new Fon_SalesOrderLineItemWrapper(invLine,ActiveMembershipItem);
        Fon_SalesOrderWrapper wrap= new Fon_SalesOrderWrapper(inv);
        Test.stopTest();
    }
}