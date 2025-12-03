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

    
}