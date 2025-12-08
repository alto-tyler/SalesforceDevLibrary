
# Alto Flow Modal Width Override

A Flow screen component that allows you to override the default modal width for Flow screens in Salesforce. This is especially useful when your Flow is launched as a Quick Action and opens in a modal dialog, letting you provide more space for custom screens such as datatables, large forms, or embedded components.

## Features

- **Custom Modal Width**: Set a specific width for the Flow modal dialog (e.g., 600px, 900px, 1200px, or any valid CSS width value)
- **Easy Configuration**: Add the component to your Flow screen and set the desired width property
- **No Code Required**: Works declaratively in Flow Builder
- **Responsive**: Supports both fixed and percentage-based widths
- **Scoped**: Only affects the Flow screen where the component is used

---

## How It Works

1. Add the **Alto Flow Modal Width Override** component to your Flow screen.
2. Set the **Modal Width** property to your desired value (e.g., `900px`, `80%`).
3. When the Flow screen is displayed, the modal dialog will use the specified width.

---

## Input Properties

| Property      | Type   | Label        | Required | Description                                      |
|--------------|--------|--------------|----------|--------------------------------------------------|
| Modal Width  | String | Modal Width  | ✅ Yes   | The width to apply to the Flow modal (e.g., `900px`, `80%`). |

---

## Example Usage

- **Wider Datatable**: Set Modal Width to `1200px` for screens with datatables.
- **Large Forms**: Use `80%` to make the modal nearly full screen for complex forms.
- **Default**: If not set, the Flow uses Salesforce's standard modal width.

---

## Limitations

- Only affects the Flow screen where the component is placed
- May not work if Salesforce changes modal structure in future releases
- Does not affect embedded Flows or non-modal screens

---

## Deployment

1. Deploy the Aura component to your org.
2. Add **Alto Flow Modal Width Override** to your Flow screen.
3. Set the **Modal Width** property as needed.

---

## Support

For issues or questions:
- Check the component is deployed and added to the correct Flow screen
- Ensure the width value is a valid CSS width (e.g., `900px`, `80%`)
- Contact the maintainer for further assistance
