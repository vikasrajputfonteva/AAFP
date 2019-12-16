({
    init: function(cmp, event, helper) {
        var sectionfieldSetName = cmp.get('v.sectionfieldSetName');
        var changeMemberTypeFieldSetName = cmp.get('v.changeMemberTypeFieldSetName');
        var isUpgrade = cmp.get("v.isUpgrade");
        var recordId = cmp.get('v.contactId');
        var getFormAction = cmp.get('c.getForm');
        if(isUpgrade){
            getFormAction.setParams({
                "fieldSetName": changeMemberTypeFieldSetName,
                "objectName": "Fon_Membership_Staging__c",
                "recordId": recordId,
                "isUpgrade": isUpgrade
            });
        }
        else{
            getFormAction.setParams({
                "fieldSetName": sectionfieldSetName,
                "objectName": "Fon_Membership_Staging__c",
                "recordId": recordId,
                "isUpgrade": isUpgrade
            });
        }
        getFormAction.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === "SUCCESS") {
                var form = response.getReturnValue();
                cmp.set('v.sectionFields', form);
            }
        });
        $A.enqueueAction(getFormAction);
    },
    
    HideMe: function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/r/Contact/"+component.get("v.contactId")+"/view?0.source=alohaHeader"
        });
        urlEvent.fire();
    },
    
    ShowModuleBox: function(component, event, helper) {
        component.set("v.ShowModule", true);
    },
    
    savedSuccessfully: function(component, event, helper) {
        component.set("v.ShowModule",false);
        helper.onSuccess(component, event, helper);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/r/Contact/"+component.get("v.contactId")+"/view?0.source=alohaHeader"
        });
        urlEvent.fire();
    },
    
    pageError: function(component, event, helper) {
        alert('Please contact to your admin.');
    },
    
    handleOnSubmit: function(component, event, helper) {
        event.preventDefault();
        var chapterValue = component.find("duesPaidBychapter").get("v.value");
        var residencyID = component.find("duesPaidByResidencyID").get("v.value");
        var chapterId;	
        var warningMessage;
        
        var mainMembershipValue = component.find("mainPicklist").get("v.value");	
        if(mainMembershipValue == 'Student' || mainMembershipValue == 'Resident'){
            var resiPicklist = component.find("resiPicklist");    
            var resiValue = resiPicklist.get("v.value");
            if(resiValue){ }
            else{
                alert($A.get("$Label.c.Fon_ResidencyProgramGraduationDateValidationMessage"));
                return;
            }
        }
        
        if(chapterValue){
            warningMessage= $A.get("$Label.c.Fon_ValidChapterId");
            if(component.get("v.chapterId")){
                chapterId = component.get("v.chapterId");
            }
            else if(component.get("v.chapterAccountId")){
                
            }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type: 'Warning',
                        mode: 'dismissible',
                        duration:' 2000',
                        title: "Warning!",
                        message: $A.get("$Label.c.Fon_ChapterIdRequiredMessage")
                    });
                    toastEvent.fire();
                    return;
                }
        }
        else if(residencyID){
            warningMessage= $A.get("$Label.c.Fon_ValidResidencyId");
            if(component.get("v.residencyId")){
                chapterId = component.get("v.residencyId");
            }
        }
        
        if(chapterId){
            var action = component.get('c.isChapterIdValid');
            action.setParams({
                "chapterId": chapterId,
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (response.getReturnValue() && state === "SUCCESS") { 
                    var fields = event.getParam("fields"); 
                    fields["Fon_Contact__c"] = component.get("v.contactId");
                    fields["Fon_Is_New__c"] = true;
                    var isUpgrade = component.get("v.isUpgrade");
                    if(isUpgrade){
                        fields["Fon_Is_New__c"] = false;
                    }
                    component.find('MemStag').submit(fields);
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type: 'Warning',
                        mode: 'dismissible',
                        duration:' 2000',
                        title: "Warning!",
                        message: warningMessage
                    });
                    toastEvent.fire();
                    component.set("v.chapterId","");
                }
            });
            $A.enqueueAction(action);
        }
        else{
            var fields = event.getParam("fields");
            fields["Fon_Contact__c"] = component.get("v.contactId");
            var isUpgrade = component.get("v.isUpgrade");
            if(isUpgrade){
                fields["Fon_Is_New__c"] = false;
            }
            component.find('MemStag').submit(fields);
        } 
    },
    
    paidByChapter: function(component, event, helper) {
        var chapterValue = component.find("duesPaidBychapter").get("v.value");
        if(chapterValue == true){
            component.find("duesPaidByResidencyID").set("v.value",false);
            component.set("v.isChapterIdDisable",false);
            component.set("v.isResidencyDisable",true);
            component.set("v.residencyAccountId",null);
            component.set("v.residencyId","");
            component.set("v.isPaymentMethodDisable",true);
            component.set("v.paymentMethodId",null);
            component.set("v.paymentId","");
        }else{
            component.set("v.isChapterIdDisable",true);
            component.set("v.chapterId","");
            component.set("v.chapterAccountId",null);
            component.set("v.isPaymentMethodDisable",false);
        }
    },
    
    chpterTxt : function(component, event, helper){
        // component.set("v.chapterAccountId","");
    },
    
    chapterAccount : function(component, event, helper){
        // component.set("v.chapterId","");
    },
    
    residencyTxt : function(component, event, helper){
        //   component.set("v.residencyAccountId","");
    },
    
    residencyAccount : function(component, event, helper){
        //  component.set("v.residencyId","");
    },
    
    paidByResidency: function(component, event, helper) {
        var residencyID = component.find("duesPaidByResidencyID").get("v.value");	
        
        if(residencyID == true){
            component.find("duesPaidBychapter").set("v.value",false);
            component.set("v.isChapterIdDisable",true);
            component.set("v.isResidencyDisable",false);
            component.set("v.chapterId","");
            component.set("v.chapterAccountId",null);
            component.set("v.isPaymentMethodDisable",true);
            component.set("v.paymentMethodId",null);
            component.set("v.paymentId","");
        }
        else{
            component.set("v.isResidencyDisable",true);
            component.set("v.residencyId","");
            component.set("v.residencyAccountId",null);
            component.set("v.isPaymentMethodDisable",false);
        }
    },
    
    foundationDonationRenewalChange: function(component, event, helper) {
        var foundationDonationRenewalValue = component.find("foundationDonationRenewalId").get("v.value");
        if(foundationDonationRenewalValue == true){
            component.set("v.isDonationDisable",false);
        }else{
            component.set("v.isDonationDisable",true);
        }
    },
    
    handleSubmit: function(component, event, helper) {
        event.preventDefault();
        var mainMembershipValue = component.find("mainPicklist").get("v.value");	
        if(mainMembershipValue == 'Resident'){
            var resiPicklist = component.find("resiPicklist");    
            var resiValue = resiPicklist.get("v.value");
            if(resiValue){ }
            else{
                alert($A.get("$Label.c.Fon_ResidencyProgramGraduationDateValidationMessage"));
                return;
            }
        }
        if(mainMembershipValue == 'Student'){
            var medicalSchoolDate = component.find("medicalSchoolDate");    
            var medicalSchoolDateValue = medicalSchoolDate.get("v.value");
            if(medicalSchoolDateValue){ }
            else{
                alert($A.get("$Label.c.Fon_MedicalSchoolDateValidationMessage"));
                return;
            }
        }      
        
        var fields = event.getParam("fields");
        fields["Fon_Contact__c"] = component.get("v.contactId");
        var isUpgrade = component.get("v.isUpgrade");
        if(isUpgrade){
            fields["Fon_Is_New__c"] = false;
        }
        component.find('MemStag').submit(fields);
    },
    changePlanPickList : function(component, event, helper) {
        var val = event.getSource().get("v.value");
        if(val == 'Auto Full Pay' || val == 'Installment'){
            component.set("v.isFoundationDonationRenewalDisable",false);
        }
        else{
            component.find("foundationDonationRenewalId").set("v.value", false);
            component.set("v.isFoundationDonationRenewalDisable",true);
        }
    }
})