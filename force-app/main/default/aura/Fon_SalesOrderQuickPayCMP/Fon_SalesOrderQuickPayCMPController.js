({
	myAction : function(component, event, helper) {
		
	},
    sectionOne : function(component, event, helper) {
       helper.helperFun(component,event,'articleOne');
    },
    
   sectionTwo : function(component, event, helper) {
      helper.helperFun(component,event,'articleTwo');
    },
   
   sectionThree : function(component, event, helper) {
      helper.helperFun(component,event,'articleThree');
   },
   
   sectionFour : function(component, event, helper) {
      helper.helperFun(component,event,'articleFour');
   },
   
   removeSalesOrder : function(component, event, helper) {
        var nonRemoveSalesOrder = [];
        var lstSalesOrder = component.get("v.lstSalesOrder");
        var objSalesOrder = component.get("v.objSalesOrder");
        for(var eachSO in lstSalesOrder){
            if(lstSalesOrder[eachSO].strSOID == event.currentTarget.id){
                
            }else{
                nonRemoveSalesOrder.push(lstSalesOrder[eachSO]);
            }
        }
        component.set("v.lstSalesOrder", nonRemoveSalesOrder);
        helper.calcultetotalInvoiceAmt(component, event, helper);
	}
})