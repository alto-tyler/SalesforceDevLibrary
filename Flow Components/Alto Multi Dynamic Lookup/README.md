# Alto Multi Dynamic Lookup

A Flow screen component that allows users to search and select multiple records using the Alto Dynamic Lookup component, displaying selected items as removable pills.

## ⚠️ Dependency Requirement

**This component requires the Alto Dynamic Lookup component to be deployed first.**

The Multi Dynamic Lookup component is a wrapper around the single-select Dynamic Lookup component, adding multi-select functionality with pill display. You must deploy Alto Dynamic Lookup before deploying this component.

**Deployment Order:**
1. Deploy [Alto Dynamic Lookup](../Alto%20Dynamic%20Lookup/) first
2. Then deploy Alto Multi Dynamic Lookup

---

## Features

- Search and select multiple records from any Salesforce object
- Visual pill display of selected items with remove capability
- "Clear All" button to remove all selections at once
- All search capabilities from Dynamic Lookup (parent filtering, barcode scanning, custom queries)
- Validation support for required multi-select fields
- Four output formats: semicolon-separated strings and arrays for both IDs and display names

---

## How It Works

1. User searches for records using the embedded Dynamic Lookup component
2. When a record is selected, it's added as a pill below the search field
3. Selected items remain visible as pills even as the lookup clears for next search
4. Users can remove individual pills or clear all selections at once
5. Flow receives selected IDs and names in multiple formats for flexible processing

---

## Input Properties

### Display Section

| Property | Type | Label | Default | Description |
|----------|------|-------|---------|-------------|
| **Label** | String | `I01_Display_Label` | "Search and Select" | Label shown above the multi-select component |
| **Placeholder** | String | `I02_Display_Placeholder` | "Search..." | Placeholder text in the lookup search field |
| **Icon Name** | String | `I03_Display_IconName` | "standard:account" | SLDS icon shown in lookup and pills (e.g., `standard:account`, `utility:search`) |

### Object Configuration Section

| Property | Type | Label | Required | Description |
|----------|------|-------|----------|-------------|
| **Object API Name** | String | `I04_Object_ObjectApiName` | ✅ Yes | API name of the object to search (e.g., `Account`, `Contact`) |
| **Display Field Name** | String | `I05_Object_DisplayFieldName` | ✅ Yes | Field to display in search results and pills (e.g., `Name`) |
| **Search Field API Name** | String | `I06_Object_SearchFieldApiName` | ✅ Yes | Field to search when user types (e.g., `Name`) |
| **Value Field Name** | String | `I07_Object_ValueFieldName` | No | Field to use as value in outputs (default: `Id`, but can be any unique field) |

### Query Configuration Section

| Property | Type | Label | Default | Description |
|----------|------|-------|---------|-------------|
| **Max Results** | Integer | `I08_Query_MaxResults` | 200 | Maximum records to show in search dropdown (1-2000) |
| **Where Clause** | String | `I09_Query_WhereClause` | — | Additional WHERE conditions (e.g., `Type = 'Customer'`) |
| **Sort By** | String | `I10_Query_SortBy` | — | Field to sort results by (e.g., `Name`, `CreatedDate`) |
| **Sort Direction** | String | `I11_Query_SortDirection` | "asc" | Sort direction: `asc` or `desc` |
| **Value Match Type** | String | `I12_Query_ValueMatchType` | "partial" | Match type: `exact` (equals) or `partial` (contains) |

### Parent Filter Section

| Property | Type | Label | Default | Description |
|----------|------|-------|---------|-------------|
| **Parent Initialized** | Boolean | `I13_Parent_ParentInitialized` | false | Set to true when parent component has loaded (enables parent filtering) |
| **Parent Filter Field** | String | `I14_Parent_ParentFilterField` | — | Field on child object to filter by parent (e.g., `AccountId` for Contacts) |
| **Parent Filter Value** | String | `I15_Parent_ParentFilterValue` | — | Value from parent to filter on (e.g., `{!Account.Id}`) |
| **Parent Filter Operator** | String | `I16_Parent_ParentFilterOperator` | "=" | Comparison operator: `=`, `!=`, `IN`, `LIKE`. Use comma-separated values for `IN` |
| **Disable On No Parent Value** | Boolean | `I17_Parent_DisableOnNoParentValue` | false | Disable lookup when parent value is empty |

### Behavior Section

| Property | Type | Label | Default | Description |
|----------|------|-------|---------|-------------|
| **Required** | Boolean | `I18_Behavior_Required` | false | Make at least one selection required for Flow progression (validates on Next) |
| **Disabled** | Boolean | `I19_Behavior_Disabled` | false | Disable the entire multi-lookup component |
| **Allow Display Field Match** | Boolean | `I20_Behavior_AllowDisplayFieldMatch` | false | Allow searching on display field even when search field is different |
| **Relative Dropdown** | Boolean | `I21_Behavior_RelativeDropdown` | false | Make dropdown position relative to screen instead of input field |
| **Populate On Tab** | Boolean | `I22_Behavior_PopulateOnTab` | false | Pressing Tab waits for records to load and selects first result |

### Barcode Scanning Section

| Property | Type | Label | Default | Description |
|----------|------|-------|---------|-------------|
| **Allow Barcode Scanning** | Boolean | `I23_Scan_AllowBarcodeScanning` | false | Enable barcode scanning button in lookup field |
| **Scan Button Icon** | String | `I24_Scan_ScanButtonIcon` | "utility:scan" | Icon for the barcode scan button |

---

## Output Properties

| Property | Type | Label | Description |
|----------|------|-------|-------------|
| **Selected Values** | String | `O1_selectedValues` | Semicolon-separated list of selected IDs (based on Value Field Name) |
| **Selected Values Collection** | String[] | `O2_selectedValuesCollection` | Array of selected IDs for loop processing in Flow |
| **Selected Names** | String | `O3_selectedNames` | Semicolon-separated list of selected names (based on Display Field Name) |
| **Selected Names Collection** | String[] | `O4_selectedNamesCollection` | Array of selected names for loop processing in Flow |

**Note:** The component provides both string and collection outputs for flexibility. Use collections for loops, use strings for display or simple storage.

---

## Flow Examples

### Example 1: Multi-Select Contacts for Account

**Scenario:** On an Account record screen, allow users to select multiple Contacts to add to a campaign.

**Setup:**

1. Add a Screen element with **Alto Multi Dynamic Lookup**
2. Configure properties:
   - **Label**: `Select Campaign Members`
   - **Object API Name**: `Contact`
   - **Display Field Name**: `Name`
   - **Search Field API Name**: `Name`
   - **Parent Filter Field**: `AccountId`
   - **Parent Filter Value**: `{!recordId}` (your Account ID variable)
   - **Parent Initialized**: `{!$GlobalConstant.True}`
   - **Required**: `{!$GlobalConstant.True}`
   - **Icon Name**: `standard:contact`

3. Create Flow variables to store outputs:
   - **selectedContactIds** (Text) = `{!MultiLookup.selectedValues}`
   - **selectedContactNames** (Text Collection) = `{!MultiLookup.selectedNamesCollection}`

4. After screen, add a Loop element:
   - **Collection Variable**: `{!selectedContactNames}`
   - Inside loop: Display confirmation message with each contact name

---

### Example 2: Select Multiple Products with Barcode Scanning

**Scenario:** Allow warehouse users to scan and select multiple products for an order.

**Setup:**

1. Add a Screen element with **Alto Multi Dynamic Lookup**
2. Configure properties:
   - **Label**: `Scan or Search Products`
   - **Object API Name**: `Product2`
   - **Display Field Name**: `Name`
   - **Search Field API Name**: `ProductCode`
   - **Value Field Name**: `Id`
   - **Allow Barcode Scanning**: `{!$GlobalConstant.True}`
   - **Scan Button Icon**: `utility:scan`
   - **Icon Name**: `standard:product`
   - **Where Clause**: `IsActive = true`
   - **Required**: `{!$GlobalConstant.True}`

3. Create Flow variables:
   - **selectedProductIds** (Text Collection) = `{!MultiLookup.selectedValuesCollection}`

4. After screen, use Loop to process each product ID:
   - Get Product records using the collection
   - Create Order Line Items for each

---

### Example 3: Dependent Multi-Lookup with Validation

**Scenario:** First select an Account, then select multiple Cases related to that Account.

**Setup:**

**Screen 1: Select Account**
1. Add **Alto Dynamic Lookup** for Account selection
2. Store selected Account ID in variable: `selectedAccountId`

**Screen 2: Select Multiple Cases**
1. Add **Alto Multi Dynamic Lookup** for Cases
2. Configure properties:
   - **Label**: `Select Cases to Update`
   - **Object API Name**: `Case`
   - **Display Field Name**: `CaseNumber`
   - **Search Field API Name**: `CaseNumber`
   - **Parent Filter Field**: `AccountId`
   - **Parent Filter Value**: `{!selectedAccountId}`
   - **Parent Initialized**: Map to Account lookup's `componentInitialized` output
   - **Disable On No Parent Value**: `{!$GlobalConstant.True}`
   - **Required**: `{!$GlobalConstant.True}`
   - **Icon Name**: `standard:case`

3. Store outputs:
   - **selectedCaseIds** (Text Collection) = `{!MultiLookup.selectedValuesCollection}`
   - **selectedCaseNumbers** (Text) = `{!MultiLookup.selectedNames}`

4. Use a Loop element to process each Case ID

**Why use Parent Initialized?**
- Prevents Cases from loading before Account is selected
- Ensures dependent relationship is properly established
- Maps to the Account lookup's `componentInitialized` output property

---

### Example 4: Rehydrating Selected Values on Screen Navigation

**Scenario:** User selects multiple records, clicks Previous to go back, then returns to the screen - their selections should still be visible.

**Setup:**

1. Add **Alto Multi Dynamic Lookup** to a Screen
2. Create variables:
   - **selectedIds** (Text) - stores semicolon-separated IDs
   - **selectedNames** (Text) - stores semicolon-separated names

3. **On the Screen:**
   - Map `Selected Values` input to `{!selectedIds}`
   - Map `Selected Names` input to `{!selectedNames}`
   - Map `Selected Values` output to `{!selectedIds}`
   - Map `Selected Names` output to `{!selectedNames}`

4. **Result:**
   - When screen loads, component reads `selectedIds` and `selectedNames` variables
   - Displays pills for all previously selected items
   - When user adds/removes items, variables update automatically
   - Navigation back and forth preserves selections

**This is the self-mapping pattern** - same variable mapped to both input and output properties.

---

## Validation Behavior

When **Required** is set to `true`:
- Clicking "Next" in Flow validates that at least one item is selected
- If no items selected, Flow displays error: "Please select at least one item."
- User cannot proceed until they select at least one record
- Error message appears below the component

**Tip:** Use Required when selections are mandatory for Flow logic to work properly.

---

## Troubleshooting

### Component doesn't appear in Flow Builder
- Verify **both** Alto Dynamic Lookup and Alto Multi Dynamic Lookup are deployed
- Refresh Flow Builder browser tab
- Check deployment logs for errors

### "The requested resource does not exist" error
- **Cause:** Alto Dynamic Lookup component is not deployed
- **Solution:** Deploy Alto Dynamic Lookup component first, then redeploy Multi Dynamic Lookup

### Search returns no results
- Check **Object API Name** is correct (e.g., `Account`, not "Accounts")
- Verify **Search Field API Name** exists on the object
- Review **Where Clause** syntax - must be valid SOQL (don't include "WHERE" keyword)
- Ensure user has read access to the object and search fields

### Parent filter not working
- Verify **Parent Initialized** is set to `{!$GlobalConstant.True}` or mapped to parent lookup's `componentInitialized` output
- Check **Parent Filter Field** exists on the child object (e.g., `AccountId` on Contact)
- Ensure **Parent Filter Value** variable contains a valid ID
- If using **Disable On No Parent Value**, component will be disabled until parent value exists

### Duplicate pills appear
- Component automatically prevents duplicates based on **Value Field Name**
- If duplicates appear, check that Value Field Name contains unique values (typically `Id`)

### Pills show IDs instead of names
- Ensure **Display Field Name** is set to a text field like `Name`
- Verify the field has data (not null/blank)
- If using initial values, make sure to map both `selectedValues` AND `selectedNames` inputs

### Selected items disappear when navigating back
- Use the self-mapping pattern: map the same variable to both input and output properties
- Example: `selectedIds` → Selected Values (input), Selected Values → `selectedIds` (output)
- This preserves selections across screen navigation

---

## Best Practices

### 1. Use Collections for Loops, Strings for Display
```
Loop over selectedValuesCollection to process each record
Display selectedNames in a text template for confirmation
```

### 2. Always Map Parent Initialized for Dependent Lookups
When filtering by parent record:
- Create a parent Dynamic Lookup component first
- Map its `componentInitialized` output to this component's `Parent Initialized` input
- This ensures proper loading sequence

### 3. Implement Self-Mapping for Navigation Persistence
Map the same variable to both input and output:
- Input: `Selected Values` = `{!selectedIds}`
- Output: `{!selectedIds}` = `Selected Values`

### 4. Provide Clear Labels
Use descriptive labels that explain what users are selecting:
- ✅ "Select Campaign Members"
- ✅ "Choose Products for Order"
- ❌ "Multi Lookup"

### 5. Use Where Clauses for Filtering
Filter irrelevant records before users search:
```
IsActive = true AND Type = 'Customer'
```

### 6. Consider Max Results
- Default is 200 records
- Increase for larger datasets, but be mindful of performance
- Consider using more specific Where Clause instead of increasing Max Results

---

## Output Format Examples

When you select 3 Contacts (John Smith, Jane Doe, Bob Jones):

| Output Property | Format | Example Value |
|----------------|--------|---------------|
| **Selected Values** | String (semicolon-separated) | `003xx001;003xx002;003xx003` |
| **Selected Values Collection** | String[] (array) | `["003xx001", "003xx002", "003xx003"]` |
| **Selected Names** | String (semicolon-separated) | `John Smith;Jane Doe;Bob Jones` |
| **Selected Names Collection** | String[] (array) | `["John Smith", "Jane Doe", "Bob Jones"]` |

**When to use each:**
- **String outputs**: Display in text templates, store in text variables, simple string processing
- **Collection outputs**: Loop processing, creating records, passing to subflows that expect collections

---

## Component Architecture

The Multi Dynamic Lookup component:
1. **Embeds** the Alto Dynamic Lookup component for search functionality
2. **Adds** pill display for multiple selections
3. **Provides** "Clear All" functionality
4. **Prevents** duplicate selections automatically
5. **Outputs** both string and collection formats for flexibility

**Relationship:**
```
Alto Multi Dynamic Lookup (wrapper)
    └── Alto Dynamic Lookup (embedded for search)
```

This is why deploying Dynamic Lookup first is required.

---

## API Version

Built with **Salesforce API version 62.0**.

---

## Support

For issues or questions:
- Ensure Alto Dynamic Lookup is deployed first
- Review the [Dynamic Lookup documentation](../Alto%20Dynamic%20Lookup/) for search-related configuration
- Check deployment logs for specific error messages
- Verify user permissions for objects and fields being queried
