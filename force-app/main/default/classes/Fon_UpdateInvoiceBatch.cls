global class Fon_UpdateInvoiceBatch implements Database.Batchable<sObject>{
    Set<String> salesOrderIds = new Set<String>();
    String newBatchRecordId;
    public Fon_UpdateInvoiceBatch(Set<String> soIds,String newBatchRecordId){
        //System.debug('==================soIds==================='+soIds);
        salesOrderIds.addAll(soIds);  
        this.newBatchRecordId=newBatchRecordId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query='select id,OrderApi__Contact__c,OrderApi__Status__c, OrderApi__Posting_Entity__c, OrderApi__Schedule_Type__c,(select id,OrderApi__Sales_Order__c from OrderApi__Sales_Order_Lines__r where OrderApi__Item__r.OrderApi__Is_Subscription__c=true AND OrderApi__Subscription_Plan__r.OrderApi__Enable_Schedule__c=false)';
        query +='from OrderApi__Sales_Order__c where Id IN :salesOrderIds AND OrderApi__Status__c=\'Closed\' AND OrderApi__Posting_Entity__c=\'Receipt\' AND OrderApi__Is_Posted__c=false AND Fon_Auto_Apply_Credit__c=true And OrderApi__Contact__c!=null';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC,List<OrderApi__Sales_Order__c> SOlist){
        //System.debug('==================SOlist==================='+SOlist);
        Set<Id> contactIds=new Set<Id>();
        Map<Id,Id> conVSso = new Map<Id,Id>();
        Set<Id> finalSalesOrderIds = new Set<Id>();
        List<OrderApi__Sales_Order__c> updateSalesOrderList = new List<OrderApi__Sales_Order__c>();
        List<OrderApi__Invoice__c> updateInvoiceList = new List<OrderApi__Invoice__c> ();
        if(SOlist.size()>0){
            for(OrderApi__Sales_Order__c so:SOlist){
                List<OrderApi__Sales_Order_Line__c> soliList=so.OrderApi__Sales_Order_Lines__r;
                if(soliList.size()>0){
                    contactIds.add(so.OrderApi__Contact__c);
                    conVSso.put(so.OrderApi__Contact__c,so.Id);
                }
            }
            if(!contactIds.isEmpty() && !conVSso.isEmpty()){//Credit Memo with fields ‘Suggested usage’ = Memberships & ‘Required’ = True 
                List<OrderApi__Credit_Memo__c> creditMemoList=[select id,OrderApi__Contact__c from OrderApi__Credit_Memo__c where OrderApi__Contact__c In:contactIds And Fon_Suggested_Usage__c=:Label.Fon_Memberships And Fon_Required__c=true];
                //System.debug('==================creditMemoList==================='+creditMemoList);
                if(creditMemoList.size()>0){   
                    for(OrderApi__Credit_Memo__c CM:creditMemoList){
                        finalSalesOrderIds.add(conVSso.get(CM.OrderApi__Contact__c));
                    }
                }
            }
            //System.debug('==================finalSalesOrderIds==================='+finalSalesOrderIds);
            for(OrderApi__Sales_Order__c so:SOlist){
                if(finalSalesOrderIds.Contains(so.Id)){
                    so.OrderApi__Status__c='Open';//Sales orders to ‘Open’ 
                    so.OrderApi__Posting_Entity__c='Invoice';//‘Posting Entity’ equals to Invoice 
                    so.OrderApi__Schedule_Type__c='Simple Invoice';//‘Schedule Type’ equals to ‘Simple Invoice’ 
                    updateSalesOrderList.add(so);
                }
            }
            if(updateSalesOrderList.size()>0){
                Update updateSalesOrderList;
                for(OrderApi__Sales_Order__c so : updateSalesOrderList){
                    so.OrderApi__Status__c='Closed';//Sales orders to ‘Closed’ 
                }
                update updateSalesOrderList;
                
                //Posting the sales order here
                 for(OrderApi__Sales_Order__c so : updateSalesOrderList){
                    so.OrderApi__Posting_Status__c = 'Posted'; //Sales orders to ‘Posted’ 
                }
                update updateSalesOrderList;
                
                Set<Id> processedSo = (new Map<Id,OrderApi__Sales_Order__c>(updateSalesOrderList)).keySet();
                List<OrderApi__Invoice__c> invoiceList=[select id,Fon_Auto_Apply_Credit__c from OrderApi__Invoice__c where OrderApi__Sales_Order__c IN : processedSo];
                if(invoiceList.size()>0){
                    for(OrderApi__Invoice__c invoice : invoiceList){
                        invoice.Fon_Auto_Apply_Credit__c=true;  
                        updateInvoiceList.add(invoice);
                    }
                    if(updateInvoiceList.size()>0){
                        update updateInvoiceList; 
                    }
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
        Database.executeBatch(new Fon_CreditMemoLineBatch(newBatchRecordId));
    }
}