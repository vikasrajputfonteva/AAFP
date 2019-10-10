({
    init : function(component, event, helper) {
        helper.fetchSalesOrderData(component, event, helper);
    },
    closeModalView : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }, 
    changeValue : function(component, event, helper) {
        var selectedOption = component.find("selectedOption").get("v.value");
        if(selectedOption.trim() == 'none'){
            component.set("v.isOptionSelected",true);
            return;
        }
        component.set("v.isOptionSelected",false);
    },
    
    process : function(component, event, helper) {
        
        var objSOWrapper = component.get("v.objSOWrapper");
        
        var objInvoiceWrapper = component.get("v.objInvoiceWrapper");
        var isSingleInvoiceExisted = component.get("v.isSingleInvoiceExisted");
        if(isSingleInvoiceExisted){
            var isOneInvoiceLineSelected = false;
            for(var invoiceLine in objInvoiceWrapper.lstInvoiceLineItem){
                var eachLine = objInvoiceWrapper.lstInvoiceLineItem[invoiceLine];
                if(eachLine.isChecked){
                    isOneInvoiceLineSelected = true;
                }
            }
            if(!isOneInvoiceLineSelected){
                helper.showToastMessage("warning", "Warning!", $A.get("$Label.c.Fon_PleaseSelectAtLeastOneRecord"));
                return;
            }
            var isValidInvoiceLine = true;
            for(var invoiceLine in objInvoiceWrapper.lstInvoiceLineItem){
                var eachLine = objInvoiceWrapper.lstInvoiceLineItem[invoiceLine];
                eachLine.isNotValidQuantity = false;
                eachLine.isNotValidRefund = false;
                if(eachLine.objInvoiceLine.OrderApi__Quantity__c == 0){
                    isValidInvoiceLine = false;
                    eachLine.isNotValidQuantity = true;
                    //helper.showToastMessage("warning", "Warning!", "Quantity can not be set as 0.");
                    //break;
                }
                if(eachLine.objInvoiceLine.OrderApi__Quantity__c > eachLine.quantity){
                    isValidInvoiceLine = false;
                    eachLine.isNotValidQuantity = true;
                    //helper.showToastMessage("warning", "Warning!", "Entered quantity can not be greator than actual quantity: "+eachLine.quantity);
                    //break;
                }
                if(eachLine.refundAmount == 0 ){
                    //isValidInvoiceLine = false;
                    //helper.showToastMessage("warning", "Warning!", "Refund Amount can not be set as 0.");
                    //break;
                }
                if(eachLine.refundAmount > eachLine.objInvoiceLine.OrderApi__Total__c){
                    isValidInvoiceLine = false;
                    eachLine.isNotValidRefund = true;
                    //helper.showToastMessage("warning", "Warning!", "Entered refund can not be greator than actual total amount: "+eachLine.objInvoiceLine.OrderApi__Total__c);
                    //break;
                }
                
            }
            if(isValidInvoiceLine){
                component.set("v.spinner",true);
            	helper.refundInvoice(component, event, helper);
            }else{
                component.set("v.objInvoiceWrapper",objInvoiceWrapper);
            }
            
        }else if(objSOWrapper.lstReceiptLineItem.length > 0){
            var isOneReceiptLineSelected = false;							
            for(var receiptLine in objSOWrapper.lstReceiptLineItem){			
                var eachLine = objSOWrapper.lstReceiptLineItem[receiptLine];
                //alert(eachLine.isChecked);
                if(eachLine.isChecked){
                    isOneReceiptLineSelected = true;
                }
            }
            if(!isOneReceiptLineSelected){
                helper.showToastMessage("warning", "Warning!",   $A.get("$Label.c.Fon_PleaseSelectAtLeastOneRecord"));
                return;
            }
            var isValidReceiptLine = true;
            for(var receiptLine in objSOWrapper.lstReceiptLineItem){
                var eachLine = objSOWrapper.lstReceiptLineItem[receiptLine];                    
                eachLine.isNotValidQuantity = false;
                eachLine.isNotValidRefund = false;
                if(eachLine.objReceiptLine.OrderApi__Quantity__c == 0){
                    isValidReceiptLine = false;
                    eachLine.isNotValidQuantity = true;
                    //helper.showToastMessage("warning", "Warning!", "Quantity can not be set as 0.");
                    //break;
                }
                if(eachLine.objReceiptLine.OrderApi__Quantity__c > eachLine.quantity){
                    isValidReceiptLine = false;
                    eachLine.isNotValidQuantity = true;
                    //helper.showToastMessage("warning", "Warning!", "Entered quantity can not be greator than actual quantity: "+eachLine.quantity);
                    //break;
                }
                if(eachLine.refundAmount == 0){
                    //isValidReceiptLine = false;
                    //helper.showToastMessage("warning", "Warning!", "Refund Amount can not be set as 0.");
                    //break;
                }
                if(eachLine.refundAmount > eachLine.objReceiptLine.OrderApi__Total__c){
                    isValidReceiptLine = false;
                    eachLine.isNotValidRefund = true;
                    //helper.showToastMessage("warning", "Warning!", "Entered refund can not be greator than actual total amount: "+eachLine.objReceiptLine.OrderApi__Total__c);
                    //break;
                }
            }
            if(isValidReceiptLine){
                var isRefundValidatedOneTime = component.get("v.isRefundValidatedOneTime");
                if(objSOWrapper.isRefundReceiptExist && !isRefundValidatedOneTime){
                    $A.util.toggleClass(component.find("secondModalFrame"), 'slds-hide');
                    $A.util.toggleClass(component.find("mainModalFrame"), 'slds-hide');
                    component.set("v.isRefundValidatedOneTime", true);
                    return;
                }
                component.set("v.spinner",true);
                helper.refundReceipt(component, event, helper);
            }else{
                component.set("v.objSOWrapper",objSOWrapper);
            }
            
        }
    },
    
    cancel : function(component, event, helper) {
        helper.redirect(component, event, helper);
    },
    
    selectInvoiceAndContinue : function(component, event, helper) {
        //alert('selectInvoiceAndContinue');
        var objSOWrapper = component.get("v.objSOWrapper");
        for(var eachInvoice in objSOWrapper.lstInvoice){
            //alert(objSOWrapper.lstInvoice[eachInvoice].isChecked);
            if(objSOWrapper.lstInvoice[eachInvoice].isChecked){
                var objInvoice = objSOWrapper.lstInvoice[eachInvoice];
                component.set("v.objInvoiceWrapper",objInvoice);
                component.set("v.isMultiInvoiceExistedWithNoSelect",false);
                component.set("v.isSingleInvoiceExisted",true);
                break;
            }
        }
    },
    
    checkRefundReceiptExisted : function(component, event, helper) {
        var objSOWrapper = component.get("v.objSOWrapper");
        if(objSOWrapper.isRefundReceiptExist){
            $A.util.toggleClass(component.find("secondModalFrame"), 'slds-hide');
            $A.util.toggleClass(component.find("mainModalFrame"), 'slds-hide');
            return;
        }
    }
    
})