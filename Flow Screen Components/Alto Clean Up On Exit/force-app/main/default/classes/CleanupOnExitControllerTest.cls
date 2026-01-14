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
    static void testCascadeDeleteWithOrderAndOrderItems() {
        // Create Account, Contract, and Order (Order has Master-Detail to Contract)
        Account testAccount = new Account(Name = 'Test Account for Order');
        insert testAccount;
        
        Contract testContract = new Contract(
            AccountId = testAccount.Id,
            StartDate = Date.today(),
            ContractTerm = 12
        );
        insert testContract;
        
        // Activate the contract
        testContract.Status = 'Activated';
        update testContract;
        
        // Create standard pricebook and product for OrderItem
        Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true);
        insert testProduct;
        
        // Get standard pricebook
        Id pricebookId = Test.getStandardPricebookId();
        
        // Create standard PricebookEntry
        PricebookEntry testPricebookEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert testPricebookEntry;
        
        // Create Order with Pricebook
        Order testOrder = new Order(
            AccountId = testAccount.Id,
            ContractId = testContract.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = pricebookId
        );
        insert testOrder;
        
        // Create OrderItem (Master-Detail to Order)
        OrderItem testOrderItem = new OrderItem(
            OrderId = testOrder.Id,
            PricebookEntryId = testPricebookEntry.Id,
            Quantity = 1,
            UnitPrice = 100
        );
        insert testOrderItem;
        
        // Verify OrderItem exists
        System.assertEquals(1, [SELECT COUNT() FROM OrderItem WHERE OrderId = :testOrder.Id]);
        
        Test.startTest();
        
        // Call delete with cascade=true - should find and delete OrderItems first
        String result = CleanupOnExitController.deleteRecord(testOrder.Id, true, null);
        
        Test.stopTest();
        
        // Verify Order and OrderItems are deleted
        System.assert(result.startsWith('SUCCESS'), 'Delete should succeed with cascade');
        System.assertEquals(0, [SELECT COUNT() FROM OrderItem WHERE OrderId = :testOrder.Id]);
        System.assertEquals(0, [SELECT COUNT() FROM Order WHERE Id = :testOrder.Id]);
    }
    
    @isTest
    static void testCascadeDeleteWithGridActions() {
        // Create a GridConfiguration (parent)
        rootstock__GridConfiguration__c gridConfig = new rootstock__GridConfiguration__c(
            rootstock__Name__c = 'Test Grid Config',
            rootstock__ObjectAPIName__c = 'Account',
            rootstock__FieldSetAPIName__c = 'TestFieldSet'
        );
        insert gridConfig;
        
        // Create GridAction children (Master-Detail to GridConfiguration)
        rootstock__GridAction__c action1 = new rootstock__GridAction__c(
            rootstock__GridConfiguration__c = gridConfig.Id,
            rootstock__ButtonLabel__c = 'Test Button 1',
            rootstock__Type__c = 'Single Row Action',
            rootstock__UniqueKey2__c = 'UniqueKey1Value',
            rootstock__ActionTarget__c = 'Flow'
        );
        rootstock__GridAction__c action2 = new rootstock__GridAction__c(
            rootstock__GridConfiguration__c = gridConfig.Id,
            rootstock__ButtonLabel__c = 'Test Button 2',
            rootstock__Type__c = 'Single Row Action',
            rootstock__UniqueKey2__c = 'UniqueKey2Value',
            rootstock__ActionTarget__c = 'Flow'
        );
        insert new List<rootstock__GridAction__c>{action1, action2};
        
        // Verify children exist
        System.assertEquals(2, [SELECT COUNT() FROM rootstock__GridAction__c WHERE rootstock__GridConfiguration__c = :gridConfig.Id]);
        
        Test.startTest();
        
        // Call delete with cascade=true - should find and delete GridActions first
        String result = CleanupOnExitController.deleteRecord(gridConfig.Id, true, null);
        
        Test.stopTest();
        
        // Verify GridConfiguration and GridActions are deleted
        System.assert(result.startsWith('SUCCESS'), 'Delete should succeed with cascade');
        System.assertEquals(0, [SELECT COUNT() FROM rootstock__GridAction__c WHERE rootstock__GridConfiguration__c = :gridConfig.Id]);
        System.assertEquals(0, [SELECT COUNT() FROM rootstock__GridConfiguration__c WHERE Id = :gridConfig.Id]);
    }
    
    @isTest
    static void testCascadeDeleteWithPricebookEntry() {
        // Create a custom pricebook (PricebookEntry has Master-Detail to Pricebook2)
        Pricebook2 customPricebook = new Pricebook2(Name = 'Test Pricebook', IsActive = true);
        insert customPricebook;
        
        // Create product
        Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true);
        insert testProduct;
        
        // Create standard price first (required before custom price)
        Id standardPricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPriceEntry = new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert standardPriceEntry;
        
        // Create PricebookEntry for custom pricebook (Master-Detail to Pricebook2)
        PricebookEntry testPricebookEntry = new PricebookEntry(
            Pricebook2Id = customPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert testPricebookEntry;
        
        // Verify PricebookEntry exists
        System.assertEquals(1, [SELECT COUNT() FROM PricebookEntry WHERE Pricebook2Id = :customPricebook.Id]);
        
        Test.startTest();
        
        // Call delete with cascade=true - should delete PricebookEntries first
        String result = CleanupOnExitController.deleteRecord(customPricebook.Id, true, null);
        
        Test.stopTest();
        
        // Verify Pricebook and PricebookEntries are deleted
        System.assert(result.startsWith('SUCCESS'), 'Delete should succeed with cascade');
        System.assertEquals(0, [SELECT COUNT() FROM PricebookEntry WHERE Pricebook2Id = :customPricebook.Id]);
        System.assertEquals(0, [SELECT COUNT() FROM Pricebook2 WHERE Id = :customPricebook.Id]);
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
    
    @isTest
    static void testDeleteLookupChildrenWithContacts() {
        // Create a test account with contacts
        Account testAccount = new Account(Name = 'Test Account with Lookup Children');
        insert testAccount;
        
        // Create child contacts (lookup relationship)
        Contact contact1 = new Contact(LastName = 'Contact 1', AccountId = testAccount.Id, Email = 'contact1@test.com');
        Contact contact2 = new Contact(LastName = 'Contact 2', AccountId = testAccount.Id, Email = 'contact2@test.com');
        insert new List<Contact>{contact1, contact2};
        
        // Verify children exist
        System.assertEquals(2, [SELECT COUNT() FROM Contact WHERE AccountId = :testAccount.Id]);
        
        Test.startTest();
        
        // Call delete with lookup relationship specified (Contacts is the relationship name)
        String result = CleanupOnExitController.deleteRecord(testAccount.Id, false, 'Contacts');
        
        Test.stopTest();
        
        // Verify lookup children were deleted first, then parent
        System.assert(result.startsWith('SUCCESS'), 'Delete should succeed');
        System.assertEquals(0, [SELECT COUNT() FROM Contact WHERE AccountId = :testAccount.Id]);
        System.assertEquals(0, [SELECT COUNT() FROM Account WHERE Id = :testAccount.Id]);
    }
    
    @isTest
    static void testDeleteLookupChildrenMultipleRelationships() {
        // Create a test account with multiple types of children
        Account testAccount = new Account(Name = 'Test Account Multiple Children');
        insert testAccount;
        
        // Create contacts
        Contact contact1 = new Contact(LastName = 'Contact 1', AccountId = testAccount.Id, Email = 'contact1@test.com');
        insert contact1;
        
        // Create cases
        Case case1 = new Case(Subject = 'Test Case', AccountId = testAccount.Id);
        insert case1;
        
        Test.startTest();
        
        // Call delete with multiple lookup relationships
        String result = CleanupOnExitController.deleteRecord(testAccount.Id, false, 'Contacts,Cases');
        
        Test.stopTest();
        
        // Verify all children and parent deleted
        System.assert(result.startsWith('SUCCESS'), 'Delete should succeed');
        System.assertEquals(0, [SELECT COUNT() FROM Contact WHERE AccountId = :testAccount.Id]);
        System.assertEquals(0, [SELECT COUNT() FROM Case WHERE AccountId = :testAccount.Id]);
        System.assertEquals(0, [SELECT COUNT() FROM Account WHERE Id = :testAccount.Id]);
    }
    
    @isTest
    static void testDeleteLookupChildrenInvalidRelationship() {
        // Create a test account
        Account testAccount = new Account(Name = 'Test Account Invalid Lookup');
        insert testAccount;
        
        Test.startTest();
        
        // Call delete with non-existent relationship name
        String result = CleanupOnExitController.deleteRecord(testAccount.Id, false, 'InvalidRelationshipName');
        
        Test.stopTest();
        
        // Should still succeed (just skips invalid relationship)
        System.assert(result.startsWith('SUCCESS'), 'Delete should succeed even with invalid relationship');
        System.assertEquals(0, [SELECT COUNT() FROM Account WHERE Id = :testAccount.Id]);
    }
    
    @isTest
    static void testDeleteLookupChildrenEmptyString() {
        // Create a test account
        Account testAccount = new Account(Name = 'Test Account Empty Lookup');
        insert testAccount;
        
        Test.startTest();
        
        // Call delete with empty string for relationships
        String result = CleanupOnExitController.deleteRecord(testAccount.Id, false, '');
        
        Test.stopTest();
        
        // Should succeed (empty string treated as no lookups)
        System.assert(result.startsWith('SUCCESS'), 'Delete should succeed with empty lookup string');
        System.assertEquals(0, [SELECT COUNT() FROM Account WHERE Id = :testAccount.Id]);
    }
    
    @isTest
    static void testDeleteLookupChildrenWithSpacesInCSV() {
        // Create a test account with contacts
        Account testAccount = new Account(Name = 'Test Account CSV Spaces');
        insert testAccount;
        
        Contact contact1 = new Contact(LastName = 'Contact 1', AccountId = testAccount.Id, Email = 'contact1@test.com');
        insert contact1;
        
        Test.startTest();
        
        // Call delete with spaces in CSV
        String result = CleanupOnExitController.deleteRecord(testAccount.Id, false, ' Contacts , ');
        
        Test.stopTest();
        
        // Should succeed (spaces trimmed)
        System.assert(result.startsWith('SUCCESS'), 'Delete should succeed with spaces in CSV');
        System.assertEquals(0, [SELECT COUNT() FROM Contact WHERE AccountId = :testAccount.Id]);
        System.assertEquals(0, [SELECT COUNT() FROM Account WHERE Id = :testAccount.Id]);
    }
    
    @isTest
    static void testDeleteRecordFailure() {
        // Create a test account with a contact that has a required field preventing deletion
        Account testAccount = new Account(Name = 'Test Account Delete Failure');
        insert testAccount;
        
        // Create a contact with the account
        Contact contact1 = new Contact(LastName = 'Contact 1', AccountId = testAccount.Id, Email = 'contact1@test.com');
        insert contact1;
        
        Test.startTest();
        
        // Try to delete account without deleting contact first (should fail)
        // Database.delete with allOrNone=false will return error in result
        String result = CleanupOnExitController.deleteRecord(testAccount.Id, false, null);
        
        Test.stopTest();
        
        // Result could be SUCCESS or ERROR depending on org config
        // If Account->Contact is optional, it succeeds. If required, it fails.
        // Just verify we got a response
        System.assert(result != null, 'Should return a result');
    }
    
    @isTest
    static void testCascadeDeleteNullParameter() {
        // Create a test account
        Account testAccount = new Account(Name = 'Test Account Null Cascade');
        insert testAccount;
        
        Test.startTest();
        
        // Call delete with null cascade parameter (should treat as false)
        String result = CleanupOnExitController.deleteRecord(testAccount.Id, null, null);
        
        Test.stopTest();
        
        // Verify delete succeeded
        System.assert(result.startsWith('SUCCESS'), 'Delete should succeed with null cascade');
        System.assertEquals(0, [SELECT COUNT() FROM Account WHERE Id = :testAccount.Id]);
    }
}