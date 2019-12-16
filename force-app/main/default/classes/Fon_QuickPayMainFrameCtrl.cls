public without sharing class Fon_QuickPayMainFrameCtrl{
    @AuraEnabled
    public static Fon_SalesOrderWrapper fetchSalesOrder1(Integer AFFPId, String InvoiceId){
        Fon_SalesOrderWrapper objSO;
        List<Fon_SalesOrderLineItemWrapper> lstSOLI;
        Boolean isFoundationDonation=false;
        Boolean isPACItem=false;
        Boolean isMainMembershipItem = false;
        Id defaultPriceRuleIdOfPACItem;
        Id defaultPriceRuleIdOfFoundationItem;
        
        List<OrderApi__Sales_Order__c> lstSO = [SELECT Id,
                                                Name, 
                                                OrderApi__Posting_Entity__c,
                                                OrderApi__Is_Posted__c, 
                                                OrderApi__Posting_Status__c, 
                                                OrderApi__Status__c,
                                                (Select Id,OrderApi__Item__r.Id,
                                                 OrderApi__Item__r.Name,
                                                 OrderApi__Sale_Price__c,
                                                 OrderApi__Item__r.Fon_Is_PAC_Item__c,
                                                 OrderApi__Total__c,
                                                 OrderApi__Item__r.Is_Foundation_Donation__c,
                                                 OrderApi__Item_Class__r.Fon_Is_Main_Membership__c,
                                                 OrderApi__Contact__r.Name
                                                 FROM OrderApi__Sales_Order_Lines__r),
                                                (Select id,
                                                 OrderApi__Is_Posted__c,
                                                 OrderApi__Balance_Due__c 
                                                 from OrderApi__Invoices__r where
                                                 OrderApi__Is_Paid__c=false Order By CreatedDate asc) FROM OrderApi__Sales_Order__c WHERE Name=:InvoiceId And OrderApi__Contact__r.AAFP_ID__c= :string.valueOf(AFFPId)];
        
        List<OrderApi__Item__c> packItem = [select id,OrderApi__Item_Class__c,Name,Fon_Is_PAC_Item__c,Is_Foundation_Donation__c from OrderApi__Item__c where Fon_Is_PAC_Item__c=true Limit 1];
        List<OrderApi__Item__c> foundationItem = [select id,OrderApi__Item_Class__c,Name,Fon_Is_PAC_Item__c,Is_Foundation_Donation__c from OrderApi__Item__c where Is_Foundation_Donation__c=true Limit 1];
        if(packItem.size()>0){
            List<OrderApi__Price_Rule__c> priceRuleList=[select id from OrderApi__Price_Rule__c where OrderApi__Is_Active__c=true And OrderApi__Is_Default__c=true And OrderApi__Item__c=:packItem[0].Id Limit 1];
            if(priceRuleList.size()>0){
                defaultPriceRuleIdOfPACItem=priceRuleList[0].Id;
            }
        }
        if(foundationItem.size()>0){
            List<OrderApi__Price_Rule__c> priceRuleList=[select id from OrderApi__Price_Rule__c where OrderApi__Is_Active__c=true And OrderApi__Is_Default__c=true And OrderApi__Item__c=:foundationItem[0].Id Limit 1];
            if(priceRuleList.size()>0){
                defaultPriceRuleIdOfFoundationItem=priceRuleList[0].Id;
            }
        }
        if(lstSO.size()>0){          
            for(OrderApi__Sales_Order__c eachSO : lstSO){
                List<OrderApi__Invoice__c> invList=eachSO.OrderApi__Invoices__r;
                List<OrderApi__Invoice__c> balanceDueInvoiceList = new List<OrderApi__Invoice__c>();
                Decimal totalBalanceDue=0;
                
                if(invList.size()>0){
                    for(OrderApi__Invoice__c obj:invList){
                        if(obj.OrderApi__Balance_Due__c>0){
                            balanceDueInvoiceList.add(obj);
                            totalBalanceDue +=obj.OrderApi__Balance_Due__c;
                        }
                    }
                } 
                
                objSO = new Fon_SalesOrderWrapper(eachSO);
                if(balanceDueInvoiceList.size()>0){
                    objSO.lstInvoice=balanceDueInvoiceList;
                    objSO.invoicesTotalDueAmount = 0.00;//totalBalanceDue;
                    objSO.hasBalanceDueInvoice = true;
                }
                
                if(eachSO.OrderApi__Status__c=='Closed' && eachSO.OrderApi__Posting_Entity__c=='Receipt'){
                    if(eachSO.OrderApi__Is_Posted__c==false && eachSO.OrderApi__Posting_Status__c!='Posted'){ //Closed Sales Order, NOT posted
                        if(invList.size()>0){
                            objSO = new Fon_SalesOrderWrapper(eachSO);
                            objSO.strMSG=System.Label.Fon_Aafp;
                            return rectifySalesOrderData(objSO);
                        }
                        else{
                            lstSOLI = new List<Fon_SalesOrderLineItemWrapper>();
                            for(OrderApi__Sales_Order_Line__c eachSOLI : eachSO.OrderApi__Sales_Order_Lines__r){
                                
                                Fon_SalesOrderLineItemWrapper objSOLI = new Fon_SalesOrderLineItemWrapper(eachSOLI);
                                if(eachSOLI.OrderApi__Item__r.Is_Foundation_Donation__c){
                                    isFoundationDonation= true;
                                    objSOLI.hasDonation = true; 
                                }
                                if(eachSOLI.OrderApi__Item__r.Fon_Is_PAC_Item__c){
                                    isPACItem=true;
                                    objSOLI.hasPACDonation= true;
                                    objSOLI.strEmployeeName =  eachSOLI.OrderApi__Contact__r.Name;
                                    objSOLI.strOccupation = 'None';
                                    objSOLI.strAccountType = System.Label.Fon_Corporate;
                                    
                                }
                                if(eachSOLI.OrderApi__Item_Class__r.Fon_Is_Main_Membership__c){
                                    isMainMembershipItem= true; 
                                }
                                lstSOLI.add(objSOLI);
                            }
                            if(!isFoundationDonation && isMainMembershipItem){//Creating Soli of Foundation Item
                                if(foundationItem.size()>0){
                                    Fon_SalesOrderLineItemWrapper objSOLI = new Fon_SalesOrderLineItemWrapper(createSoli(eachSO.Id),foundationItem[0],defaultPriceRuleIdOfPACItem,defaultPriceRuleIdOfFoundationItem);
                                    lstSOLI.add(objSOLI);
                                }
                            }
                            if(!isPACItem && isMainMembershipItem){//Creating Soli of PAC Item
                                if(packItem.size()>0){
                                    Fon_SalesOrderLineItemWrapper objSOLI = new Fon_SalesOrderLineItemWrapper(createSoli(eachSO.Id),packItem[0],defaultPriceRuleIdOfPACItem,defaultPriceRuleIdOfFoundationItem);
                                    lstSOLI.add(objSOLI);
                                }
                            }
                            objSO.lstSOLI = lstSOLI;
                            return rectifySalesOrderData(objSO);
                        }
                    }
                    else if(eachSO.OrderApi__Is_Posted__c==true && eachSO.OrderApi__Posting_Status__c=='Posted'){//Closed Sales Order, Posted , Paid
                        if(invList.size()>0){
                            Boolean isAllInvoicePaid=true;
                            for(OrderApi__Invoice__c invObj:invList){
                                if(invObj.OrderApi__Balance_Due__c>0 && invObj.OrderApi__Is_Posted__c==true){//check
                                    isAllInvoicePaid=false;
                                    break;
                                }
                            }
                            if(isAllInvoicePaid){
                                objSO = new Fon_SalesOrderWrapper(eachSO);
                                objSO.strMSG=System.Label.Fon_Paid;
                                return rectifySalesOrderData(objSO);
                            }
                            else{
                                lstSOLI = new List<Fon_SalesOrderLineItemWrapper>();
                                for(OrderApi__Sales_Order_Line__c eachSOLI : eachSO.OrderApi__Sales_Order_Lines__r){
                                    Fon_SalesOrderLineItemWrapper objSOLI = new Fon_SalesOrderLineItemWrapper(eachSOLI);
                                    if(eachSOLI.OrderApi__Item__r.Is_Foundation_Donation__c){
                                        isFoundationDonation= true;
                                        objSOLI.hasDonation = true; 
                                    }
                                    if(eachSOLI.OrderApi__Item__r.Fon_Is_PAC_Item__c){
                                        isPACItem=true;
                                        objSOLI.hasPACDonation= true; 
                                        objSOLI.strEmployeeName =  eachSOLI.OrderApi__Contact__r.Name;
                                        objSOLI.strOccupation = 'None';
                                        objSOLI.strAccountType = System.Label.Fon_Corporate; 
                                    }
                                    if(eachSOLI.OrderApi__Item_Class__r.Fon_Is_Main_Membership__c){
                                        isMainMembershipItem= true; 
                                    }
                                    lstSOLI.add(objSOLI);
                                }
                                if(!isFoundationDonation && isMainMembershipItem){
                                    if(foundationItem.size()>0){
                                        Fon_SalesOrderLineItemWrapper objSOLI = new Fon_SalesOrderLineItemWrapper(createSoli(eachSO.Id),foundationItem[0],defaultPriceRuleIdOfPACItem,defaultPriceRuleIdOfFoundationItem);
                                        lstSOLI.add(objSOLI);
                                    }
                                }
                                if(!isPACItem && isMainMembershipItem){
                                    if(packItem.size()>0){
                                        Fon_SalesOrderLineItemWrapper objSOLI = new Fon_SalesOrderLineItemWrapper(createSoli(eachSO.Id),packItem[0],defaultPriceRuleIdOfPACItem,defaultPriceRuleIdOfFoundationItem);
                                        lstSOLI.add(objSOLI);
                                    }
                                }
                                objSO.lstSOLI = lstSOLI;
                                return rectifySalesOrderData(objSO);
                            }
                        }
                        else{
                            objSO = new Fon_SalesOrderWrapper(eachSO);
                            objSO.strMSG=System.Label.Fon_Paid;
                            return rectifySalesOrderData(objSO);
                        }
                    }
                }
                else if(eachSO.OrderApi__Posting_Entity__c=='Invoice'){
                    if(eachSO.OrderApi__Status__c=='Open'){
                        objSO = new Fon_SalesOrderWrapper(eachSO);
                        objSO.strMSG='Open';
                        return rectifySalesOrderData(objSO);
                    }
                    else if((eachSO.OrderApi__Is_Posted__c==false && eachSO.OrderApi__Posting_Status__c!='Posted') || eachSO.OrderApi__Status__c!='Closed'){
                        objSO = new Fon_SalesOrderWrapper(eachSO);
                        objSO.strMSG=System.Label.Fon_Aafp;
                        return rectifySalesOrderData(objSO);
                    }
                    else if(eachSO.OrderApi__Is_Posted__c==true && eachSO.OrderApi__Posting_Status__c=='Posted' && eachSO.OrderApi__Status__c=='Closed'){
                        if(invList.size()>0){
                            lstSOLI = new List<Fon_SalesOrderLineItemWrapper>();
                            
                            for(OrderApi__Sales_Order_Line__c eachSOLI : eachSO.OrderApi__Sales_Order_Lines__r){
                                Fon_SalesOrderLineItemWrapper objSOLI = new Fon_SalesOrderLineItemWrapper(eachSOLI);
                                if(eachSOLI.OrderApi__Item__r.Is_Foundation_Donation__c){
                                    isFoundationDonation= true;
                                    objSOLI.hasDonation = true; 
                                }
                                if(eachSOLI.OrderApi__Item__r.Fon_Is_PAC_Item__c){
                                    isPACItem=true;
                                    objSOLI.hasPACDonation= true; 
                                    objSOLI.strEmployeeName = eachSOLI.OrderApi__Contact__r.Name;
                                    objSOLI.strOccupation = 'None';
                                    objSOLI.strAccountType = System.Label.Fon_Corporate;
                                }
                                if(eachSOLI.OrderApi__Item_Class__r.Fon_Is_Main_Membership__c){
                                    isMainMembershipItem= true; 
                                }
                                lstSOLI.add(objSOLI);
                                
                            }
                            if(!isFoundationDonation && isMainMembershipItem){
                                if(foundationItem.size()>0){
                                    Fon_SalesOrderLineItemWrapper objSOLI = new Fon_SalesOrderLineItemWrapper(createSoli(eachSO.Id),foundationItem[0],defaultPriceRuleIdOfPACItem,defaultPriceRuleIdOfFoundationItem);
                                    lstSOLI.add(objSOLI);
                                }
                            }
                            if(!isPACItem && isMainMembershipItem){
                                if(packItem.size()>0){
                                    Fon_SalesOrderLineItemWrapper objSOLI = new Fon_SalesOrderLineItemWrapper(createSoli(eachSO.Id),packItem[0],defaultPriceRuleIdOfPACItem,defaultPriceRuleIdOfFoundationItem);
                                    lstSOLI.add(objSOLI);
                                }
                            }
                            objSO.lstSOLI = lstSOLI;
                            return rectifySalesOrderData(objSO);
                        }
                        else{
                            objSO = new Fon_SalesOrderWrapper(eachSO);
                            objSO.strMSG=System.Label.Fon_Paid;
                            return rectifySalesOrderData(objSO);
                        }
                    }
                }
                else{
                    objSO = new Fon_SalesOrderWrapper(eachSO);
                    objSO.strMSG=System.Label.Fon_Open;
                    return rectifySalesOrderData(objSO);
                }
            }
        }
        return rectifySalesOrderData(objSO);
    }
    
    public static OrderApi__Sales_Order_Line__c createSoli(Id soId){
        OrderApi__Sales_Order_Line__c soli = new OrderApi__Sales_Order_Line__c();
        soli.OrderApi__Sales_Order__c= soId;
        return soli;
    }    
    
    @AuraEnabled
    public static List<Fon_SalesOrderWrapper> fetchSalesOrderList(){
        return new List<Fon_SalesOrderWrapper>();
    }
    
    @AuraEnabled
    public static String manageSalesOrderAndInvoice(String lstSalesOrder, String strPayeeEmailId){
        List<Fon_SalesOrderWrapper> lstDeserializeSalesOrder = (List<Fon_SalesOrderWrapper>)System.JSON.deserialize(lstSalesOrder, List<Fon_SalesOrderWrapper>.class);
        List<OrderApi__Invoice_Line__c> lstInvoiceLine = new List<OrderApi__Invoice_Line__c>();
        List<OrderApi__Sales_Order_Line__c> lstSalesOrderLine = new List<OrderApi__Sales_Order_Line__c>();
        String strAllId = '';
        List<OrderApi__Sales_Order__c> salesOrderForPayeeSet = new List<OrderApi__Sales_Order__c>();
        List<OrderApi__Invoice__c> invoiceForPayeeSet = new List<OrderApi__Invoice__c>();
        Set<Id> argIdSetOfSO = new Set<Id>();
        for(Fon_SalesOrderWrapper eachSOWrap : lstDeserializeSalesOrder){
            for(Fon_SalesOrderLineItemWrapper eachSOLIWrap : eachSOWrap.lstSOLI){
                if((eachSOLIWrap.isPACItem || eachSOLIWrap.isFoundationDonation) && eachSOLIWrap.salesPriceAmount != 0.00){
                    argIdSetOfSO.add(eachSOWrap.strSOID);
                }
            }
        }
        Map<Id,OrderApi__Sales_Order__c> mapIdToObjSalesOrder = fetchSalesOrderData(argIdSetOfSO, strPayeeEmailId);
        for(Fon_SalesOrderWrapper eachSOWrap : lstDeserializeSalesOrder){
            salesOrderForPayeeSet.add(new OrderApi__Sales_Order__c(Id=eachSOWrap.strSOID, Fon_Payee_Email__c=strPayeeEmailId));
            String strInvoiceId = '';
            Id invoiceId;
            if(eachSOWrap.lstInvoice != null && !eachSOWrap.lstInvoice.isEmpty()){
                for(OrderApi__Invoice__c objInvoice : eachSOWrap.lstInvoice){
                    strInvoiceId = strInvoiceId + Id.valueOf(objInvoice.Id)+',';
                }
            }
            for(Fon_SalesOrderLineItemWrapper eachSOLIWrap : eachSOWrap.lstSOLI){
                if((eachSOLIWrap.isPACItem || eachSOLIWrap.isFoundationDonation) && eachSOLIWrap.salesPriceAmount != 0.00){
                    OrderApi__Sales_Order_Line__c objSOLI = eachSOLIWrap.objSOLI;
                    objSOLI.OrderApi__Price_Override__c = true;
                    objSOLI.OrderApi__Quantity__c = 1;
                    objSOLI.OrderApi__Sale_Price__c = eachSOLIWrap.salesPriceAmount;
                    if(eachSOLIWrap.isPACItem){
                        objSOLI.Fon_Employee_Name__c = eachSOLIWrap.strEmployeeName;
                        objSOLI.Fon_Occupation__c = eachSOLIWrap.strOccupation;
                        objSOLI.Fon_Account_Type__c = eachSOLIWrap.strAccountType;
                    }
                    if(mapIdToObjSalesOrder.containsKey(eachSOLIWrap.objSOLI.OrderApi__Sales_Order__c)){
                        objSOLI.OrderApi__Sales_Order__c = mapIdToObjSalesOrder.get(eachSOLIWrap.objSOLI.OrderApi__Sales_Order__c).Id;
                    }
                    lstSalesOrderLine.add(objSOLI);
                    if(!String.isBlank(eachSOWrap.objAdjustmentInvoice) && String.isBlank(objSOLI.id)){
                        OrderApi__Invoice_Line__c objInvoiceLine = new OrderApi__Invoice_Line__c();
                        objInvoiceLine.OrderApi__Invoice__c = eachSOWrap.objAdjustmentInvoice;
                        objInvoiceLine.OrderApi__Item__c = eachSOLIWrap.objSOLI.OrderApi__Item__c;
                        objInvoiceLine.OrderApi__Price_Override__c = true;
                        objInvoiceLine.OrderApi__Is_Adjustment__c = true;
                        //objInvoiceLine.OrderApi__Is_Posted__c = true;
                        objInvoiceLine.OrderApi__Quantity__c = eachSOLIWrap.objSOLI.OrderApi__Quantity__c ;
                        objInvoiceLine.OrderApi__Sale_Price__c = eachSOLIWrap.salesPriceAmount;
                        objInvoiceLine.OrderApi__Invoice_Line__c = eachSOWrap.parentInvoiceLine;
                        lstInvoiceLine.add(objInvoiceLine);
                    }
                }
            }
            if(String.isBlank(strInvoiceId)){
                strAllId = strAllId + eachSOWrap.strSOID + ',';
            }else{
                strAllId = strAllId + strInvoiceId;
            }
        }
        if(!lstSalesOrderLine.isEmpty()){
            upsert lstSalesOrderLine;
        }
        if(!mapIdToObjSalesOrder.values().isEmpty()){
            for(OrderApi__Sales_Order__c eacSalesOrder : mapIdToObjSalesOrder.values()){
                eacSalesOrder.OrderApi__Status__c = 'Closed';
                eacSalesOrder.OrderApi__Posting_Status__c = 'Pending';
            }
            update mapIdToObjSalesOrder.values();
            for(OrderApi__Sales_Order__c eacSalesOrder : mapIdToObjSalesOrder.values()){
                strAllId = strAllId + eacSalesOrder.Id + ',';
            }
        }
        if(!lstInvoiceLine.isEmpty()){
            //    insert lstInvoiceLine;
            for(OrderApi__Invoice_Line__c inv : lstInvoiceLine){
                inv.OrderApi__Is_Posted__c = true;
            }
            //    update lstInvoiceLine;
        }
        if(!salesOrderForPayeeSet.isEmpty()){
            update new List<OrderApi__Sales_Order__c>(salesOrderForPayeeSet);
        }
        if(!invoiceForPayeeSet.isEmpty()){
            update new List<OrderApi__Invoice__c>(invoiceForPayeeSet);
        }
        //System.debug('=======================strAllId======'+strAllId);
        
        return strAllId.substring(0,strAllId.length()-1);
    }
    
    public static void adjustInvoiceLineItemAmount(Fon_SalesOrderWrapper objSO){
        //System.debug('==========================SO=========='+objSO);
        List<Id> lstInvoiceIds = new List<Id>();
        Map<String,Decimal> mapItemIdToTotalPrice = new Map<String,Decimal>();
        for(OrderApi__Invoice__c objInvoice : objSO.lstInvoice){
            lstInvoiceIds.add(objInvoice.Id);
        }
        List<OrderApi__Invoice__c> lstInvoiceRec = [SELECT Id,Name,(SELECT Id,OrderApi__Item__r.Id,OrderApi__Total__c,OrderApi__Sales_Order_Line__c,OrderApi__Balance_Due__c FROM OrderApi__Invoice_Lines__r 
                                                                    WHERE OrderApi__Sales_Order_Line__c != null) FROM OrderApi__Invoice__c WHERE Id IN: lstInvoiceIds];
        for(OrderApi__Invoice__c eachInvoice : lstInvoiceRec){
            for(OrderApi__Invoice_Line__c eachInvoiceLine : eachInvoice.OrderApi__Invoice_Lines__r){
                //String customKey = ''+Id.valueOf(eachInvoiceLine.OrderApi__Sales_Order_Line__c)+Id.valueOf(eachInvoiceLine.OrderApi__Item__r.Id);
                String customKey = ''+Id.valueOf(eachInvoiceLine.OrderApi__Item__r.Id);
                if(mapItemIdToTotalPrice.containsKey(customKey)){
                    Decimal totalPrice = mapItemIdToTotalPrice.get(customKey);
                    totalPrice = totalPrice + eachInvoiceLine.OrderApi__Balance_Due__c;
                    mapItemIdToTotalPrice.put(customKey, totalPrice);
                }else{
                    mapItemIdToTotalPrice.put(customKey, eachInvoiceLine.OrderApi__Balance_Due__c);
                }
            }
        }
        for(Fon_SalesOrderLineItemWrapper eachSOLIWrap : objSO.lstSOLI){
            //String customKey = ''+Id.valueOf(eachSOLIWrap.objSOLI.Id)+Id.valueOf(eachSOLIWrap.objSOLI.OrderApi__Item__c);
            String customKey = ''+Id.valueOf(eachSOLIWrap.objSOLI.OrderApi__Item__c);
            if( mapItemIdToTotalPrice.containsKey(customKey)){
                eachSOLIWrap.salesPriceAmount = mapItemIdToTotalPrice.get(customKey);
            }
        }
    }
    
    public static Fon_SalesOrderWrapper rectifySalesOrderData(Fon_SalesOrderWrapper objSO){
        if(objSO.lstInvoice != null && objSO.lstInvoice.size()>0){
            List<OrderApi__Invoice_Line__c> invLineList = [select id from OrderApi__Invoice_Line__c where OrderApi__Invoice__c=:objSO.lstInvoice[0].Id Order by CreatedDate asc limit 1];
            if(invLineList.size()>0){
                objSO.objAdjustmentInvoice = objSO.lstInvoice[0].Id;
                objSO.parentInvoiceLine = invLineList[0].id;
            }
            adjustInvoiceLineItemAmount(objSO);
        }
        return objSO;
    }
    
    public static Map<Id,OrderApi__Sales_Order__c> fetchSalesOrderData(Set<Id> argIdSet, String strPayeeEmailId){
        List<OrderApi__Sales_Order__c> lstRecrodSO = [SELECT Id,OrderApi__Contact__c,OrderApi__Account__c,OrderApi__Business_Group__c,OrderApi__Payment_Method__c,OrderApi__Payment_Terms__c,
                                                      OrderApi__Entity__c,OrderApi__Status__c,OrderApi__Posting_Entity__c,OrderApi__Posting_Status__c FROM OrderApi__Sales_Order__c WHERE Id IN :argIdSet];
        Map<Id,OrderApi__Sales_Order__c> mapIdToObjSalesOrder = new Map<Id,OrderApi__Sales_Order__c>();
        for(OrderApi__Sales_Order__c eachRecSO : lstRecrodSO){
            OrderApi__Sales_Order__c objClonedSO = eachRecSO.clone(false);
            objClonedSO.OrderApi__Posting_Entity__c = 'Receipt';
            objClonedSO.OrderApi__Status__c = 'Open';
            objClonedSO.OrderApi__Posting_Status__c = '';
            objClonedSO.Fon_Payee_Email__c = strPayeeEmailId;
            objClonedSO.Fon_Salesorder_Type__c = 'Donation'	;
            objClonedSO.Fon_Dues_Sales_Order__c = eachRecSO.Id;
            mapIdToObjSalesOrder.put(eachRecSO.Id, objClonedSO);
        }
        if(!mapIdToObjSalesOrder.values().isEmpty()){
            insert mapIdToObjSalesOrder.values();
        }
        return mapIdToObjSalesOrder;
    }
    
    @AuraEnabled
    public static Boolean isSingleInvoice(String ids){
        if(ids.containsIgnoreCase(',')){
            return false;
        }
        else{
            List<OrderApi__Invoice__c> inv=[select id from OrderApi__Invoice__c where id=:ids];
            if(inv.size()>0){
                return true;
            }
            else{
                return false;
            }
        }
    }
    
}