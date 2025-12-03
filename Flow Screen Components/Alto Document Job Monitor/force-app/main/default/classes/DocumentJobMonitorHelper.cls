public with sharing class DocumentJobMonitorHelper {
    
    @AuraEnabled(cacheable=false)
    public static List<ContentVersionInfo> getContentVersionDetails(List<String> contentVersionIds) {
        List<ContentVersionInfo> results = new List<ContentVersionInfo>();
        
        if (contentVersionIds == null || contentVersionIds.isEmpty()) {
            return results;
        }
        
        List<ContentVersion> cvList = [
            SELECT Id, Title, FileExtension, ContentDocumentId
            FROM ContentVersion
            WHERE Id IN :contentVersionIds
            WITH SECURITY_ENFORCED
        ];
        
        for (ContentVersion cv : cvList) {
            ContentVersionInfo info = new ContentVersionInfo();
            info.id = cv.Id;
            
            // Check if title already ends with the file extension to avoid duplication
            String title = cv.Title;
            if (String.isNotBlank(cv.FileExtension)) {
                String extension = '.' + cv.FileExtension;
                if (!title.endsWithIgnoreCase(extension)) {
                    title = title + extension;
                }
            }
            info.title = title;
            info.contentDocumentId = cv.ContentDocumentId;
            results.add(info);
        }
        
        return results;
    }
    
    public class ContentVersionInfo {
        @AuraEnabled public String id;
        @AuraEnabled public String title;
        @AuraEnabled public String contentDocumentId;
    }
}
