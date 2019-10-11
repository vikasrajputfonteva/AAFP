({
    doInit : function(component, event, helper){
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        component.set("v.cbaseURL", baseURL);
    },
    keyPressCheck : function(component, event, helper) {
        var AFFPID = component.find("aafpTXT").get("v.value");
        var InvoiceId = component.find("invoiceTXT").get("v.value");
        
        /*if(AFFPID && InvoiceId){
                if(AFFPID.length == 7 && InvoiceId.length == 7){
                    component.set("v.disable","false");
                }
                else {
                    component.set("v.disable","true");
                }
            }
            else if(AFFPID==''){
                component.set("v.disable","true");
            }
                else if(InvoiceId==''){
                    component.set("v.disable","true");
                }*/
        
        if(AFFPID && InvoiceId){
            if(AFFPID.length > 0 && InvoiceId.length > 0){
                component.set("v.disable","false");
            }
            else {
                component.set("v.disable","true");
            }
        }
        else if(AFFPID==''){
            component.set("v.disable","true");
        }
            else if(InvoiceId==''){
                component.set("v.disable","true");
            }
    },
    addAnotherInvoice : function(component, event, helper){
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
                        //alert(staticLabel);
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
                        //alert(staticLabel);
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
                            //alert(staticLabel);
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
                                        //alert("Invoice already in list.");
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
                }else{
                    component.set('v.toastwindowMain',true);
                    var staticLabel = $A.get("$Label.c.Fon_NotFoundSalesOrder");
                    //alert(staticLabel);
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
            }
            else {
                //alert('=======');
                console.log(result.getState());
                component.set('v.toastwindowMain',true);
                var staticLabel = $A.get("$Label.c.Fon_NotFoundSalesOrder");
                // alert(staticLabel);
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