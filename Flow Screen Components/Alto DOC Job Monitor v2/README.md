# Alto DOC Job Monitor v2

A Flow screen component (and Lightning page component) that monitors Rootforms DOX document generation jobs in real-time, displaying task progress, email status, generated document links, and a Clone & Restart action.

## Features

- **Real-Time Status Monitoring** - Automatically polls document job status every 5 seconds until completion
- **Task Progress** - Displays related Tasks with collapsible section and live spinner while tasks are pending
- **Clone & Restart** - One-click clone of the job with cleared attachment/status fields, seamlessly switches to the new job in-place
- **Document Preview** - Native Salesforce file preview for generated ContentDocuments
- **Email Status** - Shows DOX email delivery status when present
- **Additional Record Linkage Status** - Displays linkage status when the job has `attachDocAsFile` enabled
- **Status Badge** - Visual status pill that derives "In Progress" even when the DOX status is still "Not Started" but tasks have appeared
- **URL-Addressable** - Can be embedded on Lightning App/Record pages and opened via URL with `c__recordId` parameter
- **Requires Rootforms DOX** - Depends on the `DOX__Document_Job__c` object from the Rootforms package

---

## How It Works

1. Create a document job record in your Flow or on a record page
2. Pass the Document Job Id to this component's **Record Id** input
3. Component polls the Document Job record every 5 seconds
4. Tasks are shown as they appear during generation
5. When the job reaches a terminal status (Completed / Exception), polling stops and generated documents are displayed
6. Use **Clone & Restart** to re-run the job without leaving the page

---

## Input Properties

| Property | Type | Label | Required | Description |
|----------|------|-------|----------|-------------|
| **recordId** | String | `Record Id` | ✅ Yes | The Id of the `DOX__Document_Job__c` record to monitor. Can be passed as a Flow input or via the URL parameter `c__recordId` |

---

## Component Behavior

### Status Monitoring

The component displays different content based on the document job status:

**Not Started / In Progress:**
- Header shows current status badge and live polling indicator
- Tasks section shows a spinner while no tasks have appeared yet
- Tasks expand automatically when present; collapses when job completes

**Completed:**
- Stops polling automatically
- Displays list of generated documents with **Preview** buttons (native file preview)
- Legacy Attachment IDs are rendered inline via `<iframe>`
- Auto-opens the first ContentDocument in native file preview on first completion

**Exception / Error:**
- Stops polling automatically
- Error message displayed in the header error banner

### Clone & Restart

Clicking **Clone & Restart** calls `alto_DoxJobMonitorController.cloneJob`, which:
- Queries all readable fields on the source job
- Creates a clone with status reset to "Not Started"
- Clears: `DOX__Attachment_Id__c`, `DOX__multipleAttachmentIDs__c`, `DOX__emailStatus__c`, `DOX__Additional_Rec_Linkage_Staus__c`
- The component seamlessly switches to the new job ID without a page reload

### Document Retrieval

Resolves document IDs from `DOX__Attachment_Id__c` and `DOX__multipleAttachmentIDs__c`:
- Supports ContentVersion IDs (068…), ContentDocument IDs (069…), and legacy Attachment IDs (00P…)
- Deduplicates IDs across both fields
- Falls back to ContentDocumentLink query for title resolution
- Malformed IDs are included with the raw ID as the display title

---

## Apex Classes

| Class | Purpose |
|-------|---------|
| `alto_DoxJobMonitorController` | Main controller — `getJobData`, `cloneJob`, `getFileBlob` |
| `alto_DoxJobMonitorControllerTest` | Test class with full coverage |

---

## Flow Example

**Scenario:** Generate a document with Rootforms and let the user monitor progress.

1. **Create Records** — Create a `DOX__Document_Job__c` record, store Id in `{!DocumentJobId}`
2. **Screen** — Add **Alto DOC Job Monitor**
   - **Record Id**: `{!DocumentJobId}`

The user stays on the screen, sees tasks appear in real-time, and can preview generated documents as soon as the job completes.

---

## Deployment

Deploy via SFDX using the included `manifest/package.xml`:

```bash
sf project deploy start --manifest manifest/package.xml
```

Or deploy the entire `force-app` directory:

```bash
sf project deploy start --source-dir force-app
```

**Dependencies:** Rootforms (DOX package) must be installed in the target org.
