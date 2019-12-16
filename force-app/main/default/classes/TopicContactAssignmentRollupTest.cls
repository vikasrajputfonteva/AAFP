@isTest
private class TopicContactAssignmentRollupTest {

    @isTest
    private static void insertTopic() {     
        // Create MOCK topic
        Topic testTopic = new Topic();
        testTopic.name = 'UNIT TEST';
        insert testTopic;

        // Create MOCK Contact
        Contact testContact = new Contact();
        testContact.FirstName = 'UNIT TEST';
        testContact.LastName = 'UNIT TEST';
        insert testContact;
        
        // Assign MOCK topic to MOCK contact
        TopicAssignment testTopicAssignment = new TopicAssignment();
        testTopicAssignment.EntityId = testContact.Id;
        testTopicAssignment.TopicId = testTopic.Id;
        //testTopicAssignment.EntityType = 'Contact';
        insert testTopicAssignment;

        // Check if the topics were updated on the Contact
        Contact myContact = [select AAFP_Topic_List__c from Contact where Id = :testContact.Id];
        //System.assertEquals('', '');  
        System.assertEquals(myContact.AAFP_Topic_List__c, 'UNIT TEST');  
    }

    @isTest
    private static void deleteTopic() {
        // Create MOCK topic
        Topic testTopic = new Topic();
        testTopic.name = 'UNIT TEST';
        insert testTopic;

        // Create MOCK Contact
        Contact testContact = new Contact();
        testContact.FirstName = 'UNIT TEST';
        testContact.LastName = 'UNIT TEST';     
        insert testContact;
                
        // Assign MOCK topic to MOCK contact
        TopicAssignment testTopicAssignment = new TopicAssignment();
        testTopicAssignment.EntityId = testContact.Id;
        testTopicAssignment.TopicId = testTopic.Id;
        //testTopicAssignment.EntityType = 'Contact';
        insert testTopicAssignment;
        
        // Check if the topics were updated on the Contact
        Contact myContact = [select AAFP_Topic_List__c from Contact where Id = :testContact.Id];
        String insertTopicResult = myContact.AAFP_Topic_List__c;

        // Delete the Topic
        TopicAssignment testTopicAssignmentToDelelete = [select Id from TopicAssignment where Id = :testTopicAssignment.Id];        
        delete testTopicAssignmentToDelelete;
        
        // Pull the contact again to see if the topic is gone
        // This test ensures there topic was there AND is now gone
        Contact myContactForDelete = [select AAFP_Topic_List__c from Contact where Id = :testContact.Id];
//                System.assertEquals('', '');  

        System.assert( 
                      (myContact.AAFP_Topic_List__c == 'UNIT TEST' 
                         && 
                       String.isBlank(myContactForDelete.AAFP_Topic_List__c)) 
                      );  
                      
    }
}