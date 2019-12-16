public class Fon_NewMembershipController{
    
    private static Map<String, Schema.FieldSet> fieldSetMap;
    
    @AuraEnabled
    public static List<Field> getForm(Id recordId, String objectName, String fieldSetName, Boolean isUpgrade) {
        List<Field> fields = new List<Field>();
        getObjectFieldSets(objectName);
        
        if(!String.isBlank(fieldSetName)){
            fields.addAll(getFields(fieldSetName));
        }
        //Adding value here
        List<Fon_Membership_Staging__c> lstMembership = [SELECT Id,
                                                         Fon_Staging_Status__c,
                                                         Fon_Cancelled_Reason__c,
                                                         Fon_Payment_Method_Id__c,
                                                         Fon_Membership_State__c,
                                                         Fon_Membership_Local__c,
                                                         Fon_AAFP_Subscription_Plan_Picklist__c,
                                                         Fon_Subscription_Plan__c,
                                                         Fon_Foundation_Donation_Renewal__c,
                                                         Fon_Foundation_Contribution_Information__c,
                                                         Fon_PAC_Contribution_Information__c,
                                                         Fon_Year__c,Fon_Chapter_Join_Date__c,
                                                         Fon_Membership_Activation_Date__c,
                                                         Fon_Is_Membership_Type_Changed__c,
                                                         Fon_Membership_Type__c
                                                         FROM Fon_Membership_Staging__c 
                                                         WHERE Fon_Contact__c =:recordId ORDER BY CreatedDate DESC ];
        if(!lstMembership.isEmpty() && isUpgrade){
            for(Field eachField : fields){
                if(lstMembership[0].Fon_Is_Membership_Type_Changed__c){
                    eachField.isFieldDisable = true;
                    if(eachField.APIName == 'Fon_Payment_Method_Id__c' ){
                        eachField.defaultValue = (String)lstMembership[0].get(eachField.APIName);
                    }
                    else if(eachField.APIName == 'Fon_Membership_State__c'){
                        eachField.defaultValue = (String)lstMembership[0].get(eachField.APIName);
                    }
                    else if(eachField.APIName == 'Fon_Membership_Local__c'){
                        eachField.defaultValue = (String)lstMembership[0].get(eachField.APIName);
                    }
                    else if(eachField.APIName == 'Fon_AAFP_Subscription_Plan_Picklist__c'){
                        eachField.defaultValue = (String)lstMembership[0].get(eachField.APIName);
                    }
                    else if(eachField.APIName == 'Fon_Subscription_Plan__c'){
                        eachField.defaultValue = (String)lstMembership[0].get(eachField.APIName);
                    }
                    else if(eachField.APIName == 'Fon_Foundation_Donation_Renewal__c'){
                        eachField.defaultBoolValue = (Boolean)lstMembership[0].get(eachField.APIName);
                    }
                    else if(eachField.APIName == 'Fon_Foundation_Contribution_Information__c' && lstMembership[0].Fon_Foundation_Contribution_Information__c != null){
                        eachField.defaultValue = lstMembership[0].Fon_Foundation_Contribution_Information__c+'';
                    }
                    else if(eachField.APIName == 'Fon_PAC_Contribution_Information__c' && lstMembership[0].Fon_PAC_Contribution_Information__c != null){
                        eachField.defaultValue = lstMembership[0].Fon_PAC_Contribution_Information__c+'';
                    }
                    else if(eachField.APIName == 'Fon_Year__c'){
                        eachField.defaultValue = (String)lstMembership[0].get(eachField.APIName);
                    }
                    else if(eachField.APIName == 'Fon_Chapter_Join_Date__c'){
                        eachField.currentDate = (Date)lstMembership[0].get(eachField.APIName);
                    }
                    else if(eachField.APIName == 'Fon_Membership_Activation_Date__c'){
                        eachField.currentDate = (Date)lstMembership[0].get(eachField.APIName);
                    }
                    else if(eachField.APIName == 'Fon_Is_Membership_Type_Changed__c'){
                        eachField.defaultBoolValue = (Boolean)lstMembership[0].get(eachField.APIName);    
                    }
                    else if(eachField.APIName == 'Fon_Membership_Type__c'){
                        eachField.defaultValue = (String)lstMembership[0].get(eachField.APIName);
                    }
                }
            }
        }
        return fields;
    }
    
    private static void getObjectFieldSets(String objectName){
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        fieldSetMap = objectDescribe.fieldSets.getMap();
    }
    
    private static List<Field> getFields(String fieldSetName) {
        Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
        List<Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();
        
        List<Field> fields = new List<Field>();
        for (Schema.FieldSetMember fsm : fieldSetMembers) {
            Field f = new Field(fsm);
            fields.add(f);
        }
        return fields;
    }
    
    public class Field {
        @AuraEnabled public Boolean DBRequired;
        @AuraEnabled public String APIName;
        @AuraEnabled public String Label;        
        @AuraEnabled public Boolean Required;
        @AuraEnabled public String Type;
        @AuraEnabled public Date currentDate;   
        @AuraEnabled public String defaultValue;  
        @AuraEnabled public Boolean defaultBoolValue; 
        @AuraEnabled public Boolean isFieldDisable; 
        
        public Field(Schema.FieldSetMember f) {
            this.DBRequired = f.DBRequired;
            this.APIName = f.fieldPath;
            this.Label = f.label;
            this.Required = f.required;
            this.Type = String.valueOf(f.getType());
            this.currentDate=system.today();  
            this.isFieldDisable = false;
        }
        
        public Field(Boolean DBRequired) {
            this.DBRequired = DBRequired;
        }
    }
    
    //Date- 8 Aug 2019
    @AuraEnabled
    public static Boolean isChapterIdValid(String chapterId){
       List<Account> ac= [select id from Account where id=:chapterId];
        if(ac.size()>0){
            return true;
        }
        else{
             return false;
        }
    }
}