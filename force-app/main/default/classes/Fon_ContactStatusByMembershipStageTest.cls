@isTest
public class Fon_ContactStatusByMembershipStageTest {
    
    @isTest
    public static void method1(){
    
      Account acct = new Account();
        acct.Name = 'Test Account';
        insert acct;
        
        Contact con = new Contact();
        con.LastName = 'LASTNAME';
        con.AccountId = acct.Id;
        con.Email ='testemail@testemail.com';
        con.MailingPostalCode = '22209';
    
        con.Fon_Total_Months_of_Membership__c=10;
        con.Fon_Current_Membership_Status__c='Active';
        insert con;  
        
        
    Fon_Membership_Staging__c member=new Fon_Membership_Staging__c();
     member.Name='RSI MembershipTest';
     member.Fon_Staging_Status__c='Active';
     member.Fon_Membership_Type__c='Active';
     member.Fon_Residency_Program_Graduation_Date__c=system.today()+2;
    // member.Fon_Dues_Paid_by_Chapter__c=20;
    // member.Fon_Dues_Paid_by_Residency_Program__c=15;
     member.Fon_Contact__c=con.Id;
     member.Fon_Membership_Activation_Date__c=system.today();
     member.Fon_Extended_Training_Date__c=system.today();
     member.Fon_Join_Date__c=system.today();
     member.Fon_Chapter_Join_Date__c=system.today();
     insert member;
        
       Test.startTest();
       Fon_ContactStatusByMembershipStageBatch batchable=new Fon_ContactStatusByMembershipStageBatch();
       Database.executeBatch(batchable);
       Test.stopTest();          

    }
}