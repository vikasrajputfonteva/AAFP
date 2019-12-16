({
    parentComponentEvent : function(component, event, helper){
        var message = event.getParam("lstSalesOrder"); 
        component.set("v.lstSalesOrder", message);   
    },
    submitSalesOrder : function(component, event, helper){
        var spinner = component.find("quickPaySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        component.set("v.submitBtnDisable",true); // Remove this line of code after testing done
        var payeeEmail = component.get("v.payeeEmail");
        if(true){  
            var baseemailCheck = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
            if(baseemailCheck.test(payeeEmail) || !(payeeEmail)){
            }else{
                var spinner = component.find("quickPaySpinner");
                $A.util.toggleClass(spinner, "slds-hide");
                component.set("v.submitBtnDisable",false);
                var theme = component.find("toast-theme");
                $A.util.addClass(theme, "slds-theme_warning");
                component.set('v.toastwindowMain',true);
                var staticLabel = $A.get("$Label.c.Fon_valid_EmailAddress");
                component.set("v.msg",staticLabel);
                window.setTimeout(
                    $A.getCallback(function () {
                        component.set("v.toastwindowMain", false);
                        component.set("v.msg", "");
                    }), 2000
                ); 
                $A.util.removeClass(theme, "slds-theme_warning");
                return;
            }
        }
        else{
            var spinner = component.find("quickPaySpinner");
            $A.util.toggleClass(spinner, "slds-hide");
            component.set("v.submitBtnDisable",false);
            component.set('v.toastwindowMain',true);
            var staticLabel = $A.get("$Label.c.Fon_valid_EmailAddress");
            component.set("v.msg",staticLabel);
            window.setTimeout(
                $A.getCallback(function () {
                    component.set("v.toastwindowMain", false);
                    component.set("v.msg", "");
                }), 2000
            ); 
            return;
        }
        //$A.util.toggleClass(spinner, "slds-hide");    // Remove this line of code after testing done
        helper.validateAndSubmitSalesOrder(component, event, helper);
    }
})