public class Fon_TotalNumberOfMembershipBatch implements Database.Batchable<sObject> {
    String query;
    String whereQuery;  
    public Database.QueryLocator start(Database.BatchableContext BC){
        whereQuery = 'where OrderApi__Status__c=\'Active\' And OrderApi__Activated_Date__c!=Null And OrderApi__Item__r.OrderApi__Is_Active__c=true And OrderApi__Item__r.OrderApi__Item_Class__r.OrderApi__Is_Active__c=true And OrderApi__Contact__c!=Null';
        query= 'select id,OrderApi__Activated_Date__c,OrderApi__Contact__c,OrderApi__Item__r.Name,OrderApi__Item__r.OrderApi__Item_Class__r.Fon_Is_Main_Membership__c,(SELECT Id,OrderApi__Subscription__c,OrderApi__Term_Start_Date__c FROM OrderApi__Renewals__r LIMIT 1) from OrderApi__Subscription__c '+whereQuery;
        return Database.getQueryLocator(query); //removed this line from query:  OrderApi__Item__r.OrderApi__Item_Class__r.Fon_Is_Main_Membership__c=true And 
    }
    
    public void execute(Database.BatchableContext BC, List<OrderApi__Subscription__c> subscriptionList){
        /*
        if(subscriptionList.size()>0){
            Set<id> contactIds =  new Set<Id>();
            Integer currentMonth = System.today().Month();
            Map<Id,Integer> conVStotalNumberOfMembership = new  Map<Id,Integer>();
            for(OrderApi__Subscription__c subObj : subscriptionList){
                contactIds.add(subObj.OrderApi__Contact__c);
                Date activationDate =subObj.OrderApi__Activated_Date__c;
                Date batchRunDate = System.today();
                Integer monthDiff = activationDate.monthsBetween(batchRunDate);
                conVStotalNumberOfMembership.put(subObj.OrderApi__Contact__c,monthDiff);
            }
            if(!contactIds.isEmpty()){
                List<contact> conList = [select id,Fon_Total_Months_of_Membership__c from Contact where id in :contactIds];
                if(conList.size()>0 && !conVStotalNumberOfMembership.isEmpty()){
                    for(Contact conObj:conList){
                        conObj.Fon_Total_Months_of_Membership__c= conVStotalNumberOfMembership.get(conObj.Id);
                    }
                    update conList;
                }
            }
        }
        */
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> contactIdSetOfActive = new Set<Id>();
        for(OrderApi__Subscription__c objSub : subscriptionList){
            if(objSub.OrderApi__Renewals__r != null){
                for(OrderApi__Renewal__c objRenewal : objSub.OrderApi__Renewals__r){
                    //if(objSub.OrderApi__Item__r.Name == fetchStrNational(objRenewal)){
                    if(objSub.OrderApi__Item__r.Name.containsIgnoreCase(Label.Fon_Active_Year)){
                        contactIdSetOfActive.add(objSub.OrderApi__Contact__c);
                        fetchStrNational(objRenewal); //No use of this function any more
                    }else{
                        contactIdSet.add(objSub.OrderApi__Contact__c);
                    }
                }
            }
        }
        List<Contact> lstAllContact = new List<Contact>();
        //Map<Id,Contact> mapContactIdToObjContact = new Map<Id,Contact>([select id,Fon_Total_Months_of_Membership__c from Contact where id IN : contactIdSet]);
        List<Contact> lstContact = [select id,Fon_Total_Months_of_Membership__c,Fon_Total_Months_of_Active_Membership__c  from Contact where id IN : contactIdSet ];
        
        //Commented this line AND Fon_Total_Months_of_Membership__c != null AND Fon_Total_Months_of_Active_Membership__c != null
        for(Contact objContact : lstContact){
            if(objContact.Fon_Total_Months_of_Membership__c != null){
                objContact.Fon_Total_Months_of_Membership__c  = objContact.Fon_Total_Months_of_Membership__c + 1;
            }
        }
        update lstContact;
        List<Contact> lstContactActive = [select id,Fon_Total_Months_of_Membership__c,Fon_Total_Months_of_Active_Membership__c  from Contact where id IN : contactIdSetOfActive];
        for(Contact objContact : lstContactActive){
            if(objContact.Fon_Total_Months_of_Active_Membership__c != 0 && objContact.Fon_Total_Months_of_Active_Membership__c != null){
                objContact.Fon_Total_Months_of_Active_Membership__c = objContact.Fon_Total_Months_of_Active_Membership__c + 1;
            }
            if(objContact.Fon_Total_Months_of_Membership__c != null){
                objContact.Fon_Total_Months_of_Membership__c  = objContact.Fon_Total_Months_of_Membership__c + 1;
            }
        }
        update lstContactActive;
    }
    
    public void finish(Database.BatchableContext BC){
    }
    
    //Conversion of label value to main item on subscription
    public String fetchStrNational(OrderApi__Renewal__c objRenewal){
        if(objRenewal.OrderApi__Term_Start_Date__c != null){
            String strNationalYear = Label.Fon_Active_Year;
            return strNationalYear.replace('YEAR', ''+objRenewal.OrderApi__Term_Start_Date__c.year());
        }
        return '';
    }
    
    
}