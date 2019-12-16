global class Fon_SalesOrderTrigger extends Framework.Domain{

    public Fon_SalesOrderTrigger(List<OrderApi__Sales_Order__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new Fon_SalesOrderTrigger(sObjectList);
        }
    }

    public override void beforeInsert(){
        Framework.Log.push(Fon_SalesOrderTrigger.class.getName(),'beforeInsert');
        
        Framework.Log.pop();
    }

  
    public override void beforeUpdate(Map<Id,SObject> oldMap){
        Framework.Log.push(Fon_SalesOrderTrigger.class.getName(),'beforeUpdate');
        //Fon_SalesOrderService.createServicetaxSOLI( (OrderApi__Sales_Order__c []) records,(Map<Id,OrderApi__Sales_Order__c>) oldMap);    
        for(OrderApi__Sales_Order__c c : (OrderApi__Sales_Order__c [])records) {
               if(c.OrderApi__Is_Posted__c == true){
                    system.debug('BEFORE  !!!!!!==='+system.now()); 
                    List<OrderApi__Transaction__c> trans = new list< OrderApi__Transaction__c>();
                    trans =[select id from OrderApi__Transaction__c where OrderApi__Sales_Order__c=:c.id];
                    system.debug('BEFORE111111'+trans);
                    
                    system.debug('BEFORE NO OF TRANS==='+trans.size());
                    //subs
                    List<OrderApi__Subscription__c> subs = new list< OrderApi__Subscription__c >();
                    subs =[select id, OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__c from OrderApi__Subscription__c where OrderApi__Sales_Order_Line__r.OrderApi__Sales_Order__c=:c.id];
                    system.debug('BEFORE 111111'+subs);
                    
                    system.debug('BEFORE NO OF subs==='+subs.size());
                    //c.adderror('TESTINGeeeeeeee');
                    }
                    List<OrderApi__Transaction__c> trans = new list< OrderApi__Transaction__c>();
                    trans =[select id from OrderApi__Transaction__c where OrderApi__Sales_Order__c=:c.id];
                    system.debug('BEFORE OUTSIDE111111'+trans);
                    
                    system.debug('BEFORE NO OF TRANS==='+trans.size());
                            
            }
        Framework.Log.pop();
    }
     public override void afterUpdate(Map<Id,SObject> oldMap){
        Framework.Log.push(Fon_SalesOrderTrigger.class.getName(),'beforeUpdate');
        for(OrderApi__Sales_Order__c c : (OrderApi__Sales_Order__c [])records) {
               if(c.OrderApi__Is_Posted__c == true){
                    system.debug('AFTER UPDATEEEEE!!!!!!==='+system.now()); 
                    List<OrderApi__Transaction__c> trans = new list< OrderApi__Transaction__c>();
                    trans =[select id from OrderApi__Transaction__c where OrderApi__Sales_Order__c=:c.id];
                    system.debug('After111111'+trans);
                    
                    system.debug('AfterNO OF TRANS==='+trans.size());
                    //c.adderror('TESTINGeeeeeeee');
                    }
                    List<OrderApi__Transaction__c> trans = new list< OrderApi__Transaction__c>();
                    trans =[select id from OrderApi__Transaction__c where OrderApi__Sales_Order__c=:c.id];
                    system.debug('OUTSIDE111111'+trans);
                    
                    system.debug('AfterNO OF TRANS==='+trans.size());
                            
            }
        //Moved from subs trigger to go from SOLI->subs->term expire latest term
        //Fon_SalesOrderService.expireTermOldSubs( (OrderApi__Sales_Order__c []) records,(Map<Id,OrderApi__Sales_Order__c>) oldMap);
    
        //Fon_SalesOrderService.createServicetaxSOLI( (OrderApi__Sales_Order__c []) records,(Map<Id,OrderApi__Sales_Order__c>) oldMap);
        Framework.Log.pop();
    }


}