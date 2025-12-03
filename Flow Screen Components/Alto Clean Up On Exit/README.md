# Cleanup On Exit — Flow User Guide

This component automatically deletes temporary or draft records when users navigate away from your Flow screen or close the browser. Perfect for cleaning up records that shouldn't be saved if the user abandons the Flow.

**Use Case:** Remove temporary records created during a Flow (e.g., draft submissions, preview records, or records created for validation purposes).

---

## Adding to Your Flow

1. In Flow Builder, drag a **Screen** element onto your canvas.
2. In the left panel under **Components**, search for **"Cleanup On Exit"** and drag it onto your screen.
3. Configure the properties (see below).

---

## Flow Properties (What to Configure)

When you add the component to a Flow screen, you'll see these properties:

### **Record ID to Delete** *(required)*
- The ID of the record you want to delete when the user leaves.
- Example: `{!TempRecordId}` or `{!CreatedRecord.Id}`

### **Delete On Navigate**
- **When:** User clicks Back, Next, or navigates to another screen within the Flow.
- **Recommended:** Set to `True` for most Flow use cases.
- **Default:** False

### **Delete On Page Close**
- **When:** User closes the browser tab/window or refreshes the page.
- **Note:** This is "best effort" — the browser may not always complete the delete before closing.
- **Recommended:** Use only if you need cleanup on browser close; otherwise rely on "Delete On Navigate".
- **Default:** False

### **Cascade Delete Children**
- If `True`, the component will automatically delete Master-Detail child records before deleting the parent.
- Only affects true parent-child (Master-Detail) relationships, not lookups.
- **Default:** False

### **Lookup Child Relationships**
- For lookup relationships (not Master-Detail), specify child relationship names to delete.
- **Format:** Comma-separated list of relationship API names ending in `__r`
- **Example:** `Contacts,Custom_Children__r,namespace__Custom_Objects__r`
- **How to find:** On the child object's lookup field, look for "Child Relationship Name".

### **Show Debug Messages**
- Enable browser console logging for troubleshooting.
- **Recommended:** Set to `True` during development/testing.
- **Default:** False

---

## Example Flow Setup

### Scenario: Create a temporary Account for preview, then delete it if user exits

1. **Create Records** element:
   - Create an Account record
   - Store the ID in `{!TempAccountId}`

2. **Screen** element:
   - Add form fields to show/edit the Account
   - Add **Cleanup On Exit** component with:
     - **Record ID to Delete:** `{!TempAccountId}`
     - **Delete On Navigate:** `True`
     - **Delete On Page Close:** `True`

3. **What happens:**
   - If user clicks **Next** or **Previous**, the component automatically deletes the record
   - If user clicks **Finish** or navigates away, the record is deleted
   - The deletion happens before moving to the next screen

---

## How It Works (Behind the Scenes)

1. The component listens for navigation events (Back, Next, screen changes).
2. When triggered, it calls Apex to delete the specified record.
3. If configured, it will:
   - Delete Master-Detail children (if **Cascade Delete Children** = True)
   - Delete specified lookup children (via **Lookup Child Relationships**)
   - Delete the parent record

**Important:** The running user must have Delete permission on the target object and child objects.

---

## Best Practices

✅ **Do:**
- Use **Delete On Navigate** for reliable cleanup within Flows
- Test in a Sandbox first
- Enable **Show Debug Messages** during development
- Use **Cascade Delete Children** for Master-Detail relationships
- Specify **Lookup Child Relationships** for lookup-based children

❌ **Don't:**
- Rely solely on **Delete On Page Close** for critical cleanup (browser behavior varies)
- Forget to grant Delete permissions to users running the Flow
- Use this for permanent records — only use for temporary/draft records

---

## Troubleshooting

**Problem:** Record doesn't get deleted
- Check debug logs (enable **Show Debug Messages**)
- Verify the user has Delete permission on the object
- Ensure the Record ID is valid

**Problem:** Parent record fails to delete due to child records
- Enable **Cascade Delete Children** for Master-Detail relationships
- Add child relationship names to **Lookup Child Relationships** for lookup relationships

**Problem:** Validation errors prevent deletion
- This is expected behavior — validation rules still apply

---

## Technical Details (for Admins/Developers)

- **Component Name:** `alto_cleanupOnExit`
- **Apex Controller:** `CleanupOnExitController`
- **Test Class:** `CleanupOnExitControllerTest`
- **Deployment:** Deploy via Salesforce CLI or change sets
