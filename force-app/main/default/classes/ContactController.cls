public with sharing class ContactController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(Id accountId) {
        if (accountId == null) {
            // This check prevents a query for a null AccountId
            throw new AuraHandledException('Account ID cannot be null.');
        }
        try {
            return [
                SELECT Id, Name, Title, Phone, Email
                FROM Contact
                WHERE AccountId = :accountId
                WITH SECURITY_ENFORCED
                ORDER BY Name
                LIMIT 10
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
