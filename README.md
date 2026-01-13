# Salesforce Dev Library

A collection of reusable Salesforce Flow components and actions to enhance your Flow Builder experience.

## Components

### Flow Actions
- **[Alto Execute SOQL](Flow%20Actions/Alto%20Execute%20SOQL/)** - Execute dynamic SOQL queries from Flow
- **[Alto Rollup Numbers (Action)](Flow%20Actions/Alto%20Rollup%20Numbers%20(Action)/)** - Perform rollup calculations (SUM, AVERAGE, MEDIAN, MIN, MAX, COUNT) on record collections
- **[Alto Flow Collection Comparator](Flow%20Actions/Alto%20Flow%20Collection%20Comparator/)** - Compare two record collections based on field values and return matching/non-matching records
- **[Alto Flow Collection Filter](Flow%20Actions/Alto%20Flow%20Collection%20Filter/)** - Filter a collection based on field value criteria with exact, partial, and inverted match support
- **[Alto Flow Field Extractor](Flow%20Actions/Alto%20Flow%20Field%20Extractor/)** - Extract field values from a collection and return as both a string collection and CSV

### Flow Screen Components
- **[Alto Clean Up On Exit](Flow%20Screen%20Components/Alto%20Clean%20Up%20On%20Exit/)** - Automatically delete records when users exit a Flow screen
- **[Alto Datatable](Flow%20Screen%20Components/Alto%20Datatable/)** - Display, select, filter, search, and inline edit records in a customizable datatable. Outputs all records (edited and unedited) unlike the original which only outputs edited and selected rows (based on Eric Smith's component with reactivity enhancements)
- **[Alto Document Job Monitor](Flow%20Screen%20Components/Alto%20Document%20Job%20Monitor/)** - Monitor document generation jobs in real-time and display generated documents (requires DOX__Document_Job__c object from Rootforms)
- **[Alto Dynamic Lookup](Flow%20Screen%20Components/Alto%20Dynamic%20Lookup/)** - Configurable lookup component with parent filtering, barcode scanning, and validation
- **[Alto Multi Dynamic Lookup](Flow%20Screen%20Components/Alto%20Multi%20Dynamic%20Lookup/)** - Multi-select lookup with pill display (requires Dynamic Lookup)
- **[Alto Flow Header](Flow%20Screen%20Components/Alto%20Flow%20Header/)** - Header component with Rootstock company info and customizable action buttons
- **[Alto Flow Footer](Flow%20Screen%20Components/Alto%20Flow%20Footer/)** - Footer component with customizable action buttons and alignment options
- **[Alto Rollup Numbers](Flow%20Screen%20Components/Alto%20Rollup%20Numbers/)** - Perform rollup calculations (SUM, AVERAGE, MEDIAN, MIN, MAX, COUNT) on record collections without displaying UI
- **[Alto Flow Modal Width Override](Flow%20Screen%20Components/Alto%20Flow%20Modal%20Width%20Override/)** - Override the default modal width for Flow screens launched as Quick Actions (in modals), to support wide content such as datatables or large forms
- **[Alto Simple Calculator](Flow%20Screen%20Components/Alto%20Simple%20Calculator/)** - Perform basic arithmetic operations on two numeric values in Flow Repeaters (where formulas can't be used)
- **[Alto Record Fetcher](Flow%20Screen%20Components/Alto%20Record%20Fetcher/)** - Fetch a single record with specified fields and return it as an SObject with reactive screen support
- **[Alto Repeater Set Columns](Flow%20Screen%20Components/Alto%20Repeater%20Set%20Columns/)** - Create responsive multi-column layouts for Flow Repeaters with configurable breakpoints

### Rootstock Utilities
- **[Rootstock Test Data Factory](Rootstock%20Test%20Data%20Factory/)** - Apex utilities for generating Rootstock test data

### Reactive Screen Support

**⚠️ Important:** Most of these components leverage reactive screen functionality, which requires **Flow API version 59.0 or higher**. Reactive screens allow components to automatically update other components on the same screen when their output values change, without requiring navigation to another screen.

To use reactive features:
1. Ensure your Flow's API version is set to 59.0 or higher
2. Place reactive components on the same screen as components that consume their outputs
3. Outputs will automatically update dependent components in real-time

## How to Deploy Components to Your Org

### Prerequisites

Before you begin, make sure you have:

1. **Visual Studio Code** - [Download here](https://code.visualstudio.com/)
2. **Salesforce Extensions for VS Code** - [Install from VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode)
3. **Salesforce CLI** - [Installation instructions](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm)
4. **Git** (optional but recommended) - [Download here](https://git-scm.com/downloads)

### Step-by-Step Deployment

#### 1. Set Up Your Salesforce Project

Open a terminal (PowerShell, Command Prompt, or VS Code integrated terminal) and create a new Salesforce project:

```powershell
sf project generate --name MyProject --template standard
cd MyProject
```

This creates a new project with the standard Salesforce DX folder structure.

#### 2. Authenticate to Your Salesforce Org

Connect VS Code to your Salesforce org:

```powershell
sf org login web --alias MyOrg --set-default
```

This opens a browser window where you'll log in to your Salesforce org. Once authenticated, the CLI will save the connection.

**Tip:** You can verify your connection with:
```powershell
sf org display --target-org MyOrg
```

#### 3. Clone or Download This Repository

**Option A: Clone with Git (Recommended)**
```powershell
# Navigate to a folder where you want to download the repository
cd ..
git clone https://github.com/alto-tyler/SalesforceDevLibrary.git
```

**Option B: Download ZIP**
- Go to [https://github.com/alto-tyler/SalesforceDevLibrary](https://github.com/alto-tyler/SalesforceDevLibrary)
- Click the green "Code" button → "Download ZIP"
- Extract the ZIP file to a folder on your computer

#### 4. Copy Component Files to Your Project

Navigate to your Salesforce project and copy the component folder you want to deploy:

```powershell
cd MyProject
```

**Flow Actions:**

**For Execute SOQL:**
```powershell
xcopy "..\SalesforceDevLibrary\Flow Actions\Alto Execute SOQL\force-app" "force-app" /E /I /Y
```

**For Rollup Numbers (Action):**
```powershell
xcopy "..\SalesforceDevLibrary\Flow Actions\Alto Rollup Numbers (Action)\force-app" "force-app" /E /I /Y
```

**For Flow Collection Comparator:**
```powershell
xcopy "..\SalesforceDevLibrary\Flow Actions\Alto Flow Collection Comparator\force-app" "force-app" /E /I /Y
```

**For Flow Collection Filter:**
```powershell
xcopy "..\SalesforceDevLibrary\Flow Actions\Alto Flow Collection Filter\force-app" "force-app" /E /I /Y
```

**For Flow Field Extractor:**
```powershell
xcopy "..\SalesforceDevLibrary\Flow Actions\Alto Flow Field Extractor\force-app" "force-app" /E /I /Y
```

**Flow Screen Components:**

**For Clean Up On Exit:**
```powershell
# Copy the entire force-app folder contents
xcopy "..\SalesforceDevLibrary\Flow Screen Components\Alto Clean Up On Exit\force-app" "force-app" /E /I /Y
```

**For Datatable:**
```powershell
xcopy "..\SalesforceDevLibrary\Flow Screen Components\Alto Datatable\force-app" "force-app" /E /I /Y
```

**For Document Job Monitor:**
```powershell
# Requires Drawloop/Nintex DocGen installed in target org
xcopy "..\SalesforceDevLibrary\Flow Screen Components\Alto Document Job Monitor\force-app" "force-app" /E /I /Y
```

**For Dynamic Lookup:**
```powershell
xcopy "..\SalesforceDevLibrary\Flow Screen Components\Alto Dynamic Lookup\force-app" "force-app" /E /I /Y
```

**For Multi Dynamic Lookup:**
```powershell
# Requires Dynamic Lookup to be deployed first
xcopy "..\SalesforceDevLibrary\Flow Screen Components\Alto Multi Dynamic Lookup\force-app" "force-app" /E /I /Y
```

**For Flow Header:**
```powershell
xcopy "..\SalesforceDevLibrary\Flow Screen Components\Alto Flow Header\force-app" "force-app" /E /I /Y
```

**For Flow Footer:**
```powershell
xcopy "..\SalesforceDevLibrary\Flow Screen Components\Alto Flow Footer\force-app" "force-app" /E /I /Y
```

**For Rollup Numbers:**
```powershell
xcopy "..\SalesforceDevLibrary\Flow Screen Components\Alto Rollup Numbers\force-app" "force-app" /E /I /Y
```

**For Flow Modal Width Override:**
```powershell
xcopy "..\SalesforceDevLibrary\Flow Screen Components\Alto Flow Modal Width Override\force-app" "force-app" /E /I /Y
```

**For Simple Calculator:**
```powershell
xcopy "..\SalesforceDevLibrary\Flow Screen Components\Alto Simple Calculator\force-app" "force-app" /E /I /Y
```

**For Record Fetcher:**
```powershell
xcopy "..\SalesforceDevLibrary\Flow Screen Components\Alto Record Fetcher\force-app" "force-app" /E /I /Y
```

**For Repeater Set Columns:**
```powershell
xcopy "..\SalesforceDevLibrary\Flow Screen Components\Alto Repeater Set Columns\force-app" "force-app" /E /I /Y
```

**Note:** If you want to deploy multiple components, run multiple copy commands before deploying.

#### 5. Deploy to Your Org

Deploy the components using Salesforce CLI:

```powershell
sf project deploy start --source-dir force-app
```

You'll see output showing the deployment progress. Wait for the message: `Deploy Succeeded`.

**Alternative:** Deploy from VS Code UI
- Right-click the `force-app` folder in VS Code Explorer
- Select **SFDX: Deploy Source to Org**

#### 6. Verify Deployment

**Flow Actions:**
1. Log in to your Salesforce org
2. Go to **Setup** → **Flows** → **New Flow** (or edit an existing Flow)
3. Add an **Action** element
4. In the action search, look for:
   - "Execute SOQL Query"
   - "Rollup Numbers"
   - "Compare Record Collections"
   - "Filter Record Collection"
   - "Extract Field Values"
5. The actions should appear in the action list

**Flow Screen Components:**
1. Go to **Setup** → **Flows** → **New Flow** (or edit an existing Flow)
2. Add a **Screen** element
3. In the component panel on the left, search for the component name:
   - "Cleanup On Exit"
   - "Alto Datatable"
   - "Alto Document Job Monitor"
   - "Alto Dynamic Lookup"
   - "Alto Multi Dynamic Lookup"
   - "Alto Header"
   - "Alto Flow Footer"
   - "Alto Rollup Record Numbers"
4. The components should appear in the list

---

### Quick Reference: Deploy All Components at Once

If you want to deploy all components in one go:

```powershell
# Create new project
sf project generate --name MyProject --template standard
cd MyProject

# Authenticate
sf org login web --alias MyOrg --set-default

# Clone repository (or download and extract)
cd ..
git clone https://github.com/alto-tyler/SalesforceDevLibrary.git

# Copy all component folders
cd MyProject

# Flow Actions
xcopy "..\SalesforceDevLibrary\Flow Actions\Alto Execute SOQL\force-app" "force-app" /E /I /Y
xcopy "..\SalesforceDevLibrary\Flow Actions\Alto Rollup Numbers (Action)\force-app" "force-app" /E /I /Y
xcopy "..\SalesforceDevLibrary\Flow Actions\Alto Flow Collection Comparator\force-app" "force-app" /E /I /Y
xcopy "..\SalesforceDevLibrary\Flow Actions\Alto Flow Collection Filter\force-app" "force-app" /E /I /Y
xcopy "..\SalesforceDevLibrary\Flow Actions\Alto Flow Field Extractor\force-app" "force-app" /E /I /Y

# Flow Screen Components
xcopy "..\SalesforceDevLibrary\Flow Screen Components\Alto Clean Up On Exit\force-app" "force-app" /E /I /Y
xcopy "..\SalesforceDevLibrary\Flow Screen Components\Alto Datatable\force-app" "force-app" /E /I /Y
xcopy "..\SalesforceDevLibrary\Flow Screen Components\Alto Document Job Monitor\force-app" "force-app" /E /I /Y
xcopy "..\SalesforceDevLibrary\Flow Screen Components\Alto Dynamic Lookup\force-app" "force-app" /E /I /Y
xcopy "..\SalesforceDevLibrary\Flow Screen Components\Alto Multi Dynamic Lookup\force-app" "force-app" /E /I /Y
xcopy "..\SalesforceDevLibrary\Flow Screen Components\Alto Flow Header\force-app" "force-app" /E /I /Y
xcopy "..\SalesforceDevLibrary\Flow Screen Components\Alto Flow Footer\force-app" "force-app" /E /I /Y
xcopy "..\SalesforceDevLibrary\Flow Screen Components\Alto Rollup Numbers\force-app" "force-app" /E /I /Y
xcopy "..\SalesforceDevLibrary\Flow Screen Components\Alto Flow Modal Width Override\force-app" "force-app" /E /I /Y
xcopy "..\SalesforceDevLibrary\Flow Screen Components\Alto Simple Calculator\force-app" "force-app" /E /I /Y
xcopy "..\SalesforceDevLibrary\Flow Screen Components\Alto Record Fetcher\force-app" "force-app" /E /I /Y
xcopy "..\SalesforceDevLibrary\Flow Screen Components\Alto Repeater Set Columns\force-app" "force-app" /E /I /Y

# Deploy everything
sf project deploy start --source-dir force-app
```

---

## Testing Components

Each component includes Apex test classes. After deployment:

1. **Run tests via Salesforce CLI**
   ```powershell
   # Flow Actions
   sf apex run test --class-names ExecuteSOQLTest --target-org MyOrg --result-format human
   sf apex run test --class-names RollupNumberHelperTest --target-org MyOrg --result-format human
   sf apex run test --class-names FlowCollectionComparatorTest --target-org MyOrg --result-format human
   sf apex run test --class-names FlowCollectionFilterTest --target-org MyOrg --result-format human
   sf apex run test --class-names FlowFieldExtractorTest --target-org MyOrg --result-format human
   
   # Flow Screen Components
   sf apex run test --class-names CleanupOnExitControllerTest --target-org MyOrg --result-format human
   sf apex run test --class-names DynamicLookupQueryBuilderTest --target-org MyOrg --result-format human
   sf apex run test --class-names FlowHeaderControllerTest --target-org MyOrg --result-format human
   ```

2. **Run tests via Setup UI**
   - Go to **Setup** > **Apex Test Execution**
   - Select the test class
   - Click **Run**

---

## Using Components in Flows

After deployment, components are immediately available in Flow Builder.

### Flow Actions

1. Open **Flow Builder** (Setup > Flows > New Flow or edit existing)
2. Add an **Action** element
3. In the action search, look for:
   - "Execute SOQL Query"
   - "Rollup Numbers"
   - "Compare Record Collections"
   - "Filter Record Collection"
   - "Extract Field Values"
4. Select the action and configure input parameters as documented in each action's README

### Flow Screen Components

1. Open **Flow Builder** (Setup > Flows > New Flow or edit existing)
2. Add a **Screen** element
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

---

## Troubleshooting

### Component doesn't appear in Flow Builder
- Verify deployment was successful (no errors in deployment log)
- Refresh your Flow Builder browser tab
- Check that the `.js-meta.xml` file was deployed (contains `<isExposed>true</isExposed>`)
- Verify API version compatibility (components use API version 63.0)

### Deployment errors
- **"Component already exists"**: The component may already be deployed. Use `--ignore-warnings` flag or delete the existing component first
- **"Missing dependency"**: Some components have Apex dependencies. Deploy both Apex classes and LWC bundles together
- **Test coverage errors**: Deploy with `--ignore-warnings` if test coverage is an issue, then run tests separately

### Apex test failures
- Ensure you have the necessary object permissions
- Check that required custom objects/fields exist (e.g., Flow Header requires Rootstock objects)
- Review test class code for specific setup requirements

---

## Component Requirements

### Document Job Monitor Component
**⚠️ Requires Rootforms**  
This component monitors document generation jobs and depends on the `DOX__Document_Job__c` object and related Rootforms fields. It will not function in orgs without Rootforms installed.

### Multi Dynamic Lookup Component
**⚠️ Requires Alto Dynamic Lookup**  
This component is a wrapper around the Dynamic Lookup component and cannot function without it. Deploy Alto Dynamic Lookup before deploying Multi Dynamic Lookup.

### Flow Header Component
**⚠️ Requires Rootstock ERP**  
This component depends on Rootstock ERP custom objects (`rstk__sop__c`, `rstk__soinv__c`, etc.). It will not function in orgs without Rootstock installed.

### All Other Components
Standard Salesforce orgs - no additional packages required.

---

## API Version

All components are built with **Salesforce API version 63.0** (Spring '25). They should work in earlier versions, but you may need to update the `apiVersion` in the `-meta.xml` files if deploying to older orgs.

---

## Contributing

Contributions are welcome! Please:
1. Fork this repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request with a clear description

---

## License

These components are provided as-is for use in Salesforce orgs. Feel free to modify and distribute as needed.

---

## Support

For issues, questions, or feature requests:
- Open an issue on GitHub
- Review the individual component READMEs for detailed usage documentation

---

## Component Documentation

Each component has its own detailed README (only available in SalesforceDevLibrary and not deployable with components) with:
- Property descriptions (exact XML labels as they appear in Flow Builder)
- Flow setup examples
- JSON configuration examples (for Header/Footer)
- Troubleshooting guides
- Best practices

Navigate to each component's folder to view full documentation.
