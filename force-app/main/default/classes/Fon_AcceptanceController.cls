public without sharing class Fon_AcceptanceController {
    @AuraEnabled
    public static String loadTermConditionData(){
        String textData;
        List<Fon_Term_and_Condition__mdt> trmList = new List<Fon_Term_and_Condition__mdt>();
        trmList=[SELECT Description_Html__c FROM Fon_Term_and_Condition__mdt where DeveloperName='Fon_TermCondition'];
        if(trmList.size()>0){
            textData=trmList[0].Description_Html__c;
        }
        return textData; 
    }
}