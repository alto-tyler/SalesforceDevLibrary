# Alto Datatable

A powerful Flow screen component for displaying, selecting, filtering, searching, and inline editing Salesforce records in a customizable datatable format.

## 📌 Based on Eric Smith's Datatable Component

This component is based on the exceptional [Datatable Lightning Web Component](https://unofficialsf.com/datatable-lightning-web-component-for-flow-screens-2/) created by Eric Smith. We've enhanced it with **reactivity improvements** to better support dynamic Flow scenarios.

### ⚡ Reactivity Enhancements

The following input properties trigger the `connectedCallback` to re-render the datatable when changed:

- **Column Cell Attributes** - Updates cell styling and icons dynamically
- **Column Edits** - Changes which columns are editable
- **Column Labels** - Updates column header text
- **Column Other Attributes** - Applies custom column properties

This reactivity allows you to dynamically update datatable configuration based on Flow logic, user selections, or data changes without requiring screen navigation.

**Example Use Case:** Change column labels based on selected record type, or enable/disable editing based on user permissions.

---

## Features

### Display & Selection
- Display records from any Salesforce or Apex-Defined object
- Multi-select (checkboxes) or single-select (radio buttons) rows
- Pre-select rows on load
- Hide selection column entirely
- Show row numbers

### Filtering & Search
- Column-level filters (including blank value filtering)
- Global search bar across all columns
- Case-sensitive or case-insensitive filtering
- Clear all filters button

### Inline Editing
- Edit fields directly in the datatable
- Supported field types: Text, Number, Date, DateTime, Currency, Percent, Boolean, Picklist, Email, Phone, URL
- Restrict picklist values by Record Type
- Auto-save on tab or manual save with Cancel/Save buttons
- Optional auto-navigation to next Flow element on save

### Formatting & Customization
- Configure 15+ column attributes per field (alignment, width, icon, label, etc.)
- Column wrapping and clipping
- Flexible width columns that auto-adjust
- Custom cell attributes (styling, icons from field values)
- Custom type attributes (date/time formatting, decimal places)
- Rich text field support
- Clickable links for Name and Lookup fields

### Advanced Capabilities
- Pagination with configurable records per page
- Row actions (Remove Row or custom Standard actions)
- Table height and border customization
- Header with icon, label, and record counts
- Maximum row limits
- Required field validation
- Multi-currency support with conversion
- Export edited, selected, removed, and remaining rows

---

## Input Properties

### Data Source

| Property | Type | Label | Required | Description |
|----------|------|-------|----------|-------------|
| **Datatable Object API Name** | SObject Type | `Datatable Object API Name` | ✅ Yes | Select the API Name of the SObject (e.g., `Account`, `Contact`) |
| **Datatable Record Collection** | SObject[] | `_ Datatable Record Collection` | ✅ Yes | Record Collection variable containing records to display |
| **Pre-Selected Rows** | SObject[] | `Pre-Selected Rows` | No | Record Collection of rows to show as pre-selected |
| **Column Fields** | String | `_ Column Fields` | ✅ Yes | Comma-separated list of field API Names (e.g., `Name,Phone,BillingCity,Type`) |

### Table Formatting

| Property | Type | Label | Default | Description |
|----------|------|-------|---------|-------------|
| **Display Table Header?** | Boolean | `Display Table Header?` | false | Show header above datatable |
| **Table Icon** | String | `Table Icon` | — | Icon for header (e.g., `standard:account`) |
| **Table Label** | String | `Table Label` | — | Label for header (reactive to Flow changes) |
| **Show Record Count in Header** | Boolean | `Show Record Count in Header` | false | Display total record count in header |
| **Show Selected Count in Header** | Boolean | `Show Selected Count in Header` | false | Display selected record count in header |
| **Show Row Numbers** | Boolean | `Show Row Numbers` | false | Display row number column (always shown when editing is enabled) |
| **Table Height** | String | `Table Height` | — | CSS height (e.g., `30rem`, `calc(50vh - 100px)`) - leave blank to auto-expand |
| **Table Border** | Boolean | `Table Border` | false | Display border around datatable |
| **Maximum Number of Records to Display** | Integer | `Maximum Number of Records to Display` | — | Limit displayed records (max 2000) |

### Pagination

| Property | Type | Label | Default | Description |
|----------|------|-------|---------|-------------|
| **Show Pagination** | Boolean | `Show Pagination` | false | Enable pagination with fixed records per page |
| **Records Per Page** | Integer | `Records Per Page` | 10 | Default number of records per page |
| **Show First/Last Buttons** | Boolean | `Show First/Last Buttons` | false | Show First/Last navigation buttons in footer |

### Search

| Property | Type | Label | Default | Description |
|----------|------|-------|---------|-------------|
| **Show Search bar** | Boolean | `Show Search bar` | false | Enable global search across all columns (requires header) |
| **External Search Value** | String | `External Search Value` | — | Programmatically set the global search text. When this value changes, the table applies filtering across all visible columns reactively. Works with or without the visible Search bar. |

#### External Search Value (Programmatic Search)
- Bind a Flow text variable to `External Search Value` to drive global filtering from other screen inputs (e.g., Text, Picklist, or formula-driven values).
- Updates filtering as the bound variable changes (assignments or user input), without requiring screen navigation.
- Respects case matching behavior configured elsewhere (e.g., column filter case sensitivity).
- Useful for centralized search UX where the search input is outside the datatable header, or when the header is hidden.

### Configure Columns

Use the **Configure Columns** button to launch a wizard that helps you:
- Select and order fields
- Set column alignments (Left, Center, Right)
- Enable editing per column or all columns
- Enable filtering per column or all columns
- Add icons to column headers
- Change column labels
- Set column widths (drag to resize, snap to 5px boundaries)
- Enable flexible widths (columns auto-adjust to fill space)
- Enable text wrapping or clipping per column
- Configure special attributes (Cell, Type, Other)
- Save/load column configurations

**Advanced Column Attributes:**

| Property | Type | Label | Description |
|----------|------|-------|-------------|
| **Column Alignments** | String | `- Column Alignments` | Comma-separated ColID:alignment (e.g., `Name:center, 2:right`) |
| **Column Edits** | String | `- Column Edits` | `All` or ColID:true/false (e.g., `1:true, Phone:true`) |
| **Column Filters** | String | `- Column Filters` | `All` or ColID:true/false |
| **Column Icons** | String | `- Column Icons` | ColID:icon (e.g., `1:standard:account, Name:utility:user`) |
| **Column Labels** | String | `- Column Labels` | ColID:label (e.g., `1:Account Name, BillingCity:City`) |
| **Column Widths** | String | `- Column Widths` | ColID:width in pixels (e.g., `Name:300, 2:150`) |
| **Column Wraps** | String | `- Column Wraps` | ColID:true/false (default: false, except Name field wraps) |
| **Column Flexes** | String | `- Column Flexes` | ColID:true/false (flexible width columns) |
| **Column Scales** | String | `- Column Scale Values` | ColID:scale (decimal places for numbers, currency, percent) |
| **Column Types** | String | `- Column Field Types` | ColID:type (for Apex-Defined objects: text, number, date, etc.) |
| **Special: Column CellAttributes** | String | `. Special: Column CellAttributes` | ColID:{attribute:value} (use `;` separator) |
| **Special: Column TypeAttributes** | String | `. Special: Column TypeAttributes` | ColID:{attribute:value} (use `;` separator) |
| **Special: Column Other Attributes** | String | `. Special: Column Other Attributes` | ColID:{attribute:value} (use `;` separator) |

**Example Cell Attribute:**
```
FancyField__c:{class: slds-theme_shade slds-theme_alert-texture, iconName: {fieldName: IconValue__c}, iconPosition: left}
```

**Example Type Attribute (Date Formatting):**
```
DateField__c:{year:'numeric', day:'2-digit', month:'long'}
```

### Table Behavior

| Property | Type | Label | Default | Description |
|----------|------|-------|---------|-------------|
| **Hide Checkbox Column?** | Boolean | `Hide Checkbox Column?` | false | Hide row selection column (always shown when editing is enabled) |
| **Single Row Selection (Radio Buttons)?** | Boolean | `Single Row Selection (Radio Buttons)?` | false | Use radio buttons for single selection instead of checkboxes |
| **Hide Clear Selection Button?** | Boolean | `Hide Clear Selection Button?` | false | Hide the Clear Selection button (for single-row tables) |
| **Required?** | Boolean | `Required?` | false | Require at least 1 row to be selected for Flow progression |
| **Hide Column Header Actions?** | Boolean | `Hide Column Header Actions?` | false | Hide sort, clip/wrap text, and filter actions in column headers |
| **Match Case on Column Filters?** | Boolean | `Match Case on Column Filters?` | false | Force exact case matching on column filters |
| **Show Link on the Object's 'Name' Field** | Boolean | `Show Link on the Object's 'Name' Field` | false | Display Name field as clickable link to record |
| **Open Links in Same Tab** | Boolean | `Open Links in Same Tab` | false | Open record links in same tab instead of new tab |
| **Suppress Cancel/Save Buttons during Edit Mode?** | Boolean | `Suppress Cancel/Save Buttons during Edit Mode?` | false | Auto-save on tab-out instead of showing Cancel/Save buttons |
| **Navigate to Next Flow Element on Save?** | Boolean | `Navigate to Next Flow Element on Save?` | false | Auto-advance Flow after clicking Save (removes need for Next button) |

### Row Actions

| Property | Type | Label | Default | Description |
|----------|------|-------|---------|-------------|
| **Add a Remove Row Action Button** | Boolean | `Add a Remove Row Action Button` | false | Add Remove Row action button to each row |
| **Remove Row Action Label** | String | `Remove Row Action Label` | "Remove Row" | Hover text for Remove Row button |
| **Remove Row Action Icon** | String | `Remove Row Action Icon` | "utility:close" | Icon for Remove Row button |
| **Remove Row Action Icon Color** | String | `Remove Row Action Icon Color` | "Red" | Icon color: Red, Green, or Black |
| **Maximum # of rows that can be removed** | Integer | `Maximum # of rows that can be removed` | 0 | Max removable rows (0 = no limit) |
| **Row Action Column Location** | String | `Row Action Column Location` | "Right" | Row action column position: Left or Right |

### Advanced

| Property | Type | Label | Default | Description |
|----------|------|-------|---------|-------------|
| **Key Field** | String | `Key Field` | "Id" | Unique identifier field (normally `Id`) |
| **Record Type Id for Picklist Values** | String | `Record Type Id for Picklist Values` | — | Restrict picklist edit values to specific Record Type |
| **Allow a --None-- Picklist Option** | Boolean | `Allow a --None-- Picklist Option` | true | Include `--None--` option when editing picklists |
| **Allow table to overflow its container** | Boolean | `Allow table to overflow its container` | false | Allow table to overflow (helpful for picklist editing on small tables) |
| **Suppress Currency Conversion** | Boolean | `Suppress Currency Conversion` | false | Disable automatic currency conversion in multi-currency orgs |
| **Case Insensitive Sort** | Boolean | `Case Insensitive Sort` | false | Sort columns case-insensitively (AbCdE vs ACEbd) |
| **(User Defined) Display User Defined Object?** | Boolean | `_ (User Defined) Display User Defined Object?` | false | Set to true for Apex-Defined objects instead of Salesforce SObjects |
| **Datatable Record String (User Defined)** | String | `_ Datatable Record String (User Defined)` | — | Serialized string for Apex-Defined objects |
| **(User Defined) Display Serialized Record?** | String | `_ (User Defined) Display Serialized Record?` | — | Serialized record data (triggers reactivity) |

---

## Output Properties

### Selected Rows

| Property | Type | Label | Description |
|----------|------|-------|-------------|
| **Output Selected Rows (Collection)** | SObject[] | `Output Selected Rows (Collection)` | Collection of selected records (may not include edited values) |
| **Output Selected Row (Object)** | SObject | `Output Selected Row (Object)` | Single selected record (only when one row is selected) |
| **Selected Row Key Field Value** | String | `Selected Row Key Field Value` | Value of Key Field for selected row (supports reactive screens) |
| **Output Number of Selected Records** | Integer | `Output Number of Selected Records` | Count of selected records |

### Edited Rows

| Property | Type | Label | Description |
|----------|------|-------|-------------|
| **Output Edited Rows** | SObject[] | `Output Edited Rows` | Collection of only edited records (use Update Records to save) |
| **Output Edited (Serialized) Rows** | String | `Output Edited (Serialized) Rows` | Serialized string of edited records |
| **Output Number of Edited Records** | Integer | `Output Number of Edited Records` | Count of edited records |

### All Rows

| Property | Type | Label | Description |
|----------|------|-------|-------------|
| **Output All Rows** | SObject[] | `Output All Rows` | All currently displayed records (includes edited values) |
| **Output Number of All Records** | Integer | `Output Number of All Records` | Count of all records |

### Removed Rows

| Property | Type | Label | Description |
|----------|------|-------|-------------|
| **Output Removed Rows (Collection)** | SObject[] | `Output Removed Rows (Collection)` | Collection of removed records (includes edited values) |
| **Output Remaining Rows (Collection)** | SObject[] | `Output Remaining Rows (Collection)` | All original records not removed (includes edited values) |
| **Output Number of Removed Records** | Integer | `Output Number of Removed Records` | Count of removed records |

### Row Actions

| Property | Type | Label | Description |
|----------|------|-------|-------------|
| **Output Actioned Row (Object)** | SObject | `Output Actioned Row (Object)` | Record processed by most recent row action |

### Sorting

| Property | Type | Label | Description |
|----------|------|-------|-------------|
| **sortedBy** | String | `sortedBy` | Current sort column field name |
| **sortDirection** | String | `sortDirection` | Current sort direction (asc/desc) |

### User Defined Object Outputs

When **Display User Defined Object?** is enabled:

| Property | Type | Label |
|----------|------|-------|
| **Output Selected Rows (User Defined)** | String | `Output Selected Rows (User Defined)` |
| **Output Edited Rows (User Defined)** | String | `Output Edited Rows (User Defined)` |
| **Output Removed Rows (User Defined)** | String | `Output Removed Rows (User Defined)` |
| **Output Remaining Rows (User Defined)** | String | `Output Remaining Rows (User Defined)` |
| **Output Actioned Row (User Defined)** | String | `Output Actioned Row (User Defined)` |

---

## Flow Examples

### Example 1: Display and Select Accounts

**Scenario:** Show a list of Accounts, allow user to select multiple, then update a field on selected records.

**Setup:**

1. **Get Records** - Get Accounts
   - Object: `Account`
   - Conditions: Add any filters you need
   - How Many: All records
   - Store in: `AccountCollection` (Record Collection)

2. **Screen** - Display Accounts
   - Add **Alto Datatable** component
   - **Datatable Object API Name**: `Account`
   - **Datatable Record Collection**: `{!AccountCollection}`
   - **Column Fields**: `Name,Phone,BillingCity,Type,AnnualRevenue`
   - **Display Table Header?**: `{!$GlobalConstant.True}`
   - **Table Icon**: `standard:account`
   - **Table Label**: `Select Accounts to Update`
   - **Show Record Count in Header**: `{!$GlobalConstant.True}`
   - Store outputs:
     - `{!SelectedAccounts}` = `Output Selected Rows (Collection)`

3. **Update Records** - Update Selected Accounts
   - How to Find Records: `Use the IDs and records from the IDs stored in a record variable or record collection variable`
   - Record Collection: `{!SelectedAccounts}`
   - Set Field Values: Update fields as needed

---

### Example 2: Inline Edit Contact Records

**Scenario:** Display Contacts for an Account, allow inline editing, then save changes.

**Setup:**

1. **Get Records** - Get Contacts
   - Object: `Contact`
   - Conditions: `AccountId` Equals `{!recordId}`
   - Store in: `ContactCollection`

2. **Screen** - Edit Contacts
   - Add **Alto Datatable** component
   - **Datatable Object API Name**: `Contact`
   - **Datatable Record Collection**: `{!ContactCollection}`
   - **Column Fields**: `Name,Title,Email,Phone,MobilePhone`
   - Use **Configure Columns** button to set:
     - Column Edits: `Title:true, Email:true, Phone:true, MobilePhone:true`
   - **Display Table Header?**: `{!$GlobalConstant.True}`
   - **Table Label**: `Edit Contact Information`
   - **Navigate to Next Flow Element on Save?**: `{!$GlobalConstant.True}`
   - Store output:
     - `{!EditedContacts}` = `Output Edited Rows`

3. **Update Records** - Save Edited Contacts
   - How to Find Records: `Use the IDs and records from a record collection`
   - Record Collection: `{!EditedContacts}`

**Result:** Users edit fields directly in the table, click Save, and Flow auto-advances to update the records.

---

### Example 3: Paginated Table with Filtering

**Scenario:** Display large dataset with pagination and column filtering.

**Setup:**

1. **Get Records** - Get Opportunities
   - Object: `Opportunity`
   - Conditions: `StageName` Not Equal `Closed Won`
   - Store in: `OpenOpportunities`

2. **Screen** - Review Open Opportunities
   - Add **Alto Datatable** component
   - **Datatable Object API Name**: `Opportunity`
   - **Datatable Record Collection**: `{!OpenOpportunities}`
   - **Column Fields**: `Name,AccountId,Amount,CloseDate,StageName,Probability`
   - **Display Table Header?**: `{!$GlobalConstant.True}`
   - **Table Label**: `Open Opportunities`
   - **Show Pagination**: `{!$GlobalConstant.True}`
   - **Records Per Page**: `25`
   - **Show First/Last Buttons**: `{!$GlobalConstant.True}`
   - Use **Configure Columns** to set:
     - Column Filters: `All`
   - Store output:
     - `{!SelectedOpps}` = `Output Selected Rows (Collection)`

**Result:** Users can page through records 25 at a time, filter by any column, and select records for processing.

---

### Example 4: Remove Rows Action

**Scenario:** Allow users to remove items from a displayed list before proceeding.

**Setup:**

1. **Get Records** - Get Products
   - Object: `Product2`
   - Conditions: Add filters
   - Store in: `ProductList`

2. **Screen** - Select Products to Keep
   - Add **Alto Datatable** component
   - **Datatable Object API Name**: `Product2`
   - **Datatable Record Collection**: `{!ProductList}`
   - **Column Fields**: `Name,ProductCode,IsActive,Family`
   - **Display Table Header?**: `{!$GlobalConstant.True}`
   - **Table Label**: `Remove Unwanted Products`
   - **Add a Remove Row Action Button**: `{!$GlobalConstant.True}`
   - **Remove Row Action Label**: `Remove`
   - **Remove Row Action Icon**: `utility:delete`
   - **Remove Row Action Icon Color**: `Red`
   - Store outputs:
     - `{!RemovedProducts}` = `Output Removed Rows (Collection)`
     - `{!RemainingProducts}` = `Output Remaining Rows (Collection)`

3. **Loop** - Process Remaining Products
   - Collection Variable: `{!RemainingProducts}`
   - Continue with your logic

**Result:** Users click Remove Row icon on unwanted products. Flow receives both removed and remaining collections.

---

### Example 5: Dynamic Column Configuration (Reactivity)

**Scenario:** Change column labels based on user selection using reactive properties.

**Setup:**

1. **Screen** - Select View Type
   - Add **Radio Buttons** component
     - Label: `Select View`
     - Data Type: `Text`
     - Choices: `Standard View`, `Detailed View`
     - Store in: `selectedView`

2. **Assignment** - Build Column Labels
   - If `{!selectedView}` Equals `Standard View`:
     - Set `columnLabels` = `Name:Account, Phone:Phone, BillingCity:City`
   - If `{!selectedView}` Equals `Detailed View`:
     - Set `columnLabels` = `Name:Account Name (Full), Phone:Primary Phone Number, BillingCity:Billing City Location`

3. **Alto Datatable** (on same screen)
   - **Datatable Object API Name**: `Account`
   - **Datatable Record Collection**: `{!AccountCollection}`
   - **Column Fields**: `Name,Phone,BillingCity`
   - **Column Labels**: `{!columnLabels}` ← **Reactive property!**
   - **Display Table Header?**: `{!$GlobalConstant.True}`

**Result:** When user changes radio button selection, the Column Labels property updates and triggers `connectedCallback`, redrawing the table with new column headers.

---

### Example 6: External Search from Another Input

**Scenario:** Provide a separate search input and use it to filter the datatable globally.

**Setup:**

1. **Screen** - Add a **Text** input
   - Label: `Search`
   - Store in: `searchText`

2. **Alto Datatable** (on same screen)
   - **Datatable Object API Name**: `Account`
   - **Datatable Record Collection**: `{!AccountCollection}`
   - **Column Fields**: `Name,Phone,BillingCity,Type`
   - **External Search Value**: `{!searchText}` ← Filters reactively as the user types or changes the value
   - Optional: Leave **Show Search bar** off to centralize search outside the table

**Result:** The datatable applies global filtering based on `searchText` without requiring the built-in search bar.

## Reactivity Details

### Properties That Trigger Re-Rendering

The following input properties call `connectedCallback()` when their values change, causing the datatable to re-render:

1. **Column Cell Attributes** - Updates cell styling, icons, and CSS classes
2. **Column Edits** - Changes which columns allow editing
3. **Column Labels** - Updates column header text
4. **Column Other Attributes** - Applies custom column properties like text wrapping

### How to Use Reactivity

**Pattern:** Use Assignment elements or formulas to build property values based on user input or Flow variables, then map those variables to reactive properties.

**Example:**
```
1. User selects Record Type → Formula builds columnEdits string based on permissions
2. Map formula result to "Column Edits" property
3. Datatable re-renders with correct editable columns
```

**Benefits:**
- No need to navigate away from screen and back
- Instant visual feedback to user
- Simplifies Flow design (fewer screens needed)

---

## Troubleshooting

### Table doesn't display / shows empty
- Verify **Datatable Record Collection** variable contains records
- Check **Column Fields** uses correct field API names
- Ensure user has read access to object and fields
- Maximum 2000 records can be displayed (reduce with Get Records filters)

### "Apex CPU time limit exceeded" error
- Input collection has >2000 records - add filters to Get Records
- Reduce number of columns in **Column Fields**
- Remove unnecessary Type Attributes processing

### Edited values not saving
- **Output Edited Rows** must be passed to **Update Records** element
- Check user has edit access to fields
- Formula and Rollup fields cannot be edited
- Use **Output Number of Edited Records** to verify edits exist before updating

### Selected rows don't include edited values
- **Output Selected Rows** shows original values
- Use **Output All Rows** to get all records with edited values included
- Or use both **Output Selected Rows** and **Output Edited Rows** together

### Column filters not working
- Ensure **Column Filters** is set to `All` or includes specific column
- Some data types cannot be filtered (location, encrypted)
- DateTime columns can only be filtered on date (enter as YYYY-MM-DD)
- Time columns cannot be filtered

### Links not displaying for Name or Lookup fields
- User must have **Edit** access to the object (not just Read)
- Field must be "reparentable" for lookups
- Check **Show Link on the Object's 'Name' Field** is enabled
- Consider using [Session-Based Permission Sets](https://help.salesforce.com/articleView?id=sf.perm_sets_session_activate_flow.htm) to temporarily grant Edit access

### Picklist editing not working
- Picklists are supported in inline editing
- User must have Read access to the object for Record Type filtering
- Check **Allow a --None-- Picklist Option** if you need to clear values
- Dependent picklists are not yet supported

### Percent field editing issues
- Enter the decimal value (0.25 for 25%)
- Editing reduces available decimal places by 2 from field definition

### Date fields showing wrong day
- Component adjusts dates by timezone offset to display correctly
- If using custom Type Attributes, dates convert to UTC (may shift day)

### Reactive properties not updating table
- Only these properties trigger re-render: Column Cell Attributes, Column Edits, Column Labels, Column Other Attributes
- Other properties require screen navigation to update
- Verify variable is actually changing value (use Debug mode)

---

## Restrictions & Limitations

### Data Limits
- Maximum 2000 records can be displayed
- Collections >2000 records can cause Apex CPU timeout errors
- Data payload limit ~4MB (avoid "Automatically store all fields" in Get Records)

### Unsupported Field Types for Editing
- Lookup fields
- Location/Geolocation fields
- Time fields
- Multi-select picklists
- Encrypted fields
- Rich text fields
- Long text area fields
- Formula fields
- Rollup summary fields

### Filtering Limitations
- Time columns cannot be filtered
- DateTime columns only filter on date portion
- Location and encrypted fields cannot be filtered

### Special Considerations
- **ContentVersion object**: Do NOT include `VersionData` field (file contents too large)
- **Geolocation fields**: May cause "Unable to read SObject" error - manually select fields instead of "Automatically store all fields"
- **Address fields**: May cause issues with compound fields - select fields individually
- **Non-custom integer fields**: May cause "Argument must be a big decimal" error on update
- **Debug Mode**: If enabled, Configuration Wizard cannot display sample records

### Pre-Selected Rows
- If pre-selected records aren't in input collection, they won't appear in **Output Selected Rows**
- **Output Number of Selected Records** will include pre-selected rows even if not in collection

---

## Best Practices

### 1. Use Configure Columns Wizard
- Saves time configuring column attributes
- Provides visual preview of table
- Can save/load configurations for reuse
- Click "Snap Column Widths to Nearest 5 pixels" for consistency

### 2. Limit Columns to Improve Performance
- Only include fields users need to see
- Fewer columns = faster rendering
- Use Max Records to limit dataset size

### 3. Use Output Number Counts
- Check **Output Number of Edited Records** before updating
- Check **Output Number of Selected Records** for conditional logic
- Counts can drive conditional visibility on same screen

### 4. Combine Selection and Editing Carefully
- **Output Selected Rows** doesn't include edited values
- Use **Output All Rows** or combine Selected + Edited outputs
- See [Eric's guide on using both Selected and Edited records](https://ericsplayground.wordpress.com/2020/07/02/how-to-use-both-the-selected-and-the-edited-records-in-a-datatable/)

### 5. Enable Auto-Navigate on Save
- When editing is the only user action needed
- Set **Navigate to Next Flow Element on Save?** to `true`
- Eliminates extra "Next" button click

### 6. Use Pagination for Large Datasets
- Improves performance with 100+ records
- Keeps interface clean and usable
- Combine with column filters for best UX

### 7. Provide Clear Table Headers
- Always use **Display Table Header?** for screen readers
- Set descriptive **Table Label**
- Use **Show Record Count** to show data scope

### 8. Test with User Permissions
- Verify users have required object/field access
- Test link display (requires Edit access)
- Test picklist editing (requires Read access for Record Type filtering)

---

## Dependencies

This component includes:

**Apex Classes:**
- `alto_DatatableController` - Main controller for data operations
- `alto_EncodeDecodeURL` - URL encoding/decoding utilities
- `alto_QueryNRecords` - Record querying utilities

**LWC Components:**
- `alto_datatable` - Main datatable component
- `alto_customLightningDatatable` - Extended datatable with custom types
- `alto_comboboxColumnType` - Combobox column for picklist editing
- `alto_datatableUtils` - Shared utility functions

**Static Resources:**
- `alto_customLightningDatatableStyles` - Custom CSS styling

All dependencies are included in the `force-app` folder.

---

## API Version

Built with **Salesforce API version 65.0**.

---

## Credits

This component is based on the outstanding work by **[Eric Smith](https://trailblazer.me/id/ericsmith)**. 

- Original component: [Datatable - Lightning Web Component for Flow Screens](https://unofficialsf.com/datatable-lightning-web-component-for-flow-screens-2/)
- Source code: [GitHub - LightningFlowComponents](https://github.com/alexed1/LightningFlowComponents/tree/master/flow_screen_components/datatable)

We've added reactivity enhancements to better support dynamic Flow scenarios. All core functionality and the majority of features are Eric's exceptional work.

---

## Additional Resources

### Tutorials & Guides
- [Enhance Your Flows with Data Tables - Part 1-4](https://ericsplayground.wordpress.com/2019/03/11/enhance-your-flows-with-data-tables-part-1/) (Eric Smith's blog series)
- [How to use Apex-Defined Objects with the Datatable](https://ericsplayground.wordpress.com/how-to-use-an-apex-defined-object-with-my-datatable-flow-component/)
- [Display Rich Text and Custom Links in Datatables](https://unofficialsf.com/now-display-rich-text-and-custom-links-and-images-in-datatables/)
- [Datatable with Row Actions calling a pop-up Screen Flow](https://ericsplayground.wordpress.com/2025/01/09/datatable-with-row-actions-calling-a-pop-up-screen-flow/)

### Official Documentation
- [Salesforce Datatable Component Documentation](https://developer.salesforce.com/docs/component-library/bundle/lightning-datatable/documentation)
- [Formatted Date Time Documentation](https://developer.salesforce.com/docs/component-library/bundle/lightning-formatted-date-time/documentation)
- [Lightning Design System Icons](https://www.lightningdesignsystem.com/icons/)

---

## Support

For issues or questions:
- Review Eric Smith's [original documentation](https://unofficialsf.com/datatable-lightning-web-component-for-flow-screens-2/)
- Check the [UnofficialSF troubleshooting section](https://unofficialsf.com/datatable-lightning-web-component-for-flow-screens-2/#troubleshooting)
- Review Eric's [blog series on datatable usage](https://ericsplayground.wordpress.com/)
- Verify all dependencies are deployed correctly
