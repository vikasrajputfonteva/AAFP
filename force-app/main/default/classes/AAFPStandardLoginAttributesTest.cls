@isTest
private class AAFPStandardLoginAttributesTest {
    @isTest (SeeAllData = true)    
    private static void testName() {
    
        // Create MOCK Contact
        
//        Account a = new Account(Name = 'Test Account Name');
//        insert a;
// We hav production locked down so that Accounts cannot be created in Production at this time.  This is because
// We want accounts to first be created in Netforum. Because of this validation rule, I can't create a new Account
// in this test.  Instead I just pull a random account and use it for assigning my mock contact to.  The account is not used
// in the test.  It is only needed for creating the test contact.
        Account a = [SELECT Id FROM Account limit 1];

        Contact c = new Contact(LastName = 'UNITTEST', AccountId = a.id);
        insert c;

        User user = new User();
        user.ProfileID = [Select Id From Profile Where Name = 'Fonteva Customer Community Login User'].id;
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.FirstName = 'first';
        user.LastName = 'last';
        user.Username = 'test@appirio.com';
        user.CommunityNickname = 'testUser123';
        user.Alias = 't1';
        user.Email = 'no@email.com';
        user.IsActive = true;
        user.ContactId = c.Id;

        insert user;

        Map<String, String> formulaDefinedAttributes = new Map<String, String> ();

        AAFPStandardLoginAttributes at = new AAFPStandardLoginAttributes();

        Map<String, String> answer = at.customAttributes(user.Id, user.Id, formulaDefinedAttributes, Auth.InvocationContext.OPENIDCONNECT);
        System.assertEquals(answer.get('sf_ContactLastName'), 'UNITTEST');  

    }

}