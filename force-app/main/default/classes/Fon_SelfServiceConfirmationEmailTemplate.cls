public class Fon_SelfServiceConfirmationEmailTemplate {
    public list<OrderApi__Receipt_Line__c> receiptLineList {get;set;}
    public Decimal totalAmount {get;set;}
    public String confirmationNumber {get;set;}
    public Set<String> receiptLineIds = new Set<String>();
    
    public Fon_SelfServiceConfirmationEmailTemplate(){  
        receiptLineList = new list<OrderApi__Receipt_Line__c>();
        totalAmount = Decimal.valueOf(apexpages.currentpage().getparameters().get('totalAmount'));       
        confirmationNumber = apexpages.currentpage().getparameters().get('confirmationNumber');
        String ids = apexpages.currentpage().getparameters().get('id');
        system.debug('jmd ids--'+ids);
        String[] receiptIdList = ids.split(',');
        if (receiptIdList != null && receiptIdList.size() > 0) {
            for(String obj : receiptIdList){
                receiptLineIds.add(obj);
            }  
        }
        system.debug('jmd receiptLineIds--'+receiptLineIds);
        if(!receiptLineIds.isEmpty()){
            receiptLineList=[select OrderApi__Sales_Order_Line__r.OrderApi__Contact__r.Name,OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__r.Name,id,OrderApi__Receipt__r.OrderApi__Sales_Order__r.Name,OrderApi__Item__r.Name,OrderApi__Total__c,OrderApi__Contact__r.Name from OrderApi__Receipt_Line__c where ID In:receiptLineIds];
        }
    }
}