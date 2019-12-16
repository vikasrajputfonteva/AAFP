({
    reloadLocation : function(component, event, helper) {
        var objId = component.get("v.selectedPayment");
        window.open(decodeURIComponent(component.get("v.returnURL"))+'?id='+objId,'_top');
    }
})