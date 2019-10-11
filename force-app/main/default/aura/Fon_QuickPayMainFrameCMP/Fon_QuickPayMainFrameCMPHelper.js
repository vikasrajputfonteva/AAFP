({
    fetchSalesOrder : function(component, event, helper) {
        var action = component.get("c.fetchSalesOrder");
        action.setCallback(this,function(result){            
            if (result.getState() == 'SUCCESS') {
                component.set("v.lstSalesOrder",result.getReturnValue());
                
                //this.showToastMessage("success", "Success!", "The Membership has been cancelled successfully.");
            }else {
                //this.showToastMessage("error", "Error!", "Something went wrong. Please contact to your admin.");	
            }
        });
        $A.enqueueAction(action);
    },
    instanceSalesOrderLst : function(component, event, helper) {
        var action = component.get("c.fetchSalesOrderList");
        action.setCallback(this,function(result){            
            if (result.getState() == 'SUCCESS') {
                alert(result.getReturnValue());
                component.set("v.lstSalesOrder",result.getReturnValue());
            }else {
                
            }
        });
        $A.enqueueAction(action);
    },
    calcultetotalInvoiceAmt : function(component, event, helper) {
        var totalInvoiceAmount = parseFloat("0.00");
        var lstSalesOrder = component.get("v.lstSalesOrder");
        for(var eachSO in lstSalesOrder){
            var totalSalesPrice = parseFloat("0.00");
            var objSalesOrder = lstSalesOrder[eachSO];
            for(var eachSOLI in objSalesOrder.lstSOLI){
                var totalAmt = objSalesOrder.lstSOLI[eachSOLI].salesPriceAmount
                if(objSalesOrder.lstSOLI[eachSOLI].isPACItem){
                    if(isNaN(parseFloat(totalAmt))){
                        totalSalesPrice = totalSalesPrice + 0;
                    }else{
                        totalSalesPrice = totalSalesPrice + parseFloat(totalAmt);
                    }
                }else if(objSalesOrder.lstSOLI[eachSOLI].isFoundationDonation){
                    totalSalesPrice = totalSalesPrice + parseFloat(totalAmt);
                }else{
                    totalSalesPrice = totalSalesPrice + parseFloat(totalAmt);
                }
            }
            objSalesOrder.totalAmount = totalSalesPrice + objSalesOrder.invoicesTotalDueAmount;
            totalInvoiceAmount = totalInvoiceAmount + objSalesOrder.totalAmount;
        }
        
        component.set("v.lstSalesOrder",lstSalesOrder);
        component.set("v.totalInvoiceAmount",totalInvoiceAmount);
    },
    validateAndSubmitSalesOrder : function(component, event, helper) {
        var isAllSalesOrderValidated = true;
        var lstSalesOrder = component.get("v.lstSalesOrder");
        for(var eachSO in lstSalesOrder){
            var totalSalesPrice = parseFloat("0.00");
            var objSalesOrder = lstSalesOrder[eachSO];
            for(var eachSOLI in objSalesOrder.lstSOLI){
                var totalAmt = objSalesOrder.lstSOLI[eachSOLI].salesPriceAmount;
                if(objSalesOrder.lstSOLI[eachSOLI].isPACItem && !isNaN(parseFloat(totalAmt)) && totalAmt != 0.00){
                    if(!objSalesOrder.lstSOLI[eachSOLI].strEmployeeName || !objSalesOrder.lstSOLI[eachSOLI].strOccupation || isNaN(parseFloat(totalAmt))){
                        objSalesOrder.strBGColor = 'red';
                        isAllSalesOrderValidated = false;
                    }else{
                        objSalesOrder.strBGColor = 'whitesmoke';
                    }
                }
            }
        }
        component.set("v.lstSalesOrder",lstSalesOrder);
        if(isAllSalesOrderValidated){
            this.synchUISalesOrder(component, event, helper);
        }else{
            var spinner = component.find("quickPaySpinner");
            $A.util.toggleClass(spinner, "slds-hide");
            component.set("v.submitBtnDisable",false);
            //alert('Please enter required information');
        }
    },
    synchUISalesOrder : function(component, event, helper) {
        var strPayeeEmailId = component.get("v.payeeEmail");
        var lstSalesOrder = component.get("v.lstSalesOrder");
        var action = component.get("c.manageSalesOrderAndInvoice");
        var strJOSN = JSON.stringify(lstSalesOrder);
        console.log(strJOSN);
        action.setParams({
            'lstSalesOrder' : strJOSN,
            'strPayeeEmailId' : strPayeeEmailId
        });
        action.setCallback(this,function(result){            
            if (result.getState() == 'SUCCESS') {
                //alert('SUCCESS');
                //component.set("v.submitBtnDisable",true);
                // window.open("https://www.google.com", '_self');
                this.gotoCheckOutPage(component, event, helper, result.getReturnValue());
                //  window.open("https://fontevadev-fontevacustomer-160ec05bb8f.cs11.force.com/aafp/s/store#/store/checkout/"+urlValue, '_target');
            }else {
                var theme = component.find("toast-theme");
                component.set('v.toastwindowMain',true);
                $A.util.addClass(theme, "slds-theme_error");
                component.set("v.msg",'Contact To Admin');
                //alert('ERROR'+result.getError()[0].message);
                component.set("v.submitBtnDisable",false);
                window.setTimeout(
                    $A.getCallback(function () {
                        component.set("v.toastwindowMain", false);
                        component.set("v.msg", "");
                    }), 2000
                );
            }
            var spinner = component.find("quickPaySpinner");
            $A.util.toggleClass(spinner, "slds-hide");
            
        });
        $A.enqueueAction(action);
    },
    gotoCheckOutPage : function (component, event, helper, urlValue) {
        var action = component.get("c.isSingleInvoice");
        action.setParams({
            'ids' : urlValue
        });
        action.setCallback(this,function(result){            
            if (result.getState() == 'SUCCESS') {
                if(result.getReturnValue()){
                    //Fon_baseUrlForCommunity
                     window.open(component.get("v.cbaseURL")+"/s/store#/store/invoice_checkout/"+urlValue, '_self');
                }
                else{
                    window.open(component.get("v.cbaseURL")+"/s/store#/store/checkout/"+urlValue, '_self');
                }
            }
        });
        $A.enqueueAction(action);
    }
})