/**
* Domain class for the Fon_TransactionService SObjectType
**/
global class Fon_TransactionServiceDomain extends Framework.Domain{
    public Fon_TransactionServiceDomain(List<OrderApi__Transaction__c> sObjectList) {
        super(sObjectList);
    }
    
    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new Fon_TransactionServiceDomain(sObjectList);
        }
    }
    
    public override void beforeInsert(){
        Framework.Log.push(Fon_TransactionServiceDomain.class.getName(),'beforeInsert'); 
        Fon_TransactionService.updateCreditMemoOnTransaction((OrderApi__Transaction__c[]) records); 
        Framework.Log.pop();
    }
}