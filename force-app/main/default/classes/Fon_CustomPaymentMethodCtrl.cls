public without sharing class Fon_CustomPaymentMethodCtrl{
    public static Boolean isSandboxOrg;
    
    @AuraEnabled
    public static String getContactInfo() {
        user u = [SELECT ContactId,Id FROM User where id = : userinfo.getuserid()];
        if(u !=null){
            return u.contactid;
        }
        return null; 
    }
    
    @AuraEnabled
    public static String getTokenInfo() {
        try {
            if(!Test.isRunningTest()){
                Organization currOrg = [Select IsSandbox from Organization limit 1];
                isSandboxOrg = currOrg.IsSandbox;
            }
            system.debug('jmd-->'+isSandboxOrg);
            if(isSandboxOrg){
                OrderApi__Payment_Gateway__c pg = [SELECT Id, OrderApi__Token__c FROM OrderApi__Payment_Gateway__c WHERE OrderApi__Is_Test__c = True limit 1];
                if(pg !=null){
                    return pg.OrderApi__Token__c ;
                }
            } else{
                OrderApi__Payment_Gateway__c pg = [SELECT Id, OrderApi__Token__c FROM OrderApi__Payment_Gateway__c WHERE OrderApi__Is_Test__c = False AND OrderApi__Is_Enabled__c = true limit 1];
                if(pg !=null){
                    return pg.OrderApi__Token__c ;
                }
            }
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage()+e.getStackTraceString());
        }
        return null; 
    }
    
    @AuraEnabled
    public static String getPaymentMethod() {
        user u = [SELECT ContactId,Id FROM User where id = : userinfo.getuserid()];
        if(u !=null){
            OrderApi__Payment_Method__c pm = [SELECT Id, Name FROM OrderApi__Payment_Method__c WHERE OrderApi__Contact__c =: u.contactid ORDER BY CreatedDate DESC LIMIT 1];
            if(pm !=null){
                return pm.Name;
            }
        }
        return null; 
    }
    
    @AuraEnabled
    public static Boolean checkValidPaymentMethod() {
        String contactId='';
        user u = [SELECT ContactId,Id FROM User where id = : userinfo.getuserid()];
        if(u !=null){
            contactId= u.contactid;
        }
        
        List<OrderApi__Payment_Method__c> validPaymentMethod = [select id from OrderApi__Payment_Method__c where OrderApi__Contact__c=:contactId And OrderApi__Is_Valid__c=true];
        if(validPaymentMethod.size()>0){
            return true;
        }
        else{
            return false;
        }
    }
}