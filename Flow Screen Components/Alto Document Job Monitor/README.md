# Alto Document Job Monitor

A Flow screen component that monitors Rootforms document generation jobs in real-time and displays generated documents with preview functionality.

## Features

- **Real-Time Status Monitoring** - Automatically polls document job status every 3 seconds until completion
- **Auto-Refresh** - Updates the screen automatically when documents are generated (no navigation required)
- **Document Preview** - View generated documents directly from the Flow screen
- **Multiple Document Support** - Handles jobs that generate single or multiple documents
- **Customizable Labels** - Configure header text, section labels, and messaging
- **Status Indicators** - Visual status badges and error handling
- **Link to Job Monitor** - Quick access to the full Rootforms Job Monitor page
- **Retry Logic** - Attempts up to 5 times to retrieve generated files if they're not immediately available

---

## How It Works

1. Create a document job record in your Flow using Rootforms
2. Pass the Document Job Id to this component's **Document Job Id** input
3. Component polls the Document Job record every 3 seconds
4. When status changes to "Completed", generated documents are retrieved and displayed
5. Users can click "View" buttons to preview documents in Salesforce's file preview
6. Polling stops automatically when job completes or encounters an exception

**Note:** This component requires Rootforms to be installed in your org.

---

## Input Properties

| Property | Type | Label | Required | Description |
|----------|------|-------|----------|-------------|
| **Document Job Id** | String | `Document Job Id` | ✅ Yes | The Id of the document job record to monitor (typically from a create records output) |
| **Custom Header Text** | String | `Custom Header Text` | No | Optional custom header text (defaults to the document job name if not provided) |
| **Generated Items Label** | String | `Generated Items Label` | No | Label for the generated files section (default: "Generated Documents") |
| **Generating Message** | String | `Generating Message` | No | Message shown while generation is in progress (default: "Document generation in progress. This page will update automatically.") |

---

## Component Behavior

### Status Monitoring

The component displays different content based on the document job status:

**Queued / In Progress:**
- Shows spinner with custom generating message
- Polls every 3 seconds for status changes
- Users remain on the screen while waiting

**Completed:**
- Stops polling automatically
- Displays list of generated documents with "View" buttons
- Each document shows icon and filename with extension
- Click "View" to open file preview in Salesforce

**Exception:**
- Stops polling automatically
- Displays error message in red theme box
- Provides link to full Job Monitor for troubleshooting

### Document Retrieval

- Reads document attachment fields from the document job record
- Implements retry logic: attempts up to 5 times with 1-second delays to handle asynchronous file creation
- Removes duplicate document IDs automatically
- Fetches ContentVersion details including title and ContentDocumentId
- Appends file extensions to titles if not already present

---

## Flow Examples

### Example 1: Generate and Display Contract Document

**Scenario:** Generate a contract document using Rootforms and show it to the user when complete.

**Setup:**

1. **Screen** - Input Screen
   - Collect any necessary data (contract terms, dates, etc.)
   - Store in variables: `{!ContractTerms}`, `{!EffectiveDate}`

2. **Create Records** - Create Document Job
   - Create a document job record using Rootforms
   - Store the record Id in: `{!DocumentJobId}`

3. **Screen** - Document Status Screen
   - Add **Alto Document Job Monitor**
     - **Document Job Id**: `{!DocumentJobId}`
     - **Custom Header Text**: `Your Contract is Being Generated`
     - **Generated Items Label**: `Your Document`
     - **Generating Message**: `Please wait while we generate your contract. This will only take a moment.`

**Result:** User sees a live status update and can preview the contract as soon as it's generated, without leaving the Flow.

---

### Example 2: Batch Document Generation with Custom Labels

**Scenario:** Generate multiple invoices at once using a comma-separated list of record Ids.

**Setup:**

1. **Get Records** - Get Invoice Records
   - Object: `Invoice__c`
   - Conditions: `Status__c` Equals `Ready_to_Send`
   - Store in: `{!InvoicesToGenerate}`

2. **Loop** - Build CSV List of Invoice Ids
   - Collection: `{!InvoicesToGenerate}`
   - Current Item: `{!CurrentInvoice}`
   
3. **Assignment** (inside loop) - Build Comma-Separated List
   - Variable: `{!InvoiceIdList}` (Text variable)
   - Operator: Add
   - Value: `{!CurrentInvoice.Id},{!InvoiceIdList}`

4. **Create Records** - Create Document Job for Batch
   - Create a document job record using Rootforms for batch processing with the ID list
   - Store the record Id in: `{!DocumentJobId}`
   
5. **Screen** - Status Monitor
   - Add **Alto Document Job Monitor**
     - **Document Job Id**: `{!DocumentJobId}`
     - **Custom Header Text**: `Batch Invoice Generation`
     - **Generated Items Label**: `Invoice Documents`
     - **Generating Message**: `Generating {!InvoicesToGenerate.size} invoices. This may take a moment...`

**Result:** All invoices are generated in a single document job instead of creating separate jobs in a loop. More efficient for batch processing.

---

### Example 3: Document Generation with Error Handling

**Scenario:** Generate a proposal document and handle potential errors gracefully.

**Setup:**

1. **Create Records** - Create Document Job
   - Create a document job record using Rootforms for the proposal
   - Store the record Id in: `{!DocumentJobId}`

2. **Screen** - Monitor Document Generation
   - Add **Alto Document Job Monitor**
     - **Document Job Id**: `{!DocumentJobId}`
     - **Custom Header Text**: `Proposal Document`
   
   - Add **Display Text** (below monitor)
     - Text: `If you encounter any issues, please contact your administrator with job ID: {!DocumentJobId}`

3. **Screen** - Next Steps
   - Shown after user clicks Next
   - Display Text: `Your proposal has been generated. You can find it in the Files section of the Opportunity.`

**Result:** Users see real-time status. If an exception occurs, they see the error message and have the job ID for support. The component automatically links to the Job Monitor page for detailed troubleshooting.

---

### Example 4: Multi-Document Package Generation

**Scenario:** Generate a document package that creates multiple files (e.g., Quote, Terms & Conditions, Attachments).

**Setup:**

1. **Decision** - Check if Quote is Approved
   - Outcome 1: `{!Quote.Status__c}` Equals `Approved`

2. **Create Records** - Create Document Job for Package
   - Create a document job record using Rootforms for the multi-document package
   - Store the record Id in: `{!DocJobId}`

3. **Screen** - Document Package Status
   - Add **Alto Document Job Monitor**
     - **Document Job Id**: `{!DocJobId}`
     - **Custom Header Text**: `Quote Package Generation`
     - **Generated Items Label**: `Generated Files`
     - **Generating Message**: `Generating your quote package (Quote, T&Cs, and Attachments). This may take a moment...`

**Result:** All documents from the package are displayed in a list when complete. Users can preview each document individually by clicking "View" buttons.

---

### Example 5: Simple Document Generation (Minimal Configuration)

**Scenario:** Quick setup with default labels.

**Setup:**

1. **Create Records** - Create Document Job
   - Create a document job record using Rootforms
   - Store the record Id in: `{!JobId}`

2. **Screen** - View Document
   - Add **Alto Document Job Monitor**
     - **Document Job Id**: `{!JobId}`
     - (Leave other properties blank to use defaults)

**Result:** Uses default labels. Header shows the document job name, section is labeled "Generated Documents", and standard generating message is displayed.

---

## Customization Options

### Custom Header Text
Override the default header (which uses the job name) with custom text:
- "Generating Your Contract"
- "Please Wait - Creating Invoice"
- "{!RecordName} Document Package"

### Generated Items Label
Customize the section header for the document list:
- "Your Documents" (friendly)
- "Download Files" (action-oriented)
- "Generated Reports" (specific context)
- "Invoice PDFs" (business context)

### Generating Message
Customize the waiting message:
- "Hang tight! We're creating your document..."
- "Generating document. This typically takes 10-30 seconds."
- "Processing your request. Page will update automatically."

---

## Component UI Elements

### Header Section
- **Left Side:** Header text (custom or job name) + status badge
- **Right Side:** "View Job Monitor" button (opens Rootforms Job Monitor in new tab)

### Status Badge
- Shows current job status with visual badge component
- Common statuses: "Queued", "In Progress", "Completed", "Exception"

### Loading States
- **Initial Load:** Spinner with "Checking document job status..."
- **Generating:** Inline spinner with custom generating message

### Completed State
- List of generated documents with icons
- Each document has a "View" button (brand/blue variant)
- Documents show title with file extension

### Error States
- **Exception:** Red error box with message and link to Job Monitor
- **No Files:** Yellow warning box if job completes but no files found
- **Error Loading:** Error message if document job cannot be loaded

---

## Technical Details

### Polling Mechanism
- Polls the document job record every 3 seconds using `setInterval`
- Uses `refreshApex` to re-query record data
- Automatically stops polling when:
  - Status = "Completed"
  - Status = "Exception"
  - Component is removed from screen

### Document Retrieval
- Queries document attachment fields from the document job record
- Implements 5-retry logic with 1-second delays (handles async file creation)
- Fetches ContentVersion records via Apex with SECURITY_ENFORCED
- Appends file extensions to titles if missing

### File Preview
- Uses `NavigationMixin` to open Salesforce's native file preview
- Navigates to `standard__namedPage` with `filePreview` page name
- Passes `ContentDocumentId` as `selectedRecordId`
- Opens in same tab (users can use back button to return)

---

## Troubleshooting

### Component shows "Error loading document job"
- Verify the **Document Job Id** is a valid document job record Id
- Check that the running user has read access to the Document Job object
- Confirm Rootforms is installed and configured in the org

### Status never changes from "Queued" or "In Progress"
- Check the Rootforms Job Monitor page (click "View Job Monitor" button)
- Verify the document package is properly configured
- Ensure the related record (e.g., Opportunity, Account) has required data
- Check Rootforms configuration for the document package

### No files displayed after "Completed" status
- Check if document attachment fields are populated on the Document Job record
- Verify ContentVersion records exist for the attachment IDs
- Check user has access to the ContentVersion records
- Look for errors in browser console (Developer Tools)

### "View" button does nothing or shows error
- Ensure user has permission to view ContentDocument/ContentVersion records
- Verify the ContentDocumentId is valid
- Check browser console for navigation errors
- Try opening the file from the Files related list to confirm access

### Documents show "Error loading" as title
- Apex query for ContentVersion failed (check user permissions)
- ContentVersion records may have been deleted
- Check sharing settings for ContentDocumentLink records

### Polling doesn't stop after completion
- Browser tab may be inactive (polling continues but shouldn't impact performance)
- Refresh the Flow screen if needed
- Check browser console for JavaScript errors

---

## Best Practices

### 1. Store Document Job Id Immediately
Always capture the Document Job Id when creating the document job record:
```
Create Records → Document Job
  Store record Id in: {!DocumentJobId}
```

### 2. Use Batch Processing for Multiple Records
Instead of creating document jobs inside loops, build a comma-separated list of record Ids and use Rootforms batch processing capabilities:
- ✅ Get Records → Loop to build CSV → Create single Document Job with batch processing
- ❌ Loop → Create Document Job for each record (inefficient, creates many jobs)

**Example CSV Building:**
```
Loop through records:
  Assignment: {!IdList} = {!CurrentRecord.Id},{!IdList}
  
Then pass {!IdList} to the document job record for batch processing
```

### 3. Use Descriptive Custom Header Text
Help users understand what's being generated:
- ✅ "Contract for {!AccountName}"
- ✅ "Invoice #{!InvoiceNumber}"
- ❌ "Document Job" (too generic)

### 3. Set Expectations with Generating Message
Let users know approximately how long to wait:
- "Generating document. This typically takes 10-30 seconds."
- "Creating PDF. Please remain on this page..."

### 4. Add Context Below the Component
Use Display Text elements to provide additional information:
- Where the document will be saved
- Next steps after generation
- What to do if there's an error

### 5. Handle Large Document Jobs
For document packages with many files or large files:
- Set expectations in the generating message: "Complex package may take 1-2 minutes"
- Consider showing the component on a dedicated screen
- Provide a "Continue Later" option if appropriate

### 6. Don't Navigate Away Too Quickly
Give users time to preview documents before moving to the next screen:
- Add "Next" button (not "Finish") so users can review
- Mention in Display Text: "Review your documents above, then click Next"

### 7. Test with Different Document Packages
- Single document packages
- Multi-document packages
- Large file sizes
- Document generation that may fail (test error handling)

---

## Limitations

### Rootforms Dependency
- **Requires Rootforms** installed in the org
- Cannot be used without the Rootforms document job object
- Relies on Rootforms field structure for document job records

### Polling Frequency
- Polls every 3 seconds (not configurable)
- May show slight delay between actual completion and display
- Polling continues even if browser tab is inactive

### File Access
- Users must have Salesforce file access permissions
- ContentDocumentLink sharing determines who can view files
- Preview relies on Salesforce's standard file preview (some file types may not preview)

### Browser Requirements
- Requires JavaScript enabled
- File preview may vary by browser
- Tested with modern browsers (Chrome, Firefox, Edge, Safari)

### No Download Button
- Component provides "View" (preview) only, not direct download
- Users can download from the file preview page
- Consider adding custom download functionality if needed

---

## API Version

Built with **Salesforce API version 62.0**.

---

## Dependencies

### Required Packages
- **Rootforms** - Document generation platform

### Apex Classes
- `DocumentJobMonitorHelper` - Fetches ContentVersion details
- `DocumentJobMonitorHelperTest` - Test coverage (100%)

### Salesforce Objects
- Rootforms document job object (must exist)
- `ContentVersion` - Salesforce file storage
- `ContentDocument` - Salesforce file metadata

---

## Deployment

To deploy this component:

1. Ensure **Rootforms is installed** in your target org
2. Deploy the LWC bundle and Apex classes together
3. See the main repository README for deployment instructions

**Note:** This component will not function without Rootforms installed.

---

## Support

For issues or questions:
- Verify Rootforms is installed and configured
- Check user permissions for Document Job and ContentVersion objects
- Review browser console for JavaScript errors
- Use the "View Job Monitor" button to access Rootforms native monitoring page
- Test document generation outside of Flow to isolate issues

---

## Use Cases

### Document Automation
- Contract generation with immediate preview
- Invoice generation for batch processing
- Quote packages with multiple documents
- Report generation with status updates

### User Experience
- Keep users on the same screen during generation
- Eliminate need to navigate to Files related list
- Provide instant preview access
- Show real-time progress updates

### Error Handling
- Graceful error display for failed generations
- Link to detailed Job Monitor for troubleshooting
- Clear status indicators throughout process

---

## Integration with Other Components

### Alto Datatable
- Generate documents for selected records from datatable
- Store `outputSelectedRows` and loop through to generate documents
- Monitor each document job in sequence

### Alto Dynamic Lookup
- Select a template from Dynamic Lookup
- Pass selected template Id to Drawloop action
- Monitor generation with Document Job Monitor

### Standard Flow Elements
- Use with **Decision** elements to conditionally generate documents
- Use with **Loop** + **Assignment** to build comma-separated Id lists for batch processing
- Use with **Create Records** element to create Document Job records
- Avoid creating document jobs inside loops - build CSV list instead
