# Alto Flow Header — Flow User Guide

This component provides a professional header for Flow screens with customizable action buttons, company/division information display, and flexible navigation options. Perfect for creating branded, enterprise-ready Flow experiences.

**⚠️ Important:** This component **requires Rootstock ERP** to be installed in your Salesforce org. The Apex controller depends on Rootstock objects and fields. This component will not work in orgs without Rootstock.

**Use Cases:**
- Add custom header with branding to Flow screens
- Create Help, Cancel, or custom action buttons
- Display company/division context
- Build multi-action workflows with conditional buttons
- Navigate to external URLs or internal pages from Flows

---

## Adding to Your Flow

1. In Flow Builder, drag a **Screen** element onto your canvas.
2. In the left panel under **Components**, search for **"Alto Header"** and drag it onto your screen.
3. Configure the properties (see sections below).

---

## Flow Properties

### **Action Links (JSON)**
- Define custom action buttons using JSON array
- Each action can navigate, open URLs, or trigger Flow logic
- **Format:** JSON array of action objects (see examples below)

### **Max Visible Actions**
- Maximum number of actions to show as buttons before moving to overflow menu
- Default: `3`
- Ignored if "Custom Actions In Dropdown" is enabled

### **Custom Actions In Dropdown**
- When enabled, only Previous/Next buttons show as visible buttons
- All custom actions appear in overflow dropdown menu (⋮)
- Default: `False`

### **Show Next/Finish Button**
- Shows the Next or Finish button (auto-detected based on Flow position)
- Default: `True`

### **Next/Finish Button Label**
- Custom label for Next/Finish button
- Leave blank for auto-detection ("Next" or "Finish" based on Flow position)

### **Next/Finish Button Variant**
- Button style variant
- Options: `base`, `neutral`, `brand`, `brand-outline`, `destructive`, `destructive-text`, `inverse`, `success`
- Default: `neutral`

### **Show Previous Button**
- Shows the Previous button
- Default: `True`

### **Previous Button Label**
- Custom label for Previous button
- Leave blank to use "Previous"

### **Previous Button Variant**
- Button style variant (same options as Next button)
- Default: `neutral`

### **Custom Title/Meta?**
- When `True`, use custom title/meta instead of fetching Rootstock data
- Allows customization of header title and meta text
- Default: `False`

### **Custom Page Title**
- Custom title to show when "Custom Title/Meta?" = True

### **Custom Page Meta**
- Custom meta line to show when "Custom Title/Meta?" = True

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
| `iconName` | String | SLDS icon name (e.g., `utility:help`, `utility:close`). Optional. |
| `iconPosition` | String | Icon placement: `left` or `right`. Default: `left` |
| `visible` | Boolean | Show/hide button conditionally. Default: `true` |
| `url` | String | External URL to open. Use with `target` property. |
| `target` | String | URL target: `_blank` (new tab), `_self` (same window). Used with `url`. |
| `pageReference` | Object | Navigation mixin object for internal Salesforce navigation. |
| `navigate` | String | Flow navigation: `next`, `previous`, or `finish`. |

**Note:** Actions with `navigate`, `url`, or `pageReference` execute immediately. Actions without these properties fire the "Action Clicked" output for custom Flow logic.

---

## JSON Examples

### Example 1: Help Button (Opens URL in New Tab)

```json
[
  {
    "name": "help",
    "label": "Help",
    "iconName": "utility:help",
    "url": "https://help.yourcompany.com",
    "target": "_blank",
    "variant": "neutral"
  }
]
```

### Example 2: Cancel Button (Triggers Flow Logic)

```json
[
  {
    "name": "cancel",
    "label": "Cancel",
    "iconName": "utility:close",
    "variant": "destructive-text"
  }
]
```

**In Flow:**
1. Store `{!HeaderComponent.actionClicked}` in a text variable: `{!varActionClicked}`
2. Add a Decision element after the screen:
   - If `{!varActionClicked}` equals `"cancel"`, route to cancellation logic

### Example 3: Multiple Actions with Conditional Visibility

```json
[
  {
    "name": "save_draft",
    "label": "Save Draft",
    "iconName": "utility:save",
    "variant": "neutral",
    "visible": true
  },
  {
    "name": "submit",
    "label": "Submit",
    "iconName": "utility:check",
    "variant": "brand",
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

**Tip:** Use Flow formulas to set `visible` dynamically:
```json
[
  {
    "name": "delete",
    "label": "Delete",
    "visible": {!isEditMode}
  }
]
```

### Example 4: Navigate to Record Page

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

### Example 5: Mixed Actions (Help, Save Draft, Custom Submit)

```json
[
  {
    "name": "help",
    "label": "Help",
    "iconName": "utility:help",
    "url": "https://docs.yourcompany.com/process",
    "target": "_blank"
  },
  {
    "name": "save_draft",
    "label": "Save Draft",
    "iconName": "utility:save"
  },
  {
    "name": "submit_for_approval",
    "label": "Submit for Approval",
    "iconName": "utility:approval",
    "variant": "brand"
  }
]
```

---

## Common Flow Setup

### Scenario 1: Header with Help Button

**Component Configuration:**
```
Action Links (JSON):
[{"name":"help","label":"Help","iconName":"utility:help","url":"https://help.yourcompany.com","target":"_blank"}]

Show Next/Finish Button: True
Show Previous Button: True
```

### Scenario 2: Custom Submit with Cancel Option

**Component Configuration:**
```
Action Links (JSON):
[{"name":"cancel","label":"Cancel","iconName":"utility:close","variant":"destructive-text"},{"name":"save","label":"Save & Continue","iconName":"utility:check","variant":"brand"}]

Show Next/Finish Button: False
Show Previous Button: True
Custom Actions In Dropdown: False
```

**Flow Setup:**
1. Create Text variable: `varActionClicked`
2. After screen, add Assignment: `{!varActionClicked}` = `{!HeaderComponent.actionClicked}`
3. Add Decision:
   - Outcome 1: `{!varActionClicked}` equals `"cancel"` → Route to cancellation
   - Outcome 2: `{!varActionClicked}` equals `"save"` → Route to save logic
   - Default: Continue to next screen

### Scenario 3: Custom Title and Actions

**Component Configuration:**
```
Custom Title/Meta?: True
Custom Page Title: Order Approval Workflow
Custom Page Meta: Step 2 of 3 - Review Details

Action Links (JSON):
[{"name":"help","label":"Help","iconName":"utility:help","url":"https://help.example.com","target":"_blank"}]
```

---

## Best Practices

✅ **Do:**
- Use descriptive `name` values for actions (lowercase, no spaces)
- Set `target="_blank"` for external URLs to open in new tabs
- Use `iconName` for visual clarity
- Test button visibility logic in sandbox first
- Limit visible actions to 3-4 for clean UI

❌ **Don't:**
- Use duplicate `name` values in the same JSON array
- Forget to handle "Action Clicked" output in your Flow for custom actions
- Mix `navigate`, `url`, and "Action Clicked" patterns in one action (only one will execute)
- Use complex JSON without validating syntax first

---

## Troubleshooting

**Problem:** Action buttons don't appear
- Verify JSON syntax is valid (use a JSON validator)
- Check that `name` and `label` are provided for each action
- Ensure `visible` is not set to `false`

**Problem:** "Action Clicked" output is empty
- Verify the action doesn't have `navigate`, `url`, or `pageReference` (these execute immediately)
- Ensure the button was clicked (check Flow debug logs)

**Problem:** Custom title doesn't show
- Set **Custom Title/Meta?** = `True`
- Provide values in **Custom Page Title** and **Custom Page Meta**

**Problem:** Too many buttons, UI looks crowded
- Reduce **Max Visible Actions** to 2 or 3
- Enable **Custom Actions In Dropdown** to move custom actions to overflow menu

---

## Advanced Tips

### Dynamic JSON with Flow Variables

You can build the JSON dynamically in Flow using Text Template or Formula resources:

**Text Template Example:**
```
[
  {
    "name": "view_record",
    "label": "View {!ObjectLabel}",
    "iconName": "standard:account",
    "pageReference": {
      "type": "standard__recordPage",
      "attributes": {
        "recordId": "{!RecordId}",
        "objectApiName": "{!ObjectApiName}",
        "actionName": "view"
      }
    }
  }
]
```

### Handling Multiple Custom Actions

Use a Decision element with multiple outcomes:

```
Decision: Route Based on Action
  Outcome: Cancel
    Condition: {!varActionClicked} Equals "cancel"
    → Navigate to: Cancellation Screen
  
  Outcome: Save Draft
    Condition: {!varActionClicked} Equals "save_draft"
    → Element: Create Records (save draft)
  
  Outcome: Submit
    Condition: {!varActionClicked} Equals "submit"
    → Element: Submit for Approval
  
  Default Outcome:
    → Continue to Next Screen
```

---

## Technical Details (for Admins/Developers)

- **Component Name:** `alto_flowHeader`
- **Apex Controller:** `FlowHeaderController`
- **Test Class:** `FlowHeaderControllerTest`
- **Navigation:** Uses Lightning Navigation mixin for `pageReference` navigation
- **Targets:** `lightning__FlowScreen`, `lightning__AppPage`, `lightning__RecordPage`
