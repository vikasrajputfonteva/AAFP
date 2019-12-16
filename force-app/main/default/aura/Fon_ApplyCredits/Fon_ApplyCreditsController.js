({
    init : function(component, event, helper) {
        var recordIds = component.get("v.recordIds");
        if (recordIds) {
            var action = component.get("c.process");
            action.setParams({
                soIds : recordIds
            }); 
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state == "SUCCESS") {
                    component.set("v.showToast",true);
                    var ReturnValue= response.getReturnValue();
                }else if(state == "ERROR"){
                    alert('error');
                    helper.navigateBack(component, event, helper);
                }
            });  
            $A.enqueueAction(action);
        }
        else{
            component.set("v.showError",true);
        }
    },
    backClick : function(component, event, helper){
        component.set("v.showSpinner",true);       
        helper.navigateBack(component, event, helper);
    }
    
})