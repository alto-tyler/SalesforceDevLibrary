# Alto Flow Collection Comparator

**API Version:** 63.0  
**Category:** Utility  
**InvocableMethod Label:** `Compare Record Collections`

## Overview

The **Flow Collection Comparator** action compares two record collections based on specified field values and returns which primary records match (or don't match) the secondary collection. This is useful for filtering, validation, and data reconciliation workflows.

## Features

- **Compare Two Collections:** Compare primary records against a secondary reference collection
- **Field-Based Matching:** Match on any field (text, number, ID, etc.)
- **Case Sensitivity Option:** Control whether text comparisons are case-sensitive
- **Dual Output:** Returns both matching and non-matching records
- **Match Counts:** Provides counts for both matching and non-matching records
- **Null-Safe:** Handles null values and empty collections gracefully
- **With Sharing:** Respects org sharing rules for secure comparisons

## How It Works

1. Extracts field values from the **secondary collection** into a lookup Set
2. Iterates through the **primary collection** comparing each record's field value
3. Separates primary records into **matching** and **non-matching** lists
4. Returns both lists plus match counts

## Input Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| **Primary Records** | SObject Collection | No* | The main collection to filter/categorize |
| **Secondary Records** | SObject Collection | No* | The reference collection to compare against |
| **Primary Field API Name** | Text | Yes | Field to compare from primary records (e.g., `Name`, `ProductCode__c`) |
| **Secondary Field API Name** | Text | Yes | Field to compare from secondary records (can be same or different field) |
| **Case Sensitive** | Boolean | No | Whether text comparisons are case-sensitive (default: `false`) |

*While marked as not required to prevent Flow runtime failures, both collections should be provided for meaningful results.

## Output Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| **Matching Records** | SObject Collection | Primary records that matched secondary collection |
| **Non-Matching Records** | SObject Collection | Primary records that did NOT match secondary collection |
| **Match Count** | Number | Count of matching records |
| **Non-Match Count** | Number | Count of non-matching records |

## Flow Examples

### Example 1: Filter Quote Line Items Against Product Master

**Scenario:** You have a collection of Quote Line Items and want to identify which products are (or aren't) in the Product Master.

**Flow Structure:**
1. **Get Records** → Query Quote Line Items (collection: `varQuoteLineItems`)
2. **Get Records** → Query Rootstock Product Master records (collection: `varProductMaster`)
3. **Action: Compare Record Collections**
   - **Primary Records:** `{!varQuoteLineItems}`
   - **Secondary Records:** `{!varProductMaster}`
   - **Primary Field API Name:** `Product2Id`
   - **Secondary Field API Name:** `rstk__soprod_sf_product__c`
   - **Case Sensitive:** `true`
4. **Decision** → Check if `Match Count > 0`
5. **Loop** → Process `Matching Records` or `Non-Matching Records`

**Use Case:** Validate quote line items that have a Rootstock Product Master.

---

### Example 2: Reconcile Imported Records Against Existing Records

**Scenario:** Import a CSV of Account Names and identify which are new vs. existing.

**Flow Structure:**
1. **Get Records** → Query all Accounts (collection: `varExistingAccounts`)
2. **Loop** → Process CSV rows and create temp Account records (collection: `varImportedAccounts`)
3. **Action: Compare Record Collections**
   - **Primary Records:** `{!varImportedAccounts}`
   - **Secondary Records:** `{!varExistingAccounts}`
   - **Primary Field API Name:** `Name`
   - **Secondary Field API Name:** `Name`
   - **Case Sensitive:** `false`
4. **Create Records** → Create only `Non-Matching Records` (new accounts)
5. **Screen** → Show `Matching Records` as "Already Exists"

**Use Case:** Import validation, duplicate prevention, data migration.

---

### Example 3: Filter Collection by Another Collection's IDs

**Scenario:** You have a collection of Opportunities and only want those belonging to specific Accounts.

**Flow Structure:**
1. **Get Records** → Query target Accounts (collection: `varTargetAccounts`)
2. **Get Records** → Query all Opportunities (collection: `varAllOpportunities`)
3. **Action: Compare Record Collections**
   - **Primary Records:** `{!varAllOpportunities}`
   - **Secondary Records:** `{!varTargetAccounts}`
   - **Primary Field API Name:** `AccountId`
   - **Secondary Field API Name:** `Id`
   - **Case Sensitive:** Not applicable for IDs
4. **Loop** → Process `Matching Records`

**Use Case:** Parent-child filtering, territory-based filtering, permission-based record access.

---

### Example 4: Identify Unprocessed Records

**Scenario:** Compare a collection of records against a "processed" collection to find what's left.

**Flow Structure:**
1. **Get Records** → Query all Invoices for the month (collection: `varAllInvoices`)
2. **Get Records** → Query Invoices with Status = "Processed" (collection: `varProcessedInvoices`)
3. **Action: Compare Record Collections**
   - **Primary Records:** `{!varAllInvoices}`
   - **Secondary Records:** `{!varProcessedInvoices}`
   - **Primary Field API Name:** `Id`
   - **Secondary Field API Name:** `Id`
4. **Loop** → Process `Non-Matching Records` (unprocessed invoices)

**Use Case:** Status-based filtering, exception handling, batch processing.

---

### Example 5: Cross-Object Field Comparison

**Scenario:** Compare Product records against Order Items to find products never ordered.

**Flow Structure:**
1. **Get Records** → Query all Products (collection: `varProducts`)
2. **Get Records** → Query Order Items (collection: `varOrderItems`)
3. **Action: Compare Record Collections**
   - **Primary Records:** `{!varProducts}`
   - **Secondary Records:** `{!varOrderItems}`
   - **Primary Field API Name:** `ProductCode`
   - **Secondary Field API Name:** `Product2.ProductCode`
   - **Case Sensitive:** `false`
4. **Decision** → If `Non-Match Count > 0`
5. **Loop** → Review `Non-Matching Records` (products never ordered)

**Use Case:** Inventory management, sales analysis, product lifecycle tracking.

---

## Use Cases

- **Validation:** Verify records against a master list
- **Duplicate Detection:** Find matching records across collections
- **Data Reconciliation:** Compare imported vs. existing records
- **Filtering:** Separate records based on another collection's criteria
- **Exception Handling:** Identify records that don't meet criteria
- **Batch Processing:** Find unprocessed or remaining records
- **Cross-Object Comparisons:** Match records across different objects

## Best Practices

1. **Query Efficiently:** Only query the fields you need for comparison
2. **Consider Case Sensitivity:** Text fields should typically use `Case Sensitive = false`
3. **Use IDs When Possible:** Comparing IDs is faster and more reliable than text
4. **Handle Empty Results:** Check `Match Count` or `Non-Match Count` before looping
5. **Field Type Matching:** Ensure compared fields have compatible data types
6. **Large Collections:** For very large collections (10,000+ records), consider SOQL filtering instead
7. **Null Values:** Records with null field values will go to `Non-Matching Records`

## Limitations

- **Governor Limits:** Bound by Apex heap size and CPU time limits
- **Field Type Conversion:** All field values are converted to strings for comparison
- **No Pattern Matching:** Exact matches only (no wildcards or regex)
- **Single Field Comparison:** Can only compare one field at a time
- **Collection Size:** Subject to Flow collection limits (typically 50,000 records)

## Troubleshooting

### No records in either output collection
- Verify both input collections have records
- Check that field API names are spelled correctly (case-sensitive)
- Ensure field values aren't all null
- Verify field exists on the SObject type

### Unexpected matches or non-matches
- Check **Case Sensitive** setting for text comparisons
- Verify field values don't have leading/trailing spaces
- Confirm field data types are compatible
- Test with a smaller dataset to isolate the issue

### "Field does not exist" error
- Verify field API name includes `__c` for custom fields
- Check relationship field syntax (e.g., `Account.Name` not just `Account`)
- Ensure field is accessible via the running user's profile

### Performance issues
- Reduce collection sizes with more specific queries
- Consider filtering in SOQL before comparison
- Use indexed fields when possible
- Break large comparisons into smaller batches

## Technical Details

- **Security:** `with sharing` - respects org sharing rules
- **API Version:** 63.0
- **Class:** `FlowCollectionComparator`
- **Test Class:** `FlowCollectionComparatorTest`
- **Method:** `compareCollections(List<Request> requests)`

## Related Actions

- **Flow Collection Filter** - Filter a single collection based on field criteria
- **Flow Field Extractor** - Extract field values into a list or CSV
- **Execute SOQL** - Run dynamic queries with custom criteria

---

## Example Response Structure

```apex
Response {
    matchingRecords: [
        Account { Name: 'Acme Corp' },
        Account { Name: 'Global Industries' }
    ],
    nonMatchingRecords: [
        Account { Name: 'New Company' },
        Account { Name: 'Startup LLC' }
    ],
    matchCount: 2,
    nonMatchCount: 2
}
```

---

For deployment instructions, see the [main repository README](../../README.md).
