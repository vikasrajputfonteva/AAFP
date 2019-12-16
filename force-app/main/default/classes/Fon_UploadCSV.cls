public class Fon_UploadCSV {
    final static String strCancelled = 'Cancelled';
    final static String strExpired = 'Expired';
    final static Set<String> textSet = new Set<String>{'STRING','PICKLIST'};
        final static Set<String> booleanSet = new Set<String>{'BOOLEAN'};
            final static Set<String> dateSet = new Set<String>{'DATE'};
                final static Set<String> numberSet = new Set<String>{'DOUBLE','INTEGER'}; 
                    final static Set<String> referenceSet = new Set<String>{'REFERENCE'};
                        
                        @AuraEnabled
                        public static Boolean csvFileUpdloader(String strCSVFile){
                            if(!String.isBlank(strCSVFile)){
                                List<String> lstRows = strCSVFile.split('\n');
                            }
                            List<Fon_Membership_Staging__c> lstChangeTypeMembershipStage = new List<Fon_Membership_Staging__c>();
                            List<Fon_Membership_Staging__c> lstMembershipStage = new List<Fon_Membership_Staging__c>();
                            List<Fon_Membership_Staging__c> lstUpgradeMembershipStage = new List<Fon_Membership_Staging__c>();
                            List<Fon_Membership_Staging__c> lstUpgradeToExpireMemberStage = new List<Fon_Membership_Staging__c>();
                            Set<Id> contactIdSetOfFinancialMember = new Set<Id>();
                            Set<Id> contactIdSetOfNonFinancialMember = new Set<Id>();
                            Set<Id> expiredMemberByContactIdSet = new Set<Id>();
                            Set<Id> upgradeMemberByContactIdSet = new Set<Id>();
                            Map<String, Schema.FieldSetMember> mapFieldApiToFieldSetMember = new Map<String, Schema.FieldSetMember>();
                            Map<String, Schema.FieldSet> mapFieldSet = Schema.SObjectType.Fon_Membership_Staging__c.fieldSets.getMap();
                            List<Schema.FieldSetMember> lstFieldSetMember = mapFieldSet.get('Fon_CSV_Upload').getFields();
                            for(Schema.FieldSetMember eachField : lstFieldSetMember){
                                mapFieldApiToFieldSetMember.put(eachField.getFieldPath().toLowerCase(),eachField);
                            }
                            List<String> lstRows = strCSVFile.split('\n');
                            Map<Integer,String> mapKeyToHeaderName = fetchCSVHeaderMap(lstRows);
                            
                            for(Integer i = 1; i<lstRows.size(); i++){
                                Fon_Membership_Staging__c objMembershipStage = new Fon_Membership_Staging__c();
                                List<String> lstColumns = lstRows[i].split(',');
                                for(Integer j = 0; j < lstColumns.size(); j++){
                                    String strFieldKey = mapKeyToHeaderName.get(j).trim().toLowerCase();
                                    if(mapFieldApiToFieldSetMember.containsKey(strFieldKey) && !String.isBlank(lstColumns[j])){
                                        String strType = mapFieldApiToFieldSetMember.get(strFieldKey).getType()+'';
                                        String strFieldPath = mapFieldApiToFieldSetMember.get(strFieldKey).getFieldPath();
                                        if(strFieldKey == 'Id'.toLowerCase() && !String.isBlank(lstColumns[j])){
                                            objMembershipStage.Id = lstColumns[j].trim();
                                        }else if(textSet.contains(strType)){
                                            objMembershipStage.put(strFieldPath, lstColumns[j]);
                                        }else if(booleanSet.contains(strType)){
                                            objMembershipStage.put(strFieldPath, fetchBooleanData(lstColumns[j]));
                                        }else if(dateSet.contains(strType)){
                                            objMembershipStage.put(strFieldPath, fetchDateData(lstColumns[j]));
                                        }else if(referenceSet.contains(strType)){
                                            objMembershipStage.put(strFieldPath, Id.valueOf(lstColumns[j].trim()));
                                        }else if(numberSet.contains(strType)){
                                            objMembershipStage.put(strFieldPath, fetchNumericData(lstColumns[j]));
                                        }
                                    }
                                }
                                
                                if(!String.IsBlank(objMembershipStage.Id) && objMembershipStage.Fon_Staging_Status__c == 'Cancelled'){
                                    if(objMembershipStage.Fon_Is_Financial__c){
                                        contactIdSetOfFinancialMember.add(objMembershipStage.Fon_Contact__c);
                                    }else{
                                        contactIdSetOfNonFinancialMember.add(objMembershipStage.Fon_Contact__c);
                                    } 
                                    lstMembershipStage.add(objMembershipStage);
                                }
                                else if(objMembershipStage.Fon_Staging_Status__c == 'Upgrade'){
                                    if(!String.isEmpty(objMembershipStage.Id)){
                                        lstUpgradeToExpireMemberStage.add(fetchMemberStageRec(objMembershipStage.Id, strCancelled,objMembershipStage.FON_CANCELLED_REASON__C));
                                        upgradeMemberByContactIdSet.add(objMembershipStage.Fon_Contact__c);
                                        objMembershipStage.Id=null;
                                        objMembershipStage.Fon_Cancelled_Reason__c= '';
                                        objMembershipStage.Fon_Staging_Status__c = 'Approved';
                                        lstUpgradeMembershipStage.add(objMembershipStage);
                                    }
                                }
                            }
                            
                            Set<Id> cancellMemberContactIdSet = new Set<Id>();
                            //Cancel Membership Start
                            if(!contactIdSetOfFinancialMember.isEmpty()){
                                cancellMemberContactIdSet.addAll(contactIdSetOfFinancialMember);
                                List<OrderApi__Subscription__c> lstSubscription = Fon_CommonUtilityCtrl.fetchSubscriptionBycontactIdSet(contactIdSetOfFinancialMember);
                                Fon_CommonUtilityCtrl.updatingInvoiceAndScheduledPayment(lstSubscription);
                                Fon_CommonUtilityCtrl.updateSubscription(lstSubscription, strCancelled);
                            }
                            if(!contactIdSetOfNonFinancialMember.isEmpty()){
                                cancellMemberContactIdSet.addAll(contactIdSetOfNonFinancialMember);
                                List<OrderApi__Subscription__c> lstSubscription = Fon_CommonUtilityCtrl.fetchSubscriptionBycontactIdSet(contactIdSetOfNonFinancialMember);
                                Fon_CommonUtilityCtrl.updateSubscription(lstSubscription, strCancelled);
                            }
                            if(!cancellMemberContactIdSet.isEmpty()){
                                Fon_CommonUtilityCtrl.updatingContactStatus(cancellMemberContactIdSet, strCancelled);
                            }
                            if(!lstMembershipStage.isEmpty()){
                                upsert lstMembershipStage;
                            }
                            //Cancel Membership End
                            //Change Member Type/Upgrade Membership Start
                            if(!lstUpgradeMembershipStage.isEmpty()){
                                List<OrderApi__Subscription__c> lstSubscription = Fon_CommonUtilityCtrl.fetchSubscriptionBycontactIdSet(upgradeMemberByContactIdSet);
                                Fon_CommonUtilityCtrl.updatingInvoiceAndScheduledPayment(lstSubscription);
                                Fon_CommonUtilityCtrl.updateSubscription(lstSubscription, strCancelled);
                                Fon_CommonUtilityCtrl.updatingContactStatus(upgradeMemberByContactIdSet, strCancelled);
                                insert lstUpgradeMembershipStage;
                                update lstUpgradeToExpireMemberStage;
                            }
                            //Change Member Type/Upgrade Membership End
                            return false;
                        }
    public static Map<Integer,String> fetchCSVHeaderMap(List<String> lstRows){
        Map<Integer,String> mapKeyToHeaderName = new Map<Integer,String>();
        List<String> lstColumns = lstRows[0].split(',');
        for(Integer i = 0; i<lstColumns.size(); i++){
            mapKeyToHeaderName.put(i,lstColumns[i]);
        }
        return mapKeyToHeaderName;
    }
    public static Date fetchDateData(String strDate){
        return Date.parse(strDate);
    }
    public static Boolean fetchBooleanData(String strBoolean){
        return Boolean.valueOf(strBoolean.trim());
    }
    public static Decimal fetchNumericData(String strNumeric){
        return Decimal.valueOf(strNumeric);
    }
    public static Fon_Membership_Staging__c fetchMemberStageRec(Id membershipId, String strStatus,String cancelReason){
        return new Fon_Membership_Staging__c(Id=membershipId,Fon_Staging_Status__c=strStatus,FON_CANCELLED_REASON__C=cancelReason);
    }
}