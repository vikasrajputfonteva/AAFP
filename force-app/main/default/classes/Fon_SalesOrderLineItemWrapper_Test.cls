@isTest
public class Fon_SalesOrderLineItemWrapper_Test {
    /*public static OrderApi__Sales_Order_Line__c soli;
    public static testMethod void method() {
        
         Account ac= new Account();
        ac.Name='testAccount';
        Insert ac;
        
        Contact con= new Contact();
        con.AccountId= ac.Id;
        con.LastName= 'testLast';
        
        con.Fon_Total_Months_of_Membership__c=10;
        con.Fon_Chapter_Change_Needed__c=true;
        con.Fon_Current_Membership_Status__c='Inactive';
        insert con;
        
        OrderApi__Item_Class__c itmClassMain= new OrderApi__Item_Class__c();
        itmClassMain.Fon_Is_Main_Membership__c=true;
        itmClassMain.OrderApi__Is_Active__c=true;
        insert itmClassMain;
        
        OrderApi__Item__c itm = new OrderApi__Item__c();
        itm.Name='Membership California Dues';
        itm.Fon_Is_PAC_Item__c=true;
        itm.OrderApi__Item_Class__c=itmClassMain.Id;
        insert itm;
        
        OrderApi__Item__c itm1 = new OrderApi__Item__c();
        itm1.Name='Membership California Dues';
        itm1.Is_Foundation_Donation__c=true;
        itm1.Name='Membership California Dues';
        itm1.OrderApi__Item_Class__c=itmClassMain.Id;
        insert itm1;
        
        
        
        OrderApi__Sales_Order__c so1 = new OrderApi__Sales_Order__c();
        so1.OrderApi__Account__c = ac.id;
        so1.OrderApi__Contact__c = con.id;
        so1.OrderApi__Entity__c = 'Account';
        so1.OrderApi__Posting_Entity__c = 'Invoice';
        insert so1;
        
        so1.OrderApi__Status__c='Closed';
        update so1;

         soli = new OrderApi__Sales_Order_Line__c();
        soli.OrderApi__Sales_Order__c = so1.id;
        soli.OrderApi__Account__c = ac.id;
        soli.OrderApi__Contact__c = con.id;
        soli.OrderApi__Item__c = itm.id;
        insert soli;
        
        OrderApi__Sales_Order_Line__c soli1 = new OrderApi__Sales_Order_Line__c();
        soli1.OrderApi__Sales_Order__c = so1.id;
        soli1.OrderApi__Account__c = ac.id;
        soli1.OrderApi__Contact__c = con.id;
        soli1.OrderApi__Item__c = itm1.id;
        insert soli1;
        
        OrderApi__Invoice__c inv = new OrderApi__Invoice__c();
        inv.OrderApi__Invoice_Date__c=System.today();
        inv.OrderApi__Contact__c=con.id;
        inv.OrderApi__Sales_Order__c=so1.id;
        inv.OrderApi__Is_Posted__c=true;
        insert inv;
        
        OrderApi__Invoice_Line__c invline= new OrderApi__Invoice_Line__c();
        invline.OrderApi__Invoice__c=inv.Id;
        invline.OrderApi__Item__c=itm.Id;
        invline.OrderApi__Sale_Price__c=100;
        invline.OrderApi__Quantity__c=1;
        invline.OrderApi__Price_Override__c=true;
        insert invline;
        
        OrderApi__Invoice_Line__c invline1= new OrderApi__Invoice_Line__c();
        invline1.OrderApi__Invoice__c=inv.Id;
        invline1.OrderApi__Item__c=itm1.Id;
        invline1.OrderApi__Sale_Price__c=0;
        invline1.OrderApi__Quantity__c=1;
        invline1.OrderApi__Price_Override__c=true;
        insert invline1;
        
        
        Test.startTest();
        Fon_SalesOrderLineItemWrapper mm=new Fon_SalesOrderLineItemWrapper();
        Fon_SalesOrderLineItemWrapper wr=new Fon_SalesOrderLineItemWrapper(soli);
        Fon_SalesOrderLineItemWrapper tt=new Fon_SalesOrderLineItemWrapper(soli,itm,itm.ID,itm.ID);
        Fon_SalesOrderLineItemWrapper tt1=new Fon_SalesOrderLineItemWrapper(soli,itm1,null,null);
        Fon_SalesOrderLineItemWrapper kk=new Fon_SalesOrderLineItemWrapper(invline);
        Fon_SalesOrderLineItemWrapper nn=new Fon_SalesOrderLineItemWrapper(invline,itm);
        Fon_SalesOrderLineItemWrapper nn1=new Fon_SalesOrderLineItemWrapper(invline,itm1);
        Test.stopTest();
    }*/
}