/**
 * Apex controller for the doxJobMonitor LWC.
 * Fetches a DOX__Document_Job__c record, its related Tasks, and resolves
 * any ContentVersion / ContentDocument IDs stored in the attachment fields.
 */
public without sharing class alto_DoxJobMonitorController {

    // ── Inner types ───────────────────────────────────────────────────────────

    public class JobData {
        @AuraEnabled public DOX__Document_Job__c job;
        @AuraEnabled public List<Task>           tasks;
        @AuraEnabled public List<DocLinkInfo>    docLinks;
    }

    public class DocLinkInfo {
        @AuraEnabled public String  rawId;
        @AuraEnabled public String  contentDocumentId;
        @AuraEnabled public String  title;
        @AuraEnabled public String  url;
        @AuraEnabled public Boolean isContentDocument;
    }

    // ── Public API ────────────────────────────────────────────────────────────

    /**
     * Returns the base64-encoded body and MIME type of a file so the LWC can
     * build a local blob URL — bypassing the CORS restriction that blocks
     * client-side fetch() calls to file.force.com.
     * Accepts ContentVersion ID (068), ContentDocument ID (069), or Attachment ID (00P).
     */
    @AuraEnabled(cacheable=false)
    public static Map<String, String> getFileBlob(String rawId) {
        if (String.isBlank(rawId)) throw new AuraHandledException('rawId is required');
        Map<String, String> result = new Map<String, String>();
        try {
            Id sid = Id.valueOf(rawId);
            Schema.SObjectType t = sid.getSObjectType();
            Blob body;
            String mimeType = 'application/octet-stream';

            if (t == ContentVersion.SObjectType) {
                ContentVersion cv = [SELECT VersionData, FileType FROM ContentVersion WHERE Id = :sid LIMIT 1];
                body     = cv.VersionData;
                mimeType = mimeForFileType(cv.FileType);
            } else if (t == ContentDocument.SObjectType) {
                ContentVersion cv = [SELECT VersionData, FileType FROM ContentVersion
                                     WHERE ContentDocumentId = :sid AND IsLatest = true LIMIT 1];
                body     = cv.VersionData;
                mimeType = mimeForFileType(cv.FileType);
            } else if (t == Attachment.SObjectType) {
                Attachment att = [SELECT Body, ContentType FROM Attachment WHERE Id = :sid LIMIT 1];
                body     = att.Body;
                mimeType = String.isNotBlank(att.ContentType) ? att.ContentType : 'application/octet-stream';
            }

            if (body != null) {
                result.put('base64',   EncodingUtil.base64Encode(body));
                result.put('mimeType', mimeType);
            }
        } catch (AuraHandledException e) {
            throw e;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }

    private static String mimeForFileType(String fileType) {
        if (fileType == null) return 'application/octet-stream';
        switch on fileType.toUpperCase() {
            when 'PDF'        { return 'application/pdf'; }
            when 'PNG'        { return 'image/png'; }
            when 'JPG', 'JPEG'{ return 'image/jpeg'; }
            when 'GIF'        { return 'image/gif'; }
            when 'SVG'        { return 'image/svg+xml'; }
            when 'DOC'        { return 'application/msword'; }
            when 'DOCX'       { return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'; }
            when 'XLS'        { return 'application/vnd.ms-excel'; }
            when 'XLSX'       { return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'; }
            when else         { return 'application/octet-stream'; }
        }
    }

    @AuraEnabled(cacheable=false)
    public static Id cloneJob(Id recordId) {
        if (recordId == null) throw new AuraHandledException('recordId is required');

        // Build a dynamic SOQL to select every readable field on the object
        Map<String, Schema.SObjectField> fieldMap =
            Schema.SObjectType.DOX__Document_Job__c.fields.getMap();
        List<String> fieldNames = new List<String>(fieldMap.keySet());

        String soql = 'SELECT ' + String.join(fieldNames, ', ')
                    + ' FROM DOX__Document_Job__c WHERE Id = :recordId LIMIT 1';

        DOX__Document_Job__c src = (DOX__Document_Job__c) Database.query(soql);

        DOX__Document_Job__c cloned = src.clone(false, true, false, false);
        cloned.DOX__Status__c                       = 'Not Started';
        cloned.DOX__Attachment_Id__c                = null;
        cloned.DOX__multipleAttachmentIDs__c        = null;
        cloned.DOX__emailStatus__c                  = null;
        cloned.DOX__Additional_Rec_Linkage_Staus__c = null;

        insert cloned;
        return cloned.Id;
    }

    @AuraEnabled(cacheable=false)
    public static JobData getJobData(Id recordId) {
        if (recordId == null) throw new AuraHandledException('recordId is required');

        JobData data = new JobData();

        data.job = [
            SELECT Id, Name,
                   DOX__Status__c, DOX__Operation__c, DOX__Application__c,
                   DOX__attachDocAsFile__c,
                   DOX__Attachment_Id__c, DOX__multipleAttachmentIDs__c,
                   DOX__emailStatus__c,
                   DOX__Additional_Rec_Linkage_Staus__c
            FROM   DOX__Document_Job__c
            WHERE  Id = :recordId
            LIMIT  1
        ];

        data.tasks = [
            SELECT Id, Subject, Description, Status
            FROM   Task
            WHERE  WhatId = :recordId
            ORDER BY CreatedDate ASC
        ];

        data.docLinks = buildDocLinks(data.job);
        return data;
    }

    // ── Private helpers ───────────────────────────────────────────────────────

    private static List<DocLinkInfo> buildDocLinks(DOX__Document_Job__c job) {
        List<DocLinkInfo> links = new List<DocLinkInfo>();
        if (job == null || job.DOX__Status__c != 'Completed') return links;

        // Collect raw IDs in order, deduped
        List<String> rawIds = new List<String>();
        Set<String>  seen   = new Set<String>();

        if (String.isNotBlank(job.DOX__Attachment_Id__c)) {
            String id = job.DOX__Attachment_Id__c.trim();
            if (seen.add(id)) rawIds.add(id);
        }
        if (String.isNotBlank(job.DOX__multipleAttachmentIDs__c)) {
            for (String part : job.DOX__multipleAttachmentIDs__c.split(',')) {
                String id = part.trim();
                if (String.isNotBlank(id) && seen.add(id)) rawIds.add(id);
            }
        }
        if (rawIds.isEmpty()) return links;

        // Bucket by Salesforce ID type
        List<Id> cvIds  = new List<Id>(); // ContentVersion  (068)
        List<Id> cdIds  = new List<Id>(); // ContentDocument (069)
        List<Id> attIds = new List<Id>(); // Attachment      (00P)
        for (String raw : rawIds) {
            try {
                Id sid = Id.valueOf(raw);
                Schema.SObjectType t = sid.getSObjectType();
                if      (t == ContentVersion.SObjectType)  cvIds.add(sid);
                else if (t == ContentDocument.SObjectType) cdIds.add(sid);
                else if (t == Attachment.SObjectType)      attIds.add(sid);
            } catch (Exception e) { /* skip malformed */ }
        }

        Map<Id, ContentVersion>  cvMap  = new Map<Id, ContentVersion>();
        Map<Id, ContentDocument> cdMap  = new Map<Id, ContentDocument>();
        Map<Id, Attachment>      attMap = new Map<Id, Attachment>();

        if (!cvIds.isEmpty()) {
            for (ContentVersion cv : [SELECT Id, ContentDocumentId, Title
                                      FROM   ContentVersion WHERE Id IN :cvIds]) {
                cvMap.put(cv.Id, cv);
            }
        }
        if (!cdIds.isEmpty()) {
            for (ContentDocument cd : [SELECT Id, Title
                                       FROM   ContentDocument WHERE Id IN :cdIds]) {
                cdMap.put(cd.Id, cd);
            }
        }
        if (!attIds.isEmpty()) {
            for (Attachment a : [SELECT Id, Name FROM Attachment WHERE Id IN :attIds]) {
                attMap.put(a.Id, a);
            }
        }

        // ContentDocumentLink fallback: any CDL linked to the job gives us
        // ContentDocumentId → Title even if the stored ID was a ContentVersion
        // that wasn't found above (e.g. version since replaced).
        Map<Id, String> cdlTitleByContentDocId = new Map<Id, String>();
        for (ContentDocumentLink cdl : [
            SELECT ContentDocumentId, ContentDocument.Title
            FROM   ContentDocumentLink
            WHERE  LinkedEntityId = :job.Id
        ]) {
            cdlTitleByContentDocId.put(cdl.ContentDocumentId, cdl.ContentDocument.Title);
        }

        // Build result preserving original order
        for (String raw : rawIds) {
            DocLinkInfo link       = new DocLinkInfo();
            link.rawId             = raw;
            link.isContentDocument = false;
            link.title             = raw; // fallback to raw ID if nothing else resolves
            try {
                Id sid = Id.valueOf(raw);
                Schema.SObjectType t = sid.getSObjectType();
                if (t == ContentVersion.SObjectType) {
                    if (cvMap.containsKey(sid)) {
                        ContentVersion cv      = cvMap.get(sid);
                        link.contentDocumentId = cv.ContentDocumentId;
                        link.title             = cv.Title;
                        link.isContentDocument = true;
                    } else {
                        // Version not directly visible — try CDL fallback
                        // (we don't know the ContentDocumentId from just the CV ID here,
                        //  but cover the case via cdlTitleByContentDocId below)
                        link.title = raw;
                    }
                } else if (t == ContentDocument.SObjectType) {
                    link.contentDocumentId = raw;
                    link.isContentDocument = true;
                    if (cdMap.containsKey(sid)) {
                        link.title = cdMap.get(sid).Title;
                    } else if (cdlTitleByContentDocId.containsKey(sid)) {
                        link.title = cdlTitleByContentDocId.get(sid);
                    } else {
                        link.title = raw;
                    }
                } else if (t == Attachment.SObjectType && attMap.containsKey(sid)) {
                    link.title = attMap.get(sid).Name;
                    link.url   = '/servlet/servlet.FileDownload?file=' + raw;
                }
            } catch (Exception e) { /* keep defaults */ }
            links.add(link);
        }
        return links;
    }
}
