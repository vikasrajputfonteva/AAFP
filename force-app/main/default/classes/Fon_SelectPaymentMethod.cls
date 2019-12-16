public class Fon_SelectPaymentMethod {
    
    @AuraEnabled
    public static List<Map<String, String>> validPaymentMethod(String contactId) {
       List<user> u = [SELECT ContactId,Id FROM User where id = : userinfo.getuserid()];
        if(u.size()>0){
            if(u[0].contactid!=null){
                 contactId= u[0].contactid;
            }
        }
        List<Map<String, String>> validPaymentMethods = new List<Map<String, String>>();
        List<OrderApi__Payment_Method__c> validPaymentMethod = [select id,Name,OrderApi__Card_Type__c,OrderApi__Exp_Date__c,OrderApi__Number__c from OrderApi__Payment_Method__c where OrderApi__Contact__c=:contactId And OrderApi__Is_Valid__c=true And OrderApi__Is_Active__c=true];
        if(validPaymentMethod.size()>0){
            for(OrderApi__Payment_Method__c pm:validPaymentMethod){
                String[] tempArray = pm.OrderApi__Number__c.split('-');
                Integer month = pm.OrderApi__Exp_Date__c.month();
                Integer year = pm.OrderApi__Exp_Date__c.year();	
                String temp= pm.OrderApi__Card_Type__c+' '+month+'/'+year+' '+tempArray[3];
                validPaymentMethods.add(new Map<String, String>{'value' => pm.Name, 'label' => temp});
            }
        }
        return validPaymentMethods;
    }
}