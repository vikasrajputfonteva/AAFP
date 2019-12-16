({
    doInit : function(component,event,helper) {
        var recordId = component.get("v.recordId");
        component.set("v.showSpinner",true);
        var action = component.get("c.refundCreditMemo");
        action.setParams({
            creditMemoId: recordId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state == "SUCCESS") {
                //component.set("v.showSpinner",false);    
                var ReturnValue= response.getReturnValue();
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": ReturnValue
                });
                navEvt.fire();
            }
        });  
        $A.enqueueAction(action); 
    }
})