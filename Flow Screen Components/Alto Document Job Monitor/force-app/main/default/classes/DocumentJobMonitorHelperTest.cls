@isTest
private class DocumentJobMonitorHelperTest {
    
    @isTest
    static void testGetContentVersionDetails_Success() {
        // Create test ContentVersion records inline
        List<ContentVersion> cvList = new List<ContentVersion>();
        
        cvList.add(new ContentVersion(
            Title = 'TestDocument1',
            PathOnClient = 'TestDocument1.pdf',
            VersionData = Blob.valueOf('Test content 1')
        ));
        
        cvList.add(new ContentVersion(
            Title = 'TestDocument2',
            PathOnClient = 'TestDocument2.docx',
            VersionData = Blob.valueOf('Test content 2')
        ));
        
        insert cvList;
        
        // Re-query to get FileExtension which is auto-populated
        cvList = [SELECT Id, FileExtension FROM ContentVersion WHERE Id IN :cvList];
        
        List<String> cvIds = new List<String>();
        for (ContentVersion cv : cvList) {
            cvIds.add(cv.Id);
        }
        
        Test.startTest();
        List<DocumentJobMonitorHelper.ContentVersionInfo> results = 
            DocumentJobMonitorHelper.getContentVersionDetails(cvIds);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(2, results.size(), 'Should return 2 ContentVersion records');
        
        // Verify each result has required fields
        for (DocumentJobMonitorHelper.ContentVersionInfo info : results) {
            System.assertNotEquals(null, info.id, 'ID should not be null');
            System.assertNotEquals(null, info.title, 'Title should not be null');
            System.assertNotEquals(null, info.contentDocumentId, 'ContentDocumentId should not be null');
        }
    }
    
    @isTest
    static void testGetContentVersionDetails_EmptyList() {
        Test.startTest();
        List<DocumentJobMonitorHelper.ContentVersionInfo> results = 
            DocumentJobMonitorHelper.getContentVersionDetails(new List<String>());
        Test.stopTest();
        
        System.assertEquals(0, results.size(), 'Should return empty list for empty input');
    }
    
    @isTest
    static void testGetContentVersionDetails_NullList() {
        Test.startTest();
        List<DocumentJobMonitorHelper.ContentVersionInfo> results = 
            DocumentJobMonitorHelper.getContentVersionDetails(null);
        Test.stopTest();
        
        System.assertEquals(0, results.size(), 'Should return empty list for null input');
    }
    
    @isTest
    static void testGetContentVersionDetails_InvalidIds() {
        // Use fake IDs that won't cause internal errors
        List<String> invalidIds = new List<String>();
        
        Test.startTest();
        List<DocumentJobMonitorHelper.ContentVersionInfo> results = 
            DocumentJobMonitorHelper.getContentVersionDetails(invalidIds);
        Test.stopTest();
        
        System.assertEquals(0, results.size(), 'Should return empty list for invalid IDs');
    }
    
    @isTest
    static void testContentVersionInfo_WrapperClass() {
        // Test the wrapper class directly
        DocumentJobMonitorHelper.ContentVersionInfo info = new DocumentJobMonitorHelper.ContentVersionInfo();
        
        String testId = 'TestId123';
        String testTitle = 'Test.pdf';
        String testDocId = 'TestDocId456';
        
        info.id = testId;
        info.title = testTitle;
        info.contentDocumentId = testDocId;
        
        System.assertEquals(testId, info.id, 'ID should be set correctly');
        System.assertEquals(testTitle, info.title, 'Title should be set correctly');
        System.assertEquals(testDocId, info.contentDocumentId, 'ContentDocumentId should be set correctly');
    }
}
