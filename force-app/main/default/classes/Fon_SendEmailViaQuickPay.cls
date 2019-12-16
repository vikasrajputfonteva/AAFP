public class Fon_SendEmailViaQuickPay{
    public list<OrderApi__Receipt_Line__c> receiptLineList {get;set;}
    public String totalAmount {get;set;}
    public String confirmationNumber {get;set;}
    public Set<String> receiptLineIds = new Set<String>();
    
    public Fon_SendEmailViaQuickPay(){  
        String ids = apexpages.currentpage().getparameters().get('id');
        String[] receiptIdList = ids.split(',');
        if (receiptIdList != null && receiptIdList.size() > 0) {
            for(String obj : receiptIdList){
                receiptLineIds.add(obj);
            }  
        }
        totalAmount = apexpages.currentpage().getparameters().get('amount');       
        confirmationNumber = apexpages.currentpage().getparameters().get('number');
        if(!receiptLineIds.isEmpty()){
            receiptLineList=[select OrderApi__Sales_Order_Line__r.OrderApi__Contact__r.Name,OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__r.Name,id,OrderApi__Receipt__r.OrderApi__Sales_Order__r.Name,OrderApi__Item__r.Name,OrderApi__Total__c,OrderApi__Contact__r.Name from OrderApi__Receipt_Line__c where ID In:receiptLineIds];
        }
    }
}