public class Fon_SalesOrderLineService {
    Public static void createSalesOrderLine(List<OrderApi__Sales_Order_Line__c> newList){
        Framework.Log.push(Fon_SalesOrderLineService.class.getName(),'createSalesOrderLine'); 
        if(Fon_ConstantClass.runOnce){
            if(!system.isBatch()){
                String strConveniencefee = Label.Fon_Convenience_Fee;
                List<OrderApi__Item__c> convenienceitemList= [select OrderApi__Price__c from OrderApi__Item__c where Name=:strConveniencefee And OrderApi__Is_Active__c=true];//Create a new soli with item 'Convenience fee' of value $15. 
                List<OrderApi__Sales_Order_Line__c> insertSalesOrderLineList = new List<OrderApi__Sales_Order_Line__c>();
                
                Map<Id,Decimal> itemVSprice = new  Map<Id,Decimal>(); 
                Set<Id> subscriptionIds = new Set<Id>();
                Set<Id> existingConvenienceFeeSoli = new Set<Id>();
                Map<Id,Id> subscriptionVSitem = new Map<Id,Id>();
                Set<Id> originalSalesOrderIds = new Set<Id>();
                Map<Id,Id> originalSalesOrderVSsubscription = new Map<Id,Id>();
                Set<Id> enableSchedulesubScriptionIds= new Set<Id>();
                Set<Id> itemIds =  new Set<Id>();
                Set<Id> mainMembershipItemIds =  new Set<Id>();
                
                if(newList.size()>0){
                    for(OrderApi__Sales_Order_Line__c currentSoli:newList){
                        if(currentSoli.OrderApi__Subscription__c!=Null){
                            subscriptionIds.add(currentSoli.OrderApi__Subscription__c);//Subscription Id
                        }
                        if(currentSoli.OrderApi__Item__c!=Null){
                            itemIds.add(currentSoli.OrderApi__Item__c);
                        }
                    }
                    if(!subscriptionIds.isEmpty()){
                        List<OrderApi__Subscription__c> subscriptionList =[select OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__c,OrderApi__Subscription_Plan__r.OrderApi__Enable_Schedule__c from OrderApi__Subscription__c where Id in :subscriptionIds];
                        if(subscriptionList.size()>0){
                            for(OrderApi__Subscription__c subscription:subscriptionList){
                                if(subscription.OrderApi__Subscription_Plan__r.OrderApi__Enable_Schedule__c==true){
                                    enableSchedulesubScriptionIds.add(subscription.Id);
                                }
                                originalSalesOrderIds.add(subscription.OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__c);
                                originalSalesOrderVSsubscription.put(subscription.OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__c,subscription.Id);
                            }
                        }
                    }
                    if(!originalSalesOrderIds.isEmpty()){                        
                        List<OrderApi__Sales_Order__c> soliList=[select id,(select OrderApi__Item__c,OrderApi__Item__r.OrderApi__Price__c, OrderApi__Sale_Price__c from OrderApi__Sales_Order_Lines__r where OrderApi__Item__r.Is_Foundation_Donation__c=true And OrderApi__Item__r.OrderApi__Is_Active__c=true) from OrderApi__Sales_Order__c where Id in:originalSalesOrderIds];
                        if(soliList.size()>0){
                            for(OrderApi__Sales_Order__c SO:soliList){
                                if(SO.OrderApi__Sales_Order_Lines__r.Size()>0){
                                    for(OrderApi__Sales_Order_Line__c SOLI:SO.OrderApi__Sales_Order_Lines__r){
                                        subscriptionVSitem.put(originalSalesOrderVSsubscription.get(SO.Id),SOLI.OrderApi__Item__c);
                                        itemVSprice.put(SOLI.OrderApi__Item__c,SOLI.OrderApi__Sale_Price__c);
                                    }
                                }
                            } 
                        }
                    }     
                    if(!itemIds.isEmpty()){
                        List<OrderApi__Item__c> mainMembershipItemList = [select id from OrderApi__Item__c where id in :itemIds And OrderApi__Item_Class__r.Fon_Is_Main_Membership__c=true];
                        if(mainMembershipItemList.size()>0){
                            mainMembershipItemIds = (new Map<Id,OrderApi__Item__c>(mainMembershipItemList)).keySet();
                        }
                    }
                    for(OrderApi__Sales_Order_Line__c currentSoli:newList){
                        if(mainMembershipItemIds.contains(currentSoli.OrderApi__Item__c) && currentSoli.OrderApi__Is_Renewal__c == true && currentSoli.OrderApi__Subscription__c!=Null && enableSchedulesubScriptionIds.contains(currentSoli.OrderApi__Subscription__c)){//If soli 'is Renewal' is checked for current SOLI, 'Subscription (Upgrade/Renew)' is not empty for current SOLI 
                            //Creating Sales Order Line With Convenience Fee Item.
                            if(convenienceitemList.size()>0 && !existingConvenienceFeeSoli.contains(currentSoli.OrderApi__Sales_Order__c)){
                                OrderApi__Sales_Order_Line__c newSoli= createConvenienceFeeSoli(currentSoli.Id, currentSoli.OrderApi__Sales_Order__c,convenienceitemList[0].Id);
                                insertSalesOrderLineList.add(newSoli);
                                existingConvenienceFeeSoli.add(currentSoli.OrderApi__Sales_Order__c);
                            } 
                            //Creating Sales Order Line if Orginal Sales Order has Sales Order Line with Is_Foundation_Donation__c Item. 
                            if(!subscriptionVSitem.isEmpty() && subscriptionVSitem.containsKey(currentSoli.OrderApi__Subscription__c)){
                                OrderApi__Sales_Order_Line__c newSoli= createFoundationDonationSoli(currentSoli.Id, currentSoli.OrderApi__Sales_Order__c,subscriptionVSitem.get(currentSoli.OrderApi__Subscription__c),itemVSprice.get(subscriptionVSitem.get(currentSoli.OrderApi__Subscription__c)));
                                insertSalesOrderLineList.add(newSoli);
                            }
                        }
                    }                
                    if(insertSalesOrderLineList.size()>0){
                        Fon_ConstantClass.runOnce=false;                       
                        //Inserting Sales Order Line
                        insert insertSalesOrderLineList;
                    }
                }
            }
        }
        Framework.Log.pop();
    }
    public static OrderApi__Sales_Order_Line__c createConvenienceFeeSoli(Id ParentSOL, Id SalesOrderId,Id itemId){
        OrderApi__Sales_Order_Line__c newSoli = new OrderApi__Sales_Order_Line__c();
        newSoli.OrderApi__Sales_Order__c= SalesOrderId;
        newSoli.OrderApi__Item__c= itemId;
       // newSoli.OrderApi__Is_Renewal__c = true;
        newSoli.OrderApi__Sales_Order_Line__c = ParentSOL;
        return newSoli;
    }
    public static OrderApi__Sales_Order_Line__c createFoundationDonationSoli(Id ParentSOL, Id SalesOrderId,Id itemId,Decimal itemPrice){
        OrderApi__Sales_Order_Line__c newSoli = new OrderApi__Sales_Order_Line__c();
        newSoli.OrderApi__Sales_Order__c= SalesOrderId;
        newSoli.OrderApi__Item__c= itemId;
        newSoli.OrderApi__Sale_Price__c= itemPrice;
        newSoli.OrderApi__Price_Override__c=true;
        //newSoli.OrderApi__Is_Renewal__c = true;
        newSoli.OrderApi__Sales_Order_Line__c = ParentSOL;
        return newSoli;
    }
}