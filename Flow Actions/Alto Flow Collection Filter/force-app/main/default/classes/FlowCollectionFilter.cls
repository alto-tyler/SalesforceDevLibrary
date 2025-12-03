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

        // ✅ NEW: allows NOT / IS NOT style filtering
        @InvocableVariable(required=false)
        public Boolean invertMatch = false;
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

            for (SObject record : req.records) {
                Object fieldValue = record.get(req.fieldApiName);
                String fieldStr = fieldValue == null ? null : String.valueOf(fieldValue);
                String targetStr = req.targetValue;

                if (!req.caseSensitive) {
                    if (fieldStr != null) fieldStr = fieldStr.toLowerCase();
                    if (targetStr != null) targetStr = targetStr.toLowerCase();
                }

                Boolean isMatch;

                // ✅ Core logic: handle null / blank target and inversion
                if (String.isBlank(targetStr)) {
                    // looking for blank or null fields
                    isMatch = String.isBlank(fieldStr);
                } else if (req.partialMatch) {
                    isMatch = fieldStr != null && fieldStr.contains(targetStr);
                } else {
                    isMatch = fieldStr == targetStr;
                }

                // ✅ Apply inversion (NOT logic)
                if (req.invertMatch) {
                    isMatch = !isMatch;
                }

                if (isMatch) {
                    res.filteredRecords.add(record);
                    if (res.firstRecord == null) res.firstRecord = record;
                }
            }

            res.matchCount = res.filteredRecords.size();
            results.add(res);
        }

        return results;
    }
}