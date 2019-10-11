({
    doInit : function(component, event, helper) {
        var compEvent = $A.get('e.FDService:SparkPlugLoadedEvent');
        compEvent.setParams({extensionPoint : component.get('v.extensionPoint')});
        compEvent.fire();
        
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.today', today);
        
        
        
        var receiptData = component.get("v.data");       
        component.set("v.ConfirmationNumber",receiptData.name);
        component.set("v.total",receiptData.total);       
        
        console.log('Url-->'+receiptData.url);
        console.log('ConfirmationNumber-->'+receiptData.name);
        console.log('total-->'+receiptData.total);
        var u = receiptData.url;
        var urlSplit=u.split("recordId=")[1];
        var receiptIds=urlSplit.split("&")[0];
        console.log(receiptIds);
      
        // var receiptIds ='a1Cg0000004qFt0EAE';
        component.set("v.lstReceiptId",receiptIds);
        var lstReceiptId = component.get("v.lstReceiptId");
        console.log('lstReceiptId-->'+lstReceiptId);
        
        //Apex Function
        var action = component.get("c.receiptLineData");
        action.setParams({
            lstReceiptId: lstReceiptId,
            receiptName : receiptData.name,
            amount : receiptData.total
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state == "SUCCESS") {
                var ReturnValue= response.getReturnValue();
                component.set("v.receiptLinelst",ReturnValue);
                
            }
        });  
        $A.enqueueAction(action); 
    },
    printButtonClick : function(component, event, helper){
        window.print();
    }
})