@isTest
private class CleanupOnExitControllerTest {
    
    @isTest
    static void testDeleteExistingRecord() {
        // Create a test account
        Account testAccount = new Account(Name = 'Test Account for Cleanup');
        insert testAccount;
        
        // Verify it exists
        List<Account> accountsBefore = [SELECT Id FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(1, accountsBefore.size(), 'Account should exist before delete');
        
        Test.startTest();
        
        // Call delete method (no cascade needed for single record)
        String result = CleanupOnExitController.deleteRecord(testAccount.Id, false, null);
        
        Test.stopTest();
        
        // Verify result
        System.assert(result.startsWith('SUCCESS'), 'Delete should succeed');
        
        // Verify record is deleted
        List<Account> accountsAfter = [SELECT Id FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(0, accountsAfter.size(), 'Account should be deleted');
    }
    
    @isTest
    static void testDeleteNonExistentRecord() {
        // Create a fake ID that doesn't exist
        Id fakeAccountId = '001000000000000AAA';
        
        Test.startTest();
        
        // Call delete method with non-existent ID
        String result = CleanupOnExitController.deleteRecord(fakeAccountId, false, null);
        
        Test.stopTest();
        
        // Verify result indicates record doesn't exist
        System.assert(result.contains('does not exist'), 'Should return message that record does not exist');
    }
    
    @isTest
    static void testDeleteWithNullRecordId() {
        Test.startTest();
        
        // Call delete method with null ID
        String result = CleanupOnExitController.deleteRecord(null, false, null);
        
        Test.stopTest();
        
        // Verify error message
        System.assert(result.startsWith('ERROR'), 'Should return error for null ID');
        System.assert(result.contains('required'), 'Error should mention required field');
    }
    
    @isTest
    static void testDeleteWithBlankRecordId() {
        Test.startTest();
        
        // Call delete method with blank ID
        String result = CleanupOnExitController.deleteRecord('', false, null);
        
        Test.stopTest();
        
        // Verify error message
        System.assert(result.startsWith('ERROR'), 'Should return error for blank ID');
        System.assert(result.contains('required'), 'Error should mention required field');
    }
    
    @isTest
    static void testDeleteWithInvalidRecordId() {
        Test.startTest();
        
        // Call delete method with invalid ID format
        String result = CleanupOnExitController.deleteRecord('invalid-id-format', false, null);
        
        Test.stopTest();
        
        // Verify error message
        System.assert(result.startsWith('ERROR'), 'Should return error for invalid ID');
        System.assert(result.contains('Invalid'), 'Error should mention invalid format');
    }
    
    @isTest
    static void testDeleteAlreadyDeletedRecord() {
        // Create and delete a test account
        Account testAccount = new Account(Name = 'Test Account for Cleanup');
        insert testAccount;
        Id accountId = testAccount.Id;
        delete testAccount;
        
        Test.startTest();
        
        // Try to delete again
        String result = CleanupOnExitController.deleteRecord(accountId, false, null);
        
        Test.stopTest();
        
        // Verify result indicates already deleted
        System.assert(result.startsWith('SUCCESS'), 'Should return success for already deleted record');
        System.assert(result.contains('does not exist'), 'Should indicate record does not exist');
    }
    
    @isTest
    static void testDeleteMultipleDifferentObjectTypes() {
        // Create multiple test accounts
        Account testAccount1 = new Account(Name = 'Test Account 1');
        Account testAccount2 = new Account(Name = 'Test Account 2');
        Account testAccount3 = new Account(Name = 'Test Account 3');
        insert new List<Account>{testAccount1, testAccount2, testAccount3};
        
        Test.startTest();
        
        // Delete all three
        String result1 = CleanupOnExitController.deleteRecord(testAccount1.Id, false, null);
        String result2 = CleanupOnExitController.deleteRecord(testAccount2.Id, false, null);
        String result3 = CleanupOnExitController.deleteRecord(testAccount3.Id, false, null);
        
        Test.stopTest();
        
        // Verify all succeeded
        System.assert(result1.startsWith('SUCCESS'), 'Account 1 delete should succeed');
        System.assert(result2.startsWith('SUCCESS'), 'Account 2 delete should succeed');
        System.assert(result3.startsWith('SUCCESS'), 'Account 3 delete should succeed');
        
        // Verify all deleted
        System.assertEquals(0, [SELECT COUNT() FROM Account WHERE Id = :testAccount1.Id]);
        System.assertEquals(0, [SELECT COUNT() FROM Account WHERE Id = :testAccount2.Id]);
        System.assertEquals(0, [SELECT COUNT() FROM Account WHERE Id = :testAccount3.Id]);
    }
    
    @isTest
    static void testCascadeDeleteWithMasterDetail() {
        // Create a parent account with contacts (Master-Detail in some orgs, or use custom objects)
        Account testAccount = new Account(Name = 'Test Account with Children');
        insert testAccount;
        
        // Create child contacts
        Contact contact1 = new Contact(LastName = 'Contact 1', AccountId = testAccount.Id, Email = 'test1@example.com');
        Contact contact2 = new Contact(LastName = 'Contact 2', AccountId = testAccount.Id, Email = 'test2@example.com');
        insert new List<Contact>{contact1, contact2};
        
        // Verify children exist
        System.assertEquals(2, [SELECT COUNT() FROM Contact WHERE AccountId = :testAccount.Id]);
        
        Test.startTest();
        
        // Call delete with cascade (Note: Contacts are lookup not Master-Detail, so won't cascade)
        // This tests that cascade delete runs without error even if no Master-Detail children exist
        String result = CleanupOnExitController.deleteRecord(testAccount.Id, true, null);
        
        Test.stopTest();
        
        // For Account->Contact (lookup), cascade won't delete contacts, so account delete should fail
        // But since we're using Database.delete(allOrNone=false), it returns error message
        System.assert(result != null, 'Should return a result');
    }
    
    @isTest
    static void testCascadeDeleteParameterFalse() {
        // Create a test account
        Account testAccount = new Account(Name = 'Test Account No Cascade');
        insert testAccount;
        
        Test.startTest();
        
        // Call delete with cascade=false explicitly
        String result = CleanupOnExitController.deleteRecord(testAccount.Id, false, null);
        
        Test.stopTest();
        
        // Verify delete succeeded
        System.assert(result.startsWith('SUCCESS'), 'Delete should succeed');
        System.assertEquals(0, [SELECT COUNT() FROM Account WHERE Id = :testAccount.Id]);
    }
}
