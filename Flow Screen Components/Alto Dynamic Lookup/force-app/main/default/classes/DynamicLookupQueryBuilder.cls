public with sharing class DynamicLookupQueryBuilder {
    /**
     * Dynamically builds a SOQL query string based on provided parameters.
     *
     * @param objectApiName      The API name of the object to query.
     * @param parentFilterField  (Optional) The API name of the parent filter field.
     * @param parentFilterValue  (Optional) The value for the parent filter field.
     * @param parentFilterOperator (Optional) The operator for the parent filter (default '=').
     * @param whereClause        (Optional) Additional WHERE clause.
     * @param sortBy             (Optional) Field to sort by.
     * @param sortDirection      (Optional) Sort direction ('ASC' or 'DESC', default 'ASC').
     * @param maxResults         (Optional) Maximum number of records to return.
     * @param searchField        (Optional) Field to search in.
     * @param searchValue        (Optional) Value to search for in the searchField.
     * @param valueMatchType     (Optional) Type of match for the search value (e.g., 'exact', 'contains').
     * @param valueFieldName     (Optional) Field name to return as the value in the results.
     * @return                   The SOQL query string.
     */
    
    public class QueryParams {
        @AuraEnabled public String objectApiName;
        @AuraEnabled public String displayField;
        @AuraEnabled public String parentFilterField;
        @AuraEnabled public String parentFilterValue;
        @AuraEnabled public String parentFilterOperator;
        @AuraEnabled public String whereClause;
        @AuraEnabled public String sortBy;
        @AuraEnabled public String sortDirection;
        @AuraEnabled public Integer maxResults;
        @AuraEnabled public String searchField;
        @AuraEnabled public String searchValue;
        @AuraEnabled public String valueMatchType;
        @AuraEnabled public String valueFieldName;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getSObjectDetails(String objectApiName) {
        if (String.isBlank(objectApiName)) {
            throw new AuraHandledException('objectApiName is required');
        }
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectApiName);
        if (sObjectType == null) {
            throw new AuraHandledException('Object with API name ' + objectApiName + ' does not exist');
        }
        Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe();

        Map<String, Object> result = new Map<String, Object>{
            'label' => describeResult.getLabel(),
            'pluralLabel' => describeResult.getLabelPlural(),
            'apiName' => describeResult.getName(),
            'isCustom' => describeResult.isCustom(),
            'isAccessible' => describeResult.isAccessible(),
            'isQueryable' => describeResult.isQueryable(),
            'isCreateable' => describeResult.isCreateable(),
            'isUpdateable' => describeResult.isUpdateable(),
            'isDeleteable' => describeResult.isDeletable(),
            'isSearchable' => describeResult.isSearchable(),
            'keyPrefix' => describeResult.getKeyPrefix()
        };
        return result;
    }

    @AuraEnabled
    public static String queryRecords(
        String objectApiName,
        String displayField,
        String parentFilterField,
        String parentFilterValue,
        String parentFilterOperator,
        String whereClause,
        String sortBy,
        String sortDirection,
        Integer maxResults,
        String searchField,
        String searchValue,
        String valueMatchType,
        String valueFieldName
    ) {
        QueryParams params = mapToQueryParams(
            objectApiName,
            displayField,
            parentFilterField,
            parentFilterValue,
            parentFilterOperator,
            whereClause,
            sortBy,
            sortDirection,
            maxResults,
            searchField,
            searchValue,
            valueMatchType,
            valueFieldName
        );
        System.debug('Querying records with params: ' + JSON.serialize(params));
        String soql = buildQuery(params);
        System.debug('Generated SOQL: ' + soql);
        List<SObject> records = Database.query(soql);

        String result = JSON.serialize(records);
        return result;
    }

    // Helper to convert Map to QueryParams
    private static QueryParams mapToQueryParams(
        String objectApiName,
        String displayField,
        String parentFilterField,
        String parentFilterValue,
        String parentFilterOperator,
        String whereClause,
        String sortBy,
        String sortDirection,
        Integer maxResults,
        String searchField,
        String searchValue,
        String valueMatchType,
        String valueFieldName
    ) {
        QueryParams params = new QueryParams();
        params.objectApiName = objectApiName;
        params.displayField = displayField;
        params.parentFilterField = parentFilterField;
        params.parentFilterValue = parentFilterValue;
        params.parentFilterOperator = parentFilterOperator;
        params.whereClause = whereClause;
        params.sortBy = sortBy;
        params.sortDirection = sortDirection;
        params.maxResults = maxResults;
        params.searchField = searchField;
        params.searchValue = searchValue;
        params.valueMatchType = valueMatchType;
        params.valueFieldName = valueFieldName;

        return params;
    }

    public static String buildQuery(QueryParams params) {
        if (params == null || String.isBlank(params.objectApiName)) {
            throw new AuraHandledException('objectApiName is required');
        }

        Map<String, Schema.SObjectField> fieldMap = getFieldMap(params.objectApiName);
        Set<String> fieldSet = new Set<String>();

        // Always include Id
        fieldSet.add('Id');

        // Add displayField if set and exists in fieldMap
        if (!String.isBlank(params.displayField) && fieldMap.containsKey(params.displayField)) {
            fieldSet.add(params.displayField);
        }

        // Add parentFilterField if set
        if (!String.isBlank(params.parentFilterField) && fieldMap.containsKey(params.parentFilterField)) {
            fieldSet.add(params.parentFilterField);
        }

        // Add searchField if set
        if (!String.isBlank(params.searchField) && fieldMap.containsKey(params.searchField)) {
            fieldSet.add(params.searchField);
        }

        // Add sortBy if set
        if (!String.isBlank(params.sortBy) && fieldMap.containsKey(params.sortBy)) {
            fieldSet.add(params.sortBy);
        }

        if (!String.isBlank(params.valueFieldName) && fieldMap.containsKey(params.valueFieldName)) {
            fieldSet.add(params.valueFieldName);
        }

        // If nothing else, add Name if it exists
        if (fieldSet.size() == 1 && fieldMap.containsKey('Name')) {
            fieldSet.add('Name');
        }

        List<String> fieldNames = new List<String>(fieldSet);

        String query = 'SELECT ' + String.join(fieldNames, ', ') + ' FROM ' + params.objectApiName;
        List<String> whereParts = new List<String>();

        String parentFilter = buildParentFilter(params, fieldMap);
        if (!String.isBlank(parentFilter)) {
            whereParts.add(parentFilter);
        }

        if (!String.isBlank(params.whereClause)) {
            whereParts.add('(' + params.whereClause + ')');
        }

        if(!String.isBlank(params.searchField) && !String.isBlank(params.searchValue)) {
            if (fieldMap.containsKey(params.searchField)) {
                String searchValue = String.escapeSingleQuotes(params.searchValue);
                String matchType = String.isBlank(params.valueMatchType) ? 'partial' : params.valueMatchType.toLowerCase();
                if(matchType == 'exact') {
                    whereParts.add(params.searchField + ' = \'' + searchValue + '\'');
                } else if (matchType == 'partial') {
                    whereParts.add(params.searchField + ' LIKE \'%' + searchValue + '%\'');
                } else {
                    throw new AuraHandledException('Invalid valueMatchType: ' + params.valueMatchType);
                }
            } else {
                throw new AuraHandledException('Search field ' + params.searchField + ' does not exist on object ' + params.objectApiName);
            }
        }

        if (!whereParts.isEmpty()) {
            query += ' WHERE ' + String.join(whereParts, ' AND ');
        }

        query = appendSortAndLimit(query, params);

        return query;
    }

    private static Map<String, Schema.SObjectField> getFieldMap(String objectApiName) {
        return Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap();
    }

    private static String buildParentFilter(QueryParams params, Map<String, Schema.SObjectField> fieldMap) {
        if (String.isBlank(params.parentFilterField) || params.parentFilterValue == null) {
            return '';
        }
        String op = String.isBlank(params.parentFilterOperator) ? '=' : params.parentFilterOperator.trim().toUpperCase();
        Schema.DisplayType dt = fieldMap.get(params.parentFilterField) != null ? fieldMap.get(params.parentFilterField).getDescribe().getType() : null;
        String valueStr = params.parentFilterValue;

        if (op == 'IN' || op == 'NOT IN') {
            List<String> values = params.parentFilterValue.split(',');
            List<String> formattedValues = new List<String>();
            for (String v : values) {
                String trimmed = v.trim();
                if (dt == Schema.DisplayType.String || dt == Schema.DisplayType.Id || dt == Schema.DisplayType.Picklist || dt == Schema.DisplayType.Reference || dt == Schema.DisplayType.TextArea) {
                    formattedValues.add('\'' + String.escapeSingleQuotes(trimmed) + '\'');
                } else {
                    formattedValues.add(trimmed);
                }
            }
            valueStr = '(' + String.join(formattedValues, ', ') + ')';
            return params.parentFilterField + ' ' + op + ' ' + valueStr;
        } else if (op == 'LIKE') {
            if (!valueStr.contains('%')) {
                valueStr = '%' + valueStr + '%';
            }
            valueStr = '\'' + String.escapeSingleQuotes(valueStr) + '\'';
            return params.parentFilterField + ' LIKE ' + valueStr;
        } else {
            if (dt == Schema.DisplayType.String || dt == Schema.DisplayType.Id || dt == Schema.DisplayType.Picklist || dt == Schema.DisplayType.Reference || dt == Schema.DisplayType.TextArea) {
                valueStr = '\'' + String.escapeSingleQuotes(params.parentFilterValue) + '\'';
            }
            return params.parentFilterField + ' ' + op + ' ' + valueStr;
        }
    }

    private static String appendSortAndLimit(String query, QueryParams params) {
        if (!String.isBlank(params.sortBy)) {
            String dir = String.isBlank(params.sortDirection) ? 'ASC' : params.sortDirection;
            query += ' ORDER BY ' + params.sortBy + ' ' + dir;
        }
        if (params.maxResults != null && params.maxResults > 0) {
            query += ' LIMIT ' + params.maxResults;
        }
        return query;
    }
}