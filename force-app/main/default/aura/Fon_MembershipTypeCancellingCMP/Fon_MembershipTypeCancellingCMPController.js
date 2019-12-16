({
    closeModal : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/r/Contact/"+component.get("v.contactId")+"/view?0.source=alohaHeader"
        });
        urlEvent.fire(); 
    },
    
    recordSubmitted : function(component, event, helper) { 
        event.preventDefault();
        var fields = event.getParam("fields");
        component.set("v.fieldsObj",fields);
        $A.util.removeClass(component.find("membershipEditForm"), "slds-show");
        $A.util.addClass(component.find("membershipEditForm"), "slds-hide");
        component.set("v.showConfirm",true);  
    },
    
    continueButtonClick :  function(component, event, helper) { 
        var fields = component.get("v.fieldsObj");
        if(fields["Fon_Membership_Type__c"] == 'Student'){
            fields["Fon_Medical_School_Graduation_Date__c"] = new Date().toISOString();
        }else if(fields["Fon_Membership_Type__c"] == 'Resident'){
            fields["Fon_Residency_Program_Graduation_Date__c"] = new Date().toISOString();
        }
        fields["Fon_Staging_Status__c"] = 'Cancelled'; 
        fields["Fon_Is_Membership_Type_Changed__c"] = true;
        fields["Fon_Is_New__c"] = false;
        component.find("membershipEditForm").submit(fields);
        component.set("v.ShowModule",false);  
        component.set("v.showConfirm",false);  
        helper.continuetoCancel(component, event, helper);
    },
    
    backButtonClick :  function(component, event, helper) { 
        $A.util.removeClass(component.find("membershipEditForm"), "slds-hide");
        $A.util.addClass(component.find("membershipEditForm"), "slds-show");
        component.set("v.showConfirm",false);
        component.set("v.ShowModule",true);
    },   
    
    actionOnSuccess : function(component, event, helper) {
        component.set("v.ShowModule",false); 
        helper.cancelMembershipHelper(component, event, helper)
    },
    
    continueToSubmit : function(component, event, helper) {
        component.find('membershipStageId').submit(fields);
        
    },
    
    closeCancelModalView : function(component, event, helper) {
        component.set("v.showCancelReasonModal",false); 
        component.set("v.ShowModule",true); 
    },
    
    closeModalView : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})