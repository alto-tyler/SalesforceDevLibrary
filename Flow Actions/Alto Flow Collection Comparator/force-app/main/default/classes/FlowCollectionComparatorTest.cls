@IsTest
private class FlowCollectionComparatorTest {

    private static List<SObject> toSObjectList(List<Account> accs) {
        List<SObject> sobjs = new List<SObject>();
        for (Account a : accs) sobjs.add(a);
        return sobjs;
    }

    @IsTest
    static void testCompareCollections_basic() {
        // Primary (e.g. Quote Line Items)
        List<Account> primary = new List<Account>{
            new Account(Name = 'A_Test'),
            new Account(Name = 'B_Test'),
            new Account(Name = 'C_Test')
        };
                    
        // Secondary (e.g. Product Master)
        List<Account> secondary = new List<Account>{
        	new Account(Name = 'A_Test'),
            new Account(Name = 'X_Test')
        };
                                
        // No insert needed — we just use the in-memory records
        FlowCollectionComparator.Request req = new FlowCollectionComparator.Request();
        req.primaryRecords = toSObjectList(primary);
        req.secondaryRecords = toSObjectList(secondary);
        req.primaryFieldApiName = 'Name';
        req.secondaryFieldApiName = 'Name';
        req.caseSensitive = false;
        
        List<FlowCollectionComparator.Response> responses = FlowCollectionComparator.compareCollections(
            new List<FlowCollectionComparator.Request>{req}
        );
        
        FlowCollectionComparator.Response res = responses[0];
        System.assertEquals(1, res.matchCount, 'Should find 1 match (A_Test)');
        System.assertEquals(2, res.nonMatchCount, 'Should find 2 non-matches (B_Test, C_Test)');
    }

    @IsTest
    static void testCompareCollections_emptyInputs() {
        FlowCollectionComparator.Request req = new FlowCollectionComparator.Request();
        req.primaryRecords = new List<SObject>();
        req.secondaryRecords = new List<SObject>();
        req.primaryFieldApiName = 'Name';
        req.secondaryFieldApiName = 'Name';

        List<FlowCollectionComparator.Response> responses = FlowCollectionComparator.compareCollections(
            new List<FlowCollectionComparator.Request>{req}
        );

        FlowCollectionComparator.Response res = responses[0];
        System.assertEquals(0, res.matchCount);
        System.assertEquals(0, res.nonMatchCount);
        System.assertEquals(true, res.matchingRecords.isEmpty());
        System.assertEquals(true, res.nonMatchingRecords.isEmpty());
    }

    @IsTest
    static void testCompareCollections_caseSensitivity() {
        List<Account> prim = new List<Account>{
            new Account(Name = 'ABC'),
            new Account(Name = 'abc')
        };

        List<Account> sec = new List<Account>{
            new Account(Name = 'ABC')
        };

        FlowCollectionComparator.Request req1 = new FlowCollectionComparator.Request();
        req1.primaryRecords = toSObjectList(prim);
        req1.secondaryRecords = toSObjectList(sec);
        req1.primaryFieldApiName = 'Name';
        req1.secondaryFieldApiName = 'Name';
        req1.caseSensitive = true;

        FlowCollectionComparator.Request req2 = new FlowCollectionComparator.Request();
        req2.primaryRecords = toSObjectList(prim);
        req2.secondaryRecords = toSObjectList(sec);
        req2.primaryFieldApiName = 'Name';
        req2.secondaryFieldApiName = 'Name';
        req2.caseSensitive = false;

        List<FlowCollectionComparator.Response> responses = FlowCollectionComparator.compareCollections(
            new List<FlowCollectionComparator.Request>{req1, req2}
        );

        // Case-sensitive: only 'ABC' matches
        System.assertEquals(1, responses[0].matchCount);
        // Case-insensitive: both match
        System.assertEquals(2, responses[1].matchCount);
    }
}