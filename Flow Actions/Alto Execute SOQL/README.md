# Alto Execute SOQL

A Flow action that executes dynamic SOQL queries and returns a collection of records. Automatically handles date/datetime formatting and supports complex queries with subqueries.

## Features

- **Dynamic SOQL Execution** - Run any valid SOQL query from Flow
- **Automatic Date Formatting** - Intelligently formats dates and datetimes in WHERE clauses
- **Multiple Date Formats Supported** - ISO, en_US, date literals (TODAY, LAST_WEEK, etc.)
- **Subquery Support** - Handles nested SELECT statements
- **Flexible Return Type** - Returns generic SObject collection that can be used with any object
- **`without sharing`** - Executes with system context for maximum query flexibility

---

## How It Works

1. Build an SOQL query string in your Flow using text variables or formulas
2. Pass the query string to the Execute SOQL action
3. Action automatically formats date/datetime values in WHERE clauses
4. Query executes and returns matching records
5. Use returned records in loops, assignments, or other Flow elements

**Note:** This action runs `without sharing`, meaning it bypasses record-level security and sharing rules.

---

## Input Parameters

| Parameter | Type | Label | Required | Description |
|-----------|------|-------|----------|-------------|
| **soqlQuery** | String | `Valid SOQL query string` | ✅ Yes | The SOQL query to execute. Can include variables and merge fields. |

---

## Output Parameters

| Parameter | Type | Label | Description |
|-----------|------|-------|-------------|
| **sObjects** | SObject[] | `List of sObjects returned from query` | Collection of records matching the query. Returns `null` if no records found. |

---

## Flow Examples

### Example 1: Query Records with Dynamic Criteria

**Scenario:** Get all Opportunities for an Account that are above a certain amount.

**Setup:**

1. **Screen** - Input Criteria
   - Collect minimum amount: `{!MinAmount}` (Currency variable)

2. **Assignment** - Build SOQL Query
   - Variable: `{!SOQLQuery}` (Text variable)
   - Value: `SELECT Id, Name, Amount, StageName FROM Opportunity WHERE AccountId = '{!recordId}' AND Amount >= {!MinAmount}`

3. **Action** - Execute SOQL Query
   - **soqlQuery**: `{!SOQLQuery}`
   - Store output:
     - `{!MatchingOpportunities}` = sObjects

4. **Loop** - Process Results
   - Collection: `{!MatchingOpportunities}`
   - Current Item: `{!CurrentOpportunity}`

**Result:** Dynamically query Opportunities based on user input.

---

### Example 2: Using Date Literals

**Scenario:** Get all Cases created today.

**Setup:**

1. **Assignment** - Build Query with Date Literal
   - Variable: `{!Query}` (Text)
   - Value: `SELECT Id, CaseNumber, Subject, Status FROM Case WHERE CreatedDate = TODAY`

2. **Action** - Execute SOQL Query
   - **soqlQuery**: `{!Query}`
   - Store output: `{!TodaysCases}` = sObjects

3. **Decision** - Check if Cases Exist
   - Outcome: `{!TodaysCases}` Is Null = False

**Result:** Retrieves today's cases using date literal (no formatting needed).

---

### Example 3: Query with Datetime Formatting

**Scenario:** Get records created after a specific date/time.

**Setup:**

1. **Screen** - Date Selection
   - Collect date: `{!StartDate}` (DateTime variable)

2. **Formula** - Format Query
   - Resource: `{!QueryString}` (Text Formula)
   - Formula: `"SELECT Id, Name FROM Account WHERE CreatedDate >= " & TEXT({!StartDate})`

3. **Action** - Execute SOQL Query
   - **soqlQuery**: `{!QueryString}`
   - Store output: `{!RecentAccounts}` = sObjects

**Result:** Action automatically formats the datetime value into ISO format for the query.

---

### Example 4: Complex Query with Multiple Conditions

**Scenario:** Query Contacts with multiple criteria and related Account data.

**Setup:**

1. **Assignment** - Build Complex Query
   - Variable: `{!ComplexQuery}` (Text)
   - Value: 
     ```
     SELECT Id, Name, Email, Phone, Account.Name, Account.Industry 
     FROM Contact 
     WHERE AccountId != null 
     AND Email != null 
     AND Account.Industry IN ('Technology', 'Finance')
     ORDER BY LastModifiedDate DESC
     LIMIT 100
     ```

2. **Action** - Execute SOQL Query
   - **soqlQuery**: `{!ComplexQuery}`
   - Store output: `{!QualifiedContacts}` = sObjects

**Result:** Returns up to 100 Contacts with populated emails from Technology or Finance accounts.

---

### Example 5: Query with Subquery

**Scenario:** Get Accounts with their related Opportunities.

**Setup:**

1. **Assignment** - Build Query with Subquery
   - Variable: `{!QueryWithSubquery}` (Text)
   - Value:
     ```
     SELECT Id, Name, Industry, 
            (SELECT Id, Name, Amount, StageName FROM Opportunities WHERE StageName = 'Closed Won')
     FROM Account
     WHERE Industry = 'Technology'
     ```

2. **Action** - Execute SOQL Query
   - **soqlQuery**: `{!QueryWithSubquery}`
   - Store output: `{!AccountsWithOpps}` = sObjects

3. **Loop** - Process Accounts
   - Collection: `{!AccountsWithOpps}`
   - Access related Opportunities via `{!CurrentAccount.Opportunities}`

**Result:** Returns Accounts with nested Opportunity collections.

---

## Supported Date Formats

### Date Literals (No Formatting Required)
- `YESTERDAY`, `TODAY`, `TOMORROW`
- `LAST_WEEK`, `THIS_WEEK`, `NEXT_WEEK`
- `LAST_MONTH`, `THIS_MONTH`, `NEXT_MONTH`
- `LAST_90_DAYS`, `NEXT_90_DAYS`
- `LAST_N_DAYS:n`, `NEXT_N_DAYS:n`
- `LAST_N_WEEKS:n`, `NEXT_N_WEEKS:n`
- `LAST_N_MONTHS:n`, `NEXT_N_MONTHS:n`
- `THIS_QUARTER`, `LAST_QUARTER`, `NEXT_QUARTER`
- `LAST_N_QUARTERS:n`, `NEXT_N_QUARTERS:n`
- `THIS_YEAR`, `LAST_YEAR`, `NEXT_YEAR`
- `LAST_N_YEARS:n`, `NEXT_N_YEARS:n`
- Fiscal period literals

### ISO Format (Auto-detected)
- `2024-12-03T15:30:00Z`
- Already in proper SOQL format

### en_US Format (Auto-formatted)
- `12/03/2024 03:24 PM`
- `12/03/2024, 3:24 PM`
- Action converts to ISO format automatically

### Month Day, Year Format (Auto-formatted)
- `December 3, 2024`
- Action converts to ISO format automatically

### Locale-specific (Auto-formatted)
- Uses Salesforce locale settings
- Parses dates based on user locale
- Converts to ISO format for query

---

## Troubleshooting

### No records returned (sObjects is null)
- Verify the SOQL query syntax is valid
- Check that records matching the criteria exist
- Use `Is Null` operator in Decision element to check for empty results
- Test the query in Developer Console Query Editor first

### Invalid SOQL query error
- Ensure field API names are correct (case-sensitive)
- Verify object API names are correct
- Check that parentheses are balanced in subqueries
- Ensure WHERE clause syntax is valid

### Date formatting issues
- Use date literals when possible (`TODAY`, `LAST_MONTH`)
- For dynamic dates, use ISO format: `YYYY-MM-DDTHH:MM:SSZ`
- Check that datetime variables are properly formatted in Flow
- Test with hardcoded dates first, then make dynamic

### "Unable to parse query string" error
- Query must contain `SELECT`, `FROM`, and `WHERE` clauses for date formatting
- Ensure object name is correctly specified after `FROM`
- Check for typos in keywords (`SELECT`, `FROM`, `WHERE`)

### Subquery not working
- Verify relationship name is correct (e.g., `Opportunities`, not `Opportunity`)
- Ensure subquery is wrapped in parentheses: `(SELECT...)`
- Check that parent object has access to child relationship

### Field not accessible error
- Running user must have field-level security access
- Check object permissions for running user
- Remember: action runs `without sharing` but still requires FLS

---

## Best Practices

### 1. Use LIMIT Clause
Always include `LIMIT` to prevent governor limit issues:
```
SELECT Id, Name FROM Account WHERE Industry = 'Technology' LIMIT 200
```

### 2. Test Queries in Developer Console
Before using in Flow, test queries in Developer Console to verify syntax and results.

### 3. Use Variables for Dynamic Criteria
```
Bad:  Hardcoding values in query
Good: Using merge fields: WHERE Industry = '{!SelectedIndustry}'
```

### 4. Handle Null Results
Always check if output is null before processing:
```
Decision: {!sObjects} Is Null = False
  Then: Process records
  Else: Show "No records found"
```

### 5. Be Specific with SELECT Clauses
Only select fields you need to reduce processing time and memory:
```
Bad:  SELECT Id FROM Account (minimal, but may need more fields)
Good: SELECT Id, Name, Industry FROM Account (specific fields needed)
```

### 6. Use Indexed Fields in WHERE Clauses
For better performance, filter on indexed fields when possible:
- Id, Name, OwnerId, CreatedDate, SystemModstamp
- External ID fields
- Custom fields marked as "Unique" or "External ID"

### 7. Escape Single Quotes in Dynamic Values
If using user input in queries, ensure single quotes are escaped:
```
Formula: SUBSTITUTE({!UserInput}, "'", "\\'")
```

### 8. Consider Governor Limits
- Maximum 50,000 records returned per query
- Maximum 100 SOQL queries per transaction
- Use selective queries to avoid Full Table Scans

---

## Limitations

### Security Context
- **Runs `without sharing`** - Bypasses sharing rules and record-level security
- User must still have object and field-level security access
- Be cautious when exposing data to users who shouldn't see it

### Query Restrictions
- Cannot execute DML statements (INSERT, UPDATE, DELETE)
- Cannot execute other non-SELECT statements
- Must be valid SOQL syntax
- Subject to standard SOQL governor limits (50,000 records max)

### Date Formatting
- Only formats dates/datetimes in WHERE clauses
- Does not format dates in SELECT or ORDER BY clauses
- Requires `SELECT`, `FROM`, and `WHERE` keywords for parsing

### Return Type
- Returns generic SObject collection
- Flow must handle type casting if accessing specific fields
- Null is returned if no records match (not an empty list)

### Performance
- Complex queries with multiple subqueries may be slow
- Large result sets can consume heap memory
- No built-in pagination mechanism

---

## API Version

Built with **Salesforce API version 55.0**.

---

## Dependencies

No external dependencies. Pure Apex implementation.

---

## Use Cases

### Dynamic Reporting
- Build custom report queries based on user selections
- Filter records dynamically without pre-built views
- Allow users to select fields and criteria

### Data Migration
- Query records for export or transformation
- Build dynamic WHERE clauses based on migration rules
- Process records in batches with LIMIT and OFFSET

### Record Selection
- Let users search for records with custom criteria
- Provide advanced search functionality
- Query related records dynamically

### Conditional Processing
- Query records that meet specific conditions
- Process only records matching runtime criteria
- Dynamic segmentation and targeting

---

## Security Considerations

⚠️ **Important:** This action runs with `without sharing`, which means:

1. **Sharing Rules Bypassed**: All records are visible regardless of user's sharing access
2. **Use with Caution**: Ensure sensitive data is not exposed inappropriately
3. **Add Logic Checks**: Implement additional permission checks in Flow if needed
4. **Audit Usage**: Monitor who uses Flows containing this action

**Best Practice:** If you need sharing rules enforced, consider creating a custom action with `with sharing` or use standard Get Records element instead.

---

## Deployment

Deploy the Apex class to your org:
- See the main repository README for deployment instructions
- Includes test class with coverage
- No additional components required

---

## Testing

Test class `ExecuteSOQLTest` provides coverage for:
- Basic query execution
- Date/datetime formatting (multiple formats)
- Subquery handling
- Error conditions
- NULL handling
