public class RootstockTestDataBatch implements Database.Batchable<SObject>, Database.Stateful {
    private Integer recordCount = 0;
    private Integer batchSize = 1; // Modify as needed for execution size
    private List<RootstockTestDataFactory.Response> results = new List<RootstockTestDataFactory.Response>();

    // Constructor to initialize if needed
    public RootstockTestDataBatch(Integer batchSize) {
        if (batchSize != null && batchSize > 0) {
            this.batchSize = batchSize;
        }
    }

    // Query locator for the batch
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Since we're not iterating over existing records, return an empty query.
        // We'll use the batch execute method to run the factory logic.
        return Database.getQueryLocator([SELECT Id FROM User LIMIT :batchSize]);
    }

    // Process each batch of data. Deliberately does NOT swallow exceptions
    // from the factory calls — this batch only exists to seed data the
    // caller (e.g. FlowHeaderControllerTest) immediately depends on, so a
    // failure here must fail the test loudly with its real cause instead of
    // silently leaving that data half-created and surfacing as a confusing
    // downstream "List has no rows for assignment to SObject".
    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        for (Integer i = 0; i < batchSize; i++) {
            RootstockTestDataFactory.createTestSyConfig();
            RootstockTestDataFactory.Response res = RootstockTestDataFactory.createTestData();
            results.add(res);
            recordCount++;
        }
    }

    // Finalize the batch and send results
    public void finish(Database.BatchableContext BC) {
        System.debug('Total Records Created: ' + recordCount);
        // Optionally log or process the results
        for (RootstockTestDataFactory.Response res : results) {
            System.debug('Response: ' + res);
        }
    }
}