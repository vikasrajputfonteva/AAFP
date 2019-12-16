public class Fon_CommonUtilityCtrl{
    //final static Boolean strInvoiceStatus = true;
    final static String strActive = 'Active';
    final static String strInactive = 'Inactive';
    final static String strPostedEntity = 'Invoice';
    //final static String strPostingStatus = 'Posted';
    final static String strCancelled = 'Cancelled';
    final static String strExpired = 'Expired';
    final static List<String> lstDraftInvoice = new List<String>{'Draft','Posted'};
        final static Boolean isVoid = false;
    final static String strRefund = 'Refund';
    static String strInvoiceStatusCancel = 'Cancelled';
    public static Map<String,String> mapKeyToMSG = new Map<String,String>();
    
    public static List<OrderApi__Subscription__c> fetchSubscriptionBycontactIdSet(Set<Id> contactIdSet){
        List<OrderApi__Subscription__c> lstSubscription = [SELECT Id,OrderApi__Status__c,
                                                           OrderApi__Cancelled_Reason__c,
                                                           OrderApi__Sales_Order_Line__c,
                                                           OrderApi__Item__r.OrderApi__Item_Class__r.Fon_Is_Main_Membership__c,
                                                           OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__c 
                                                           FROM OrderApi__Subscription__c 
                                                           WHERE OrderApi__Contact__c IN :contactIdSet
                                                           AND OrderApi__Status__c =:strActive 
                                                           AND OrderApi__Subscription_Plan__c != null 
                                                           AND OrderApi__Item__r.OrderApi__Item_Class__r.Fon_Is_Main_Membership__c =:true];
        return lstSubscription;
    }
    
    // Is Financial = true: this function will be used for financial Membership
    public static void updatingInvoiceAndScheduledPayment(List<OrderApi__Subscription__c> lstSubscription){
        Set<Id> salesOrderIdSet = new Set<Id>();
        List<OrderApi__Invoice__c> lstInvoice = new List<OrderApi__Invoice__c>();
        
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
                                                    AND OrderApi__Posting_Entity__c =:strPostedEntity];
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
            Set<Id> invoiceIds= (new Map<Id,sObject>(lstInvoice)).keySet(); 
            update lstInvoice;
        }
    }
    // Is Financial = false :: this function will be used for Non financial Membership
    public static void updateSubscription(List<OrderApi__Subscription__c> lstSubscription, String strStatus){
        for(OrderApi__Subscription__c eachSubscription : lstSubscription){
            eachSubscription.OrderApi__Status__c = strStatus;
        }
        if(!lstSubscription.isEmpty()){
            update lstSubscription;
        }
    }
    
    public static void updatingContactStatus(Set<Id> contactIdSet, String strStatus){
       /* List<Contact> lstContact = new List<Contact>();
        for(Id eachId : contactIdSet){
            if(!String.isBlank(eachId)){
                lstContact.add(new Contact(id=eachId,Fon_Current_Membership_Status__c=strStatus));
            }
        }
        if(!lstContact.isEmpty()){
            update lstContact;
        }*/
    }
    
    public void createNewMembership(Set<Id> contactIdSet){
        List<Contact> lstContact = [SELECT Id,Name FROM Contact WHERE Id IN:contactIdSet];
        List<Fon_Membership_Staging__c> lstMembershipRecord = new List<Fon_Membership_Staging__c>();
        for(Contact eachContact : lstContact){
            lstMembershipRecord.add(fetchMembershipInstance(eachContact));
        }
        insert lstMembershipRecord;
    }
    
    public Fon_Membership_Staging__c fetchMembershipInstance(Contact objcontact){
        Fon_Membership_Staging__c objMember = new Fon_Membership_Staging__c();
        objMember.Fon_Contact__c = objcontact.Id;
        objMember.Name = objcontact.Name;
        objMember.Fon_Staging_Status__c = Label.Fon_New;
        objMember.Fon_Membership_Type__c = Label.Fon_Resident;
        objMember.Fon_Dues_Paid_by_Chapter__c = false;
        objMember.Fon_Dues_Paid_by_Residency_Program__c = false;
        objMember.Fon_Membership_Activation_Date__c = Date.today();
        objMember.Fon_Join_Date__c = Date.today();
        objMember.Fon_Chapter_Join_Date__c = Date.today();
        objMember.Fon_Residency_Program_Graduation_Date__c= Date.today();
        return objMember;
    }
}