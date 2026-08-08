@isTest
private class ContactControllerTest {

    @TestSetup
    static void makeData(){
        Account acc = new Account(Name='Test Account');
        insert acc;

        List<Contact> contactsToInsert = new List<Contact>();
        for(Integer i=0; i<5; i++){
            contactsToInsert.add(new Contact(
                FirstName='Test',
                LastName='Contact ' + i,
                AccountId=acc.Id
            ));
        }
        insert contactsToInsert;

        Account accWithNoContacts = new Account(Name='No Contact Account');
        insert accWithNoContacts;
    }

    @isTest
    static void testGetContacts_ReturnsContacts() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];

        Test.startTest();
        List<Contact> result = ContactController.getContacts(acc.Id);
        Test.stopTest();

        System.assertEquals(5, result.size(), 'Should return 5 contacts');
        System.assertEquals('Test Contact 0', result[0].Name, 'First contact name should be "Test Contact 0"');
    }

    @isTest
    static void testGetContacts_NoContacts() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'No Contact Account' LIMIT 1];

        Test.startTest();
        List<Contact> result = ContactController.getContacts(acc.Id);
        AccountController.syncAccount(new List<Id>{ acc.Id });
        try{
            List<Contact> result1 = ContactController.getContacts(null);
        } catch(Exception ex){
            
        }
        
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return 0 contacts');
    }
}