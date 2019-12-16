public class Fon_SalesOrderLineQuantityService{
    
    public void manageQuantity(List<OrderApi__Sales_Order_Line__c> lstSOLI){
        List<OrderApi__Sales_Order_Line__c> lstRenewalSOLI = new List<OrderApi__Sales_Order_Line__c>();
        Set<Id> subscriptionIdSet = new  Set<Id>();
        Set<Id> itemIdSet = new  Set<Id>();
        for(OrderApi__Sales_Order_Line__c eachSOLI : lstSOLI){
            if(eachSOLI.OrderApi__Is_Renewal__c && eachSOLI.OrderApi__Subscription__c != null){
                subscriptionIdSet.add(eachSOLI.OrderApi__Subscription__c);
                itemIdSet.add(eachSOLI.OrderApi__Item__c);
                lstRenewalSOLI.add(eachSOLI);
            }
        }
        Map<String,OrderApi__Subscription_Line__c> mapSubscriptionIdToSubLine = fetchSubscriptionLineByIdSet(subscriptionIdSet);
        Map<Id,OrderApi__Item__c> mapItemIdToObjItem = fetchItemByIdSet(itemIdSet);
        updatingQuantityToSOLI(lstRenewalSOLI, mapSubscriptionIdToSubLine, mapItemIdToObjItem);
    }
    
    public void updatingQuantityToSOLI(List<OrderApi__Sales_Order_Line__c> lstRenewalSOLI, Map<String,OrderApi__Subscription_Line__c> mapSubscriptionIdToSubLine, Map<Id,OrderApi__Item__c> mapItemIdToObjItem){
        List<OrderApi__Sales_Order_Line__c> upList = new List<OrderApi__Sales_Order_Line__c>();
        for(OrderApi__Sales_Order_Line__c eachSOLI : lstRenewalSOLI){
            String strKey = ''+Id.valueOf(eachSOLI.OrderApi__Subscription__c)+Id.valueOf(eachSOLI.OrderApi__Item__c);
            if(mapSubscriptionIdToSubLine.containsKey(strKey) && mapItemIdToObjItem.containsKey(eachSOLI.OrderApi__Item__c)){
                eachSOLI.OrderApi__Quantity__c = mapSubscriptionIdToSubLine.get(strKey).OrderApi__Quantity__c;
                eachSOLI.OrderApi__Total__c = eachSOLI.OrderApi__Quantity__c*eachSOLI.OrderApi__Sale_Price__c;
            }
        }
    }
    
    public Map<Id,OrderApi__Item__c> fetchItemByIdSet(Set<Id> itemIdSet){
        return new Map<Id,OrderApi__Item__c>([SELECT Id,OrderApi__Is_Subscription__c FROM OrderApi__Item__c WHERE Id IN :itemIdSet AND OrderApi__Item_Class__r.OrderApi__Is_Subscription__c = true 
                                              AND OrderApi__Item_Class__r.Fon_Is_Main_Membership__c = false]);
    }
    
    public Map<String,OrderApi__Subscription_Line__c> fetchSubscriptionLineByIdSet(Set<Id> subscriptionIdSet){
        List<OrderApi__Subscription__c> lstSubscription = [SELECT Id,OrderApi__Item__c,(SELECT Id,OrderApi__Item__c,OrderApi__Sales_Order_Line__c,OrderApi__Quantity__c FROM OrderApi__Subscription_Lines__r ORDER BY CreatedDate DESC) 
                                                           FROM OrderApi__Subscription__c WHERE Id IN :subscriptionIdSet AND OrderApi__Item__r.OrderApi__Item_Class__r.OrderApi__Is_Subscription__c = true AND 
                                                           OrderApi__Item__r.OrderApi__Item_Class__r.Fon_Is_Main_Membership__c = false AND OrderApi__Item__r.OrderApi__Item_Class__r.Fon_Is_Journal__c = true];
        Map<String,OrderApi__Subscription_Line__c> mapSubscriptionIdToSubLine = new Map<String,OrderApi__Subscription_Line__c>();
        for(OrderApi__Subscription__c eachSubscibe : lstSubscription){
            for(OrderApi__Subscription_Line__c eachSubLine : eachSubscibe.OrderApi__Subscription_Lines__r ){
                mapSubscriptionIdToSubLine.put(''+Id.valueOf(eachSubscibe.Id)+Id.valueOf(eachSubLine.OrderApi__Item__c),eachSubLine);
            }
        }
        return mapSubscriptionIdToSubLine;
    }
    
}