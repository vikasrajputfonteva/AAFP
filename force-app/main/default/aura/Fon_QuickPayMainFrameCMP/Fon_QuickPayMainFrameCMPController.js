({
    parentComponentEvent : function(component, event, helper){
        //Get the event message attribute
         alert('parent--'+event.getParam("lstSalesOrder"));
        var message = event.getParam("lstSalesOrder"); 
        //Set the handler attributes based on event data 
        component.set("v.lstSalesOrder", message);   
    },
    submitSalesOrder : function(component, event, helper){
        var spinner = component.find("quickPaySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        component.set("v.submitBtnDisable",true);
        var payeeEmail = component.get("v.payeeEmail");
        //if(payeeEmail){
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
                //alert('Please enter valid email id');
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
        }else{
            var spinner = component.find("quickPaySpinner");
            $A.util.toggleClass(spinner, "slds-hide");
            component.set("v.submitBtnDisable",false);
            component.set('v.toastwindowMain',true);
            var staticLabel = $A.get("$Label.c.Fon_valid_EmailAddress");
           // alert('Please enter valid email id');
           component.set("v.msg",staticLabel);
           window.setTimeout(
						$A.getCallback(function () {
							component.set("v.toastwindowMain", false);
							component.set("v.msg", "");
						}), 2000
					); 
            return;
        }
        helper.validateAndSubmitSalesOrder(component, event, helper);
    }
})