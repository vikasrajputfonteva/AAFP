/*
    @Description: This class will calculate total month of membership against all subscription under the contact.
    @Author: Vikas Rajput
*/
public without sharing class Fon_SubscriptionTriggerHandler{
    
    public void calcTotalMonthOfMembership(List<OrderApi__Renewal__c> lstRenewalOrder){
        Map<Id,Integer> mapContactIdToTotalMonth = new Map<Id,Integer>();
        Map<Id,Integer> mapContactIdToTotalActiveMonth = new Map<Id,Integer>();
        Set<Id> idSetSubscription = new  Set<Id>();
        Set<Id> setOfIdContact = new Set<Id>();
        for(OrderApi__Renewal__c  eachRenew : (List<OrderApi__Renewal__c >)Trigger.new ){
            idSetSubscription.add(eachRenew.OrderApi__Subscription__c);
        }
        for(OrderApi__Subscription__c eachSubs : [SELECT Id,OrderApi__Status__c,OrderApi__Is_Active__c,OrderApi__Contact__c FROM OrderApi__Subscription__c WHERE Id IN : idSetSubscription ]){
            setOfIdContact.add(eachSubs.OrderApi__Contact__c);
        }
        //System.debug('===============idSetSubscription==========='+idSetSubscription);
        List<OrderApi__Subscription__c> lstOfSubscription = [SELECT Id,OrderApi__Status__c,OrderApi__Is_Active__c,OrderApi__Term_Start_Date__c,OrderApi__Term_End_Date__c,OrderApi__Cancelled_Date__c,
                                                                OrderApi__Item__r.Id,OrderApi__Item__r.Name,OrderApi__Item_Class__r.Id,OrderApi__Expired_Date__c,OrderApi__Contact__c,Fon_Year__c,
                                                                (SELECT Id,OrderApi__Subscription__c,OrderApi__Term_Start_Date__c,OrderApi__Term_End_Date__c,OrderApi__Sales_Order_Line__c,
                                                                OrderApi__Renewed_Date__c,OrderApi__Subscription__r.Fon_Year__c,OrderApi__Subscription__r.OrderApi__Contact__c FROM OrderApi__Renewals__r) 
                                                                FROM OrderApi__Subscription__c WHERE OrderApi__Contact__c IN : setOfIdContact];
        setOfIdContact.clear();
        //System.debug('=============lstOfSubscription============='+lstOfSubscription);
        for(OrderApi__Subscription__c objSubscription : lstOfSubscription){
            for(OrderApi__Renewal__c objRenewal : objSubscription.OrderApi__Renewals__r){
                //System.debug('=============OrderApi__Term_Start_Date__c============='+objRenewal.OrderApi__Term_Start_Date__c);
                setOfIdContact.add(objSubscription.OrderApi__Contact__c);
                //if(objSubscription.OrderApi__Item__r.Name == fetchStrNational(objRenewal)){
                if(objSubscription.OrderApi__Item__r.Name.containsIgnoreCase(Label.Fon_Active_Year)){
                    addTotalTermDurationOnMap(mapContactIdToTotalMonth, objRenewal);
                    addTotalTermDurationOnMap(mapContactIdToTotalActiveMonth, objRenewal);
                    fetchStrNational(objRenewal); //No more use of function, Need to remvoe it latter
                }else{
                    addTotalTermDurationOnMap(mapContactIdToTotalMonth, objRenewal);
                }
            }
        } 
        
        //System.debug('=============setOfIdContact============='+setOfIdContact);
        //System.debug('=============mapContactIdToTotalMonth============='+mapContactIdToTotalMonth);
        //System.debug('=============mapContactIdToTotalMonth============='+mapContactIdToTotalMonth);
        
        List<Contact> lstContact = [SELECT Id,Fon_Total_Months_of_Membership__c,Fon_Total_Months_of_Active_Membership__c FROM Contact WHERE Id IN : setOfIdContact];
        for(Contact eachContact : lstContact){
            if(mapContactIdToTotalMonth.containsKey(eachContact.Id)){
                eachContact.Fon_Total_Months_of_Membership__c = mapContactIdToTotalMonth.get(eachContact.Id);
            }
            if(mapContactIdToTotalActiveMonth.containsKey(eachContact.Id)){
                eachContact.Fon_Total_Months_of_Active_Membership__c = mapContactIdToTotalActiveMonth.get(eachContact.Id);
            }
        }
        if(!lstContact.isEmpty()){
            update lstContact;
        }
        
    }
    //Conversion of label value to main item on subscription
    public String fetchStrNational(OrderApi__Renewal__c objRenewal){
        if(objRenewal.OrderApi__Term_Start_Date__c != null){
            String strNationalYear = Label.Fon_Active_Year;
            //return strNationalYear.replace('YEAR', ''+objRenewal.OrderApi__Term_Start_Date__c.year());
        }
        return '';
    }
    
    //Adding total term duration month value in logical MAP
    public void addTotalTermDurationOnMap(Map<Id,Integer> mapCommonContIdToTotalMonth, OrderApi__Renewal__c objRenewal ){
        if(mapCommonContIdToTotalMonth.containsKey(objRenewal.OrderApi__Subscription__r.OrderApi__Contact__c)){
            Integer totalMonth = mapCommonContIdToTotalMonth.get(objRenewal.OrderApi__Subscription__r.OrderApi__Contact__c);
            totalMonth = totalMonth + fetchMonthDuration(objRenewal);
            mapCommonContIdToTotalMonth.put(objRenewal.OrderApi__Subscription__r.OrderApi__Contact__c, totalMonth);
        }else{
            mapCommonContIdToTotalMonth.put(objRenewal.OrderApi__Subscription__r.OrderApi__Contact__c, fetchMonthDuration(objRenewal));
        }
    }
    //Calculating total duration against subscription
    public Integer fetchMonthDuration(OrderApi__Renewal__c objRenewal){
        Integer totalDurationMonth = 0;
        if(objRenewal.OrderApi__Term_Start_Date__c < System.today().addDays(1) && objRenewal.OrderApi__Term_End_Date__c < System.today().addDays(1)){
            Date termStartDate = Date.valueOf(objRenewal.OrderApi__Term_Start_Date__c);
            Date termEndDate = Date.valueOf(objRenewal.OrderApi__Term_End_Date__c);
            totalDurationMonth = termStartDate.monthsBetween(termEndDate)+1;
        }else if(objRenewal.OrderApi__Term_Start_Date__c < System.today().addDays(1)){
            Date termStartDate = Date.valueOf(objRenewal.OrderApi__Term_Start_Date__c);
            Date termEndDate = System.today().addDays(1);
            totalDurationMonth = termStartDate.monthsBetween(termEndDate)+1;
        }
        return totalDurationMonth;
    }

}