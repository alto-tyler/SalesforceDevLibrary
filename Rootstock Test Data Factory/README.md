# Rootstock Test Data Factory

Apex utilities to generate **baseline Rootstock setup/test data** in a repeatable way. This is intended for unit tests and sandbox/dev seeding where Rootstock objects (namespace `rstk__`) require a minimum set of related configuration records to exist.

## What This Solves

Rootstock tests often fail because required “system” records (company/division/site/UOM, etc.) aren’t present. This factory provides a single place to create that baseline data so tests can focus on business logic.

## Included Classes

### `RootstockTestDataFactory`

- Creates a Rootstock `rstk__syconfig__c` record via `createTestSyConfig()`.
- Creates baseline Rootstock records via `createTestData()` (currency, company, division, user/license record, site, UOM, locations, and an example item setup).
- Returns a `RootstockTestDataFactory.Response` object containing key records that were created so your tests can reference them without re-querying.

`Response` includes (non-exhaustive): `rstk__sycurr__c`, `rstk__sycmp__c`, `rstk__sydiv__c`, `rstk__syusr__c`, `rstk__sysite__c`, `rstk__syuom__c`, location records, and a couple of `rstk__peitem__c` references.

### `RootstockTestDataBatch`

Batch wrapper you can run to execute the factory repeatedly. This is useful when you want to seed data outside a unit test, or you want the work to run asynchronously.

### `RootstockTestDataFactoryExampleTest`

An example `@isTest` class showing how to run the batch in `@testSetup` and then create a sample Rootstock work order (`rstk__wocst__c`) using the seeded config.

## Requirements / Assumptions

- Rootstock managed package installed (the factory references objects/fields in the `rstk__` namespace).
- The org has a `Profile` named `Standard User` (the factory selects it when creating a test user).
- The example test expects a `RecordType` with `DeveloperName = 'Disassembly'` on `rstk__wocst__c`.

## How To Use

### Recommended: use from `@testSetup`

Call the batch once in `@testSetup`, then query whatever you need in tests.

```apex
@testSetup
static void setup() {
    Test.startTest();
    Database.executeBatch(new RootstockTestDataBatch(1), 1);
    Test.stopTest();
}
```

### Use directly (synchronous)

If you don’t need async execution, you can call the factory methods directly:

```apex
RootstockTestDataFactory.createTestSyConfig();
RootstockTestDataFactory.Response res = RootstockTestDataFactory.createTestData();

System.assertNotEquals(null, res.syDiv);
System.assertNotEquals(null, res.sySite);
```

### Run in Anonymous Apex (sandbox/dev)

```apex
Database.executeBatch(new RootstockTestDataBatch(1), 1);
```

## Notes / Customization

- The factory sets `rstk__triggeroptions__c = 'UT'` on many Rootstock records. Keep/change this based on how your Rootstock org expects unit-test behavior.
- Many values are intentionally hard-coded (currency, company/div/site codes, etc.) to keep the setup deterministic. Adjust those defaults to match your org conventions.
- This code performs DML and will create real records when run outside tests—use it in sandboxes/dev orgs unless you intentionally want the data in production.
