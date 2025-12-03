# Salesforce Dev Library

A collection of reusable Salesforce Flow components and actions to enhance your Flow Builder experience.

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

**For Clean Up On Exit:**
```powershell
# Copy the entire force-app folder contents
xcopy "..\SalesforceDevLibrary\Flow Components\Alto Clean Up On Exit\force-app" "force-app" /E /I /Y
```

**For Dynamic Lookup:**
```powershell
xcopy "..\SalesforceDevLibrary\Flow Components\Alto Dynamic Lookup\force-app" "force-app" /E /I /Y
```

**For Flow Header:**
```powershell
xcopy "..\SalesforceDevLibrary\Flow Components\Alto Flow Header\force-app" "force-app" /E /I /Y
```

**For Flow Footer:**
```powershell
xcopy "..\SalesforceDevLibrary\Flow Components\Alto Flow Footer\force-app" "force-app" /E /I /Y
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

1. Log in to your Salesforce org
2. Go to **Setup** → **Flows** → **New Flow** (or edit an existing Flow)
3. Add a **Screen** element
4. In the component panel on the left, search for the component name:
   - "Alto Clean Up On Exit"
   - "Alto Dynamic Lookup"  
   - "Alto Flow Header"
   - "Alto Flow Footer"
5. The component should appear in the list

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
xcopy "..\SalesforceDevLibrary\Flow Components\Alto Clean Up On Exit\force-app" "force-app" /E /I /Y
xcopy "..\SalesforceDevLibrary\Flow Components\Alto Dynamic Lookup\force-app" "force-app" /E /I /Y
xcopy "..\SalesforceDevLibrary\Flow Components\Alto Flow Header\force-app" "force-app" /E /I /Y
xcopy "..\SalesforceDevLibrary\Flow Components\Alto Flow Footer\force-app" "force-app" /E /I /Y

# Deploy everything
sf project deploy start --source-dir force-app
```

---

## Testing Components

Each component includes Apex test classes. After deployment:

1. **Run tests via Salesforce CLI**
   ```powershell
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

After deployment, components are immediately available in Flow Builder:

1. Open **Flow Builder** (Setup > Flows > New Flow or edit existing)
2. Add a **Screen** element
3. In the component sidebar, search for the component name:
   - "Alto Clean Up On Exit"
   - "Alto Dynamic Lookup"
   - "Alto Flow Header"
   - "Alto Flow Footer"
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

Each component has its own detailed README with:
- Property descriptions (exact XML labels as they appear in Flow Builder)
- Flow setup examples
- JSON configuration examples (for Header/Footer)
- Troubleshooting guides
- Best practices

Navigate to each component's folder to view full documentation.
