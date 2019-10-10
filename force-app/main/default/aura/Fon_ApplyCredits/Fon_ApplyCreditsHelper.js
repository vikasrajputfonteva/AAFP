({
    navigateBack : function(component, event, helper) {
        window.setTimeout($A.getCallback(function() {
            if( (typeof sforce != "undefined") && sforce && (!!sforce.one) ) {
                sforce.one.back(true);
            }else {
                window.location.href = "/a1F"; 
            }
        }), 1000);
    }
})