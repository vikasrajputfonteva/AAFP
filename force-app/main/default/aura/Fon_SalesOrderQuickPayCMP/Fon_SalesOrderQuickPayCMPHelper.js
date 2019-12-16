({
	helperMethod : function() {
		
	},
    helperFun : function(component,event,secId) {
	  var acc = component.find(secId);
        	for(var cmp in acc) {
        	$A.util.toggleClass(acc[cmp], 'slds-show');  
        	$A.util.toggleClass(acc[cmp], 'slds-hide');  
       }
	},
    
    calcultetotalInvoiceAmt : function(component, event, helper) {
        var totalInvoiceAmount = parseFloat("0.00");
        var lstSalesOrder = component.get("v.lstSalesOrder"); 
        for(var eachSO in lstSalesOrder){
            var totalSalesPrice = parseFloat("0.00");
            var objSalesOrder = lstSalesOrder[eachSO];
            for(var eachSOLI in objSalesOrder.lstSOLI){
                var totalAmt = objSalesOrder.lstSOLI[eachSOLI].salesPriceAmount
                if(objSalesOrder.lstSOLI[eachSOLI].isPACItem){
                    if(isNaN(parseFloat(totalAmt))){
                        totalSalesPrice = totalSalesPrice + 0.00;
                    }else{
                        totalSalesPrice = totalSalesPrice + parseFloat(totalAmt);
                    }
                }else if(objSalesOrder.lstSOLI[eachSOLI].isFoundationDonation){
                    totalSalesPrice = totalSalesPrice + parseFloat(totalAmt);
                }else{
                    totalSalesPrice = totalSalesPrice + parseFloat(totalAmt);
                }
            }
            objSalesOrder.totalAmount = totalSalesPrice + objSalesOrder.invoicesTotalDueAmount;
            totalInvoiceAmount = totalInvoiceAmount + objSalesOrder.totalAmount;
        } 
        //alert(totalInvoiceAmount);
        component.set("v.lstSalesOrder",lstSalesOrder);
        component.set("v.totalInvoiceAmount",totalInvoiceAmount);
    }
})