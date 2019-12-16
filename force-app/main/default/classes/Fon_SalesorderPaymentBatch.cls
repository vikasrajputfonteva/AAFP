global class Fon_SalesorderPaymentBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    String query;
    boolean check;
    Boolean isEpaymentRecordCreated=false;
    private Set<Id> membershipStaging ;
    public Map<string, set<Id>> epaymentIds ;
    public static date endDate;
    
    public Fon_SalesorderPaymentBatch(){
        
    }
    
    public Fon_SalesorderPaymentBatch(set<Id> stagingIds){
        this.membershipStaging = stagingIds;
        epaymentIds = new Map<string, set<Id>>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Set <string> soType = new set<string>{'Donation','Dues'};
            // get all SO(in a ordered way so that Donation SO processed first) for Stagings 
            query = 'select id'+
            ', OrderApi__Payment_Method__c'+
            ', OrderApi__Contact__c'+
            ', OrderApi__Payment_Method__r.OrderApi__Payment_Method_Token__c'+
            ', OrderApi__Posting_Entity__c'+
            ', OrderApi__Posting_Status__c '+
            ', Fon_Membership_Staging__c'+
            ', Fon_Salesorder_Type__c'+
            ', Fon_Membership_Staging__r.Fon_AAFP_Subscription_Plan_Picklist__c '+
            ', OrderApi__Is_Posted__c'+
            ', OrderApi__Status__c'+
            ' From OrderApi__Sales_Order__c '+
            ' Where Fon_is_Dues_Paid_by_Chapter_Residency__c=FALSE '+
            ' AND OrderApi__Payment_Method__c !=Null AND OrderApi__Total__c>0'+
            ' AND Fon_Membership_Staging__c=:membershipStaging '+
            ' AND Fon_Salesorder_Type__c =:soType'+
            ' ORDER BY Fon_Salesorder_Type__c ';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<OrderApi__Sales_Order__c> SO){
        system.debug('inside execute');
        
        OrderApi__Sales_Order__c soToProcess = SO.size()>0?SO[0]:NULL;
        if(soToProcess==NULL)
            return;
        
        Map<string, Set<Id>> returnedPayments = procesSalesOrderPayment(soToProcess);
        if(returnedPayments!=NULL){
            if(returnedPayments.get('Invoice') != NULL){
                Set<Id> soIds = returnedPayments.get('Invoice');
                //if(epaymentIds != NULL){
                if(epaymentIds.get('Invoice') != NULL){
                    epaymentIds.get('Invoice').addAll(soIds);
                }else{
                    epaymentIds.put('Invoice', soIds);
                }                   
                //}
            }
            
            if(returnedPayments.get('Epayment') != NULL){
                Set<Id> payIds = returnedPayments.get('Epayment');
                //if(epaymentIds != NULL){
                if(epaymentIds.get('Epayment') != NULL){
                    epaymentIds.get('Epayment').addAll(payIds);
                }else{
                    epaymentIds.put('Epayment', payIds);
                }                   
                //}
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
        // Call Sales Order batch
        if(epaymentIds.containsKey('Invoice')){
            Datetime sysTime = System.now();
            sysTime = sysTime.addSeconds(35);
            String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            set<Id> stagingIds = epaymentIds.get('Invoice');
            Fon_SalesorderPaymentSchedulable scheduler = new Fon_SalesorderPaymentSchedulable(stagingIds);
            String name = 'Callout Fon_SalesorderPaymentBatch' + String.valueOf(DateTime.now());
            if(stagingIds != NULL){
                System.schedule(name,chron_exp,scheduler);
            }
            
        }
        // Call Payment batch
        if(epaymentIds.containsKey('Epayment')){
            set<Id> payIds = epaymentIds.get('Epayment');
            if(payIds != NULL){
                Fon_EpaymentPaymentBatch btch = new Fon_EpaymentPaymentBatch(payIds);
                Database.executeBatch(btch,1);  
            }
        }    
    }
    
    // method to process SO using Credit line or using Epayment
    public static Map<string, Set<Id>> procesSalesOrderPayment(OrderApi__Sales_Order__c soToProcess){
        Framework.Log.push(Fon_SalesorderPaymentBatch.class.getName(),'procesSalesOrderPayment'); 
        Map<string, Set<Id>> paymentids = new Map<string, Set<Id>>();
        Contact con = new Contact(Id=soToProcess.OrderApi__Contact__c);
        // get available credit for given Contact
        List<OrderApi__Credit_Memo__c> cmlIST= getCreditMemoList(soToProcess.OrderApi__Contact__c);
        Boolean isInvoiced = TRUE;        
        // if SO is a Donation, pay it`
        if(soToProcess.Fon_Salesorder_Type__c == 'Donation'
           && soToProcess.OrderApi__Posting_Entity__c=='Receipt'){
               paySoReceipt(soToProcess);
               system.debug('process DONATION receipt');
           }else{
               // for Dues SO of Receipt Type
               if(soToProcess.Fon_Salesorder_Type__c == 'Dues'
                  && soToProcess.OrderApi__Posting_Entity__c=='Receipt'){
                      // check whether Donation SO exist for given Staging record and already paid
                      if(checkDonationIsPaid(soToProcess.Fon_Membership_Staging__c)){
                          system.debug('process DUES receipt');
                          if(cmlIST.size()==0){
                              paySoReceipt(soToProcess);
                          }else{
                              system.debug('Credit available , change so To invoice');
                              soToProcess.OrderApi__Posting_Entity__c='Invoice';
                              soToProcess.OrderApi__Schedule_Type__c = 'Simple Invoice';
                              soToProcess.OrderApi__Status__c = 'Open';
                              try{
                                  update soToProcess;
                              }catch(exception ex){
                                  system.debug('Error occurred during SO conversion = ' + ex.getMessage());
                                  return paymentids;
                              }
                              
                              //Post Invoice if it is not posted
                              if(soToProcess.OrderApi__Status__c ==  'Open'){
                                  system.debug('Post SO');
                                  soToProcess.OrderApi__Status__c = 'Closed';
                                  system.debug('close SO');
                                  update soToProcess;
                              }
                              
                              //Post Invoice if it is not posted
                              if(soToProcess.OrderApi__Is_Posted__c == FALSE){
                                  system.debug('Post SO');
                                  soToProcess.OrderApi__Is_Posted__c = true;
                                  update soToProcess;
                              }
                              paymentids.put('Invoice', new Set<Id>{soToProcess.Fon_Membership_Staging__c});
                              isInvoiced = FALSE;
                          }
                      }else{
                          system.debug('Donation SO not paid');
                          return paymentids;
                      }
                  }
               if(soToProcess.OrderApi__Posting_Entity__c == 'Invoice' && isInvoiced){ // for Dues SO of Invoice Type
                   // check whether Donation SO paid
                   system.debug('Process invoice');
                   // check whether Donation SO exist for given Staging record and already paid
                   if(!checkDonationIsPaid(soToProcess.Fon_Membership_Staging__c)){ 
                       system.debug('Donation SO not paid');
                       return paymentids;
                   }
                   
                   system.debug('jmd So ID--'+soToProcess.Id);
                   system.debug('jmd OrderApi__Status__c--'+soToProcess.OrderApi__Status__c);
                   //Post Invoice if it is not posted
                   if(soToProcess.OrderApi__Status__c == 'Open'){
                       system.debug('close SO');
                       soToProcess.OrderApi__Status__c = 'Closed';
                       update soToProcess;
                   }
                   
                   //Post Invoice if it is not posted
                   if(soToProcess.OrderApi__Is_Posted__c == FALSE){
                       system.debug('Post SO');
                       soToProcess.OrderApi__Is_Posted__c = true;
                       try{
                           update soToProcess;
                       }
                       catch(Exception ex){
                           system.debug('Jmd Exception--> '+ ex.getMessage());
                           system.debug('Jmd Exception Line--> '+ ex.getLineNumber());
                       }
                       system.debug('Post SO');
                   }
                   // get Invoice data
                   OrderApi__Invoice__c invoiceList = getInvoiceBySO(soToProcess.Id);
                   
                   Set<Id> invoiceIds = new set<Id>{invoiceList.Id};                                                
                       // check installment or FULL Pay                                                 
                       if(soToProcess.Fon_Membership_Staging__r.Fon_AAFP_Subscription_Plan_Picklist__c=='Auto Full Pay'){
                           con.Fon_Frequency__c = 1;
                           if(cmlIST.size()>0){
                               payUsingCReditMemoLine(invoiceList, cmlIST, NULL);
                               //Code for paying from epayment 
                               OrderApi__Invoice__c[] balanceDueInvoiceList = new List<OrderApi__Invoice__c>{getInvoiceBySO(soToProcess.Id)} ;
                                   if(balanceDueInvoiceList.size()==0 
                                      || balanceDueInvoiceList[0] == NULL){
                                          return paymentids;
                                      }
                               if(balanceDueInvoiceList[0] != NULL)
                                   invoiceIds = new set<Id>{balanceDueInvoiceList[0].Id}; 
                                       }
                           paymentids.put('Epayment', createEpaymentLine(invoiceIds, NULL)); 
                       }
                   else if(soToProcess.Fon_Membership_Staging__r.Fon_AAFP_Subscription_Plan_Picklist__c=='Installment'){
                       con.Fon_Frequency__c = 12;
                       map<Id, Integer> solInstallments = soAndInstallments(soToProcess.Id);
                       Map<Id,Decimal> invoiceLineToInstallmentAmount = new Map<Id,Decimal>();
                       integer installment = 1;
                       Boolean installmentFound = FALSE;    
                       
                       for(OrderApi__Invoice_Line__c invLineObj :invoiceList.OrderApi__Invoice_Lines__r){
                           installment = 1; 
                           system.debug('Installment = ' + solInstallments.get(invLineObj.OrderApi__Sales_Order_Line__c)); 
                           if(solInstallments.get(invLineObj.OrderApi__Sales_Order_Line__c)!=NULL){
                               installment = solInstallments.get(invLineObj.OrderApi__Sales_Order_Line__c);
                               installmentFound = TRUE;
                           }
                           Decimal balanceDue;
                           if(installment>0){
                               balanceDue = (invLineObj.OrderApi__Balance_Due__c/installment);
                           }
                           else{
                               balanceDue = invLineObj.OrderApi__Balance_Due__c;
                           }
                           balanceDue = balanceDue.setScale(2, RoundingMode.HALF_UP);
                           invoiceLineToInstallmentAmount.put(invLineObj.Id,balanceDue);
                       }
                       
                       //Added code 14 nov 
                       if(installmentFound){
                           Date myDate = System.Today();
                           if(System.today().day() <= Integer.valueOf(System.Label.Fon_10)){
                               con.Fon_No_of_Remaining_installments__c = installment+1;
                               con.Fon_Next_Payment_Month__c = myDate.month();
                           }
                           else{
                               con.Fon_No_of_Remaining_installments__c = installment;
                               if(endDate.month()==myDate.month()){//If End date and today's date month is same
                                   con.Fon_Next_Payment_Month__c = myDate.month();
                               }
                               else{
                                   con.Fon_Next_Payment_Month__c = myDate.addMonths(1).month();
                               }
                                  
                              }
                          }
                          
                          //-------------------------------------------------------------------------------dd Commented 14 nov
                          /*
if(cmlIST.size()>0){
payUsingCReditMemoLine(invoiceList, cmlIST, invoiceLineToInstallmentAmount);    
//Code for paying from epayment 
OrderApi__Invoice__c[] balanceDueInvoiceList = new List<OrderApi__Invoice__c>{getInvoiceBySO(soToProcess.Id)};
if(balanceDueInvoiceList.size()==0 || balanceDueInvoiceList[0] == NULL){
system.debug('balance found ') ;
if(installmentFound){
system.debug('Installment applied = ' + installment ) ;
con.Fon_No_of_Remaining_installments__c = installment - 1;
if(con.Fon_No_of_Remaining_installments__c>0){
Date myDate = System.Today();
con.Fon_Next_Payment_Month__c = myDate.addMonths(1).month();
con.Fon_AAFP_Subscription_Plan_Picklist__c = soToProcess.Fon_Membership_Staging__r.Fon_AAFP_Subscription_Plan_Picklist__c;
}

}
return paymentids;
}
invoiceIds = new set<Id>{balanceDueInvoiceList[0].Id}; 

if(installmentFound){
system.debug('Installment applied = ' + installment ) ;
con.Fon_No_of_Remaining_installments__c = installment - 1;
if(con.Fon_No_of_Remaining_installments__c>0){
Date myDate = System.Today();
con.Fon_Next_Payment_Month__c = myDate.addMonths(1).month();
con.Fon_AAFP_Subscription_Plan_Picklist__c = soToProcess.Fon_Membership_Staging__r.Fon_AAFP_Subscription_Plan_Picklist__c;
}
}
}
paymentids.put('Epayment', createEpaymentLine(invoiceIds,invoiceLineToInstallmentAmount));
*/
                          //-------------------------------------------------------------------------------------------------dd
                      }
                  }
               update con;
           }
        Framework.Log.pop();
        return paymentids;
    }
    
    public static map<id, Integer> soAndInstallments(Id so){
        map<Id, Integer> solInstallments = new map<Id, Integer>();
        
        for(OrderApi__Sales_Order_Line__c soLine : [Select Id, OrderApi__Activation_Date__c, OrderApi__End_Date__c, OrderApi__Subscription_Start_Date__c 
                                                    From OrderApi__Sales_Order_Line__c 
                                                    Where OrderApi__Sales_Order__c=:so
                                                    AND OrderApi__Is_Subscription__c=TRUE
                                                    AND OrderApi__Activation_Date__c!=NULL
                                                    AND OrderApi__End_Date__c!=NULL
                                                    AND OrderApi__Sales_Order__r.Fon_Membership_Staging__r.Fon_AAFP_Subscription_Plan_Picklist__c='Installment']){
                                                        endDate= soLine.OrderApi__End_Date__c;
                                                        integer installment = soLine.OrderApi__Subscription_Start_Date__c.monthsBetween(soLine.OrderApi__End_Date__c);
                                                        solInstallments.put(soLine.Id, installment);
                                                    }
        return solInstallments; 
    }   
    
    public static void payUsingCReditMemoLine(OrderApi__Invoice__c invoiceList, List<OrderApi__Credit_Memo__c> cmlIST, map<Id, Decimal> installmentAmount){
        Set<Id> appliedCreditMemoIds = new Set<Id>();
        Set<Id> greaterCreditMemoIds = new Set<Id>();
        Map<Id,Decimal> idVSremain = new Map<Id,Decimal>();
        List<OrderApi__Credit_Memo_Line__c> insertCreditMemoLine = new List<OrderApi__Credit_Memo_Line__c>();
        
        for(OrderApi__Invoice_Line__c invLineObj :invoiceList.OrderApi__Invoice_Lines__r){
            Decimal balanceDue = (installmentAmount!=NULL) ? installmentAmount.get(invLineObj.Id) : invLineObj.OrderApi__Balance_Due__c;
            for(OrderApi__Credit_Memo__c CM : cmlIST){
                if(appliedCreditMemoIds.contains(CM.id) && !greaterCreditMemoIds.contains(CM.id)){
                    continue;
                }
                else if(idVSremain.containsKey(CM.id)){
                    if(idVSremain.get(CM.id)==balanceDue){
                        greaterCreditMemoIds.remove(CM.id);
                        insertCreditMemoLine.add(createInstanceOfCreditMemoLine(CM.Id,invoiceList.Id,balanceDue,invLineObj.Id));
                        break;
                    }
                    if(idVSremain.get(CM.id)>balanceDue){
                        Decimal temp = idVSremain.get(CM.id)-balanceDue;
                        idVSremain.put(CM.Id,temp);
                        insertCreditMemoLine.add(createInstanceOfCreditMemoLine(CM.Id,invoiceList.Id,balanceDue,invLineObj.Id));
                        break;
                    }
                    else if(idVSremain.get(CM.id)<balanceDue){
                        balanceDue =balanceDue-idVSremain.get(CM.id);
                        greaterCreditMemoIds.remove(CM.id);
                        insertCreditMemoLine.add(createInstanceOfCreditMemoLine(CM.Id,invoiceList.Id,idVSremain.get(CM.id),invLineObj.Id));
                        continue;
                    }
                }
                if(CM.OrderApi__Remaining_Amount__c==balanceDue){
                    appliedCreditMemoIds.add(CM.Id);   
                    insertCreditMemoLine.add(createInstanceOfCreditMemoLine(CM.Id,invoiceList.Id,balanceDue,invLineObj.Id));
                    break;
                }
                else if(CM.OrderApi__Remaining_Amount__c>balanceDue){  
                    appliedCreditMemoIds.add(CM.Id);
                    greaterCreditMemoIds.add(CM.Id);
                    idVSremain.put(CM.Id,CM.OrderApi__Remaining_Amount__c-balanceDue);
                    insertCreditMemoLine.add(createInstanceOfCreditMemoLine(CM.Id,invoiceList.Id,balanceDue,invLineObj.Id));
                    break;
                }
                else if(CM.OrderApi__Remaining_Amount__c<balanceDue){
                    appliedCreditMemoIds.add(CM.Id);  
                    balanceDue = balanceDue-CM.OrderApi__Remaining_Amount__c;
                    insertCreditMemoLine.add(createInstanceOfCreditMemoLine(CM.Id,invoiceList.Id,CM.OrderApi__Remaining_Amount__c,invLineObj.Id));
                    continue;
                }   
            }
        }
        
        if(insertCreditMemoLine.size()>0){
            // Framework.Dispatcher.disableTriggerInContext.put('OrderApi__Invoice_Line__c',true);
            insert insertCreditMemoLine;
            for(OrderApi__Credit_Memo_Line__c cml:insertCreditMemoLine){
                cml.OrderApi__Status__c='Posted';
            }
            update insertCreditMemoLine;
            updateCreditAmtToSoli(insertCreditMemoLine); // Updating Credit_Apply_Amount under the "Sales Order Line"
        }
    }
    
    public static set<Id> createEpaymentLine(Set<Id> invoiceIds, Map<Id,Decimal> invAmount ){
        //Creating Epayment record of Invoice
        Set<Id> epaymentIds = new Set<Id>();    
        OrderApi.EPayment epaymentObj = new OrderApi.EPayment();
        List<OrderApi__Invoice__c> invoices ;
        if(!Test.isRunningTest()){
            invoices = (List<OrderApi__Invoice__c>) new Framework.Selector(OrderApi__Invoice__c.SObjectType,OrderApi__Invoice_Line__c.OrderApi__Invoice__c).selectById(invoiceIds);
        }else{
            invoices = [select id ,OrderApi__Status__c,OrderApi__Business_Group__c,OrderApi__Entity__c,OrderApi__Contact__c,OrderApi__Account__c,
                        OrderApi__Sales_Order__c,OrderApi__Balance_Due__c,
                        (select id from OrderApi__Invoice_Lines__r) from OrderApi__Invoice__c  ];
        }
        if(invoices.size()>0){
            epaymentObj.buildEpayment(invoices);
            epaymentObj.constructEPayment();
            system.debug('E payment got created');
        }
        List<OrderApi__EPayment_Line__c> updateEpaymentLine = new List<OrderApi__EPayment_Line__c>();
        List<OrderApi__EPayment_Line__c> deleteEpaymentLine = new List<OrderApi__EPayment_Line__c>();
        
        
        List<OrderApi__EPayment_Line__c> epaymentLineList = [select id,OrderApi__Sale_Price__c,OrderApi__EPayment__c,OrderApi__Invoice_Line__c,OrderApi__Invoice_Line__r.OrderApi__Credits_Applied__c, 
                                                             OrderApi__Total__c, OrderApi__Quantity__c from OrderApi__EPayment_Line__c where OrderApi__Invoice__c in:invoiceIds AND OrderApi__Invoice_Line__c!=NULL];
        for(OrderApi__EPayment_Line__c epList :epaymentLineList){
            epaymentIds.add(epList.OrderApi__EPayment__c);
            // system.debug(' inv line in test = ' + epList.OrderApi__Invoice_Line__c);
            
            if(invAmount!=NULL){
                // for(id key : invAmount.keyset()){
                //     system.debug('key = ' + key + ' value = ' + invAmount.get(key));
                //  }
                if(epList.OrderApi__Invoice_Line__r.OrderApi__Credits_Applied__c>=invAmount.get(epList.OrderApi__Invoice_Line__c)){
                    deleteEpaymentLine.add(epList);
                } else {
                    if(test.isRunningTest()){
                        epList.OrderApi__Sale_Price__c = invAmount.get(epList.OrderApi__Invoice_Line__c) - 0;
                    }else{
                        epList.OrderApi__Sale_Price__c = invAmount.get(epList.OrderApi__Invoice_Line__c) - epList.OrderApi__Invoice_Line__r.OrderApi__Credits_Applied__c;
                    }
                    
                    epList.OrderApi__Total__c = epList.OrderApi__Sale_Price__c * epList.OrderApi__Quantity__c ;
                    updateEpaymentLine.add(epList);
                }
            }
            
        }
        
        if(epaymentLineList.size() > 0 && epaymentLineList.size()==deleteEpaymentLine.size()){ // delete Epayment if all lines need to delete
            system.debug('delete e payment');
            OrderApi__EPayment__c epayTOdelete =  new OrderApi__EPayment__c (id = epaymentLineList[0].OrderApi__EPayment__c);
            epaymentIds.remove(epayTOdelete.Id);
            Delete epayTOdelete;
        }else{ // delete only ePayment Line
            if(invAmount!=NULL){
                system.debug('delete e payment line');
                delete deleteEpaymentLine;
            }
        }
        
        update updateEpaymentLine;
        system.debug('e payment size = ' + epaymentIds.size());
        return epaymentIds;                
        
        
    }
    
    public static List<OrderApi__Credit_Memo__c> getCreditMemoList(id conId){
        return [select id 
                ,OrderApi__Remaining_Amount__c
                ,OrderApi__Contact__c 
                From OrderApi__Credit_Memo__c 
                Where OrderApi__Remaining_Amount__c>0 
                AND Fon_Suggested_Usage__c=:System.Label.Fon_Memberships
                AND Fon_Required__c=TRUE 
                AND OrderApi__Contact__c =: conId
                Order By OrderApi__Remaining_Amount__c ];
        
    }
    
    public static boolean checkDonationIsPaid(Id stagingId ){
        
        OrderApi__Sales_Order__c[] SOs = [Select Id ,OrderApi__Posting_Status__c  From OrderApi__Sales_Order__c Where Fon_Membership_Staging__c=:stagingId AND Fon_Salesorder_Type__c='Donation'];
        if(SOs.size()==0){
            return TRUE;
        }else if(SOs[0].OrderApi__Posting_Status__c == 'Posted'){
            return TRUE;
        }else{
            return FALSE;
        }       
    }
    
    public static void paySoReceipt(OrderApi__Sales_Order__c SO){
        FDService.PaymentRequest objPR = FDService.PaymentRequest.getInstance();
        objPR.record = SO.Id; //Salesorder Id
        objPR.paymentGateway = null;
        objPR.paymentMethod = SO.OrderApi__Payment_Method__c;
        objPR.paymentMethodToken = SO.OrderApi__Payment_Method__r.OrderApi__Payment_Method_Token__c;
        objPR.contact = SO.OrderApi__Contact__c;
        if(!Test.isRunningTest()){
            FDService.OrderPaymentService.getInstance().pay(objPR);
        }
    }
    
    public static OrderApi__Invoice__c getInvoiceBySO(id SOID){
        List<OrderApi__Invoice__c> invoices = [select id, OrderApi__Balance_Due__c,  OrderApi__Contact__c,
                                               (select id,OrderApi__Balance_Due__c, OrderApi__Sales_Order_Line__c from OrderApi__Invoice_Lines__r where OrderApi__Balance_Due__c>0)
                                               from OrderApi__Invoice__c 
                                               where OrderApi__Sales_Order__c=:SOID
                                               And OrderApi__Balance_Due__c>0];
        
        if(invoices.size()>0){
            return invoices[0];
        }else{
            return NULL;
        }
        
    }
    
    public Static OrderApi__Credit_Memo_Line__c createInstanceOfCreditMemoLine(Id creditMemoId,Id invoiceId,Decimal amount,Id invLineId){
        OrderApi__Credit_Memo_Line__c creditMemoLineObj = new OrderApi__Credit_Memo_Line__c();
        creditMemoLineObj.OrderApi__Credit_Memo__c=creditMemoId;
        creditMemoLineObj.OrderApi__Invoice__c=invoiceId;
        creditMemoLineObj.OrderApi__Amount__c=amount;
        creditMemoLineObj.OrderApi__Invoice_Line__c=invLineId;
        return creditMemoLineObj;
    }
    
    /*
@Description: This method will be used to update "Credits_Applied" amount under the Sales Order Line
@Author: Vikas Rajput
*/
    public static void updateCreditAmtToSoli(List<OrderApi__Credit_Memo_Line__c> lstCreditMemoLine){
        Map<Id,Decimal> mapInvoicLnIdToAmount = new Map<Id,Decimal>();
        Set<Id> setInvoiceIDs = new Set<Id>();
        for(OrderApi__Credit_Memo_Line__c objCreditMemoLine : lstCreditMemoLine){
            setInvoiceIDs.add(objCreditMemoLine.OrderApi__Invoice__c);
        }
        Map<Id, OrderApi__Invoice__c> mapInvoiIdToObjPostedInvoice = fetchPostedInvoice(setInvoiceIDs);
        Map<Id,OrderApi__Invoice_Line__c> mapIdToObjInvoiceLine = fetchInvoiceLineMapByLstInvoice(mapInvoiIdToObjPostedInvoice.values());
        for(OrderApi__Credit_Memo_Line__c eachCreditMemoLine : lstCreditMemoLine){
            if(mapInvoiIdToObjPostedInvoice.containsKey(eachCreditMemoLine.OrderApi__Invoice__c) ){
                if(mapInvoicLnIdToAmount.containsKey(eachCreditMemoLine.OrderApi__Invoice_Line__c)){
                    Decimal totalAppliedAmount = mapInvoicLnIdToAmount.get(eachCreditMemoLine.OrderApi__Invoice_Line__c);
                    totalAppliedAmount = totalAppliedAmount + eachCreditMemoLine.OrderApi__Amount__c;
                    mapInvoicLnIdToAmount.put(eachCreditMemoLine.OrderApi__Invoice_Line__c, totalAppliedAmount);
                }else{
                    mapInvoicLnIdToAmount.put(eachCreditMemoLine.OrderApi__Invoice_Line__c, eachCreditMemoLine.OrderApi__Amount__c);
                }
            }
        }
        updateInvoicePostingStatus(mapInvoiIdToObjPostedInvoice, false);
        List<OrderApi__Invoice_Line__c> lstInvoiceLine = new List<OrderApi__Invoice_Line__c>();
        for(Id invoiceLnId : mapInvoicLnIdToAmount.keySet()){
            if(mapIdToObjInvoiceLine.containsKey(invoiceLnId)){
                Decimal balanceDue = mapIdToObjInvoiceLine.get(invoiceLnId).OrderApi__Total__c - mapInvoicLnIdToAmount.get(invoiceLnId);
                lstInvoiceLine.add(new OrderApi__Invoice_Line__c(Id = invoiceLnId, OrderApi__Credits_Applied__c = mapInvoicLnIdToAmount.get(invoiceLnId), OrderApi__Balance_Due__c = balanceDue));
            }
        }
        if(!lstInvoiceLine.isEmpty()){
            update lstInvoiceLine;
        }
        updateInvoicePostingStatus(mapInvoiIdToObjPostedInvoice, true);
    }
    
    //This function will return posted "Invoice" against posted "SalesOrder"
    public static Map<Id, OrderApi__Invoice__c> fetchPostedInvoice(Set<Id> argSetOfInvoiceIDs){
        String strPostedLabel = 'Posted';
        return new Map<Id, OrderApi__Invoice__c>([select id,OrderApi__Is_Posted__c,OrderApi__Sales_Order__r.OrderApi__Posting_Status__c,
                                                  OrderApi__Sales_Order__r.OrderApi__Is_Posted__c,(select id,OrderApi__Balance_Due__c,OrderApi__Total__c from OrderApi__Invoice_Lines__r WHERE OrderApi__Total__c != null) from OrderApi__Invoice__c
                                                  where Id IN : argSetOfInvoiceIDs AND OrderApi__Sales_Order__r.OrderApi__Is_Posted__c = true AND OrderApi__Sales_Order__r.OrderApi__Posting_Status__c =:strPostedLabel]);
    }
    
    //Updating posting status of "Invoice" 
    public static void updateInvoicePostingStatus(Map<Id, OrderApi__Invoice__c> mapArgInvoiIdToObjPostedInvoice, Boolean postingStatus){
        if(mapArgInvoiIdToObjPostedInvoice != null && !mapArgInvoiIdToObjPostedInvoice.values().isEmpty()){
            for(OrderApi__Invoice__c eachInvoice : mapArgInvoiIdToObjPostedInvoice.values()){
                eachInvoice.OrderApi__Is_Posted__c = postingStatus;
            }
            update mapArgInvoiIdToObjPostedInvoice.values();
        }
    }
    
    //Fetch map of invoice line object against invoice Id
    public static Map<Id,OrderApi__Invoice_Line__c> fetchInvoiceLineMapByLstInvoice(List<OrderApi__Invoice__c> lstInvoice){
        Map<Id,OrderApi__Invoice_Line__c> mapIdToObjInvoiceLine = new Map<Id,OrderApi__Invoice_Line__c>();
        for(OrderApi__Invoice__c eacInvoice : lstInvoice){
            if(eacInvoice.OrderApi__Invoice_Lines__r != null){
                for(OrderApi__Invoice_Line__c objInvLine : eacInvoice.OrderApi__Invoice_Lines__r){
                    mapIdToObjInvoiceLine.put(objInvLine.Id, objInvLine);
                }
            }
        }
        return mapIdToObjInvoiceLine;
    }
    
}