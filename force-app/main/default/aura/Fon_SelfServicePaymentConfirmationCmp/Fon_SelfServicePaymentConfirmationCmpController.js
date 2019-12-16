({
    doInit : function(component, event, helper) {
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        var isComingFromBackend = component.get("v.isComingFromBackend");
        if(isComingFromBackend){
            component.set("v.btnLabel",$A.get("$Label.c.Fon_BackToContact"));
        }

        component.set('v.today', today);
        var confirmationNumber = component.get("v.ConfirmationNumber");
        var receiptLinelst = component.get("v.receiptLinelst");
        var currentContactId= component.get("v.recordId");
        var duesReceiptLinelst = component.get("v.duesReceiptLinelst");
        var selectedValue = component.get("v.selectedValue");
        if(selectedValue=='Installment'){
            component.set("v.isInstallment",true);
        }
        else{
            component.set("v.isInstallment",false);
        }
        var action = component.get("c.sendEmailToContact");
        action.setParams({duesReceiptLinelst :duesReceiptLinelst,receiptLinelst : receiptLinelst,confirmationNumber : confirmationNumber,contactId : currentContactId});// setting the parameter to apex class method
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            console.log('-----jmdstate--'+state);
            if (state === "SUCCESS") {
                console.log('-----response.getReturnValue()--'+response.getReturnValue());
                if(response.getReturnValue()){
                    console.log('-----'+response.getReturnValue());
                    component.set("v.totalAmount",response.getReturnValue());
                }
            } 
            else{
                alert('error');
            }
        }));
        $A.enqueueAction(action);
    },
    finishHandler : function(component, event, helper) {
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        var isComingFromBackend = component.get("v.isComingFromBackend");
        var currentContactId= component.get("v.recordId");
        if(isComingFromBackend){
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": currentContactId
            });
            navEvt.fire();
        }
        else{
            window.open(baseURL+"/s"+$A.get("$Label.c.Fon_PortalPage"), '_self');
        }
    }
})