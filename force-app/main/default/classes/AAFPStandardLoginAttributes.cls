global class AAFPStandardLoginAttributes extends Auth.ConnectedAppPlugin {
    global override Map<String, String> customAttributes(Id userId, Id connectedAppId, Map<String, String> formulaDefinedAttributes, Auth.InvocationContext context)
    {
    
        // Look up the contact id for this user
        User myUser = [select Contact.id, Username, Id from user where id = :userId limit 1];


        // Look up information about this contact that we want to return as SAML attributes     
        Contact myContact = [SELECT AAFP_ID__c, Id, AAFP_isAAFPStaff__c, AAFP_Is_Organization__c, Salutation, Name, FirstName, MiddleName, LastName, DonorApi__Suffix__c, Email, MemberType_tmp__c FROM Contact where id = :myUser.contact.id limit 1];

        // Get the most current member badge
        /*
          List<orderapi__badge__c> memberBadges = [select OrderApi__Badge_Type__r.Name from orderapi__badge__c where orderapi__contact__c = :myUser.Contact.Id and OrderApi__Badge_Type__r.Name in ('Active Member','Resident Member','Student Member','Life Member','Supporting Member') and OrderApi__Is_Active__c = true order by LastModifiedDate  limit 1];
         
          if ( !memberBadges.isEmpty() ) {
          formulaDefinedAttributes.put('isMember','true');
          formulaDefinedAttributes.put('MemberType',memberBadges[0].OrderApi__Badge_Type__r.Name);
          } else {
          formulaDefinedAttributes.put('isMember','false');
          formulaDefinedAttributes.put('MemberType','Customer');
          }
         */
         
        formulaDefinedAttributes.put('sf_isAAFPStaff', String.valueOf(myContact.AAFP_isAAFPStaff__c));
        formulaDefinedAttributes.put('sf_isOrganization', String.valueOf(myContact.AAFP_Is_Organization__c));
        formulaDefinedAttributes.put('sf_MemberType', (String.isBlank(myContact.MemberType_tmp__c) ? 'non-member' : myContact.MemberType_tmp__c));
        formulaDefinedAttributes.put('sf_isMember', (String.isBlank(myContact.MemberType_tmp__c) ? '0' : '1'));
        formulaDefinedAttributes.put('sf_ContactId', myContact.Id);
        formulaDefinedAttributes.put('sf_AAFPId', myContact.AAFP_ID__c);
        formulaDefinedAttributes.put('sf_ContactFirstName', myContact.FirstName);
        formulaDefinedAttributes.put('sf_ContactMiddleName', myContact.MiddleName);
        formulaDefinedAttributes.put('sf_ContactLastName', myContact.LastName);
        formulaDefinedAttributes.put('sf_UserId', myUser.Id);
        formulaDefinedAttributes.put('sf_UserName', myUser.Username);                   
        formulaDefinedAttributes.put('sf_ContactFullName', (String.isBlank(myContact.Salutation) ? '' : myContact.Salutation)  + ' ' + myContact.Name + ' ' + (String.isBlank(myContact.DonorApi__Suffix__c) ? '' : myContact.DonorApi__Suffix__c));
        formulaDefinedAttributes.put('sf_ContactEmail', myContact.Email);
        
        return formulaDefinedAttributes;
    }
}