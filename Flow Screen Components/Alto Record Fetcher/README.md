# Alto Record Fetcher — Flow User Guide

A reactive record fetcher component that retrieves a single record with specified fields and returns it as an SObject. This component enables dynamic record fetching in Flow screens with support for relationship fields and reactive updates.

**Key Features:**
- Fetch any Salesforce record by ID
- Specify fields to retrieve (including relationship fields)
- Reactive screen support - updates automatically when record ID changes
- Returns properly structured SObject for use in Flow
- Handles null/empty record IDs gracefully
- No UI displayed (invisible component)
- Supports nested relationship fields (e.g., Account.Owner.Name)

---

## Use Cases

### Dynamic Record Loading
Load record details based on user selection or Flow variables without hardcoding Get Records elements.

### Relationship Field Access
Retrieve fields from related records (e.g., Contact.Account.Owner.Name) in a single component.

### Reactive Record Updates
When used with reactive screens, automatically fetch and display updated record data when the record ID changes.

### Conditional Record Display
Fetch records dynamically based on Flow logic and display fields in other screen components.

---

## Adding to Your Flow

1. In Flow Builder, drag a **Screen** element onto your canvas.
2. In the left panel under **Components**, search for **"alto_recordFetcher"** and drag it onto your screen.
3. Configure the properties (see sections below).
4. Reference the `Output Record` in other components on the same screen (reactive) or in later flow elements.

---

## Flow Properties

### **Input Properties**

**Object API Name**
- The API name of the Salesforce object to fetch
- Required
- Examples: 
  - `Contact`
  - `Account`
  - `rstk__poitem__c` (custom object)
- Type: String

**Record ID**
- The 15 or 18-character Salesforce ID of the record to fetch
- Required (can be null to return empty record structure)
- Examples:
  - `{!recordId}` (from Flow variable)
  - `{!Get_Selected_Contact.Id}` (from another Flow element)
  - `003xx000004TmiQAAS` (hardcoded ID)
- Type: String

**Field List (CSV)**
- Comma-separated list of field API names to retrieve
- Required
- Supports relationship fields using dot notation
- Examples:
  - `Name,Email,Phone`
  - `FirstName,LastName,Account.Name,Account.Owner.Name`
  - `Name,Status__c,Parent.Owner.Email`
- Type: String

---

### **Output Properties**

**Output Record**
- The fetched record as an SObject with all specified fields
- Type: SObject (matches the Object API Name)
- Structure matches the field list with proper relationship nesting
- Available for use immediately on same screen (reactive) or later screens

**Example Output Structure:**
If you fetch Contact with fields: `FirstName,LastName,Email,Account.Name,Account.Owner.Email`

The output record will have structure:
```
{
  Id: "003xx000004TmiQAAS",
  FirstName: "John",
  LastName: "Doe",
  Email: "john@example.com",
  Account: {
    Name: "Acme Corp",
    Owner: {
      Email: "owner@example.com"
    }
  }
}
```

---

## Example Flow Configurations

### Example 1: Display Contact Details Based on Selection

**Scenario:** User selects a Contact from a lookup, and you want to display their Account Name and Owner Email.

**Setup:**
1. Add a Dynamic Lookup component for Contact selection (output: `SelectedContactId`)
2. Add **alto_recordFetcher**:
   - **Object API Name:** `Contact`
   - **Record ID:** `{!SelectedContactId}`
   - **Field List:** `FirstName,LastName,Email,Account.Name,Account.Owner.Email`
3. Add Display Text components to show:
   - `{!recordFetcher.outputRecord.FirstName} {!recordFetcher.outputRecord.LastName}`
   - `{!recordFetcher.outputRecord.Account.Name}`
   - `{!recordFetcher.outputRecord.Account.Owner.Email}`

With reactive screens (API 59.0+), the display updates automatically when user selects a different contact.

---

### Example 2: Load Record in Repeater

**Scenario:** Display additional details for each item in a collection.

**Setup:**
1. Create a Loop through a collection of record IDs
2. Add a Screen inside the loop with **alto_recordFetcher**:
   - **Object API Name:** `Order`
   - **Record ID:** `{!CurrentItemId}`
   - **Field List:** `OrderNumber,Status,TotalAmount,Account.Name,Owner.Name`
3. Display the fetched fields using Display Text components

---

### Example 3: Fetch Custom Object with Relationship Fields

**Scenario:** Load a custom PO Item with Product and Warehouse details.

**Setup:**
1. Add **alto_recordFetcher**:
   - **Object API Name:** `rstk__poitem__c`
   - **Record ID:** `{!POItemId}`
   - **Field List:** `Name,rstk__qty__c,rstk__prod__r.Name,rstk__prod__r.rstk__prodcode__c,rstk__wh__r.Name`
2. Reference fields in Flow:
   - `{!recordFetcher.outputRecord.Name}`
   - `{!recordFetcher.outputRecord.rstk__qty__c}`
   - `{!recordFetcher.outputRecord.rstk__prod__r.Name}`
   - `{!recordFetcher.outputRecord.rstk__wh__r.Name}`

---

## Important Notes

### Null/Empty Record IDs
- If Record ID is null or empty, the component returns an empty record structure with all requested fields set to empty strings
- This prevents errors and provides a consistent output format

### Field API Names
- Use exact API names including `__c` for custom fields
- Use `__r` for custom relationship fields (e.g., `Account__r.Name`)
- Standard relationship fields don't need suffix (e.g., `Account.Name`)

### Relationship Fields
- Use dot notation for relationship fields: `Parent.Owner.Email`
- Component automatically handles nested relationships
- The output structure mirrors the dot notation in the field list

### Reactive Screens
- Requires **Flow API version 59.0 or higher**
- When Record ID changes, output automatically updates
- Other components on the same screen will reflect changes immediately

### Performance
- The component uses Lightning Data Service (LDS) for efficient record fetching
- LDS caches records to minimize server calls
- Only fetches specified fields (not all fields on the record)

---

## Troubleshooting

**Output Record is null or empty:**
- Verify Record ID is valid and not null
- Check that Object API Name matches the record's object type
- Ensure Field List contains valid field API names
- Check user has access to the record and fields

**Relationship fields not working:**
- Use correct relationship name (`Account.Name` not `AccountId.Name`)
- For custom lookups, use `__r` suffix (e.g., `Custom_Lookup__r.Name`)
- Verify the relationship field exists and is accessible

**Component not updating reactively:**
- Ensure Flow API version is 59.0 or higher
- Verify Record ID is properly mapped to a changing variable
- Check that other components reference the correct output path

**"Field does not exist" error:**
- Double-check field API names (case-sensitive)
- Ensure custom fields include `__c` suffix
- Verify fields are deployed and accessible

---

## Technical Details

- **Component Type:** Lightning Web Component (LWC)
- **API Name:** `alto_recordFetcher`
- **Namespace:** None (can be deployed to any org)
- **API Version:** 65.0
- **Dependencies:** 
  - `lightning/uiRecordApi` (Lightning Data Service)
  - `lightning/flowSupport` (Flow integration)
- **Reactive:** Yes (requires Flow API 59.0+)

---

## Installation

Deploy this component to your Salesforce org using the Salesforce CLI:

```bash
sf project deploy start --source-dir "Flow Screen Components/Alto Record Fetcher/force-app"
```

Or use the manifest file:

```bash
sf project deploy start --manifest "Flow Screen Components/Alto Record Fetcher/manifest/package.xml"
```

---

## Support

For issues, questions, or feature requests, please refer to the main repository documentation or create an issue in the GitHub repository.

---

## Version History

- **v1.0** - Initial release with relationship field support and reactive updates
