@isTest
public class Fon_QuickConfirm_Class_Test {
    public static testMethod void method1() {
        
        
        string name='abc';
        string amount='123';
        string cusEmail='Test@test.com';
        
        
        Account ac = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert ac;
        
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        con.Email = 'test1@gmail.com';
        insert con;
        
        
        
        OrderApi__Item_Class__c itmClassMain = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClassMain.Fon_Is_Main_Membership__c=true;
        itmClassMain.OrderApi__Is_Active__c=true;
        insert itmClassMain;
        
        
        OrderApi__Item__c itm = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm.OrderApi__Item_Class__c = itmClassMain.Id;
        itm.OrderApi__Price__c = 15;
        insert itm;	
        
        
        
        OrderApi__Sales_Order__c so = (OrderApi__Sales_Order__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order__c', false); 
        so.OrderApi__Account__c = ac.id;
        so.OrderApi__Contact__c = con.id;
        so.OrderApi__Entity__c = 'Contact';
        so.Fon_Payee_Email__c = cusEmail;
        insert so;
        
        
        OrderApi__Sales_Order_Line__c soli = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false); 
        soli.OrderApi__Sales_Order__c = so.id;
        soli.OrderApi__Account__c = ac.id;
        soli.OrderApi__Contact__c = con.id;
        soli.OrderApi__Item__c = itm.id;
        insert soli;
        
        
        so.OrderApi__Status__c='Closed';
        update so;
        
        
        list<string> st=new list<string>();
        
        OrderApi__Receipt__c rec = (OrderApi__Receipt__c)Fon_TestDataFactory.createSObject('OrderApi__Receipt__c', false); 
        rec.OrderApi__Sales_Order__c=so.Id;
        rec.OrderApi__Contact__c=con.Id;
        rec.OrderApi__Account__c = ac.id;
        insert rec;
        st.add(rec.Id);
        
        
        OrderApi__Receipt__c rec1 = (OrderApi__Receipt__c)Fon_TestDataFactory.createSObject('OrderApi__Receipt__c', false); 
        rec1.OrderApi__Sales_Order__c=so.Id;
        rec1.OrderApi__Contact__c=con.Id;
        rec1.OrderApi__Account__c = ac.id;
        insert rec1;
        st.add(rec1.Id);
        
        
        
        list<OrderApi__Receipt_Line__c> receiptlinesIds=new list<OrderApi__Receipt_Line__c>();			
        OrderApi__Receipt_Line__c lines = (OrderApi__Receipt_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Receipt_Line__c', false); 
        lines.OrderApi__Receipt__c=rec.Id;
        lines.OrderApi__Item__c=itm.Id;
        lines.OrderApi__Contact__c = con.id;
        insert lines;
        receiptlinesIds.add(lines);
        
        string s1 = 'test record';
        Blob tempBlob = Blob.valueOf(s1);
        
        Test.startTest();
        try{
            list<OrderApi__Receipt_Line__c> receiptlist=Fon_QuickConfirm_Class.receiptLineData(st,name,amount);
            system.assert(receiptlist.size()>0);
        }
        
        catch(Exception e){
            String exceptionMessage = e.getMessage(); 
        }
        Test.stopTest();
    }
    
    public static testMethod void method2() {
        string name='abc';
        string amount='123';
        string cusEmail='Test@test.com';
        
        
        
        Account ac = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert ac;
        
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        con.Email='abc@gmail.com';
        insert con;
        
        
        
        OrderApi__Item_Class__c itmClassMain = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClassMain.Fon_Is_Main_Membership__c=true;
        itmClassMain.OrderApi__Is_Active__c=true;
        insert itmClassMain;
        
        OrderApi__Item__c itm = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm.OrderApi__Item_Class__c = itmClassMain.Id;
        itm.OrderApi__Price__c = 15;
        insert itm;	
        
        
        
        
        OrderApi__Sales_Order__c so = (OrderApi__Sales_Order__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order__c', false); 
        so.OrderApi__Account__c = ac.id;
        so.OrderApi__Contact__c = con.id;
        so.OrderApi__Entity__c = 'Contact';
        so.Fon_Payee_Email__c = cusEmail;
        insert so;
        
        
        OrderApi__Sales_Order_Line__c soli = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false); 
        soli.OrderApi__Sales_Order__c = so.id;
        soli.OrderApi__Account__c = ac.id;
        soli.OrderApi__Contact__c = con.id;
        soli.OrderApi__Item__c = itm.id;
        insert soli;
        
        
        so.OrderApi__Status__c='Closed';
        update so;
        
        
        list<string> st=new list<string>();
        
        
        OrderApi__Receipt__c rec = (OrderApi__Receipt__c)Fon_TestDataFactory.createSObject('OrderApi__Receipt__c', false); 
        rec.OrderApi__Sales_Order__c=so.Id;
        rec.OrderApi__Contact__c=con.Id;
        rec.OrderApi__Account__c = ac.id;
        insert rec;
        st.add(rec.Id);
        
        
        
        OrderApi__Receipt__c rec1 = (OrderApi__Receipt__c)Fon_TestDataFactory.createSObject('OrderApi__Receipt__c', false); 
        rec1.OrderApi__Sales_Order__c=so.Id;
        rec1.OrderApi__Contact__c=con.Id;
        rec1.OrderApi__Account__c = ac.id;
        insert rec1;
        st.add(rec1.Id);
        
        list<OrderApi__Receipt_Line__c> receiptlinesIds=new list<OrderApi__Receipt_Line__c>();			
        OrderApi__Receipt_Line__c lines = (OrderApi__Receipt_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Receipt_Line__c', false); 
        lines.OrderApi__Receipt__c=rec.Id;
        lines.OrderApi__Item__c=itm.Id;
        lines.OrderApi__Contact__c = con.id;
        lines.OrderApi__Sales_Order_Line__c=soli.Id;
        insert lines;
        receiptlinesIds.add(lines);
        
        string s1 = 'test record';
        Blob tempBlob = Blob.valueOf(s1);
        
        Test.startTest();
        try{
            list<OrderApi__Receipt_Line__c> receiptlist=Fon_QuickConfirm_Class.receiptLineData(st,name,amount);
            system.assert(receiptlist.size()>0);
        }
        catch(Exception e){
            String exceptionMessage = e.getMessage(); 
        }
        Test.stopTest();
    }
    
}