
# Cleanup On Exit — How to Use

This guide explains how to use the `alto_cleanupOnExit` component and its supporting Apex controller to remove temporary Salesforce records when a user navigates away or closes a browser tab.

**Goal:** Remove ephemeral records automatically when users leave a page (e.g., temporary form submissions or on-the-fly records created during a Flow).

**Files:**
- Component: `force-app/main/default/lwc/alto_cleanupOnExit/alto_cleanupOnExit.js` and `alto_cleanupOnExit.html`
- Controller: `force-app/main/default/classes/CleanupOnExitController.cls`
- Tests: `CleanupOnExitControllerTest.cls`

## Quick Start (3 steps)

1. Add the component to your page or Flow and provide the `recordId`.
2. Configure whether you want deletion on navigation, on page close, or both.
3. Optionally set `cascadeDelete` or `lookupChildRelationships` to remove related records first.

Example quick snippet (LWC in an Aura or App Builder context):

```
<c-alto-clean-up-on-exit
    record-id="{!recordId}"
    delete-on-navigate="true"
    delete-on-page-close="true"
    cascade-delete="false"
    lookup-child-relationships="My_Custom_Children__r"
    show-debug-messages="true">
</c-alto-clean-up-on-exit>
```

## Properties (what to set)

- `recordId` (required for deletion): the Id of the parent record you intend to delete.
- `deleteOnNavigate` (boolean): perform delete during `disconnectedCallback` (when navigating away inside the app).
- `deleteOnPageClose` (boolean): attempt delete during `beforeunload` / `pagehide` (when closing tab/browser).
- `cascadeDelete` (boolean): instructs the Apex controller to attempt to delete Master-Detail child records first.
- `lookupChildRelationships` (CSV string): names of child relationships (child relationship names from object schema) to delete lookup children for.
- `showDebugMessages` (boolean): enables browser console logging for debugging.

Tip: Set `showDebugMessages=true` during testing to see lifecycle logs in the browser console.

## Deployment / Installation

1. Deploy the LWC folder and the Apex classes to your org (use your preferred CI or Salesforce CLI):

```powershell
sfdx force:source:deploy -p "force-app/main/default/lwc/alto_cleanupOnExit" -u <username>
sfdx force:source:deploy -p "force-app/main/default/classes/CleanupOnExitController.cls" -u <username>
```

2. Run tests (recommended):

```powershell
sfdx force:apex:test:run -n CleanupOnExitControllerTest -r human -u <username>
```

3. Add the component to a Lightning record page or include it inside a Flow screen (as an LWC) and wire `recordId` from the current record.

## Using in a Flow

- Add `alto_cleanupOnExit` to a Flow Screen as an LWC component.
- Map the Flow variable containing the record Id to `recordId`.
- Set `deleteOnNavigate=true` so the Flow will attempt cleanup when the user moves between screens or exits the flow.

Example Flow property mapping:
- `recordId` -> `{!tempRecordId}`
- `deleteOnNavigate` -> `true`
- `deleteOnPageClose` -> `false` (optional)

Note: Because Flow screen unload timing can vary, test the flow end-to-end in sandbox.

## Behavior details (what happens under the hood)

- The LWC listens to `disconnectedCallback`, `beforeunload`, and `pagehide` and calls the Apex method `CleanupOnExitController.deleteRecord(recordId, cascadeDelete, lookupRelationships)` when configured.
- The Apex controller validates the Id, confirms record existence, optionally deletes lookup-specified children and Master-Detail children, then deletes the parent record using `Database.delete(recId, false)` (non-atomic; partial failures won't throw an exception).
- The controller returns plain text status messages prefixed with `SUCCESS:` or `ERROR:` for logging/diagnostics.

## Permissions & Safety

- The running user must have Delete permission on the target object and on child objects to remove them.
- The controller uses dynamic queries and describe calls; ensure that the code runs in an org context with appropriate sharing and describe access.

## Reliability and Best Practices

- Browser unload events are not guaranteed to complete server calls. Use `deleteOnNavigate` for more reliable in-app navigation cleanup; `deleteOnPageClose` is best-effort.
- For guaranteed cleanup consider server-side approaches (scheduled jobs, a short-lived flag, or a background process that deletes stale temporary records).
- Prefer `lookupChildRelationships` to explicitly remove lookup children you control; `cascadeDelete` only deletes relationships that the platform reports as cascade-capable (Master-Detail).

## Troubleshooting

- If deletes fail silently, enable `showDebugMessages` to view console logs and check Apex debug logs for errors.
- If parent delete fails due to child records, either enable `cascadeDelete` (when applicable) or add the appropriate lookup relationship names to `lookupChildRelationships`.
- If you see permission errors in Apex logs, verify the running user's profile/permission sets.

## Example: Minimal usage for ephemeral record in a Flow

1. Create temporary record in Flow.
2. Pass its Id into `alto_cleanupOnExit` on every screen where cleanup may be required.
3. Set `deleteOnNavigate=true` to remove the record when the user leaves the current Flow screen or finishes the Flow.
