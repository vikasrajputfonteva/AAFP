public class Fon_SalesorderLineHandler {
    //TC-022253
    public static void createSoliForChapterLocal(List<OrderApi__Sales_Order_Line__c> newList){
        if(!system.isBatch()){
            List<OrderApi__Sales_Order_Line__c> insertSoliList = new List<OrderApi__Sales_Order_Line__c>();
            Set<Id> renewalSoliIds = new Set<Id>();
            Set<Id> insertSoIds = new Set<Id>();
            Set<Id> subscriptionIds = new Set<Id>();
            Set<Id> ItemIds = new Set<Id>();
            Map<Id,Id> subVSso = new Map<Id,Id>();
            Map<Id,Id> itemVSrenewItem = new Map<Id,Id>();
            List<OrderApi__Subscription_Line__c> subLineList = new List<OrderApi__Subscription_Line__c>();
            Map<Id,Id> subscriptionIdVSrenewalSoliId = new Map<Id,Id>();
            
            for(OrderApi__Sales_Order_Line__c newSoliObj : newList){
                if(newSoliObj.OrderApi__Is_Renewal__c == true && newSoliObj.OrderApi__Subscription__c != Null){
                    renewalSoliIds.add(newSoliObj.Id);
                }
            }
            if(!renewalSoliIds.isEmpty()){
                List<OrderApi__Sales_Order_Line__c> renewalSoliList = [select id,
                                                                       OrderApi__Sales_Order__c,
                                                                       OrderApi__Subscription__c
                                                                       from OrderApi__Sales_Order_Line__c
                                                                       Where OrderApi__Item__r.OrderApi__Item_Class__r.Fon_Is_Main_Membership__c=true
                                                                       AND Id In:renewalSoliIds];
                if(renewalSoliList.size()>0){
                    for(OrderApi__Sales_Order_Line__c soliObj:renewalSoliList){
                        insertSoIds.add(soliObj.OrderApi__Sales_Order__c);
                        subscriptionIds.add(soliObj.OrderApi__Subscription__c);
                        subVSso.put(soliObj.OrderApi__Subscription__c,soliObj.OrderApi__Sales_Order__c);
                        subscriptionIdVSrenewalSoliId.put(soliObj.OrderApi__Subscription__c,soliObj.Id);
                    }
                }
                if(!subscriptionIds.isEmpty()){
                    subLineList = [select id,OrderApi__Item__c,OrderApi__Subscription__c,
                                   OrderApi__Item_Class__r.Fon_Is_State_Membership__c,
                                   OrderApi__Item_Class__r.Fon_Is_Local_Membership__c
                                   from OrderApi__Subscription_Line__c
                                   WHERE OrderApi__Subscription__c In:subscriptionIds
                                   AND (OrderApi__Item_Class__r.Fon_Is_State_Membership__c=true
                                        OR OrderApi__Item_Class__r.Fon_Is_Local_Membership__c=true)
                                   Order By OrderApi__Subscription__c];
                    if(subLineList.size()>0){
                        for(OrderApi__Subscription_Line__c subLineObj : subLineList){
                            ItemIds.add(subLineObj.OrderApi__Item__c);
                        }
                    }
                    if(!ItemIds.isEmpty()){
                        List<OrderApi__Renewal_Path__c> renewalPathList = [select id,
                                                                           OrderApi__Renew_Into_Item__c,
                                                                           OrderApi__Item__c
                                                                           from OrderApi__Renewal_Path__c 
                                                                           WHERE OrderApi__Renew_Into_Item__c!=null
                                                                           AND OrderApi__Item__c In:ItemIds
                                                                           AND OrderApi__Is_Default__c=true];
                        if(renewalPathList.size()>0){
                            for(OrderApi__Renewal_Path__c rpObj : renewalPathList){
                                itemVSrenewItem.put(rpObj.OrderApi__Item__c,rpObj.OrderApi__Renew_Into_Item__c);
                            }
                        }
                    }
                }
            }
            if(!itemVSrenewItem.isEmpty()){
                for(OrderApi__Subscription_Line__c subLineObj : subLineList){
                    if(itemVSrenewItem.get(subLineObj.OrderApi__Item__c) != Null){
                        OrderApi__Sales_Order_Line__c soli = new OrderApi__Sales_Order_Line__c();
                        soli.OrderApi__Sales_Order__c=subVSso.get(subLineObj.OrderApi__Subscription__c);
                        soli.OrderApi__Item__c= itemVSrenewItem.get(subLineObj.OrderApi__Item__c);
                        soli.OrderApi__Sales_Order_Line__c=subscriptionIdVSrenewalSoliId.get(subLineObj.OrderApi__Subscription__c);
                        insertSoliList.add(soli);
                    }
                }
            }
            if(insertSoliList.size()>0){
                try{
                    Fon_ConstantClass.runOnce=false;
                    insert insertSoliList;
                }
                catch(Exception e){
                    system.debug('Fon_SalesorderLineHandler Exception--'+e.getMessage());
                    system.debug('Fon_SalesorderLineHandler Exception Line Number--'+e.getLineNumber());
                }
            }
        }
    } 
}