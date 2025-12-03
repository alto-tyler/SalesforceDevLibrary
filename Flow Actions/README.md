# Flow Actions

Salesforce Flow Actions are Apex invocable methods that can be used directly in Flow Builder as Action elements. These provide powerful server-side processing capabilities that can be called from any Flow.

## Available Actions

### Alto Execute SOQL
Execute dynamic SOQL queries with automatic date/datetime formatting

**Key Features:**
- Execute any valid SOQL query dynamically from Flow
- Automatic date and datetime formatting (supports DATE_LITERAL, ISO, en_US formats)
- Subquery support with recursive formatting
- Returns SObject collection for use in Flow
- Without sharing context for maximum query flexibility

**API Version:** 55.0

**Use Cases:**
- Dynamic record retrieval based on runtime conditions
- Complex queries with date filtering
- Queries requiring subqueries or aggregate functions
- Scenarios where Get Records element limitations are too restrictive

[View Full Documentation](Alto%20Execute%20SOQL/)

---

### Alto Rollup Numbers (Action)
Perform rollup calculations (SUM, AVERAGE, MEDIAN, MIN, MAX, COUNT) on record collections

**Key Features:**
- Six rollup operations: SUM, AVERAGE, MEDIAN, MIN, MAX, COUNT
- Works on any numeric field in a collection
- Returns single Decimal value
- Null-safe processing
- With sharing context for security

**API Version:** 59.0

**Use Cases:**
- Calculate totals across filtered record collections
- Determine averages for reporting
- Find min/max values in a dataset
- Count records meeting specific criteria
- Perform calculations that aren't available in standard Flow functions

[View Full Documentation](Alto%20Rollup%20Numbers%20(Action)/)

---

### Alto Flow Collection Comparator
Compare two record collections based on field values and return matching/non-matching records

**Key Features:**
- Compare primary records against a secondary reference collection
- Field-based matching with case sensitivity option
- Returns both matching and non-matching records
- Provides match counts for both categories
- Null-safe with graceful empty collection handling
- With sharing context for security

**API Version:** 63.0

**Use Cases:**
- Filter quote line items against product master
- Reconcile imported records against existing records
- Identify unprocessed records by comparing against processed collection
- Cross-object field comparisons
- Data validation and duplicate detection

[View Full Documentation](Alto%20Flow%20Collection%20Comparator/)

---

### Alto Flow Collection Filter
Filter a collection based on field value criteria with support for exact, partial, and inverted matches

**Key Features:**
- Filter on any field type (text, number, picklist, etc.)
- Multiple match modes: exact, partial (contains), blank/null detection
- Case sensitivity option for text comparisons
- Inverted match (NOT logic) for exclusion filtering
- Returns filtered collection, first match, and match count
- Null-safe processing

**API Version:** 63.0

**Use Cases:**
- Filter by status or stage values
- Find records with blank required fields
- Search for records containing specific text
- Get records that DON'T match criteria (inverted)
- Conditional processing based on runtime criteria

[View Full Documentation](Alto%20Flow%20Collection%20Filter/)

---

### Alto Flow Field Extractor
Extract field values from a collection and return as both a string collection and CSV

**Key Features:**
- Extract any field from any SObject collection
- Returns both List<String> and comma-separated CSV
- Optional deduplication for unique values only
- Null values automatically skipped
- Includes count of extracted values
- Type agnostic (converts any field to string)

**API Version:** 63.0

**Use Cases:**
- Build SOQL IN clauses with extracted IDs
- Generate CSV exports for integrations
- Get unique values from a field (deduplication)
- Build email recipient lists from Contact records
- Count distinct values in a collection
- Extract parent/related field values

[View Full Documentation](Alto%20Flow%20Field%20Extractor/)

---

## How to Use Flow Actions

1. Open **Flow Builder** (Setup > Flows > New Flow or edit existing)
2. Add an **Action** element to your Flow
3. In the action search, look for:
   - "Execute SOQL Query"
   - "Rollup Numbers"
   - "Compare Record Collections"
   - "Filter Record Collection"
   - "Extract Field Values"
4. Select the action and configure input parameters
5. Use the action's output variables in subsequent Flow elements

## Deployment

Each action includes:
- `README.md` - Comprehensive documentation with examples
- `force-app/` - Apex classes and test classes
- `manifest/package.xml` - Deployment manifest

See the [main repository README](../) for detailed deployment instructions.

## Testing

All actions include comprehensive test classes:
- `ExecuteSOQLTest` - Tests for Execute SOQL action
- `RollupNumberHelperTest` - Tests for Rollup Numbers action
- `FlowCollectionComparatorTest` - Tests for Collection Comparator action
- `FlowCollectionFilterTest` - Tests for Collection Filter action
- `FlowFieldExtractorTest` - Tests for Field Extractor action

Run tests after deployment:
```powershell
sf apex run test --class-names ExecuteSOQLTest --target-org MyOrg --result-format human
sf apex run test --class-names RollupNumberHelperTest --target-org MyOrg --result-format human
sf apex run test --class-names FlowCollectionComparatorTest --target-org MyOrg --result-format human
sf apex run test --class-names FlowCollectionFilterTest --target-org MyOrg --result-format human
sf apex run test --class-names FlowFieldExtractorTest --target-org MyOrg --result-format human
```

## Flow Actions vs Flow Screen Components

**Flow Actions:**
- Server-side Apex processing
- No user interface
- Can be used in any Flow type (Screen, Autolaunched, Triggered)
- Appear in the Action element in Flow Builder
- Execute synchronously during Flow execution

**Flow Screen Components:**
- Client-side LWC components
- Display user interface on screens
- Only available in Screen Flows
- Appear in Screen elements in Flow Builder
- Can interact with users and update reactively

---

For detailed documentation on each action, click the links above or navigate to the action's folder.
