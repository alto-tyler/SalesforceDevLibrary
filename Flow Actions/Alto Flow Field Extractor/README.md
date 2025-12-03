# Alto Flow Field Extractor

**API Version:** 63.0  
**Category:** Utility  
**InvocableMethod Label:** `Extract Field Values`

## Overview

The **Flow Field Extractor** action extracts a specified field from a record collection and returns the values as both a string collection and a CSV string. Supports optional deduplication for unique values only.

## Features

- **Dynamic Field Extraction:** Extract any field from any SObject collection
- **Dual Output Formats:** Returns both List<String> and comma-separated CSV
- **Deduplication Option:** Remove duplicate values automatically
- **Null Handling:** Skips null values (doesn't include in output)
- **Record Count:** Returns count of extracted values
- **With Sharing:** Respects org sharing rules
- **Type Agnostic:** Works with any field type (converts to string)

## How It Works

1. Loops through the input record collection
2. Extracts the specified field value from each record
3. Converts value to string (skips null values)
4. Optionally deduplicates values
5. Returns as both a string collection and CSV format

## Input Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| **Records** | SObject Collection | No | The collection to extract values from |
| **Field API Name** | Text | Yes | Field to extract (e.g., `Id`, `Name`, `Email`, `ProductCode__c`) |
| **Deduplicate** | Boolean | No | Remove duplicate values (default: `false`) |

## Output Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| **Values** | Text Collection | List of extracted field values as strings |
| **CSV** | Text | Comma-separated string of all values |
| **Number Of Records** | Number | Count of values in the output collection |

## Flow Examples

### Example 1: Extract Account IDs for SOQL Query

**Scenario:** Get a list of Account IDs to use in a dynamic SOQL query

**Flow Structure:**
1. **Get Records** → Query Opportunities with Amount > $10,000 (collection: `varOpportunities`)
2. **Action: Extract Field Values**
   - **Records:** `{!varOpportunities}`
   - **Field API Name:** `AccountId`
   - **Deduplicate:** `true`
3. **Action: Execute SOQL**
   - **SOQL Query:** `SELECT Id, Name FROM Account WHERE Id IN ('{!Values_from_Extract}')`

**Result:** Unique list of Account IDs as strings

---

### Example 2: Build CSV for External System

**Scenario:** Export a list of Product Codes as CSV for an integration

**Flow Structure:**
1. **Get Records** → Query Products for active items (collection: `varProducts`)
2. **Action: Extract Field Values**
   - **Records:** `{!varProducts}`
   - **Field API Name:** `ProductCode`
   - **Deduplicate:** `false`
3. **Create Records** → Create Integration Log with `CSV` field

**Result:** CSV string like `"PROD-001,PROD-002,PROD-003"`

---

### Example 3: Display Unique Owners

**Scenario:** Show a list of unique opportunity owners for reporting

**Flow Structure:**
1. **Get Records** → Query Opportunities (collection: `varOpportunities`)
2. **Action: Extract Field Values**
   - **Records:** `{!varOpportunities}`
   - **Field API Name:** `Owner.Name`
   - **Deduplicate:** `true`
3. **Screen** → Display `Values` collection in a text component

**Result:** Deduplicated list of owner names

---

### Example 4: Count Unique Values

**Scenario:** Determine how many unique products are in a quote

**Flow Structure:**
1. **Get Records** → Query Quote Line Items for Quote (collection: `varLineItems`)
2. **Action: Extract Field Values**
   - **Records:** `{!varLineItems}`
   - **Field API Name:** `Product2Id`
   - **Deduplicate:** `true`
3. **Screen** → Display `Number Of Records` as "Unique Product Count"

**Result:** Count of distinct products

---

### Example 5: Build Email Recipient List

**Scenario:** Create a semicolon-separated list of email addresses

**Flow Structure:**
1. **Get Records** → Query Contacts for Account (collection: `varContacts`)
2. **Action: Extract Field Values**
   - **Records:** `{!varContacts}`
   - **Field API Name:** `Email`
   - **Deduplicate:** `true`
3. **Assignment** → `{!varEmailList}` = Replace `{!CSV}` comma with semicolon
4. **Action: Send Email** → Use `varEmailList` for recipients

**Result:** Deduplicated email list

---

### Example 6: Extract Related Field Values

**Scenario:** Get all Account Names from a collection of Contacts

**Flow Structure:**
1. **Get Records** → Query Contacts (collection: `varContacts`)
2. **Action: Extract Field Values**
   - **Records:** `{!varContacts}`
   - **Field API Name:** `Account.Name`
   - **Deduplicate:** `true`
3. **Loop** → Process `Values` collection

**Result:** Unique list of parent Account names

---

## Use Cases

- **SOQL IN Clauses:** Build lists of IDs for dynamic queries
- **CSV Generation:** Create comma-separated values for integrations
- **Deduplication:** Get unique values from a field
- **Reporting:** Count distinct values
- **Email Lists:** Build recipient lists from Contact records
- **Data Export:** Extract field values for external systems
- **Validation:** Check for specific values in a collection
- **Related Record Data:** Extract parent or child field values

## Best Practices

1. **Deduplicate When Needed:** Use `true` for unique values, `false` to preserve all
2. **Null Handling:** Null values are automatically skipped (not included in output)
3. **Related Fields:** Use dot notation for parent fields (e.g., `Account.Name`)
4. **CSV Format:** CSV output is comma-separated with no spaces
5. **Check Count:** Use `Number Of Records` to verify extraction before processing
6. **String Conversion:** All field types are converted to strings
7. **Governor Limits:** Be mindful of heap size with very large collections

## Limitations

- **String Conversion Only:** All values are converted to strings
- **CSV Format:** Fixed comma separator (no custom delimiters)
- **No Formatting:** Numeric/Date values use default string conversion
- **Null Values Skipped:** Null values are not included in output
- **Governor Limits:** Subject to Apex heap size and CPU time limits
- **Collection Size:** Bound by Flow collection limits (typically 50,000 records)
- **No Complex Fields:** Cannot extract complex types (e.g., Address, Location)

## Troubleshooting

### Empty output when expecting values
- Verify **Field API Name** is correct (case-sensitive, include `__c` for custom fields)
- Check if all field values are null
- Ensure input collection has records
- Verify field exists on the SObject type

### "Field does not exist" error
- Confirm field API name spelling (include `__c` for custom fields)
- Check relationship field syntax (e.g., `Account.Name` not `AccountName`)
- Ensure field is accessible to running user's profile
- Verify field exists on all records in the collection

### Unexpected duplicates in output
- Verify `Deduplicate` is set to `true`
- Check if values differ by case (deduplication is case-sensitive)
- Look for leading/trailing spaces in field values

### CSV format issues
- CSV uses comma separator (no customization available)
- No quotes around values (standard comma-separated format)
- To change delimiter, use Formula to replace commas after extraction

### Related field returning null
- Verify parent record exists (check relationship field is populated)
- Confirm relationship field API name (e.g., `Account.Name` requires AccountId)
- Ensure parent record field is not null

## Comparison: Extract Field Values vs Assignment/Loop

| Feature | Flow Field Extractor | Assignment + Loop |
|---------|---------------------|-------------------|
| **Lines of Code** | 1 action | Loop + Assignment per iteration |
| **Deduplication** | Built-in | Requires complex formula logic |
| **CSV Output** | Automatic | Manual string concatenation |
| **Performance** | Fast (single Apex call) | Slower (multiple Flow operations) |
| **Null Handling** | Automatic skip | Manual null checks required |

**Best Practice:** Use Flow Field Extractor for cleaner, faster field extraction.

## Technical Details

- **Security:** `with sharing` - respects org sharing rules
- **API Version:** 63.0
- **Class:** `FlowFieldExtractor`
- **Test Class:** `FlowFieldExtractorTest`
- **Method:** `extractFieldValues(List<Request> requests)`

## Related Actions

- **Flow Collection Filter** - Filter collection before extraction
- **Flow Collection Comparator** - Compare collections based on field values
- **Execute SOQL** - Use extracted IDs in dynamic queries

---

## Example Response Structure

```apex
Response {
    values: ['001xx000003DGb2AAG', '001xx000003DGb3AAG', '001xx000003DGb4AAG'],
    csv: '001xx000003DGb2AAG,001xx000003DGb3AAG,001xx000003DGb4AAG',
    numberOfRecords: 3
}
```

---

## CSV Format Examples

**Without Deduplication:**
```
Input: [Product{Code: 'A'}, Product{Code: 'B'}, Product{Code: 'A'}]
Output CSV: 'A,B,A'
Number Of Records: 3
```

**With Deduplication:**
```
Input: [Product{Code: 'A'}, Product{Code: 'B'}, Product{Code: 'A'}]
Output CSV: 'A,B'
Number Of Records: 2
```

---

For deployment instructions, see the [main repository README](../../README.md).
