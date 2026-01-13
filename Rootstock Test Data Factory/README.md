# Rootstock Test Data Factory

A lightweight SFDX-style module containing only Apex classes for generating test data across Rootstock objects. This folder is structured to match the other components in this repo and focuses on `force-app/main/default/classes`.

## Structure

```
Rootstock Test Data Factory/
└─ force-app/
   └─ main/
      └─ default/
         └─ classes/
            ├─ RootstockTestDataBatch.cls
            ├─ RootstockTestDataBatch.cls-meta.xml
            ├─ RootstockTestDataFactory.cls
            ├─ RootstockTestDataFactory.cls-meta.xml
            ├─ RootstockTestDataFactoryExampleTest.cls
            ├─ RootstockTestDataFactoryExampleTest.cls-meta.xml

└─ manifest/
   └─ package.xml
```

## Prerequisites

- Salesforce CLI (`sf` or legacy `sfdx`) installed
- An authenticated org alias (e.g., `DevHub`, `MyScratch`, or `SandboxAlias`)

## Deploy

Using the modern `sf` CLI:

```powershell
sf project deploy start --source-dir "Rootstock Test Data Factory/force-app/main/default/classes" --target-org <alias>
```

Using the legacy `sfdx` CLI by path:

```powershell
sfdx force:source:deploy -p "Rootstock Test Data Factory/force-app/main/default/classes" -u <alias>
```

Using `package.xml`:

```powershell
sfdx force:source:deploy -x "Rootstock Test Data Factory/manifest/package.xml" -u <alias>
```

## Notes

- This module includes only Apex classes; no LWC or other metadata.
- Replace or extend the sample factory methods to align to your Rootstock data model.
