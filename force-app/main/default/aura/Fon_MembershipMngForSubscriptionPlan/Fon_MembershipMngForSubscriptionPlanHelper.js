({
    fetchAllSuscription : function(component, event, helper) {
        var action = component.get("c.fetchAllSuscriptionPlan");
        action.setParams({
            subscriptionId : component.get("v.objActiveSubscription").Id
        });
        action.setCallback(this,function(result){            
            if (result.getState() == 'SUCCESS') {
                var lstPlan = result.getReturnValue();
                component.set("v.lstSubscriptionPlan",lstPlan);
                component.set("v.isComponentLoading",false);
                
            }else {
                this.showToastMessage("error", "Error!", $A.get("$Label.c.Fon_ContactToAdminErrorMessage"));
            }
            $A.get("e.force:closeQuickAction").fire();
            var serverStatusSpinner = component.find("serverStatusSpinner");
            $A.util.toggleClass(serverStatusSpinner, "slds-hide");
            
        });
		$A.enqueueAction(action);
    },
    showToastMessage : function(type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            mode: 'dismissible',
            duration:'2000',
            title: title,
            message: message
        });
        toastEvent.fire();
    },
    changeSubscriptionPlan : function(component, event, helper) {
        var action = component.get("c.changeSubscriptionPlan");
        action.setParams({
            ContactId : component.get("v.contactId"),
            OldsubPlanId : component.get("v.objActiveSubscription"),
            NewsubPlanId : component.get("v.selectedSuscribePlanId")
        });
        action.setCallback(this,function(result){            
            if (result.getState() == 'SUCCESS') {
                //alert(result.getReturnValue());
                this.showToastMessage("success", "SUCCESS!", $A.get("$Label.c.Fon_SubscriptionUpdated"));
                //alert('ContactId'+component.get("v.contactId")+'OldsubPlanId'+component.get("v.objActiveSubscription").OrderApi__Subscription_Plan__c+'NewsubPlanId'+component.get("v.selectedSuscribePlanId"));
            }else {
                this.showToastMessage("error", "Error!", $A.get("$Label.c.Fon_ContactToAdminErrorMessage"));
            }
            $A.get("e.force:closeQuickAction").fire();
            var serverStatusSpinner = component.find("serverStatusSpinner");
            $A.util.toggleClass(serverStatusSpinner, "slds-hide");
            component.set("v.isComponentLoading",true);
            this.redirectToContact(component, event, helper);
        });
		$A.enqueueAction(action);
    },
    redirectToContact : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/r/Contact/"+component.get("v.contactId")+"/view?0.source=alohaHeader"
        });
        urlEvent.fire();
    }
})