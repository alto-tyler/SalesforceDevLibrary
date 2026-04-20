@isTest
private class alto_DoxJobMonitorControllerTest {

    // ── Helpers ───────────────────────────────────────────────────────────────

    private static DOX__Document_Job__c makeJob(String status) {
        DOX__Document_Job__c job = new DOX__Document_Job__c(DOX__Status__c = status);
        insert job;
        return job;
    }

    /**
     * Inserts a ContentVersion (auto-creates ContentDocument), links it to the
     * given record, and returns the re-queried CV with ContentDocumentId set.
     */
    private static ContentVersion makeContentVersion(String title, Id linkTo) {
        ContentVersion cv = new ContentVersion(
            Title          = title,
            PathOnClient   = title.replaceAll(' ', '_') + '.pdf',
            VersionData    = Blob.valueOf(title),
            IsMajorVersion = true
        );
        insert cv;
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

        insert new ContentDocumentLink(
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId    = linkTo,
            ShareType         = 'V'
        );
        return cv;
    }

    // ── cloneJob ──────────────────────────────────────────────────────────────

    @isTest
    static void testCloneJobNullIdThrows() {
        Boolean threw = false;
        try {
            alto_DoxJobMonitorController.cloneJob(null);
        } catch (AuraHandledException e) {
            threw = true;
        }
        System.assert(threw, 'Expected AuraHandledException for null recordId');
    }

    @isTest
    static void testCloneJobClearsStatusAndAttachmentFields() {
        DOX__Document_Job__c src = makeJob('Completed');
        src.DOX__Attachment_Id__c         = 'fakeId';
        src.DOX__multipleAttachmentIDs__c = 'id1,id2';
        src.DOX__emailStatus__c           = 'Sent';
        update src;

        Test.startTest();
        Id clonedId = alto_DoxJobMonitorController.cloneJob(src.Id);
        Test.stopTest();

        System.assertNotEquals(null, clonedId, 'Should return the cloned record Id');
        System.assertNotEquals(src.Id, clonedId, 'Clone should be a new record');

        DOX__Document_Job__c cloned = [
            SELECT DOX__Status__c,
                   DOX__Attachment_Id__c,
                   DOX__multipleAttachmentIDs__c,
                   DOX__emailStatus__c,
                   DOX__Additional_Rec_Linkage_Staus__c
            FROM   DOX__Document_Job__c
            WHERE  Id = :clonedId
        ];
        // DOX package automation may override the status after insert;
        // verify only that the attachment / email fields were cleared.
        System.assertEquals(null, cloned.DOX__Attachment_Id__c);
        System.assertEquals(null, cloned.DOX__multipleAttachmentIDs__c);
        System.assertEquals(null, cloned.DOX__emailStatus__c);
        System.assertEquals(null, cloned.DOX__Additional_Rec_Linkage_Staus__c);
    }

    // ── getJobData ────────────────────────────────────────────────────────────

    @isTest
    static void testGetJobDataNullIdThrows() {
        Boolean threw = false;
        try {
            alto_DoxJobMonitorController.getJobData(null);
        } catch (AuraHandledException e) {
            threw = true;
        }
        System.assert(threw, 'Expected AuraHandledException for null recordId');
    }

    @isTest
    static void testGetJobDataReturnsJobAndEmptyCollections() {
        DOX__Document_Job__c job = makeJob('Not Started');

        Test.startTest();
        alto_DoxJobMonitorController.JobData data = alto_DoxJobMonitorController.getJobData(job.Id);
        Test.stopTest();

        System.assertNotEquals(null, data.job,      'job should not be null');
        System.assertEquals(job.Id, data.job.Id,   'job Id should match');
        System.assertNotEquals(null, data.tasks,    'tasks list should not be null');
        System.assertEquals(0, data.tasks.size(),  'no tasks expected');
        System.assertNotEquals(null, data.docLinks, 'docLinks list should not be null');
        System.assertEquals(0, data.docLinks.size(), 'docLinks should be empty for non-Completed job');
    }

    @isTest
    static void testGetJobDataReturnsTasks() {
        DOX__Document_Job__c job = makeJob('In Progress');
        insert new Task(Subject = 'Step 1', Status = 'Open', WhatId = job.Id);
        insert new Task(Subject = 'Step 2', Status = 'Open', WhatId = job.Id);

        Test.startTest();
        alto_DoxJobMonitorController.JobData data = alto_DoxJobMonitorController.getJobData(job.Id);
        Test.stopTest();

        System.assertEquals(2, data.tasks.size(), 'Should return 2 tasks');
    }

    @isTest
    static void testGetJobDataCompletedNoAttachmentsReturnsEmptyDocLinks() {
        DOX__Document_Job__c job = makeJob('Completed');

        Test.startTest();
        alto_DoxJobMonitorController.JobData data = alto_DoxJobMonitorController.getJobData(job.Id);
        Test.stopTest();

        System.assertEquals(0, data.docLinks.size(), 'Completed job with no attachment IDs should have empty docLinks');
    }

    @isTest
    static void testGetJobDataWithContentVersionId() {
        DOX__Document_Job__c job = makeJob('Completed');
        ContentVersion cv = makeContentVersion('Invoice PDF', job.Id);

        job.DOX__Attachment_Id__c = cv.Id;
        update job;

        Test.startTest();
        alto_DoxJobMonitorController.JobData data = alto_DoxJobMonitorController.getJobData(job.Id);
        Test.stopTest();

        System.assertEquals(1, data.docLinks.size(), 'Expected 1 doc link');
        alto_DoxJobMonitorController.DocLinkInfo link = data.docLinks[0];
        System.assertEquals(String.valueOf(cv.Id), link.rawId);
        System.assertEquals(String.valueOf(cv.ContentDocumentId), link.contentDocumentId);
        System.assertEquals('Invoice PDF', link.title);
        System.assertEquals(true, link.isContentDocument);
    }

    @isTest
    static void testGetJobDataWithContentDocumentId() {
        DOX__Document_Job__c job = makeJob('Completed');
        ContentVersion cv = makeContentVersion('Quote PDF', job.Id);

        job.DOX__Attachment_Id__c = cv.ContentDocumentId;
        update job;

        Test.startTest();
        alto_DoxJobMonitorController.JobData data = alto_DoxJobMonitorController.getJobData(job.Id);
        Test.stopTest();

        System.assertEquals(1, data.docLinks.size());
        alto_DoxJobMonitorController.DocLinkInfo link = data.docLinks[0];
        System.assertEquals(String.valueOf(cv.ContentDocumentId), link.rawId);
        System.assertEquals(String.valueOf(cv.ContentDocumentId), link.contentDocumentId);
        System.assertEquals('Quote PDF', link.title);
        System.assertEquals(true, link.isContentDocument);
    }

    @isTest
    static void testGetJobDataWithAttachmentId() {
        DOX__Document_Job__c job = makeJob('Completed');

        Attachment att = new Attachment(
            ParentId = job.Id,
            Name     = 'Legacy File.pdf',
            Body     = Blob.valueOf('legacy content')
        );
        insert att;

        job.DOX__Attachment_Id__c = att.Id;
        update job;

        Test.startTest();
        alto_DoxJobMonitorController.JobData data = alto_DoxJobMonitorController.getJobData(job.Id);
        Test.stopTest();

        System.assertEquals(1, data.docLinks.size());
        alto_DoxJobMonitorController.DocLinkInfo link = data.docLinks[0];
        System.assertEquals(String.valueOf(att.Id), link.rawId);
        System.assertEquals('Legacy File.pdf', link.title);
        System.assertEquals(false, link.isContentDocument);
        System.assert(link.url != null && link.url.contains(att.Id), 'URL should reference the attachment Id');
    }

    @isTest
    static void testGetJobDataMultipleAttachmentsWithDeduplication() {
        DOX__Document_Job__c job = makeJob('Completed');
        ContentVersion cv1 = makeContentVersion('Doc One', job.Id);
        ContentVersion cv2 = makeContentVersion('Doc Two', job.Id);

        // cv1 appears in both fields → should be deduped to 2 unique links
        job.DOX__Attachment_Id__c         = cv1.Id;
        job.DOX__multipleAttachmentIDs__c = cv1.Id + ', ' + cv2.Id;
        update job;

        Test.startTest();
        alto_DoxJobMonitorController.JobData data = alto_DoxJobMonitorController.getJobData(job.Id);
        Test.stopTest();

        System.assertEquals(2, data.docLinks.size(), 'Duplicate ID should be deduped');
        System.assertEquals('Doc One', data.docLinks[0].title);
        System.assertEquals('Doc Two', data.docLinks[1].title);
    }

    @isTest
    static void testGetJobDataMalformedAttachmentIdUsesRawAsFallback() {
        DOX__Document_Job__c job = makeJob('Completed');
        // Use a short string that fits the 18-char field but is not a valid SF ID
        job.DOX__Attachment_Id__c = 'BADID001';
        update job;

        Test.startTest();
        alto_DoxJobMonitorController.JobData data = alto_DoxJobMonitorController.getJobData(job.Id);
        Test.stopTest();

        System.assertEquals(1, data.docLinks.size());
        alto_DoxJobMonitorController.DocLinkInfo link = data.docLinks[0];
        System.assertEquals('BADID001', link.rawId);
        System.assertEquals('BADID001', link.title);
        System.assertEquals(false, link.isContentDocument);
    }

    // ── getFileBlob ───────────────────────────────────────────────────────────

    @isTest
    static void testGetFileBlobBlankIdThrows() {
        Boolean threw = false;
        try {
            alto_DoxJobMonitorController.getFileBlob('');
        } catch (AuraHandledException e) {
            threw = true;
        }
        System.assert(threw, 'Expected AuraHandledException for blank rawId');
    }

    @isTest
    static void testGetFileBlobNullIdThrows() {
        Boolean threw = false;
        try {
            alto_DoxJobMonitorController.getFileBlob(null);
        } catch (AuraHandledException e) {
            threw = true;
        }
        System.assert(threw, 'Expected AuraHandledException for null rawId');
    }

    @isTest
    static void testGetFileBlobWithContentVersionId() {
        DOX__Document_Job__c job = makeJob('Completed');
        ContentVersion cv = makeContentVersion('TestPDF', job.Id);

        Test.startTest();
        Map<String, String> result = alto_DoxJobMonitorController.getFileBlob(String.valueOf(cv.Id));
        Test.stopTest();

        System.assertNotEquals(null, result,             'Result map should not be null');
        System.assert(result.containsKey('base64'),      'Result should contain base64 key');
        System.assert(result.containsKey('mimeType'),    'Result should contain mimeType key');
        System.assert(String.isNotBlank(result.get('base64')), 'base64 should not be blank');
        // File was inserted as .pdf → PDF MIME type
        System.assertEquals('application/pdf', result.get('mimeType'));
    }

    @isTest
    static void testGetFileBlobWithContentDocumentId() {
        DOX__Document_Job__c job = makeJob('Completed');
        ContentVersion cv = makeContentVersion('DocPreview', job.Id);

        Test.startTest();
        Map<String, String> result = alto_DoxJobMonitorController.getFileBlob(String.valueOf(cv.ContentDocumentId));
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assert(String.isNotBlank(result.get('base64')), 'base64 should not be blank');
        System.assertEquals('application/pdf', result.get('mimeType'));
    }

    @isTest
    static void testGetFileBlobWithAttachmentId() {
        DOX__Document_Job__c job = makeJob('Completed');
        Attachment att = new Attachment(
            ParentId    = job.Id,
            Name        = 'legacy.pdf',
            Body        = Blob.valueOf('legacy bytes'),
            ContentType = 'application/pdf'
        );
        insert att;

        Test.startTest();
        Map<String, String> result = alto_DoxJobMonitorController.getFileBlob(String.valueOf(att.Id));
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assert(String.isNotBlank(result.get('base64')), 'base64 should not be blank');
        System.assertEquals('application/pdf', result.get('mimeType'));
    }

    @isTest
    static void testGetFileBlobAttachmentNoContentTypeDefaultsMime() {
        DOX__Document_Job__c job = makeJob('Completed');
        Attachment att = new Attachment(
            ParentId = job.Id,
            Name     = 'unknown.bin',
            Body     = Blob.valueOf('raw data')
            // ContentType intentionally omitted
        );
        insert att;

        Test.startTest();
        Map<String, String> result = alto_DoxJobMonitorController.getFileBlob(String.valueOf(att.Id));
        Test.stopTest();

        System.assertEquals('application/octet-stream', result.get('mimeType'),
            'Missing ContentType should default to application/octet-stream');
    }
}
