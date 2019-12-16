({
    init : function(component, event, helper) {
        helper.fetchSalesOrderData(component, event, helper);
    },
    
    closeModalView : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }, 
    
    changeValue1 : function(component, event, helper) {
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
        
        if(objSOWrapper.lstReceiptLineItem.length > 0){
            var isOneReceiptLineSelected = false;
            var  receiptLineforNonMembershipItem = false;
            for(var receiptLine in objSOWrapper.lstReceiptLineItem){			
                var eachLine = objSOWrapper.lstReceiptLineItem[receiptLine];
                if(eachLine.isChecked){
                    isOneReceiptLineSelected = true;
                }
                if(eachLine.isChecked && eachLine.isNonMembershipItem){
                    receiptLineforNonMembershipItem = true;
                }
            }
            if(!isOneReceiptLineSelected){
                helper.showToastMessage("warning", "Warning!",   $A.get("$Label.c.Fon_PleaseSelectAtLeastOneRecord"));
                return;
            }
            
            for(var receiptLine in objSOWrapper.lstReceiptLineItem){
                var eachLine = objSOWrapper.lstReceiptLineItem[receiptLine];
                if(eachLine.isChecked && eachLine.isNonMembershipItem){
                    //alert(eachLine.receiptLineId);
                    //var selct = component.find(eachLine.receiptLineId).get("v.value"); 
                    
                   // alert(selct);
                   // return;
                }
                
                /*  var selectedSubscription = component.find(objSOWrapper.lstReceiptLineItem[receiptLine]).get("v.value");
                if(selectedSubscription ==undefined || selectedSubscription == 'none'){
                    helper.showToastMessage("warning", "Warning!",  "Please select the value to cancel the subscription");
                    return;
                }*/
            }
           
         //  alert('work in progress');
          //  return;
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
                if(eachLine.refundAmount > eachLine.netAmount){
                    isValidReceiptLine = false;
                    eachLine.isNotValidRefund = true;
                    //helper.showToastMessage("warning", "Warning!", "Entered refund can not be greator than actual total amount: "+eachLine.objReceiptLine.OrderApi__Total__c);
                    //break;
                }
            }
            if(isValidReceiptLine){
                var isRefundValidatedOneTime = component.get("v.isRefundValidatedOneTime");
                /*  if(objSOWrapper.isRefundReceiptExist && !isRefundValidatedOneTime){
                    $A.util.toggleClass(component.find("secondModalFrame"), 'slds-hide');
                    $A.util.toggleClass(component.find("mainModalFrame"), 'slds-hide');
                    component.set("v.isRefundValidatedOneTime", true);
                    return;
                }*/
                component.set("v.spinner",true);
                helper.refundReceipt(component, event, helper);
            }
            else{
                component.set("v.objSOWrapper",objSOWrapper);
            }
        }
    },
    
    cancel : function(component, event, helper) {
        helper.redirect(component, event, helper);
    },
       
    onChange : function(component, event, helper) {
        if(event.getSource().get("v.value")){}
        else{
            var key = event.getSource().get("v.name");
            var receiptLineIdVScancelSubscription = component.get("v.receiptLineIdVScancelSubscription");
            receiptLineIdVScancelSubscription[key]="false";
        }
    } ,
    
    handleOnChange : function(component, event, helper) {
        var val = event.getSource().get("v.value");
        var key = event.getSource().get("v.name");
        var receiptLineIdVScancelSubscription = component.get("v.receiptLineIdVScancelSubscription");
        receiptLineIdVScancelSubscription[key]=val;
    },
})