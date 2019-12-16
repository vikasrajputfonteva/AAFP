global class TestObjects extends Framework.Domain {
   public TestObjects(List<Fon_Test_Object__c> sObjectList) {
       super(sObjectList);
   }
   global class Constructor implements Framework.Domain.DomainConstructor {
       public Framework.Domain construct(List<SObject> sObjectList) {
           return new TestObjects(sObjectList);
       }
   }
}