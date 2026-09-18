@IsTest
private class FlowCollectionFilterTest {

    private static List<SObject> toSObjectList(List<Account> accs) {
        List<SObject> sobjs = new List<SObject>();
        for (Account a : accs) sobjs.add(a);
        return sobjs;
    }

    @IsTest
    static void testFilter_exactMatch() {
        List<Account> accs = new List<Account>{
            new Account(Name = 'Alpha'),
                new Account(Name = 'Beta'),
                new Account(Name = 'Alpha')
                };

                    FlowCollectionFilter.Request req = new FlowCollectionFilter.Request();
        req.records = toSObjectList(accs);
        req.fieldApiName = 'Name';
        req.targetValue = 'Alpha';
        req.caseSensitive = false;
        req.partialMatch = false;

        List<FlowCollectionFilter.Response> resList = FlowCollectionFilter.filterCollection(
            new List<FlowCollectionFilter.Request>{req}
        );

        FlowCollectionFilter.Response res = resList[0];
        System.assertEquals(2, res.matchCount);
        System.assertEquals(2, res.filteredRecords.size());
        System.assertNotEquals(null, res.firstRecord);
        System.assertEquals('Alpha', (String)res.firstRecord.get('Name'));
    }

    @IsTest
    static void testFilter_partialMatch() {
        List<Account> accs = new List<Account>{
            new Account(Name = 'Acme Tools'),
                new Account(Name = 'Acme Supplies'),
                new Account(Name = 'Global Corp')
                };

                    FlowCollectionFilter.Request req = new FlowCollectionFilter.Request();
        req.records = toSObjectList(accs);
        req.fieldApiName = 'Name';
        req.targetValue = 'Acme';
        req.partialMatch = true;

        List<FlowCollectionFilter.Response> resList = FlowCollectionFilter.filterCollection(
            new List<FlowCollectionFilter.Request>{req}
        );

        FlowCollectionFilter.Response res = resList[0];
        System.assertEquals(2, res.matchCount);
        System.assert(res.firstRecord != null);
        System.assert(((String)res.firstRecord.get('Name')).contains('Acme'));
    }

    @IsTest
    static void testFilter_noMatches() {
        List<Account> accs = new List<Account>{
            new Account(Name = 'A'),
                new Account(Name = 'B')
                };

                    FlowCollectionFilter.Request req = new FlowCollectionFilter.Request();
        req.records = toSObjectList(accs);
        req.fieldApiName = 'Name';
        req.targetValue = 'Z';

        List<FlowCollectionFilter.Response> resList = FlowCollectionFilter.filterCollection(
            new List<FlowCollectionFilter.Request>{req}
        );

        FlowCollectionFilter.Response res = resList[0];
        System.assertEquals(0, res.matchCount);
        System.assertEquals(true, res.filteredRecords.isEmpty());
        System.assertEquals(null, res.firstRecord);
    }

    @IsTest
    static void testFilter_nullTargetValue() {
        List<Account> accs = new List<Account>{
            new Account(Name = null),
                new Account(Name = ''),
                new Account(Name = 'Acme')
                };

                    FlowCollectionFilter.Request req = new FlowCollectionFilter.Request();
        req.records = toSObjectList(accs);
        req.fieldApiName = 'Name';
        req.targetValue = null; // looking for blank names

        List<FlowCollectionFilter.Response> resList = FlowCollectionFilter.filterCollection(
            new List<FlowCollectionFilter.Request>{req}
        );

        FlowCollectionFilter.Response res = resList[0];
        System.assertEquals(2, res.matchCount, 'Should match null and blank Name');
    }

    @IsTest
    static void testFilter_notBlank() {
        List<Account> accs = new List<Account>{
            new Account(Name = 'Acme'),
                new Account(Name = null),
                new Account(Name = '')
                };

                    FlowCollectionFilter.Request req = new FlowCollectionFilter.Request();
        req.records = toSObjectList(accs);
        req.fieldApiName = 'Name';
        req.targetValue = null;
        req.invertMatch = true; // NOT blank/null

        List<FlowCollectionFilter.Response> resList = FlowCollectionFilter.filterCollection(
            new List<FlowCollectionFilter.Request>{req}
        );

        FlowCollectionFilter.Response res = resList[0];
        System.assertEquals(1, res.matchCount, 'Should only match the non-blank record');
    }

    @IsTest
    static void testFilter_relationshipField() {
        // Create test data with relationships
        Account acc1 = new Account(Name = 'Acme Corp');
        Account acc2 = new Account(Name = 'Global Inc');
        insert new List<Account>{acc1, acc2};

        Contact con1 = new Contact(FirstName = 'John', LastName = 'Doe', AccountId = acc1.Id);
        Contact con2 = new Contact(FirstName = 'Jane', LastName = 'Smith', AccountId = acc2.Id);
        Contact con3 = new Contact(FirstName = 'Bob', LastName = 'Jones', AccountId = acc1.Id);
        insert new List<Contact>{con1, con2, con3};

        // Query contacts with Account relationship
        List<Contact> contacts = [SELECT Id, FirstName, LastName, Account.Name FROM Contact WHERE Id IN :new List<Id>{con1.Id, con2.Id, con3.Id}];
        List<SObject> sobjs = new List<SObject>();
        for (Contact c : contacts) {
            sobjs.add(c);
        }

        // Test filtering by relationship field
        FlowCollectionFilter.Request req = new FlowCollectionFilter.Request();
        req.records = sobjs;
        req.fieldApiName = 'Account.Name';
        req.targetValue = 'Acme Corp';
        req.caseSensitive = false;
        req.partialMatch = false;

        List<FlowCollectionFilter.Response> resList = FlowCollectionFilter.filterCollection(
            new List<FlowCollectionFilter.Request>{req}
        );

        FlowCollectionFilter.Response res = resList[0];
        System.assertEquals(2, res.matchCount, 'Should match 2 contacts with Account.Name = Acme Corp');
        System.assertEquals(2, res.filteredRecords.size());
        System.assertNotEquals(null, res.firstRecord);
    }

    @IsTest
    static void testFilter_relationshipField_null() {
        // Create contact without account
        Contact con1 = new Contact(FirstName = 'John', LastName = 'Doe');
        insert con1;

        // Query contact with Account relationship (will be null)
        List<Contact> contacts = [SELECT Id, FirstName, LastName, Account.Name FROM Contact WHERE Id = :con1.Id];
        List<SObject> sobjs = new List<SObject>();
        for (Contact c : contacts) {
            sobjs.add(c);
        }

        // Test filtering for null relationship field
        FlowCollectionFilter.Request req = new FlowCollectionFilter.Request();
        req.records = sobjs;
        req.fieldApiName = 'Account.Name';
        req.targetValue = null;

        List<FlowCollectionFilter.Response> resList = FlowCollectionFilter.filterCollection(
            new List<FlowCollectionFilter.Request>{req}
        );

        FlowCollectionFilter.Response res = resList[0];
        System.assertEquals(1, res.matchCount, 'Should match contact with null Account.Name');
    }

    @IsTest
    static void testFilter_multipleFields_AND() {
        List<Account> accs = new List<Account>{
            new Account(Name = 'Acme Corp', Industry = 'Technology'),
            new Account(Name = 'Acme Inc', Industry = 'Manufacturing'),
            new Account(Name = 'Global Corp', Industry = 'Technology')
        };

        FlowCollectionFilter.Request req = new FlowCollectionFilter.Request();
        req.records = toSObjectList(accs);
        req.fieldApiName = 'Name';
        req.targetValue = 'Acme';
        req.partialMatch = true;
        req.additionalFields = 'Industry';
        req.additionalValues = 'Technology';
        req.matchLogic = 'AND';

        List<FlowCollectionFilter.Response> resList = FlowCollectionFilter.filterCollection(
            new List<FlowCollectionFilter.Request>{req}
        );

        FlowCollectionFilter.Response res = resList[0];
        System.assertEquals(1, res.matchCount, 'Should match only Acme Corp with Technology');
        System.assertEquals('Acme Corp', (String)res.firstRecord.get('Name'));
    }

    @IsTest
    static void testFilter_multipleFields_OR() {
        List<Account> accs = new List<Account>{
            new Account(Name = 'Acme Corp', Industry = 'Technology'),
            new Account(Name = 'Beta Inc', Industry = 'Manufacturing'),
            new Account(Name = 'Global Corp', Industry = 'Technology')
        };

        FlowCollectionFilter.Request req = new FlowCollectionFilter.Request();
        req.records = toSObjectList(accs);
        req.fieldApiName = 'Name';
        req.targetValue = 'Acme';
        req.partialMatch = true;
        req.additionalFields = 'Industry';
        req.additionalValues = 'Manufacturing';
        req.matchLogic = 'OR';

        List<FlowCollectionFilter.Response> resList = FlowCollectionFilter.filterCollection(
            new List<FlowCollectionFilter.Request>{req}
        );

        FlowCollectionFilter.Response res = resList[0];
        System.assertEquals(2, res.matchCount, 'Should match Acme Corp OR Beta Inc');
    }

    @IsTest
    static void testFilter_multipleFields_threeFields() {
        List<Account> accs = new List<Account>{
            new Account(Name = 'Test1', Industry = 'Tech', Type = 'Customer'),
            new Account(Name = 'Test2', Industry = 'Tech', Type = 'Partner'),
            new Account(Name = 'Test3', Industry = 'Finance', Type = 'Customer')
        };

        FlowCollectionFilter.Request req = new FlowCollectionFilter.Request();
        req.records = toSObjectList(accs);
        req.fieldApiName = 'Name';
        req.targetValue = 'Test';
        req.partialMatch = true;
        req.additionalFields = 'Industry,Type';
        req.additionalValues = 'Tech,Customer';
        req.matchLogic = 'AND';

        List<FlowCollectionFilter.Response> resList = FlowCollectionFilter.filterCollection(
            new List<FlowCollectionFilter.Request>{req}
        );

        FlowCollectionFilter.Response res = resList[0];
        System.assertEquals(1, res.matchCount, 'Should match only Test1 (Tech AND Customer)');
        System.assertEquals('Test1', (String)res.firstRecord.get('Name'));
    }

    @IsTest
    static void testFilter_multipleFields_defaultAND() {
        List<Account> accs = new List<Account>{
            new Account(Name = 'AA', Industry = 'Tech'),
            new Account(Name = 'AB', Industry = 'Finance')
        };

        FlowCollectionFilter.Request req = new FlowCollectionFilter.Request();
        req.records = toSObjectList(accs);
        req.fieldApiName = 'Name';
        req.targetValue = 'A';
        req.partialMatch = true;
        req.additionalFields = 'Industry';
        req.additionalValues = 'Tech';
        // matchLogic not specified - should default to AND

        List<FlowCollectionFilter.Response> resList = FlowCollectionFilter.filterCollection(
            new List<FlowCollectionFilter.Request>{req}
        );

        FlowCollectionFilter.Response res = resList[0];
        System.assertEquals(1, res.matchCount, 'Should default to AND logic');
    }


}
