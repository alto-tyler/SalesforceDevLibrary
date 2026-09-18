# Alto Flow Collection Filter

**API Version:** 66.0  
**Category:** Utility  
**InvocableMethod Label:** `Filter Record Collection`

## Overview

The **Flow Collection Filter** action filters a collection of records based on field value criteria. It supports exact matches, partial matches (contains), case sensitivity, inverted matches (NOT logic), relationship (dot-notation) field traversal, and multi-field filtering with AND/OR logic. Returns the filtered collection, first matching record, and match count.

## Features

- **Field-Based Filtering:** Filter on any field type (text, number, picklist, etc.)
- **Relationship Field Traversal:** Filter on parent-relationship fields using dot-notation (e.g., `Account.Name`, `Account__r.Name`)
- **Multi-Field Filtering:** Add additional field/value criteria via comma-separated lists, without chaining multiple actions
- **AND/OR Match Logic:** Choose whether all criteria must match (`AND`, default) or any criterion must match (`OR`)
- **Multiple Match Modes:** Exact match, partial match (contains), blank/null detection
- **Case Sensitivity Option:** Control text comparison behavior
- **Inverted Match (NOT):** Find records that DON'T match criteria
- **Three Outputs:** Filtered collection, first matching record, and match count
- **Null-Safe:** Handles null and blank values gracefully, including missing relationship records
- **With Sharing:** Respects org sharing rules

## How It Works

1. Builds a list of filter criteria: the primary field/value pair, plus any additional fields/values supplied
2. Loops through the input record collection
3. For each record, evaluates every criterion (traversing relationship fields when the field name contains a `.`) and combines the results using the configured `AND`/`OR` logic
4. Returns all matching records plus metadata (first record, count)

## Input Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| **Records** | SObject Collection | Yes | The collection to filter |
| **Field API Name** | Text | Yes | Field to evaluate (e.g., `Status__c`, `Name`, `Account.Name`) |
| **Target Value** | Text | No | Value to match against. If blank/null, finds blank fields |
| **Case Sensitive** | Boolean | No | Whether text comparisons are case-sensitive (default: `false`) |
| **Partial Match** | Boolean | No | If `true`, matches if field contains target value (default: `false`) |
| **Invert Match** | Boolean | No | If `true`, returns records that DON'T match (default: `false`) |
| **Additional Fields** | Text | No | Comma-separated list of extra field API names to filter on (e.g., `Industry,Type`) |
| **Additional Values** | Text | No | Comma-separated list of target values matching the order of **Additional Fields** |
| **Match Logic** | Text | No | `AND` or `OR` — how the primary criterion and any additional criteria are combined (default: `AND`) |

Case Sensitive, Partial Match, and Invert Match apply uniformly to the primary criterion and all additional criteria in a given request.

## Output Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| **Filtered Records** | SObject Collection | Records that matched the criteria |
| **First Record** | SObject | The first matching record (null if no matches) |
| **Match Count** | Number | Count of matching records |

## Flow Examples

### Example 1: Filter by Status

**Scenario:** Get all Opportunities with Status = "Closed Won"

**Flow Structure:**
1. **Get Records** → Query Opportunities (collection: `varOpportunities`)
2. **Action: Filter Record Collection**
   - **Records:** `{!varOpportunities}`
   - **Field API Name:** `StageName`
   - **Target Value:** `Closed Won`
   - **Case Sensitive:** `false`
   - **Partial Match:** `false`
   - **Invert Match:** `false`
3. **Loop** → Process `Filtered Records`

---

### Example 2: Find Records with Blank/Null Fields

**Scenario:** Find Contacts without email addresses

**Flow Structure:**
1. **Get Records** → Query Contacts (collection: `varContacts`)
2. **Action: Filter Record Collection**
   - **Records:** `{!varContacts}`
   - **Field API Name:** `Email`
   - **Target Value:** *(leave blank)*
   - **Invert Match:** `false`
3. **Screen** → Display `Match Count` and `Filtered Records`

**Result:** Returns contacts where Email is null or blank.

---

### Example 3: Partial Match (Contains)

**Scenario:** Find Products with "Pro" in the name

**Flow Structure:**
1. **Get Records** → Query Products (collection: `varProducts`)
2. **Action: Filter Record Collection**
   - **Records:** `{!varProducts}`
   - **Field API Name:** `Name`
   - **Target Value:** `Pro`
   - **Case Sensitive:** `false`
   - **Partial Match:** `true`
   - **Invert Match:** `false`
3. **Loop** → Process `Filtered Records`

**Result:** Returns "Professional Plan", "Pro Account", "Bronze Pro", etc.

---

### Example 4: Inverted Match (NOT)

**Scenario:** Get all Accounts that are NOT in California

**Flow Structure:**
1. **Get Records** → Query Accounts (collection: `varAccounts`)
2. **Action: Filter Record Collection**
   - **Records:** `{!varAccounts}`
   - **Field API Name:** `BillingState`
   - **Target Value:** `California`
   - **Case Sensitive:** `false`
   - **Partial Match:** `false`
   - **Invert Match:** `true`
3. **Loop** → Process `Filtered Records`

**Result:** Returns all accounts where BillingState ≠ "California"

---

### Example 5: Filter by Checkbox Value

**Scenario:** Get all Users where IsActive = true

**Flow Structure:**
1. **Get Records** → Query Users (collection: `varUsers`)
2. **Action: Filter Record Collection**
   - **Records:** `{!varUsers}`
   - **Field API Name:** `IsActive`
   - **Target Value:** `true`
   - **Case Sensitive:** `false`
   - **Partial Match:** `false`
3. **Loop** → Process `Filtered Records`

**Note:** Boolean fields are converted to strings ("true" / "false")

---

### Example 6: Find Non-Blank Fields (Double Inversion)

**Scenario:** Find Contacts that HAVE email addresses

**Flow Structure:**
1. **Get Records** → Query Contacts (collection: `varContacts`)
2. **Action: Filter Record Collection**
   - **Records:** `{!varContacts}`
   - **Field API Name:** `Email`
   - **Target Value:** *(leave blank)*
   - **Invert Match:** `true`
3. **Loop** → Process `Filtered Records`

**Logic:** Match blank emails, then invert = records with non-blank emails

---

### Example 7: Filter by Relationship Field

**Scenario:** Get all Contacts whose parent Account name is "Acme Corp"

**Flow Structure:**
1. **Get Records** → Query Contacts, including `Account.Name` (collection: `varContacts`)
2. **Action: Filter Record Collection**
   - **Records:** `{!varContacts}`
   - **Field API Name:** `Account.Name`
   - **Target Value:** `Acme Corp`
3. **Loop** → Process `Filtered Records`

**Note:** The queried record must have the relationship field selected (e.g., via SOQL `SELECT Id, Account.Name FROM Contact`) for it to be available to traverse. Missing/null parent records resolve to a null field value rather than an error.

---

### Example 8: Multi-Field Filter with AND Logic

**Scenario:** Get Accounts whose name contains "Acme" AND whose Industry is "Technology"

**Flow Structure:**
1. **Get Records** → Query Accounts (collection: `varAccounts`)
2. **Action: Filter Record Collection**
   - **Records:** `{!varAccounts}`
   - **Field API Name:** `Name`
   - **Target Value:** `Acme`
   - **Partial Match:** `true`
   - **Additional Fields:** `Industry`
   - **Additional Values:** `Technology`
   - **Match Logic:** `AND`
3. **Loop** → Process `Filtered Records`

**Result:** Returns only Accounts matching both criteria (e.g., "Acme Corp" with Industry = Technology, but not "Acme Inc" with Industry = Manufacturing).

---

### Example 9: Multi-Field Filter with OR Logic

**Scenario:** Get Accounts whose name contains "Acme" OR whose Industry is "Manufacturing"

**Flow Structure:**
1. **Get Records** → Query Accounts (collection: `varAccounts`)
2. **Action: Filter Record Collection**
   - **Records:** `{!varAccounts}`
   - **Field API Name:** `Name`
   - **Target Value:** `Acme`
   - **Partial Match:** `true`
   - **Additional Fields:** `Industry`
   - **Additional Values:** `Manufacturing`
   - **Match Logic:** `OR`
3. **Loop** → Process `Filtered Records`

**Result:** Returns any Account matching either criterion.

---

### Example 10: Three-Field AND Filter

**Scenario:** Get Accounts named like "Test" AND Industry = "Tech" AND Type = "Customer"

**Flow Structure:**
1. **Get Records** → Query Accounts (collection: `varAccounts`)
2. **Action: Filter Record Collection**
   - **Records:** `{!varAccounts}`
   - **Field API Name:** `Name`
   - **Target Value:** `Test`
   - **Partial Match:** `true`
   - **Additional Fields:** `Industry,Type`
   - **Additional Values:** `Tech,Customer`
   - **Match Logic:** `AND`
3. **Loop** → Process `Filtered Records`

**Note:** Additional Fields/Additional Values are matched by position — the Nth value applies to the Nth field.

---

## Use Cases

- **Status Filtering:** Filter by Stage, Status, or other picklist values
- **Data Quality:** Find records with blank required fields
- **Search:** Find records containing specific text
- **Validation:** Ensure records meet criteria before processing
- **Exception Handling:** Find records that DON'T meet criteria (inverted)
- **Conditional Processing:** Process only records matching runtime conditions
- **Record Selection:** Get a subset for display or further processing
- **Cross-Object Filtering:** Filter child records by a value on their parent (e.g., Contacts by Account name)
- **Multi-Criteria Filtering:** Filter on several fields at once with AND/OR logic instead of chaining multiple actions

## Best Practices

1. **Query First:** Use SOQL filtering when possible (more efficient than Apex filtering)
2. **Case Sensitivity:** Use `false` for user-entered text comparisons
3. **Null Handling:** Leave Target Value blank to find null/blank fields
4. **Partial Matches:** Great for search-like functionality (contains)
5. **Check Match Count:** Before looping, verify `Match Count > 0`
6. **Use First Record:** Access single record output without looping
7. **Combine Filters:** Use **Additional Fields**/**Additional Values** with **Match Logic** for multi-criteria filtering in a single action, or chain multiple actions for more complex AND-of-ORs style logic
8. **Relationship Queries:** When filtering on a relationship field, make sure the relationship is included in the original SOQL query

## Limitations

- **Positional Multi-Field Matching:** Additional Fields/Additional Values are matched by comma position, so both lists must stay in sync and avoid commas within values
- **Uniform Match Options:** Case Sensitive, Partial Match, and Invert Match apply to all criteria in a request (primary and additional) — they cannot be set per-field
- **Single Logic Mode:** Only one of AND/OR applies per action call (no mixed AND/OR grouping within a single call)
- **String Conversion:** All field values are converted to strings
- **No Regex:** Pattern matching is limited to "contains" (no wildcards or regex)
- **Governor Limits:** Subject to Apex heap size and CPU time
- **Collection Size:** Bound by Flow collection limits (typically 50,000 records)

## Troubleshooting

### No records returned when expecting matches
- Verify field API name is correct (case-sensitive, include `__c` for custom fields, `__r` for custom relationships)
- Check Target Value for extra spaces or formatting
- Try `Case Sensitive = false` for text fields
- Verify records actually contain the target value
- Check if `Invert Match` is accidentally enabled
- For relationship fields, confirm the relationship was included in the SOQL query that produced the collection

### Too many records returned
- Verify `Partial Match` isn't enabled when you want exact matches
- Check `Invert Match` setting
- Ensure Target Value is specific enough
- Verify field data is clean (no extra spaces, formatting)
- If using multiple fields, confirm `Match Logic` is `AND` and not `OR`

### "Field does not exist" error
- Confirm field API name spelling (case-sensitive)
- Include `__c` suffix for custom fields
- Check field is accessible to running user's profile
- Verify field exists on the SObject type in collection

### Unexpected results with Invert Match
- **Blank Target + Invert = false:** Returns blank/null fields
- **Blank Target + Invert = true:** Returns non-blank fields
- **Value Target + Invert = true:** Returns records NOT matching value
- Test logic with small dataset first

### Unexpected results with multi-field filtering
- Confirm **Additional Fields** and **Additional Values** have the same number of comma-separated entries, in the same order
- Remember `Match Logic` defaults to `AND` when left blank
- Case Sensitive/Partial Match/Invert Match apply to every criterion, not just the primary one

## Comparison: Filter vs Get Records

| Feature | Flow Collection Filter | Get Records (SOQL) |
|---------|----------------------|---------------------|
| **When to Use** | Filter existing collection | Query from database |
| **Performance** | Slower (Apex loop) | Faster (database query) |
| **Flexibility** | Runtime field selection | Fixed fields at design time |
| **Partial Match** | Yes | Requires LIKE syntax |
| **Invert Match** | Yes | Requires NOT/!= logic |
| **Multi-Field AND/OR** | Yes, in one action | Requires multiple WHERE conditions |
| **Relationship Fields** | Yes (if already queried) | Yes |
| **Collection Input** | Yes | No (always queries) |

**Best Practice:** Use Get Records for initial queries, Filter for runtime criteria on existing collections.

## Technical Details

- **Security:** `with sharing` - respects org sharing rules
- **API Version:** 66.0
- **Class:** `FlowCollectionFilter`
- **Test Class:** `FlowCollectionFilterTest`
- **Method:** `filterCollection(List<Request> requests)`
- **Helper Methods:** `buildFilterCriteria`, `evaluateRecord`, `evaluateSingleCriterion`, `getFieldValue` (supports dot-notation relationship traversal)

## Related Actions

- **Flow Collection Comparator** - Compare two collections
- **Flow Field Extractor** - Extract field values into list/CSV
- **Execute SOQL** - Run dynamic queries with custom WHERE clauses

---

## Example Response Structure

```apex
Response {
    filteredRecords: [
        Contact { Name: 'John Doe', Email: 'john@example.com' },
        Contact { Name: 'Jane Smith', Email: 'jane@example.com' }
    ],
    firstRecord: Contact { Name: 'John Doe', Email: 'john@example.com' },
    matchCount: 2
}
```

---

For deployment instructions, see the [main repository README](../../README.md).
