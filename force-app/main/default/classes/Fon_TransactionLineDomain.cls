global class Fon_TransactionLineDomain extends Framework.Domain{
    public Fon_TransactionLineDomain(List<OrderApi__Transaction_Line__c> sObjectList) {
        super(sObjectList);
    }
    
    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new Fon_TransactionLineDomain(sObjectList);
        }
    }
    
    public override void beforeInsert(){
        Framework.Log.push(Fon_TransactionLineDomain.class.getName(),'beforeInsert'); 
        Fon_TransactionLineService.filterTransactionLine((OrderApi__Transaction_Line__c[]) records); 
        Framework.Log.pop();
    }
}