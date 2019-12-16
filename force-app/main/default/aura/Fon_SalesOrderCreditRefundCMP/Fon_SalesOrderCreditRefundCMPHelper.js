({
    fetchSalesOrderData : function(component, event, helper) {
        var action = component.get("c.fetchSOByCreditAndRefundLine");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this,function(result){            
            if (result.getState() == 'SUCCESS') {
                var objSOWrapper = result.getReturnValue();
                component.set("v.objSOWrapper",objSOWrapper);
                if(objSOWrapper.lstInvoice.length > 1){
                    component.set("v.isMultiInvoiceExistedWithNoSelect",true);
                }
                if(objSOWrapper.lstInvoice.length == 0 && objSOWrapper.lstReceiptLineItem.length == 0){
                    component.set("v.noRecordFound",true);
                }
                else if(objSOWrapper.lstInvoice.length == 1){
                    var objInvoiceWrapper;
                    for(var eachInvoice in objSOWrapper.lstInvoice){
                        objInvoiceWrapper = objSOWrapper.lstInvoice[eachInvoice];
                        component.set("v.objInvoiceWrapper",objInvoiceWrapper);
                        component.set("v.isSingleInvoiceExisted",true);
                        break;
                    }
                }else if(objSOWrapper.lstInvoice.length == 0 && objSOWrapper.lstReceiptLineItem.length > 0){
                    component.set("v.isOnlyReceiptExisted",true);
                }
                
            }else{
                alert($A.get("$Label.c.Fon_ContactToAAFP"));
            }
        });
        $A.enqueueAction(action);
    },
    
    showToastMessage : function(type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            mode: 'dismissible',
            duration:'2000',
            title: title,
            message: message
        });
        toastEvent.fire();
    },
    
    refundReceipt : function(component, event, helper) {
        var picklistValue= component.find("selectedOption").get("v.value");
        var lstId = component.get("v.lstId");
        var lstReceiptLine = component.get("v.lstReceiptLine");
        var objSOWrapper = component.get("v.objSOWrapper");
        var receiptLineIdVScancelSubscription = component.get("v.receiptLineIdVScancelSubscription");
        
        var action = component.get("c.refundReceiptLine");
        for(var receiptLine in objSOWrapper.lstReceiptLineItem){
            if(objSOWrapper.lstReceiptLineItem[receiptLine].isChecked){
                lstId.push(objSOWrapper.lstReceiptLineItem[receiptLine].objReceiptLine.Id);
                var objReceiptLine = {
                    'sobjectType' : 'OrderApi__Receipt_Line__c',
                    'Id' : objSOWrapper.lstReceiptLineItem[receiptLine].objReceiptLine.Id,
                    'Fon_Refund_Quantity__c' : objSOWrapper.lstReceiptLineItem[receiptLine].objReceiptLine.OrderApi__Quantity__c,
                    'Fon_Refund_Amount__c' : objSOWrapper.lstReceiptLineItem[receiptLine].refundAmount
                };
                lstReceiptLine.push(objReceiptLine);
            }
        }
        if(picklistValue=='createcredit'){
            action.setParams({
                lstId : lstId,
                isReceiptLine : true,
                isCreateCredit : true,
                lstReceiptLine : lstReceiptLine,
                receiptLineIdVScancelSubscription : receiptLineIdVScancelSubscription
            });
        }
        else{
            action.setParams({
                lstId : lstId,
                isReceiptLine : true,
                isCreateCredit : false,
                lstReceiptLine : lstReceiptLine,
                receiptLineIdVScancelSubscription : receiptLineIdVScancelSubscription
            }); 
        }
        action.setCallback(this,function(result){            
            if (result.getState() == 'SUCCESS') {
                var objSOWrapper = result.getReturnValue();
                this.showToastMessage("success", "Success!",  $A.get("$Label.c.Fon_RefundCreatedSuccessfully"));
                this.redirect(component, event, helper);
            }else{
                this.showToastMessage("error", "Error!", $A.get("$Label.c.Fon_ContactToAAFP"));
            }
            component.set("v.spinner",false);
        });
        $A.enqueueAction(action);
    },
    
    redirect : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/r/OrderApi__Sales_Order__c/"+component.get("v.recordId")+"/view?0.source=alohaHeader"
        });
        urlEvent.fire();
    }
})