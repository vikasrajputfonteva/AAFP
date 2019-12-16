({
	init : function(component, event, helper) {
		helper.fetchAllSuscription(component, event, helper);
	},
    changeValue : function(component, event, helper) {
        //alert('======'+ component.get("v.selectedSuscribePlanId"));
    },
    closeModalView : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/r/Contact/"+component.get("v.contactId")+"/view?0.source=alohaHeader"
        });
        urlEvent.fire();
    },
    updateSubscription : function(component, event, helper) {
        var objActiveSubscription = component.get("v.objActiveSubscription");
        var selectedSubscriptionPlanId = component.get("v.selectedSuscribePlanId");
        if(objActiveSubscription == '' || objActiveSubscription == undefined || objActiveSubscription == null){
     		helper.showToastMessage("warning", "Warning!", $A.get("$Label.c.Fon_NoActiveSubscription"));
            return;
        }
        if(selectedSubscriptionPlanId == '' || selectedSubscriptionPlanId == undefined){
            helper.showToastMessage("warning", "Warning!", $A.get("$Label.c.Fon_SelectAtLeastOneSubscription"));
            return;
        }
        if(objActiveSubscription.OrderApi__Subscription_Plan__c == selectedSubscriptionPlanId){
            helper.showToastMessage("warning", "Warning!", $A.get("$Label.c.Fon_SelectedSubscriptionPlan"));
            return; 
        }
        var serverStatusSpinner = component.find("serverStatusSpinner");
        component.set("v.isComponentLoading",true);
        $A.util.toggleClass(serverStatusSpinner, "slds-hide");
        helper.changeSubscriptionPlan(component, event, helper);
    },
    cancelView : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/r/Contact/"+component.get("v.contactId")+"/view?0.source=alohaHeader"
        });
        urlEvent.fire();
    }
})