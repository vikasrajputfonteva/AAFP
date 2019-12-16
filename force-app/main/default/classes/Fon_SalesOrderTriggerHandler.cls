/*
    @Description: This claas will managed to update the important date on sales order line.
    @Author: Vikas Rajput
*/
public without sharing class Fon_SalesOrderTriggerHandler{
    private static String strPrintOption = 'Print';
    //This function will be called only after update action
    public static void initAction(List<OrderApi__Sales_Order__c> lstSalesOrder, Map<Id,OrderApi__Sales_Order__c> mapSOIdToObjSO){
        Set<Id> idSetOfSalesOrder = new Set<Id>();
        for(OrderApi__Sales_Order__c eachSO : lstSalesOrder){
            if(eachSO.OrderApi__Is_Posted__c && mapSOIdToObjSO.containsKey(eachSO.Id) && !mapSOIdToObjSO.get(eachSO.Id).OrderApi__Is_Posted__c ){
                idSetOfSalesOrder.add(eachSO.Id);
            }
        }
        List<OrderApi__Sales_Order__c> lstAllSalesOrder = fetchSalesOrder(idSetOfSalesOrder);
        filterNonRenewalOrder(lstAllSalesOrder);  //Code has beed commented to debug the CPU Time Limit Issue, Code comment will be removed in future.
        manageQNTYOnSOLI(fetchSalesOrder(idSetOfSalesOrder));
    }
    
    public static List<OrderApi__Sales_Order__c> fetchSalesOrder(Set<Id> idSetOfSalesOrder){
        List<OrderApi__Sales_Order__c> lstOfNonReneSalesOrder = new List<OrderApi__Sales_Order__c>();
        lstOfNonReneSalesOrder = [SELECT Id,(SELECT Id,OrderApi__Is_Renewal__c,OrderApi__Item__c,OrderApi__Item__r.OrderApi__Is_Subscription__c,
                                                        OrderApi__Auto_Calculate_Activation_Date__c,OrderApi__Subscription_Start_Date__c,OrderApi__Activation_Date__c, OrderApi__Item_Class__r.Fon_Is_Journal__c,OrderApi__Subscription__c,
                                                        OrderApi__Item__r.Fon_Journal_Print__c,OrderApi__End_Date__c,OrderApi__Quantity__c   
                                                         FROM OrderApi__Sales_Order_Lines__r) FROM OrderApi__Sales_Order__c WHERE Id IN :idSetOfSalesOrder];
        return lstOfNonReneSalesOrder;
    }
    /*
        @Description: In this function, filtering non-renewal "sales order" and set of "item" id => Item will be linked to Issue object
        @Author: Vikas Rajput
    */
    public static void filterNonRenewalOrder(List<OrderApi__Sales_Order__c> lstSalesOrder){
        List<OrderApi__Sales_Order__c> lstOfNonReneSalesOrder = new List<OrderApi__Sales_Order__c>();
        Set<Id> idSetOfItem  = new  Set<Id>();
        for(OrderApi__Sales_Order__c eachSalesOrder : lstSalesOrder){
            if(eachSalesOrder.OrderApi__Sales_Order_Lines__r != null && !eachSalesOrder.OrderApi__Sales_Order_Lines__r.isEmpty()){
                Set<Id> localSetOfItemId = new  Set<Id>();
                Boolean renewalFlag = false;
                for(OrderApi__Sales_Order_Line__c eachSOLI : eachSalesOrder.OrderApi__Sales_Order_Lines__r){
                    localSetOfItemId.add(eachSOLI.OrderApi__Item__c);
                    if(eachSOLI.OrderApi__Is_Renewal__c){
                        renewalFlag = true;
                    }
                }
                if(!renewalFlag){
                    lstOfNonReneSalesOrder.add(eachSalesOrder);
                    idSetOfItem.addAll(localSetOfItemId);
                }
            }
        }
        updateImpDateOnSOLI(lstOfNonReneSalesOrder,idSetOfItem);
        
    }
    /*
        @Description: Fetching "Issue" object using query 
        @Author: Vikas Rajput
    */
    
    /* AAFP: Need to query on issue object, Un-comment it when query object is confirm.
    public static Map<Id,Issue__c> fetchIssueDate(Set<Id> idSetOfItem){
        Map<Id,Issue__c> mapItemIdToIssueObj = new Map<Id,Issue__c>();
        List<Issue__c> lstIssue = [SELECT Id,Item__c,DateofIssue,CurrentIssueSold FROM Issue__c WHERE Item__c IN :idSetOfItem WHERE];
        for(Issue__c eachIssue : lstIssue){
            mapItemIdToIssueObj.put(eachIssue.Item__c, eachIssue);
        }
        return mapItemIdToIssueObj;
    }
    */
    
    /*
        @Description: Updating important date field on "Sales Order Line Item"
        @Author: Vikas Rajput
    */
    public static void updateImpDateOnSOLI(List<OrderApi__Sales_Order__c> lstOfNonReneSalesOrder, Set<Id> idSetOfItem){
        Set<OrderApi__Sales_Order_Line__c> soliSet = new Set<OrderApi__Sales_Order_Line__c>();
        //Map<Id,Issue__c> mapItemIdToIssueObj = fetchIssueDate(idSetOfItem);
        for(OrderApi__Sales_Order__c eachSalesOrder : lstOfNonReneSalesOrder){
            for(OrderApi__Sales_Order_Line__c objSOLI : eachSalesOrder.OrderApi__Sales_Order_Lines__r){
                if(objSOLI.OrderApi__Item__r.OrderApi__Is_Subscription__c && objSOLI.OrderApi__Item_Class__r.Fon_Is_Journal__c && objSOLI.OrderApi__Item__r.Fon_Journal_Print__c == strPrintOption){ //&& mapItemIdToIssueObj.containsKey(objSOLI.OrderApi__Item__c
                    //Date objDate = mapItemIdToIssueObj.get(objSOLI.OrderApi__Item__c).DateofIssue;
                    //AAFP - Change the Hard Coded Date 
                    Date objDate = System.today();
                    objSOLI.OrderApi__Auto_Calculate_Activation_Date__c = false; //AAFP: Need to change start date logic based on issue or fullfilment object. 
                    objSOLI.OrderApi__Subscription_Start_Date__c = objDate.toStartOfMonth(); //AAFP: Need to change "Subscription_Start_Date" logic based on issue or fullfilment object.
                    objSOLI.OrderApi__Activation_Date__c = objDate; //AAFP: Need to change "Activation_Date" logic based on issue or fullfilment object.
                    objSOLI.OrderApi__End_Date__c = objDate.toStartOfMonth().addYears(1); //AAFP: Need to change "End_Date" logic based on issue or fullfilment object.
                    soliSet.add(objSOLI);
                }
            }
        }
        if(!soliSet.isEmpty()){
            update new List<OrderApi__Sales_Order_Line__c>(soliSet);
        }
    }
    
    public static void manageQNTYOnSOLI(List<OrderApi__Sales_Order__c> lstSalesOrder){
        List<OrderApi__Sales_Order__c> lstOfReneSalesOrder = new List<OrderApi__Sales_Order__c>();
        Set<Id> setOfSubscriptionId = new Set<Id>();
        for(OrderApi__Sales_Order__c eachSalesOrder : lstSalesOrder){
            if(eachSalesOrder.OrderApi__Sales_Order_Lines__r != null && !eachSalesOrder.OrderApi__Sales_Order_Lines__r.isEmpty()){
                Set<Id> localSetOfItemId = new  Set<Id>();
                Boolean renewalFlag = false;
                for(OrderApi__Sales_Order_Line__c eachSOLI : eachSalesOrder.OrderApi__Sales_Order_Lines__r){
                    localSetOfItemId.add(eachSOLI.OrderApi__Item__c);
                    if(eachSOLI.OrderApi__Is_Renewal__c && !String.isBlank(eachSOLI.OrderApi__Subscription__c)){
                        renewalFlag = true;
                        setOfSubscriptionId.add(eachSOLI.OrderApi__Subscription__c);
                    }
                }
                if(renewalFlag){
                    lstOfReneSalesOrder.add(eachSalesOrder);
                }
            }
        }
        Map<Id,Map<Id,Integer>> mapSubcribeIdToMapItemIdToQnty = new Map<Id,Map<Id,Integer>>();
        List<OrderApi__Subscription__c> lstSubscription = [SELECT Id,(SELECT Id,OrderApi__Quantity__c,OrderApi__Item__c FROM 
                                                        OrderApi__Subscription_Lines__r) FROM OrderApi__Subscription__c WHERE Id IN : setOfSubscriptionId];
        for(OrderApi__Subscription__c eachSubs : lstSubscription){
            Map<Id,Integer> mapIdToQuantity = new Map<Id,Integer>();
            for(OrderApi__Subscription_Line__c eachLine : eachSubs.OrderApi__Subscription_Lines__r){
                if(mapIdToQuantity.containsKey(eachLine.OrderApi__Item__c)){
                    Integer totalQnty = mapIdToQuantity.get(eachLine.OrderApi__Item__c);
                    totalQnty = totalQnty + Integer.valueOf(eachLine.OrderApi__Quantity__c);
                    mapIdToQuantity.put(eachLine.OrderApi__Item__c, totalQnty);
                }else{
                    mapIdToQuantity.put(eachLine.OrderApi__Item__c, Integer.valueOf(eachLine.OrderApi__Quantity__c));
                }
            }
            mapSubcribeIdToMapItemIdToQnty.put(eachSubs.Id,mapIdToQuantity);
        }
        //Updating quantity on Sales Order Line
        Set<OrderApi__Sales_Order_Line__c> soliSet = new Set<OrderApi__Sales_Order_Line__c>();
        for(OrderApi__Sales_Order__c eachSalesOrder : lstOfReneSalesOrder){
            for(OrderApi__Sales_Order_Line__c eachSOLI : eachSalesOrder.OrderApi__Sales_Order_Lines__r){
                if(eachSOLI.OrderApi__Is_Renewal__c && !String.isBlank(eachSOLI.OrderApi__Subscription__c) && 
                    mapSubcribeIdToMapItemIdToQnty.containsKey(eachSOLI.OrderApi__Subscription__c)){
                    updatingQuantity(eachSalesOrder, mapSubcribeIdToMapItemIdToQnty.get(eachSOLI.OrderApi__Subscription__c));
                    break;
                }
            }
            soliSet.addAll(eachSalesOrder.OrderApi__Sales_Order_Lines__r);
        }
        if(!soliSet.isEmpty()){
            update new List<OrderApi__Sales_Order_Line__c>(soliSet);
        }
    }
    
    public static void updatingQuantity(OrderApi__Sales_Order__c objSalesorder, Map<Id,Integer> mapItemIdToQuantity){
        for(OrderApi__Sales_Order_Line__c eachSOLI : objSalesorder.OrderApi__Sales_Order_Lines__r){
            if(mapItemIdToQuantity.containsKey(eachSOLI.OrderApi__Item__c)){
                eachSOLI.OrderApi__Quantity__c = mapItemIdToQuantity.get(eachSOLI.OrderApi__Item__c);
            }
        }
        
    }
    
}