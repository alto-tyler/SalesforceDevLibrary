public with sharing class RollupNumberHelper {
    
    /**
     * Performs a rollup calculation on a collection of records
     * @param records Collection of SObjects to perform rollup on
     * @param fieldApiName API name of the numeric field to rollup
     * @param rollupOption Type of rollup: SUM, AVERAGE, MEDIAN, MIN, MAX, COUNT
     * @return Decimal The calculated rollup result
     */
    @InvocableMethod(label='Rollup Numbers' description='Performs rollup calculations (SUM, AVERAGE, MEDIAN, MIN, MAX, COUNT) on a collection of records' category='Data')
    public static List<Decimal> calculateRollup(List<RollupRequest> requests) {
        List<Decimal> results = new List<Decimal>();
        
        for (RollupRequest request : requests) {
            Decimal result = performRollup(request.records, request.fieldApiName, request.rollupOption);
            results.add(result);
        }
        
        return results;
    }
    
    /**
     * Wrapper class for invocable method input
     */
    public class RollupRequest {
        @InvocableVariable(label='Records' description='Collection of records to rollup' required=false)
        public List<SObject> records;
        
        @InvocableVariable(label='Field API Name' description='API name of the numeric field to rollup' required=true)
        public String fieldApiName;
        
        @InvocableVariable(label='Rollup Option' description='SUM, AVERAGE, MEDIAN, MIN, MAX, or COUNT' required=true)
        public String rollupOption;
    }
    
    /**
     * Performs the actual rollup calculation
     */
    private static Decimal performRollup(List<SObject> records, String fieldApiName, String rollupOption) {
        if (records == null || records.isEmpty()) {
            if (rollupOption != null && rollupOption.toUpperCase() == 'COUNT') {
                return 0;
            }
            return null;
        }
        
        List<Decimal> values = extractNumericValues(records, fieldApiName);
        
        if (values.isEmpty()) {
            if (rollupOption != null && rollupOption.toUpperCase() == 'COUNT') {
                return records.size();
            }
            return null;
        }
        
        String option = (rollupOption != null) ? rollupOption.toUpperCase() : 'SUM';
        
        switch on option {
            when 'SUM' {
                return calculateSum(values);
            }
            when 'AVERAGE' {
                return calculateAverage(values);
            }
            when 'MEDIAN' {
                return calculateMedian(values);
            }
            when 'MIN' {
                return calculateMin(values);
            }
            when 'MAX' {
                return calculateMax(values);
            }
            when 'COUNT' {
                return records.size();
            }
            when else {
                return calculateSum(values);
            }
        }
    }
    
    /**
     * Extracts numeric values from a list of SObjects for a given field
     * @param records List of SObjects
     * @param fieldApiName API name of the field to extract
     * @return List<Decimal> List of numeric values
     */
    @SuppressWarnings('PMD.CognitiveComplexity')
    private static List<Decimal> extractNumericValues(List<SObject> records, String fieldApiName) {
        List<Decimal> values = new List<Decimal>();
        
        if (String.isBlank(fieldApiName)) {
            return values;
        }
        
        for (SObject record : records) {
            if (record == null) {
                continue;
            }
            
            try {
                Object rawValue = record.get(fieldApiName);
                
                if (rawValue == null) {
                    continue;
                }
                
                Decimal decimalValue = convertToDecimal(rawValue);
                
                if (decimalValue != null) {
                    values.add(decimalValue);
                }
            } catch (Exception e) {
                // Skip records with invalid numeric values
                continue;
            }
        }
        
        return values;
    }
    
    /**
     * Converts an Object to Decimal
     * @param rawValue Object to convert
     * @return Decimal The converted value or null
     */
    private static Decimal convertToDecimal(Object rawValue) {
        if (rawValue instanceof Decimal) {
            return (Decimal) rawValue;
        } else if (rawValue instanceof Integer) {
            return Decimal.valueOf((Integer) rawValue);
        } else if (rawValue instanceof Long) {
            return Decimal.valueOf((Long) rawValue);
        } else if (rawValue instanceof Double) {
            return Decimal.valueOf((Double) rawValue);
        } else {
            // Try to parse as string
            String strValue = String.valueOf(rawValue);
            if (String.isNotBlank(strValue)) {
                return Decimal.valueOf(strValue);
            }
        }
        return null;
    }
    
    private static Decimal calculateSum(List<Decimal> values) {
        Decimal sum = 0;
        for (Decimal value : values) {
            sum += value;
        }
        return sum;
    }
    
    private static Decimal calculateAverage(List<Decimal> values) {
        if (values.isEmpty()) {
            return null;
        }
        return calculateSum(values) / values.size();
    }
    
    private static Decimal calculateMedian(List<Decimal> values) {
        if (values.isEmpty()) {
            return null;
        }
        
        List<Decimal> sorted = new List<Decimal>(values);
        sorted.sort();
        
        Integer size = sorted.size();
        Integer mid = size / 2;
        
        if (Math.mod(size, 2) == 1) {
            return sorted[mid];
        } else {
            return (sorted[mid - 1] + sorted[mid]) / 2;
        }
    }
    
    private static Decimal calculateMin(List<Decimal> values) {
        if (values.isEmpty()) {
            return null;
        }
        
        Decimal minValue = values[0];
        for (Decimal value : values) {
            if (value < minValue) {
                minValue = value;
            }
        }
        return minValue;
    }
    
    private static Decimal calculateMax(List<Decimal> values) {
        if (values.isEmpty()) {
            return null;
        }
        
        Decimal maxValue = values[0];
        for (Decimal value : values) {
            if (value > maxValue) {
                maxValue = value;
            }
        }
        return maxValue;
    }
}
