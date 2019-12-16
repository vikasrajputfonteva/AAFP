({
    doInit : function(component, event, helper) {
        var activeSectionList = component.get("v.activeSectionList");
        activeSectionList.push($A.get("$Label.c.Fon_FirstPageFirstSectionTitle"));
        activeSectionList.push($A.get("$Label.c.Fon_FirstPageSecondSectionTitle"));
        activeSectionList.push($A.get("$Label.c.Fon_FirstPageThirdSectionTitle"));
        
        var currentContactId= component.get("v.recordId");
        
        if(!currentContactId){
            var action = component.get('c.getCurrentContactId');
            action.setCallback(this, $A.getCallback(function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    if(response.getReturnValue()!=null){
                        component.set("v.recordId",response.getReturnValue())
                        helper.fetchSubscriptionPlanPicklist(component, event);
                        helper.fetchCurrentSubscriptionPlan(component, event);
                        helper.checkSubscription(component, event);
                        helper.fetchValidPaymentMethod(component, event);
                        helper.fetchCurrentYearDues(component, event);
                        helper.fetchNextYearDues(component, event); 
                        
                    }
                } 
            }));
            $A.enqueueAction(action);
        }
        else{
            component.set("v.isComingFromBackend",true);
            helper.fetchSubscriptionPlanPicklist(component, event);
            helper.fetchCurrentSubscriptionPlan(component, event);
            helper.checkSubscription(component, event);
            helper.fetchValidPaymentMethod(component, event);
            helper.fetchCurrentYearDues(component, event);
            helper.fetchNextYearDues(component, event);
            
        }
        component.set("v.isfirstPage",true);
    },
    
    handlesubscriptionChange : function(component, event, helper) {
        var balaceAmt = component.get("v.balanceDue");
        var selectedValue = component.get("v.selectedValue"); 
        var currentPlan = component.get("v.currentPlan");
        var packAmt = component.get("v.packAmtDonation");
        var isFoundationDonationChecked = component.find("foundationDonationCheckBox").get("v.checked");
        var isNextYearConvenienceFeeApplied = component.get("v.isNextYearConvenienceFeeApplied");
        if(selectedValue){
            if(selectedValue=='Installment'){
                component.set("v.isFoundationAutoRenewDisable",false);
                if(selectedValue!=currentPlan){
                    if(balaceAmt>=110){
                        component.set("v.showValidationMsg",false);
                        component.set("v.isConvenienceFeeAdd",true);
                        if(isNextYearConvenienceFeeApplied){
                            component.set("v.convenienceFeeAmt",parseFloat($A.get("$Label.c.Fon_NextYearConvenienceFeeAmt")));
                        }
                        else{
                            component.set("v.convenienceFeeAmt",parseFloat($A.get("$Label.c.Fon_CurrentYearConvenienceFeeAmt")));
                        }
                        component.set("v.isNextButtonDisable",false);
                        component.set("v.isOnlyChangeSubscription",false);
                    }
                    else{
                        component.set("v.showValidationMsg",true);
                    }
                }
            }
            else if(selectedValue=='Auto Full Pay'){
                component.set("v.isFoundationAutoRenewDisable",false);
                if(selectedValue!=currentPlan){
                    /*if(balaceAmt<110){   Commented 15 nov
                        component.set("v.showValidationMsg",true);
                    }
                    else{*/
                    component.set("v.showValidationMsg",false);
                    component.set("v.isConvenienceFeeAdd",false);
                    component.set("v.convenienceFeeAmt",0);
                    component.set("v.isNextButtonDisable",false);
                    component.set("v.isOnlyChangeSubscription",true);
                    // } Commented 15 nov
                }
            }
        }			
        else{//If new Plan performa
            component.set("v.isFoundationDonationRenewal",false);
            component.set("v.isFoundationAutoRenewDisable",true);
            component.set("v.showValidationMsg",false);
            component.set("v.convenienceFeeAmt",0);
            component.set("v.isConvenienceFeeAdd",false);
            component.set("v.isNextButtonDisable",false);
            component.set("v.isOnlyChangeSubscription",true);
        }
        if(currentPlan==null){
            component.set("v.currentPlan","");
        }
        if(selectedValue==currentPlan){
            component.set("v.isOnlyChangeSubscription",false);
            component.set("v.showValidationMsg",false);
            component.set("v.convenienceFeeAmt",0);
            component.set("v.isConvenienceFeeAdd",false);
            if(!isFoundationDonationChecked && packAmt == 0){
                component.set("v.isNextButtonDisable",true);
            }
        }
    },
    
    selectPACDonation : function(component, event, helper){        
        component.set("v.isDonationAmountDisable",true);
        var isChecked = component.find("foundationDonationCheckBox").get("v.checked");
        var packValue = event.getSource().get("v.value");
        
        if(event.getSource().get("v.value")){
            component.set("v.isRequired", true);
            if(event.getSource().get("v.value") == 0){
                component.set("v.disableInputField",false);
                component.set("v.isDonationAmountDisable",false)
                component.set("v.packAmtDonation",0);
                
                if(isChecked){ }
                else{
                    component.set("v.isNextButtonDisable",true);
                }
                component.set("v.isOnlyChangeSubscription",false);
                component.set("v.donationAmount",0.00);
            }
            else{
                component.set("v.disableInputField",false);
                var packAmt =  parseFloat(event.getSource().get("v.value"));
                component.set("v.packAmtDonation",packAmt);
                component.set("v.isNextButtonDisable",false);
                component.set("v.isOnlyChangeSubscription",false);
                component.set("v.donationAmount",packAmt);
            }
            
            if(packValue=='50'){
                component.set("v.isSecondChecked",false);
                component.set("v.isThirdChecked",false);
                component.set("v.isFourthChecked",false);
                component.set("v.isFiveChecked",false);
            }
            else if(packValue=='100'){
                component.set("v.isFirstChecked",false);
                component.set("v.isThirdChecked",false);
                component.set("v.isFourthChecked",false);
                component.set("v.isFiveChecked",false);
            }
                else if(packValue=='365'){
                    component.set("v.isFirstChecked",false);
                    component.set("v.isSecondChecked",false);
                    component.set("v.isFourthChecked",false);
                    component.set("v.isFiveChecked",false);
                }
                    else if(packValue=='0'){
                        component.set("v.isFirstChecked",false);
                        component.set("v.isSecondChecked",false);
                        component.set("v.isThirdChecked",false);
                        component.set("v.isFiveChecked",false);
                    }
        }
        else{
            component.set("v.isRequired", false);
            var empName = component.find("empName");    
            var occupation = component.find("occupation");    
            empName.setCustomValidity("");
            occupation.setCustomValidity("");
            empName.reportValidity();
            occupation.reportValidity();
            
            component.set("v.disableInputField",true);
            component.set("v.isDonationAmountDisable",true);
            component.set("v.packAmtDonation",0);
            
            if(isChecked){ }
            else{
                component.set("v.isNextButtonDisable",true);
            }
            component.set("v.isOnlyChangeSubscription",true);
            component.set("v.donationAmount",0.00);
        }
    },
    
    customPACDonation : function(component, event, helper){
        var amt= parseFloat(event.getSource().get("v.value"));
        if(amt){
            component.set("v.packAmtDonation",amt);
            component.set("v.isNextButtonDisable",false);
        }
        else{
            component.set("v.packAmtDonation",0);
            component.set("v.isNextButtonDisable",true);
        }
    },
    
    selectFoundationDonationRenewal : function(component, event, helper){
        component.set("v.isFoundationDonationRenewal",component.find("isFoundationDonationRenewalCheckBox").get("v.checked"));
    },   
    
    selectFoundationDonation : function(component, event, helper) {
        var isChecked = component.find("foundationDonationCheckBox").get("v.checked");
        var donationAmt= component.get("v.foundationAmtDonation");
        var packAmt = component.get("v.packAmtDonation");
        
        if(isChecked){
            component.set("v.isFoundationDonationChecked",true);
            component.set("v.foundationAmtDonation",50);
            component.set("v.isNextButtonDisable",false);
            component.set("v.isOnlyChangeSubscription",false);
        }
        else{ 
            component.set("v.foundationAmtDonation",0);
            component.set("v.isFoundationDonationChecked",false);  
            if(packAmt == 0){
                component.set("v.isNextButtonDisable",true);
            }
            component.set("v.isOnlyChangeSubscription",true);
        }
    },
    
    processPaymentButtionClick : function(component, event, helper){
        helper.showSpinner(component);
        var donationAmt= component.get("v.foundationAmtDonation");
        var packAmt = component.get("v.packAmtDonation");
        var convenienceFeeAmt = component.get("v.convenienceFeeAmt");
        var newSubscriptionPlan = component.get("v.selectedValue");
        var isFoundationDonationRenewal = component.get("v.isFoundationDonationRenewal");
        
        var currentContactId= component.get("v.recordId");
        var isCurrentTermNotPaidFull= component.get("v.isCurrentTermNotPaidFull");
        
        
        var soliList =  component.get("v.soliList");
        var selectedValue =  component.get("v.selectedValue");
        var currentPlan =  component.get("v.currentPlan");
        var isDonationAvailable = false;
        var isDuesAvailable = false;
        
        if(donationAmt>0 || packAmt >0 || convenienceFeeAmt >0){//Checking Donation 
            isDonationAvailable= true;
        }
        if(soliList.length>0 && (selectedValue=='Auto Full Pay' || selectedValue=='') && selectedValue!=currentPlan){
            isDuesAvailable = true;
        }
        
        if(isDonationAvailable && isDuesAvailable){
            component.set("v.payDonationDuesSo",true);
            helper.createSalesOrderForDonation(component, event);
        }
        else if(isDuesAvailable){ 
            if(soliList[0].invoiceId!=null && soliList[0].invoiceId!=''){
                var action = component.get("c.createEpaymentLine");
                action.setParams({invID : soliList[0].invoiceId,paymentMethodId : component.get("v.selectedPayment")});// setting the parameter to apex class method
                action.setCallback(this, $A.getCallback(function (result) {
                    var state = result.getState();
                    if (state == 'SUCCESS') {
                        if(result.getReturnValue()!=null){    
                            var action = component.get("c.payInvoiceDues");
                            action.setParams({epayId : result.getReturnValue(), newSubscriptionPlan : newSubscriptionPlan, isFoundationDonationRenewal : isFoundationDonationRenewal,paymentMethodId : component.get("v.selectedPayment")});
                            action.setCallback(this, $A.getCallback(function (result) {
                                var state = result.getState();
                                if (state == 'SUCCESS') {
                                    if(result.getReturnValue()!=null){    
                                        helper.hideSpinner(component);
                                        // alert(result.getReturnValue());
                                        var ReturnValue= result.getReturnValue();
                                        component.set("v.ConfirmationNumber",ReturnValue[0].OrderApi__Receipt__r.Name);
                                        component.set("v.receiptLinelst",ReturnValue);
                                        component.set("v.stepIndex","3");
                                        component.set("v.isfirstPage",false); 
                                        component.set("v.isSecondPage",false); 
                                        component.set("v.isThirdPage",true);
                                    }
                                    else{
                                        helper.hideSpinner(component);
                                        alert($A.get("$Label.c.Fon_PaymentNotSuccesfull"));
                                    }
                                }
                                else if (state === "ERROR") {
                                    helper.hideSpinner(component);
                                    var errors = result.getError();
                                    if (errors) {
                                        if (errors[0] && errors[0].message) {
                                            alert("Error message: " + errors[0].message);
                                        }
                                    } else {
                                        alert($A.get("$Label.c.Fon_ContactToAdminErrorMessage"));
                                    }
                                }
                            }));
                            $A.enqueueAction(action);
                            
                        }
                        else{
                            helper.hideSpinner(component);
                            alert($A.get("$Label.c.Fon_PaymentNotSuccesfull"));
                        }
                    }
                    else if (state === "ERROR") {
                        helper.hideSpinner(component);
                        var errors = result.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                alert("Error message: " + errors[0].message);
                            }
                        } else {
                            alert($A.get("$Label.c.Fon_ContactToAdminErrorMessage"));
                        }
                    }
                }));
                $A.enqueueAction(action);
            }
            else if(soliList[0].salesOrderId!=null && soliList[0].salesOrderId!=''){
                var action = component.get("c.payReceiptDues");
                action.setParams({soID : soliList[0].salesOrderId, paymentMethodId : component.get("v.selectedPayment"), newSubscriptionPlan : newSubscriptionPlan, isFoundationDonationRenewal : isFoundationDonationRenewal});// setting the parameter to apex class method
                action.setCallback(this, $A.getCallback(function (result) {
                    var state = result.getState();
                    if (state == 'SUCCESS') {
                        if(result.getReturnValue()!=null){    
                            helper.hideSpinner(component);
                            var ReturnValue= result.getReturnValue();
                            component.set("v.ConfirmationNumber",ReturnValue[0].OrderApi__Receipt__r.Name);
                            component.set("v.receiptLinelst",ReturnValue);
                            component.set("v.stepIndex","3");
                            component.set("v.isfirstPage",false); 
                            component.set("v.isSecondPage",false); 
                            component.set("v.isThirdPage",true);
                            
                            //alert(result.getReturnValue());
                        }
                        else{
                            helper.hideSpinner(component);
                            alert($A.get("$Label.c.Fon_PaymentNotSuccesfull"));
                        }
                    }
                    else if (state === "ERROR") {
                        helper.hideSpinner(component);
                        var errors = result.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                alert("soliList[0].salesOrderIdError message: " + errors[0].message);
                            }
                        } else {
                            alert($A.get("$Label.c.Fon_ContactToAdminErrorMessage"));
                        }
                    }
                }));
                $A.enqueueAction(action);
            }
        }
            else if(isDonationAvailable){
                helper.createSalesOrderForDonation(component, event);
            }
    },
    
    selectAccountType : function(component,event){
        var accountType = event.getSource().get("v.value");
        component.set("v.accountType",accountType);
        if(accountType=='Corporate'){
            component.set("v.isAccountTypePersonalChecked",false);
        }
        else if(accountType=='Personal'){
            component.set("v.isAccountTypeCorporateChecked",false);
        }
    },

    nextButtonClick : function(component, event, helper){
        var isOnlyChangeSubscription =  component.get("v.isOnlyChangeSubscription");
        var newSubscriptionPlan = component.get("v.selectedValue"); 
        var soliList = component.get("v.soliList");
        var currentContactId= component.get("v.recordId");
        
        if(isOnlyChangeSubscription && soliList.length==0){
            helper.showSpinner(component);
            var action = component.get("c.changeSubscriptionPlan");
            action.setParams({contactId : currentContactId,newSubscriptionPlan : newSubscriptionPlan});
            action.setCallback(this,function(result){
                var state = result.getState();
                if(state == 'SUCCESS'){
                    component.set("v.isOnlyChangeSubscription",false);
                    component.set("v.isNextButtonDisable",true);
                    if(result.getReturnValue()){
                        component.set("v.currentPlan",newSubscriptionPlan);
                        helper.checkSubscription(component, event);
                        alert("Plan Changed Successfully!");
                    }
                    helper.hideSpinner(component);
                }
                else if (state === "ERROR") {
                    helper.hideSpinner(component);
                    var errors = result.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            alert("Error message: " + errors[0].message);
                        }
                    } else {
                        alert($A.get("$Label.c.Fon_ContactToAdminErrorMessage"));
                    }
                }
            });
            $A.enqueueAction(action);
        }
        else{
            var empName = component.find("empName");    
            var empNameValue = empName.get("v.value");
            var occupation = component.find("occupation");    
            var occupationValue = occupation.get("v.value");
            if(empNameValue){
                empName.setCustomValidity("");
            }
            else{
                empName.setCustomValidity($A.get("$Label.c.Fon_EmployeeNameRequired"));
            }
            if(occupationValue){
                occupation.setCustomValidity("");
            }
            else{
                occupation.setCustomValidity($A.get("$Label.c.Fon_OccupationRequired"));
            }
            empName.reportValidity();
            occupation.reportValidity();
            if(empNameValue && occupationValue){
                component.set("v.stepIndex","2");
                component.set("v.isfirstPage",false); 
                component.set("v.isSecondPage",true); 
                component.set("v.isThirdPage",false);  
            }
            else if(component.get("v.disableInputField")){
                component.set("v.stepIndex","2");
                component.set("v.isfirstPage",false); 
                component.set("v.isSecondPage",true); 
                component.set("v.isThirdPage",false); 
            }
        }
    },

    handleBlur : function (component, event) {
        var empName = component.find("empName");    
        var empNameValue = empName.get("v.value");
        var occupation = component.find("occupation");    
        var occupationValue = occupation.get("v.value");
        if(empNameValue){
            empName.setCustomValidity("");
        }
        else{
            empName.setCustomValidity($A.get("$Label.c.Fon_EmployeeNameRequired"));
        }
        if(occupationValue){
            occupation.setCustomValidity("");
        }
        else{
            occupation.setCustomValidity($A.get("$Label.c.Fon_OccupationRequired"));
        }
        empName.reportValidity();
        occupation.reportValidity();
    },

    backButtonClick : function(component, event){
        component.set("v.stepIndex","1");
        component.set("v.isfirstPage",true); 
        component.set("v.isSecondPage",false); 
        component.set("v.isThirdPage",false);  
    },

    handleSectionToggle : function(component, event){
        var openSections = event.getParam('openSections');
        var activeSections = component.get("v.activeSections");
        component.set("v.activeSections",openSections);
    }
})