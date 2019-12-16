trigger TopicContactAssignmentRollup on TopicAssignment(after insert, after delete) {
	/*
	  TopicContactAssignmentRollup: This trigger fires after any change to a Contact's Topic Assignment.
	  It will read the Topics assigned to this Contact and put them in a denormalized field on the Contact Object.
	  This is so the Topic list can be used in Reports.  Currently Salesforce does not support showing Topics in its reports.
	 */

	list<TopicAssignment> topicAssignments = new list<TopicAssignment> ();

	// User old for deletes and new for everything else.
	if (Trigger.isDelete)
	{
		topicAssignments = Trigger.old;
	} else
	{
		topicAssignments = Trigger.new;
	}

	List<Contact> myContacts = new List<Contact> { };

	for (TopicAssignment myTopic : topicAssignments)
	{
		List<TopicAssignment> topicList = [SELECT Topic.name FROM TopicAssignment where EntityType = 'Contact' and EntityId = :myTopic.EntityId];
		// Initially set the topic list to blank
		String topicListDN = '';
		Integer firstRecordFlag = 0;
		for (TopicAssignment t : topicList) {
			if (firstRecordFlag == 0)
			{
				topicListDN += t.Topic.Name;
				firstRecordFlag = 1;
			} else
			{
				topicListDN += ', ' + t.Topic.Name;
			}
		}
		Contact myContact = [SELECT Id, AAFP_Topic_List__c FROM Contact where Id = :myTopic.EntityId];
		myContact.AAFP_Topic_List__c = topicListDN;
		myContacts.add(myContact);
	}

	if (myContacts.size() > 0) {
		update myContacts;
	}
}