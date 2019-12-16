({
	selectPACDonation : function(component, event, helper) {
		//alert(event.getSource().get("v.value"));
		component.set("v.isDonationAmountDisable",true);
        var objSalesOrder = component.get("v.objSalesOrder");
        for(var eachSOLI in objSalesOrder.lstSOLI){
            if(objSalesOrder.lstSOLI[eachSOLI].isPACItem && event.getSource().get("v.value") > 0){
                objSalesOrder.lstSOLI[eachSOLI].salesPriceAmount = event.getSource().get("v.value");
            }else if(objSalesOrder.lstSOLI[eachSOLI].isPACItem && event.getSource().get("v.value") == 0){
                component.set("v.isDonationAmountDisable",false);
                objSalesOrder.lstSOLI[eachSOLI].salesPriceAmount = 0.00;
            }else if(objSalesOrder.lstSOLI[eachSOLI].isPACItem && event.getSource().get("v.value") < 0){
                objSalesOrder.lstSOLI[eachSOLI].salesPriceAmount = 0.00;
            }
            
        }
        
        component.set("v.objSalesOrder",objSalesOrder);
        helper.calculateSalesOerderTotalAmount(component, event, helper);
	},
     
    customPACDonation : function(component, event, helper) {
        var objSalesOrder = component.get("v.objSalesOrder");
        for(var eachSOLI in objSalesOrder.lstSOLI){
            if(objSalesOrder.lstSOLI[eachSOLI].isPACItem && event.getSource().get("v.value") > 0){
                objSalesOrder.lstSOLI[eachSOLI].salesPriceAmount = event.getSource().get("v.value");
            }else if(objSalesOrder.lstSOLI[eachSOLI].isPACItem){ 
            }
        }
        component.set("v.objSalesOrder",objSalesOrder);
        helper.calculateSalesOerderTotalAmount(component, event, helper);
    },
    selectFoundationDonation : function(component, event, helper) {
        //alert(event.getSource().get("v.value"));
        var objSalesOrder = component.get("v.objSalesOrder");
        for(var eachSOLI in objSalesOrder.lstSOLI){
            if(objSalesOrder.lstSOLI[eachSOLI].isFoundationDonation && !event.getSource().get("v.value")){
                objSalesOrder.lstSOLI[eachSOLI].salesPriceAmount = 50;
                component.set("v.isFoundationAmtDonation",true);
            }else if(objSalesOrder.lstSOLI[eachSOLI].isFoundationDonation){
                objSalesOrder.lstSOLI[eachSOLI].salesPriceAmount = 0.00;
                component.set("v.isFoundationAmtDonation",false);
            }
        }
        component.set("v.objSalesOrder",objSalesOrder);
        helper.calculateSalesOerderTotalAmount(component, event, helper);
    },
    selectAccountType : function(component, event, helper) {
        //alert(event.getSource().get("v.value"));
        var objSalesOrder = component.get("v.objSalesOrder");
        //objSalesOrder.strAccountType = event.getSource().get("v.value");
        for(var eachSOLI in  objSalesOrder.lstSOLI){
            if(objSalesOrder.lstSOLI[eachSOLI].isPACItem){
                objSalesOrder.lstSOLI[eachSOLI].strAccountType = event.getSource().get("v.value");
                //alert(objSalesOrder.lstSOLI[eachSOLI].strAccountType);
            }
        }
        component.set("v.objSalesOrder",objSalesOrder);
    }
})