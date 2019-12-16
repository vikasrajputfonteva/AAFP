global class Fon_SalesOrderLineItemManagerBatch implements Database.Batchable<sObject>, Database.Stateful{
    private final String strConveniencefee = Label.Fon_Convenience_Fee; //It will have a name of item(Convenience fee).
    private Set<Id> overridePriceSalesOrderId = new Set<Id>();
    /**
@Author: RSystem
@Description: To process the soli records where creation date on SOLI is today.
*/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Collect the batches of records
        return Database.getQueryLocator('SELECT Id,Name,OrderApi__Item__c,OrderApi__Item__r.Is_Foundation_Donation__c,OrderApi__List_Price__c,OrderApi__Price_Override__c,'+
                                        'OrderApi__Is_Renewal__c,OrderApi__Subscription__c,OrderApi__Subscription__r.OrderApi__Subscription_Plan__c,'+
                                        'OrderApi__Subscription__r.OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__c,OrderApi__Subscription__r.OrderApi__Sales_Order_Line__c,'+
                                        'OrderApi__Subscription__r.OrderApi__Subscription_Plan__r.OrderApi__Enable_Schedule__c,CreatedDate,'+
                                        'OrderApi__Account__c,OrderApi__Contact__c,OrderApi__Business_Group__c,OrderApi__Price_Rule__c,'+
                                        'OrderApi__Sale_Price__c,OrderApi__Sales_Order__c FROM OrderApi__Sales_Order_Line__c WHERE CreatedDate = TODAY And OrderApi__Item__r.OrderApi__Item_Class__r.Fon_Is_Main_Membership__c=true');
    }
    global void execute(Database.BatchableContext BC, List<OrderApi__Sales_Order_Line__c> lstSOLI) {
        Map<Id,Id> mapSubscriptionIdToSOId = new Map<Id,Id>();
        OrderApi__Item__c objConvenienceFeeItem = fetchConvenienceFeeItem();
        List<OrderApi__Sales_Order_Line__c> lstNewSOLI = new List<OrderApi__Sales_Order_Line__c>();
        Set<Id> setSalesOrderId = new Set<Id>();
        for(OrderApi__Sales_Order_Line__c eachSOLIRecord : lstSOLI){
            setSalesOrderId.add(eachSOLIRecord.OrderApi__Sales_Order__c);
            if(eachSOLIRecord.OrderApi__Subscription__c != null && eachSOLIRecord.OrderApi__Subscription__r.OrderApi__Sales_Order_Line__c != null){
                mapSubscriptionIdToSOId.put(eachSOLIRecord.OrderApi__Subscription__c,eachSOLIRecord.OrderApi__Subscription__r.OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__c);
            }
        }
        Map<Id,List<OrderApi__Sales_Order_Line__c>> mapSalesOrderIdToLstSOLI = fetchSOLIBySOId(mapSubscriptionIdToSOId.values());
        Set<Id> setConvenienceSalesOrderId = fetchConvenienceFeeSalesOrder(setSalesOrderId);
        setSalesOrderId = new Set<Id>();
        for(OrderApi__Sales_Order_Line__c eachSOLI : lstSOLI){
            if(eachSOLI.OrderApi__Is_Renewal__c && !String.isEmpty(eachSOLI.OrderApi__Subscription__c) && 
               !String.isEmpty(eachSOLI.OrderApi__Subscription__r.OrderApi__Subscription_Plan__c) && 
               eachSOLI.OrderApi__Subscription__r.OrderApi__Subscription_Plan__r.OrderApi__Enable_Schedule__c && objConvenienceFeeItem != null && 
               !setConvenienceSalesOrderId.contains(eachSOLI.OrderApi__Sales_Order__c)){
                   OrderApi__Sales_Order_Line__c InstanceSOLI = fetchSOLIInstance(eachSOLI);
                   InstanceSOLI.OrderApi__Item__c = objConvenienceFeeItem.Id;
                   lstNewSOLI.add(InstanceSOLI);
                   setSalesOrderId.add(eachSOLI.OrderApi__Sales_Order__c);
               }
            if(mapSubscriptionIdToSOId.containsKey(eachSOLI.OrderApi__Subscription__c) && mapSubscriptionIdToSOId.get(eachSOLI.OrderApi__Subscription__c) != null && 
               mapSalesOrderIdToLstSOLI.containsKey(mapSubscriptionIdToSOId.get(eachSOLI.OrderApi__Subscription__c))){
                   for(OrderApi__Sales_Order_Line__c objSaleLineItem : mapSalesOrderIdToLstSOLI.get(mapSubscriptionIdToSOId.get(eachSOLI.OrderApi__Subscription__c))){
                       if(objSaleLineItem.OrderApi__Item__r.Is_Foundation_Donation__c && !overridePriceSalesOrderId.contains(objSaleLineItem.OrderApi__Sales_Order__c)){
                           OrderApi__Sales_Order_Line__c InstanceSOLI = fetchSOLIInstance(objSaleLineItem);
                           InstanceSOLI.OrderApi__Price_Override__c = true;
                           InstanceSOLI.OrderApi__Sales_Order__c = eachSOLI.OrderApi__Sales_Order__c;
                           InstanceSOLI.OrderApi__Sale_Price__c = objSaleLineItem.OrderApi__Sale_Price__c;
                           lstNewSOLI.add(InstanceSOLI);
                           //setSalesOrderId.add(objSaleLineItem.OrderApi__Sales_Order__c);
                           overridePriceSalesOrderId.add(eachSOLI.OrderApi__Sales_Order__c);
                       }
                   }
               }
        }
        // Inserting List of new OrderApi__Sales_Order_Line__c
        if(!lstNewSOLI.isEmpty()){
            insert lstNewSOLI;
        }
        if(!setSalesOrderId.isEmpty()){
            List<OrderApi__Sales_Order__c> lstSalesOrder = new List<OrderApi__Sales_Order__c>();
            for(Id eachSOId : setSalesOrderId){
                lstSalesOrder.add(new OrderApi__Sales_Order__c(Id = eachSOId,Fon_Added_SOLI__c = true));
            }
            update lstSalesOrder;
        }
    }
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
    }
    /**
@Description: Initializing new instance of SOLI based on param(soli).
@param: Object of OrderApi__Sales_Order_Line__c objOldSOLI as param.
@return: New instance of OrderApi__Sales_Order_Line__c
*/
    public OrderApi__Sales_Order_Line__c fetchSOLIInstance(OrderApi__Sales_Order_Line__c objOldSOLI){
        OrderApi__Sales_Order_Line__c objSOLI = new OrderApi__Sales_Order_Line__c(OrderApi__Sales_Order__c = objOldSOLI.OrderApi__Sales_Order__c,OrderApi__Item__c = objOldSOLI.OrderApi__Item__c,
                                                                                  OrderApi__Account__c = objOldSOLI.OrderApi__Account__c,OrderApi__Contact__c = objOldSOLI.OrderApi__Contact__c,OrderApi__Business_Group__c = objOldSOLI.OrderApi__Business_Group__c,
                                                                                  OrderApi__Price_Rule__c = objOldSOLI.OrderApi__Price_Rule__c);
        return objSOLI;
    }
    /**
@Description: Fetch Convenience fee Item.
@return: New instance of OrderApi__Sales_Order_Line__c
*/
    public OrderApi__Item__c fetchConvenienceFeeItem(){
        List<OrderApi__Item__c> lstItems = [SELECT Id,OrderApi__Price__c FROM OrderApi__Item__c WHERE Name =: strConveniencefee];
        if(!lstItems.isEmpty()){
            return lstItems[0];
        }
        return null;
    }
    /**
@Description: To fetch set of sales order record ids that have soli linked with Convenience fee Item.
@param: Collection of sales order id Set<Id> setSalesOrderId.
@return: sales order id's set that have soli linked with Convenience fee Item.
*/
    public Set<Id> fetchConvenienceFeeSalesOrder(Set<Id> setSalesOrderId){
        Set<Id> setConvenienceSalesOrderId = new Set<Id>();
        for(OrderApi__Sales_Order__c objSO : [SELECT Id,(SELECT Id FROM OrderApi__Sales_Order_Lines__r WHERE OrderApi__Item__r.Name =: strConveniencefee) 
                                              FROM OrderApi__Sales_Order__c WHERE Id IN :setSalesOrderId]){
                                                  if(objSO.OrderApi__Sales_Order_Lines__r != null && !objSO.OrderApi__Sales_Order_Lines__r.isEmpty()){
                                                      setConvenienceSalesOrderId.add(objSO.Id);
                                                  }
                                              }
        return setConvenienceSalesOrderId;
    }
    /**
@Description: To fetch list of sales order record.
@param: Collection of sales order id Set<Id> setSalesOrderId.
@return: sales order list List<OrderApi__Sales_Order__c>.
*/
    public Map<Id,List<OrderApi__Sales_Order_Line__c>> fetchSOLIBySOId(List<Id> lstSalesOrderId){
        Map<Id,List<OrderApi__Sales_Order_Line__c>> mapSalesOrderIdToLstSOLI = new Map<Id,List<OrderApi__Sales_Order_Line__c>>();
        for(OrderApi__Sales_Order__c objSO : [SELECT Id,(SELECT Id,OrderApi__Item__r.Is_Foundation_Donation__c,OrderApi__Sales_Order__c,OrderApi__Item__c,
                                                         OrderApi__Account__c,OrderApi__Contact__c,OrderApi__Business_Group__c,OrderApi__Price_Rule__c,
                                                         OrderApi__Sale_Price__c FROM OrderApi__Sales_Order_Lines__r) 
                                              FROM OrderApi__Sales_Order__c WHERE Id IN :lstSalesOrderId]){
                                                  if(objSO.OrderApi__Sales_Order_Lines__r != null && !objSO.OrderApi__Sales_Order_Lines__r.isEmpty()){
                                                      mapSalesOrderIdToLstSOLI.put(objSO.Id,objSO.OrderApi__Sales_Order_Lines__r);
                                                  }
                                              }
        return mapSalesOrderIdToLstSOLI;
    }
}