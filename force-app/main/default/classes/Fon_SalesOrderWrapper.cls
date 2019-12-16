public class Fon_SalesOrderWrapper{
    @AuraEnabled public String strBGColor = 'whitesmoke';
    @AuraEnabled public String strAccountTypeBGColor = 'whitesmoke';
    @AuraEnabled public Boolean isInvoice = false;
    @AuraEnabled public String strMSG;
    @AuraEnabled public String strSOID;
    @AuraEnabled public String strSOName;
    @AuraEnabled public Boolean hasBalanceDueInvoice = false;
    
    @AuraEnabled public Decimal invoicesTotalDueAmount = 0.00;
    @AuraEnabled public Decimal totalAmount = 0.00;
    @AuraEnabled public OrderApi__Sales_Order__c objSO;
    @AuraEnabled public String objAdjustmentInvoice;
    @AuraEnabled public String parentInvoiceLine;
    @AuraEnabled public List<OrderApi__Invoice__c> lstInvoice;
    @AuraEnabled public List<Fon_SalesOrderLineItemWrapper> lstSOLI = new List<Fon_SalesOrderLineItemWrapper>();
    
    public Fon_SalesOrderWrapper(OrderApi__Sales_Order__c objSO){
        //this.objSO = objSO;
        this.isInvoice = false;
        this.strSOID = objSO.Id;
        this.strSOName = objSO.Name;
    }
    public Fon_SalesOrderWrapper(){}
    
    public Fon_SalesOrderWrapper(OrderApi__Invoice__c objInvoice){
        this.isInvoice = true;
        this.strSOID = objInvoice.Id;
        this.strSOName = objInvoice.Name;
    }
}