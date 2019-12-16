@isTest
public class Fon_SalesOrderWrapper_Test {
     /*public static testMethod void method() {
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
        itm.Is_Foundation_Donation__c=false;
        itm.Fon_Is_PAC_Item__c=false;
        itm.OrderApi__Item_Class__c=itmClassMain.Id;
        insert itm;
        
        OrderApi__Sales_Order__c so1 = new OrderApi__Sales_Order__c();
        so1.OrderApi__Account__c = ac.id;
        so1.OrderApi__Contact__c = con.id;
        so1.OrderApi__Entity__c = 'Account';
        so1.OrderApi__Posting_Entity__c = 'Invoice';
        insert so1;
        
        so1.OrderApi__Status__c='Closed';
        update so1;

        OrderApi__Sales_Order_Line__c soli = new OrderApi__Sales_Order_Line__c();
        soli.OrderApi__Sales_Order__c = so1.id;
        soli.OrderApi__Account__c = ac.id;
        soli.OrderApi__Contact__c = con.id;
        soli.OrderApi__Item__c = itm.id;
        insert soli;
        
        OrderApi__Invoice__c inv = new OrderApi__Invoice__c();
        inv.OrderApi__Invoice_Date__c=System.today();
        inv.OrderApi__Contact__c=con.id;
        inv.OrderApi__Sales_Order__c=so1.id;
        inv.OrderApi__Is_Posted__c=true;
        insert inv;
        
        
        
        Test.startTest();
        Fon_SalesOrderWrapper ff=new Fon_SalesOrderWrapper(so1);
        Fon_SalesOrderWrapper tt=new Fon_SalesOrderWrapper(inv);
        Test.stopTest();
    }*/
}