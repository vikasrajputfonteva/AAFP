@isTest
public class Fon_SelfServicePortalControllerTest {
    @isTest
    public static void method1(){
        Account ac = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert ac;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        con.AccountId=ac.Id;
        con.Fon_AAFP_Subscription_Plan_Picklist__c='Installment';
        con.Fon_No_of_Remaining_installments__c=3;
        con.Fon_Next_Payment_Month__c=2;
        con.Email='twst@gmail.com';
        insert con;
        
        OrderApi__Payment_Method__c pm = (OrderApi__Payment_Method__c)Fon_TestDataFactory.createSObject('OrderApi__Payment_Method__c', false); 
        pm.OrderApi__Contact__c= con.Id;
        pm.OrderApi__Is_Active__c= true;
        pm.OrderApi__Is_Valid__c= true;
        pm.OrderApi__Year__c = 2020;
        pm.OrderApi__Month__c = 06;        
        pm.OrderApi__Card_Type__c = 'visa';
        
        pm.OrderApi__Number__c='1010-0101-1010-1010';
        insert pm;
        
        OrderApi__Item_Class__c itmClass = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClass.OrderApi__Is_Active__c=true;
        insert itmClass;
        
        OrderApi__Item__c itm = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm.OrderApi__Item_Class__c=itmClass.Id;
        itm.OrderApi__Price__c=100;
        itm.Is_Foundation_Donation__c=true;
        insert itm;
        
        OrderApi__Item__c item = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        item.OrderApi__Item_Class__c=itmClass.Id;
        item.OrderApi__Price__c=100;
        item.Fon_Is_PAC_Item__c=true;
        insert item;
        
        OrderApi__Item_Class__c itmClassMain = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClassMain.Fon_Is_Main_Membership__c=true;
        itmClassMain.OrderApi__Is_Active__c=true;
        insert itmClassMain;
        
        OrderApi__Item__c itm1 = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm1.OrderApi__Item_Class__c=itmClassMain.Id;
        itm1.OrderApi__Price__c=100;
        insert itm1;
        
        OrderApi__Subscription_Plan__c plan1 = (OrderApi__Subscription_Plan__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription_Plan__c', false);
        plan1.OrderApi__Type__c='Calendar';
        plan1.OrderApi__Is_Active__c=true;
        insert plan1;
        
        
        OrderApi__Sales_Order__c so = (OrderApi__Sales_Order__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order__c', false); 
        so.OrderApi__Account__c = ac.id;
        so.OrderApi__Contact__c = con.id;
        so.OrderApi__Posting_Entity__c = 'Invoice';
        so.OrderApi__Payment_Method__c=pm.Id;
        insert so;
        
        OrderApi__Sales_Order_Line__c sol1 = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false); 
        sol1.OrderApi__Sales_Order__c = so.id;
        sol1.OrderApi__Account__c = ac.id;
        sol1.OrderApi__Contact__c = con.id;
        sol1.OrderApi__Item__c = itm1.id;
        insert sol1;
        
        OrderApi__Invoice__c inv = (OrderApi__Invoice__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice__c', false);
        inv.OrderApi__Contact__c=con.id;
        inv.OrderApi__Sales_Order__c=so.id;
        insert inv;
        
        OrderApi__Invoice_Line__c invLine = (OrderApi__Invoice_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Invoice_Line__c', false);
        invLine.OrderApi__Invoice__c=inv.Id;
        invLine.OrderApi__Item__c=itm1.Id;
        invLine.OrderApi__Sale_Price__c =100;
        invLine.OrderApi__Quantity__c=1;
        invLine.OrderApi__Total__c=100;
        insert invLine;
        
        inv.OrderApi__Is_Posted__c=true;
        inv.OrderApi__Amount_Paid__c=50;
        update inv;
        
        OrderApi__Subscription__c sub = (OrderApi__Subscription__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription__c', false);
        sub.OrderApi__Contact__c=con.Id;
        sub.OrderApi__Is_Active__c=true;
        sub.OrderApi__Item__c=itm1.Id;
        sub.OrderApi__Status__c='Active';
        sub.OrderApi__Subscription_Plan__c=plan1.Id;
        sub.OrderApi__Sales_Order_Line__c=sol1.Id;
        sub.OrderApi__Activated_Date__c=system.today();
        insert sub;
        
        OrderApi__Renewal__c renewal=new OrderApi__Renewal__c();
        renewal.OrderApi__Is_Active__c=true;
        renewal.OrderApi__Subscription__c=sub.Id;
        insert renewal;
        
        
        OrderApi__Receipt__c receipt=(OrderApi__Receipt__c)Fon_TestDataFactory.createSObject('OrderApi__Receipt__c', false); 
        //receipt.OrderApi__Sales_Order__c=so1.Id;
        insert receipt;
        
        OrderApi__Receipt_Line__c receiptline=(OrderApi__Receipt_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Receipt_Line__c', false);
        receiptline.OrderApi__Receipt__c=receipt.Id;
        receiptline.OrderApi__Total__c=100;
        insert receiptline;
        
        OrderApi__EPayment__c epay= (OrderApi__EPayment__c)Fon_TestDataFactory.createSObject('OrderApi__EPayment__c', false);
        insert epay;
        
        OrderApi__Receipt__c receipt1=(OrderApi__Receipt__c)Fon_TestDataFactory.createSObject('OrderApi__Receipt__c', false); 
        receipt1.OrderApi__EPayment__c=epay.Id;
        insert receipt1;
        
        OrderApi__Receipt_Line__c receiptline1=(OrderApi__Receipt_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Receipt_Line__c', false);
        receiptline1.OrderApi__Receipt__c=receipt1.Id;
        receiptline1.OrderApi__Total__c=100;
        insert receiptline1;
        
        List<user> userList =new List<user>();
        Profile p = [SELECT Id FROM Profile where Name='Fonteva Customer Community Login User'];
        User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com',ContactId=con.Id,
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='newuser@testorg.com');
        userList.add(u2);
        String nextPaymentDue='3';
        Decimal noOfInstallmentsRemaining=5;
        Decimal installmentAmount=120;
        Decimal balanceRemaining=40;
        Decimal convenienceFeeAmt=15;
        Decimal packAmt=100;
        Decimal foundationDonationAmt=100;
        
        // Fon_SelfServiceConfirmationEmailTemplate obj = new Fon_SelfServiceConfirmationEmailTemplate();
        
        List<OrderApi__Receipt_Line__c> rll = new List<OrderApi__Receipt_Line__c>();
        rll.add(receiptline);
        Test.setCurrentPageReference(new PageReference('Page.Fon_SelfServiceConfirmationEmailTemplate'));
        System.currentPageReference().getParameters().put('totalAmount','55');
        System.currentPageReference().getParameters().put('confirmationNumber','1000');
        System.currentPageReference().getParameters().put('id',receiptline.Id);        
        System.runAs(u2){
            Test.startTest();
            Fon_SelfServicePaymentConfirmation.sendEmailToContact(rll,rll, '1001', con.Id);
            Fon_SelfServicePortalController.getCurrentContactId();
            Fon_SelfServicePortalController.isvalidPaymentMethodAvailable(con.Id);
            Fon_SelfServicePortalController.fetchCurrentYearDues(con.Id);
           
            Fon_SelfServicePortalController.getCurrentSubscriptionPlan(con.Id);
            Fon_SelfServicePortalController.getSubscriptionPlan();
            Fon_SelfServicePortalController.isFullPaidCurrentSubcription(con.Id);
            Fon_SelfServicePortalController.isRenewalOrderCreated(con.Id);
           
            Fon_SelfServicePortalController.createSalesOrderForDonation(false,convenienceFeeAmt,packAmt,foundationDonationAmt,pm.Id,con.id,'test','td','jk','');
            string newSubscriptionPlan='Auto Full Pay';
            Fon_SelfServicePortalController.convertSalesorderIntoInvoice(con.Id);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void method2(){
        Account ac = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert ac;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        con.AccountId=ac.Id;
        con.Fon_AAFP_Subscription_Plan_Picklist__c='Installment';
        con.Fon_No_of_Remaining_installments__c=3;
        con.Fon_Next_Payment_Month__c=2;
        con.Email='twst@gmail.com';
        insert con;
        
        OrderApi__Payment_Method__c pm = (OrderApi__Payment_Method__c)Fon_TestDataFactory.createSObject('OrderApi__Payment_Method__c', false); 
        pm.OrderApi__Contact__c= con.Id;
        pm.OrderApi__Is_Active__c= true;
        pm.OrderApi__Is_Valid__c= true;
        pm.OrderApi__Year__c = 2020;
        pm.OrderApi__Month__c = 06;        
        pm.OrderApi__Card_Type__c = 'visa';
        
        pm.OrderApi__Number__c='1010-0101-1010-1010';
        insert pm;
        
        OrderApi__Item_Class__c itmClass = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClass.OrderApi__Is_Active__c=true;
        insert itmClass;
        
        OrderApi__Item__c itm = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm.OrderApi__Item_Class__c=itmClass.Id;
        itm.OrderApi__Price__c=100;
        itm.Is_Foundation_Donation__c=true;
        insert itm;
        
        OrderApi__Item__c item = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        item.OrderApi__Item_Class__c=itmClass.Id;
        item.OrderApi__Price__c=100;
        item.Fon_Is_PAC_Item__c=true;
        insert item;
        
        OrderApi__Item_Class__c itmClassMain = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClassMain.Fon_Is_Main_Membership__c=true;
        itmClassMain.OrderApi__Is_Active__c=true;
        insert itmClassMain;
        
        OrderApi__Item__c itm1 = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm1.OrderApi__Item_Class__c=itmClassMain.Id;
        itm1.OrderApi__Price__c=100;
        insert itm1;
        
        OrderApi__Subscription_Plan__c plan1 = (OrderApi__Subscription_Plan__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription_Plan__c', false);
        plan1.OrderApi__Type__c='Calendar';
        plan1.OrderApi__Is_Active__c=true;
        insert plan1;
        
        OrderApi__Sales_Order__c so2 = (OrderApi__Sales_Order__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order__c', false); 
        so2.OrderApi__Account__c = ac.id;
        so2.OrderApi__Contact__c = con.id;
        so2.OrderApi__Status__c='Open';
        so2.OrderApi__Posting_Entity__c='Receipt';
        insert so2;
        
        OrderApi__Subscription__c sub = (OrderApi__Subscription__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription__c', false);
        sub.OrderApi__Contact__c=con.Id;
        sub.OrderApi__Is_Active__c=true;
        sub.OrderApi__Item__c=itm1.Id;
        sub.OrderApi__Status__c='Active';
        sub.OrderApi__Subscription_Plan__c=plan1.Id;
        insert sub;
        
        
        
        OrderApi__Sales_Order_Line__c sol2 = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false); 
        sol2.OrderApi__Sales_Order__c = so2.id;
        sol2.OrderApi__Item__c = itm1.id;
        sol2.OrderApi__Is_Renewal__c=true;
        sol2.OrderApi__Subscription__c=sub.Id;
        sol2.OrderApi__Subscription_Start_Date__c=system.today();
        sol2.OrderApi__End_Date__c=System.today()+365;
        insert sol2;
        
        
        
        List<user> userList =new List<user>();
        Profile p = [SELECT Id FROM Profile where Name='Fonteva Customer Community Login User'];
        User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com',ContactId=con.Id,
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='newuser@testorg.com');
        userList.add(u2);
        String nextPaymentDue='3';
        Decimal noOfInstallmentsRemaining=5;
        Decimal installmentAmount=120;
        Decimal balanceRemaining=40;
        Decimal convenienceFeeAmt=15;
        Decimal packAmt=100;
        Decimal foundationDonationAmt=100;
        
        // Fon_SelfServiceConfirmationEmailTemplate obj = new Fon_SelfServiceConfirmationEmailTemplate();
        
        
        Test.startTest();
        
        Fon_SelfServicePortalController.fetchNextYearDues(con.Id);
        Fon_SelfServicePortalController.payReceiptDues(so2.Id,pm.Id,'Installment',true);
        //Fon_SelfServicePortalController.processPayment(convenienceFeeAmt,packAmt,foundationDonationAmt,pm.Id,con.id,'test','td','jk');
        Fon_SelfServicePortalController.receiptLineData(so2.Id);
        Fon_SelfServicePortalController.receiptLineData1(so2.Id);
        
        Test.stopTest();
        
    }
    
    @isTest
    public static void method3(){
        Account ac = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert ac;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        con.AccountId=ac.Id;
        con.Fon_AAFP_Subscription_Plan_Picklist__c='Auto Full Pay';
        con.Fon_No_of_Remaining_installments__c=3;
        con.Fon_Next_Payment_Month__c=2;
        con.Email='twst@gmail.com';
        insert con;
        
        OrderApi__Payment_Method__c pm = (OrderApi__Payment_Method__c)Fon_TestDataFactory.createSObject('OrderApi__Payment_Method__c', false); 
        pm.OrderApi__Contact__c= con.Id;
        pm.OrderApi__Is_Active__c= true;
        pm.OrderApi__Is_Valid__c= true;
        pm.OrderApi__Year__c = 2020;
        pm.OrderApi__Month__c = 06;        
        pm.OrderApi__Card_Type__c = 'visa';
        
        pm.OrderApi__Number__c='1010-0101-1010-1010';
        insert pm;
        
        OrderApi__Item_Class__c itmClass = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClass.OrderApi__Is_Active__c=true;
        insert itmClass;
        
        OrderApi__Item__c itm = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm.OrderApi__Item_Class__c=itmClass.Id;
        itm.OrderApi__Price__c=100;
        itm.Is_Foundation_Donation__c=true;
        insert itm;
        
        OrderApi__Item__c item = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        item.OrderApi__Item_Class__c=itmClass.Id;
        item.OrderApi__Price__c=100;
        item.Fon_Is_PAC_Item__c=true;
        insert item;
        
        OrderApi__Item_Class__c itmClassMain = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClassMain.Fon_Is_Main_Membership__c=true;
        itmClassMain.OrderApi__Is_Active__c=true;
        insert itmClassMain;
        
        OrderApi__Item__c itm1 = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm1.OrderApi__Item_Class__c=itmClassMain.Id;
        itm1.OrderApi__Price__c=100;
        insert itm1;
        
        OrderApi__Subscription_Plan__c plan1 = (OrderApi__Subscription_Plan__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription_Plan__c', false);
        plan1.OrderApi__Type__c='Calendar';
        plan1.OrderApi__Is_Active__c=true;
        insert plan1;
        
        
        
        OrderApi__Sales_Order__c so2 = (OrderApi__Sales_Order__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order__c', false); 
        so2.OrderApi__Account__c = ac.id;
        so2.OrderApi__Contact__c = con.id;
        so2.OrderApi__Posting_Entity__c='Receipt';
        so2.Fon_Salesorder_Type__c='Dues';
        insert so2;
        
        OrderApi__Sales_Order_Line__c sol2 = (OrderApi__Sales_Order_Line__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order_Line__c', false); 
        sol2.OrderApi__Sales_Order__c = so2.id;
        sol2.OrderApi__Item__c = itm1.id;
        insert sol2;
        
        so2.OrderApi__Status__c='Closed';
        so2.OrderApi__Is_Posted__c=false;
        update so2;
        
        OrderApi__Subscription__c sub = (OrderApi__Subscription__c)Fon_TestDataFactory.createSObject('OrderApi__Subscription__c', false);
        sub.OrderApi__Contact__c=con.Id;
        sub.OrderApi__Is_Active__c=true;
        sub.OrderApi__Item__c=itm1.Id;
        sub.OrderApi__Status__c='Active';
        sub.OrderApi__Subscription_Plan__c=plan1.Id;
        sub.OrderApi__Sales_Order_Line__c=sol2.Id;
        insert sub;
        
        List<user> userList =new List<user>();
        Profile p = [SELECT Id FROM Profile where Name='Fonteva Customer Community Login User'];
        User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com',ContactId=con.Id,
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='newuser@testorg.com');
        userList.add(u2);
        String nextPaymentDue='3';
        Decimal noOfInstallmentsRemaining=5;
        Decimal installmentAmount=120;
        Decimal balanceRemaining=40;
        Decimal convenienceFeeAmt=15;
        Decimal packAmt=100;
        Decimal foundationDonationAmt=100;
        
        // Fon_SelfServiceConfirmationEmailTemplate obj = new Fon_SelfServiceConfirmationEmailTemplate();
        
        
        Test.startTest();
        
        Fon_SelfServicePortalController.checkCurrentDuesSO(con.Id);
        Fon_SelfServicePortalController.convertSalesorderIntoInvoice(con.Id);
        //Fon_SelfServicePortalController.processPayment(convenienceFeeAmt,packAmt,foundationDonationAmt,pm.Id,con.id,'test','td','jk');
        
        
        Test.stopTest();
        
    }
    
    @isTest
    public static void methodTest1(){
        Account ac = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert ac;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        con.AccountId=ac.Id;
        con.Fon_No_of_Remaining_installments__c=3;
        con.Fon_Next_Payment_Month__c=2;
        con.Email='twst@gmail.com';
        con.Fon_AAFP_Subscription_Plan_Picklist__c='Installment';
        insert con;
        
        OrderApi__Payment_Method__c pm = (OrderApi__Payment_Method__c)Fon_TestDataFactory.createSObject('OrderApi__Payment_Method__c', false); 
        pm.OrderApi__Contact__c= con.Id;
        pm.OrderApi__Is_Active__c= true;
        pm.OrderApi__Is_Valid__c= true;
        pm.OrderApi__Year__c = 2020;
        pm.OrderApi__Month__c = 06;        
        pm.OrderApi__Card_Type__c = 'visa';
        pm.OrderApi__Number__c='1010-0101-1010-1010';
        insert pm;
        
        OrderApi__Item_Class__c itmClassMain = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClassMain.Fon_Is_Main_Membership__c=true;
        itmClassMain.OrderApi__Is_Active__c=true;
        insert itmClassMain;
        
        OrderApi__Item__c itm1 = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm1.OrderApi__Item_Class__c=itmClassMain.Id;
        itm1.OrderApi__Price__c=100;
        insert itm1;
        
        OrderApi__Sales_Order__c so = (OrderApi__Sales_Order__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order__c', false); 
        so.OrderApi__Account__c = ac.id;
        so.OrderApi__Contact__c = con.id;
        so.OrderApi__Posting_Entity__c = 'Invoice';
        so.OrderApi__Payment_Method__c=pm.Id;
        insert so;
        
        OrderApi__EPayment__c epay= (OrderApi__EPayment__c)Fon_TestDataFactory.createSObject('OrderApi__EPayment__c', false);
        epay.OrderApi__Sales_Order__c=so.Id;
        epay.OrderApi__Succeeded__c=true;
        insert epay;

        OrderApi__EPayment__c epay1= (OrderApi__EPayment__c)Fon_TestDataFactory.createSObject('OrderApi__EPayment__c', false);

//        insert epay1;
        
        Test.startTest();
        Fon_SelfServicePortalController.payDonationSo(so.Id,'Installment',true,true);
        Fon_SelfServicePortalController.payReceiptDues(so.Id,pm.Id,'Installment',true);
       // Fon_SelfServicePortalController.payInvoiceDues(epay1.id,'Installment',true,pm.Id);
        Fon_SelfServicePortalController.changeSubscriptionPlan(con.Id,'Installment');
        Test.stopTest();
    }
    
    @isTest
    public static void methodTest2(){
        Account ac = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert ac;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        con.AccountId=ac.Id;
        con.Fon_No_of_Remaining_installments__c=3;
        con.Fon_Next_Payment_Month__c=2;
        con.Email='twst@gmail.com';
        con.Fon_AAFP_Subscription_Plan_Picklist__c='Installment';
        insert con;
        
        OrderApi__Payment_Method__c pm = (OrderApi__Payment_Method__c)Fon_TestDataFactory.createSObject('OrderApi__Payment_Method__c', false); 
        pm.OrderApi__Contact__c= con.Id;
        pm.OrderApi__Is_Active__c= true;
        pm.OrderApi__Is_Valid__c= true;
        pm.OrderApi__Year__c = 2020;
        pm.OrderApi__Month__c = 06;        
        pm.OrderApi__Card_Type__c = 'visa';
        pm.OrderApi__Number__c='1010-0101-1010-1010';
        insert pm;
        
        OrderApi__Item_Class__c itmClassMain = (OrderApi__Item_Class__c)Fon_TestDataFactory.createSObject('OrderApi__Item_Class__c', false); 
        itmClassMain.Fon_Is_Main_Membership__c=true;
        itmClassMain.OrderApi__Is_Active__c=true;
        insert itmClassMain;
        
        OrderApi__Item__c itm1 = (OrderApi__Item__c)Fon_TestDataFactory.createSObject('OrderApi__Item__c', false); 
        itm1.OrderApi__Item_Class__c=itmClassMain.Id;
        itm1.OrderApi__Price__c=100;
        insert itm1;
        
        OrderApi__Sales_Order__c so = (OrderApi__Sales_Order__c)Fon_TestDataFactory.createSObject('OrderApi__Sales_Order__c', false); 
        so.OrderApi__Account__c = ac.id;
        so.OrderApi__Contact__c = con.id;
        so.OrderApi__Posting_Entity__c = 'Invoice';
        so.OrderApi__Payment_Method__c=pm.Id;
        insert so;
        
      
        OrderApi__EPayment__c epay1= (OrderApi__EPayment__c)Fon_TestDataFactory.createSObject('OrderApi__EPayment__c', false);
        insert epay1;
        
        OrderApi__Invoice__c inv= new OrderApi__Invoice__c();
        inv.OrderApi__Sales_Order__c= so.id;
        insert inv;
        
        OrderApi__Invoice_Line__c inl = new OrderApi__Invoice_Line__c();
        inl.OrderApi__Invoice__c=inv.id;
        inl.OrderApi__Item__c=itm1.id;
        insert inl;
        
        OrderApi__EPayment__c epay2= (OrderApi__EPayment__c)Fon_TestDataFactory.createSObject('OrderApi__EPayment__c', false);
        epay2.OrderApi__Succeeded__c=false;
        
        insert epay2;
        
        OrderApi__EPayment_Line__c epp =  (OrderApi__EPayment_Line__c)Fon_TestDataFactory.createSObject('OrderApi__EPayment_Line__c', false);
        epp.OrderApi__Invoice__c=inv.id;
        epp.OrderApi__EPayment__c=epay2.id;
        epp.OrderApi__Invoice_Line__c=inl.Id;
        insert epp;
            
        
        Test.startTest();
        
        Fon_SelfServicePortalController.payInvoiceDues(epay1.id,'Installment',true,pm.Id);
        Fon_SelfServicePortalController.createEpaymentLine(inv.Id,pm.Id); 
       
        Test.stopTest();
    }
}