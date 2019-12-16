/*
@Description: Filtering "Membership Stage" records based on "Staging Status" = "Approved",
This is base function to perform further logic.
@Author: RSI
*/
public class Fon_MembershipStagingTriggerHandler{
    
    Map<Id,String> conVSpaymentMethodId = new  Map<Id,String>();
    Set<Id> contactIds = new  Set<Id>();
    public static Boolean processAlreadyInit = false;
    
    public List<OrderApi__Sales_Order__c> initializeMembershipStage(List<Fon_Membership_Staging__c> lstAllStaging){
        List<OrderApi__Sales_Order__c> lstSalesOrder;
        List<Fon_Membership_Staging__c> lstApprovedMembershipStage = new List<Fon_Membership_Staging__c>();
        for(Fon_Membership_Staging__c objStage : lstAllStaging){
            if(objStage.Fon_Staging_Status__c == 'Approved'){
                lstApprovedMembershipStage.add(objStage);    //Getting the approved membership staging record here
            }
        }
        
        if(!lstApprovedMembershipStage.isEmpty()){
            lstSalesOrder = createSalesOrderByMemberStagingV2(lstApprovedMembershipStage);  //Batch process will be called from here
            // lstSalesOrder = createSalesOrderByMemberStaging(lstApprovedMembershipStage);  //Batch process will be called from here
        }
        return lstSalesOrder;
    }
    
    //This method will be passed/used in batch
    public List<OrderApi__Sales_Order__c> createSalesOrderByMemberStagingV2(List<Fon_Membership_Staging__c> lstApprovedMembershipStage){
        List<Fon_Membership_Staging__c> lstErrorReasonMembershipStage = new List<Fon_Membership_Staging__c>();
        Map<Id,Set<String>> mapMemberShipIdToSetItemName = new Map<Id,Set<String>>();
        Set<Id> contactIdSet = new Set<Id>();
        Set<String> subscriptionPlanSet = new Set<String>();
        //  Set<String> convenienceFeeSet = new Set<String>();
        Set<Id> setConIdForDollarInvoice = new Set<Id>();
        //Configuring base line data for further logic
        for(Fon_Membership_Staging__c eachMemberStaging : lstApprovedMembershipStage){
            contactIdSet.add(eachMemberStaging.Fon_Contact__c);
            Set<String> itemNameSet = new Set<String>();
            itemNameSet.add(eachMemberStaging.Fon_National__c); 
            itemNameSet.add(eachMemberStaging.Fon_Chapter__c);
            itemNameSet.add(eachMemberStaging.Fon_Local__c);
            // put Convience as well
            itemNameSet.add(eachMemberStaging.Fon_Convenience_Fee__c);
            
            mapMemberShipIdToSetItemName.put(eachMemberStaging.Id,itemNameSet);
            subscriptionPlanSet.add(eachMemberStaging.Fon_Subscription_Plan__c);
            if(String.isBlank(eachMemberStaging.Fon_ContactID__c) && String.isBlank(eachMemberStaging.Fon_Membership_Type__c)){
                eachMemberStaging.Fon_Error_Reason__c = 'Need to ask about Error Reason';
                lstErrorReasonMembershipStage.add(eachMemberStaging);
            }
            if(eachMemberStaging.Fon_Generate_New_Invoice__c){
                eachMemberStaging.Fon_Is_New__c = true;
                setConIdForDollarInvoice.add(eachMemberStaging.Fon_Contact__c);
            }
            //  convenienceFeeSet.add(eachMemberStaging.Fon_Convenience_Fee__c);
        }
        if(!lstErrorReasonMembershipStage.isEmpty()){
            update lstErrorReasonMembershipStage;   //This line of code will be updated by FD Sevice
        }
        if(!setConIdForDollarInvoice.isEmpty()){
            cancellingInvoice(setConIdForDollarInvoice);
        }
        List<String> lstItemName = new List<String>();
        for(Set<String> eachSetItem : mapMemberShipIdToSetItemName.values()){
            lstItemName.addAll(eachSetItem);
        }
        
        system.debug('jmd--lstItemName--'+lstItemName);
        //lstItemName.addAll(convenienceFeeSet);
        
        Map<String,OrderApi__Item__c> mapItemNameToObjItem = new Map<String,OrderApi__Item__c>();
        Map<id,OrderApi__Item__c> mapItemIdToObjItem = new Map<id,OrderApi__Item__c>();
        
        system.debug('***1. Total CPU USED*** '+Limits.getCpuTime() + '***Available CPU USED*** ' + Limits.getLimitCpuTime());
        
        for(OrderApi__Item__c eachItem : [SELECT Id,
                                          Fon_Is_PAC_Item__c,
                                          Name,
                                          OrderApi__Item_Class__r.Fon_Is_Main_Membership__c,
                                          Is_Foundation_Donation__c 
                                          FROM OrderApi__Item__c 
                                          WHERE (Name IN:lstItemName OR Is_Foundation_Donation__c = true OR Fon_Is_PAC_Item__c = true)]){
                                              mapItemNameToObjItem.put(eachItem.Name,eachItem);                               
                                              mapItemIdToObjItem.put(eachItem.Id,eachItem);
                                          }
        /*
//Convenience Fee
for(OrderApi__Item__c eachItem : [SELECT Id,Fon_Is_PAC_Item__c,Name,OrderApi__Item_Class__r.Fon_Is_Main_Membership__c,Is_Foundation_Donation__c FROM OrderApi__Item__c WHERE Name IN:convenienceFeeSet]){
mapItemNameToObjItem.put(eachItem.Name,eachItem);
}*/
        
        Map<String,OrderApi__Subscription_Plan__c> mapNameToObjSubscriptionPlan = new Map<String,OrderApi__Subscription_Plan__c>();
        for(OrderApi__Subscription_Plan__c eachSubscription : [SELECT Id,Name FROM OrderApi__Subscription_Plan__c WHERE Name IN:subscriptionPlanSet ]){
            mapNameToObjSubscriptionPlan.put(eachSubscription.Name,eachSubscription);
        }
        //Map<OrderApi__Sales_Order__c,OrderApi__Sales_Order__c> mapNewSOToInsertedSO = new Map<OrderApi__Sales_Order__c,OrderApi__Sales_Order__c>();
        //Map<OrderApi__Sales_Order__c,List<FDService.SalesOrderLine>> mapSOTolstSOLI = new Map<OrderApi__Sales_Order__c,List<FDService.SalesOrderLine>>();
        
        map<string, OrderApi__Sales_Order__c> stagingToSalesOrders = new map<string, OrderApi__Sales_Order__c>();
        map<string, List<FDService.SalesOrderLine>> stagingToSalesOrderLines = new map<string, List<FDService.SalesOrderLine>>();
        // Create SO AND SOL
        map<string, Fon_Membership_Staging__c> stagingMaps = new map<string, Fon_Membership_Staging__c>();
        Boolean isConvienceSOCreated = FALSE;
        for(Fon_Membership_Staging__c eachMemberStaging : lstApprovedMembershipStage){
            //mapSOTolstSOLI.put(instanceSalesOrder(eachMemberStaging), instanceOfALLSalesOrderLineItem(eachMemberStaging,mapItemNameToObjItem,mapMemberShipIdToSetItemName,mapNameToObjSubscriptionPlan));
            //mapNewSOToInsertedSO.put(instanceSalesOrder(eachMemberStaging), instanceSalesOrder(eachMemberStaging));
            isConvienceSOCreated = FALSE;
            if(eachMemberStaging.Fon_PAC_Contribution_Information__c > 0 || eachMemberStaging.Fon_Foundation_Contribution_Information__c > 0 ){
                system.debug('***2 start. Total CPU USED*** '+Limits.getCpuTime() + '***Available CPU USED*** ' + Limits.getLimitCpuTime());
                OrderApi__Sales_Order__c SO = instanceSalesOrderV2(eachMemberStaging, TRUE);
                system.debug('***2 finish. Total CPU USED*** '+Limits.getCpuTime() + '***Available CPU USED*** ' + Limits.getLimitCpuTime());
                stagingToSalesOrders.put(eachMemberStaging.id+'_DONATION', SO);
                set<string> itemName = mapMemberShipIdToSetItemName.get(eachMemberStaging.Id);
                for(string key : mapItemNameToObjItem.keyset()){
                    if(mapItemNameToObjItem.get(key).Fon_Is_PAC_Item__c == TRUE
                       && eachMemberStaging.Fon_PAC_Contribution_Information__c > 0){
                           itemName.add(key);
                       }
                    if(mapItemNameToObjItem.get(key).Is_Foundation_Donation__c == TRUE
                       && eachMemberStaging.Fon_Foundation_Contribution_Information__c > 0){
                           itemName.add(key);
                       }
                }
                
                mapMemberShipIdToSetItemName.put(eachMemberStaging.Id, itemName);
                isConvienceSOCreated = TRUE;
            }
            
            if(isConvienceSOCreated == FALSE
               && eachMemberStaging.Fon_AAFP_Subscription_Plan_Picklist__c == 'Installment'){
                   OrderApi__Sales_Order__c SO = instanceSalesOrderV2(eachMemberStaging, TRUE);
                   stagingToSalesOrders.put(eachMemberStaging.id+'_DONATION', SO);
               }   
            
            
            system.debug('***3 start. Total CPU USED*** '+Limits.getCpuTime() + '***Available CPU USED*** ' + Limits.getLimitCpuTime());
            OrderApi__Sales_Order__c soDues = instanceSalesOrderV2(eachMemberStaging, FALSE);
            system.debug('***3 finish. Total CPU USED*** '+Limits.getCpuTime() + '***Available CPU USED*** ' + Limits.getLimitCpuTime());
            system.debug('SO Name = ' + soDues.OrderApi__Account__c);
            stagingToSalesOrders.put(eachMemberStaging.id+'_DUES', soDues);
            
            stagingToSalesOrderLines.put(eachMemberStaging.Id, instanceOfALLSalesOrderLineItemV2(eachMemberStaging
                                                                                                 , mapItemNameToObjItem
                                                                                                 , mapMemberShipIdToSetItemName
                                                                                                 , mapNameToObjSubscriptionPlan));
            stagingMaps.put(eachMemberStaging.id, eachMemberStaging);
        }
        for(string kk : stagingToSalesOrders.keyset()){
            system.debug('Key = ' + kk + ' value = ' + stagingToSalesOrders.get(kk));
        }
        system.debug('***Final SO. Total CPU USED*** '+Limits.getCpuTime() + '***Available CPU USED*** ' + Limits.getLimitCpuTime());
        List<OrderApi__Sales_Order__c> lstSORecord = insertingSalesOrderAndSOLIV2(stagingToSalesOrders
                                                                                  , stagingToSalesOrderLines
                                                                                  , mapItemIdToObjItem
                                                                                  , stagingMaps);
        system.debug('***Final Finish SO. Total CPU USED*** '+Limits.getCpuTime() + '***Available CPU USED*** ' + Limits.getLimitCpuTime());
        return  lstSORecord; //Implementing FD Service here
    }
    
    //Instantiating Sales Order Here
    public OrderApi__Sales_Order__c instanceSalesOrderV2(Fon_Membership_Staging__c objMemberStage, boolean isDonation){
        OrderApi__Sales_Order__c objSO = new OrderApi__Sales_Order__c();                            //This line of code will be updated by FD Sevice
        objSO.Fon_Salesorder_Type__c = 'Dues';
        
        objSO.Fon_Membership_Staging__c = objMemberStage.Id;
        if(objMemberStage.Fon_Payment_Method__c != null){
            objSO.OrderApi__Payment_Method__c = objMemberStage.Fon_Payment_Method__c;
        }
        else if(String.isNotBlank(objMemberStage.Fon_Payment_Method_Id__c)){
            objSO.OrderApi__Payment_Method__c = objMemberStage.Fon_Payment_Method_Id__c;
        }        
        if(objMemberStage.Fon_AAFP_Subscription_Plan_Picklist__c == 'Auto Full Pay' || objMemberStage.Fon_AAFP_Subscription_Plan_Picklist__c == null){// Auto Full Pay
            objSO.OrderApi__Contact__c = objMemberStage.Fon_Contact__c;
            objSO.OrderApi__Account__c = objMemberStage.Fon_Contact__r.AccountId; //Member's Household Account
            objSO.OrderApi__Entity__c = 'Contact';
            objSO.OrderApi__Posting_Entity__c = 'Receipt';
            objSO.OrderApi__Status__c = 'Open';
            objSO.OrderApi__Closed_Status__c = 'Cash Sale';
            objSO.OrderApi__Schedule_Type__c = 'Simple Receipt';
            if(!String.isBlank(objMemberStage.Fon_Payment_Method_Id__c)){
                objSO.Fon_Process_Payment__c = true;
            }
        }
        
        if(objMemberStage.Fon_AAFP_Subscription_Plan_Picklist__c == 'Installment'){//Installment
            objSO.OrderApi__Contact__c = objMemberStage.Fon_Contact__c;
            objSO.OrderApi__Posting_Entity__c = 'Invoice';
            objSO.OrderApi__Status__c = 'Open';
            objSO.OrderApi__Closed_Status__c = 'Cash Sale';
            objSO.OrderApi__Schedule_Type__c = 'Simple Invoice';
            if(!String.isBlank(objMemberStage.Fon_Payment_Method_Id__c)){
                objSO.Fon_Process_Payment__c = true;
            }
            objSO.OrderApi__Entity__c = 'Contact';
            objSO.OrderApi__Account__c = objMemberStage.Fon_Contact__r.AccountId; //Member's Household Account
        }
        
        if(objMemberStage.Fon_Dues_Paid_by_Chapter__c == true || objMemberStage.Fon_Dues_Paid_by_Residency_Program__c == true){
            objSO.OrderApi__Entity__c = 'Account';
            objSO.Fon_is_Dues_Paid_by_Chapter_Residency__c= true;
            objSO.OrderApi__Posting_Entity__c = 'Invoice';
            objSO.OrderApi__Schedule_Type__c = 'Simple Invoice';
            
            if(objMemberStage.Fon_Dues_Paid_by_Residency_Program__c == true){
                if(objMemberStage.Fon_Residency_Account__c!=null){
                    objSO.OrderApi__Account__c = objMemberStage.Fon_Residency_Account__c; 
                }
                else if(String.isNotBlank(objMemberStage.Fon_Residency_Account_ID__c)){
                    objSO.OrderApi__Account__c = objMemberStage.Fon_Residency_Account_ID__c; 
                }
                else{
                      objSO.OrderApi__Account__c = objMemberStage.Fon_Contact__r.AAFP_Residency_program_Account__c; //Member's Residency Program Account
                   // objSO.OrderApi__Account__c = objMemberStage.Fon_Contact__r.Fon_Residency_Program__c; //Member's Residency Program Account
                }
            }else{
                if(objMemberStage.Fon_Chapter_Account__c!=null){
                    objSO.OrderApi__Account__c = objMemberStage.Fon_Chapter_Account__c; 
                }
                else if(String.isNotBlank(objMemberStage.Fon_Chapter_Id__c)){
                    objSO.OrderApi__Account__c = objMemberStage.Fon_Chapter_Id__c; 
                }
            }
        }
        
        if(objMemberStage.Fon_Create_Invoice__c){
            objSO.OrderApi__Posting_Entity__c = 'Invoice';
            objSO.OrderApi__Schedule_Type__c = 'Simple Invoice';
        }
        
        if(isDonation){
            objSO.OrderApi__Posting_Entity__c = 'Receipt';
            objSO.OrderApi__Schedule_Type__c = 'Simple Receipt';
            objSO.Fon_Salesorder_Type__c = 'Donation';
        }
        return objSO;
    }
    
    //Instantiating Sales Order Line Item Here
    public List<FDService.SalesOrderLine> instanceOfALLSalesOrderLineItemV2(Fon_Membership_Staging__c objMemberStage, Map<String,OrderApi__Item__c> mapItemNameToObjItem, Map<Id,Set<String>> mapMemberShipIdToSetItemName, Map<String,OrderApi__Subscription_Plan__c> mapNameToObjSubscriptionPlan){
        List<FDService.SalesOrderLine> lstSalesOrderLineItem = new List<FDService.SalesOrderLine>();
        FDService.SalesOrderLine nationalTypeSoli;
        for(String strItemName : mapMemberShipIdToSetItemName.get(objMemberStage.Id)){
            system.debug('Item name = ' + strItemName + ' convience = ' + objMemberStage.Fon_Convenience_Fee__c + ' installment = ' + objMemberStage.Fon_AAFP_Subscription_Plan_Picklist__c);
            if(mapItemNameToObjItem.containsKey(strItemName)){
                OrderApi__Item__c itemToAdd = mapItemNameToObjItem.get(strItemName);
                if(itemToAdd.Fon_Is_PAC_Item__c 
                   && objMemberStage.Fon_PAC_Contribution_Information__c > 0){
                       FDService.SalesOrderLine objFDServiceSOLI = fetchSalesOrderLineItemFDService(itemToAdd, objMemberStage, mapNameToObjSubscriptionPlan);
                       lstSalesOrderLineItem.add(objFDServiceSOLI);
                       // jump it
                       continue;
                   }
                if(itemToAdd.Is_Foundation_Donation__c 
                   && objMemberStage.Fon_Foundation_Contribution_Information__c > 0){
                       FDService.SalesOrderLine objFDServiceSOLI = fetchSalesOrderLineItemFDService(itemToAdd, objMemberStage, mapNameToObjSubscriptionPlan);
                       //ADDING THE ITEM FOR PAC Contribution, Foundation Contribution
                       lstSalesOrderLineItem.add(objFDServiceSOLI);
                       // jump it
                       continue;
                   }   
                if(strItemName == objMemberStage.Fon_Convenience_Fee__c){
                    if(objMemberStage.Fon_AAFP_Subscription_Plan_Picklist__c == 'Installment'){
                        system.debug('create for convience')    ;
                        FDService.SalesOrderLine objFDServiceSOLI = fetchSalesOrderLineItemFDService(itemToAdd, objMemberStage, mapNameToObjSubscriptionPlan);
                        lstSalesOrderLineItem.add(objFDServiceSOLI);    
                    }
                    // jump it
                    continue;
                }  
                
                system.debug('is convience ' + strItemName)   ; 
                FDService.SalesOrderLine objFDServiceSOLI = fetchSalesOrderLineItemFDService(mapItemNameToObjItem.get(strItemName), objMemberStage, mapNameToObjSubscriptionPlan);
                if(nationalTypeSoli != null){
                    objFDServiceSOLI.parentForeignKey = nationalTypeSoli.foreignKey;
                }else{
                    nationalTypeSoli = objFDServiceSOLI;
                }
                lstSalesOrderLineItem.add(objFDServiceSOLI);
            }
        }
        
        return lstSalesOrderLineItem;
    }
    
    //Inserting Sales Order and Sales Order Line using FD Service
    public List<OrderApi__Sales_Order__c> insertingSalesOrderAndSOLIV2(map<string, OrderApi__Sales_Order__c> stagingSalesOrderMap,
                                                                       map<string, List<FDService.SalesOrderLine>> stagingSalesOrderLines,
                                                                       map<id, OrderApi__Item__c> itemToAdd,
                                                                       map<string, Fon_Membership_Staging__c> stagingrecord)
    {
        integer beforeSO = Limits.getCpuTime();
        Id duesSalesorderId;
        
        system.debug('***before SO Insert Total CPU USED*** '+Limits.getCpuTime());
        insert stagingSalesOrderMap.values();  // Used = 781 Inserting SO
        system.debug('***after SO Insert Total CPU USED*** '+Limits.getCpuTime() + ' Used = ' + (Limits.getCpuTime()-beforeSO));
        
        List<FDService.SalesOrderLine> lstNewSOLI = new List<FDService.SalesOrderLine>();
        
        for(string stagingId : stagingSalesOrderLines.keySet()){
            for(FDService.SalesOrderLine sol :  stagingSalesOrderLines.get(stagingId)){
                //for(FDService.SalesOrderLine sol : sols){
                if((itemToAdd.get(sol.Item).Fon_Is_PAC_Item__c
                    || (itemToAdd.get(sol.Item).Is_Foundation_Donation__c)
                    || (itemToAdd.get(sol.Item).Name.contains('Convenience'))) 
                   && stagingSalesOrderMap.ContainsKey(stagingId+'_DONATION')){
                       sol.salesOrder = stagingSalesOrderMap.get(stagingId+'_DONATION').Id;    
                   }else{
                       system.debug('staging Id = ' + stagingId + ' SO ID = ' + stagingSalesOrderMap.get(stagingId+'_DUES'));
                       sol.salesOrder = stagingSalesOrderMap.get(stagingId+'_DUES').Id;
                       duesSalesorderId = stagingSalesOrderMap.get(stagingId+'_DUES').Id; //Dues Salesorder ID
                   }
                lstNewSOLI.add(sol);
                //}
            }
        }
        
        if(!lstNewSOLI.isEmpty()){
            integer beforeSOL = Limits.getCpuTime();
            system.debug('***before SOL Insert:Using FD service> Total CPU USED*** '+Limits.getCpuTime());
            FDService.OrderService.getInstance().addItemsToOrder(lstNewSOLI); //FD Service Call
            system.debug('***after SOL Insert:Using FD service> Total CPU USED*** '+Limits.getCpuTime() + ' Used = ' + (Limits.getCpuTime()-beforeSOL));
        }
        
        //Close the Sales Order
        for(OrderApi__Sales_Order__c eachSO : stagingSalesOrderMap.values()){
            eachSO.OrderApi__Status__c = 'Closed';
            if(eachSO.Fon_Salesorder_Type__c=='Donation'){
                eachSO.Fon_Dues_Sales_Order__c = duesSalesorderId;//TC-021927
            }
            //13 nov posting so for change member type
            for(string stagingId : stagingSalesOrderLines.keySet()){
                Fon_Membership_Staging__c staging = stagingrecord.get(stagingId);
                if(!staging.Fon_Is_New__c && eachSO.OrderApi__Posting_Entity__c=='Receipt'){
                    eachSO.OrderApi__Posting_Status__c = 'Posted';
                }
            }
            //13 nov posting so for change member type
        }
        
        integer beforeUpdateSO = Limits.getCpuTime();
        system.debug('***before SO Update Total CPU USED*** '+Limits.getCpuTime());
        Update stagingSalesOrderMap.values(); //Updating SO
        system.debug('***after SO Update Total CPU USED*** '+Limits.getCpuTime() + ' Used = ' + (Limits.getCpuTime()-beforeUpdateSO));
        
        list<OrderApi__Sales_Order__c> soToPost = new list<OrderApi__Sales_Order__c>();
        for(string stagingId : stagingSalesOrderLines.keySet()){
            Fon_Membership_Staging__c staging = stagingrecord.get(stagingId);
            if(staging.Fon_Dues_Paid_by_Chapter__c || staging.Fon_Dues_Paid_by_Residency_Program__c ){
                if(stagingSalesOrderMap.containsKey(stagingId+'_DONATION')) {
                    OrderApi__Sales_Order__c so = stagingSalesOrderMap.get(stagingId+'_DONATION');
                    so.OrderApi__Posting_Status__c = 'Posted';
                    soToPost.add(so);
                }
                if(stagingSalesOrderMap.containsKey(stagingId+'_DUES')) {
                    OrderApi__Sales_Order__c so =  stagingSalesOrderMap.get(stagingId+'_DUES');
                    so.OrderApi__Posting_Status__c = 'Posted';
                    soToPost.add(so);
                }
            }  
        }
        
        
        
        system.debug('***Final before SO Update Total CPU USED*** '+Limits.getCpuTime());
        update soToPost;
        system.debug('***Final after SO Update Total CPU USED*** '+Limits.getCpuTime());
        
        return stagingSalesOrderMap.values();
    }
    
    //Instantiating Sales Order Line Item Here
    public FDService.SalesOrderLine fetchSalesOrderLineItemFDService(OrderApi__Item__c objItem, Fon_Membership_Staging__c objMemberStage, Map<String,OrderApi__Subscription_Plan__c> mapNameToObjSubscriptionPlan){
        system.debug('***4 FD service SO. Total CPU USED*** '+Limits.getCpuTime() + '***Available CPU USED*** ' + Limits.getLimitCpuTime());
        FDService.SalesOrderLine objLineItem = new FDService.SalesOrderLine();    //This line of code will be updated by FD Sevice
        system.debug('***4 FD service FINISH SO. Total CPU USED*** '+Limits.getCpuTime() + '***Available CPU USED*** ' + Limits.getLimitCpuTime());
        objLineItem.item = objItem.Id;
        objLineItem.activationDate = objMemberStage.Fon_Membership_Activation_Date__c;
        objLineItem.autoCalculateActivationDate = false;
        objLineItem.subscriptionStartDate = objMemberStage.Fon_Join_Date__c;
        if(mapNameToObjSubscriptionPlan.containsKey(objMemberStage.Fon_Subscription_Plan__c)){
            objLineItem.subscriptionPlan = mapNameToObjSubscriptionPlan.get(objMemberStage.Fon_Subscription_Plan__c).Id;
        }
        if(!objMemberStage.Fon_Is_New__c){
            objLineItem.priceOverride = true;
            objLineItem.salePrice = 0;
        }
        else{   
            if(objItem.Fon_Is_PAC_Item__c){
                objLineItem.priceOverride = true;
                objLineItem.salePrice = objMemberStage.Fon_PAC_Contribution_Information__c;
            }
            else if(objItem.Is_Foundation_Donation__c){
                objLineItem.priceOverride = true;
                objLineItem.salePrice = objMemberStage.Fon_Foundation_Contribution_Information__c;
            }
        }
        objLineItem.isSubscription = true;
        return objLineItem;
    }
    
    public static void cancellingInvoice(Set<Id> contactId){
        Map<Id,Id> subscriptionVssalesOrder = new Map<Id,Id>();
        set<Id> subscriptionSet=new set<Id>();
        set<Id> salesOrderSet =new set<Id>();
        set<Id> salesOrderId =new set<Id>();
        list<OrderApi__Subscription__c> subscription =[select id from OrderApi__Subscription__c where OrderApi__In_Grace_Period__c =true AND OrderApi__Contact__c  IN : contactId];
        for(OrderApi__Subscription__c sub : subscription){
            subscriptionSet.add(sub.Id);
        }
        list<OrderApi__Sales_Order_Line__c> salesOrderLines=[select id,OrderApi__Sales_Order__c,OrderApi__Subscription__c 
                                                             from OrderApi__Sales_Order_Line__c where OrderApi__Is_Renewal__c=true AND OrderApi__Subscription__c In: subscriptionSet ];
        if(salesOrderLines.size()>0){
            for(OrderApi__Sales_Order_Line__c  SOLI : salesOrderLines){
                salesOrderSet.add(SOLI.OrderApi__Sales_Order__c);
                subscriptionVssalesOrder.put(SOLI.OrderApi__Subscription__c,SOLI.OrderApi__Sales_Order__c);
            }
        }
        list<OrderApi__Sales_Order__c> salesOrder=[select id,(select id from OrderApi__Invoices__r where OrderApi__Is_Paid__c= true),(select id from OrderApi__Receipts__r  where OrderApi__Is_Payment__c = true)
                                                   from OrderApi__Sales_Order__c where Id IN : salesOrderSet];
        if(salesOrder.size()>0){
            for(OrderApi__Sales_Order__c sa :salesOrder){
                if(sa.OrderApi__Invoices__r.isEmpty() || sa.OrderApi__Receipts__r.isEmpty() ){
                    salesOrderId.add(sa.Id); 
                    sa.OrderApi__Status__c='Cancelled';
                }
            }
        }
        for(OrderApi__Subscription__c updatesub : subscription){
            system.debug(salesOrderId.contains(updatesub.Id));
            if(salesOrderId.contains(subscriptionVssalesOrder.get(updatesub.Id))){
                updatesub .OrderApi__Status__c='Cancelled';
            }
        }    
        if(!subscription.isEmpty()){
            update subscription;
        }
        if(!salesOrder.isEmpty()){
            update salesOrder;
        }
    }
    
    // need to delete below codes after testing CPU time with non FD service code
    /*
public List<OrderApi__Sales_Order__c> initializeMembershipStage_FDService(List<Fon_Membership_Staging__c> lstAllStaging){
List<OrderApi__Sales_Order__c> lstSalesOrder;
List<Fon_Membership_Staging__c> lstApprovedMembershipStage = new List<Fon_Membership_Staging__c>();
for(Fon_Membership_Staging__c objStage : lstAllStaging){
if(objStage.Fon_Staging_Status__c == 'Approved'){
if(!objStage.Fon_Is_New__c){
contactIds.add(objStage.Fon_Contact__c);
}
//  lstApprovedMembershipStage.add(objStage);    //Getting the approved membership staging record here
}
lstApprovedMembershipStage.add(objStage);    //Getting the approved membership staging record here

}
if(!contactIds.isEmpty()){
List<Fon_Membership_Staging__c> existingMembership = [select id,Fon_Contact__c,Fon_Payment_Method_Id__c from Fon_Membership_Staging__c 
where Fon_Contact__c In:contactIds And Fon_Staging_Status__c = 'Expired' Order by LastModifiedDate desc];
if(existingMembership.size()>0){
contactIds.clear();
for(Fon_Membership_Staging__c memObj:existingMembership){
if(!contactIds.contains(memObj.Fon_Contact__c)){
contactIds.add(memObj.Fon_Contact__c);
if(memObj.Fon_Payment_Method_Id__c!=null){
conVSpaymentMethodId.put(memObj.Fon_Contact__c,memObj.Fon_Payment_Method_Id__c);
}
}
}
}
}

if(!lstApprovedMembershipStage.isEmpty()){
lstSalesOrder = createSalesOrderByMemberStagingV2(lstApprovedMembershipStage);  //Batch process will be called from here
// lstSalesOrder = createSalesOrderByMemberStaging(lstApprovedMembershipStage);  //Batch process will be called from here
}
return lstSalesOrder;
}
*/
}