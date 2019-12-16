/**
*
* Domain class for the Fon_SalesOrderLineDomain SObjectType
*
**/

global class Fon_SalesOrderLineDomain extends Framework.Domain{
    public Fon_SalesOrderLineDomain(List<OrderApi__Sales_Order_Line__c> sObjectList) {
        super(sObjectList);
    }
    
    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new Fon_SalesOrderLineDomain(sObjectList);
        }
    }
    public override void beforeInsert(){
        Framework.Log.push(Fon_SalesOrderLineDomain.class.getName(),'beforeInsert'); 
        Fon_SalesOrderLineQuantityService obj = new Fon_SalesOrderLineQuantityService();
        obj.manageQuantity((OrderApi__Sales_Order_Line__c[]) records);
        // Polulating PAC Employee, Occupation, Account Type
        setPacDetails((OrderApi__Sales_Order_Line__c[]) records);
        Framework.Log.pop();
    }
    public static void setPacDetails(List<OrderApi__Sales_Order_Line__c> lstSOLI){
        Set<Id> membershipStagingIds= new Set<Id>();
        Set<Id> soIds= new Set<Id>();
        Map<Id,String> employeeNameMap = new Map<Id,String>();
        Map<Id,String> occuptionMap = new Map<Id,String>();
        Map<Id,String> accountTypeMap = new Map<Id,String>();
        Map<Id,Id> soVSms = new Map<Id,Id>();
        Set<Id> soIdForAutoCalculateActivationDate = new Set<Id>();
        Set<Id> soIdsForDues= new Set<Id>();
        
        for(OrderApi__Sales_Order_Line__c objSoli : lstSOLI){
            if(objSoli.Fon_isPacItemLine__c){
                soIds.add(objSoli.OrderApi__Sales_Order__c);
            }
            else{
                soIdsForDues.add(objSoli.OrderApi__Sales_Order__c);
            }
        }
        if(!soIdsForDues.isEmpty()){
            List<OrderApi__Sales_Order__c> soList1 = [select id from OrderApi__Sales_Order__c where id in :soIdsForDues AND Fon_Salesorder_Type__c='Dues'];
            if(soList1.size()>0){
                for(OrderApi__Sales_Order__c soObj:soList1){
                    soIdForAutoCalculateActivationDate.add(soObj.Id);
                }
            }
        }
        for(OrderApi__Sales_Order_Line__c objSoli : lstSOLI){
            if(soIdForAutoCalculateActivationDate.contains(objSoli.OrderApi__Sales_Order__c)){
                objSoli.OrderApi__Auto_Calculate_Activation_Date__c=false;
            }
        }
        
        if(!soIds.isEmpty()){
            List<OrderApi__Sales_Order__c> soList = [select id,Fon_Salesorder_Type__c,Fon_Membership_Staging__c from OrderApi__Sales_Order__c where id in :soIds AND Fon_Membership_Staging__c!=Null];
            if(soList.size()>0){
                for(OrderApi__Sales_Order__c soObj:soList){
                    membershipStagingIds.add(soObj.Fon_Membership_Staging__c);
                    soVSms.put(soObj.Id,soObj.Fon_Membership_Staging__c);
                }
                if(!membershipStagingIds.isEmpty()){
                    List<Fon_Membership_Staging__c> msList = [select id,Fon_PAC_Contribution_Employer__c,Fon_PAC_Contribution_Account_Type__c,Fon_PAC_Contribution_Occupation__c from Fon_Membership_Staging__c where id in :membershipStagingIds];
                    if(msList.size()>0){
                        for(Fon_Membership_Staging__c msObj:msList){
                            employeeNameMap.put(msObj.Id,msObj.Fon_PAC_Contribution_Employer__c);
                            occuptionMap.put(msObj.Id,msObj.Fon_PAC_Contribution_Occupation__c);
                            accountTypeMap.put(msObj.Id,msObj.Fon_PAC_Contribution_Account_Type__c);
                        }
                        for(OrderApi__Sales_Order_Line__c objSoli : lstSOLI){
                            objSoli.Fon_Employee_Name__c= employeeNameMap.get(soVSms.get(objSoli.OrderApi__Sales_Order__c));
                            objSoli.Fon_Occupation__c= occuptionMap.get(soVSms.get(objSoli.OrderApi__Sales_Order__c));
                            objSoli.Fon_Account_Type__c= accountTypeMap.get(soVSms.get(objSoli.OrderApi__Sales_Order__c));
                        }
                    }
                }
            }
        }
    }
    
    /* TC-022253 */ 
    public override void afterInsert(){
        Framework.Log.push(Fon_SalesOrderLineDomain.class.getName(),'After Insert Fon_SalesOrderLineDomain'); 
        if(Fon_ConstantClass.runOnce){
            Fon_SalesorderLineHandler.createSoliForChapterLocal((OrderApi__Sales_Order_Line__c[])records); 
        }
        Framework.Log.pop();
    }
}