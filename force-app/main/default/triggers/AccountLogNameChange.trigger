trigger AccountLogNameChange on Account(after insert, after update) {

/*
This trigger is used to log name changes for Med Schools and Residencies.
When there is a name change, if it is a new name, it is logged to Account_Alternate_Name__c
*/

	List<AAFP_Account_Alternate_Name__c> altNames = new List<AAFP_Account_Alternate_Name__c> { };

	for (Account myaccount : Trigger.new)
	{
		// We only need to log name changes for Med schools and Residencies
		if (myaccount.Type == 'Medical School' || myaccount.Type == 'Residency Program') {
			if (Trigger.isInsert) {
				AAFP_Account_Alternate_Name__c altName = new AAFP_Account_Alternate_Name__c();
				altName.Account__c = myaccount.Id;
				altName.Name = myaccount.Name;
				if ( myaccount.Name.length() < 81) {
					altNames.add(altName);
				}
			}

			// On updates, we need to see if this name was ever used in the past.  This is not a change log.  So we only want 
			// to keep one copy of each version of the name
			if (Trigger.isUpdate) {
				Account oldAccount = Trigger.oldMap.get(myaccount.ID);
				if (oldAccount.Name != myaccount.Name) {
					List<AAFP_Account_Alternate_Name__c > checkAltNames = [select id from AAFP_Account_Alternate_Name__c where Account__c = :myaccount.id and Name = :myaccount.Name limit 1];
						if (checkAltNames.size() < 1) {
							AAFP_Account_Alternate_Name__c altName = new AAFP_Account_Alternate_Name__c();
							altName.Account__c = myaccount.Id;
							altName.Name = myaccount.Name;
							if (myaccount.Name.length() < 81) {
								altNames.add(altName);
							}
						}
					}
				}
			}
		}
		
		if (altNames.size() > 0) {
			insert altNames;
		}
		
	}