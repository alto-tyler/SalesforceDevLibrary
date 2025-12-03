# Alto Rollup Numbers

A Flow screen component that performs rollup calculations (SUM, AVERAGE, MEDIAN, MIN, MAX, COUNT) on numeric fields from a record collection without displaying any UI.

## Features

- **No-UI Component** - Invisible on screen, only processes data and returns results
- **Dual Field Support** - Calculate rollups for two different fields simultaneously
- **Six Rollup Operations** - SUM, AVERAGE, MEDIAN, MIN, MAX, COUNT
- **Generic SObject Support** - Works with any Salesforce object
- **Reactive Calculations** - Automatically recalculates when inputs change (requires Flow API 59.0+)
- **Null-Safe** - Handles empty collections and null values gracefully
- **Alto Datatable Integration** - Pass `outputAllRows` from Alto Datatable to rollup column values reactively

---

## How It Works

1. Pass a record collection from Flow to the component
2. Specify one or two numeric field API names to calculate
3. Choose rollup operation(s): SUM, AVERAGE, MEDIAN, MIN, MAX, or COUNT
4. Component calculates results and outputs as Integer values
5. Use output values in your Flow logic (formulas, decisions, assignments)

**Note:** This component has no visual output - it only processes data in the background.

### Integration with Alto Datatable

You can pass the **`outputAllRows`** output from Alto Datatable directly into this component's **Records** input. When users filter, edit, or interact with the datatable, the rollup calculations will automatically update in real-time. Use the rollup results in Display Text, Text/Number Input components, or other screen elements on the same screen to show live calculations.

**Reactive Behavior:** Requires Flow API version 59.0 or higher for reactive screen functionality.

---

## Input Properties

| Property | Type | Label | Required | Description |
|----------|------|-------|----------|-------------|
| **Records** | SObject[] | `Records` | ✅ Yes | Record collection to perform rollup calculations on |
| **Number Field API Name (1)** | String | `Number Field API Name (1)` | No | API name of first numeric field to calculate (e.g., `Amount`, `Quantity__c`) |
| **Rollup Option (1)** | String | `Rollup Option (1)` | No | Calculation method for field 1: `SUM`, `AVERAGE`, `MEDIAN`, `MIN`, `MAX`, `COUNT` (default: `SUM`) |
| **Number Field API Name (2)** | String | `Number Field API Name (2)` | No | API name of second numeric field to calculate |
| **Rollup Option (2)** | String | `Rollup Option (2)` | No | Calculation method for field 2: `SUM`, `AVERAGE`, `MEDIAN`, `MIN`, `MAX`, `COUNT` (default: `SUM`) |

---

## Output Properties

| Property | Type | Label | Description |
|----------|------|-------|-------------|
| **Result (1)** | Integer | `Result (1)` | Calculated result for first field based on Rollup Option (1) |
| **Result (2)** | Integer | `Result (2)` | Calculated result for second field based on Rollup Option (2) |

**Note:** Results are `null` if no valid numeric values are found (except for COUNT which returns 0).

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

**Scenario:** Get the sum of all Opportunity amounts for display or decision logic.

**Setup:**

1. **Get Records** - Get Opportunities
   - Object: `Opportunity`
   - Conditions: `StageName` Equals `Closed Won`
   - Store in: `ClosedOpportunities` (Record Collection)

2. **Screen** - Add Alto Rollup Numbers
   - **Records**: `{!ClosedOpportunities}`
   - **Number Field API Name (1)**: `Amount`
   - **Rollup Option (1)**: `SUM`
   - Store output:
     - `{!TotalAmount}` (Number) = `Result (1)`

3. **Decision** or **Display** element
   - Use `{!TotalAmount}` in your Flow logic

**Result:** `TotalAmount` variable contains the sum of all Opportunity amounts.

---

### Example 2: Calculate Average and Max Order Values

**Scenario:** Find both the average order value and the largest order to display on a summary screen.

**Setup:**

1. **Get Records** - Get Orders
   - Object: `Order`
   - Conditions: `AccountId` Equals `{!recordId}`
   - Store in: `AccountOrders`

2. **Screen** - Summary Screen
   - Add **Alto Rollup Numbers** component
   - **Records**: `{!AccountOrders}`
   - **Number Field API Name (1)**: `TotalAmount`
   - **Rollup Option (1)**: `AVERAGE`
   - **Number Field API Name (2)**: `TotalAmount`
   - **Rollup Option (2)**: `MAX`
   - Store outputs:
     - `{!AvgOrderValue}` = `Result (1)`
     - `{!LargestOrder}` = `Result (2)`

3. Add **Display Text** components to show values:
   - "Average Order Value: ${!AvgOrderValue}"
   - "Largest Order: ${!LargestOrder}"

**Result:** Users see both average and maximum order values calculated from the same field.

---

### Example 3: Count Records with Rollup

**Scenario:** Count how many Cases are in a collection without needing a Loop element.

**Setup:**

1. **Get Records** - Get Cases
   - Object: `Case`
   - Conditions: `Status` Not Equal `Closed`
   - Store in: `OpenCases`

2. **Screen** - Add Alto Rollup Numbers (invisible)
   - **Records**: `{!OpenCases}`
   - **Number Field API Name (1)**: (leave blank)
   - **Rollup Option (1)**: `COUNT`
   - Store output:
     - `{!OpenCaseCount}` = `Result (1)`

3. **Decision** - Check Case Count
   - Outcome 1: `{!OpenCaseCount}` Greater Than `10`
   - Outcome 2: Default

**Result:** `OpenCaseCount` contains the total number of records without needing a Loop.

---

### Example 4: Dual Field Calculation on Custom Objects

**Scenario:** Calculate both total quantity and total value from Order Line Items.

**Setup:**

1. **Get Records** - Get Order Line Items
   - Object: `OrderItem`
   - Conditions: `OrderId` Equals `{!OrderId}`
   - Store in: `OrderLineItems`

2. **Screen** - Add Alto Rollup Numbers
   - **Records**: `{!OrderLineItems}`
   - **Number Field API Name (1)**: `Quantity`
   - **Rollup Option (1)**: `SUM`
   - **Number Field API Name (2)**: `TotalPrice`
   - **Rollup Option (2)**: `SUM`
   - Store outputs:
     - `{!TotalQuantity}` = `Result (1)`
     - `{!TotalValue}` = `Result (2)`

3. **Assignment** or **Display**
   - Use both `{!TotalQuantity}` and `{!TotalValue}` in downstream logic

**Result:** Both quantity sum and price sum calculated in a single component.

---

### Example 5: Median Price Point Analysis

**Scenario:** Find the median price to understand the middle of your product pricing.

**Setup:**

1. **Get Records** - Get Products
   - Object: `Product2`
   - Conditions: `IsActive` Equals `true`
   - Store in: `ActiveProducts`

2. **Screen** - Add Alto Rollup Numbers
   - **Records**: `{!ActiveProducts}`
   - **Number Field API Name (1)**: `ListPrice__c`
   - **Rollup Option (1)**: `MEDIAN`
   - Store output:
     - `{!MedianPrice}` = `Result (1)`

3. **Display Text**
   - "Median Product Price: ${!MedianPrice}"

**Result:** Shows the middle price point when all active products are sorted by price.

---

### Example 6: Reactive Datatable Integration

**Scenario:** Display a datatable of Opportunities and show live rollup calculations (total amount, count) that update as users filter or edit the datatable.

**Setup:**

1. **Get Records** - Get Opportunities
   - Object: `Opportunity`
   - Conditions: `OwnerId` Equals `{!$User.Id}`
   - Store in: `MyOpportunities`

2. **Screen** - Summary Dashboard
   - Add **Alto Datatable** component
     - **Records**: `{!MyOpportunities}`
     - **Object API Name**: `Opportunity`
     - Configure columns: Name, Amount, StageName, CloseDate
     - Enable filtering and inline editing
     - Store output:
       - `{!FilteredOpps}` = `outputAllRows`
   
   - Add **Alto Rollup Numbers** component (invisible)
     - **Records**: `{!FilteredOpps}` ← Use datatable's outputAllRows
     - **Number Field API Name (1)**: `Amount`
     - **Rollup Option (1)**: `SUM`
     - **Number Field API Name (2)**: (leave blank)
     - **Rollup Option (2)**: `COUNT`
     - Store outputs:
       - `{!TotalAmount}` = `Result (1)`
       - `{!OppCount}` = `Result (2)`
   
   - Add **Display Text** components
     - "Total Pipeline: ${!TotalAmount}"
     - "Showing {!OppCount} opportunities"

**Result:** As users filter the datatable or edit Amount values inline, the rollup calculations automatically update without leaving the screen. This provides real-time feedback on filtered/edited data.

**Requirements:** Flow API version 59.0+ for reactive behavior.
   - **Rollup Option (1)**: `MEDIAN`
   - Store output:
     - `{!MedianPrice}` = `Result (1)`

3. **Display Text**
   - "Median Product Price: ${!MedianPrice}"

**Result:** Shows the middle price point when all active products are sorted by price.

---

## Reactivity Behavior

The component automatically recalculates results when any input changes:

- **Records collection changes** - New records added/removed (e.g., from Alto Datatable's `outputAllRows`)
- **Field API name changes** - Different field selected
- **Rollup option changes** - Calculation method changed

This reactive behavior allows you to:
- Update calculations dynamically based on user selections
- Recalculate when screen data refreshes
- Chain calculations with other reactive components (e.g., Alto Datatable filtering)
- Display live rollup values in Display Text, Text Input, or Number Input components on the same screen

**Integration with Other Components:**
- Connect to **Alto Datatable's `outputAllRows`** to show live rollup calculations as users filter/edit table data
- Use rollup outputs in **Display Text** components to show real-time totals
- Use rollup outputs in **Text/Number Input** components for conditional visibility or validation
- Chain multiple rollup calculations together on the same screen

**Requirements:** Reactive screen functionality requires **Flow API version 59.0 or higher**.

---

## Null Handling

### Empty or Null Collections
- If `Records` is empty or null, results will be `null` (except COUNT returns `0`)

### Null Field Values
- Null or non-numeric values are excluded from calculations
- Component only processes valid numeric values
- COUNT still returns total record count regardless of field values

### Missing Fields
- If the specified field doesn't exist on the records, result is `null`
- No error is thrown - component handles gracefully

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
- Verify **Records** variable contains data (use Debug to check)
- Check **Number Field API Name** matches the actual field API name (case-sensitive)
- Ensure the field is numeric (Number, Currency, Percent)
- Check that records have non-null values in the specified field

### Wrong field API name format
- Use API names with `__c` suffix for custom fields (e.g., `Quantity__c`)
- Standard fields use their API name (e.g., `Amount`, `NumberOfEmployees`)
- Don't include object name (use `Amount`, not `Opportunity.Amount`)

### COUNT returns 0 when expecting a number
- COUNT returns the total record count, not the count of non-null field values
- If you need non-null value count, use a different approach or filter records first

### Results not updating
- Ensure the **Records** variable is actually changing
- Check that you're storing outputs to Flow variables correctly
- Verify reactive property changes are triggering (add Debug element)

### Incorrect calculation results
- **SUM/AVERAGE**: Check for null values being excluded (may affect averages)
- **MEDIAN**: Verify you understand median vs average (middle value when sorted)
- **MIN/MAX**: Ensure all values are numeric (strings won't compare correctly)

### Using with formula fields
- Formula fields work as long as they return numeric values
- Currency conversion formulas work correctly
- Rollup summary fields can be used as input fields

---

## Best Practices

### 1. Use COUNT for Record Counts
Instead of looping through a collection to count records:
```
❌ Loop + Assignment to increment counter
✅ Alto Rollup Numbers with Rollup Option = COUNT
```

### 2. Calculate Multiple Metrics at Once
Use both Field 1 and Field 2 inputs to calculate two metrics simultaneously instead of adding two separate components.

### 3. Validate Input Collections
Always verify your Get Records element returns data before using rollup calculations:
```
1. Get Records
2. Decision: Is collection empty?
3a. If empty: Show message
3b. If has records: Calculate rollups
```

### 4. Store Outputs Immediately
Map rollup results to Flow variables on the same screen where the component exists - outputs are available instantly.

### 5. Choose the Right Operation
- **SUM**: Total values (revenue, quantities)
- **AVERAGE**: Mean values (average deal size)
- **MEDIAN**: Middle value (less affected by outliers)
- **MIN/MAX**: Range boundaries (smallest/largest values)
- **COUNT**: Quick record counts without loops

### 6. Use Null Checks in Formulas
When using rollup results in formulas, check for null:
```
IF(ISBLANK({!Result1}), 0, {!Result1})
```

### 7. Place on Hidden Screens
Since this component has no UI, place it on a screen with other components or use it to pre-calculate values before a Decision element.

---

## Use Cases

### Business Reporting
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
- Count records to show/hide screen sections

### Dashboard Metrics
- Calculate KPIs for display on summary screens
- Aggregate data for visual components
- Pre-calculate values for chart inputs

---

## Limitations

### Data Types
- Only works with numeric fields (Number, Currency, Percent)
- Text, Date, DateTime, and other types are ignored
- Boolean fields are not supported

### Performance
- Processes all records in memory
- Very large collections (1000+ records) may have performance impact
- Consider filtering records in Get Records to limit dataset size

### Output Type
- Results are returned as Integer type
- Decimal values are preserved for AVERAGE and MEDIAN
- Use formulas to format results for display (e.g., currency formatting)

### No Conditional Aggregation
- Cannot apply filters within the component (e.g., "SUM only if Status = Active")
- Filter records in Get Records element before passing to component
- Use multiple Get Records + Rollup components for different conditions

---

## API Version

Built with **Salesforce API version 59.0**.

---

## Dependencies

This component is self-contained with no external dependencies:
- No Apex classes required
- No static resources required
- Pure LWC implementation

All code is included in the `force-app` folder.

---

## Support

For issues or questions:
- Verify **Records** collection contains data
- Check field API names are correct (case-sensitive)
- Ensure fields are numeric types
- Use Flow Debug to inspect input/output values
- Review troubleshooting section above

---

## Deployment

To deploy this component, see the main repository README for deployment instructions. This component can be deployed standalone as it has no dependencies on other components.
