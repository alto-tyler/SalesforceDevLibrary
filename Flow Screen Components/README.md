# Flow Screen Components

Salesforce Flow Screen Components are Lightning Web Components (LWC) that can be used in Screen Flows to provide rich user interfaces and interactions. These components enhance the Flow Builder experience with custom UI elements.

## Available Components

### Alto Clean Up On Exit
Automatically delete records when users exit a Flow screen

**Key Features:**
- Deletes specified records when screen is exited
- Supports multiple deletion modes (single record, collection, all)
- Invisible component (no UI)
- Configurable error handling
- Useful for cleaning up temporary records

**Use Cases:**
- Remove draft records if user abandons the Flow
- Clean up temporary data after processing
- Delete records created during multi-screen processes

[View Full Documentation](Alto%20Clean%20Up%20On%20Exit/)

---

### Alto Datatable
Display, select, filter, search, and inline edit records in a customizable datatable

**Key Features:**
- Display record collections with customizable columns
- Inline editing with validation
- Row selection (single or multi-select)
- Search and filter capabilities
- Pagination support
- Outputs all records (edited and unedited) - unlike the original which only outputs edited and selected rows
- Reactive screen support (outputs update other components automatically)
- Based on Eric Smith's component with enhancements

**Use Cases:**
- Display and edit multiple records on a screen
- Allow users to select records for processing
- Show related records with inline editing
- Create data review and approval interfaces

[View Full Documentation](Alto%20Datatable/)

---

### Alto Document Job Monitor
Monitor document generation jobs in real-time and display generated documents

**Key Features:**
- Real-time monitoring of document generation progress
- Display generated document links
- Auto-refresh status
- Configurable appearance
- **Requires DOX__Document_Job__c object from Rootforms**

**Use Cases:**
- Show users document generation progress

---

### Alto Flow Modal Width Override
Override the default modal width for Flow screens launched as Quick Actions (in modals), to support wide content such as datatables or large forms.

**Key Features:**
- Set a custom modal width (e.g., 900px, 80%)
- Works declaratively in Flow Builder
- Responsive and supports fixed or percentage widths
- Only affects the Flow screen where used

**Use Cases:**
- Make datatables or large forms easier to use
- Provide more space for custom UI in modal Flows

[View Full Documentation](Alto%20Flow%20Modal%20Width%20Override/)
- Provide immediate access to generated documents
- Create document generation workflows with user feedback

[View Full Documentation](Alto%20Document%20Job%20Monitor/)

---

### Alto Dynamic Lookup
Configurable lookup component with parent filtering, barcode scanning, and validation

**Key Features:**
- Search and select records dynamically
- Parent record filtering
- Barcode scanning support
- Required field validation
- Recent items display
- Configurable search fields

**Use Cases:**
- Dynamic record selection in Flows
- Parent-filtered lookups (e.g., "show only contacts for this account")
- Barcode-based record selection
- Custom record picker interfaces

[View Full Documentation](Alto%20Dynamic%20Lookup/)

---

### Alto Multi Dynamic Lookup
Multi-select lookup with pill display

**Key Features:**
- Multiple record selection
- Pill-based display of selected records
- Remove individual selections
- **Requires Alto Dynamic Lookup**
- Uses Dynamic Lookup component for search

**Use Cases:**
- Select multiple records in a Flow
- Build many-to-many relationships
- Create tag-like selection interfaces

[View Full Documentation](Alto%20Multi%20Dynamic%20Lookup/)

---

### Alto Flow Header
Header component with Rootstock company info and customizable action buttons

**Key Features:**
- Display company information (logo, name)
- Customizable action buttons
- JSON-based button configuration
- Integration with Rootstock ERP data
- **Requires Rootstock ERP**

**Use Cases:**
- Branded Flow headers with company info
- Quick access buttons in Flow screens
- Consistent UI across multiple Flows

[View Full Documentation](Alto%20Flow%20Header/)

---

### Alto Flow Footer
Footer component with customizable action buttons and alignment options

**Key Features:**
- Configurable action buttons
- Left, center, right alignment
- JSON-based button configuration
- Consistent with Flow Header styling

**Use Cases:**
- Navigation buttons in Flow screens
- Action buttons at bottom of screens
- Consistent footer UI across Flows

[View Full Documentation](Alto%20Flow%20Footer/)

---

### Alto Rollup Numbers
Perform rollup calculations (SUM, AVERAGE, MEDIAN, MIN, MAX, COUNT) on record collections without displaying UI

**Key Features:**
- Six rollup operations: SUM, AVERAGE, MEDIAN, MIN, MAX, COUNT
- Calculate on one or two fields simultaneously
- Invisible component (no UI)
- Reactive screen support (outputs update other components automatically)
- Integrates with Alto Datatable for live updates

**Use Cases:**
- Calculate totals on filtered record collections
- Show live calculations as users modify datatable rows
- Display statistics without server round-trips
- Create reactive dashboards in Flows

[View Full Documentation](Alto%20Rollup%20Numbers/)

---

### Alto Simple Calculator
Perform basic arithmetic operations on two numeric values in Flow Repeaters

**Key Features:**
- Four operations: Add, Subtract, Multiply, Divide
- Works inside Flow Repeaters with reactive screens
- Invisible component (no UI)
- Prevents division by zero errors
- Supports decimal numbers

**Use Cases:**
- Calculate values inside Flow Repeaters (where formulas can't be used)
- Multiply quantity by price for line item totals
- Calculate discounts or percentages
- Perform dynamic calculations on repeating data

[View Full Documentation](Alto%20Simple%20Calculator/)

---

### Alto Record Fetcher
Fetch a single record with specified fields and return it as an SObject

**Key Features:**
- Fetch any Salesforce record by ID dynamically
- Specify fields to retrieve via CSV list
- Supports relationship fields (e.g., Account.Owner.Name)
- Reactive screen support (updates when record ID changes)
- Invisible component (no UI)
- Handles null IDs gracefully

**Use Cases:**
- Load record details based on user selection
- Access relationship fields in Flow screens
- Dynamic record display with reactive updates
- Fetch records in repeaters or loops

[View Full Documentation](Alto%20Record%20Fetcher/)

---

### Alto Repeater Set Columns
Create responsive multi-column layouts for Flow Repeaters

**Key Features:**
- Configure column counts for 4 screen sizes (XL, Large, Medium, Small)
- Responsive design with automatic breakpoint adaptation
- Supports 1-12 columns per breakpoint
- Invisible component (no UI)
- Works with any repeater content

**Use Cases:**
- Display products in responsive grid layouts
- Create multi-column form fields in repeaters
- Build dashboard card layouts
- Show line items in table-like column format

[View Full Documentation](Alto%20Repeater%20Set%20Columns/)

---

## Reactive Screen Support

**⚠️ Important:** Most of these components leverage reactive screen functionality, which requires **Flow API version 59.0 or higher**. Reactive screens allow components to automatically update other components on the same screen when their output values change, without requiring navigation to another screen.

**Components with Reactive Support:**
- Alto Datatable (outputs `outputAllRows` reactively)
- Alto Rollup Numbers (outputs update when input collection changes)
- Alto Simple Calculator (outputs update when input values change)
- Alto Record Fetcher (outputs update when record ID changes)

**To use reactive features:**
1. Ensure your Flow's API version is set to 59.0 or higher
2. Place reactive components on the same screen as components that consume their outputs
3. Outputs will automatically update dependent components in real-time

## How to Use Screen Components

1. Open **Flow Builder** (Setup > Flows > New Flow or edit existing)
2. Add a **Screen** element to your Flow
3. In the component sidebar, search for the component name:
   - "Cleanup On Exit"
   - "Alto Datatable"
   - "Alto Document Job Monitor"
   - "Alto Dynamic Lookup"
   - "Alto Multi Dynamic Lookup"
   - "Alto Header"
   - "Alto Flow Footer"
   - "Alto Rollup Record Numbers"
   - "alto_simpleCalculator"
   - "alto_recordFetcher"
   - "Alto Repeater Set Columns"
4. Drag the component onto your screen
5. Configure properties as documented in each component's README

## Deployment

Each component includes:
- `README.md` - Comprehensive documentation with examples
- `force-app/` - LWC bundle and optional Apex classes
- `manifest/package.xml` - Deployment manifest

See the [main repository README](../) for detailed deployment instructions.

## Component Dependencies

### Components Requiring External Packages

- **Alto Document Job Monitor** - Requires Rootforms
- **Alto Flow Header** - Requires Rootstock ERP
- **Alto Multi Dynamic Lookup** - Requires Alto Dynamic Lookup

### All Other Components
Standard Salesforce orgs - no additional packages required.

## Testing

Components with Apex controllers include test classes:
- `CleanupOnExitControllerTest`
- `DynamicLookupQueryBuilderTest`
- `FlowHeaderControllerTest`

Run tests after deployment:
```powershell
sf apex run test --class-names CleanupOnExitControllerTest --target-org MyOrg --result-format human
sf apex run test --class-names DynamicLookupQueryBuilderTest --target-org MyOrg --result-format human
sf apex run test --class-names FlowHeaderControllerTest --target-org MyOrg --result-format human
```

---

For detailed documentation on each component, click the links above or navigate to the component's folder.
