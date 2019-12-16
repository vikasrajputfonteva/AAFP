/*
    @Description: This class will update Reinstatement date on contact.
    @Author: Vikas Rajput
*/
public without sharing class Fon_RenewalTriggerHandler{
    
    //Updating Reinstated Date On Contact
    public void updateReinstatedDate(List<OrderApi__Renewal__c> lstRenewalOrder){
        Map<Id,OrderApi__Renewal__c> mapSoliIdToRenewalDate = new Map<Id,OrderApi__Renewal__c>();
        for(OrderApi__Renewal__c eachRenewal : lstRenewalOrder){
            if(eachRenewal.OrderApi__Renewed_Date__c != null){
                if(!mapSoliIdToRenewalDate.containsKey(eachRenewal.OrderApi__Sales_Order_Line__c)){
                    mapSoliIdToRenewalDate.put(eachRenewal.OrderApi__Sales_Order_Line__c, eachRenewal);
                }
            }
        }
        List<Contact> lstContact = new List<Contact>();
        Set<Id> idSetOfContact = new Set<Id>();
        List<OrderApi__Sales_Order_Line__c> lstRenewalSOLI = fetchSOLIRecord(mapSoliIdToRenewalDate.keySet());
        for(OrderApi__Sales_Order_Line__c eachSOLI : lstRenewalSOLI){
            if(!idSetOfContact.contains(eachSOLI.OrderApi__Contact__c) && mapSoliIdToRenewalDate.containsKey(eachSOLI.Id) ){
                Contact objContact = new Contact(Id = eachSOLI.OrderApi__Contact__c);
                objContact.Fon_Membership_Reinstatement_Date__c = mapSoliIdToRenewalDate.get(eachSOLI.Id).OrderApi__Renewed_Date__c;
                lstContact.add(objContact);
                idSetOfContact.add(eachSOLI.OrderApi__Contact__c);
            }
        }
        if(!lstContact.isEmpty()){
            update lstContact;
        }
    }
    
    //Fetch List Of SOLI
    public List<OrderApi__Sales_Order_Line__c> fetchSOLIRecord(Set<Id> idSetOfSOLI){
        List<OrderApi__Sales_Order_Line__c> lstSOLI = [SELECT Id,OrderApi__Is_Renewal__c,OrderApi__Subscription__c,OrderApi__Contact__c,OrderApi__Account__c FROM OrderApi__Sales_Order_Line__c WHERE Id IN : idSetOfSOLI AND OrderApi__Is_Renewal__c = true];
        return lstSOLI;
    }



}