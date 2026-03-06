# Alto Disable Pull To Refresh — User Guide

This invisible utility component disables the pull-to-refresh gesture on Salesforce mobile apps. Simply add it once to any Flow screen or Lightning page to prevent users from accidentally refreshing and losing their progress.

**Key Features:**
- Disables pull-to-refresh on mobile devices
- Disables pull-to-show-more gesture
- Add once per screen for full mobile control
- Invisible (no UI rendered)
- Works on Flow screens and Lightning pages
- Optionally enable gestures selectively

---

## Why Use This Component?

On Salesforce mobile apps, users can pull down from the top of the screen to refresh the page. While useful in some contexts, this can be problematic in Flows or custom pages where:

- Users accidentally refresh and lose unsaved data
- Multi-step processes are interrupted
- Data entry progress is lost
- Forms are cleared unexpectedly

This component prevents these issues by disabling the refresh gesture for the current page.

---

## Adding to Your Flow

1. In Flow Builder, drag a **Screen** element onto your canvas.
2. In the left panel under **Components**, search for **"Alto Disable Pull To Refresh"** and drag it onto your screen.
3. By default, both pull-to-refresh and pull-to-show-more are **disabled** — you're done!
4. (Optional) Configure the properties if you want to selectively enable gestures.

---

## Flow Properties

### **Enable Pull To Refresh**
- Controls whether the pull-to-refresh gesture is enabled on mobile
- Default: `False` (disabled)
- Set to `True` if you want to re-enable pull-to-refresh on this specific screen

### **Enable Pull To Show More**
- Controls whether the pull-to-show-more gesture is enabled on mobile
- Default: `False` (disabled)
- Set to `True` if you want to re-enable pull-to-show-more on this specific screen

---

## Common Use Cases

### Example 1: Disable Refresh in Data Entry Flow

**Scenario:** You have a multi-screen Flow where users enter order details. You want to prevent accidental refreshes that would lose their progress.

**Setup:**
1. Add a Screen element
2. Drag **Alto Disable Pull To Refresh** onto the screen
3. Add your form fields and other components
4. No configuration needed — refreshing is disabled by default

### Example 2: Disable on First Screen, Enable on Confirmation Screen

**Scenario:** You want to disable refresh during data entry but allow it on the final confirmation screen.

**First Screen:**
```
Add Component: Alto Disable Pull To Refresh
  Enable Pull To Refresh: False (default)
  Enable Pull To Show More: False (default)
```

**Confirmation Screen:**
```
Add Component: Alto Disable Pull To Refresh
  Enable Pull To Refresh: True
  Enable Pull To Show More: True
```

### Example 3: Lightning Record Page with Custom Form

**Scenario:** You've built a custom Lightning record page with complex interactions and want to prevent accidental refreshes.

**Setup:**
1. Open the Lightning App Builder
2. Add **Alto Disable Pull To Refresh** component to your page
3. The component is invisible and will automatically disable gestures

---

## Best Practices

✅ **Do:**
- Add this component to Flow screens with significant data entry
- Place it on screens where refresh would cause data loss
- Use on multi-step processes where maintaining state is critical
- Add to Lightning pages with custom interactions

❌ **Don't:**
- Add multiple instances to the same screen (unnecessary)
- Forget to test on mobile devices to verify behavior
- Use on screens where refreshing is expected/desired

---

## Technical Details

- **Component Name:** `alto_disablePullToRefresh`
- **Targets:** Flow Screen, App Page, Record Page, Home Page
- **API Version:** 66.0
- **Visibility:** Invisible component (no UI rendered)
- **Event:** Dispatches `updateScrollSettings` event to Salesforce mobile container

### How It Works

When the component loads (`connectedCallback`), it dispatches a custom `updateScrollSettings` event that bubbles up to the Salesforce mobile app container. The mobile app receives this event and updates its scroll behavior accordingly.

This is a standard Salesforce mobile API pattern for controlling native mobile behaviors from Lightning components.

### Browser/Desktop Behavior

This component has no effect on desktop browsers or Salesforce Classic. Pull-to-refresh is a mobile-specific gesture, so the component is essentially invisible on non-mobile platforms.

### Mobile App Compatibility

- **Salesforce Mobile App:** ✅ Fully supported
- **Mobile browser (Safari/Chrome):** ⚠️ Limited support (depends on browser implementation)
- **Lightning Experience desktop:** ❌ No effect (not applicable)

---

## Troubleshooting

**Problem:** Pull-to-refresh still works after adding the component

**Solutions:**
- Verify you're testing on the Salesforce Mobile App (not a mobile browser)
- Check that **Enable Pull To Refresh** is set to `False`
- Ensure the component is actually on the current screen
- Try navigating away and back to the screen to reinitialize

**Problem:** Component not appearing in Flow Builder

**Solution:**
- Verify the component is deployed to your org
- Check that your Flow's API version is 66.0 or higher
- Refresh Flow Builder or clear browser cache

---

## Deployment

This component includes:
- `README.md` - This documentation
- `force-app/main/default/lwc/alto_disablePullToRefresh/` - Lightning Web Component
- `manifest/package.xml` - Deployment manifest

See the [main repository README](../../) for detailed deployment instructions.

---

## Version History

- **v1.0** (March 2026) - Initial release
  - Disable pull-to-refresh gesture
  - Disable pull-to-show-more gesture
  - Support for Flow screens and Lightning pages
