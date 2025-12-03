@isTest
private class DynamicLookupQueryBuilderTest {

    @IsTest
    static void testQueryRecords() {
        // Create test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact con = new Contact(FirstName = 'John', LastName = 'Doe', AccountId = acc.Id);
        insert con;

        // Set up parameters for the query
        String objectApiName = 'Contact';
        String displayField = 'Name';
        String parentFilterField = 'AccountId';
        String parentFilterValue = acc.Id;
        String parentFilterOperator = '=';
        String whereClause = '';
        String sortBy = 'LastName';
        String sortDirection = 'ASC';
        Integer maxResults = 10;
        String searchField = 'FirstName';
        String searchValue = 'John';
        String valueMatchType = 'partial';
        String valueFieldName = 'FirstName';

        // Call the method under test
        String result = DynamicLookupQueryBuilder.queryRecords(
            objectApiName,
            displayField,
            parentFilterField,
            parentFilterValue,
            parentFilterOperator,
            whereClause,
            sortBy,
            sortDirection,
            maxResults,
            searchField,
            searchValue,
            valueMatchType,
            valueFieldName
        );

        // Verify the result
        List<Contact> contacts = (List<Contact>) JSON.deserialize(result, List<Contact>.class);
        System.assertEquals(1, contacts.size());
        System.assertEquals(con.Id, contacts[0].Id);
    }

    @IsTest
    static void testGetSObjectDetails() {
        // Test with a valid object API name
        Map<String, Object> result = DynamicLookupQueryBuilder.getSObjectDetails('Account');
        System.assertEquals('Account', result.get('apiName'));

        // Test with an invalid object API name
        try {
            result = DynamicLookupQueryBuilder.getSObjectDetails('InvalidObject');
            // If the above line doesn't throw an exception, the test should fail
            System.assert(false, 'Expected AuraHandledException was not thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
}