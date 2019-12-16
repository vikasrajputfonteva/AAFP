({  
    showToastMessage : function(type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            mode: 'dismissible',
            duration:'5000',
            title: title,
            message: message
        });
        toastEvent.fire();
    },
    
    fetchMemberShipStageInstance : function(component, event, helper) {
        var objMembershipStage = {
            'Id': null,
            'Name': null,
            'Fon_Contact__c': null,
            'Fon_Cancelled_Reason__c': null,
            'Fon_Chapter_Id__c': null,
            'Fon_Chapter_Join_Date__c': null,
            'Fon_ContactID__c': null,
            'Fon_Dues_Paid_by_Chapter__c': null,
            'Fon_Dues_Paid_by_Residency_Program__c': null,
            "Fon_Dues_Waived__c": false,
            'Fon_Error_Reason__c': null,
            'Fon_Expiration_Date__c': null,
            'Fon_Extended_Training_Date__c': null,
            'Fon_Foundation_Contribution_Information__c': null,
            'Fon_Join_Date__c': null,
            "Fon_Life_Approved_Flag__c": false,
            'Fon_Main_Membership__c': null,
            'Fon_Medical_School_Graduation_Date__c': null,
            'Fon_Membership_Activation_Date__c	': null,
            'Fon_Membership_Local__c': null,
            'Fon_Membership_State__c': null,
            'Fon_Membership_Type__c': null,
            'Fon_Other_Price_Override__c': null,
            'Fon_PAC_Contribution_Account_Type__c': null,
            'Fon_PAC_Contribution_Employer__c': null,
            'Fon_PAC_Contribution_Information__c': null,
            'Fon_PAC_Contribution_Occupation__c': null,
            'Fon_Payment_Method_Id__c': null,
            'Fon_Residency_Program_Graduation_Date__c': null,
            'Fon_Residency_Training_Status__c': null,
            'Fon_Staging_Status__c': null,
            'Fon_Subscription_Plan__c': null,
            'Fon_Year__c': null
        };
        component.set("v.objMembershipStage",objMembershipStage);
    },
    addingColumnNameToKey : function(component, event, helper, csvRows) {
        var keyToColumnName = {};
        var baseRowCells = csvRows[0].split(',');
        //alert(baseRowCells.length);
        for(var k = 0; k < (baseRowCells.length); k++){
            keyToColumnName[k] = baseRowCells[k];
        }
        component.set("v.mapKeyToColumnName", keyToColumnName);
    },
    csvFileUploader : function(component, event, helper, text) { 
        var action = component.get("c.csvFileUpdloader");
        var strJSONData = JSON.stringify(component.get("v.data"));        
        action.setParams({
            strCSVFile : text
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") { 
                component.set("v.Spinner", false);
                alert($A.get("$Label.c.Fon_CsvSuccessMessgae"));
                component.set("v.fileName","No File Selected..");
                //this.showToastMessage("success", "Success!", $A.get("$Label.c.Fon_CsvSuccessMessgae"));
            }else{
                component.set("v.Spinner", false);
                alert($A.get("$Label.c.Fon_CsvErrorMessage"));
                //this.showToastMessage("error", "error!", $A.get("$Label.c.Fon_CsvErrorMessage"));
            }
        });
        $A.enqueueAction(action);
        
    }
})