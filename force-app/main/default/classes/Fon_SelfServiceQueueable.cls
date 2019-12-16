public class Fon_SelfServiceQueueable implements Queueable {
    public String salesorderId;
    
    public Fon_SelfServiceQueueable(String salesorderId){
        this.salesorderId = salesorderId;
    }
    
    public void execute(QueueableContext context) {
        OrderApi__Sales_Order__c[] soList = [select id,
                                             OrderApi__Is_Posted__c,
                                             OrderApi__Status__c
                                             from OrderApi__Sales_Order__c
                                             where Id =:salesorderId
                                            ];
        if(soList.size()>0){
            soList[0].OrderApi__Status__c='Closed';
            update soList;
            soList[0].OrderApi__Is_Posted__c=true;
            update soList;
        }
    }
}