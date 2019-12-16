({
    doinit : function(component, event, helper) {
        var action= component.get('c.validPaymentMethod');
        action.setParams({  contactId : ''  });// setting the parameter to apex class method

        
        // Set up the callback
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            var resultsToast = $A.get("e.force:showToast");
            if(state === "SUCCESS"){
                //if successful stores query results in paymentMethods
                var recordTypes = response.getReturnValue();
                component.set('v.paymentMethods', response.getReturnValue());
            } else if (state === "ERROR") {
                //otherwise write errors to console for debugging
                alert('Problem with connection. Please try again. Error Code: relIPViewHelper.getIPList.action.setCallback');
                resultsToast.setParams({
                    "title": "Error",
                    "message": "Error: " + JSON.stringify(result.error)
                });
                resultsToast.fire();
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    },
    selectedPaymentMethod : function(component, event,helper){
        // alert(component.get("v.selectedPayment"));
    },
    handleClick : function(component, event,helper){
        var pm= component.get("v.selectedPayment");
        if(pm){
            helper.reloadLocation(component, event, helper); 
        }
        else{
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "warning",
                "type": "warning",
                "message": $A.get("$Label.c.Fon_SelectPaymentMethodValidation")
            });
            resultsToast.fire();
        }
    }
})