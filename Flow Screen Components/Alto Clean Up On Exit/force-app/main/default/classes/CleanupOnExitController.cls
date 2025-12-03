public with sharing class CleanupOnExitController {
    
    @AuraEnabled
    public static String deleteRecord(String recordId, Boolean cascadeDelete, String lookupRelationships) {
        try {
            if (String.isBlank(recordId)) {
                return 'ERROR: Record ID is required';
            }
            
            // Validate the ID format
            Id recId;
            try {
                recId = Id.valueOf(recordId);
            } catch (Exception e) {
                return 'ERROR: Invalid Record ID format';
            }
            
            // Get the SObject type
            String objectType = recId.getSObjectType().getDescribe().getName();
            
            // Check if record exists before attempting delete
            String query = 'SELECT Id FROM ' + String.escapeSingleQuotes(objectType) + ' WHERE Id = :recId LIMIT 1';
            List<SObject> records = Database.query(query);
            
            if (records.isEmpty()) {
                System.debug('CleanupOnExit: Record ' + recordId + ' does not exist (already deleted or never existed)');
                return 'SUCCESS: Record does not exist (already deleted)';
            }
            
            // Delete lookup children first if specified
            if (String.isNotBlank(lookupRelationships)) {
                String lookupDeleteResult = deleteLookupChildren(recId, objectType, lookupRelationships);
                if (lookupDeleteResult.startsWith('ERROR')) {
                    return lookupDeleteResult;
                }
            }
            
            // If cascade delete is enabled, try to delete Master-Detail child relationships
            if (cascadeDelete == true) {
                String childDeleteResult = deleteChildRecords(recId, objectType);
                if (childDeleteResult.startsWith('ERROR')) {
                    return childDeleteResult;
                }
            }
            
            // Delete the record
            Database.DeleteResult result = Database.delete(recId, false);
            
            if (result.isSuccess()) {
                System.debug('CleanupOnExit: Successfully deleted record ' + recordId + ' (' + objectType + ')');
                return 'SUCCESS: Record deleted';
            } else {
                String errorMsg = result.getErrors()[0].getMessage();
                System.debug('CleanupOnExit: Failed to delete record - ' + errorMsg);
                return 'ERROR: ' + errorMsg;
            }
            
        } catch (Exception e) {
            System.debug('CleanupOnExit: Exception deleting record - ' + e.getMessage());
            return 'ERROR: ' + e.getMessage();
        }
    }
    
    private static String deleteChildRecords(Id parentId, String parentObjectType) {
        try {
            // Get all child relationships for this object
            Schema.DescribeSObjectResult parentDescribe = parentId.getSObjectType().getDescribe();
            List<Schema.ChildRelationship> childRelationships = parentDescribe.getChildRelationships();
            
            Integer totalChildrenDeleted = 0;
            
            for (Schema.ChildRelationship rel : childRelationships) {
                // Skip if relationship can't be cascaded (system objects, etc)
                if (rel.getChildSObject() == null || rel.getField() == null) {
                    continue;
                }
                
                String childObjectName = rel.getChildSObject().getDescribe().getName();
                String relationshipFieldName = rel.getField().getDescribe().getName();
                
                // ONLY process Master-Detail relationships
                Schema.DescribeFieldResult fieldDescribe = rel.getField().getDescribe();
                if (fieldDescribe.getType() != Schema.DisplayType.REFERENCE || 
                    !fieldDescribe.isCascadeDelete()) {
                    // Skip if not a Master-Detail (cascade delete relationship)
                    continue;
                }
                
                // Skip certain system relationships
                if (childObjectName.endsWith('Share') || 
                    childObjectName.endsWith('History') || 
                    childObjectName.endsWith('Feed') ||
                    !rel.getChildSObject().getDescribe().isDeletable()) {
                    continue;
                }
                
                try {
                    // Query for child records
                    String childQuery = 'SELECT Id FROM ' + String.escapeSingleQuotes(childObjectName) + 
                                      ' WHERE ' + String.escapeSingleQuotes(relationshipFieldName) + ' = :parentId';
                    List<SObject> childRecords = Database.query(childQuery);
                    
                    if (!childRecords.isEmpty()) {
                        // Delete child records
                        Database.DeleteResult[] childResults = Database.delete(childRecords, false);
                        
                        for (Database.DeleteResult dr : childResults) {
                            if (dr.isSuccess()) {
                                totalChildrenDeleted++;
                            } else {
                                System.debug('CleanupOnExit: Failed to delete child record - ' + dr.getErrors()[0].getMessage());
                            }
                        }
                        
                        System.debug('CleanupOnExit: Deleted ' + childRecords.size() + ' Master-Detail child records from ' + childObjectName);
                    }
                } catch (Exception childEx) {
                    // Log but don't fail - some child relationships might not be queryable
                    System.debug('CleanupOnExit: Could not delete children from ' + childObjectName + ': ' + childEx.getMessage());
                }
            }
            
            if (totalChildrenDeleted > 0) {
                System.debug('CleanupOnExit: Total Master-Detail child records deleted: ' + totalChildrenDeleted);
            }
            
            return 'SUCCESS: Child records processed';
            
        } catch (Exception e) {
            System.debug('CleanupOnExit: Error processing child relationships - ' + e.getMessage());
            return 'ERROR: Could not process child relationships - ' + e.getMessage();
        }
    }
    
    private static String deleteLookupChildren(Id parentId, String parentObjectType, String lookupRelationships) {
        try {
            // Parse CSV list of relationship names
            List<String> relationshipNames = lookupRelationships.split(',');
            Integer totalDeleted = 0;
            Schema.DescribeSObjectResult parentDescribe = parentId.getSObjectType().getDescribe();
            
            for (String relationshipName : relationshipNames) {
                String cleanRelName = relationshipName.trim();
                if (String.isBlank(cleanRelName)) {
                    continue;
                }
                
                try {
                    // Find the actual child relationship by name
                    Schema.ChildRelationship targetRelationship = null;
                    for (Schema.ChildRelationship rel : parentDescribe.getChildRelationships()) {
                        System.debug('CleanupOnExit: Checking relationship ' + rel.getRelationshipName());
                        if (rel.getRelationshipName() == cleanRelName) {
                            targetRelationship = rel;
                            break;
                        }
                    }
                    
                    if (targetRelationship == null) {
                        System.debug('CleanupOnExit: Could not find relationship ' + cleanRelName + ' on ' + parentObjectType);
                        continue;
                    }
                    
                    String childObjectName = targetRelationship.getChildSObject().getDescribe().getName();
                    String lookupFieldName = targetRelationship.getField().getDescribe().getName();
                    
                    System.debug('CleanupOnExit: Found relationship - Child: ' + childObjectName + ', Field: ' + lookupFieldName);
                    
                    // Query for child records using the actual lookup field
                    String childQuery = 'SELECT Id FROM ' + String.escapeSingleQuotes(childObjectName) + 
                                      ' WHERE ' + String.escapeSingleQuotes(lookupFieldName) + ' = :parentId';
                    
                    List<SObject> childRecords = Database.query(childQuery);
                    
                    if (!childRecords.isEmpty()) {
                        Database.DeleteResult[] results = Database.delete(childRecords, false);
                        Integer deleted = 0;
                        for (Database.DeleteResult dr : results) {
                            if (dr.isSuccess()) {
                                deleted++;
                            } else {
                                System.debug('CleanupOnExit: Failed to delete lookup child - ' + dr.getErrors()[0].getMessage());
                            }
                        }
                        totalDeleted += deleted;
                        System.debug('CleanupOnExit: Deleted ' + deleted + ' lookup children from ' + childObjectName);
                    }
                } catch (Exception childEx) {
                    System.debug('CleanupOnExit: Error deleting lookup children for ' + cleanRelName + ': ' + childEx.getMessage());
                }
            }
            
            if (totalDeleted > 0) {
                System.debug('CleanupOnExit: Total lookup children deleted: ' + totalDeleted);
            }
            
            return 'SUCCESS: Lookup children processed';
            
        } catch (Exception e) {
            System.debug('CleanupOnExit: Error processing lookup relationships - ' + e.getMessage());
            return 'ERROR: Could not process lookup relationships - ' + e.getMessage();
        }
    }
}
