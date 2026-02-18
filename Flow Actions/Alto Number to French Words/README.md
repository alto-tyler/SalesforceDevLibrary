# Alto Number to French Words

## Description
A Salesforce Flow Action that converts decimal numbers to their French word representation with configurable currency units. This is particularly useful for generating check amounts, invoices, or any document requiring numbers spelled out in French.

## Features
- ✅ Converts decimal numbers to French words following proper French grammar rules
- ✅ Configurable major unit (e.g., euro, dollar, livre)
- ✅ Configurable minor unit (e.g., centime, cent, penny)
- ✅ Handles numbers up to millions
- ✅ Automatic pluralization (euros vs euro)
- ✅ Proper French number formatting (vingt-et-un, soixante-dix, quatre-vingts)
- ✅ Flow-ready with @InvocableMethod

## Installation

### Option 1: Using Salesforce CLI
```bash
sf project deploy start --manifest manifest/package.xml --target-org your-org-alias
```

### Option 2: Using ANT Migration Tool
```bash
ant deployCode -Dsf.username=your@username.com
```

### Option 3: Manual Deployment
1. Copy the contents of `force-app/main/default/classes/` to your Salesforce org
2. Deploy via VS Code, Workbench, or Developer Console

## Usage

### In Salesforce Flow
1. Add an **Action** element to your Flow
2. Search for "Convert Number to French Words"
3. Configure the inputs:
   - **Input Number** (Decimal): The number to convert (e.g., 1234.56)
   - **Major Unit** (String): The major currency unit (e.g., "euro", "dollar", "livre")
   - **Minor Unit** (String): The minor currency unit (e.g., "centime", "cent", "penny")
4. Store the output in a Text variable

### Example Flow Usage
**Input:** 
- Number: `1234.56`
- Major Unit: `euro`
- Minor Unit: `centime`

**Output:** 
- `mille deux cent trente-quatre euros et cinquante-six centimes`

### In Apex Code
```apex
// Using the static method directly
String result = alto_NumberToFrenchWords.convert(1234.56, 'euro', 'centime');
System.debug(result); // mille deux cent trente-quatre euros et cinquante-six centimes

// With separate major/minor values
String result2 = alto_NumberToFrenchWords.convert(100, 50, 'dollar', 'cent');
System.debug(result2); // cent dollars et cinquante cents
```

## Examples

| Input Number | Major Unit | Minor Unit | French Words |
|--------------|------------|------------|-------------|
| 1 | euro | centime | un euro |
| 21 | euro | centime | vingt-et-un euros |
| 71 | dollar | cent | soixante-et-onze dollars |
| 80 | livre | penny | quatre-vingts livres |
| 99.99 | euro | centime | quatre-vingt-dix-neuf euros et quatre-vingt-dix-neuf centimes |
| 100 | dollar | cent | cent dollars |
| 201.50 | euro | centime | deux cent un euros et cinquante centimes |
| 1000 | livre | penny | mille livres |
| 1234.56 | euro | centime | mille deux cent trente-quatre euros et cinquante-six centimes |

## Files

### Apex Classes
- **alto_NumberToFrenchWords.cls**: Main conversion logic with Flow integration
- **alto_NumberToFrenchWordsTest.cls**: Comprehensive test class

### Configuration
- **manifest/package.xml**: Salesforce package deployment manifest

## French Number Rules Implemented
- Numbers 1-16 use unique words
- "et" (without hyphen) for 21, 31, 41, 51, 61, 71
- Special handling for 70-79 (soixante-dix, soixante et onze, etc.)
- Special handling for 80-99 (quatre-vingts, quatre-vingt-un, etc.)
- "cent" becomes "cents" when plural and ending a group
- "mille" never takes an "s"
- "million" becomes "millions" when plural
- Automatic pluralization of currency units

## Test Coverage
The component includes comprehensive test coverage:
- Basic numbers (0-100)
- Tens with "et" rule (21, 31, 41, 51, 61, 71)
- Special cases (70-79, 80-99)
- Hundreds and thousands
- Millions
- Decimal values
- Multiple currency types
- Edge cases

## Requirements
- Salesforce API Version: 65.0 or higher
- Apex Test Coverage: 100%

## License
MIT License - Feel free to use and modify

## Author
Alto

## Version History
- **1.0.0** (February 2026): Initial release with configurable currency units
