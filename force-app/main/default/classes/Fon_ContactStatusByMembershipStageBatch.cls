/**
    @Author: RSystem
    @Description: Processing the "Membership Staging" record and updating the "New Physician"/"Graduating Resident" status on contact level
*/
global class Fon_ContactStatusByMembershipStageBatch implements Database.Batchable<sObject>, Database.Stateful{
    List<String> lstMembershipType = new List<String>{'Active','Inactive'};
    String strActive = 'Active';
    Date oldDateBySevenYear = Date.today().addYears(-7);
    Date oldDateByThreeYear = Date.today().addYears(-3);
    //Building the base query for the batch
    global Database.QueryLocator start(Database.BatchableContext BC) {
         return Database.getQueryLocator('SELECT Id,Fon_Membership_Type__c,Fon_Staging_Status__c,Fon_Contact__c,Fon_Contact__r.Id,Fon_Residency_Program_Graduation_Date__c,Fon_Extended_Training_Date__c,'+
                                            'Fon_Dues_Waived__c FROM Fon_Membership_Staging__c WHERE Fon_Staging_Status__c =:strActive AND Fon_Residency_Program_Graduation_Date__c !=null AND Fon_Contact__c !=null');
    }
    //Executing business logic here
    global void execute(Database.BatchableContext BC, List<Fon_Membership_Staging__c> lstMemberStage) {
        List<Contact> lstContact = new List<Contact>();
        for(Fon_Membership_Staging__c eachMemberStage : lstMemberStage){
            Contact objContact = new Contact(Id=eachMemberStage.Fon_Contact__c);
            if(lstMembershipType.contains(eachMemberStage.Fon_Membership_Type__c) && ((eachMemberStage.Fon_Residency_Program_Graduation_Date__c > oldDateBySevenYear && 
                eachMemberStage.Fon_Residency_Program_Graduation_Date__c < Date.today()) || (eachMemberStage.Fon_Extended_Training_Date__c > oldDateBySevenYear && 
                    eachMemberStage.Fon_Extended_Training_Date__c < Date.today())) && eachMemberStage.Fon_Extended_Training_Date__c > eachMemberStage.Fon_Residency_Program_Graduation_Date__c.addYears(-3) &&
                        eachMemberStage.Fon_Extended_Training_Date__c < eachMemberStage.Fon_Residency_Program_Graduation_Date__c){
                objContact.Fon_New_Physician__c = true;
                lstContact.add(objContact);
            }
            if(eachMemberStage.Fon_Membership_Type__c == strActive && eachMemberStage.Fon_Staging_Status__c == strActive && eachMemberStage.Fon_Residency_Program_Graduation_Date__c > Date.today()){
                objContact.Fon_Graduating_Resident__c = true;
                lstContact.add(objContact);
            }
        }
        if(!lstContact.isEmpty()){
            update lstContact;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
    }
}