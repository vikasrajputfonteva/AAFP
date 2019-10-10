global class Fon_CreditMemoLineBatch implements Database.Batchable<sObject>{
    String newBatchRecordId;
    public Fon_CreditMemoLineBatch(String newBatchRecordId){
        this.newBatchRecordId=newBatchRecordId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        string query ='select id,OrderApi__Contact__c,OrderApi__Balance_Due__c,(select id from OrderApi__Invoice_Lines__r where OrderApi__Item__r.OrderApi__Is_Subscription__c=true And OrderApi__Subscription_Plan__r.OrderApi__Enable_Schedule__c=false) from OrderApi__Invoice__c where Fon_Auto_Apply_Credit__c=true And OrderApi__Balance_Due__c>0';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<OrderApi__Invoice__c> invoiceList){
        Set<Id> contactIds = new Set<Id>();
        Set<Id> invoiceIds = new Set<Id>();
        Map<Id,List<OrderApi__Credit_Memo__c>> conVScm = new Map<Id,List<OrderApi__Credit_Memo__c>>();
        List<OrderApi__Credit_Memo_Line__c> insertCreditMemoLine = new List<OrderApi__Credit_Memo_Line__c>();
        
        if(invoiceList.size()>0){
            for(OrderApi__Invoice__c inv:invoiceList){
                List<OrderApi__Invoice_Line__c> invLines=inv.OrderApi__Invoice_Lines__r;
                if(invLines.size()>0){
                    contactIds.add(inv.OrderApi__Contact__c);
                    invoiceIds.add(inv.Id);
                }
            }
            if(!contactIds.isEmpty()){
                List<Contact> conList=[select id,(select id,OrderApi__Remaining_Amount__c,OrderApi__Contact__c from OrderApi__Credit_Memos__r where OrderApi__Remaining_Amount__c>0 And Fon_Suggested_Usage__c=:Label.Fon_Memberships And Fon_Required__c=true Order By OrderApi__Remaining_Amount__c desc) from contact where id in:contactIds];
                if(conList.size()>0){
                    for(Contact con:conList){
                        List<OrderApi__Credit_Memo__c> tempList = con.OrderApi__Credit_Memos__r;  
                        if(tempList.size()>0){
                            conVScm.put(con.Id,tempList);
                        }  
                    }
                }
            }
            
            if(!conVScm.isEmpty() && !invoiceIds.isEmpty()){
                Set<Id> appliedCreditMemoIds = new Set<Id>();
                Set<Id> greaterCreditMemoIds = new Set<Id>();
                Map<Id,Decimal> idVSremain = new Map<Id,Decimal>();
                for(OrderApi__Invoice__c inv:invoiceList){
                    if(invoiceIds.contains(inv.id)){
                        if(conVScm.containsKey(inv.OrderApi__Contact__c)){
                            List<OrderApi__Credit_Memo__c> creditMemoList=conVScm.get(inv.OrderApi__Contact__c);  
                            if(creditMemoList.size()>0){
                                Decimal balanceDue = inv.OrderApi__Balance_Due__c;
                                for(OrderApi__Credit_Memo__c CM:creditMemoList){
                                    if(appliedCreditMemoIds.contains(CM.id) && !greaterCreditMemoIds.contains(CM.id)){
                                        continue;
                                    }
                                    else if(idVSremain.containsKey(CM.id)){
                                        if(idVSremain.get(CM.id)==balanceDue){
                                            greaterCreditMemoIds.remove(CM.id);
                                            insertCreditMemoLine.add(createCML(CM.Id,inv.Id,balanceDue));
                                            break;
                                        }
                                        if(idVSremain.get(CM.id)>balanceDue){
                                            Decimal temp = idVSremain.get(CM.id)-balanceDue;
                                            idVSremain.put(CM.Id,temp);
                                            insertCreditMemoLine.add(createCML(CM.Id,inv.Id,balanceDue));
                                            break;
                                        }
                                        else if(idVSremain.get(CM.id)<balanceDue){
                                            balanceDue =balanceDue-idVSremain.get(CM.id);
                                            greaterCreditMemoIds.remove(CM.id);
                                            insertCreditMemoLine.add(createCML(CM.Id,inv.Id,idVSremain.get(CM.id)));
                                            continue;
                                        }
                                    }
                                    if(CM.OrderApi__Remaining_Amount__c==balanceDue){
                                        appliedCreditMemoIds.add(CM.Id);   
                                        insertCreditMemoLine.add(createCML(CM.Id,inv.Id,balanceDue));
                                        break;
                                    }
                                    else if(CM.OrderApi__Remaining_Amount__c>balanceDue){  
                                        appliedCreditMemoIds.add(CM.Id);
                                        greaterCreditMemoIds.add(CM.Id);
                                        idVSremain.put(CM.Id,CM.OrderApi__Remaining_Amount__c-balanceDue);
                                        insertCreditMemoLine.add(createCML(CM.Id,inv.Id,balanceDue));
                                        break;
                                    }
                                    else if(CM.OrderApi__Remaining_Amount__c<balanceDue){
                                        appliedCreditMemoIds.add(CM.Id);  
                                        balanceDue = balanceDue-CM.OrderApi__Remaining_Amount__c;
                                        insertCreditMemoLine.add(createCML(CM.Id,inv.Id,CM.OrderApi__Remaining_Amount__c));
                                        continue;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        if(insertCreditMemoLine.size()>0){
            insert insertCreditMemoLine;
            Set<Id> cmForTransaction = new Set<Id>();
            for(OrderApi__Credit_Memo_Line__c cml:insertCreditMemoLine){
                cml.OrderApi__Status__c='Posted';
                cmForTransaction.add(cml.OrderApi__Credit_Memo__c);
            }
            update insertCreditMemoLine;
            /*if(!cmForTransaction.isEmpty()){
List<OrderApi__Transaction__c> trans=[select id,OrderApi__Batch__c from OrderApi__Transaction__c where OrderApi__Credit_Memo__c In:cmForTransaction And OrderApi__Batch__c!=Null];
if(trans.size()>0){
for(OrderApi__Transaction__c obj:trans){
obj.OrderApi__Batch__c=newBatchRecordId;
}
update trans;
}
}*/
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }
    public OrderApi__Credit_Memo_Line__c createCML(Id creditMemoId,Id invoiceId,Decimal amount){
        OrderApi__Credit_Memo_Line__c CML = new OrderApi__Credit_Memo_Line__c();
        CML.OrderApi__Credit_Memo__c=creditMemoId;
        CML.OrderApi__Invoice__c=invoiceId;
        CML.OrderApi__Amount__c=amount;
        CML.Fon_Batch__c =newBatchRecordId;
        return CML;
    }
    
}