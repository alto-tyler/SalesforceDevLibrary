public with sharing class FlowCollectionComparator { 
    // Request structure
    public class Request {
        // ✅ Not required to prevent Flow runtime failure
        @InvocableVariable(required=false)
        public List<SObject> primaryRecords;

        @InvocableVariable(required=false)
        public List<SObject> secondaryRecords;

        @InvocableVariable(required=true)
        public String primaryFieldApiName;

        @InvocableVariable(required=true)
        public String secondaryFieldApiName;

        @InvocableVariable(required=false)
        public Boolean caseSensitive = false;
    }

    // Response structure
    public class Response {
        @InvocableVariable(label='Matching Records')
        public List<SObject> matchingRecords;

        @InvocableVariable(label='Non-Matching Records')
        public List<SObject> nonMatchingRecords;

        @InvocableVariable(label='Match Count')
        public Integer matchCount;

        @InvocableVariable(label='Non-Match Count')
        public Integer nonMatchCount;
    }

    @InvocableMethod(
        label='Compare Record Collections'
        description='Compares two record collections based on field values and returns matching and non-matching primary records.'
        category='Utility'
    )
    public static List<Response> compareCollections(List<Request> requests) {
        List<Response> results = new List<Response>();

        if (requests == null || requests.isEmpty()) {
            return results;
        }

        for (Request req : requests) {
            Response res = new Response();
            res.matchingRecords = new List<SObject>();
            res.nonMatchingRecords = new List<SObject>();
            res.matchCount = 0;
            res.nonMatchCount = 0;

            // ✅ Safe guard: handle missing or blank inputs gracefully
            if (req == null ||
                req.primaryRecords == null || req.primaryRecords.isEmpty() ||
                req.secondaryRecords == null || req.secondaryRecords.isEmpty() ||
                String.isBlank(req.primaryFieldApiName) || String.isBlank(req.secondaryFieldApiName)) {
                results.add(res);
                continue;
            }

            // Collect secondary field values into a Set for fast lookups
            Set<String> secondaryValues = new Set<String>();
            for (SObject sec : req.secondaryRecords) {
                if (sec == null) continue;
                Object val = sec.get(req.secondaryFieldApiName);
                if (val != null) {
                    String strVal = String.valueOf(val);
                    if (req.caseSensitive == false) {
                        strVal = strVal.toLowerCase();
                    }
                    secondaryValues.add(strVal);
                }
            }

            // Compare primary against secondary
            for (SObject prim : req.primaryRecords) {
                if (prim == null) continue;
                Object val = prim.get(req.primaryFieldApiName);
                if (val == null) {
                    res.nonMatchingRecords.add(prim);
                    continue;
                }

                String strVal = String.valueOf(val);
                if (req.caseSensitive == false) {
                    strVal = strVal.toLowerCase();
                }

                if (secondaryValues.contains(strVal)) {
                    res.matchingRecords.add(prim);
                } else {
                    res.nonMatchingRecords.add(prim);
                }
            }

            // Counts
            res.matchCount = res.matchingRecords.size();
            res.nonMatchCount = res.nonMatchingRecords.size();

            results.add(res);
        }

        return results;
    }
}