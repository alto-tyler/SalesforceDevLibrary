@isTest
public class RootstockTestDataFactoryExampleTest {
    
    // @testSetup to create test data that can be reused across tests
    @testSetup
    static void setupTestData() {
        Test.startTest();
        // Create test data by calling the RootstockTestDataFactory.createTestData() method
        RootstockTestDataBatch batchJob = new RootstockTestDataBatch(1); // Specify batch size
        Database.executeBatch(batchJob, 1); // Specify batch chunk size
        Test.stopTest();
        
        rstk__sydiv__c syDiv = [SELECT Id FROM rstk__sydiv__c LIMIT 1];
        rstk__sysite__c sySite = [SELECT Id FROM rstk__sysite__c LIMIT 1];
        rstk__icitem__c disIcItem = [SELECT Id FROM rstk__icitem__c WHERE rstk__icitem_item__r.rstk__peitem_item__c = 'EXAMPLEITEM' LIMIT 1];
        
        RecordType disassemblyRecordType = [
            SELECT Id, DeveloperName, Name, SobjectType 
            FROM RecordType 
            WHERE DeveloperName = 'Disassembly' 
            AND SobjectType = 'rstk__wocst__c'
            LIMIT 1
        ];

        rstk__wocst__c testDisWo = new rstk__wocst__c(
            RecordTypeId = disassemblyRecordType.Id,
            rstk__wocst_div__c = syDiv.Id,
            rstk__wocst_site__c = sySite.Id,
            rstk__wocst_targetsite__c = sySite.Id,
            rstk__wocst_ordno__c = 'TestDisWO',
            rstk__wocst_item__c = disIcItem.Id,
            rstk__wocst_qtyreq__c = 1,
            rstk__wocst_duedte__c = System.today(),
            rstk__wocst_disassmind__c = true,
            rstk__triggeroptions__c = 'UT'
        );
        
        insert testDisWo;
    }
    
    @isTest
    static void testExampleMethod() {
        rstk__wocst__c testDisWo = [SELECT Id, rstk__wocst_div__c FROM rstk__wocst__c LIMIT 1];
    }

}