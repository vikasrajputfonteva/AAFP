({
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
                        totalSalesPrice = totalSalesPrice + 0.00;
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
    addAnotherInvoice1 : function(component, event, helper){
        var AFFPID = component.find("aafpTXT").get("v.value");
        var InvoiceId = component.find("invoiceTXT").get("v.value");
        var action = component.get("c.fetchSalesOrder1");
        action.setParams({
            AFFPId : AFFPID,
            InvoiceId: InvoiceId
        });
        action.setCallback(this,function(result){   
            if (result.getState() == 'SUCCESS') {
                var lstSalesOrder = component.get("v.lstSalesOrder");
                if(result.getReturnValue()!=null){     
                    if(result.getReturnValue().strMSG == $A.get("$Label.c.Fon_Open")){
                        component.set('v.toastwindowMain',true);
                        var staticLabel = $A.get("$Label.c.Fon_NoAvailableSO");
                        component.set("v.msg",staticLabel);
                        component.set("v.AFFPID","");
                        component.set("v.INVOICEID","");
                        component.set("v.disable","true");
                        window.setTimeout(
                            $A.getCallback(function () {
                                component.set("v.toastwindowMain", false);
                                component.set("v.msg", "");
                            }), 2000
                        ); 
                        
                    }
                    else if(result.getReturnValue().strMSG == $A.get("$Label.c.Fon_Paid")){
                        component.set('v.toastwindowMain',true);
                        var staticLabel = $A.get("$Label.c.Fon_PaidSO");
                        component.set("v.msg",staticLabel);
                        component.set("v.AFFPID","");
                        component.set("v.INVOICEID","");
                        component.set("v.disable","true");
                        window.setTimeout(
                            $A.getCallback(function () {
                                component.set("v.toastwindowMain", false);
                                component.set("v.msg", "");
                            }), 2000
                        ); 
                    }
                        else if(result.getReturnValue().strMSG == $A.get("$Label.c.Fon_Aafp")){
                            component.set('v.toastwindowMain',true);
                            var staticLabel = $A.get("$Label.c.Fon_ContactToAAFP");
                            component.set("v.msg",staticLabel);
                            component.set("v.AFFPID","");
                            component.set("v.INVOICEID","");
                            component.set("v.disable","true");
                            window.setTimeout(
                                $A.getCallback(function () {
                                    component.set("v.toastwindowMain", false);
                                    component.set("v.msg", "");
                                }), 2000
                            ); 
                        }
                            else{
                                var isDuplicate = "false";
                                for(var obj in lstSalesOrder){
                                    if(lstSalesOrder[obj].strSOID == result.getReturnValue().strSOID){
                                        component.set('v.toastwindowMain',true);
                                        component.set("v.msg",$A.get("$Label.c.Fon_InvInlist"));
                                        isDuplicate = "true";
                                        window.setTimeout(
                                            $A.getCallback(function () {
                                                component.set("v.toastwindowMain", false);
                                                component.set("v.msg", "");
                                            }), 2000
                                        ); 
                                    }
                                }
                                if(isDuplicate=="false"){
                                    lstSalesOrder.push(result.getReturnValue());
                                    component.set("v.lstSalesOrder",lstSalesOrder);
                                    helper.calcultetotalInvoiceAmt(component, event, helper);
                                    component.set("v.AFFPID","");
                                    component.set("v.INVOICEID","");
                                    component.set("v.disable","true");
                                }
                            }
                }
                else{
                    component.set('v.toastwindowMain',true);
                    var staticLabel = $A.get("$Label.c.Fon_NotFoundSalesOrder");
                    component.set("v.msg",staticLabel);
                    component.set("v.AFFPID","");
                    component.set("v.INVOICEID","");
                    component.set("v.disable","true");
                    window.setTimeout(
                        $A.getCallback(function () {
                            component.set("v.toastwindowMain", false);
                            component.set("v.msg", "");
                        }), 2000
                    ); 
                }
                
                // var cmpEvent = component.getEvent("Fon_QuickPayComponentEvent"); 
                //cmpEvent.setParams({"lstSalesOrder" : component.get("v.lstSalesOrder")});
                //cmpEvent.fire(); 
                //this.showToastMessage("success", "Success!", "The Membership has been cancelled successfully.");
            }else {
                
                component.set('v.toastwindowMain',true);
                var staticLabel = $A.get("$Label.c.Fon_NotFoundSalesOrder");
                component.set("v.msg",staticLabel);
                component.set("v.AFFPID","");
                component.set("v.INVOICEID","");
                component.set("v.disable","true");
                window.setTimeout(
                    $A.getCallback(function () {
                        component.set("v.toastwindowMain", false);
                        component.set("v.msg", "");
                    }), 2000
                ); 
                //this.showToastMessage("error", "Error!", "Something went wrong. Please contact to your admin.");
            }
        });
        $A.enqueueAction(action);
    }
})