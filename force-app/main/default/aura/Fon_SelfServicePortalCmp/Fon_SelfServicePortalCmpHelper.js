({
    checkSubscription : function(component, event){ 
        var currentContactId= component.get('v.recordId');    
        var action = component.get("c.isCurrentSubcriptionIsActive");
        action.setParams({contactId : currentContactId});// setting the parameter to apex class method
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue()){
                    component.set('v.disableChangeSubscriptionPicklist',false)
                    this.isFullPaidCurrentSubcription(component, event);
                }
                else{
                    this.isRenewalOrderCreated(component, event);                   
                }
            } 
        }));
        $A.enqueueAction(action);
    },
    
    checkCurrentDuesSO : function(component, event){
        var currentContactId= component.get('v.recordId');
        var currentPlan = component.get("v.currentPlan");
        var action = component.get("c.checkCurrentDuesSO");
        action.setParams({contactId : currentContactId});// setting the parameter to apex class method
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {    
                var result = response.getReturnValue();
                if(result!=null){
                    for(var key in result){
                        component.set("v.balanceDue",parseFloat(key));
                        component.set("v.soliList",result[key]);
                        console.log('jmd state--'+JSON.stringify(component.get("v.soliList")));
                    }
                    if(component.get("v.balanceDue")>0){ 
                        component.set("v.isCurrentYearDuesNotPaid",true)
                        component.set('v.disableChangeSubscriptionPicklist',false)
                    }
                    else{
                        if(currentPlan == 'Installment'){
                            component.set('v.disableChangeSubscriptionPicklist',false);
                            var subscriptionMap = [];
                            subscriptionMap.push({key: "Installment", value: "Installment"});
                            component.set("v.subscriptionMap", "");
                            component.set("v.subscriptionMap", subscriptionMap);
                        }
                        else if(currentPlan == 'Auto Full Pay'){
                            component.set('v.disableChangeSubscriptionPicklist',false);
                            var subscriptionMap = [];
                            subscriptionMap.push({key: "Auto Full Pay", value: "Auto Full Pay"});
                            component.set("v.subscriptionMap", "");
                            component.set("v.subscriptionMap", subscriptionMap);
                        }
                            else{
                                component.set('v.disableChangeSubscriptionPicklist',true);
                                component.set('v.changeOnlyInPerforma',false);
                            }
                        
                    }
                }
            } 
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("checkCurrentDuesSO Error message: " + errors[0].message);
                    }
                } else {
                    alert($A.get("$Label.c.Fon_ContactToAdminErrorMessage"));
                }
            }
        }));
        $A.enqueueAction(action);
    },
   
    isFullPaidCurrentSubcription : function(component, event){
        var currentContactId= component.get('v.recordId');   
        var action = component.get("c.isFullPaidCurrentSubcription");
        action.setParams({contactId : currentContactId});// setting the parameter to apex class method
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {    
                var result = response.getReturnValue();
                if(result!=null){
                    for(var key in result){
                        console.log(parseFloat(key));
                        console.log(result[key]);
                        component.set("v.balanceDue",parseFloat(key));
                        component.set("v.soliList",result[key]);
                    }
                }
                if(component.get("v.balanceDue")>0){//Not Full Paid
                    component.set("v.isCurrentTermNotPaidFull",true);
                }
                else{//Full Paid
                    component.set("v.isCurrentTermNotPaidFull",false);
                    this.isRenewalOrderCreated(component, event);          
                }
            } 
            else if (state === "ERROR") {
                var errors = response.getError();
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
    },
    
    isRenewalOrderCreated : function(component, event){
       
        var currentContactId= component.get('v.recordId');   
        var currentPlan = component.get("v.currentPlan");
        var isCurrentTermNotPaidFull= component.get("v.isCurrentTermNotPaidFull");
        
        var action = component.get("c.isRenewalOrderCreated");
        action.setParams({contactId : currentContactId});// setting the parameter to apex class method
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                var result = response.getReturnValue();
                for(var key in result){
                    component.set("v.balanceDue",result[key]);
                }
                console.log(component.get("v.balanceDue"));
                if(component.get("v.balanceDue")>0){ 
                    component.set('v.disableChangeSubscriptionPicklist',false);
                    if(!isCurrentTermNotPaidFull){
                        component.set("v.isNextYearConvenienceFeeApplied",true);
                    }
                }
                else{  
                    this.checkCurrentDuesSO(component, event);
                }
            } 
            else{
                console.log('Problem in isRenewalOrderCreated function');
            }
        }));
        $A.enqueueAction(action);
    },
    
    //Fetching All Valid Payment Method of contact
    fetchValidPaymentMethod : function(component, event){ 
        var currentContactId= component.get("v.recordId");
        var action = component.get('c.isvalidPaymentMethodAvailable');
        action.setParams({contactId : currentContactId});// setting the parameter to apex class method
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.lstPaymentMethods", response.getReturnValue());
                if(response.getReturnValue()==null){
                    component.set("v.showOldCmp",true)
                }
                
                
            } 
        }));
        $A.enqueueAction(action);
    }, 
    //Fetching Currentm Year Dues
    fetchCurrentYearDues  : function(component, event){
        var currentContactId= component.get("v.recordId");
        var action = component.get("c.fetchCurrentYearDues");
        action.setParams({contactId : currentContactId});// setting the parameter to apex class method
        action.setCallback(this,function(result){   
            if (result.getState() == 'SUCCESS') {
                if(result.getReturnValue()!=null){    
                    component.set("v.lstActiveInstallmentsSubscription",result.getReturnValue());
                    var lstData =  component.get("v.lstActiveInstallmentsSubscription");
                    var totalBalance = 0;
                    for(var obj in lstData){
                        if(lstData[obj].isAutoFullPay){
                            totalBalance = parseFloat(totalBalance) + parseFloat(lstData[obj].balanceRemaining);
                        }
                    }
                    component.set("v.totalBalaceDueAmount",totalBalance);
                }
            }
        });
        $A.enqueueAction(action);
    },
    //Fetching Next Year Dues
    fetchNextYearDues : function(component, event){ 
        var currentContactId= component.get("v.recordId");
        var action = component.get("c.fetchNextYearDues");
        action.setParams({contactId : currentContactId});// setting the parameter to apex class method
        action.setCallback(this,function(result){   
            if (result.getState() == 'SUCCESS') {
                if(result.getReturnValue()!=null){    
                    component.set("v.lstNextYearDues",result.getReturnValue());
                    var lstData =  component.get("v.lstNextYearDues");
                    var totalBalance = 0;
                    for(var obj in lstData){
                        if(lstData[obj].isAutoFullPay){
                            totalBalance = parseFloat(totalBalance) + parseFloat(lstData[obj].balanceRemaining);
                        }
                    }
                    if(totalBalance>0){
                        component.set("v.totalBalaceDueAmount",totalBalance);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    //Fetching all Subscription Plan Picklist value
    fetchSubscriptionPlanPicklist: function(component, event) {
        var action = component.get("c.getSubscriptionPlan");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var subscriptionMap = [];
                for(var key in result){
                    subscriptionMap.push({key: key, value: result[key]});
                }
                component.set("v.subscriptionMap", subscriptionMap);
            }
        });
        $A.enqueueAction(action);
    },
    //Fetching current plan of contact
    fetchCurrentSubscriptionPlan: function(component, event) {
        var currentContactId= component.get("v.recordId");
        var action = component.get("c.getCurrentSubscriptionPlan");
        action.setParams({contactId : currentContactId});// setting the parameter to apex class method
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.selectedValue", result);
                component.set("v.currentPlan", result);
                if(result == 'Installment' || result == 'Auto Full Pay'){
                    component.set("v.isFoundationAutoRenewDisable",false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    showSpinner:function(component){
        component.set("v.IsSpinner",true);
    },
    
    hideSpinner:function(component){
        component.set("v.IsSpinner",false);
    } ,  
    
    createSalesOrderForDonation : function(component, event){
        var convenienceFeeAmt = component.get("v.convenienceFeeAmt");
        var packAmt = component.get("v.packAmtDonation");
        var donationAmt= component.get("v.foundationAmtDonation");
        var paymentMethodId = component.get("v.selectedPayment");
        var currentContactId= component.get("v.recordId");
        var employeeName= component.get("v.employeeName");
        var occupation= component.get("v.occupation");
        var accountType= component.get("v.accountType");
        var isNextYearConvenienceFeeApplied= component.get("v.isNextYearConvenienceFeeApplied");
        var soliList = component.get("v.soliList");
        var duesSoId;
        if(soliList!=null && soliList!=''){
            if(soliList[0].salesOrderId!=null && soliList[0].salesOrderId!=''){
                duesSoId = soliList[0].salesOrderId;
            }
        }
        
      
       
        
        var action = component.get("c.createSalesOrderForDonation");
        action.setParams({isNextYearConvenienceFeeApplied : isNextYearConvenienceFeeApplied,convenienceFeeAmt : convenienceFeeAmt , packAmt : packAmt , foundationDonationAmt : donationAmt, paymentMethodId: paymentMethodId, contactId : currentContactId, employeeName : employeeName, occupation : occupation, accountType : accountType, duesSoId : duesSoId});// setting the parameter to apex class method
        action.setCallback(this,function(result){   
            if (result.getState() == 'SUCCESS') {
                if(result.getReturnValue()!=null){   
                    this.payDonationSo(component, event,result.getReturnValue());
                }
                else{
                    this.hideSpinner(component);
                    alert($A.get("$Label.c.Fon_ContactToAdminErrorMessage"));
                }
            }
            else if (state === "ERROR") {
                this.hideSpinner(component);
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
    },
    
    payDonationSo : function(component, event, donationSoId){
        var soliList = component.get("v.soliList");
        var newSubscriptionPlan = component.get("v.selectedValue");
        var isFoundationDonationRenewal = component.get("v.isFoundationDonationRenewal");
        var isCurrentYearDuesNotPaid = component.get("v.isCurrentYearDuesNotPaid");
       
        
       
        //  alert(newSubscriptionPlan);
       var action = component.get("c.payDonationSo");
        action.setParams({soID : donationSoId, newSubscriptionPlan : newSubscriptionPlan,isFoundationDonationRenewal: isFoundationDonationRenewal,isCurrentTermNotPaidFull : isCurrentYearDuesNotPaid});
        action.setCallback(this,function(result){   
            var state = result.getState();
            if (state == 'SUCCESS') {
                if(result.getReturnValue()!=null){    
                    if(component.get("v.payDonationDuesSo")){
                        component.set("v.receiptLinelst",result.getReturnValue());
                        var ReturnValue= result.getReturnValue();
                        if(soliList[0].invoiceId!=null && soliList[0].invoiceId!=''){
                            var action = component.get("c.createEpaymentLine");
                            action.setParams({invID : soliList[0].invoiceId,paymentMethodId : component.get("v.selectedPayment")});// setting the parameter to apex class method
                            action.setCallback(this, $A.getCallback(function (result) {
                                var state = result.getState();
                                if (state == 'SUCCESS') {
                                    if(result.getReturnValue()!=null){    
                                        var action = component.get("c.payInvoiceDues");
                                        action.setParams({epayId : result.getReturnValue(),newSubscriptionPlan : newSubscriptionPlan ,isFoundationDonationRenewal : isFoundationDonationRenewal,paymentMethodId : component.get("v.selectedPayment")});
                                        action.setCallback(this, $A.getCallback(function (result) {
                                            var state = result.getState();
                                            if (state == 'SUCCESS') {
                                                if(result.getReturnValue()!=null){    
                                                    this.hideSpinner(component);
                                                    component.set("v.payDonationDuesSo",false);
                                                    var ReturnValue1= result.getReturnValue();
                                                    component.set("v.duesReceiptLinelst",result.getReturnValue());
                                                    component.set("v.ConfirmationNumber",ReturnValue[0].OrderApi__Receipt__r.Name+', '+ReturnValue1[0].OrderApi__Receipt__r.Name);
                                                    component.set("v.stepIndex","3");
                                                    component.set("v.isfirstPage",false); 
                                                    component.set("v.isSecondPage",false); 
                                                    component.set("v.isThirdPage",true);
                                                }
                                                else{
                                                    this.hideSpinner(component);
                                                    alert($A.get("$Label.c.Fon_PaymentNotSuccesfull"));
                                                }
                                            }
                                            else if (state === "ERROR") {
                                                this.hideSpinner(component);
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
                                        this.hideSpinner(component);
                                        alert($A.get("$Label.c.Fon_PaymentNotSuccesfull"));
                                    }
                                }
                                else if (state === "ERROR") {
                                    this.hideSpinner(component);
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
                            action.setParams({soID : soliList[0].salesOrderId, paymentMethodId : component.get("v.selectedPayment"),newSubscriptionPlan : newSubscriptionPlan,isFoundationDonationRenewal : isFoundationDonationRenewal});// setting the parameter to apex class method
                            action.setCallback(this, $A.getCallback(function (result) {
                                var state = result.getState();
                                if (state == 'SUCCESS') {
                                    if(result.getReturnValue()!=null){    
                                        this.hideSpinner(component);
                                        component.set("v.payDonationDuesSo",false);
                                        var ReturnValue1= result.getReturnValue();
                                        component.set("v.duesReceiptLinelst",result.getReturnValue());
                                        component.set("v.ConfirmationNumber",ReturnValue[0].OrderApi__Receipt__r.Name+', '+ReturnValue1[0].OrderApi__Receipt__r.Name);
                                        component.set("v.stepIndex","3");
                                        component.set("v.isfirstPage",false); 
                                        component.set("v.isSecondPage",false); 
                                        component.set("v.isThirdPage",true);
                                    }
                                    else{
                                        this.hideSpinner(component);
                                        alert($A.get("$Label.c.Fon_PaymentNotSuccesfull"));
                                    }
                                }
                                else if (state === "ERROR") {
                                    this.hideSpinner(component);
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
                    else{
                        this.hideSpinner(component);
                        var ReturnValue= result.getReturnValue();
                        component.set("v.ConfirmationNumber",ReturnValue[0].OrderApi__Receipt__r.Name);
                        component.set("v.receiptLinelst",ReturnValue);
                        component.set("v.stepIndex","3");
                        component.set("v.isfirstPage",false); 
                        component.set("v.isSecondPage",false); 
                        component.set("v.isThirdPage",true);
                    }
                }
                else{
                    this.hideSpinner(component);
                    alert($A.get("$Label.c.Fon_PaymentNotSuccesfull"));
                }
            }
            else if (state === "ERROR") {
                this.hideSpinner(component);
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
    
})