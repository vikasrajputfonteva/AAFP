@isTest
public class Fon_AcceptanceControllerTest {
    @isTest
    public static void method1(){
        Fon_Term_and_Condition__mdt tc= [SELECT Description_Html__c FROM Fon_Term_and_Condition__mdt where DeveloperName='Fon_TermCondition'];
        test.startTest();
        Fon_AcceptanceController.loadTermConditionData();
        test.stopTest();
    }
}