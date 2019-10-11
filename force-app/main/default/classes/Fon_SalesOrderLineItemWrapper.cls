public class Fon_SalesOrderLineItemWrapper{
    @AuraEnabled public Boolean isSelected;
    @AuraEnabled public String strItemName;
    @AuraEnabled public String strEmployeeName;
    @AuraEnabled public String strOccupation;
    @AuraEnabled public String strAccountType = System.Label.Fon_Corporate;
    @AuraEnabled public Decimal salesPriceAmount;
    @AuraEnabled public Decimal donationPACAmount;
    @AuraEnabled public Boolean isPACItem = false;
    @AuraEnabled public Boolean isFoundationDonation = false;
    @AuraEnabled public OrderApi__Sales_Order_Line__c objSOLI;
    @AuraEnabled public OrderApi__Invoice_Line__c objInvoiceLine;
    @AuraEnabled public Boolean hasDonation = false;
    @AuraEnabled public Boolean hasPACDonation = false;
    
    public Fon_SalesOrderLineItemWrapper(OrderApi__Sales_Order_Line__c objSOLI){
        this.objSOLI = objSOLI;
        this.strItemName = objSOLI.OrderApi__Item__r.Name;
        if(objSOLI.OrderApi__Item__r.Fon_Is_PAC_Item__c){
            this.salesPriceAmount = objSOLI.OrderApi__Total__c;
            this.isPACItem = objSOLI.OrderApi__Item__r.Fon_Is_PAC_Item__c;
            this.donationPACAmount = objSOLI.OrderApi__Total__c;
        }
        else if(objSOLI.OrderApi__Item__r.Is_Foundation_Donation__c){
            this.salesPriceAmount = objSOLI.OrderApi__Total__c;
            this.isFoundationDonation = objSOLI.OrderApi__Item__r.Is_Foundation_Donation__c;
        }
        else{
            this.salesPriceAmount = objSOLI.OrderApi__Total__c;
        }
    }
    
    public Fon_SalesOrderLineItemWrapper(OrderApi__Sales_Order_Line__c objSOLI, OrderApi__Item__c objItem,Id defaultPriceRuleIdOfPACItem,Id defaultPriceRuleIdOfFoundationItem){
        this.objSOLI = objSOLI;
        this.objSOLI.OrderApi__Item__c = objItem.Id;
        this.objSOLI.OrderApi__Item_Class__c= objItem.OrderApi__Item_Class__c;//Setting Item Class of item
        this.strItemName = objItem.Name;
        if(objItem.Fon_Is_PAC_Item__c){
            this.salesPriceAmount = 0.00;
            this.isPACItem = objItem.Fon_Is_PAC_Item__c;
            this.donationPACAmount = 0.00; //objSOLI.OrderApi__Total__c;
            this.objSOLI.OrderApi__Price_Rule__c=defaultPriceRuleIdOfPACItem; //Setting default price rule of item
        }else if(objItem.Is_Foundation_Donation__c){
            this.salesPriceAmount = 0.00;
            this.isFoundationDonation = objItem.Is_Foundation_Donation__c;
            this.objSOLI.OrderApi__Price_Rule__c=defaultPriceRuleIdOfFoundationItem; //Setting default price rule of item
        }else{
            this.salesPriceAmount = objSOLI.OrderApi__Total__c;
        }
        
    }
    
    public Fon_SalesOrderLineItemWrapper(){}
    
    //@Constructor for Invoice Line
    public Fon_SalesOrderLineItemWrapper(OrderApi__Invoice_Line__c objInvoiceLine){
        //this.objSOLI = objSOLI;
        this.objInvoiceLine = objInvoiceLine;
        this.strItemName = objInvoiceLine.OrderApi__Item__r.Name;
        if(objInvoiceLine.OrderApi__Item__r.Fon_Is_PAC_Item__c){
            this.salesPriceAmount = 100.00;
            this.isPACItem = objInvoiceLine.OrderApi__Item__r.Fon_Is_PAC_Item__c;
        }else if(objInvoiceLine.OrderApi__Item__r.Is_Foundation_Donation__c){
            this.salesPriceAmount = 0.00;
            this.isFoundationDonation = objInvoiceLine.OrderApi__Item__r.Is_Foundation_Donation__c;
        }else{
            this.salesPriceAmount = objInvoiceLine.OrderApi__Balance_Due__c; //objInvoiceLine.OrderApi__Total__c;
        }
    }
    
    public Fon_SalesOrderLineItemWrapper(OrderApi__Invoice_Line__c objInvoiceLineARG, OrderApi__Item__c objItem){
        this.objInvoiceLine = objInvoiceLineARG;
        this.objInvoiceLine.OrderApi__Item__c = objItem.Id;
        this.strItemName = objItem.Name;
        if(objItem.Fon_Is_PAC_Item__c){
            this.salesPriceAmount = 100.00;
            this.isPACItem = objItem.Fon_Is_PAC_Item__c;
        }else if(objItem.Is_Foundation_Donation__c){
            this.salesPriceAmount = 0.00;
            this.isFoundationDonation = objItem.Is_Foundation_Donation__c;
        }else{
           // this.salesPriceAmount = objInvoiceLineARG.OrderApi__Total__c;
           this.salesPriceAmount = objInvoiceLineARG.OrderApi__Balance_Due__c;
        }
        
    }
}