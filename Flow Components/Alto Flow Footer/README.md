# Alto Flow Footer — Flow User Guide

This component provides a customizable footer for Flow screens with action buttons, flexible navigation controls, and optional meta text. Perfect for creating consistent navigation experiences across your Flows.

**Use Cases:**
- Standardize Next/Previous button styling across Flows
- Add custom action buttons (Save Draft, Cancel, Submit, etc.)
- Display footer meta information (disclaimers, help text, status)
- Control button alignment and grouping
- Build multi-action workflows with conditional buttons

---

## Adding to Your Flow

1. In Flow Builder, drag a **Screen** element onto your canvas.
2. In the left panel under **Components**, search for **"Alto Flow Footer"** and drag it onto your screen.
3. Configure the properties (see sections below).

---

## Flow Properties

### **Action Links (JSON)**
- Define custom action buttons using JSON array
- Each action can navigate, open URLs, or trigger Flow logic
- **Format:** JSON array of action objects (see examples below)

### **Show Next/Finish Button**
- Shows the Next or Finish button (auto-detected based on Flow position)
- Default: `True`

### **Show Previous Button**
- Shows the Previous button
- Default: `True`

### **Next Button Label**
- Custom label for Next/Finish button
- Leave blank for auto-detection ("Next" or "Finish" based on Flow position)

### **Previous Button Label**
- Custom label for Previous button
- Leave blank to use "Previous"

### **Next Button Variant**
- Button style variant
- Options: `base`, `neutral`, `brand`, `brand-outline`, `destructive`, `destructive-text`, `inverse`, `success`
- Default: `brand`

### **Previous Button Variant**
- Button style variant (same options as Next button)
- Default: `neutral`

### **Button Alignment**
- Horizontal alignment of buttons
- Options: `left`, `center`, `right`
- Default: `right`

### **Display Buttons as Group**
- When enabled, buttons are displayed as a grouped set (SLDS button group)
- Creates a unified button bar appearance
- Default: `False`

### **Footer Meta Text**
- Optional meta text to display in the footer
- Examples: disclaimers, help text, process status
- Only appears if "Show Footer Meta" is enabled

### **Show Footer Meta**
- When enabled, displays the footer meta text
- Default: `False`

### **Action Clicked** *(Output)*
- Output property containing the name of the clicked custom action
- Use in Flow Decision elements to route based on button clicks
- Only fires for custom actions without `navigate`, `url`, or `pageReference`

---

## Action Links JSON Format

Each action in the JSON array can have these properties:

| Property | Type | Description |
|----------|------|-------------|
| `name` | String | **Required.** Unique identifier for the action. Returned in "Action Clicked" output. |
| `label` | String | **Required.** Button text displayed to user. |
| `variant` | String | Button style: `base`, `neutral`, `brand`, `brand-outline`, `destructive`, `destructive-text`, `inverse`, `success`. Default: `neutral` |
| `iconName` | String | SLDS icon name (e.g., `utility:save`, `utility:close`). Optional. |
| `iconPosition` | String | Icon placement: `left` or `right`. Default: `left` |
| `visible` | Boolean | Show/hide button conditionally. Default: `true` |
| `url` | String | External URL to open. Use with `target` property. |
| `target` | String | URL target: `_blank` (new tab), `_self` (same window). Used with `url`. |
| `pageReference` | Object | Navigation mixin object for internal Salesforce navigation. |
| `navigate` | String | Flow navigation: `next`, `previous`, or `finish`. |

**Note:** Actions with `navigate`, `url`, or `pageReference` execute immediately. Actions without these properties fire the "Action Clicked" output for custom Flow logic.

---

## JSON Examples

### Example 1: Save Draft Button

```json
[
  {
    "name": "save_draft",
    "label": "Save Draft",
    "iconName": "utility:save",
    "variant": "neutral"
  }
]
```

**In Flow:**
1. Store `{!FooterComponent.actionClicked}` in variable: `{!varActionClicked}`
2. Add Decision: If `{!varActionClicked}` equals `"save_draft"`, create draft record

### Example 2: Cancel and Submit Buttons

```json
[
  {
    "name": "cancel",
    "label": "Cancel",
    "iconName": "utility:close",
    "variant": "destructive-text"
  },
  {
    "name": "submit",
    "label": "Submit for Approval",
    "iconName": "utility:approval",
    "variant": "brand"
  }
]
```

### Example 3: External Help Link

```json
[
  {
    "name": "help",
    "label": "Help",
    "iconName": "utility:help",
    "url": "https://help.yourcompany.com/process-guide",
    "target": "_blank",
    "variant": "neutral"
  }
]
```

### Example 4: Navigate to Record

```json
[
  {
    "name": "view_account",
    "label": "View Account",
    "iconName": "standard:account",
    "pageReference": {
      "type": "standard__recordPage",
      "attributes": {
        "recordId": "001XXXXXXXXXXXXXXX",
        "objectApiName": "Account",
        "actionName": "view"
      }
    }
  }
]
```

### Example 5: Conditional Buttons with Visibility

```json
[
  {
    "name": "save_draft",
    "label": "Save Draft",
    "iconName": "utility:save",
    "visible": true
  },
  {
    "name": "delete",
    "label": "Delete",
    "iconName": "utility:delete",
    "variant": "destructive",
    "visible": false
  }
]
```

**Tip:** Use Flow formulas to set `visible` dynamically based on conditions.

### Example 6: Custom Previous with Icon

```json
[
  {
    "name": "custom_back",
    "label": "Go Back",
    "iconName": "utility:back",
    "iconPosition": "left",
    "navigate": "previous",
    "variant": "neutral"
  }
]
```

---

## Common Flow Setup

### Scenario 1: Standard Footer with Meta Text

**Component Configuration:**
```
Show Next/Finish Button: True
Show Previous Button: True
Next Button Variant: brand
Previous Button Variant: neutral
Button Alignment: right

Show Footer Meta: True
Footer Meta Text: All fields marked with * are required. Click Next to continue.
```

### Scenario 2: Custom Actions Footer (No Standard Navigation)

**Component Configuration:**
```
Show Next/Finish Button: False
Show Previous Button: False
Button Alignment: center
Display Buttons as Group: True

Action Links (JSON):
[
  {"name":"cancel","label":"Cancel","variant":"neutral"},
  {"name":"save_draft","label":"Save Draft","iconName":"utility:save","variant":"neutral"},
  {"name":"submit","label":"Submit","iconName":"utility:check","variant":"brand"}
]
```

**Flow Setup:**
1. Create Text variable: `varActionClicked`
2. After screen, add Assignment: `{!varActionClicked}` = `{!FooterComponent.actionClicked}`
3. Add Decision:
   - Outcome "Cancel": `{!varActionClicked}` equals `"cancel"` → End Flow
   - Outcome "Save Draft": `{!varActionClicked}` equals `"save_draft"` → Create draft record
   - Outcome "Submit": `{!varActionClicked}` equals `"submit"` → Submit for approval

### Scenario 3: Grouped Button Bar

**Component Configuration:**
```
Display Buttons as Group: True
Button Alignment: center

Action Links (JSON):
[
  {"name":"option_a","label":"Option A","variant":"neutral"},
  {"name":"option_b","label":"Option B","variant":"neutral"},
  {"name":"option_c","label":"Option C","variant":"neutral"}
]

Show Next/Finish Button: False
Show Previous Button: False
```

### Scenario 4: Left-Aligned with Help Button

**Component Configuration:**
```
Button Alignment: left

Action Links (JSON):
[
  {"name":"help","label":"Need Help?","iconName":"utility:help","url":"https://help.yourcompany.com","target":"_blank"}
]

Show Next/Finish Button: True
Show Previous Button: True
Next Button Variant: brand
```

---

## Best Practices

✅ **Do:**
- Use `brand` variant for primary actions (Submit, Next)
- Use `neutral` variant for secondary actions (Cancel, Previous)
- Set **Button Alignment** to `right` for standard Flow navigation
- Use **Display Buttons as Group** for option-selection scenarios
- Add **Footer Meta Text** for important disclaimers or instructions

❌ **Don't:**
- Use duplicate `name` values in the same JSON array
- Forget to handle "Action Clicked" output for custom actions
- Mix too many button variants (stick to 2-3 for consistency)
- Use **Display Buttons as Group** with many buttons (limit to 3-5)

---

## Troubleshooting

**Problem:** Custom action buttons don't appear
- Verify JSON syntax is valid (use a JSON validator)
- Check that `name` and `label` are provided for each action
- Ensure `visible` is not set to `false`

**Problem:** "Action Clicked" output is empty
- Verify the action doesn't have `navigate`, `url`, or `pageReference` (these execute immediately)
- Ensure you're checking the output after the button is clicked
- Use Flow debug to verify the button click is registered

**Problem:** Footer meta text doesn't show
- Set **Show Footer Meta** = `True`
- Ensure **Footer Meta Text** has content

**Problem:** Buttons not aligned correctly
- Check **Button Alignment** setting (`left`, `center`, `right`)
- Verify **Display Buttons as Group** is set appropriately

**Problem:** Standard Next/Previous buttons missing
- Ensure **Show Next/Finish Button** and **Show Previous Button** are `True`
- Verify Flow has available actions (can't show Previous on first screen)

---

## Advanced Tips

### Dynamic JSON with Flow Variables

Build JSON dynamically using Text Template or Formula:

**Text Template Example:**
```
[
  {
    "name": "save_continue",
    "label": "Save & Continue",
    "iconName": "utility:save",
    "variant": "brand",
    "visible": {!ShowSaveButton}
  }
]
```

### Handling Multiple Actions

Use a Decision element with multiple outcomes:

```
Decision: Route Footer Action
  Outcome: Cancel
    Condition: {!varActionClicked} Equals "cancel"
    → Action: Show toast "Cancelled"
    → Navigate: End Flow
  
  Outcome: Save Draft
    Condition: {!varActionClicked} Equals "save_draft"
    → Element: Create Records (save draft)
    → Action: Show toast "Draft saved"
  
  Outcome: Submit
    Condition: {!varActionClicked} Equals "submit"
    → Element: Submit for Approval
    → Navigate: Next Screen
  
  Default Outcome:
    → Continue (no action taken)
```

### Combining with Flow Variables for Status

**Footer Meta Text Example:**
```
Step {!CurrentStep} of {!TotalSteps} | {!StatusMessage}
```

This dynamically updates based on Flow variables.

---

## Technical Details (for Admins/Developers)

- **Component Name:** `alto_flowFooter`
- **Navigation:** Uses Lightning Navigation mixin for `pageReference` navigation
- **Target:** `lightning__FlowScreen`
- **Button Variants:** Supports all SLDS button variants
- **Button Group:** Uses SLDS `slds-button-group` for grouped display
