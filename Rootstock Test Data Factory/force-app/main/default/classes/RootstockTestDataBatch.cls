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

    // Process each batch of data
    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        for (Integer i = 0; i < batchSize; i++) {
            try {
                RootstockTestDataFactory.createTestSyConfig();
                RootstockTestDataFactory.Response res = RootstockTestDataFactory.createTestData();
                results.add(res);
                recordCount++;
            } catch (Exception ex) {
                // Handle any exceptions that occur during the creation
                System.debug('Error creating test data: ' + ex.getMessage());
            }
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