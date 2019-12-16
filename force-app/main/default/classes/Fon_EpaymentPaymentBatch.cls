global class Fon_EpaymentPaymentBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    String query;
    boolean check;
    private set<Id> paymentIds;
    
    global Fon_EpaymentPaymentBatch(){
        
    }
    
    global Fon_EpaymentPaymentBatch(set<Id> payIds){
        this.paymentIds = payIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        If(paymentIds==NULL){
            query = 'select id,Fon_IsPaymentProcessBatch__c,OrderApi__Contact__c,OrderApi__Sales_Order__c, OrderApi__Sales_Order__r.OrderApi__Payment_Method__c,OrderApi__Sales_Order__r.OrderApi__Payment_Method__r.OrderApi__Payment_Method_Token__c from OrderApi__EPayment__c where Fon_IsPaymentProcessBatch__c=true';
        }else{
            query = 'select id,Fon_IsPaymentProcessBatch__c,OrderApi__Contact__c,OrderApi__Sales_Order__c, OrderApi__Sales_Order__r.OrderApi__Payment_Method__c,OrderApi__Sales_Order__r.OrderApi__Payment_Method__r.OrderApi__Payment_Method_Token__c from OrderApi__EPayment__c where Id=:paymentIds';
        }
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<OrderApi__EPayment__c> EP){
        if(EP.size()>0){
            Contact con = new Contact(Id=EP[0].OrderApi__Contact__c);
            Boolean installmentAplied = FALSE;
            
            FDService.PaymentRequest objPR = FDService.PaymentRequest.getInstance();
            objPR.record = EP[0].Id; //Epayment Id
            objPR.paymentGateway = null;
            objPR.paymentMethod = EP[0].OrderApi__Sales_Order__r.OrderApi__Payment_Method__c;
            objPR.paymentMethodToken = EP[0].OrderApi__Sales_Order__r.OrderApi__Payment_Method__r.OrderApi__Payment_Method_Token__c;
            objPR.contact = EP[0].OrderApi__Contact__c;
            if(!Test.isRunningTest()){
                FDService.OrderPaymentService.getInstance().pay(objPR);
            }
            else{
                check=true;
            }
            
            OrderApi__EPayment__c epayAfterPayment = [Select Id, OrderApi__Succeeded__c, (Select Id, OrderApi__Sales_Order_Line__c From OrderApi__EPayment_Lines__r), OrderApi__Sales_Order__r.Fon_Membership_Staging__r.Fon_AAFP_Subscription_Plan_Picklist__c From OrderApi__EPayment__c Where Id=:EP[0].Id];
            if(epayAfterPayment.OrderApi__Succeeded__c){
                map<Id, Integer> solInstallments = new  map<Id, Integer>();
                if(epayAfterPayment.OrderApi__Sales_Order__r.Fon_Membership_Staging__r.Fon_AAFP_Subscription_Plan_Picklist__c == 'Installment'){ 
                    solInstallments = Fon_SalesorderPaymentBatch.soAndInstallments(EP[0].OrderApi__Sales_Order__c);
                }
                Integer installment = NULL;
                for(OrderApi__EPayment_Line__c ePayLine :  epayAfterPayment.OrderApi__EPayment_Lines__r){
                    if(solInstallments.get(ePayLine.OrderApi__Sales_Order_Line__c)!=NULL){
                        installment = solInstallments.get(ePayLine.OrderApi__Sales_Order_Line__c);
                        if(installment>0){
                            con.Fon_No_of_Remaining_installments__c = installment - 1;
                            if(con.Fon_No_of_Remaining_installments__c>0){
                                Date myDate = System.Today();
                                con.Fon_Next_Payment_Month__c =myDate.addMonths(1).month();
                                con.Fon_AAFP_Subscription_Plan_Picklist__c = epayAfterPayment.OrderApi__Sales_Order__r.Fon_Membership_Staging__r.Fon_AAFP_Subscription_Plan_Picklist__c;
                                installmentAplied = TRUE;
                            }
                        }
                    }
                }
                if(installmentAplied)
                    Update con;
                
            }
            // EP[0].Fon_IsPaymentProcessBatch__c=false;
            // update EP;
        }
    }
    
    global void finish(Database.BatchableContext BC) {}
}