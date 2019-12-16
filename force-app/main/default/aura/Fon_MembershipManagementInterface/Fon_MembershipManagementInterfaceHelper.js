({
    cancelMembershipHelper : function(component, event, helper) {
		var action = component.get("c.cancellingMembership");
        action.setParams({
            recordId : component.get("v.recordId"),
            reason : component.get("v.reasonForCancelling"),
            source : 'membershipcancelled'
        });
        action.setCallback(this,function(result){            
            if (result.getState() == 'SUCCESS') {
                component.set("v.dynamicMsgMAP",result.getReturnValue());
                var resultMap = component.get("v.dynamicMsgMAP");
                var strMessage = resultMap['isEmptyMember'];
                if(strMessage != 'true'){
                    //Show success message
                	this.showToastMessage("success", "Success!", $A.get("$Label.c.Fon_MembershipCancelled"));
                }else{
                    this.showToastMessage("warning", "Warning!", $A.get("$Label.c.Fon_NoActiveMembership"));
                }
            }
            else {
                this.showToastMessage("error", "Error!", $A.get("$Label.c.Fon_ContactToAdminErrorMessage"));
            }
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
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
    fetchActiveMembership : function(component, event, helper) {
        var action = component.get("c.fetchingActiveMembership");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this,function(result){            
            if (result.getState() == 'SUCCESS') {
                var membershipId = result.getReturnValue();
                component.set("v.activeMembershipId",membershipId);
            }else {
                this.showToastMessage("error", "Error!", $A.get("$Label.c.Fon_ContactToAdminErrorMessage"));
            }
        });
        $A.enqueueAction(action);
    },
    fetchActiveSubscription : function(component, event, helper) {
        var action = component.get("c.fetchingActiveSubscription");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this,function(result){            
            if (result.getState() == 'SUCCESS') {
                var aubscriptionId = result.getReturnValue();
                component.set("v.objActiveSubscription",aubscriptionId);
                this.disableRevertTheFinancialCheckbox(component, event, helper);
            }else {
                this.showToastMessage("error", "Error!", $A.get("$Label.c.Fon_ContactToAdminErrorMessage"));
            }
        });
        $A.enqueueAction(action);
    },
    disableRevertTheFinancialCheckbox :  function(component, event, helper) {
        var membershipId = component.get("v.activeMembershipId");
        var action = component.get("c.disableRevertTheFinancialCheckbox");
        action.setParams({
            recordId : membershipId
        });
        action.setCallback(this,function(result){            
            if (result.getState() == 'SUCCESS') {
                component.set("v.disableRevertTheFinancialCheckbox",result.getReturnValue());
            }else {
                this.showToastMessage("error", "Error!", $A.get("$Label.c.Fon_ContactToAdminErrorMessage"));
            }
        });
        $A.enqueueAction(action);
    }
})