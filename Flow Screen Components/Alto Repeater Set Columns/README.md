# Alto Repeater Set Columns — Flow User Guide

A responsive column layout component for Flow Repeaters that enables multi-column displays with configurable breakpoints. This component solves the limitation where Flow Repeaters display items in a single column by allowing you to set custom column counts for different screen sizes.

**Key Features:**
- Set different column counts for 4 screen sizes (XL, Large, Medium, Small)
- Responsive design adapts to device width automatically
- Works with any Flow Repeater content
- No UI displayed (invisible component)
- Configurable breakpoints: 1440px, 1024px, 768px
- Supports 1-12 columns per breakpoint

---

## Use Case: Multi-Column Repeater Layouts

Flow Repeaters display items vertically in a single column by default. This component allows you to create responsive multi-column layouts, perfect for displaying cards, tiles, or form fields side-by-side.

**Example Scenarios:**
- Display product catalog in 3 columns on desktop, 2 on tablet, 1 on mobile
- Show line items in a 4-column grid for wide screens
- Create responsive card layouts that adapt to screen size
- Display form fields in multiple columns within a repeater

---

## Adding to Your Flow

1. In Flow Builder, add a **Repeater** component to your screen.
2. Add your content components inside the repeater (e.g., Display Text, Input Fields).
3. Search for **"Alto Repeater Set Columns"** and drag it **inside the repeater** (it should appear as one of the repeater items).
4. Configure the column counts for each screen size.

⚠️ **Important:** This component must be placed **inside the repeater** region, not outside it.

---

## Flow Properties

### **Column Configuration**

**Columns (XL: 1440px+)**
- Number of columns for extra-large screens
- Default: `2`
- Range: 1-12
- Use case: Desktop monitors, large displays
- Example: `4` columns for wide dashboard layouts

**Columns (Large: 1024-1439px)**
- Number of columns for large screens
- Default: `2`
- Range: 1-12
- Use case: Standard desktop, laptop screens
- Example: `3` columns for typical laptop displays

**Columns (Medium: 768-1023px)**
- Number of columns for medium screens
- Default: `2`
- Range: 1-12
- Use case: Tablets in landscape, small laptops
- Example: `2` columns for tablet landscape view

**Columns (Small: below 768px)**
- Number of columns for small screens
- Default: `1`
- Range: 1-12
- Use case: Phones, tablets in portrait
- Example: `1` column for mobile-friendly single-column layout

---

## Screen Size Breakpoints

| Breakpoint | Screen Width | Common Devices | Typical Use |
|------------|--------------|----------------|-------------|
| **XL** | 1440px and up | Large monitors, 4K displays | 3-4 columns |
| **Large** | 1024px - 1439px | Desktops, laptops | 2-3 columns |
| **Medium** | 768px - 1023px | Tablets landscape, small laptops | 2 columns |
| **Small** | Below 768px | Phones, tablets portrait | 1 column |

---

## Example Flow Configurations

### Example 1: Product Catalog Grid

**Scenario:** Display products in a responsive grid - 4 columns on desktop, 2 on tablet, 1 on mobile.

**Setup:**
1. Create a collection of Product records
2. Add a **Repeater** component with your product collection
3. Inside the repeater, add Display components for product details (image, name, price)
4. Add **Alto Repeater Set Columns** inside the repeater:
   - **Columns (XL):** `4`
   - **Columns (Large):** `3`
   - **Columns (Medium):** `2`
   - **Columns (Small):** `1`

**Result:** Products display in a responsive grid that adapts to screen size.

---

### Example 2: Form Fields in Columns

**Scenario:** Display form inputs in 2 columns on desktop, 1 column on mobile.

**Setup:**
1. Create a collection of field definitions or records to edit
2. Add a **Repeater** component
3. Inside the repeater, add input fields (Text Input, Number Input, etc.)
4. Add **Alto Repeater Set Columns**:
   - **Columns (XL):** `2`
   - **Columns (Large):** `2`
   - **Columns (Medium):** `2`
   - **Columns (Small):** `1`

**Result:** Form fields appear side-by-side on larger screens, stack vertically on mobile.

---

### Example 3: Dashboard Cards

**Scenario:** Display metric cards in a 3-column layout on desktop.

**Setup:**
1. Create a collection of metric/summary records
2. Add a **Repeater** component
3. Inside repeater, add components to display card content (title, value, icon)
4. Add **Alto Repeater Set Columns**:
   - **Columns (XL):** `3`
   - **Columns (Large):** `3`
   - **Columns (Medium):** `2`
   - **Columns (Small):** `1`

**Result:** Metrics display in responsive card grid.

---

### Example 4: Line Item Table

**Scenario:** Show invoice line items with multiple fields in a wide table format.

**Setup:**
1. Create line item collection (Product, Quantity, Price, Total)
2. Add **Repeater**
3. Add Display Text components for each field
4. Add **Alto Repeater Set Columns**:
   - **Columns (XL):** `4` (one column per field)
   - **Columns (Large):** `4`
   - **Columns (Medium):** `2` (field name + value pairs)
   - **Columns (Small):** `1` (stacked)

**Result:** Line items display in table-like format on desktop, adapt to mobile.

---

## Important Notes

### Placement

⚠️ **Critical:** The component **must be placed inside the repeater region**. If placed outside, it will not affect the repeater layout.

In Flow Builder:
1. Expand the Repeater component
2. Drag components into the repeater area
3. Add Alto Repeater Set Columns as one of the repeater items

### Column Width Calculation

- Columns are distributed evenly across available width
- Width = 100% / number of columns
- Example: 3 columns = 33.33% width each
- All repeater items will have the same width per row

### Content Considerations

- Ensure content fits within column width at each breakpoint
- Test with actual content to verify responsive behavior
- Consider minimum content width when choosing column counts
- Long text may wrap or truncate depending on column width

### No Output Values

This component doesn't produce any output values - it only affects the visual layout of the repeater.

### Browser Compatibility

Works with all modern browsers supporting CSS media queries and flexbox.

---

## Troubleshooting

**Columns not applying:**
- Verify component is placed **inside** the repeater, not outside
- Check browser console for any errors
- Refresh the Flow screen
- Ensure column values are set (defaults: 2, 2, 2, 1)

**Layout breaks on certain screen sizes:**
- Review breakpoint configuration - ensure values make sense progressively
- Test on actual devices or using browser responsive design mode
- Reduce column count for smaller breakpoints

**Content overlapping or squished:**
- Content is too wide for the column width
- Reduce number of columns for that breakpoint
- Adjust content component widths/padding
- Test with realistic content sizes

**Component not found in Flow Builder:**
- Verify deployment was successful
- Refresh Flow Builder
- Check that `.cmp-meta.xml` includes `implements="lightning:availableForFlowScreens"`

---

## Best Practices

### Progressive Column Reduction
Design for mobile-first, progressively adding columns for larger screens:
- Small: 1 column (mobile)
- Medium: 2 columns (tablet)
- Large: 3 columns (laptop)
- XL: 4 columns (desktop)

### Content-First Approach
Choose column counts based on content minimum width:
- Complex cards with images: 1-3 columns max
- Simple text fields: 2-4 columns
- Icon + label combinations: 3-6 columns

### Testing
Always test your layout at different screen sizes:
1. Use browser DevTools responsive mode
2. Test on actual devices when possible
3. Verify content doesn't overflow or break at breakpoints

### Performance
- Component uses CSS injection for styling (minimal performance impact)
- No API calls or server interactions
- Lightweight and efficient

---

## Technical Details

- **Component Type:** Aura Component
- **API Name:** `alto_repeaterSetColumns`
- **Namespace:** None (can be deployed to any org)
- **API Version:** 65.0
- **Dependencies:** None
- **Mechanism:** Injects responsive CSS targeting the parent repeater container

---

## How It Works

1. Component initializes when repeater loads
2. Finds parent `flowruntime-list-container` element
3. Adds unique class to parent for targeting
4. Injects responsive CSS with media queries
5. CSS applies width percentages to repeater items
6. Layout responds automatically to screen size changes

---

## Installation

Deploy this component to your Salesforce org using the Salesforce CLI:

```bash
sf project deploy start --source-dir "Flow Screen Components/Alto Repeater Set Columns/force-app"
```

Or use the manifest file:

```bash
sf project deploy start --manifest "Flow Screen Components/Alto Repeater Set Columns/manifest/package.xml"
```

---

## Support

For issues, questions, or feature requests, please refer to the main repository documentation or create an issue in the GitHub repository.

---

## Version History

- **v1.0** - Initial release with responsive 4-breakpoint column layout support

---

## Limitations

- Only affects visual layout (no data manipulation)
- Requires modern browser with CSS media query support
- Must be used inside Flow Repeater component
- All items in repeater row have equal width (no variable column spans)
- Column configuration applies to entire repeater (cannot vary per item)
