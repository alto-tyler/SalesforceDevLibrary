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
            System.assert(false, 'Expected AuraHandledException was not thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    @IsTest
    static void testGetSObjectDetailsBlankThrows() {
        try {
            DynamicLookupQueryBuilder.getSObjectDetails('');
            System.assert(false, 'Expected exception not thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    @IsTest
    static void testBuildQueryNullParamsThrows() {
        try {
            DynamicLookupQueryBuilder.buildQuery(null);
            System.assert(false, 'Expected exception not thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    @IsTest
    static void testBuildQueryBlankObjectApiNameThrows() {
        DynamicLookupQueryBuilder.QueryParams params = new DynamicLookupQueryBuilder.QueryParams();
        params.objectApiName = '';
        try {
            DynamicLookupQueryBuilder.buildQuery(params);
            System.assert(false, 'Expected exception not thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    @IsTest
    static void testExactMatchSearch() {
        Account acc = new Account(Name = 'ExactSearchAcct');
        insert acc;

        String result = DynamicLookupQueryBuilder.queryRecords(
            'Account', 'Name', null, null, null, null,
            null, null, 10, 'Name', 'ExactSearchAcct', 'exact', null
        );

        List<Account> accounts = (List<Account>) JSON.deserialize(result, List<Account>.class);
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    static void testInvalidValueMatchTypeThrows() {
        DynamicLookupQueryBuilder.QueryParams params = new DynamicLookupQueryBuilder.QueryParams();
        params.objectApiName = 'Account';
        params.searchField = 'Name';
        params.searchValue = 'test';
        params.valueMatchType = 'invalid_type';
        try {
            DynamicLookupQueryBuilder.buildQuery(params);
            System.assert(false, 'Expected exception not thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    @IsTest
    static void testSearchFieldNotOnObjectThrows() {
        DynamicLookupQueryBuilder.QueryParams params = new DynamicLookupQueryBuilder.QueryParams();
        params.objectApiName = 'Account';
        params.searchField = 'NonExistentField__xyz';
        params.searchValue = 'test';
        try {
            DynamicLookupQueryBuilder.buildQuery(params);
            System.assert(false, 'Expected exception not thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }

    @IsTest
    static void testWhereClauseAppended() {
        Account acc = new Account(Name = 'WhereClauseAcct', BillingCity = 'Toronto');
        insert acc;

        String result = DynamicLookupQueryBuilder.queryRecords(
            'Account', 'Name', null, null, null,
            'BillingCity = \'Toronto\'',
            null, null, 10, null, null, null, null
        );

        List<Account> accounts = (List<Account>) JSON.deserialize(result, List<Account>.class);
        System.assert(accounts.size() >= 1);
    }

    @IsTest
    static void testParentFilterInOperator() {
        Account a1 = new Account(Name = 'InFilter1');
        Account a2 = new Account(Name = 'InFilter2');
        insert new List<Account>{ a1, a2 };

        // Use Name field (String type) with IN operator
        String result = DynamicLookupQueryBuilder.queryRecords(
            'Account', 'Name', 'Name', 'InFilter1,InFilter2', 'IN',
            null, null, null, 10, null, null, null, null
        );

        List<Account> accounts = (List<Account>) JSON.deserialize(result, List<Account>.class);
        System.assertEquals(2, accounts.size());
    }

    @IsTest
    static void testParentFilterNotInOperator() {
        Account acc = new Account(Name = 'NotInFilterAcct');
        insert acc;

        // Exclude the record by name using NOT IN
        String result = DynamicLookupQueryBuilder.queryRecords(
            'Account', 'Name', 'Name', 'NotInFilterAcct', 'NOT IN',
            null, null, null, 10, null, null, null, null
        );

        List<Account> accounts = (List<Account>) JSON.deserialize(result, List<Account>.class);
        for (Account a : accounts) {
            System.assertNotEquals('NotInFilterAcct', a.Name);
        }
    }

    @IsTest
    static void testParentFilterLikeOperator() {
        Account acc = new Account(Name = 'LikeFilterAcct');
        insert acc;

        String result = DynamicLookupQueryBuilder.queryRecords(
            'Account', 'Name', 'Name', 'LikeFilter', 'LIKE',
            null, null, null, 10, null, null, null, null
        );

        List<Account> accounts = (List<Account>) JSON.deserialize(result, List<Account>.class);
        System.assert(accounts.size() >= 1);
    }

    @IsTest
    static void testParentFilterLikeOperatorWithWildcard() {
        Account acc = new Account(Name = 'LikeWildcardAcct');
        insert acc;

        // Value already contains %, should not double-wrap
        String result = DynamicLookupQueryBuilder.queryRecords(
            'Account', 'Name', 'Name', '%LikeWildcard%', 'LIKE',
            null, null, null, 10, null, null, null, null
        );

        List<Account> accounts = (List<Account>) JSON.deserialize(result, List<Account>.class);
        System.assert(accounts.size() >= 1);
    }

    @IsTest
    static void testParentFilterInNumericField() {
        // NumberOfEmployees is an Integer field (non-String) — covers the 'else' branch in IN loop
        Account acc = new Account(Name = 'NumericInAcct', NumberOfEmployees = 5);
        insert acc;

        String result = DynamicLookupQueryBuilder.queryRecords(
            'Account', 'Name', 'NumberOfEmployees', '5', 'IN',
            null, null, null, 10, null, null, null, null
        );

        List<Account> accounts = (List<Account>) JSON.deserialize(result, List<Account>.class);
        System.assert(accounts.size() >= 1);
    }

    @IsTest
    static void testNoSortByStillReturnsResults() {
        Account acc = new Account(Name = 'NoSortAcct');
        insert acc;

        // No sortBy, no maxResults → no ORDER BY or LIMIT added
        String result = DynamicLookupQueryBuilder.queryRecords(
            'Account', 'Name', null, null, null, null,
            null, null, null, null, null, null, null
        );

        List<Account> accounts = (List<Account>) JSON.deserialize(result, List<Account>.class);
        System.assert(accounts.size() >= 1);
    }
}