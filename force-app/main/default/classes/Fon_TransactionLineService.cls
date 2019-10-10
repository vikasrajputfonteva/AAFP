public class Fon_TransactionLineService{
    static String strPaymentType = 'Refund';
    public static void filterTransactionLine(LIst<OrderApi__Transaction_Line__c> lstTransactionLine){
        Set<Id> idSetOfTransaction = new Set<Id>();
        LIst<OrderApi__Transaction_Line__c> lstFilteredTransactionLine = new LIst<OrderApi__Transaction_Line__c>();
        for(OrderApi__Transaction_Line__c eachTLine : lstTransactionLine){
            if(String.isBlank(eachTLine.OrderApi__Item__c) && String.isBlank(eachTLine.OrderApi__Receipt_Line__c)){
                lstFilteredTransactionLine.add(eachTLine);
                idSetOfTransaction.add(eachTLine.OrderApi__Transaction__c);
            }
        }
        if(!lstFilteredTransactionLine.isEmpty()){
            Map<Id,String> mapTransactionLineToCreditMemoNo = fetchCreditMemoByTransactionLine(idSetOfTransaction);
            updatingCreditMemoNoOnTransLine(lstFilteredTransactionLine, mapTransactionLineToCreditMemoNo);
        }
    }

    public static void updatingCreditMemoNoOnTransLine(LIst<OrderApi__Transaction_Line__c> lstTransactionLine, Map<Id,String> mapTransactionLineToCreditMemoNo){
        for(OrderApi__Transaction_Line__c eachTransLine : lstTransactionLine){
            if(mapTransactionLineToCreditMemoNo.containsKey(eachTransLine.OrderApi__Transaction__c)){
                eachTransLine.Fon_Credit_Memo_Numbers__c = mapTransactionLineToCreditMemoNo.get(eachTransLine.OrderApi__Transaction__c);
            }
        }
    }
    
    public static Map<Id,String> fetchCreditMemoByTransactionLine(Set<Id> idSetOfTransaction){
        Map<Id,Id> mapTransactionIdToReceiptId = new Map<Id,Id>();
        Map<Id,String> mapReceiptIdToStrCreditMemoNo = new Map<Id,String>();
        Map<Id,String> mapTransactionLineToCreditMemoNo = new Map<Id,String>();
        List<OrderApi__Transaction__c> lstTransaction = [SELECT Id,OrderApi__Receipt__c,OrderApi__Receipt__r.OrderApi__Receipt__c FROM OrderApi__Transaction__c 
                                                            WHERE Id IN :idSetOfTransaction AND OrderApi__Receipt__r.OrderApi__Type__c =: strPaymentType];
        for(OrderApi__Transaction__c eachTransaction : lstTransaction){
            if(!String.isBlank(eachTransaction.OrderApi__Receipt__c) && !String.isBlank(eachTransaction.OrderApi__Receipt__r.OrderApi__Receipt__c)){
                mapTransactionIdToReceiptId.put(eachTransaction.Id, eachTransaction.OrderApi__Receipt__r.OrderApi__Receipt__c);
            }
        }
        if(!mapTransactionIdToReceiptId.keySet().isEmpty()){
            for(OrderApi__Receipt__c eachReceipt : [SELECT Id,(SELECT Id,Name FROM Credit_Memos__r) FROM OrderApi__Receipt__c WHERE Id IN :mapTransactionIdToReceiptId.values()]){
                if(eachReceipt.Credit_Memos__r != null && !eachReceipt.Credit_Memos__r.isEmpty()){
                    String strCreditMemo = '';
                    for(OrderApi__Credit_Memo__c eachCreditMemo : eachReceipt.Credit_Memos__r){
                        strCreditMemo = strCreditMemo + eachCreditMemo.Name + ',';
                    }
                    strCreditMemo = strCreditMemo.removeEnd(',');
                    mapReceiptIdToStrCreditMemoNo.put(eachReceipt.Id,strCreditMemo);
                }
            }
        }
        for(OrderApi__Transaction__c eachTransaction : lstTransaction){
            if(mapReceiptIdToStrCreditMemoNo.containsKey(eachTransaction.OrderApi__Receipt__r.OrderApi__Receipt__c)){
                String strMemo = mapReceiptIdToStrCreditMemoNo.get(eachTransaction.OrderApi__Receipt__r.OrderApi__Receipt__c);
                mapTransactionLineToCreditMemoNo.put(eachTransaction.Id, strMemo);
            }
        }
        return mapTransactionLineToCreditMemoNo;
    }
    
    
}