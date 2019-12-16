public class Fon_SelfServicePortalController {
    
    @AuraEnabled
    public static String getCurrentContactId(){
        List<user> userList= [select ContactId from user where id=:UserInfo.getUserId() AND ContactId!=null];
        return userList[0].ContactId;
    }
    
    @AuraEnabled
    public static List<PaymentMethodWrapper> isvalidPaymentMethodAvailable(Id contactId) {
        List<PaymentMethodWrapper> lstPaymentMethodWrap = new List<PaymentMethodWrapper>();
        List<OrderApi__Payment_Method__c> lstPaymentMethod = [select id,
                                                              Name,OrderApi__Card_Type__c,
                                                              OrderApi__Exp_Date__c,OrderApi__Number__c
                                                              from OrderApi__Payment_Method__c 
                                                              where OrderApi__Contact__c=:contactId 
                                                              And OrderApi__Is_Valid__c=true 
                                                              And OrderApi__Is_Active__c=true];
        for(OrderApi__Payment_Method__c eachPaymentMethod : lstPaymentMethod){
            lstPaymentMethodWrap.add(new PaymentMethodWrapper(eachPaymentMethod));
        }
        return lstPaymentMethodWrap;
    }
    
    public class PaymentMethodWrapper{
        @AuraEnabled public String strLabel{get;set;}
        @AuraEnabled public String strValue{get;set;}
        
        public PaymentMethodWrapper(OrderApi__Payment_Method__c objPayMethod){
            String[] tempArray = objPayMethod.OrderApi__Number__c.split('-');
            Integer month = objPayMethod.OrderApi__Exp_Date__c.month();
            Integer year = objPayMethod.OrderApi__Exp_Date__c.year(); 
            this.strValue = objPayMethod.Id;
            this.strLabel = objPayMethod.OrderApi__Card_Type__c+' '+month+'/'+year+' '+tempArray[3];
        }
    }
    
    @AuraEnabled
    public static List<SuscriptionPlanWrapper> fetchCurrentYearDues(Id contactId){
        Id soId;
        List<SuscriptionPlanWrapper> tempList = new List<SuscriptionPlanWrapper>();
        if(contactId!=null){
            Contact[] con = [select id,Fon_AAFP_Subscription_Plan_Picklist__c from Contact where Id =:contactId];
            if(con[0].Fon_AAFP_Subscription_Plan_Picklist__c==Label.Fon_Installment){//Installment
                //need to add is main membership
                List<OrderApi__Subscription__c> activeSubscriptionList = [select id,
                                                                          OrderApi__Activated_Date__c,
                                                                          OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__c,
                                                                          OrderApi__Contact__r.Fon_No_of_Remaining_installments__c,
                                                                          OrderApi__Contact__r.Fon_Next_Payment_Month__c,
                                                                          OrderApi__Term_End_Date__c,
                                                                          OrderApi__Subscription_Plan__r.Name,
                                                                          (select id,OrderApi__Is_Active__c from OrderApi__Renewals__r WHERE OrderApi__Is_Active__c=true)
                                                                          from OrderApi__Subscription__c 
                                                                          where OrderApi__Contact__c=:contactId 
                                                                          AND OrderApi__Contact__r.Fon_AAFP_Subscription_Plan_Picklist__c=:Label.Fon_Installment 
                                                                          AND OrderApi__Is_Active__c=true
                                                                          AND OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__r.OrderApi__Posting_Entity__c='Invoice' Limit 1];
                if(activeSubscriptionList.size()>0){
                    for(OrderApi__Subscription__c subObj: activeSubscriptionList){
                        soId = subObj.OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__c;
                    }
                    
                    OrderApi__Invoice__c[] invList = [select id,
                                                      OrderApi__Contact__r.Fon_Next_Payment_Month__c,
                                                      OrderApi__Contact__r.Fon_No_of_Remaining_installments__c,
                                                      (select id,OrderApi__Balance_Due__c from OrderApi__Invoice_Lines__r WHERE OrderApi__Item__r.OrderApi__Item_Class__r.Fon_Is_Main_Membership__c=true) 
                                                      from OrderApi__Invoice__c WHERE OrderApi__Balance_Due__c>0 AND OrderApi__Sales_Order__c =:soId];
                    if(invList.size()==0){
                        return null;
                    }
                    List<OrderApi__Invoice_Line__c> invLineList = invList[0].OrderApi__Invoice_Lines__r;
                    Decimal totalBalance=0;
                    DEcimal installmentAmount=0;
                    integer installment = 1; 
                    if(invList[0].OrderApi__Contact__r.Fon_No_of_Remaining_installments__c>1){
                        installment=Integer.valueOf(invList[0].OrderApi__Contact__r.Fon_No_of_Remaining_installments__c);
                    }
                    For(OrderApi__Invoice_Line__c invLineObj:invLineList){
                        totalBalance+=invLineObj.OrderApi__Balance_Due__c;
                        Decimal balanceDue = (invLineObj.OrderApi__Balance_Due__c/installment);
                        balanceDue = balanceDue.setScale(2, RoundingMode.HALF_UP);
                        installmentAmount+=balanceDue;
                    }
                    Date dt = date.newInstance(System.today().year(), Integer.valueOf(invList[0].OrderApi__Contact__r.Fon_Next_Payment_Month__c), 1);
                    tempList.add(new SuscriptionPlanWrapper(getMonthYear(dt),invList[0].OrderApi__Contact__r.Fon_No_of_Remaining_installments__c,installmentAmount.setScale(2, RoundingMode.HALF_UP),totalBalance));
                }
                return tempList; 
            }
            else{//Auto Full Pay Or Performa
                List<OrderApi__Subscription__c> activeSubscriptionList = [select id,
                                                                          OrderApi__Activated_Date__c,
                                                                          OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__c,
                                                                          OrderApi__Contact__r.Fon_No_of_Remaining_installments__c,
                                                                          OrderApi__Contact__r.Fon_Next_Payment_Month__c,
                                                                          OrderApi__Term_End_Date__c,
                                                                          OrderApi__Subscription_Plan__r.Name,
                                                                          (select id,OrderApi__Is_Active__c from OrderApi__Renewals__r WHERE OrderApi__Is_Active__c=true)
                                                                          from OrderApi__Subscription__c 
                                                                          where OrderApi__Contact__c=:contactId 
                                                                          AND OrderApi__Contact__r.Fon_AAFP_Subscription_Plan_Picklist__c!=:Label.Fon_Installment 
                                                                          AND OrderApi__Is_Active__c=true
                                                                          AND OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__r.OrderApi__Posting_Entity__c='Invoice' Limit 1];
                if(activeSubscriptionList.size()>0){
                    for(OrderApi__Subscription__c subObj: activeSubscriptionList){
                        soId = subObj.OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__c;
                    }
                    
                    OrderApi__Invoice__c[] invList = [select id,OrderApi__Contact__r.Fon_Next_Payment_Month__c
                                                      ,OrderApi__Contact__r.Fon_No_of_Remaining_installments__c
                                                      ,(select id,OrderApi__Item__r.Name,OrderApi__Balance_Due__c from OrderApi__Invoice_Lines__r) from OrderApi__Invoice__c WHERE OrderApi__Balance_Due__c>0 AND OrderApi__Sales_Order__c =:soId];
                    if(invList.size()==0){
                        return null;
                    }
                    List<OrderApi__Invoice_Line__c> invLineList = invList[0].OrderApi__Invoice_Lines__r;
                    For(OrderApi__Invoice_Line__c invLineObj:invLineList){
                        tempList.add(new SuscriptionPlanWrapper(invLineObj.OrderApi__Item__r.Name, invLineObj.OrderApi__Balance_Due__c, true));
                    }
                }
                else{
                    OrderApi__Sales_Order__c[] soList = [select id,
                                                         OrderApi__Total__c,
                                                         (select OrderApi__Item__r.Name,OrderApi__Total__c from OrderApi__Sales_Order_Lines__r) 
                                                         from OrderApi__Sales_Order__c
                                                         where OrderApi__Contact__c=:contactId 
                                                         AND OrderApi__Contact__r.Fon_AAFP_Subscription_Plan_Picklist__c!='Installment'
                                                         AND OrderApi__Posting_Entity__c='Receipt'
                                                         AND OrderApi__Is_Posted__c!=true
                                                         AND OrderApi__Status__c='Closed'
                                                         AND Fon_Salesorder_Type__c!='Donation'
                                                         AND (Fon_Membership_Staging__r.Fon_Staging_Status__c!='Cancelled' OR Fon_Membership_Staging__c=null)
                                                         Limit 1
                                                        ];
                    if(soList.size()==0){
                        return tempList;
                    }
                    List<OrderApi__Sales_Order_Line__c> soliList=soList[0].OrderApi__Sales_Order_Lines__r;
                    if(soliList.size()>0){
                        for(OrderApi__Sales_Order_Line__c soliObj:soliList){
                            tempList.add(new SuscriptionPlanWrapper(soliObj.OrderApi__Item__r.Name, soliObj.OrderApi__Total__c, true));
                        }
                    }
                }
                return tempList; 
            }
        }
        return null;
    }
    
    @AuraEnabled
    public static List<SuscriptionPlanWrapper> fetchNextYearDues(Id contactId){  
        Boolean isNextYearDues=false;
        Date nextPaymentDue;
        Integer noOfInstallmentsRemaining=0;
        Integer installment = 1; 
        Decimal totalBalance = 0;
        Decimal installmentAmount = 0;
        List<SuscriptionPlanWrapper> tempList = new List<SuscriptionPlanWrapper>();
        if(contactId!=null){
            Contact[] con = [select id,Fon_AAFP_Subscription_Plan_Picklist__c from Contact where Id =:contactId];
            List<OrderApi__Sales_Order__c> openSO = [select id,
                                                     (select id,OrderApi__Item__r.Name,
                                                      OrderApi__Subscription_Start_Date__c,
                                                      OrderApi__End_Date__c,
                                                      OrderApi__Total__c
                                                      from OrderApi__Sales_Order_Lines__r 
                                                      WHERE OrderApi__Is_Renewal__c=true 
                                                      AND (OrderApi__Item__r.OrderApi__Item_Class__r.Fon_Is_Main_Membership__c=true
                                                           OR OrderApi__Item__r.OrderApi__Item_Class__r.Fon_Is_State_Membership__c=true
                                                           OR OrderApi__Item__r.OrderApi__Item_Class__r.Fon_Is_Local_Membership__c=true)
                                                      AND OrderApi__Subscription_Start_Date__c!=Null)
                                                     from OrderApi__Sales_Order__c 
                                                     where OrderApi__Contact__c=:contactId 
                                                     AND OrderApi__Status__c='Open'
                                                     Limit 1];
            
            if(con[0].Fon_AAFP_Subscription_Plan_Picklist__c==Label.Fon_Installment && openSO.size()>0){
                for(OrderApi__Sales_Order__c soObj: openSO){
                    List<OrderApi__Sales_Order_Line__c> soliList= soObj.OrderApi__Sales_Order_Lines__r;
                    if(soliList.size()>0){
                        isNextYearDues=true;
                        nextPaymentDue=soliList[0].OrderApi__Subscription_Start_Date__c;
                        noOfInstallmentsRemaining=soliList[0].OrderApi__Subscription_Start_Date__c.monthsBetween(soliList[0].OrderApi__End_Date__c);
                        installment=noOfInstallmentsRemaining+1;
                        for(OrderApi__Sales_Order_Line__c soliObj:soliList){
                            totalBalance+=soliObj.OrderApi__Total__c;
                            Decimal balanceDue = (totalBalance/installment);
                            balanceDue = balanceDue.setScale(2, RoundingMode.HALF_UP);
                            installmentAmount+=balanceDue;
                        }
                    }
                }
                if(isNextYearDues){
                    tempList.add(new SuscriptionPlanWrapper(getMonthYear(nextPaymentDue),installment,installmentAmount,totalBalance));
                }
            }
            else if(openSO.size()>0){
                for(OrderApi__Sales_Order__c soObj: openSO){
                    List<OrderApi__Sales_Order_Line__c> soliList= soObj.OrderApi__Sales_Order_Lines__r;
                    if(soliList.size()>0){
                        for(OrderApi__Sales_Order_Line__c soliObj:soliList){
                            tempList.add(new SuscriptionPlanWrapper(soliObj.OrderApi__Item__r.Name, soliObj.OrderApi__Total__c, true));
                        }
                    }
                }
            }
            return tempList; 
        }
        return null;
    }
    
    public class SuscriptionPlanWrapper{
        @AuraEnabled public String nextPaymentDue;
        @AuraEnabled public Integer noOfInstallmentsRemaining;
        @AuraEnabled public Decimal installmentAmount;
        @AuraEnabled public Decimal balanceRemaining;
        
        @AuraEnabled public String itemName;
        @AuraEnabled public Boolean isAutoFullPay;
        
        
        public SuscriptionPlanWrapper(String nextPaymentDue,Decimal noOfInstallmentsRemaining,Decimal installmentAmount,Decimal balanceRemaining){
            this.nextPaymentDue=nextPaymentDue;
            this.noOfInstallmentsRemaining=Integer.valueOf(noOfInstallmentsRemaining);
            this.installmentAmount=installmentAmount;
            this.balanceRemaining=balanceRemaining;
        }
        public SuscriptionPlanWrapper(String itemName, Decimal balanceRemaining, Boolean isAutoFullPay){
            this.itemName= itemName;
            this.balanceRemaining= balanceRemaining;
            this.isAutoFullPay= isAutoFullPay;
        }
    } 
    
    @AuraEnabled
    public static String getCurrentSubscriptionPlan(Id contactId){
        Contact conList = [select id,Fon_AAFP_Subscription_Plan_Picklist__c from Contact where id=:contactId ];
        return conList.Fon_AAFP_Subscription_Plan_Picklist__c;
    }
    
    @AuraEnabled 
    public static Map<String, String> getSubscriptionPlan(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Contact.Fon_AAFP_Subscription_Plan_Picklist__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    static String getMonthYear(Date dt){
        Map<Integer,String> monthNameMap=new Map<Integer, String>{1 =>'January', 2=>'February', 3=>'March', 4=>'April', 5=>'May',
            6=>'June', 7=>'July', 8=>'August', 9=>'September',10=>'October',
            11=>'November', 12=>'December'};
                return monthNameMap.get(dt.month())+' '+dt.year();                                             
    }
    
    @AuraEnabled
    public static String createSalesOrderForDonation(Boolean isNextYearConvenienceFeeApplied,
                                                     Decimal convenienceFeeAmt,
                                                     Decimal packAmt,
                                                     Decimal foundationDonationAmt,
                                                     Id paymentMethodId,
                                                     Id contactId,
                                                     String employeeName,
                                                     String occupation,
                                                     String accountType,
                                                     String duesSoId)
    {
        String currentYear = String.valueOf(System.today().year());
        String nextYear = String.valueOf(System.today().year()+1);
        List<String> lstItemName = new List<String>();
        if(isNextYearConvenienceFeeApplied){
            lstItemName.add(nextYear+' Convenience Fee');
        }
        else{
            lstItemName.add(currentYear+' Convenience Fee');
        }
        Id convenienceFeeItemId;
        Id packItemId;
        Id fonundationDonationItemId;
        
        for(OrderApi__Item__c eachItem : [SELECT Id,Fon_Is_PAC_Item__c,Name,Is_Foundation_Donation__c 
                                          FROM OrderApi__Item__c 
                                          WHERE (Name IN:lstItemName OR Is_Foundation_Donation__c = true OR Fon_Is_PAC_Item__c = true)]){
                                              if(eachItem.Is_Foundation_Donation__c){
                                                  fonundationDonationItemId=eachItem.Id;
                                              }
                                              else if(eachItem.Fon_Is_PAC_Item__c){
                                                  packItemId=eachItem.Id;
                                              }
                                              else{
                                                  convenienceFeeItemId=eachItem.Id;
                                              }
                                          }
        
        OrderApi__Sales_Order__c soObj = createInstanceOfSalesorder(paymentMethodId,contactId,duesSoId);
        
        insert soObj;
        if(soObj.Id!=null){
            List<OrderApi__Sales_Order_Line__c> insertSalesorderline= new  List<OrderApi__Sales_Order_Line__c>();
            if(convenienceFeeAmt>0){
                OrderApi__Sales_Order_Line__c objSoli = createInstanceOfSalesorderLine(soObj.Id,convenienceFeeItemId,false,0,paymentMethodId,'','','');
                insertSalesorderline.add(objSoli);
            }
            if(packAmt>0){
                OrderApi__Sales_Order_Line__c objSoli = createInstanceOfSalesorderLine(soObj.Id,packItemId,true,packAmt,paymentMethodId,employeeName,occupation,accountType);
                insertSalesorderline.add(objSoli);
            }
            if(foundationDonationAmt>0){
                OrderApi__Sales_Order_Line__c objSoli = createInstanceOfSalesorderLine(soObj.Id,fonundationDonationItemId,false,0,paymentMethodId,'','','');
                insertSalesorderline.add(objSoli);
            }
            insert insertSalesorderline;
            soObj.OrderApi__Status__c='Closed';
            update soObj;
            return soObj.Id;
        }
        return null;
    }
    
    @AuraEnabled
    public static list<OrderApi__Receipt_Line__c> payDonationSo(String soID,
                                                                String newSubscriptionPlan,
                                                                Boolean isFoundationDonationRenewal,
                                                                Boolean isCurrentTermNotPaidFull)
    {
        OrderApi__Sales_Order__c so = [select id,OrderApi__Posting_Entity__c,
                                       OrderApi__Is_Posted__c,
                                       OrderApi__Is_Voided__c,OrderApi__Contact__c,OrderApi__Payment_Method__c,OrderApi__Payment_Method__r.OrderApi__Payment_Method_Token__c from OrderApi__Sales_Order__c where id=:soID];
        FDService.PaymentRequest objPR = FDService.PaymentRequest.getInstance();
        objPR.record = so.Id; //Salesorder Id
        objPR.paymentGateway = null;
        objPR.paymentMethod = so.OrderApi__Payment_Method__c;
        objPR.paymentMethodToken = so.OrderApi__Payment_Method__r.OrderApi__Payment_Method_Token__c;
        objPR.contact = so.OrderApi__Contact__c;
        if(!Test.isRunningTest()){
            FDService.OrderPaymentService.getInstance().pay(objPR);
        }
        OrderApi__EPayment__c[] epay= [select id from OrderApi__EPayment__c WHERE OrderApi__Succeeded__c=true AND OrderApi__Sales_Order__c=:soID];
        if(epay.size()==0){
            so.OrderApi__Is_Voided__c=true;
            update so;
            list<OrderApi__Receipt_Line__c> nullLine = new list<OrderApi__Receipt_Line__c>();
            return nullLine;
        }
        
        Contact[] con = [select id,
                         Fon_AAFP_Subscription_Plan_Picklist__c,
                         Fon_Foundation_Donation_Renewal__c,
                         Fon_No_of_Remaining_installments__c
                         ,Fon_Next_Payment_Month__c,Fon_Frequency__c from contact WHERE id=:so.OrderApi__Contact__c];
        con[0].Fon_AAFP_Subscription_Plan_Picklist__c = newSubscriptionPlan;
        if(isFoundationDonationRenewal){
            con[0].Fon_Foundation_Donation_Renewal__c = true;
        }
        if(newSubscriptionPlan=='Installment'){
            OrderApi__Sales_Order__c[] soList = [select id,
                                                 OrderApi__Total__c,
                                                 OrderApi__Posting_Entity__c,
                                                 OrderApi__Is_Posted__c,
                                                 OrderApi__Status__c,
                                                 OrderApi__Payment_Method__c,
                                                 (select OrderApi__Item__r.Name,OrderApi__Total__c,OrderApi__Activation_Date__c,OrderApi__End_Date__c,OrderApi__Subscription_Start_Date__c                                                      
                                                  from OrderApi__Sales_Order_Lines__r WHERE OrderApi__Item__r.OrderApi__Item_Class__r.Fon_Is_Main_Membership__c=true) 
                                                 from OrderApi__Sales_Order__c
                                                 where OrderApi__Contact__c=:so.OrderApi__Contact__c 
                                                 AND OrderApi__Contact__r.Fon_AAFP_Subscription_Plan_Picklist__c!='Installment'
                                                 AND OrderApi__Status__c='Closed'
                                                 AND Fon_Salesorder_Type__c!='Donation'
                                                 Limit 1
                                                ];
            if(soList.size()>0){
                List<OrderApi__Sales_Order_Line__c> soliList= soList[0].OrderApi__Sales_Order_Lines__r;
                if(soList[0].OrderApi__Posting_Entity__c=='Receipt' && soList[0].OrderApi__Is_Posted__c != true){//Performa or Auto full pay not paid
                    soList[0].OrderApi__Payment_Method__c= so.OrderApi__Payment_Method__c;
                    soList[0].OrderApi__Posting_Entity__c='Invoice';
                    soList[0].OrderApi__Status__c='Open';
                    update soList;
                    ID jobID = System.enqueueJob(new Fon_SelfServiceQueueable(soList[0].Id));
                    if(soliList.size()>0){
                        Decimal totalBalance=0;
                        Date myDate = System.Today();
                        if(System.today().day() <= Integer.valueOf(System.Label.Fon_10)){
                            con[0].Fon_No_of_Remaining_installments__c= (soliList[0].OrderApi__Subscription_Start_Date__c.monthsBetween(soliList[0].OrderApi__End_Date__c))+1;
                            con[0].Fon_Next_Payment_Month__c = myDate.month();
                        }
                        else{
                            Integer installmet = soliList[0].OrderApi__Subscription_Start_Date__c.monthsBetween(soliList[0].OrderApi__End_Date__c);
                            if(installmet == 0){
                                con[0].Fon_No_of_Remaining_installments__c= 1;
                            }
                            else{
                                con[0].Fon_No_of_Remaining_installments__c= soliList[0].OrderApi__Subscription_Start_Date__c.monthsBetween(soliList[0].OrderApi__End_Date__c);
                            }
                            con[0].Fon_Next_Payment_Month__c = myDate.addMonths(1).month();
                        }
                        con[0].Fon_Frequency__c = 12;
                    }
                }
                else if(soList[0].OrderApi__Posting_Entity__c=='Invoice'  && soList[0].OrderApi__Is_Posted__c == true){//Performa or Auto full pay not paid
                    if(soliList.size()>0){
                        Decimal totalBalance=0;
                        Date myDate = System.Today();
                        if(System.today().day() <= Integer.valueOf(System.Label.Fon_10)){
                            con[0].Fon_No_of_Remaining_installments__c= (soliList[0].OrderApi__Subscription_Start_Date__c.monthsBetween(soliList[0].OrderApi__End_Date__c))+1;
                            con[0].Fon_Next_Payment_Month__c = myDate.month();
                        }
                        else{
                            Integer installmet = soliList[0].OrderApi__Subscription_Start_Date__c.monthsBetween(soliList[0].OrderApi__End_Date__c);
                            if(installmet == 0){
                                con[0].Fon_No_of_Remaining_installments__c= 1;
                            }
                            else{
                                con[0].Fon_No_of_Remaining_installments__c= soliList[0].OrderApi__Subscription_Start_Date__c.monthsBetween(soliList[0].OrderApi__End_Date__c);
                            }
                            con[0].Fon_Next_Payment_Month__c = myDate.addMonths(1).month();
                        }
                        con[0].Fon_Frequency__c = 12;
                    }
                }
            }
        }
        update con;
        list<OrderApi__Receipt_Line__c> recptline = receiptLineData(soID);
        return recptline;
    }
    
    @AuraEnabled
    public static list<OrderApi__Receipt_Line__c> payReceiptDues(String soID, String paymentMethodId,String newSubscriptionPlan,Boolean isFoundationDonationRenewal){
        OrderApi__Sales_Order__c so = [select id,OrderApi__Posting_Entity__c,
                                       OrderApi__Is_Posted__c,
                                       OrderApi__Is_Voided__c,OrderApi__Contact__c,OrderApi__Payment_Method__c,OrderApi__Payment_Method__r.OrderApi__Payment_Method_Token__c from OrderApi__Sales_Order__c where id=:soID];
        Boolean updateSo=false;
        FDService.PaymentRequest objPR = FDService.PaymentRequest.getInstance();
        objPR.record = so.Id; //Salesorder Id
        objPR.paymentGateway = null;    
        objPR.contact = so.OrderApi__Contact__c;
        if(so.OrderApi__Payment_Method__c!=null){
            objPR.paymentMethod = so.OrderApi__Payment_Method__c;
            objPR.paymentMethodToken = so.OrderApi__Payment_Method__r.OrderApi__Payment_Method_Token__c;
        }
        else{
            OrderApi__Payment_Method__c[] pm=[select id,OrderApi__Payment_Method_Token__c from OrderApi__Payment_Method__c WHERE id=:paymentMethodId];
            objPR.paymentMethod = pm[0].id;
            objPR.paymentMethodToken = pm[0].OrderApi__Payment_Method_Token__c;
            updateSo=true;
        }
        if(!Test.isRunningTest()){
            FDService.OrderPaymentService.getInstance().pay(objPR);
        }
        
        if(updateSo){
            so.OrderApi__Payment_Method__c = paymentMethodId;
            update so;
        }
        OrderApi__EPayment__c[] epay= [select id from OrderApi__EPayment__c WHERE OrderApi__Succeeded__c=true AND OrderApi__Sales_Order__c=:soID];
        if(epay.size()==0){
            list<OrderApi__Receipt_Line__c> nullLine = new list<OrderApi__Receipt_Line__c>();
            return nullLine;
        }
        
        Contact[] con = [select id,Fon_AAFP_Subscription_Plan_Picklist__c,Fon_Foundation_Donation_Renewal__c from contact WHERE id=:so.OrderApi__Contact__c];
        con[0].Fon_AAFP_Subscription_Plan_Picklist__c = newSubscriptionPlan;
        if(isFoundationDonationRenewal){
            con[0].Fon_Foundation_Donation_Renewal__c = true;
        }
        update con;
        
        list<OrderApi__Receipt_Line__c> recptline = receiptLineData(soID);
        return recptline;
    }
    
    @AuraEnabled
    public static list<OrderApi__Receipt_Line__c> payInvoiceDues(String epayId,String newSubscriptionPlan,Boolean isFoundationDonationRenewal,String paymentMethodId){
        OrderApi__EPayment__c[] EP = [select id,
                                      OrderApi__Payment_Method__c,
                                      OrderApi__Payment_Method__r.OrderApi__Payment_Method_Token__c,
                                      OrderApi__Contact__c,
                                      OrderApi__Sales_Order__c,
                                      OrderApi__Sales_Order__r.OrderApi__Payment_Method__c,
                                      OrderApi__Sales_Order__r.OrderApi__Payment_Method__r.OrderApi__Payment_Method_Token__c
                                      from OrderApi__EPayment__c where id=:epayId];
        //Payment logic of invoice
        FDService.PaymentRequest objPR = FDService.PaymentRequest.getInstance();
        objPR.record = epayId; //Epayment Id
        objPR.paymentGateway = null;
        objPR.paymentMethod = EP[0].OrderApi__Payment_Method__c;
        objPR.paymentMethodToken = EP[0].OrderApi__Payment_Method__r.OrderApi__Payment_Method_Token__c;
        objPR.contact = EP[0].OrderApi__Contact__c;
        if(!Test.isRunningTest()){
            FDService.OrderPaymentService.getInstance().pay(objPR);
        }
        OrderApi__EPayment__c[] epay= [select id,OrderApi__Sales_Order__c from OrderApi__EPayment__c WHERE OrderApi__Succeeded__c=true AND Id=:EP[0].Id];
        if(epay.size()==0){
            list<OrderApi__Receipt_Line__c> nullLine = new list<OrderApi__Receipt_Line__c>();
            return nullLine;
        }
        
        Contact[] con = [select id,Fon_AAFP_Subscription_Plan_Picklist__c,
                         Fon_No_of_Remaining_installments__c,
                         Fon_Next_Payment_Month__c,
                         Fon_Frequency__c,
                         Fon_Foundation_Donation_Renewal__c from contact WHERE id=:EP[0].OrderApi__Contact__c];
        if(newSubscriptionPlan!='Installment'){ 
            List<OrderApi__Subscription__c> activeSubscriptionList = [select id,OrderApi__Payment_Method__c
                                                                      from OrderApi__Subscription__c 
                                                                      where OrderApi__Contact__c=:EP[0].OrderApi__Contact__c 
                                                                      AND OrderApi__Is_Active__c=true
                                                                      Limit 1];
            if(activeSubscriptionList.size()>0){
                activeSubscriptionList[0].OrderApi__Payment_Method__c=paymentMethodId;
                update activeSubscriptionList;
                
                List<OrderApi__Sales_Order__c> openSO = [select id,OrderApi__Payment_Method__c,
                                                         (select id from OrderApi__Sales_Order_Lines__r 
                                                          WHERE OrderApi__Is_Renewal__c=true
                                                          AND OrderApi__Subscription_Start_Date__c!=Null)
                                                         from OrderApi__Sales_Order__c 
                                                         where OrderApi__Contact__c=:EP[0].OrderApi__Contact__c 
                                                         AND OrderApi__Status__c='Open'
                                                         Limit 1];
                if(openSO.size()>0){
                    List<OrderApi__Sales_Order_Line__c> soliLine = openSO[0].OrderApi__Sales_Order_Lines__r;
                    if(soliLine.size()>0){
                        openSO[0].OrderApi__Payment_Method__c=paymentMethodId;
                        update openSO;
                    }
                }
                
            }
            con[0].Fon_No_of_Remaining_installments__c=null;
            con[0].Fon_Next_Payment_Month__c=null;
            con[0].Fon_Frequency__c=null;
        }
        con[0].Fon_AAFP_Subscription_Plan_Picklist__c = newSubscriptionPlan;
        if(isFoundationDonationRenewal){
            con[0].Fon_Foundation_Donation_Renewal__c = true;
        }
        update con;
        
        list<OrderApi__Receipt_Line__c> recptline = receiptLineData1(epay[0].Id);
        return recptline;
    }
    
    @AuraEnabled
    public static String createEpaymentLine(String invID,String paymentMethodId){
        //Creating Epayment record of Invoice   
        Set<Id> invoiceIds = new Set<Id>();
        invoiceIds.add(invID); 
        OrderApi.EPayment epaymentObj = new OrderApi.EPayment();
        List<OrderApi__Invoice__c> invoices ;
        if(!Test.isRunningTest()){
            invoices = (List<OrderApi__Invoice__c>) new Framework.Selector(OrderApi__Invoice__c.SObjectType,OrderApi__Invoice_Line__c.OrderApi__Invoice__c).selectById(invoiceIds);
            if(invoices.size()>0){
                epaymentObj.buildEpayment(invoices);
                epaymentObj.constructEPayment();
                system.debug('E payment got created');
            }
        }
        
        List<OrderApi__EPayment_Line__c> epaymentLineList = [select id,OrderApi__Sale_Price__c,OrderApi__EPayment__c,OrderApi__Invoice_Line__c,OrderApi__Invoice_Line__r.OrderApi__Credits_Applied__c, 
                                                             OrderApi__Total__c, OrderApi__Quantity__c from OrderApi__EPayment_Line__c where OrderApi__Invoice__c in:invoiceIds AND OrderApi__Invoice_Line__c!=NULL AND OrderApi__EPayment__r.OrderApi__Succeeded__c=false Limit 1];
        List<OrderApi__EPayment__c> epay = [select id,OrderApi__Payment_Method__c from OrderApi__EPayment__c where Id =:epaymentLineList[0].OrderApi__EPayment__c];
        epay[0].OrderApi__Payment_Method__c=paymentMethodId;
        update epay;
        return epaymentLineList[0].OrderApi__EPayment__c;
    }
    
    public static OrderApi__Sales_Order__c createInstanceOfSalesorder(Id paymentMethodId, Id conId,String duesSoId){
        OrderApi__Sales_Order__c objSO = new OrderApi__Sales_Order__c();        
        objSO.OrderApi__Payment_Method__c = paymentMethodId;
        objSO.OrderApi__Contact__c = conId;
        objSO.OrderApi__Entity__c = 'Contact';
        objSO.OrderApi__Posting_Entity__c = 'Receipt';
        objSO.OrderApi__Status__c = 'Open';
        objSO.OrderApi__Closed_Status__c = 'Cash Sale';
        objSO.OrderApi__Schedule_Type__c = 'Simple Receipt';
        objSO.Fon_Salesorder_Type__c = 'Donation';
        if(String.isNotBlank(duesSoId) && duesSoId != null){
            objSo.Fon_Dues_Sales_Order__c = duesSoId;  
        }
        return objSO;
    }
    
    public static OrderApi__Sales_Order_Line__c createInstanceOfSalesorderLine(Id salesorderId,Id itemId,Boolean isPack,Decimal amt,Id paymentMethodId,String employeeName,String occupation,String accountType){
        OrderApi__Sales_Order_Line__c objSoli = new OrderApi__Sales_Order_Line__c();        
        objSoli.OrderApi__Sales_Order__c= salesorderId;
        objSoli.OrderApi__Payment_Method__c= paymentMethodId;
        objSoli.OrderApi__Item__c= itemId;
        if(isPack){
            objSoli.OrderApi__Price_Override__c= true;
            objSoli.OrderApi__Sale_Price__c=amt;
            objSoli.Fon_Employee_Name__c= employeeName;
            objSoli.Fon_Occupation__c= occupation;
            objSoli.Fon_Account_Type__c= accountType;
        }        
        return objSoli;
    }
    
    public static void convertSalesorderIntoInvoice(Id contactId){
        List<OrderApi__Subscription__c> activeSubscriptionList = [select id,OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__c from OrderApi__Subscription__c where OrderApi__Contact__c=:contactId AND OrderApi__Is_Active__c=true];
        List<OrderApi__Sales_Order__c> soList = [select id,
                                                 OrderApi__Posting_Entity__c,
                                                 OrderApi__Is_Posted__c
                                                 from OrderApi__Sales_Order__c 
                                                 WHERE OrderApi__Posting_Entity__c='Receipt' AND id=:activeSubscriptionList[0].OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__c
                                                 AND OrderApi__Is_Posted__c!=true];
        if(soList.size()>0){
            soList[0].OrderApi__Posting_Entity__c='Invoice';
            soList[0].OrderApi__Is_Posted__c=true;
            update soList;
        }
    }
    
    @AuraEnabled  
    public static list<OrderApi__Receipt_Line__c> receiptLineData(Id soID){
        list<OrderApi__Receipt_Line__c> receiptLineList=[select OrderApi__Receipt__c,OrderApi__Sales_Order_Line__r.OrderApi__Contact__r.Name,OrderApi__Receipt__r.Name,
                                                         OrderApi__Sales_Order_Line__r.OrderApi__Contact__r.Email,
                                                         OrderApi__Sales_Order_Line__r.OrderApi__Contact__c,
                                                         OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__r.Fon_Payee_Email__c,OrderApi__Contact__c,
                                                         OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__r.Name,id,Name,OrderApi__Invoice__r.Fon_Payee_Email__c,
                                                         OrderApi__Contact__r.Email,OrderApi__Receipt__r.OrderApi__Sales_Order__r.Name,OrderApi__Item__r.Name,
                                                         OrderApi__Total__c,OrderApi__Contact__r.Name from OrderApi__Receipt_Line__c where OrderApi__Receipt__r.OrderApi__Sales_Order__c =:soID];
        return receiptLineList;
    } 
    
    @AuraEnabled  
    public static list<OrderApi__Receipt_Line__c> receiptLineData1(Id soID){
        list<OrderApi__Receipt_Line__c> receiptLineList=[select OrderApi__Receipt__c,OrderApi__Sales_Order_Line__r.OrderApi__Contact__r.Name,OrderApi__Receipt__r.Name,
                                                         OrderApi__Sales_Order_Line__r.OrderApi__Contact__r.Email,
                                                         OrderApi__Sales_Order_Line__r.OrderApi__Contact__c,
                                                         OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__r.Fon_Payee_Email__c,OrderApi__Contact__c,
                                                         OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__r.Name,id,Name,OrderApi__Invoice__r.Fon_Payee_Email__c,
                                                         OrderApi__Contact__r.Email,OrderApi__Receipt__r.OrderApi__Sales_Order__r.Name,OrderApi__Item__r.Name,
                                                         OrderApi__Total__c,OrderApi__Contact__r.Name from OrderApi__Receipt_Line__c where OrderApi__Receipt__r.OrderApi__EPayment__c =:soID];
        return receiptLineList;
    } 
    public Static String soId;
    public static String entityType;
    
    @AuraEnabled
    public static Boolean isCurrentSubcriptionIsActive(String contactId){
        Boolean isActive=false;
        List<OrderApi__Subscription__c> activeSubscriptionList = [select id,
                                                                  OrderApi__Activated_Date__c,
                                                                  OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__c,
                                                                  OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__r.OrderApi__Posting_Entity__c,
                                                                  (select id,OrderApi__Is_Active__c from OrderApi__Renewals__r WHERE OrderApi__Is_Active__c=true)
                                                                  from OrderApi__Subscription__c 
                                                                  where OrderApi__Contact__c=:contactId 
                                                                  AND OrderApi__Is_Active__c=true];
        if(activeSubscriptionList.size()==0){
            return false;
        }
        for(OrderApi__Subscription__c subObj: activeSubscriptionList){
            soId=subObj.OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__c;
            entityType = subObj.OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__r.OrderApi__Posting_Entity__c;
            List<OrderApi__Renewal__c> termList= subObj.OrderApi__Renewals__r;
            if(termList.size()>0){
                isActive=true;
            }
        }
        if(isActive){
            return isActive;
        }
        return false;
    }
    
    @AuraEnabled
    public static Map<Boolean,Decimal> isRenewalOrderCreated(String contactId){
        Boolean isRenewalSoli=false;
        Map<Boolean,Decimal> temp = new Map<Boolean,Decimal>();
        List<OrderApi__Sales_Order__c> openSO = [select id,OrderApi__Total__c,
                                                 (select id,
                                                  OrderApi__Subscription_Start_Date__c,
                                                  OrderApi__End_Date__c,
                                                  OrderApi__Total__c
                                                  from OrderApi__Sales_Order_Lines__r 
                                                  WHERE OrderApi__Is_Renewal__c=true
                                                  AND (OrderApi__Item__r.OrderApi__Item_Class__r.Fon_Is_Main_Membership__c=true
                                                       OR OrderApi__Item__r.OrderApi__Item_Class__r.Fon_Is_State_Membership__c=true
                                                       OR OrderApi__Item__r.OrderApi__Item_Class__r.Fon_Is_Local_Membership__c=true)
                                                  AND OrderApi__Subscription_Start_Date__c!=Null)
                                                 from OrderApi__Sales_Order__c 
                                                 where OrderApi__Contact__c=:contactId                                                
                                                 AND OrderApi__Status__c='Open'];
        if(openSO.size()>0){
            for(OrderApi__Sales_Order__c soObj: openSO){
                List<OrderApi__Sales_Order_Line__c> soliList= soObj.OrderApi__Sales_Order_Lines__r;
                if(soliList.size()>0){
                    isRenewalSoli=true;
                }
                if(isRenewalSoli){
                    temp.put(isRenewalSoli,soObj.OrderApi__Total__c);
                }
            }
            return temp;
        }
        return temp;
    }
    
    @AuraEnabled
    public static Map<Decimal,List<soliWrapper>> isFullPaidCurrentSubcription(String contactId){
        List<soliWrapper> soliWrapperList = new List<soliWrapper>();
        Map<Decimal,List<soliWrapper>> mp = new Map<Decimal,List<soliWrapper>>();
        isCurrentSubcriptionIsActive(contactId);
        if(entityType=='Invoice'){
            OrderApi__Invoice__c[] invList = [select id,OrderApi__Balance_Due__c,OrderApi__Sales_Order__c,(select Id,OrderApi__Item__r.Name, OrderApi__Balance_Due__c from OrderApi__Invoice_Lines__r) from OrderApi__Invoice__c WHERE OrderApi__Balance_Due__c>0 AND OrderApi__Sales_Order__c =:soId];
            if(invList.size()==0){//Full Paid
                return mp;  
            }
            else{       
                List<OrderApi__Invoice_Line__c> invLineList=invList[0].OrderApi__Invoice_Lines__r;
                if(invLineList.size()>0){
                    for(OrderApi__Invoice_Line__c soliObj:invLineList){
                        soliWrapperList.add(new soliWrapper(soliObj.OrderApi__Item__r.Name,soliObj.OrderApi__Balance_Due__c,invList[0].OrderApi__Sales_Order__c,invList[0].Id));
                    }
                    mp.put(invList[0].OrderApi__Balance_Due__c,soliWrapperList);
                }
                return mp;
            }
        }
        
        return mp;
    }
    
    @AuraEnabled
    public static Map<Decimal,List<soliWrapper>> checkCurrentDuesSO(String contactId){
        List<soliWrapper> soliWrapperList = new List<soliWrapper>();
        Map<Decimal,List<soliWrapper>> mp = new Map<Decimal,List<soliWrapper>>();
        OrderApi__Sales_Order__c[] soList = [select id,
                                             OrderApi__Total__c,
                                             (select OrderApi__Item__r.Name,OrderApi__Total__c from OrderApi__Sales_Order_Lines__r) 
                                             from OrderApi__Sales_Order__c
                                             where OrderApi__Contact__c=:contactId 
                                             AND OrderApi__Contact__r.Fon_AAFP_Subscription_Plan_Picklist__c!='Installment'
                                             AND OrderApi__Posting_Entity__c='Receipt'
                                             AND OrderApi__Is_Posted__c!=true
                                             AND OrderApi__Status__c='Closed'
                                             AND Fon_Salesorder_Type__c!='Donation'
                                             AND (Fon_Membership_Staging__r.Fon_Staging_Status__c!='Cancelled' OR Fon_Membership_Staging__c=null)
                                             Limit 1
                                            ];
        
        if(soList.size()==0){
            return mp;
        }
        List<OrderApi__Sales_Order_Line__c> soliList=soList[0].OrderApi__Sales_Order_Lines__r;
        if(soliList.size()>0){
            for(OrderApi__Sales_Order_Line__c soliObj:soliList){
                soliWrapperList.add(new soliWrapper(soliObj.OrderApi__Item__r.Name,soliObj.OrderApi__Total__c,soList[0].Id,''));
            }
            mp.put(soList[0].OrderApi__Total__c,soliWrapperList);
        }
        
        return mp;
    }
    
    public class soliWrapper{
        @AuraEnabled public String itemName       {get;set;}
        @AuraEnabled public Decimal balanceAmount {get;set;}
        @AuraEnabled public String salesOrderId   {get;set;}
        @AuraEnabled public String invoiceId      {get;set;}
        
        public soliWrapper(String itemName, Decimal balanceAmount,String salesOrderId,String invoiceId){
            this.itemName = itemName;
            this.balanceAmount = balanceAmount;
            this.salesOrderId = salesOrderId;
            this.invoiceId = invoiceId;
        }
    }
    
    @AuraEnabled
    public static Boolean changeSubscriptionPlan(String contactId,String newSubscriptionPlan){
        Contact[] con = [select Fon_AAFP_Subscription_Plan_Picklist__c from contact WHERE id=:contactId];
        if(con.size()==0){
            return false;
        }
        con[0].Fon_AAFP_Subscription_Plan_Picklist__c=newSubscriptionPlan;
        update con;
        return true;
    }
    
}