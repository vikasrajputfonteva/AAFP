/*
@Description:  Managing membership related action such as Cancelled Membership, Chnage Member Type and Change State etc.
@Author: RSI
*/
public with sharing class Fon_MembershipManagementInterfaceCtrl{
    Static String membershipStateChapter;
    Static String membershipLocal;
    final static String strActive = 'Active';
    final static String strInactive = 'Inactive';
    final static String strPostedEntity = 'Invoice';
    final static String strCancelled = 'Cancelled';
    final static List<String> lstDraftInvoice = new List<String>{'Draft','Posted'};
        final static Boolean isVoid = false;
    public static Map<String,String> mapKeyToMSG = new Map<String,String>();
    
    /* Cancel membership button functionality Start */
    @AuraEnabled
    public static Map<String,String> cancelMembership(String recordId, String reason, Boolean isRevertFinancial){
        List<Fon_Membership_Staging__c> lstMember = [SELECT Id,Fon_Staging_Status__c FROM Fon_Membership_Staging__c WHERE Fon_Staging_Status__c =:strActive AND Fon_Contact__c =:recordId];
        for(Fon_Membership_Staging__c eachMember : lstMember){
            eachMember.Fon_Staging_Status__c = strCancelled;
        }
        if(!lstMember.isEmpty()){
            if(isRevertFinancial){
                update_InvoiceAndScheduledPayment(recordId);//Voiding invoice
            }
            updateSubscription(recordId);
            
            update lstMember;
            //update new Contact(id=recordId,Fon_Current_Membership_Status__c=strCancelled);
        }
        else{
            mapKeyToMSG.put('isEmptyMember','true');
        }
        return mapKeyToMSG;
    }
    
    public static void update_InvoiceAndScheduledPayment(Id contactId){
        Set<Id> salesOrderIdSet = new Set<Id>();
        List<OrderApi__Invoice__c> lstInvoice = new List<OrderApi__Invoice__c>();
        List<OrderApi__Subscription__c> lstSubscription = [SELECT Id,OrderApi__Status__c,
                                                           OrderApi__Cancelled_Reason__c,
                                                           OrderApi__Sales_Order_Line__c,
                                                           OrderApi__Item__r.OrderApi__Item_Class__r.Fon_Is_Main_Membership__c,
                                                           OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__c 
                                                           FROM OrderApi__Subscription__c 
                                                           WHERE OrderApi__Contact__c =:contactId 
                                                           AND OrderApi__Status__c =:strActive 
                                                           AND OrderApi__Subscription_Plan__c != null 
                                                           AND OrderApi__Item__r.OrderApi__Item_Class__r.Fon_Is_Main_Membership__c =true];
        for(OrderApi__Subscription__c eachSubscription : lstSubscription){           
            if(eachSubscription.OrderApi__Sales_Order_Line__c != null){
                salesOrderIdSet.add(eachSubscription.OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__c);
            }
        }
        if(!salesOrderIdSet.isEmpty()){
            List<OrderApi__Sales_Order__c> lstSO = [SELECT Id,(SELECT Id,OrderApi__Is_Voided__c,OrderApi__Is_Posted__c,OrderApi__Is_Cancelled__c, 
                                                               OrderApi__Is_Paid__c FROM OrderApi__Invoices__r WHERE OrderApi__Status__c IN :lstDraftInvoice) 
                                                    FROM OrderApi__Sales_Order__c 
                                                    WHERE Id IN :salesOrderIdSet 
                                                   ]; 
            if(lstSO.size()>0){
                for(OrderApi__Sales_Order__c eachSO : lstSO){
                    for(OrderApi__Invoice__c eachInvoice : eachSO.OrderApi__Invoices__r){
                        if(eachInvoice.OrderApi__Is_Posted__c && !eachInvoice.OrderApi__Is_Paid__c){
                            eachInvoice.OrderApi__Is_Voided__c = true;
                            lstInvoice.add(eachInvoice);
                        }else if(!eachInvoice.OrderApi__Is_Posted__c && !eachInvoice.OrderApi__Is_Paid__c){
                            eachInvoice.OrderApi__Is_Cancelled__c = true;
                            lstInvoice.add(eachInvoice);
                        }
                    }
                }
            }
        }
        if(!lstInvoice.isEmpty()){
            update lstInvoice;
        }
    }
    
    public static void updateSubscription(Id contactId){
        List<OrderApi__Subscription__c> lstSubscription = [SELECT Id,OrderApi__Status__c,OrderApi__Cancelled_Reason__c,OrderApi__Sales_Order_Line__c,
                                                           OrderApi__Item__r.OrderApi__Item_Class__r.Fon_Is_Main_Membership__c,
                                                           OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__c FROM OrderApi__Subscription__c 
                                                           WHERE OrderApi__Contact__c =:contactId AND OrderApi__Status__c =:strActive AND 
                                                           OrderApi__Subscription_Plan__c != null AND OrderApi__Item__r.OrderApi__Item_Class__r.Fon_Is_Main_Membership__c =:true];
        for(OrderApi__Subscription__c eachSubscription : lstSubscription){
            eachSubscription.OrderApi__Status__c = strCancelled;
        }
        if(!lstSubscription.isEmpty()){
            update lstSubscription;
        }
    }
    
    /* Cancel membership button functionality End */   
    
    /*  Change Member type button functionality Start */ 
    /* @Lightning Component: Fon_MembershipManagementInterface */
    @AuraEnabled
    public static Map<String,String> changeMembershipType(String recordId){
        List<Fon_Membership_Staging__c> lstMember = [SELECT Id,Fon_Staging_Status__c,Fon_Cancelled_Reason__c FROM Fon_Membership_Staging__c 
                                                     WHERE Fon_Staging_Status__c =:strActive AND Fon_Contact__c =:recordId];
        if(!lstMember.isEmpty()){
            //update new Contact(id=recordId,Fon_Current_Membership_Status__c=strInactive);
            update_Subscription_InvoiceAndScheduledPayment(recordId); //Updating Subscription,invoice and Scheduled Payment
        }else{
            mapKeyToMSG.put('isEmptyMember','true');
        }
        return mapKeyToMSG;
    }
    
    public static void update_Subscription_InvoiceAndScheduledPayment(Id contactId){
        Set<Id> salesOrderIdSet = new Set<Id>();
        //List<OrderApi__Scheduled_Payment__c> updateschedulePaymentList = new  List<OrderApi__Scheduled_Payment__c>();
        List<OrderApi__Subscription__c> lstSubscription = [SELECT Id,OrderApi__Status__c,
                                                           OrderApi__Cancelled_Reason__c,
                                                           OrderApi__Sales_Order_Line__c,
                                                           OrderApi__Item__r.OrderApi__Item_Class__r.Fon_Is_Main_Membership__c,
                                                           OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__c 
                                                           FROM OrderApi__Subscription__c 
                                                           WHERE OrderApi__Contact__c =:contactId 
                                                           AND OrderApi__Status__c =:strActive 
                                                           AND OrderApi__Subscription_Plan__c != null 
                                                           AND OrderApi__Item__r.OrderApi__Item_Class__r.Fon_Is_Main_Membership__c =:true];
        if(!lstSubscription.isEmpty()){
            for(OrderApi__Subscription__c eachSubscription : lstSubscription){
                eachSubscription.OrderApi__Status__c = strCancelled;
                if(eachSubscription.OrderApi__Sales_Order_Line__c != null){
                    salesOrderIdSet.add(eachSubscription.OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__c);
                }
            }
            update lstSubscription;
            /*   
for(OrderApi__Subscription__c eachSubscribe : lstSubscription){
eachSubscribe.OrderApi__Status__c = strExpired;
}
update lstSubscription; 
*/
        }
        List<OrderApi__Invoice__c> lstInvoice = new List<OrderApi__Invoice__c>();
        List<OrderApi__Sales_Order__c> lstSO = [SELECT Id,(SELECT Id,OrderApi__Is_Voided__c,OrderApi__Is_Posted__c,OrderApi__Is_Cancelled__c, 
                                                           OrderApi__Is_Paid__c FROM OrderApi__Invoices__r 
                                                           WHERE OrderApi__Status__c IN :lstDraftInvoice) 
                                                FROM OrderApi__Sales_Order__c 
                                                WHERE Id IN :salesOrderIdSet 
                                                AND OrderApi__Posting_Entity__c =:strPostedEntity ];
        // AND OrderApi__Schedule_Type__c = 'Installment'];
        
        for(OrderApi__Sales_Order__c eachSO : lstSO){
            for(OrderApi__Invoice__c eachInvoice : eachSO.OrderApi__Invoices__r){
                if(eachInvoice.OrderApi__Is_Posted__c && !eachInvoice.OrderApi__Is_Paid__c){
                    eachInvoice.OrderApi__Is_Voided__c = true;
                }else if(!eachInvoice.OrderApi__Is_Posted__c && !eachInvoice.OrderApi__Is_Paid__c){
                    eachInvoice.OrderApi__Is_Cancelled__c = true;
                }
                lstInvoice.add(eachInvoice);
            }
        }
        if(!lstInvoice.isEmpty()){
            /*Set<Id> invoiceIds= (new Map<Id,sObject>(lstInvoice)).keySet(); 
if(!invoiceIds.isEmpty()){
List<OrderApi__Scheduled_Payment__c> schedulePaymentList = [select OrderApi__Is_Cancelled__c from OrderApi__Scheduled_Payment__c where OrderApi__Invoice__c in:invoiceIds];
if(schedulePaymentList.size()>0){
for(OrderApi__Scheduled_Payment__c sp:schedulePaymentList){
sp.OrderApi__Is_Cancelled__c=true;         
updateschedulePaymentList.add(sp);
}
}
}*/
            update lstInvoice;
            /* if(updateschedulePaymentList.size()>0){
update updateschedulePaymentList;
}*/
        }
    }
    
    /*  Change Member type button functionality End */ 
    
    /*
@Description: Fetching active Membership record id
@Param: String recordId => Passing the id of the contact.
@Return: Active membership record id.
@Author: RSI
*/
    @AuraEnabled
    public static String fetchingActiveMembership(String recordId){
        String membershipRecordId = '';
        List<Fon_Membership_Staging__c> lstMemberShipStage = [SELECT Id FROM Fon_Membership_Staging__c WHERE Fon_Contact__c =:recordId AND Fon_Staging_Status__c =:strActive];
        for(Fon_Membership_Staging__c eachMember : lstMemberShipStage){
            membershipRecordId = eachMember.Id;
            break;
        }
        return membershipRecordId;
    }
    
    /*
@Description: Fetching active subscription id
@Param: String recordId => Passing the id of the contact.
@Return: Active subscription record id.
@Author: RSI
*/
    @AuraEnabled
    public static OrderApi__Subscription__c fetchingActiveSubscription(String recordId){
        OrderApi__Subscription__c subscriptionRecId;
        List<OrderApi__Subscription__c> lstSubscription = [SELECT Id,OrderApi__Subscription_Plan__c FROM OrderApi__Subscription__c WHERE OrderApi__Contact__c=:recordId AND OrderApi__Status__c =:strActive AND Fon_Is_Main_Membership__c =:true];
        for(OrderApi__Subscription__c  eachSubscribe : lstSubscription){
            subscriptionRecId = eachSubscribe;
            break;
        }
        return subscriptionRecId;
    }
    
    /*
@Description: Fetching active Membership record id
@Param: String recordId => Passing the id of the contact.
@Return: Active membership record id.
@Author: RSI

@AuraEnabled
public static String updateContactByMembership(String recordId){
if(!String.isBlank(recordId)){
update new Contact(id=recordId,Fon_Current_Membership_Status__c=strInactive);
return 'true';
}
return 'false';
}
*/
    
    @AuraEnabled
    public static Boolean changeStateLocal(String recordId){
        List<Contact> conList=[select id from Contact Where id=:recordId And Fon_Chapter_Change_Needed__c=true];
        if(conList.size()>0){
            return true;
        }
        else{
            return false;
        }  
    }
    
    @AuraEnabled
    public static Boolean changeStateLocalMethod(String contactId,String activeMembershipId,String State,String Local){//TC-012383
        Set<Id> itemIds = new Set<Id>();
        Set<Id> soIds = new Set<Id>();
        Map<Id,Id> subscriptionVsItem = new Map<Id,Id>();
        Map<Id,Id> ItemVsSubscription = new Map<Id,Id>();
        List<OrderApi__Item__c> stateItem = new List<OrderApi__Item__c>();
        List<OrderApi__Item__c> localItem = new List<OrderApi__Item__c>();
        List<OrderApi__Badge__c> updateBadgeList = new List<OrderApi__Badge__c>();
        List<OrderApi__Subscription_Line__c> updateSubscriptionLine = new List<OrderApi__Subscription_Line__c>();
        Map<Id,Id> stVSbadgeType = new Map<Id,Id>();
        Map<Id,Id> stVSbadgeWorkflow = new Map<Id,Id>();
        String stateName;
        String localName;
        
        List<Fon_Membership_Staging__c> lstMemberShipStage = [SELECT Fon_Chapter__c,Fon_Local__c,Fon_Year__c,Fon_Membership_Type__c,Fon_Membership_State__c,Fon_Membership_Local__c FROM Fon_Membership_Staging__c WHERE id =:activeMembershipId AND Fon_Staging_Status__c ='Active' Limit 1];
        if(lstMemberShipStage.size()>0){
            if(String.isNotBlank(State)){
                String[] temp= lstMemberShipStage[0].Fon_Chapter__c.split(' ');
                stateName = temp[0]+' '+temp[1]+' '+temp[2]+' '+State;
                stateItem = [select id from OrderApi__Item__c where Name=:stateName And OrderApi__Item_Class__r.Fon_Is_State_Membership__c=true];
            }
            if(String.isNotBlank(Local)){          
                String[] temp= lstMemberShipStage[0].Fon_Local__c.split(' ');
                localName = temp[0]+' '+temp[1]+' '+temp[2]+' '+State+' '+Local;
                localItem = [select id from OrderApi__Item__c where Name=:localName And OrderApi__Item_Class__r.Fon_Is_Local_Membership__c=true];
            }
        }
        if(stateItem.size()>0){
            List<OrderApi__Badge_Workflow__c> stateBadge=[select id,OrderApi__Badge_Type__c from OrderApi__Badge_Workflow__c where OrderApi__Item__c=:stateItem[0].Id];
            if(stateBadge.size()>0){
                stVSbadgeType.put(stateItem[0].Id,stateBadge[0].OrderApi__Badge_Type__c);
                stVSbadgeWorkflow.put(stateItem[0].Id,stateBadge[0].Id);
            }
        }
        if(localItem.size()>0){
            List<OrderApi__Badge_Workflow__c> localBadge=[select id,OrderApi__Badge_Type__c from OrderApi__Badge_Workflow__c where OrderApi__Item__c=:localItem[0].Id];
            if(localBadge.size()>0){
                stVSbadgeType.put(localItem[0].Id,localBadge[0].OrderApi__Badge_Type__c);
                stVSbadgeWorkflow.put(localItem[0].Id,localBadge[0].Id);
            }
        }
        if(lstMemberShipStage.size()>0){
            if(State!=lstMemberShipStage[0].Fon_Membership_State__c || Local!=lstMemberShipStage[0].Fon_Membership_Local__c){
                if(stateItem.size()>0 || localItem.size()>0){
                    List<OrderApi__Subscription__c> subscriptions = [select id from OrderApi__Subscription__c 
                                                                     where OrderApi__Contact__c=:contactId 
                                                                     And OrderApi__Is_Active__c=true  
                                                                     And OrderApi__Item__r.OrderApi__Is_Active__c=true 
                                                                     And OrderApi__Item__r.OrderApi__Item_Class__r.OrderApi__Is_Active__c=true
                                                                     And OrderApi__Item__r.OrderApi__Item_Class__r.Fon_Is_Main_Membership__c=true];
                    if(subscriptions.size()>0){
                        List<OrderApi__Subscription_Line__c> subscriptionLines = [select OrderApi__Item__c,OrderApi__Sales_Order_Line__c from OrderApi__Subscription_Line__c where OrderApi__Subscription__c=:subscriptions[0].id And OrderApi__Item__c!=Null];
                        if(subscriptionLines.size()>0){
                            for(OrderApi__Subscription_Line__c SL:subscriptionLines){
                                itemIds.add(SL.OrderApi__Item__c);
                                soIds.add(SL.OrderApi__Sales_Order_Line__c);
                                ItemVsSubscription.put(SL.OrderApi__Item__c,SL.Id);
                            }    
                        }
                        if(!itemIds.isEmpty()){
                            List<OrderApi__Item__c> itmList=[select OrderApi__Item_Class__r.Fon_Is_State_Membership__c,OrderApi__Item_Class__r.Fon_Is_Local_Membership__c from OrderApi__Item__c where OrderApi__Is_Active__c=true And id in :itemIds And (OrderApi__Item_Class__r.Fon_Is_State_Membership__c=true OR OrderApi__Item_Class__r.Fon_Is_Local_Membership__c=true)];
                            if(itmList.size()>0){
                                for(OrderApi__Item__c itm:itmList){
                                    for(OrderApi__Subscription_Line__c SL:subscriptionLines){
                                        if(itm.Id==SL.OrderApi__Item__c){
                                            if(itm.OrderApi__Item_Class__r.Fon_Is_State_Membership__c){
                                                if(stateItem.size()>0){
                                                    SL.OrderApi__Item__c=stateItem[0].Id;
                                                    subscriptionVsItem.put(SL.Id,stateItem[0].Id);
                                                    updateSubscriptionLine.add(SL);
                                                }
                                            }
                                            else if(itm.OrderApi__Item_Class__r.Fon_Is_Local_Membership__c){
                                                if(localItem.size()>0){
                                                    SL.OrderApi__Item__c=localItem[0].Id;
                                                    subscriptionVsItem.put(SL.Id,localItem[0].Id);
                                                    updateSubscriptionLine.add(SL);
                                                }
                                            }
                                        }
                                    }  
                                }
                            }
                        }
                        if(!soIds.isEmpty()){
                            List<OrderApi__Badge__c> badgeList=[select OrderApi__Item__c from OrderApi__Badge__c where OrderApi__Is_Active__c=true And OrderApi__Sales_Order_Line__c in:soIds];
                            if(badgeList.size()>0){
                                for(OrderApi__Badge__c bdg:badgeList){
                                    if(!subscriptionVsItem.isEmpty()){                                       
                                        bdg.OrderApi__Badge_Type__c=stVSbadgeType.get(subscriptionVsItem.get(ItemVsSubscription.get(bdg.OrderApi__Item__c)));
                                        bdg.OrderApi__Badge_Workflow__c=stVSbadgeWorkflow.get(subscriptionVsItem.get(ItemVsSubscription.get(bdg.OrderApi__Item__c)));
                                        bdg.OrderApi__Item__c=subscriptionVsItem.get(ItemVsSubscription.get(bdg.OrderApi__Item__c)); 
                                        updateBadgeList.add(bdg);
                                    }
                                }
                            }
                        }
                    }
                    //Removed from query Fon_Membership_State__c,Fon_Membership_Local__c
                    List<Contact> conList=[select Fon_Chapter_Change_Needed__c from Contact where id=:contactId];          
                    if(updateSubscriptionLine.size()>0){
                        update updateSubscriptionLine; 
                        if(updateBadgeList.size()>0){
                            update updateBadgeList;
                        }
                        conList[0].Fon_Chapter_Change_Needed__c=false;
                        //conList[0].Fon_Membership_State__c=State;
                        //conList[0].Fon_Membership_Local__c=Local;
                        update conList;
                        return true;
                    }
                }
            }
        }
        return false;
    }
    
    @AuraEnabled
    public static Boolean disableRevertTheFinancialCheckbox(String recordId){
        OrderApi__Sales_Order__c[] duesSo = [select id from OrderApi__Sales_Order__c 
                                             WHERE Fon_Membership_Staging__c =:recordId
                                             AND Fon_Salesorder_Type__c = 'Dues'
                                             AND Fon_Membership_Staging__r.Fon_Staging_Status__c = 'Active'
                                             AND OrderApi__Posting_Entity__c = 'Invoice'];
        if(duesSo.size()>0){
            OrderApi__Invoice__c[] inv = [select id from OrderApi__Invoice__c 
                                          WHERE OrderApi__Sales_Order__c =: duesSo[0].Id
                                          AND OrderApi__Amount_Paid__c = 0
                                         ];
            if(inv.size()>0){
                return false;
            }
            else{
                return true;
            }
        }
        return true;
    }
}