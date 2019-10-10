({
	createMemo : function(component,event,helper) {
		var action = component.get("c.createCreditMemo");
        action.setParams({
            receiptId : component.get("v.receiptId")
        });
        action.setCallback(this,function(result){
            $A.util.removeClass(component.find('mainWrapperDiv'),'hidden');
            if (result.getState() == 'SUCCESS') {
                this.showSuccessToastMSG(component,event,helper);
            }else if (result.getState() === 'ERROR') {
                this.showErrorToastMSG(component,event,helper);
            }
        });
		$A.enqueueAction(action);
	},
    showSuccessToastMSG : function (component,event,helper) {
        $A.util.removeClass(component.find('successNotifyDiv'), 'slds-hide');
        window.setTimeout($A.getCallback(function() {
            $A.util.addClass(component.find('successNotifyDiv'), 'slds-hide');
        }), 5000);
        this.goBackToReceipt(component,event,helper);
    },
    showErrorToastMSG : function (component,event,helper) {
        $A.util.removeClass(component.find('errorNotifyDiv'), 'slds-hide');
        /*
        window.setTimeout($A.getCallback(function() {
            $A.util.addClass(component.find('errorNotifyDiv'), 'slds-hide');
        }), 12000);
        */
        //this.goBackToReceipt(component,event,helper);
    },
    goBackToReceipt : function (component,event,helper) {
        window.setTimeout($A.getCallback(function() {
            //$A.util.addClass(component.find('successNotifyDiv'), 'slds-hide');
            if( (typeof sforce != "undefined") && sforce && (!!sforce.one) ) {
                sforce.one.navigateToURL("/lightning/r/OrderApi__Receipt__c/"+component.get('v.receiptId')+'/view?0.source=alohaHeader');
            }else {
                window.location.href = "/"+component.get('v.receiptId');
            }
        }), 1000);
    }
})