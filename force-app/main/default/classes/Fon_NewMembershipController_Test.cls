@isTest
public class Fon_NewMembershipController_Test {
    
    
    static testMethod void TestNewMembershipController() {
        Account acct = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert acct;
        
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        insert con;
        
        
        Fon_Membership_Staging__c ms = (Fon_Membership_Staging__c)Fon_TestDataFactory.createSObject('Fon_Membership_Staging__c', false);
        ms.Fon_Contact__c=con.Id;
        ms.Fon_Staging_Status__c = 'New';
        ms.Fon_Residency_Program_Graduation_Date__c=system.today();
        ms.Fon_Chapter_Id__c=acct.Id;
        ms.Fon_Is_Membership_Type_Changed__c=true;
        insert ms;
        
        test.startTest();
        try{
            Fon_NewMembershipController.getForm(con.id, 'Fon_Membership_Staging__c', 'Fon_membership_staging_fs',true);
            Boolean value=Fon_NewMembershipController.isChapterIdValid(ms.Fon_Chapter_Id__c);
            system.assertEquals(true, value);
        }
        catch (Exception e) {
            String exceptionMessage = e.getMessage();
        }
        
        test.stopTest();
        
    }
}