@isTest
private class AccountLogNameChangeTest {

    /*  Test inserting a brand new account
	*/
	@isTest
	private static void insertAccount() {
		Account myAccount = new Account();
		myAccount.Name = 'TEST1';
		myAccount.Type = 'Medical School';
		myAccount.AAFP_ID__c = '9999999';
		insert myAccount;
		List<AAFP_Account_Alternate_Name__c> altNames = [select id from AAFP_Account_Alternate_Name__c where account__c = :myAccount.id and Name = :myAccount.Name];
		System.assertEquals(altNames.size(), 1);
	}

    /*  Test make a new name for an existing account
	*/
	@isTest
	private static void changeAccountNewName() {
		Account myAccount = new Account();
		myAccount.Name = 'TEST1';
		myAccount.Type = 'Medical School';
		myAccount.AAFP_ID__c = '9999999';
		insert myAccount;
		myAccount.Name = 'TEST2';
		upsert myAccount;
		List<AAFP_Account_Alternate_Name__c> altNames = [select id from AAFP_Account_Alternate_Name__c where account__c = :myAccount.id and Name = :myAccount.Name];
		System.assertEquals(altNames.size(), 1);
	}

    /*  Test reusing an old name for an existing account
	*/
	@isTest
	private static void changeAccountOldName() {
		Account myAccount = new Account();
		myAccount.Name = 'TEST1';
		myAccount.Type = 'Medical School';
		myAccount.AAFP_ID__c = '9999999';
		insert myAccount;
		myAccount.Name = 'TEST2';
		upsert myAccount;
		myAccount.Name = 'TEST1';
		upsert myAccount;
		List<AAFP_Account_Alternate_Name__c> altNames = [select id from AAFP_Account_Alternate_Name__c where account__c = :myAccount.id and Name = :myAccount.Name];
		System.assertEquals(altNames.size(), 1);
	}
}