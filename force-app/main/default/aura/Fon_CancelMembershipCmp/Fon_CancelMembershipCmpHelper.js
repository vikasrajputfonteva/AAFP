({
    showToastMessage : function(type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            mode: 'dismissible',
            duration:'5000',
            title: title,
            message: message
        });
        toastEvent.fire();
    }, 
    cancelMembershipHelper : function(component, event, helper) {
        var reasonForCancelling = component.find("reasonForCancelling");
        var reasonForCancellingValue = reasonForCancelling.get("v.value"); 
        var fields = event.getParam('fields');
        var conId= component.get("v.contactId");
        var action = component.get("c.cancelMembership");
        action.setParams({
            recordId : conId,
            reason : reasonForCancellingValue,
            isRevertFinancial: component.get("v.isRevertFinancial")
        });
        action.setCallback(this,function(result){            
            if (result.getState() == 'SUCCESS') {
                component.set("v.dynamicMsgMAP",result.getReturnValue());
                var resultMap = component.get("v.dynamicMsgMAP");
                var strMessage = resultMap['isEmptyMember'];
                if(strMessage != 'true'){
                    component.find('membershipCanselForm').submit(fields);
                    this.gotoNewMembership(component, event, helper);
                }else{
                    this.showToastMessage("warning", "Warning!", $A.get("$Label.c.Fon_NoActiveMembership"));
                } 
            }
            else if (result.getState() === "ERROR") {
                var errors = result.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " + errors[0].message);
                    }
                    else{
                         alert($A.get("$Label.c.Fon_ContactToAdminErrorMessage"));
                    }
                } else {
                    alert($A.get("$Label.c.Fon_ContactToAdminErrorMessage"));
                }
            }
        });
        $A.enqueueAction(action);
    },
    gotoNewMembership : function(component, event, helper) {
        var isDeactivatingMembership = component.get("v.isDeactivatingMembership");
        if(isDeactivatingMembership){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:Fon_NewMembershipCmp",
                componentAttributes: {
                    contactId : component.get("v.contactId")
                }
            });
            evt.fire();
        }
    }
    
})