# Alto Dynamic Lookup — Flow User Guide

This component provides a powerful, configurable lookup field for Flows that can search any Salesforce object with filtering, sorting, and parent-child relationships. Perfect for creating custom search experiences in your Flows.

**Key Features:**
- Filter Contacts by Account
- Search Products by Category
- Find Cases by Status and Owner
- Create dependent lookups (select Account first, then Contact)
- Barcode scanning for inventory/asset lookups (mobile)
- **Translation Support:** Uses Custom Labels for all UI text, enabling multi-language support

---

## Adding to Your Flow

1. In Flow Builder, drag a **Screen** element onto your canvas.
2. In the left panel under **Components**, search for **"Alto Dynamic Lookup"** and drag it onto your screen.
3. Configure the properties (see sections below).

---

## Flow Properties (Organized by Section)

The component properties are organized into logical sections in Flow Builder. All property labels start with a prefix (e.g., `I01_`, `I02_`) to keep them grouped and sorted.

### **Display Section** (I01-I04)

**I01_Display_Label**
- The label shown above the lookup field
- Example: `"Select Contact"`, `"Choose Product"`

**I02_Display_HelpText**
- Help text shown in tooltip next to label
- Example: `"Choose a contact for this opportunity."`

**I03_Display_Placeholder**
- Placeholder text in the search input
- Default: `"Search..."`
- Example: `"Type to search contacts..."`

**I04_Display_IconName**
- SLDS icon to show next to results
- Default: `"standard:account"`
- Examples: `"standard:contact"`, `"standard:product2"`, `"utility:search"`
- [Find icons here](https://www.lightningdesignsystem.com/icons/)

---

### **Object Configuration Section** (I05-I08)

**I05_Object_ObjectApiName** *(critical)*
- API name of the object to search
- Examples: `"Account"`, `"Contact"`, `"Product2"`, `"Custom_Object__c"`

**I06_Object_DisplayFieldName**
- Field to display in the dropdown results
- Default: `"Name"`
- Examples: `"Name"`, `"Email"`, `"ProductCode"`

**I07_Object_SearchFieldApiName**
- Field to search on when user types
- Default: `"Name"`
- Leave empty to search the Display Field
- Examples: `"LastName"`, `"Email"`, `"Phone"`

**I08_Object_ValueFieldName**
- Field to use as the selected value (usually Id)
- Default: `"Id"`
- Can be any field: `"Id"`, `"Email"`, `"ProductCode"`

---

### **Query Configuration Section** (I09-I13)

**I09_Query_MaxResults**
- Maximum number of records to return
- Default: `200`
- Range: 1-2000

**I10_Query_WhereClause**
- Additional filter conditions (without the "WHERE" keyword)
- Examples:
  - `"Type = 'Customer'"`
  - `"IsActive = true AND Rating = 'Hot'"`
  - `"CreatedDate = LAST_N_DAYS:30"`

**I11_Query_SortBy**
- Field to sort results by
- Leave empty to use Display Field
- Examples: `"Name"`, `"CreatedDate"`, `"LastModifiedDate"`

**I12_Query_SortDirection**
- Sort direction
- Options: `"asc"` or `"desc"`
- Default: `"asc"`

**I13_Query_ValueMatchType**
- How to match the initial value
- Options:
  - `"partial"` (default) — contains/includes the search text
  - `"exact"` — must match exactly

---

### **Parent Filter Section** (I14-I18)

Use these to create dependent lookups (e.g., filter Contacts by selected Account).

**I14_Parent_ParentInitialized**
- **Important:** Map this to the parent lookup's **O3_componentInitialized** output
- This tells the child lookup that the parent has finished loading
- Example: `{!ParentLookupComponent.componentInitialized}`
- Required for dependent lookups to work correctly
- Default: `False`

**I15_Parent_ParentFilterField**
- Field on the child object to filter by
- Examples: `"AccountId"`, `"Product__c"`, `"CustomLookup__c"`

**I16_Parent_ParentFilterValue**
- Value from parent to filter on
- Examples: `{!ParentLookupComponent.selectedValue}`

**I17_Parent_ParentFilterOperator**
- Comparison operator
- Options: `"="`, `"!="`, `"IN"`, `"LIKE"`
- Default: `"="`
- For `IN`, use comma-separated values in Parent Filter Value

**I18_Parent_DisableOnNoParentValue**
- Disable this lookup when parent value is empty
- Recommended: `True` for dependent lookups
- Default: `False`

---

### **Behavior Section** (I19-I26)

**I19_Behavior_Required**
- Make this field required for Flow progression
- Default: `False`

**I20_Behavior_Disabled**
- Disable the lookup field with disabled appearance
- Value still passes through and initial value will be set
- Default: `False`

**I21_Behavior_ReadOnly**
- Make lookup read-only with clean appearance (no border, no user interaction)
- Value still passes through and initial value will be set
- Useful for displaying pre-selected values without allowing changes
- Default: `False`

**I22_Behavior_AllowDisplayFieldMatch**
- Allows matching initial/selected values and Tab-populated values against the display field (not just value field)
- **When to use:** Enable when pre-populating with display values (e.g., names) instead of Ids, or when using **I24_Behavior_PopulateOnTab**
- **Example:** If display field is "Name" and you set initial value to "John Doe", the component will find matching records by name
- Works with **I29_Value_InitialValue**, **I30_Value_SelectedValue**, and **I24_Behavior_PopulateOnTab**
- Default: `False`

**I23_Behavior_RelativeDropdown**
- Changes dropdown positioning to use the Flow screen space instead of overflowing the component container
- **When to use:** Enable if the dropdown is cut off or hidden by the Flow container boundaries
- **Mobile:** Automatically enabled on mobile devices
- **Desktop:** Useful for long result lists that get clipped by Flow's container
- Default: `False` (desktop), automatically `True` (mobile)

**I24_Behavior_PopulateOnTab**
- When user presses Tab, automatically select the first matching result
- Great for keyboard-heavy data entry
- Default: `False`

**I25_Display_ShowObjectMeta**
- Show the object name as meta text beneath each result in the dropdown
- Helps users identify the object type when searching multiple objects
- Default: `True`

**I26_Display_CustomMeta**
- Custom meta text to show beneath each result in the dropdown
- Overrides the object name when **I25_Display_ShowObjectMeta** is true
- Example: Use a formula to show custom information like "Contact - [Account Name]"
- Default: Empty

---

### **Barcode Scanning Section** (I27-I28)

**I27_Scan_AllowBarcodeScanning**
- Enable barcode scanning button (mobile only)
- Default: `False`

**I28_Scan_ScanButtonIcon**
- Icon for the scan button
- Default: `"utility:scan"`
- Examples: `"utility:scan"`, `"utility:photo"`

---

### **Initial Value / Output Section** (I29-I30)

**I29_Value_InitialValue**
- Pre-populate with a specific value on component load
- Example: `{!RecordId}` to auto-select a record

**I30_Value_SelectedValue / O1_selectedValue** *(Input/Output)*
- **As Input:** Pre-populate the selection
- **As Output:** The value of the selected record
- **Critical for Flows:** Map this field to ITSELF (`{!ComponentName.selectedValue}`) to preserve the selection when validation errors occur
- **Why:** Without this mapping, the lookup will clear when the user corrects validation errors and returns to the screen
- **Example mapping:** Set I30_Value_SelectedValue = `{!ContactLookup.selectedValue}` (where ContactLookup is your component API name)

---

### **Output-Only Properties** (O1-O5)

These are automatically set by the component — you can use them in Flow decisions and formulas.

**O1_selectedValue** (also shown as I30_Value_SelectedValue)
- The value of the selected record based on **I08_Object_ValueFieldName** (typically the Id, but can be any field)
- Access via: `{!ComponentName.selectedValue}`
- **Important:** Also serves as an input — map to itself to preserve selection on validation errors

**O2_recordId**
- The Id of the selected record
- Access via: `{!ComponentName.recordId}`

**O3_componentInitialized**
- `True` when component has finished loading
- Use in decisions to prevent progression before component is ready
- Access via: `{!ComponentName.componentInitialized}`

**O4_Record Selected**
- `True` when a record has been selected
- Use in decisions to conditionally show content based on selection
- Access via: `{!ComponentName.recordSelected}`

**O5_Record Not Selected**
- `True` when no record has been selected
- Use in decisions to conditionally show instructions or warnings
- Access via: `{!ComponentName.recordSelectedNegative}`

---

## Common Flow Examples

### Example 1: Simple Contact Lookup

```
I05_Object_ObjectApiName: "Contact"
I01_Display_Label: "Select Contact"
I06_Object_DisplayFieldName: "Name"
I07_Object_SearchFieldApiName: "LastName"
I19_Behavior_Required: True
```

### Example 2: Dependent Lookup (Account → Contacts)

**First Screen: Account Lookup**
```
I05_Object_ObjectApiName: "Account"
I01_Display_Label: "Select Account"
Store O2_recordId in: {!SelectedAccountId}
```

**Second Screen: Contact Lookup (filtered by Account)**
```
I05_Object_ObjectApiName: "Contact"
I01_Display_Label: "Select Contact"
I14_Parent_ParentInitialized: {!AccountLookup.componentInitialized}
I15_Parent_ParentFilterField: "AccountId"
I16_Parent_ParentFilterValue: {!AccountLookup.selectedValue}
I18_Parent_DisableOnNoParentValue: True
I30_Value_SelectedValue: {!ContactLookup.selectedValue}
```

### Example 3: Product Search with Filters

```
I05_Object_ObjectApiName: "Product2"
I01_Display_Label: "Search Products"
I06_Object_DisplayFieldName: "Name"
I07_Object_SearchFieldApiName: "ProductCode"
I10_Query_WhereClause: "IsActive = true AND Family = 'Hardware'"
I11_Query_SortBy: "Name"
I09_Query_MaxResults: 50
```

### Example 4: Barcode Scanning (Mobile)

```
I05_Object_ObjectApiName: "Asset"
I01_Display_Label: "Scan Asset"
I06_Object_DisplayFieldName: "Name"
I07_Object_SearchFieldApiName: "SerialNumber"
I27_Scan_AllowBarcodeScanning: True
```

---

## Best Practices

✅ **Do:**
- Use **I19_Behavior_Required** for mandatory selections
- Set **I18_Parent_DisableOnNoParentValue** = True for dependent lookups
- Use **I10_Query_WhereClause** to filter results for better performance
- Enable **I24_Behavior_PopulateOnTab** for data entry efficiency
- Store **O2_recordId** or **I30_Value_SelectedValue** in Flow variables

❌ **Don't:**
- Return more than 200 records without good reason (performance)
- Forget to set **I05_Object_ObjectApiName** (required!)
- Use complex SOQL in **I10_Query_WhereClause** without testing

---

## Troubleshooting

**Problem:** No results appear
- Verify **I05_Object_ObjectApiName** is correct
- Check user has Read permission on the object and fields
- Review **I10_Query_WhereClause** syntax (no "WHERE" keyword needed)

**Problem:** Parent filter not working
- Ensure **I15_Parent_ParentFilterField** matches the exact API name (e.g., `AccountId`)
- Verify **I16_Parent_ParentFilterValue** contains a valid value
- Check if **I18_Parent_DisableOnNoParentValue** is preventing input

**Problem:** Component won't validate
- Check **O3_componentInitialized** is True before allowing progression
- Ensure **I19_Behavior_Required** is set correctly
- Verify selected value exists

**Problem:** Search is too slow
- Reduce **I09_Query_MaxResults**
- Add filters via **I10_Query_WhereClause**
- Index the **I07_Object_SearchFieldApiName** field (Admin task)

---

## Advanced Tips

### Debugging
- Press **Ctrl+Shift+L** in the browser console to toggle debug logging (developer feature)
- Press **Ctrl+D** while focused in the lookup input field to show debug logs directly on the Flow screen (no browser console needed)

### Remembering Selection After Validation Errors
**Recommended Method (Easiest):**
Map **I30_Value_SelectedValue** to itself:
- Set **I30_Value_SelectedValue** = `{!ComponentName.selectedValue}`
- This automatically preserves the selection when users fix validation errors

**Alternative Method (Using Variables):**
Store the selection in a Flow variable:
1. Create a Text variable: `varSelectedContactId`
2. Set **I29_Value_InitialValue** = `{!varSelectedContactId}`
3. After selection, assign **O2_recordId** → `{!varSelectedContactId}`

### Using Selected Record Data
Access the record return via the component's outputs:
- `{!ComponentName.recordId}` — The record Id
- `{!ComponentName.selectedValue}` — The value field (usually Id)

---

## Technical Details (for Admins/Developers)

- **Component Name:** `alto_dynamicLookup`
- **Apex Class:** `DynamicLookupQueryBuilder`
- **Test Class:** `DynamicLookupQueryBuilderTest`
- **Custom Labels:** All UI text uses Custom Labels for translation support
- **Deployment:** Deploy via Salesforce CLI, change sets, or packages
- **Caching:** Object details are cached (`@AuraEnabled(cacheable=true)`)

### Translation Support

The component uses **Custom Labels** for all user-facing text, enabling multi-language support:

**Available Custom Labels:**
- `alto_DynLookup_ApplyingParent` - "Applying parent values..."
- `alto_DynLookup_BarcodeUnavailable` - "BarcodeScanner unavailable. Non-mobile device?"
- `alto_DynLookup_Error` - "Error"
- `alto_DynLookup_ErrorRecords` - "Error fetching records"
- `alto_DynLookup_ErrorSObject` - "Error fetching SObject details"
- `alto_DynLookup_ErrorScanning` - "Error during scanning"
- `alto_DynLookup_FieldRequired` - "Field is required."
- `alto_DynLookup_FindingMatch` - "Finding match..."
- `alto_DynLookup_GettingContext` - "Getting context..."
- `alto_DynLookup_LookupNotReady` - "Lookup was not ready before proceeding."
- `alto_DynLookup_NoRecordsFound` - "No Records Found"
- `alto_DynLookup_Preparing` - "Preparing lookup..."
- `alto_DynLookup_ProcessingBarcode` - "Processing scanned barcode..."
- `alto_DynLookup_RemoveOption` - "Remove selected option"
- `alto_DynLookup_RetrievingRecords` - "Retrieving records..."
- `alto_DynLookup_ScanError` - "Scan error"
- `alto_DynLookup_ScanReceived` - "Scan event received"
- `alto_DynLookup_Search` - "Search"
- `alto_DynLookup_Success` - "Success"
- `alto_DynLookup_UserDismissed` - "User terminated scanning session."
- `alto_DynLookup_WaitingParent` - "Waiting for parent..."

**To Add Translations:**
1. Navigate to **Setup** → **Custom Labels**
2. Find labels starting with `alto_DynLookup_`
3. Click **Edit** on each label and add translations for your desired languages
4. Save and test in a Flow with the desired user language enabled

---
- **Security:** Respects user permissions and field-level security