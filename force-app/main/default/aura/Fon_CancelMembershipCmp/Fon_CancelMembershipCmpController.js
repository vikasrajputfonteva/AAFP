({
    closeModal : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/r/Contact/"+component.get("v.contactId")+"/view?0.source=alohaHeader"
        });
        urlEvent.fire();
    },
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    
    actionOnSuccess : function(component, event, helper){
        helper.showToastMessage("success", "Success!",  $A.get("$Label.c.Fon_MembershipCancelled"));
        var isDeactivatingMembership = component.get("v.isDeactivatingMembership");
        if(!isDeactivatingMembership){
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "/lightning/r/Contact/"+component.get("v.contactId")+"/view?0.source=alohaHeader"
            });
            urlEvent.fire();
        }
    },
    
    onCheck : function(component, event, helper){
        var checkCmp = component.find("checkbox");
        var chkValue = checkCmp.get("v.value"); 
        if(chkValue){
            component.set("v.isRevertFinancial","true");
        }
        else{
            component.set("v.isRevertFinancial","false");
        }
    },
    
    recordSubmitted : function(component, event, helper){
        event.preventDefault();       // stop the form from submitting
        var reasonForCancelling = component.find("reasonForCancelling");
        var reasonForCancellingValue = reasonForCancelling.get("v.value"); 
        if(reasonForCancellingValue == '' || reasonForCancellingValue === undefined){
            helper.showToastMessage("warning", "Warning!", $A.get("$Label.c.Fon_PleaseSelectReasonForCancelling"));
            return;
        }
        helper.cancelMembershipHelper(component, event, helper)
    }
})