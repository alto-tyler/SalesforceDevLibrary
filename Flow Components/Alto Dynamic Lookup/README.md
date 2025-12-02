# Alto Dynamic Lookup — How to Use

This guide explains how to use the `alto_dynamicLookup` Lightning Web Component (LWC) and the supporting Apex `DynamicLookupQueryBuilder` to implement flexible, dynamic lookups in Lightning pages and Flows.

Purpose: provide a configurable lookup control that can query any sObject at runtime, support parent filters, live or local search, barcode scanning (mobile), and easily integrate with Flows.

Files:
- LWC: `force-app/main/default/lwc/alto_dynamicLookup/alto_dynamicLookup.js` and `alto_dynamicLookup.html`
- Apex: `force-app/main/default/classes/DynamicLookupQueryBuilder.cls`
- Tests: `DynamicLookupQueryBuilderTest.cls`

## Quick Start (minimum)

1. Deploy the LWC and Apex class to your org.
2. Add the component to a Lightning record page or Flow screen.
3. Set `objectApiName` and at least one of `fieldApiName` (search field) or `displayFieldName`.

Minimal example usage (App Builder / Aura markup):

```
<c-alto-dynamic-lookup
    object-api-name="Contact"
    label="Contact Lookup"
    field-api-name="LastName"
    display-field-name="Name"
    value-field-name="Id"
    max-results="50"
    placeholder="Search contacts...">
</c-alto-dynamic-lookup>
```

Note: In many builders (Flow, App Builder) the `objectApiName` is exposed as a property named `objectApiName` — wire it to the record object you need.

## Deployment (Salesforce CLI)

```powershell
sfdx force:source:deploy -p "force-app/main/default/lwc/alto_dynamicLookup" -u <username>
sfdx force:source:deploy -p "force-app/main/default/classes/DynamicLookupQueryBuilder.cls" -u <username>

# Run tests
sfdx force:apex:test:run -n DynamicLookupQueryBuilderTest -r human -u <username>
```

## Public properties (what you can set)

- `label` — Text label for the control.
- `placeholder` — Placeholder text in the input.
- `iconName` — Icon to show next to results (e.g., `standard:account`).
- `displayFieldName` — Field on the sObject to show in the dropdown (defaults to `Name`).
- `fieldApiName` — Field to use when searching (e.g., `LastName`, `Email`).
- `maxResults` — Maximum number of rows shown in the dropdown.
- `valueFieldName` — Field used as the selection value (defaults to `Id`).
- `valueMatchType` — `partial` (default) or `exact` search when matching values locally.
- `allowDisplayFieldMatch` — If `true`, allow matching against the `displayFieldName` (contains).
- `sortBy` / `sortDirection` — Controls ORDER BY in the query.
- `parentFilterField` / `parentFilterValue` / `parentFilterOperator` — Add a parent filter (e.g., filter Contacts by AccountId).
- `disableOnNoParentValue` — If `true`, the input disables until a `parentFilterValue` is set.
- `allowBarcodeScanning` — If `true` and running on supported mobile app, a scan button will be shown.
- `populateOnTab` — If `true`, pressing Tab with a search value attempts to auto-populate the first matching record.

Also available (programmatic) via getters/setters:
- `selectedRecord` — object representing the selected sObject row.
- `selectedValue` — the corresponding `valueFieldName` for the selection.
- `recordId` — the selected record Id (if available).
- `componentInitialized` / `parentInitialized` — status flags emitted to Flow.

Keyboard / debug: Press Ctrl+Shift+L to toggle lookup debug logging (developer convenience).

## How it queries (Apex integration)

- `getSObjectDetails(objectApiName)` (cacheable): returns describe info (labels, accessibility, keyPrefix).
- `queryRecords(...)`: builds a SOQL string dynamically on the server using parameters and returns JSON-serialized records.

Key server-side parameters supported:
- `objectApiName`, `displayField`, `searchField`, `searchValue`, `parentFilterField`, `parentFilterValue`, `parentFilterOperator`, `whereClause`, `sortBy`, `sortDirection`, `maxResults`, `valueFieldName`, `valueMatchType`.

The server method intelligently escapes values and supports `IN`, `LIKE`, and other parent filter operators. It includes `Id` in SELECT by default and will include `Name` if nothing else is present.

## Integration with Flow

1. Add the LWC as a screen component.
2. Map your Flow variable that holds the temporary record Id to `value` or handle `selectedRecord` outputs as needed.
3. Use `componentInitialized` to block progression until the lookup is ready.

Flow attribute recommendations:
- `selectedRecord` -> Flow output variable (record data)
- `selectedValue` or `recordId` -> Flow variable for the selected Id
- `componentInitialized` -> Flow boolean used to gate actions until ready

## Modes: live vs local search

- By default the component uses live search (`searchType = 'live'`) and calls the server for filtered results. This is best for large datasets.
- Local search is supported internally (`searchType = 'local'`) if you preload data into `rawData` — useful for small datasets or highly interactive filtering.

## Special features

- Barcode scanning: on supported mobile clients `allowBarcodeScanning` shows a scan button and uses `lightning/mobileCapabilities.getBarcodeScanner()` to read values.
- `populateOnTab`: pressing Tab with a search value triggers an attempt to auto-select the first matching record and populate the control.
- `allowDisplayFieldMatch`: attempts to match typed text against the display field using `contains` when direct value-based match fails.

## Events dispatched (useful for parent components / Flows)

- `recordselected` — CustomEvent with `detail.record` containing the selected sObject record.
- `selectedvaluechange` — CustomEvent with `detail.value` when the selected value changes.
- Flow attribute changes via `FlowAttributeChangeEvent` for `selectedRecord`, `selectedValue`, `recordId`, and `componentInitialized` so Flows can bind to them directly.

## Troubleshooting & Tips

- Missing results:
  - Ensure `objectApiName` and `fieldApiName`/`displayFieldName` are correct and accessible.
  - Check Apex debug logs for `Generated SOQL:` and errors thrown by `DynamicLookupQueryBuilder`.

- Permission errors:
  - The running user must have `QUERY`/`READ` permission on the target object/fields.

- If matching logic yields multiple results and you expect one, try:
  - Adjusting `valueFieldName` to a unique field.
  - Enabling `allowDisplayFieldMatch` or tightening `whereClause`.

- If parent-filtered lookups are not working:
  - Verify `parentFilterField` exactly matches the API name (e.g., `AccountId`).
  - Ensure `parentFilterValue` is provided (or set `parentInitialized` when ready).

## Example: filtering Contacts by Account in a Flow

1. Set up a Flow that creates or references an `Account` (or passes an Account Id into the Flow).
2. Add `alto_dynamicLookup` to a screen and map:

```
objectApiName -> "Contact"
parentFilterField -> "AccountId"
parentFilterValue -> {!accountId}
displayFieldName -> "Name"
fieldApiName -> "LastName"
valueFieldName -> "Id"
populateOnTab -> true
```

3. The lookup will only be enabled once `parentFilterValue` is set (if `disableOnNoParentValue` is true). The dropdown will show Contacts for that Account.

## Tests

Run `DynamicLookupQueryBuilderTest` (included) to validate server-side query building and SObject describe behavior.