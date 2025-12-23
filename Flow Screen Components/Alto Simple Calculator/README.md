# Alto Simple Calculator — Flow User Guide

A simple calculator component for Flow Repeaters that enables basic arithmetic operations on two numeric values. This component solves the limitation where formulas cannot be accessed inside Flow Repeaters by providing add, subtract, multiply, and divide operations through a reactive screen component.

**Key Features:**
- Perform basic arithmetic operations (add, subtract, multiply, divide)
- Works inside Flow Repeaters with reactive screens
- No UI displayed (invisible component)
- Outputs calculation result immediately
- Supports decimal numbers
- Prevents division by zero errors

---

## Use Case: Flow Repeaters

Flow Repeaters cannot access formulas, which makes calculations on repeating data challenging. This component solves that problem by allowing you to perform calculations on values from the current repeater iteration.

**Example Scenario:**
- You have a repeater displaying line items
- Each iteration needs to calculate: `Quantity × Price = Total`
- Place this component on the repeater screen
- Pass `Quantity` and `Price` from current iteration
- Set operation to "Multiply"
- Use the output `Result` to display or store the total

---

## Adding to Your Flow

1. In Flow Builder, drag a **Screen** element onto your canvas (with a **Repeater** region).
2. In the left panel under **Components**, search for **"alto_simpleCalculator"** and drag it onto your screen.
3. Configure the properties (see sections below).
4. Reference the `Result` output in other components on the same screen (reactive) or in later flow elements.

---

## Flow Properties

### **Input Values**

**Value 1**
- First number in the calculation
- Required
- Example: `5`, `10.5`, `{!CurrentItem.Quantity}`

**Value 2**
- Second number in the calculation
- Required
- Example: `3`, `2.5`, `{!CurrentItem.Price}`

**Operation**
- The arithmetic operation to perform
- Required
- Options:
  - `Add` - Value 1 + Value 2
  - `Subtract` - Value 1 - Value 2
  - `Multiply` - Value 1 × Value 2
  - `Divide` - Value 1 ÷ Value 2
- Example: `Multiply`

---

## Output Values

**Result**
- The result of the calculation
- Type: Number (Decimal)
- Available for use in formulas, assignments, or display components on the same screen (reactive) or later screens

---

## Example Flow Configuration

### Scenario: Calculate Line Item Totals in Repeater

**Setup:**
1. Create a collection of records with `Quantity` and `Price` fields
2. Add a **Repeater** component to loop through the collection
3. Add **Simple Calculator** to the repeater screen:
   - **Value 1:** `{!CurrentItem.Quantity}`
   - **Value 2:** `{!CurrentItem.Price}`
   - **Operation:** `Multiply`
4. Add a **Display Text** component:
   - **Value:** `{!SimpleCalculator.Result}`
   - Shows the calculated total for each line item

### Scenario: Calculate Discount Amount

**Setup:**
1. Display fields: `Original Price` and `Discount Percentage`
2. Add **Simple Calculator #1**:
   - **Value 1:** `{!DiscountPercentage}`
   - **Value 2:** `100`
   - **Operation:** `Divide`
   - Output: Decimal percentage (e.g., 0.15 for 15%)
3. Add **Simple Calculator #2**:
   - **Value 1:** `{!OriginalPrice}`
   - **Value 2:** `{!SimpleCalculator1.Result}`
   - **Operation:** `Multiply`
   - Output: Discount amount

---

## Important Notes

### Division by Zero
- If you attempt to divide by zero, the component will output `0` to prevent errors
- Consider validating inputs before division operations

### Decimal Precision
- Results are returned as Salesforce `Number` type with standard decimal precision
- For financial calculations, consider rounding the result in a subsequent formula

### Reactive Screens
- This component requires **Flow API version 59.0 or higher** for reactive screen support
- Outputs update automatically on the same screen without requiring navigation
- Perfect for use in Repeaters where immediate feedback is needed

### No UI Display
- This component is invisible and shows no user interface
- It only performs calculations and provides outputs
- Combine with Display Text or other components to show results to users

---

## Troubleshooting

**Result is not updating:**
- Ensure your Flow API version is 59.0 or higher
- Verify that Value 1 and Value 2 are properly mapped to valid numbers
- Check that the Operation is set correctly

**Unexpected zero result:**
- Check if Value 2 is zero when using Divide operation
- Verify that input values contain numeric data

**Cannot use inside Repeater:**
- Confirm you're using API version 59.0 or higher
- Make sure the component is placed on the screen inside the Repeater region
- Ensure you're referencing `{!CurrentItem.FieldName}` for repeater values

---

## Technical Details

- **Component Type:** Lightning Web Component (LWC)
- **API Name:** `alto_simpleCalculator`
- **Namespace:** None (can be deployed to any org)
- **API Version:** 59.0 or higher (for reactive screens)
- **Dependencies:** None

---

## Installation

Deploy this component to your Salesforce org using the Salesforce CLI:

```bash
sf project deploy start --source-dir "Flow Screen Components/Alto Simple Calculator/force-app"
```

Or use the manifest file:

```bash
sf project deploy start --manifest "Flow Screen Components/Alto Simple Calculator/manifest/package.xml"
```

---

## Support

For issues, questions, or feature requests, please refer to the main repository documentation or create an issue in the GitHub repository.

---

## Version History

- **v1.0** - Initial release with basic arithmetic operations (add, subtract, multiply, divide)
