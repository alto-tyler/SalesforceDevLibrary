# Alto Rollup Numbers (Action)

A Flow action that performs rollup calculations (SUM, AVERAGE, MEDIAN, MIN, MAX, COUNT) on numeric fields from a record collection. Unlike the screen component version, this is a pure Apex action that can be used anywhere in a Flow without requiring a screen.

## Features

- **Six Rollup Operations** - SUM, AVERAGE, MEDIAN, MIN, MAX, COUNT
- **Generic SObject Support** - Works with any Salesforce object
- **Null-Safe** - Handles empty collections and null values gracefully
- **Single Field Processing** - Calculates one field at a time
- **Type Flexible** - Accepts Decimal, Integer, Long, Double, and numeric strings
- **No UI Required** - Pure action, works in autolaunched Flows

---

## How It Works

1. Pass a record collection to the action
2. Specify the numeric field API name to calculate
3. Choose rollup operation: SUM, AVERAGE, MEDIAN, MIN, MAX, or COUNT
4. Action returns the calculated result as a Decimal
5. Use the result in formulas, decisions, assignments, or other elements

---

## Input Parameters

| Parameter | Type | Label | Required | Description |
|-----------|------|-------|----------|-------------|
| **Records** | SObject[] | `Records` | No | Record collection to perform rollup calculations on |
| **Field API Name** | String | `Field API Name` | ✅ Yes | API name of numeric field to calculate (e.g., `Amount`, `Quantity__c`) |
| **Rollup Option** | String | `Rollup Option` | ✅ Yes | Calculation method: `SUM`, `AVERAGE`, `MEDIAN`, `MIN`, `MAX`, or `COUNT` |

---

## Output Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| **Result** | Decimal | Calculated result based on rollup option. Returns `null` if no valid values found (except COUNT returns 0). |

---

## Rollup Operations

### SUM
Adds all numeric values in the field.

**Example:** For Amounts `[100, 200, 300]` → Result = `600`

### AVERAGE
Calculates the arithmetic mean of all numeric values.

**Example:** For Amounts `[100, 200, 300]` → Result = `200`

### MEDIAN
Finds the middle value when values are sorted (or average of two middle values for even counts).

**Example:** 
- For `[100, 200, 300]` → Result = `200`
- For `[100, 200, 300, 400]` → Result = `250`

### MIN
Returns the smallest numeric value.

**Example:** For Amounts `[100, 200, 300]` → Result = `100`

### MAX
Returns the largest numeric value.

**Example:** For Amounts `[100, 200, 300]` → Result = `300`

### COUNT
Returns the total number of records in the collection (regardless of field values).

**Example:** For any collection of 5 records → Result = `5`

**Note:** COUNT returns the total number of records, not the count of non-null values in the field.

---

## Flow Examples

### Example 1: Calculate Total Opportunity Amount

**Scenario:** Sum all Opportunity amounts for decision logic.

**Setup:**

1. **Get Records** - Get Opportunities
   - Object: `Opportunity`
   - Conditions: `StageName` Equals `Closed Won`, `AccountId` Equals `{!recordId}`
   - Store in: `{!ClosedOpportunities}`

2. **Action** - Alto Rollup Numbers
   - **Records**: `{!ClosedOpportunities}`
   - **Field API Name**: `Amount`
   - **Rollup Option**: `SUM`
   - Store output: `{!TotalAmount}` = Result

3. **Decision** - Check Total
   - Outcome 1: `{!TotalAmount}` Greater Than `1000000`
   - Outcome 2: Default

**Result:** `TotalAmount` contains the sum of all closed won Opportunity amounts.

---

### Example 2: Find Average Deal Size

**Scenario:** Calculate average Opportunity size for reporting.

**Setup:**

1. **Get Records** - Get Opportunities
   - Object: `Opportunity`
   - Conditions: `OwnerId` Equals `{!$User.Id}`
   - Store in: `{!MyOpportunities}`

2. **Action** - Rollup Numbers (Average)
   - **Records**: `{!MyOpportunities}`
   - **Field API Name**: `Amount`
   - **Rollup Option**: `AVERAGE`
   - Store output: `{!AvgDealSize}` = Result

3. **Update Records** - Update User Record
   - Record: `{!$User.Id}`
   - Field: `Average_Deal_Size__c` = `{!AvgDealSize}`

**Result:** User record updated with current average deal size.

---

### Example 3: Count Records Without Loop

**Scenario:** Count how many Cases are in a collection.

**Setup:**

1. **Get Records** - Get Cases
   - Object: `Case`
   - Conditions: `Status` Not Equal `Closed`
   - Store in: `{!OpenCases}`

2. **Action** - Rollup Numbers (Count)
   - **Records**: `{!OpenCases}`
   - **Field API Name**: `Id` (can be any field)
   - **Rollup Option**: `COUNT`
   - Store output: `{!CaseCount}` = Result

3. **Send Email** - Notification
   - Body: `You have {!CaseCount} open cases.`

**Result:** Email contains the count of open cases.

---

### Example 4: Find Min and Max Order Values

**Scenario:** Identify the smallest and largest order amounts.

**Setup:**

1. **Get Records** - Get Orders
   - Object: `Order`
   - Conditions: `AccountId` Equals `{!recordId}`
   - Store in: `{!AccountOrders}`

2. **Action** - Rollup Numbers (Min)
   - **Records**: `{!AccountOrders}`
   - **Field API Name**: `TotalAmount`
   - **Rollup Option**: `MIN`
   - Store output: `{!SmallestOrder}` = Result

3. **Action** - Rollup Numbers (Max)
   - **Records**: `{!AccountOrders}`
   - **Field API Name**: `TotalAmount`
   - **Rollup Option**: `MAX`
   - Store output: `{!LargestOrder}` = Result

4. **Update Records** - Update Account
   - Field: `Smallest_Order__c` = `{!SmallestOrder}`
   - Field: `Largest_Order__c` = `{!LargestOrder}`

**Result:** Account record shows the range of order values.

---

### Example 5: Calculate Median for Statistical Analysis

**Scenario:** Find the median value to understand the middle of your data distribution.

**Setup:**

1. **Get Records** - Get Products
   - Object: `Product2`
   - Conditions: `IsActive` Equals `true`
   - Store in: `{!ActiveProducts}`

2. **Action** - Rollup Numbers (Median)
   - **Records**: `{!ActiveProducts}`
   - **Field API Name**: `ListPrice__c`
   - **Rollup Option**: `MEDIAN`
   - Store output: `{!MedianPrice}` = Result

3. **Create Records** - Log to Custom Object
   - Object: `Product_Analytics__c`
   - Field: `Median_Price__c` = `{!MedianPrice}`
   - Field: `Calculation_Date__c` = `{!$Flow.CurrentDateTime}`

**Result:** Median product price logged for trend analysis.

---

## Null Handling

### Empty or Null Collections
- If **Records** is empty or null, returns `null` (except COUNT returns `0`)

### Null Field Values
- Null or non-numeric values are excluded from calculations
- Action only processes valid numeric values
- COUNT still returns total record count regardless of field values

### Missing Fields
- If the specified field doesn't exist on records, result is `null`
- No error is thrown - action handles gracefully

**Example:**
```
Records: [
  { Amount: 100 },
  { Amount: null },
  { Amount: 200 }
]

SUM → 300 (null excluded)
AVERAGE → 150 (averages 100 and 200)
COUNT → 3 (counts all records)
```

---

## Troubleshooting

### Result is always null
- Verify **Records** variable contains data
- Check **Field API Name** matches the actual field API name (case-sensitive)
- Ensure the field is numeric (Number, Currency, Percent)
- Check that records have non-null values in the specified field

### Wrong field API name format
- Use API names with `__c` suffix for custom fields (e.g., `Quantity__c`)
- Standard fields use their API name (e.g., `Amount`, `NumberOfEmployees`)
- Don't include object name (use `Amount`, not `Opportunity.Amount`)

### COUNT returns 0 when expecting a number
- COUNT returns the total record count, not the count of non-null field values
- If you need non-null value count, use a different approach or filter records first

### Incorrect calculation results
- **SUM/AVERAGE**: Check for null values being excluded (may affect averages)
- **MEDIAN**: Verify you understand median vs average (middle value when sorted)
- **MIN/MAX**: Ensure all values are numeric (strings won't compare correctly)

### Using with formula fields
- Formula fields work as long as they return numeric values
- Currency conversion formulas work correctly
- Rollup summary fields can be used as input fields

### Action not found in Flow Builder
- Verify the Apex class is deployed
- Check that API version is compatible
- Ensure class has `@InvocableMethod` annotation
- Refresh Flow Builder page

---

## Best Practices

### 1. Use COUNT for Record Counts
Instead of looping through a collection to count records:
```
❌ Loop + Assignment to increment counter
✅ Alto Rollup Numbers with Rollup Option = COUNT
```

### 2. Handle Null Results
Always check for null before using results:
```
Decision: {!Result} Is Null = False
  Then: Use result
  Else: Handle no data scenario
```

### 3. Validate Input Collections
Always verify your Get Records element returns data before calculating:
```
1. Get Records
2. Decision: Is collection empty?
3a. If empty: Show message / exit
3b. If has records: Calculate rollups
```

### 4. Choose the Right Operation
- **SUM**: Total values (revenue, quantities)
- **AVERAGE**: Mean values (average deal size)
- **MEDIAN**: Middle value (less affected by outliers)
- **MIN/MAX**: Range boundaries (smallest/largest values)
- **COUNT**: Quick record counts without loops

### 5. Use in Autolaunched Flows
Perfect for scheduled Flows, platform events, and record-triggered Flows:
```
Record-Triggered Flow → Get Records → Rollup Numbers → Update Record
```

### 6. Combine Multiple Calculations
For multiple metrics, call the action multiple times:
```
1. Rollup Numbers (SUM) → TotalAmount
2. Rollup Numbers (COUNT) → RecordCount
3. Formula: AverageAmount = TotalAmount / RecordCount
```

---

## Limitations

### Data Types
- Only works with numeric fields (Number, Currency, Percent)
- Text, Date, DateTime, and other types are ignored
- Boolean fields are not supported

### Single Field
- Processes one field per action call
- For multiple fields, call action multiple times
- Consider screen component version for dual-field processing

### Performance
- Processes all records in memory
- Very large collections (1000+ records) may have performance impact
- Consider filtering records in Get Records to limit dataset size

### Output Type
- Results are returned as Decimal type
- Use formulas to format results for display (e.g., TEXT() for formatting)
- Currency symbols must be added separately

### No Conditional Aggregation
- Cannot apply filters within the action (e.g., "SUM only if Status = Active")
- Filter records in Get Records element before passing to action
- Use multiple Get Records + Rollup actions for different conditions

---

## Differences from Screen Component Version

| Feature | Action (Apex) | Screen Component (LWC) |
|---------|---------------|------------------------|
| **Usage Context** | Anywhere in Flow | Screen elements only |
| **Fields Processed** | One field per call | Two fields simultaneously |
| **Reactivity** | No reactive behavior | Reactive (auto-updates on input change) |
| **UI Display** | No UI | No UI (calculation only) |
| **Output Type** | Decimal | Integer |
| **Best For** | Background processing, autolaunched Flows | Interactive Flows with reactive screens |

---

## API Version

Built with **Salesforce API version 59.0**.

---

## Dependencies

No external dependencies. Pure Apex implementation with test class included.

---

## Use Cases

### Business Calculations
- Calculate total revenue from Opportunities
- Find average case resolution time
- Determine median product price points
- Identify min/max order values

### Data Validation
- Count records to verify Get Records results
- Calculate sums to compare against expected values
- Find outliers using MIN/MAX

### Conditional Logic
- Sum amounts to determine approval routing
- Average values to trigger escalation rules
- Count records for threshold-based decisions

### Scheduled/Triggered Flows
- Daily rollup calculations in scheduled Flows
- Real-time aggregations in record-triggered Flows
- Platform event processing with aggregation

---

## Deployment

Deploy the Apex class to your org:
- See the main repository README for deployment instructions
- Includes test class `RollupNumberHelperTest` with full coverage
- No additional components required

---

## Testing

Test class `RollupNumberHelperTest` provides coverage for:
- All six rollup operations (SUM, AVERAGE, MEDIAN, MIN, MAX, COUNT)
- Null handling (empty collections, null values)
- Multiple data types (Decimal, Integer, Long, Double)
- Edge cases (single record, even/odd counts for median)
- Invalid field names
