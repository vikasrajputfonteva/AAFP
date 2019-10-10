({
	doInit : function(component,event,helper) {
        var receiptId = component.get("v.receiptId");
        if (component.get('v.actionType') === 'creditMemo'){
            //$('#mainWrapper').addClass('hidden');
            $A.util.removeClass(component.find('mainWrapperDiv'),'hidden');        
            helper.createMemo(component,event,helper);
        }else {
            //helper.creditMemo(component,event,helper);
        }
	},
    goBack : function (component,event,helper) {
        helper.goBackToReceipt(component);
	}
})