({
    init : function(component, event, helper) {
        component.set("v.showSpinner",true);
        var recordId = component.get("v.recordId");
        var action = component.get("c.convertProformaInvoice");
        action.setParams({
            salesOrderId: recordId
        }); 
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state == "SUCCESS") {
                component.set("v.showSpinner",false);    
                var ReturnValue= response.getReturnValue();
                
                component.set("v.myMap",ReturnValue);
                var mp= component.get("v.myMap");
                var msg = mp['true'];
                
                if(msg){
                    component.set("v.showError",true);
                    component.set("v.msg",msg);
                }
                else{
                    $A.util.removeClass
                    component.set("v.showToast",true);                   
                    window.setTimeout(
                        $A.getCallback(function () {
                            component.set("v.showToast", false);
                        }), 5000
                    );
                    helper.navigateBackToHomePage(component, event, helper);
                }
            }
            else if(state == "ERROR"){
                alert($Label.c.Fon_ContactToAdminErrorMessage);
            }
        });  
        $A.enqueueAction(action); 
    },
    closeClick:function(component, event, helper) {
        component.get("v.showError",false);
        helper.navigateBackToHomePage(component, event, helper);
    }
})