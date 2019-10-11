@isTest

public class Fon_TestDataFactory_Test {
    
    static {
        
        Fon_TestDataFactory.FillAllFields = true; // increase test coverage without creating custom objects
        
    }  
    
    
    
    static testMethod void createsSingleObjectWithSingleRequiredStringField() {
        
        Account account = (Account)Fon_TestDataFactory.createSObject('Account');
        
        insert account;
        
        Fon_TestDataFactory.setRecordType(account);
        
        
        System.assert(account.Id != null);
        
        System.assert(account.Name != null);
        
    }
    
    static testMethod void createObjectWithUnsupportedTypeThrowsException() {
        
        try {
            
            Fon_TestDataFactory.createSObject('Unsupported');
            
            System.assert(false);
            
        } catch (Exception ex) {
            
            System.assert(true);
            
        }
        
    }
    
}