public without sharing class Fon_ReceiptService {
    /* @@@TC-012644 
@Description: The Deposit Account on the Refund Receipt to the ‘Accounts Payable account’ on the Business Group that the receipt is related to.
*/
    
    public static void updateDepositeAccountBI(List<OrderApi__Receipt__c> newList){//Before Insert
        Framework.Log.push(Fon_ReceiptService.class.getName(),'updateDepositeAccountBI'); 
        if(newList.size()>0){
            Set<Id> businessGroupIds = new Set<Id>();
            Map<Id,Id> businessGroup_AccountsPayableAccount=new Map<Id,Id>();
            for(OrderApi__Receipt__c receipt:newList){
                businessGroupIds.add(receipt.OrderApi__Business_Group__c);
            }
            if(!businessGroupIds.isEmpty()){
                List<OrderApi__Business_Group__c> bgList=[select Accounts_Payable_Account__c from OrderApi__Business_Group__c where id in:businessGroupIds And Accounts_Payable_Account__c!=Null];
                if(bgList.size()>0){
                    for(OrderApi__Business_Group__c bg:bgList){
                        businessGroup_AccountsPayableAccount.put(bg.Id,bg.Accounts_Payable_Account__c);
                    }
                }
            }
            
            for(OrderApi__Receipt__c receipt:newList){
                if(receipt.OrderApi__Type__c=='Refund' && receipt.OrderApi__Payment_Type__c=='Check'){
                    if(!businessGroup_AccountsPayableAccount.isEmpty()){
                        if(businessGroup_AccountsPayableAccount.ContainsKey(receipt.OrderApi__Business_Group__c)){
                            receipt.OrderApi__Deposit_Account__c=businessGroup_AccountsPayableAccount.get(receipt.OrderApi__Business_Group__c);
                        }
                        else{
                            //receipt.addError(Label.Fon_ReceiptErrorMessage);    
                        }
                    }
                    else{
                      //  receipt.addError(Label.Fon_ReceiptErrorMessage);    
                    }
                }
            }
        }
        Framework.Log.pop();
    }
    
}