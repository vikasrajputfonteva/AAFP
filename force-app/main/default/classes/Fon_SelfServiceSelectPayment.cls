public class Fon_SelfServiceSelectPayment {
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
                return pm.Id;
            }
        }
        return null; 
    }
    @AuraEnabled
    public static List<PaymentMethodWrapper> isvalidPaymentMethodAvailable(Id contactId) {
        List<PaymentMethodWrapper> lstPaymentMethodWrap = new List<PaymentMethodWrapper>();
        List<OrderApi__Payment_Method__c> lstPaymentMethod = [select id,
                                                              Name,OrderApi__Card_Type__c,
                                                              OrderApi__Exp_Date__c,OrderApi__Number__c
                                                              from OrderApi__Payment_Method__c 
                                                              where OrderApi__Contact__c=:contactId 
                                                              And OrderApi__Is_Valid__c=true 
                                                              And OrderApi__Is_Active__c=true];
        for(OrderApi__Payment_Method__c eachPaymentMethod : lstPaymentMethod){
            lstPaymentMethodWrap.add(new PaymentMethodWrapper(eachPaymentMethod));
        }
        return lstPaymentMethodWrap;
    }
    
    public class PaymentMethodWrapper{
        @AuraEnabled public String strLabel{get;set;}
        @AuraEnabled public String strValue{get;set;}
        
        public PaymentMethodWrapper(OrderApi__Payment_Method__c objPayMethod){
            String[] tempArray = objPayMethod.OrderApi__Number__c.split('-');
            Integer month = objPayMethod.OrderApi__Exp_Date__c.month();
            Integer year = objPayMethod.OrderApi__Exp_Date__c.year(); 
            this.strValue = objPayMethod.Id;
            this.strLabel = objPayMethod.OrderApi__Card_Type__c+' '+month+'/'+year+' '+tempArray[3];
        }
    }
}