public without sharing class Fon_TransactionService {
    public static void updateCreditMemoOnTransaction(LIst<OrderApi__Transaction__c> newList){
       
        if(newList.size()>0){
            //For TC-012647
            Set<Id> creditMemoIds= new Set<Id>();
            //For TC-012647
            
            Set<Id> receiptIds= new Set<Id>();
            Map<Id,Id> receiptVScreditMemo = new Map<Id,Id>();
            for(OrderApi__Transaction__c trsns:newList){
                if(trsns.OrderApi__Receipt__c!=Null){
                    receiptIds.add(trsns.OrderApi__Receipt__c);
                }
                //For TC-012647
                if(trsns.OrderApi__Credit_Memo__c!=null){
                    creditMemoIds.add(trsns.OrderApi__Credit_Memo__c);
                }
                //For TC-012647
            }
            if(!receiptIds.isEmpty()){
                List<OrderApi__Receipt__c> receiptList=[select Fon_Credit_Memo__c from OrderApi__Receipt__c where Fon_Credit_Memo__c!=Null];
                if(receiptList.size()>0){
                    for(OrderApi__Receipt__c receipt:receiptList){
                        receiptVScreditMemo.put(receipt.Id,receipt.Fon_Credit_Memo__c);
                    }
                }
            }
            if(!receiptVScreditMemo.isEmpty()){
                for(OrderApi__Transaction__c trsns:newList){
                    if(trsns.OrderApi__Receipt__c!=Null){
                        trsns.OrderApi__Credit_Memo__c=receiptVScreditMemo.get(trsns.OrderApi__Receipt__c);
                    }
                } 
            }
            
            //For TC-012647
            List<OrderApi__Credit_Memo_Line__c> cmlList = new List<OrderApi__Credit_Memo_Line__c>();
            if(!creditMemoIds.isEmpty()){
                List<OrderApi__Credit_Memo__c> cmlist = [select id,(select OrderApi__Credit_Memo__c,Fon_Batch__c,OrderApi__Invoice__c from OrderApi__Credit_Memo_Lines__r where Fon_Batch__c!=null And OrderApi__Status__c='Posted') from OrderApi__Credit_Memo__c where id in:creditMemoIds];
                if(cmlist.size()>0){
                    for(OrderApi__Credit_Memo__c cm:cmlist){
                        List<OrderApi__Credit_Memo_Line__c> templList=cm.OrderApi__Credit_Memo_Lines__r;
                        if(templList.size()>0){
                            cmlList.addAll(templList);
                        }
                    }
                    if(cmlList.size()>0){
                        for(OrderApi__Transaction__c trsns:newList){
                            for(OrderApi__Credit_Memo_Line__c obj:cmlList){
                                if(trsns.OrderApi__Credit_Memo__c==obj.OrderApi__Credit_Memo__c && trsns.OrderApi__Invoice__c==obj.OrderApi__Invoice__c){
                                    
                                    trsns.OrderApi__Batch__c=obj.Fon_Batch__c;
                                }
                            }
                        }
                    }
                }
            }
            //For TC-012647
        }
     
    }
}