@IsTest
private class FlowFieldExtractorTest {

    // Helper: cast List<Account> → List<SObject>
    private static List<SObject> toSObjectList(List<Account> accs) {
        List<SObject> sobjs = new List<SObject>();
        for (Account a : accs) sobjs.add(a);
        return sobjs;
    }

    @IsTest
    static void testExtractFieldValues_basic() {
        // Create mock data
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Acme'),
            new Account(Name = 'GlobalCorp'),
            new Account(Name = 'Acme') // duplicate
        };
        insert accounts;

        // Prepare request
        FlowFieldExtractor.Request req = new FlowFieldExtractor.Request();
        req.records = toSObjectList(accounts);
        req.fieldApiName = 'Name';
        req.deduplicate = false;

        // Execute
        List<FlowFieldExtractor.Response> responses = FlowFieldExtractor.extractFieldValues(
            new List<FlowFieldExtractor.Request>{req}
        );

        // Validate
        System.assertEquals(1, responses.size(), 'Should return one response');
        FlowFieldExtractor.Response res = responses[0];

        System.assertEquals(3, res.values.size(), 'Should extract all 3 values');
        System.assert(res.csv.contains('Acme') && res.csv.contains('GlobalCorp'), 'CSV should include both names');
    }

    @IsTest
    static void testExtractFieldValues_deduplication() {
        // Create mock data
        List<Account> accounts = new List<Account>{
            new Account(Name = 'A'),
            new Account(Name = 'B'),
            new Account(Name = 'A')
        };
        insert accounts;

        // Prepare request with deduplication
        FlowFieldExtractor.Request req = new FlowFieldExtractor.Request();
        req.records = toSObjectList(accounts);
        req.fieldApiName = 'Name';
        req.deduplicate = true;

        // Execute
        List<FlowFieldExtractor.Response> responses = FlowFieldExtractor.extractFieldValues(
            new List<FlowFieldExtractor.Request>{req}
        );

        // Validate
        FlowFieldExtractor.Response res = responses[0];
        System.assertEquals(2, res.values.size(), 'Deduplication should remove duplicates');
        System.assert(res.csv.contains('A') && res.csv.contains('B'), 'CSV should contain A and B');
    }

    @IsTest
    static void testExtractFieldValues_emptyOrInvalid() {
        // Empty records
        FlowFieldExtractor.Request reqEmpty = new FlowFieldExtractor.Request();
        reqEmpty.records = new List<SObject>();
        reqEmpty.fieldApiName = 'Name';

        // Missing fieldApiName
        List<Account> accs = new List<Account>{ new Account(Name='Test') };
        insert accs;
        FlowFieldExtractor.Request reqNoField = new FlowFieldExtractor.Request();
        reqNoField.records = toSObjectList(accs);
        reqNoField.fieldApiName = null;

        // Execute
        List<FlowFieldExtractor.Response> responses = FlowFieldExtractor.extractFieldValues(
            new List<FlowFieldExtractor.Request>{reqEmpty, reqNoField}
        );

        // Validate both handled gracefully
        System.assertEquals(2, responses.size());
        System.assertEquals(true, responses[0].values == null || responses[0].values.isEmpty(), 'Empty request should return empty values');
        System.assertEquals(0, responses[1].values.size(), 'Invalid field request should return empty values');
    }
}