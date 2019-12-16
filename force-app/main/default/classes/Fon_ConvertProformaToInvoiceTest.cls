@isTest
public class Fon_ConvertProformaToInvoiceTest{
    
    @isTest
    public static void method1(){
        
        
        Account acct = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert acct;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        insert con;
        
        OrderApi__Sales_Order__c so = (OrderApi__Sales_Order__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order__c', false); 
        so.OrderApi__Account__c = acct.id;
        so.OrderApi__Contact__c = con.id;
        insert so;
        
        OrderApi__Item_Class__c itmClass = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false);
        itmClass.OrderApi__Is_Subscription__c = true;		
        insert itmClass;
        
        OrderApi__Item__c itm = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm.OrderApi__Item_Class__c = itmClass.Id;
        itm.OrderApi__Is_Active__c = false;
        itm.OrderApi__Price__c = 15;
        insert itm;
        
        OrderApi__Subscription_Plan__c subPlan = (OrderApi__Subscription_Plan__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription_Plan__c', false); 
        subPlan.OrderApi__Type__c = 'Termed';
        subPlan.OrderApi__Initial_Term_Months__c = 12;
        subPlan.OrderApi__Renewal_Term_Months__c = 12;
        subPlan.OrderApi__Is_Active__c = true;
        subPlan.OrderApi__Enable_Schedule__c=true;
        subPlan.OrderApi__Schedule_Frequency__c='Monthly';
        insert subPlan;
        
        OrderApi__Sales_Order_Line__c sol1 = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false); 
        sol1.OrderApi__Sales_Order__c = so.id;
        sol1.OrderApi__Account__c = acct.id;
        sol1.OrderApi__Contact__c = con.id;
        sol1.OrderApi__Subscription_Plan__c = subPlan.Id;
        sol1.OrderApi__Item__c = itm.id;
        insert sol1;
        
        so.OrderApi__Status__c='Closed';
        update so;
        
        Map<String,String> errorVSmsg = new Map<String,String>();
        Test.startTest();
        try{
            errorVSmsg = Fon_ConvertProformaToInvoiceController.convertProformaInvoice(so.Id);
            system.assertEquals(null, errorVSmsg.get('true'));
        }
        catch (Exception e) {
            String exceptionMessage = e.getMessage();
        }
        Test.stopTest();          
    }
    
    
}