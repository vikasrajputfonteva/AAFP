({
	helperMethod : function() {
		
	},
    
    calculateSalesOerderTotalAmount : function(component, event, helper) {
        var objSalesOrder = component.get("v.objSalesOrder");
    	var totalSalesPrice = parseFloat("0.00");
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
        objSalesOrder.totalAmount = totalSalesPrice;
        component.set("v.objSalesOrder",objSalesOrder);
        this.calcultetotalInvoiceAmt(component, event, helper);
    },
    
    calcultetotalInvoiceAmt : function(component, event, helper) {
        var totalInvoiceAmount = parseFloat("0.00");
        var lstSalesOrder = component.get("v.lstSalesOrder"); 
        for(var eachSO in lstSalesOrder){
            var totalSalesPrice = parseFloat("0.00");
            var objSalesOrder = lstSalesOrder[eachSO];
            for(var eachSOLI in objSalesOrder.lstSOLI){
                var totalAmt = objSalesOrder.lstSOLI[eachSOLI].salesPriceAmount;
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
            totalInvoiceAmount = totalInvoiceAmount + objSalesOrder.totalAmount ;
        } 
        //alert(totalInvoiceAmount);
        component.set("v.lstSalesOrder",lstSalesOrder);
        component.set("v.totalInvoiceAmount",totalInvoiceAmount);
    }
})