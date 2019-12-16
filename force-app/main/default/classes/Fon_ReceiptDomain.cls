/**
 *
 * Domain class for the OrderApi__Receipt__c SObjectType
 *
 **/
global class Fon_ReceiptDomain extends Framework.Domain{
    public Fon_ReceiptDomain(List<OrderApi__Receipt__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new Fon_ReceiptDomain(sObjectList);
        }
    }

    public override void beforeInsert(){
        Framework.Log.push(Fon_ReceiptDomain.class.getName(),'beforeInsert'); 
        Fon_ReceiptService.updateDepositeAccountBI((OrderApi__Receipt__c[]) records); 
        Framework.Log.pop();
    }
}