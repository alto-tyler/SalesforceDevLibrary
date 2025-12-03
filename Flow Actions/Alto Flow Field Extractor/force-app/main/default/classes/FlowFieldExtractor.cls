public with sharing class FlowFieldExtractor {
    public class Request {
        @InvocableVariable(required=false)
        public List<SObject> records;

        @InvocableVariable(required=true)
        public String fieldApiName;

        @InvocableVariable(required=false)
        public Boolean deduplicate = false;
    }

    public class Response {
        @InvocableVariable
        public List<String> values;

        @InvocableVariable
        public String csv;
        
        @InvocableVariable
        public Integer numberOfRecords;
    }

    @InvocableMethod(
        label='Extract Field Values'
        description='Extracts a specified field from a record collection, optionally deduplicates, and returns a string collection and CSV string.'
        category='Utility'
    )
    public static List<Response> extractFieldValues(List<Request> requests) {
        List<Response> results = new List<Response>();
        
        for (Request req : requests) {
            Response res = new Response();
            res.values = new List<String>(); // always initialize
            
            if (req.records == null || req.records.isEmpty() || String.isBlank(req.fieldApiName)) {
                res.csv = '';
                results.add(res);
                continue;
            }
            
            // Extract values dynamically
            List<String> extractedValues = new List<String>();
            for (SObject record : req.records) {
                Object fieldValue = record.get(req.fieldApiName);
                if (fieldValue != null) {
                    extractedValues.add(String.valueOf(fieldValue));
                }
            }
            
            // Deduplicate if requested
            if (req.deduplicate == true) {
                extractedValues = new List<String>(new Set<String>(extractedValues));
            }
            
            // Assign results
            res.values = extractedValues;
            res.csv = String.join(extractedValues, ',');
            res.numberOfRecords = extractedValues.size();
            results.add(res);
        }

        return results;
    }
}