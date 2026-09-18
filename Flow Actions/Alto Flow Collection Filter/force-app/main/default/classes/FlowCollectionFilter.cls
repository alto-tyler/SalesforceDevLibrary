public with sharing class FlowCollectionFilter {
    public class Request {
        @InvocableVariable(required=true)
        public List<SObject> records;

        @InvocableVariable(required=true)
        public String fieldApiName;

        @InvocableVariable(required=false)
        public String targetValue;

        @InvocableVariable(required=false)
        public Boolean caseSensitive = false;

        @InvocableVariable(required=false)
        public Boolean partialMatch = false;

        @InvocableVariable(required=false)
        public Boolean invertMatch = false;

        @InvocableVariable(required=false description='Additional field names (comma-separated)')
        public String additionalFields;

        @InvocableVariable(required=false description='Additional target values (comma-separated)')
        public String additionalValues;

        @InvocableVariable(required=false description='Match logic: AND or OR (default: AND)')
        public String matchLogic;
    }

    public class Response {
        @InvocableVariable public List<SObject> filteredRecords;
        @InvocableVariable public SObject firstRecord;
        @InvocableVariable public Integer matchCount;
    }

    @InvocableMethod(label='Filter Record Collection')
    public static List<Response> filterCollection(List<Request> requests) {
        List<Response> results = new List<Response>();

        for (Request req : requests) {
            Response res = new Response();
            res.filteredRecords = new List<SObject>();
            res.firstRecord = null;
            res.matchCount = 0;

            if (req.records == null || req.records.isEmpty() || String.isBlank(req.fieldApiName)) {
                results.add(res);
                continue;
            }

            // Build filter criteria list
            List<FilterCriteria> criteria = buildFilterCriteria(req);
            String logic = String.isBlank(req.matchLogic) ? 'AND' : req.matchLogic.toUpperCase();

            for (SObject record : req.records) {
                Boolean recordMatches = evaluateRecord(record, criteria, logic);

                if (recordMatches) {
                    res.filteredRecords.add(record);
                    if (res.firstRecord == null) {
                        res.firstRecord = record;
                    }
                }
            }

            res.matchCount = res.filteredRecords.size();
            results.add(res);
        }

        return results;
    }

    /**
     * Build list of filter criteria from request
     */
    private static List<FilterCriteria> buildFilterCriteria(Request req) {
        List<FilterCriteria> criteria = new List<FilterCriteria>();

        // Add primary filter
        FilterCriteria primary = new FilterCriteria();
        primary.fieldName = req.fieldApiName;
        primary.targetValue = req.targetValue;
        primary.caseSensitive = req.caseSensitive;
        primary.partialMatch = req.partialMatch;
        primary.invertMatch = req.invertMatch;
        criteria.add(primary);

        // Add additional filters if provided
        if (!String.isBlank(req.additionalFields)) {
            List<String> fields = req.additionalFields.split(',');
            List<String> values = String.isBlank(req.additionalValues) ?
                new List<String>() : req.additionalValues.split(',');

            for (Integer i = 0; i < fields.size(); i++) {
                FilterCriteria additional = new FilterCriteria();
                additional.fieldName = fields[i].trim();
                additional.targetValue = i < values.size() ? values[i].trim() : '';
                additional.caseSensitive = req.caseSensitive;
                additional.partialMatch = req.partialMatch;
                additional.invertMatch = req.invertMatch;
                criteria.add(additional);
            }
        }

        return criteria;
    }

    /**
     * Evaluate if a record matches the filter criteria
     */
    private static Boolean evaluateRecord(SObject record, List<FilterCriteria> criteria, String logic) {
        if (logic == 'OR') {
            // OR logic - return true if ANY criterion matches
            for (FilterCriteria criterion : criteria) {
                if (evaluateSingleCriterion(record, criterion)) {
                    return true;
                }
            }
            return false;
        } else {
            // AND logic (default) - return true only if ALL criteria match
            for (FilterCriteria criterion : criteria) {
                if (!evaluateSingleCriterion(record, criterion)) {
                    return false;
                }
            }
            return true;
        }
    }

    /**
     * Evaluate a single filter criterion
     */
    private static Boolean evaluateSingleCriterion(SObject record, FilterCriteria criterion) {
        Object fieldValue = getFieldValue(record, criterion.fieldName);
        String fieldStr = fieldValue == null ? null : String.valueOf(fieldValue);
        String targetStr = criterion.targetValue;

        if (!criterion.caseSensitive) {
            if (fieldStr != null) {
                fieldStr = fieldStr.toLowerCase();
            }
            if (targetStr != null) {
                targetStr = targetStr.toLowerCase();
            }
        }

        Boolean isMatch;

        if (String.isBlank(targetStr)) {
            isMatch = String.isBlank(fieldStr);
        } else if (criterion.partialMatch) {
            isMatch = fieldStr != null && fieldStr.contains(targetStr);
        } else {
            isMatch = fieldStr == targetStr;
        }

        if (criterion.invertMatch) {
            isMatch = !isMatch;
        }

        return isMatch;
    }

    /**
     * Inner class to hold filter criteria
     */
    private class FilterCriteria {
        String fieldName;
        String targetValue;
        Boolean caseSensitive;
        Boolean partialMatch;
        Boolean invertMatch;
    }

    /**
     * Get field value from SObject, supporting relationship traversal
     * Handles both direct fields (e.g., 'Name') and relationship fields (e.g., 'Account__r.Name')
     */
    private static Object getFieldValue(SObject record, String fieldPath) {
        if (record == null || String.isBlank(fieldPath)) {
            return null;
        }

        // Check if this is a relationship field (contains '.')
        if (!fieldPath.contains('.')) {
            // Direct field access
            try {
                return record.get(fieldPath);
            } catch (Exception e) {
                return null;
            }
        }

        // Relationship field - traverse the path
        List<String> fieldParts = fieldPath.split('\\.');
        SObject currentRecord = record;

        // Traverse all relationship levels except the last one
        for (Integer i = 0; i < fieldParts.size() - 1; i++) {
            try {
                currentRecord = currentRecord.getSObject(fieldParts[i]);
                if (currentRecord == null) {
                    return null;
                }
            } catch (Exception e) {
                return null;
            }
        }

        // Get the final field value
        try {
            return currentRecord.get(fieldParts[fieldParts.size() - 1]);
        } catch (Exception e) {
            return null;
        }
    }
}
