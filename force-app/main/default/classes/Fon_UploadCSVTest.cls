@isTest
public class Fon_UploadCSVTest {
    @isTest
    public static void method1(){
        String strCSVFile ='Test';
        String strCancelled = 'Cancelled';  
        String strExpired = 'Expired';
        Account ac = (Account)Fon_TestDataFactory.createSObject('Account', false); 
        insert ac;
        Contact con = (Contact)Fon_TestDataFactory.createSObject('Contact', false); 
        insert con;
        
        List<Fon_Membership_Staging__c> lstMembership = new List<Fon_Membership_Staging__c>();
        Fon_Membership_Staging__c ms = (Fon_Membership_Staging__c)Fon_TestDataFactory.createSObject('Fon_Membership_Staging__c', false); 
        ms.Fon_Contact__c=con.Id;
        ms.Fon_Residency_Program_Graduation_Date__c=system.today();
        ms.Fon_Expiration_Date__c=system.today();
        ms.Fon_Error_Reason__c='Error';
        ms.Fon_Cancelled_Reason__c='Test';
        ms.Fon_Staging_Status__c = 'Cancelled';
        ms.Fon_Chapter_Join_Date__c=system.today();
        ms.Fon_Foundation_Contribution_Information__c = 10;
        lstMembership.add(ms);
        
        Fon_Membership_Staging__c ms1 = (Fon_Membership_Staging__c)Fon_TestDataFactory.createSObject('Fon_Membership_Staging__c', false); 
        ms1.Fon_Contact__c=con.Id;
        ms1.Fon_Residency_Program_Graduation_Date__c=system.today();
        ms1.Fon_Expiration_Date__c=system.today();
        ms1.Fon_Error_Reason__c='Error';
        ms1.Fon_Cancelled_Reason__c='Test';
        ms1.Fon_Staging_Status__c = 'Cancelled';
        ms1.Fon_Chapter_Join_Date__c=system.today();
        ms1.Fon_Foundation_Contribution_Information__c = 10;
        lstMembership.add(ms1);
        
        Fon_Membership_Staging__c ms2 = (Fon_Membership_Staging__c)Fon_TestDataFactory.createSObject('Fon_Membership_Staging__c', false); 
        ms2.Fon_Contact__c=con.Id;
        ms2.Fon_Residency_Program_Graduation_Date__c=system.today();
        ms2.Fon_Expiration_Date__c=system.today();
        ms2.Fon_Error_Reason__c='Error';
        ms2.Fon_Cancelled_Reason__c='Test';
        ms2.Fon_Staging_Status__c = 'Cancelled';
        ms2.Fon_Chapter_Join_Date__c=system.today();
        ms2.Fon_Foundation_Contribution_Information__c = 10;
        lstMembership.add(ms2);
        insert lstMembership;
        
       
        String csv = 'FON_CANCELLED_REASON__C,FON_CONTACT__C,FON_STAGING_STATUS__C,ID,Fon_Is_Financial__c\r\nLocal Relocate 9999,'+ms.Fon_Contact__c+',Cancelled,'+ms.id+',TRUE'+
                        '\r\nLocal Relocate 9999,'+ms1.Fon_Contact__c+',Expired,'+ms1.id+',False';
        Test.startTest();
        Fon_UploadCSV.csvFileUpdloader(csv);
        Fon_UploadCSV.fetchBooleanData('true');
        /// Fon_UploadCSV.fetchCSVHeaderMap(null);
      //  Fon_UploadCSV.fetchDateData('29-09-09');
        Fon_UploadCSV.fetchMemberStageRec(ms.id, 'Cancelled');
        Fon_UploadCSV.fetchNumericData('01');
        Date objDate = Date.newInstance(System.today().year(), System.today().month(), System.today().day()); //System.now().date();
        String todayDate = objDate.format();
        String csvUpgrade = 'FON_CANCELLED_REASON__C,FON_CONTACT__C,FON_DUES_PAID_BY_CHAPTER__C,FON_DUES_PAID_BY_RESIDENCY_PROGRAM__C,FON_JOIN_DATE__C,Fon_Chapter_Join_Date__c,FON_MEDICAL_SCHOOL_GRADUATION_DATE__C,FON_MEMBERSHIP_ACTIVATION_DATE__C,FON_MEMBERSHIP_LOCAL__C,FON_MEMBERSHIP_STATE__C,FON_MEMBERSHIP_TYPE__C,FON_RESIDENCY_PROGRAM_GRADUATION_DATE__C,FON_STAGING_STATUS__C,FON_YEAR__C,ID,NAME'+
                           '\r\nLocal Relocate 9999,'+ms1.Fon_Contact__c+',1,2,'+todayDate+','+todayDate+','+todayDate+','+todayDate+',,,Resident,'+todayDate+',Upgrade,,'+ms2.id+','+ms2.id+'';
        Fon_UploadCSV.csvFileUpdloader(csvUpgrade);
        Test.stopTest();
    }
}