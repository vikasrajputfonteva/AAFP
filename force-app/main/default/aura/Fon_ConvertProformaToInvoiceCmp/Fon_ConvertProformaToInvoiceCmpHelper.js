({
    navigateBackToHomePage : function(component, event, helper) {
        component.get("v.showError",false);
        window.setTimeout($A.getCallback(function() {
            if( (typeof sforce != "undefined") && sforce && (!!sforce.one) ) {
                sforce.one.navigateToURL("/lightning/r/OrderApi__Sales_Order__c/"+component.get('v.recordId')+'/view?0.source=alohaHeader');
            }else {
                window.location.href = "/"+component.get('v.recordId');
            }
        }), 1000);
    }
})