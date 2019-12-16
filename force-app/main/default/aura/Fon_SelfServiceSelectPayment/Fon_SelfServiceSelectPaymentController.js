({
    doInit : function(component, event, helper) {
        var lstPaymentMethods = component.get("v.lstPaymentMethods");
        
        if(lstPaymentMethods.length>0){
            component.set('v.showPicklist',true);
        }  
        else{
            component.set('v.showPicklist',false);
            helper.loadData(component, event, helper);
            component.set('v.showOldCmp',true);
        }
    },
    
 
   
    backHandleClick : function(component, event, helper){
        var currentContactId= component.get("v.recordId");
        var action = component.get('c.isvalidPaymentMethodAvailable');
        action.setParams({contactId : currentContactId});// setting the parameter to apex class method
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.lstPaymentMethods", response.getReturnValue());
                component.set('v.showOldCmp',false);
                component.set('v.showPicklist',true);
            } 
        }));
        $A.enqueueAction(action);
    },
    
    closeModel: function(cmp, event, helper) {
        cmp.set("v.isOpen", false);
    },
    
    createNewPaymentMethod : function(component, event, helper){
        helper.showSpinner(component);
        component.set("v.showOldCmp",true);
        component.set('v.showPicklist',false);
        helper.loadData(component, event, helper);
    },
    
    handleClick: function (component, event, helper) {
        
        var action = component.get('c.getPaymentMethod');
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue()==null){
                    alert('No Payment Method found');
                }
                else{
                    component.set('v.selectedPayment', response.getReturnValue());
                    
                }
                
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
                component.set("v.isOpen", true);
            }
        }));
        $A.enqueueAction(action); 
    },
})