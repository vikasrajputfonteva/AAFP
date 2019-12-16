global class Fon_RenewalSOLIManagerBatch implements Database.Batchable<sObject>, Database.Stateful{

    /*
        @Author: RSystem
        @Description: To process the soli records where creation date on SOLI is today.
    */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //String testId = 'a1Eg0000004F9qR';
        // Collect the batches of records
        String soStatus = 'Closed';
        return Database.getQueryLocator('SELECT Id,Name,OrderApi__Item__c,OrderApi__Item__r.Is_Foundation_Donation__c,OrderApi__List_Price__c,OrderApi__Price_Override__c,OrderApi__Sales_Order_Line__c,'+
                                        'OrderApi__Is_Renewal__c,OrderApi__Subscription__c,OrderApi__Subscription__r.OrderApi__Subscription_Plan__c,'+
                                        'OrderApi__Subscription__r.OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__c,OrderApi__Subscription__r.OrderApi__Sales_Order_Line__c,'+
                                        'OrderApi__Subscription__r.OrderApi__Subscription_Plan__r.OrderApi__Enable_Schedule__c,CreatedDate,'+
                                        'OrderApi__Account__c,OrderApi__Contact__c,OrderApi__Business_Group__c,OrderApi__Price_Rule__c,'+
                                        'OrderApi__Sale_Price__c,OrderApi__Sales_Order__c FROM OrderApi__Sales_Order_Line__c WHERE '+
                                        'OrderApi__Item__r.OrderApi__Item_Class__r.Fon_Is_Main_Membership__c=true AND OrderApi__Sales_Order__r.OrderApi__Status__c = :soStatus AND OrderApi__Is_Renewal__c = true');
    
    }

    global void execute(Database.BatchableContext BC, List<OrderApi__Sales_Order_Line__c> lstSOLI) {
        
        Map<Id,Id> mapSOIdToSubscriptionId = new Map<Id,Id>();
        Map<Id,Id> mapSubscriptionIdToSOId = new Map<Id,Id>();
        Set<Id> setSalesOrderId = new Set<Id>();
        for(OrderApi__Sales_Order_Line__c eachSOLIRecord : lstSOLI){
            setSalesOrderId.add(eachSOLIRecord.OrderApi__Sales_Order__c);
            if(eachSOLIRecord.OrderApi__Subscription__c != null && eachSOLIRecord.OrderApi__Subscription__r.OrderApi__Sales_Order_Line__c != null){
                mapSubscriptionIdToSOId.put(eachSOLIRecord.OrderApi__Subscription__c,eachSOLIRecord.OrderApi__Subscription__r.OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__c);
                mapSOIdToSubscriptionId.put(eachSOLIRecord.OrderApi__Sales_Order__c, eachSOLIRecord.OrderApi__Subscription__c);
            }
        }
        
        Set<Id> setOfItemId = new Set<Id>();
        Map<Id,List<OrderApi__Subscription_Line__c>> mapSubIdToLstSubLine = fetchSubscription(mapSubscriptionIdToSOId.keySet());
        for(List<OrderApi__Subscription_Line__c> lstSubsLine : mapSubIdToLstSubLine.values()){
            for(OrderApi__Subscription_Line__c eachSunLine : lstSubsLine){
                setOfItemId.add(eachSunLine.OrderApi__Item__c);
            }
        }
        
        List<OrderApi__Sales_Order_Line__c> lstNewSOLI = new List<OrderApi__Sales_Order_Line__c>();
        Map<Id,OrderApi__Renewal_Path__c> mapItemIdToObjRenewalPath = fetchRenewalPathByItem(setOfItemId);
        
        for(OrderApi__Sales_Order__c eachSO : fetchRenewalSalesOrder(setSalesOrderId)){
            Id subscriptionID = mapSOIdToSubscriptionId.get(eachSO.Id);
            
            if(subscriptionID != null && mapSubIdToLstSubLine.containsKey(subscriptionID)){
                for(OrderApi__Subscription_Line__c objSubsLine : mapSubIdToLstSubLine.get(subscriptionID)){ 
                    Boolean recordExist = false;
                    OrderApi__Sales_Order_Line__c  tempSOLI;
                    for(OrderApi__Sales_Order_Line__c  objSOLI : eachSO.OrderApi__Sales_Order_Lines__r){
                        tempSOLI = objSOLI;
                        if(mapItemIdToObjRenewalPath.containsKey(objSubsLine.OrderApi__Item__c) && Id.valueOf(mapItemIdToObjRenewalPath.get(objSubsLine.OrderApi__Item__c).OrderApi__Renew_Into_Item__c) == Id.valueOf(objSOLI.OrderApi__Item__c) ){
                            recordExist = true;
                        }
                    }
                    
                    if(!recordExist && tempSOLI != null && mapItemIdToObjRenewalPath.containsKey(objSubsLine.OrderApi__Item__c)){
                         OrderApi__Sales_Order_Line__c InstanceSOLI = fetchSOLIInstance(tempSOLI);
                         InstanceSOLI.OrderApi__Sales_Order_Line__c = tempSOLI.Id;
                         InstanceSOLI.OrderApi__Item__c = mapItemIdToObjRenewalPath.get(objSubsLine.OrderApi__Item__c).OrderApi__Renew_Into_Item__c;
                         lstNewSOLI.add(InstanceSOLI);
                    }
                    recordExist = false;
                }
            }
        }
        
        if(!lstNewSOLI.isEmpty()){
            insert lstNewSOLI;
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
        // execute any post-processing operations
        
        
    }
    
    public Map<Id,List<OrderApi__Subscription_Line__c>> fetchSubscription(Set<Id> idSetOfSubscription){
        Map<Id,List<OrderApi__Subscription_Line__c>> mapSubIdToLstSubLine = new Map<Id,List<OrderApi__Subscription_Line__c>>();
        for(OrderApi__Subscription__c eachSubs : [SELECT Id,(SELECT Id,OrderApi__Item__c,OrderApi__Sales_Order_Line__c FROM OrderApi__Subscription_Lines__r) FROM OrderApi__Subscription__c]){
            if(eachSubs.OrderApi__Subscription_Lines__r != null){
                mapSubIdToLstSubLine.put(eachSubs.Id, eachSubs.OrderApi__Subscription_Lines__r);       
            }                                                                  
        }
        return mapSubIdToLstSubLine;
    }
    
    public Map<Id,OrderApi__Renewal_Path__c> fetchRenewalPathByItem(Set<Id> setOfItemId){
        Map<Id,OrderApi__Renewal_Path__c> mapItemIdToObjRenewalPath = new Map<Id,OrderApi__Renewal_Path__c>();
        List<OrderApi__Item__c> lstOfItem = [SELECT Id,(SELECT Id,OrderApi__Item__c,OrderApi__Renew_Into_Item__c FROM OrderApi__Renewal_Paths__r) FROM OrderApi__Item__c WHERE Id IN :setOfItemId];
        for(OrderApi__Item__c eachItem : lstOfItem){
            if(eachItem.OrderApi__Renewal_Paths__r != null && !eachItem.OrderApi__Renewal_Paths__r.isEmpty()){
                mapItemIdToObjRenewalPath.put(eachItem.Id, eachItem.OrderApi__Renewal_Paths__r[0]);
            }
        }
        return mapItemIdToObjRenewalPath;
    }
    
    public List<OrderApi__Sales_Order__c> fetchRenewalSalesOrder(Set<Id> setSalesOrderId){
        List<OrderApi__Sales_Order__c> lstSO = [SELECT Id,(SELECT Id,OrderApi__Item__c,OrderApi__Sales_Order__c,OrderApi__Sale_Price__c,
                                                OrderApi__Account__c,OrderApi__Contact__c,OrderApi__Business_Group__c,OrderApi__Price_Rule__c 
                                                FROM OrderApi__Sales_Order_Lines__r) FROM OrderApi__Sales_Order__c WHERE Id IN :setSalesOrderId];                       
        return lstSO;
    }
    
    public OrderApi__Sales_Order_Line__c fetchSOLIInstance(OrderApi__Sales_Order_Line__c objOldSOLI){
        OrderApi__Sales_Order_Line__c objSOLI = new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c = objOldSOLI.OrderApi__Sales_Order__c,OrderApi__Item__c = objOldSOLI.OrderApi__Item__c,
                                                                                  OrderApi__Account__c = objOldSOLI.OrderApi__Account__c,OrderApi__Contact__c = objOldSOLI.OrderApi__Contact__c,OrderApi__Business_Group__c = objOldSOLI.OrderApi__Business_Group__c,
                                                                                  OrderApi__Price_Rule__c = objOldSOLI.OrderApi__Price_Rule__c);
        return objSOLI;
    }
}