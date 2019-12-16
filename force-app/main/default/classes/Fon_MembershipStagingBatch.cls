global class Fon_MembershipStagingBatch implements Database.Batchable<sObject>, Database.Stateful{
    List<OrderApi__Sales_Order__c> lstSalesOrder = new List<OrderApi__Sales_Order__c>();
    List<Fon_Membership_Staging__c> lstMembershipRec = new List<Fon_Membership_Staging__c>();
    Set<Id> memberStageIdSet;
    
    global Fon_MembershipStagingBatch(){}
    global Fon_MembershipStagingBatch(Set<Id> memberStageIdSet){
        this.memberStageIdSet = memberStageIdSet;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(memberStageIdSet != null){//Replaced Fon_Residency_Program__c with AAFP_Residency_program_Account__c
            return Database.getQueryLocator('SELECT Fon_AAFP_Subscription_Plan_Picklist__c,Id,Fon_Contact__r.AccountId,Fon_Contact__r.AAFP_Residency_program_Account__c,Fon_Dues_Paid_by_Chapter__c,Fon_Dues_Paid_by_Residency_Program__c,Fon_Foundation_Contribution_Information__c,Fon_Staging_Status__c,Fon_Contact__c,Fon_Year__c,Fon_Membership_Activation_Date__c,Fon_PAC_Contribution_Information__c,'+
                                            'Fon_Membership_State__c,Fon_Membership_Local__c,Fon_Is_New__c,Fon_Chapter_Id__c,Fon_Generate_New_Invoice__c,'+
                                            'Fon_National__c,Fon_Chapter__c,Fon_Local__c,Fon_Foundation_Donation_Renewal__c,Fon_Convenience_Fee__c,Fon_Create_Invoice__c,'+
                                            'Fon_Membership_Type__c,Fon_Subscription_Plan__c,Fon_Residency_Account__c,Fon_Chapter_Account__c,Fon_Residency_Account_ID__c,Fon_ContactID__c,Fon_Payment_Method_Id__c,Fon_Payment_Method__c,Fon_Join_Date__c FROM Fon_Membership_Staging__c WHERE Id IN :memberStageIdSet');
        }
        return Database.getQueryLocator('SELECT Fon_AAFP_Subscription_Plan_Picklist__c,Id,Fon_Contact__r.AccountId,Fon_Contact__r.AAFP_Residency_program_Account__c,Fon_Dues_Paid_by_Chapter__c,Fon_Dues_Paid_by_Residency_Program__c,Fon_Foundation_Contribution_Information__c,Fon_Staging_Status__c,Fon_Contact__c,Fon_Year__c,Fon_Membership_Activation_Date__c,Fon_PAC_Contribution_Information__c,'+
                                        'Fon_Membership_State__c,Fon_Membership_Local__c,Fon_Is_New__c,Fon_Chapter_Id__c,Fon_Generate_New_Invoice__c,'+
                                        'Fon_National__c,Fon_Chapter__c,Fon_Local__c,Fon_Foundation_Donation_Renewal__c,Fon_Convenience_Fee__c,Fon_Create_Invoice__c,'+
                                        'Fon_Membership_Type__c,Fon_Subscription_Plan__c,Fon_Residency_Account__c,Fon_Chapter_Account__c,Fon_Residency_Account_ID__c,Fon_ContactID__c,Fon_Payment_Method_Id__c,Fon_Payment_Method__c,Fon_Join_Date__c FROM Fon_Membership_Staging__c');
    }
    
    global void execute(Database.BatchableContext BC, List<Fon_Membership_Staging__c> lstMemberStage) {
        List<OrderApi__Sales_Order__c> lstNewSalesOrder = new Fon_MembershipStagingTriggerHandler().initializeMembershipStage(lstMemberStage);
        if(lstNewSalesOrder != null && !lstNewSalesOrder.isEmpty()){
            lstSalesOrder.addAll(lstNewSalesOrder);
        }
        for(Fon_Membership_Staging__c eachMember : lstMemberStage){
            if(eachMember.Fon_Staging_Status__c == 'Approved'){
                lstMembershipRec.add(new Fon_Membership_Staging__c(Id=eachMember.Id, Fon_Staging_Status__c='Active'));
            }
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        if(!lstMembershipRec.isEmpty()){
            update lstMembershipRec;
        }
        
        Set<Id> ContactIdSet=new Set<Id>(); 
        Map<Id,String> mainMembership =new map<Id,String>();
        Map<Id,String> chapterState =new map<Id,String>();
        Map<Id,String> chapterLocal = new map<Id,String>();
        Map<Id,String> stagingStatus = new Map<Id,String>();
        Map<Id,Date> activationDate = new Map<Id,Date>();
        Map<Id,Date> medicalSchoolGraduationDate = new Map<Id,Date>();
        Map<Id,Boolean> donationRenewal = new Map<Id,Boolean>();
        Set<Id> mdIds= (new Map<Id,Fon_Membership_Staging__c>(lstMembershipRec)).keySet();
        Map<Id,String> planMap = new Map<Id,String>();
        
        List<Fon_Membership_Staging__c> msList = [select Fon_Medical_School_Graduation_Date__c,id,Fon_AAFP_Subscription_Plan_Picklist__c,Fon_Membership_Activation_Date__c,Fon_Contact__c,Fon_Membership_State__c,Fon_Foundation_Donation_Renewal__c,
                                                  Fon_Membership_Local__c,Fon_Membership_Type__c,Fon_Staging_Status__c from Fon_Membership_Staging__c where id in:mdIds];
        
        if(msList.size()>0){
            for(Fon_Membership_Staging__c member :msList){
                ContactIdSet.add(member.Fon_Contact__c);           
                mainMembership.put(member.Fon_Contact__c,member.Fon_Membership_Type__c);
                chapterState.put(member.Fon_Contact__c,member.Fon_Membership_State__c);
                chapterLocal.put(member.Fon_Contact__c,member.Fon_Membership_Local__c);    
                stagingStatus.put(member.Fon_Contact__c,member.Fon_Staging_Status__c);
                activationDate.put(member.Fon_Contact__c,member.Fon_Membership_Activation_Date__c);
                donationRenewal.put(member.Fon_Contact__c,member.Fon_Foundation_Donation_Renewal__c);
                planMap.put(member.Fon_Contact__c,member.Fon_AAFP_Subscription_Plan_Picklist__c);
                medicalSchoolGraduationDate.put(member.Fon_Contact__c,member.Fon_Medical_School_Graduation_Date__c);
            }
        }
        if(!ContactIdSet.isEmpty()){//Removed From query Fon_Main_Membership__c Fon_Membership_State__c,Fon_Membership_Local__c,Fon_Membership_Activation_Date__c,Fon_Current_Membership_Status__c
            List<Contact> contacts =[select id,
                                     Fon_AAFP_Subscription_Plan_Picklist__c,
                                     Fon_Foundation_Donation_Renewal__c
                                     from Contact where Id In : ContactIdSet];
            if(contacts.size() >0){
                for(Contact con: contacts){
                    //con.Fon_Main_Membership__c=mainMembership.get(con.Id);
                    //con.Fon_Membership_Local__c=chapterLocal.get(con.Id);
                    //con.Fon_Membership_State__c=chapterState.get(con.Id);
                    //if(activationDate.get(con.Id)!=Null){
                    //    con.Fon_Membership_Activation_Date__c=activationDate.get(con.Id);
                    //}
                    
                    // con.Fon_Current_Membership_Status__c= stagingStatus.get(con.Id);
                    con.Fon_Foundation_Donation_Renewal__c = donationRenewal.get(con.Id);
                    con.Fon_AAFP_Subscription_Plan_Picklist__c = planMap.get(con.Id);
                    con.Fon_Frequency__c=null;
                    con.Fon_No_of_Remaining_installments__c=null;
                    con.Fon_Next_Payment_Month__c=null;
                    if(medicalSchoolGraduationDate.get(con.Id)!=Null){
                        con.AAFP_Medical_School_Graduation_Date__c= medicalSchoolGraduationDate.get(con.Id);
                    }
                }
                update contacts;
            }
        }
        
        Set<Id> invoiceSOId =  new Set<Id>();
        List<OrderApi__Sales_Order__c> updateSoList =  new List<OrderApi__Sales_Order__c>();
        
        List<OrderApi__Sales_Order__c> processPaymentSoList = new List<OrderApi__Sales_Order__c>();
        for(OrderApi__Sales_Order__c soObj:lstSalesOrder){
            if(soObj.Fon_Salesorder_Type__c == 'Dues'){
                invoiceSOId.add(soObj.Id);
            }
            if(!soObj.Fon_is_Dues_Paid_by_Chapter_Residency__c && soObj.OrderApi__Payment_Method__c !=Null){
                soObj.Fon_isPaymentProcess__c=true;
                processPaymentSoList.add(soObj);
            }
        }
        system.debug('jmd--processPaymentSoList'+ processPaymentSoList);
        
        List<OrderApi__Sales_Order__c> soList = [select id,OrderApi__Posting_Entity__c,
                                                 OrderApi__Posting_Status__c,
                                                 OrderApi__Is_Posted__c from OrderApi__Sales_Order__c 
                                                 WHERE Id In:invoiceSOId AND OrderApi__Total__c=0];
        if(soList.size()>0){
            for(OrderApi__Sales_Order__c objSO : soList){
                if(objSO.OrderApi__Posting_Entity__c== 'Invoice' && objSO.OrderApi__Is_Posted__c == false){
                    objSO.OrderApi__Posting_Status__c = 'Posted';
                    updateSoList.add(objSO);
                }
            }
        }
        update updateSoList;
        if(processPaymentSoList.size()>0 && soList.size()==0){
            update processPaymentSoList;
            Datetime sysTime = System.now();
            sysTime = sysTime.addSeconds(30);
            String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            Fon_SalesorderPaymentSchedulable scheduler = new Fon_SalesorderPaymentSchedulable(memberStageIdSet);
            String name = 'Callout Payment Batchable' + String.valueOf(DateTime.now());
            System.schedule(name,chron_exp,scheduler);
        }
    }
}