import {LightningElement, api} from 'lwc';

export default class alto_comboboxColumnType extends LightningElement {
    @api editable;
    @api fieldName;
    @api keyField;
    @api keyFieldValue;
    @api picklistValues;
    @api value;
    @api alignment
    @api controllerValueIndex;  // {controllerValue: index}, only set when this field has a controller
    @api validForByValue;       // {thisFieldValue: [validControllerIndexes]}, only set when this field has a controller
    @api controllerFieldName;   // This field's controller's API name, only set when this field has a controller
    @api selectedRowKeys = [];
    editMode = false;
    applyToSelected = false;   // "Update N selected items" checkbox state -- reset after each commit/cancel

    _originalValue;    // Snapshot taken on entering edit mode, restored on Cancel

    _controllerValue;
    @api
    get controllerValue() {
        return this._controllerValue;
    }
    set controllerValue(newValue) {
        const previousValue = this.effectiveControllerValue;
        this._controllerValue = newValue;
        this.reactToControllerChange(previousValue);
    }

    // Live (not-yet-saved) edits to OTHER cells in this row, keyed by row key then field API
    // name -- e.g. {[keyFieldValue]: {Pricing_Model__c: 'Fixed Cost'}}. Set by the parent
    // datatable (see alto_datatable.js handleComboValueChange) as the user edits a controller
    // field, WITHOUT touching mydata/data (which would reset the base lightning-datatable's
    // pending draftValues and silently break Save, including navigateNextOnSave). Lets this
    // dependent picklist's options recalculate immediately, before Save.
    _liveControllerValues;
    @api
    get liveControllerValues() {
        return this._liveControllerValues;
    }
    set liveControllerValues(newValue) {
        const previousValue = this.effectiveControllerValue;
        this._liveControllerValues = newValue;
        this.reactToControllerChange(previousValue);
    }

    // The controller's value to filter this field's options against: a live (unsaved) edit to
    // it in this same row takes priority over the last-saved value bound from row data.
    get effectiveControllerValue() {
        const rowOverrides = this._liveControllerValues && this._liveControllerValues[this.keyFieldValue];
        if (rowOverrides && this.controllerFieldName && Object.prototype.hasOwnProperty.call(rowOverrides, this.controllerFieldName)) {
            return rowOverrides[this.controllerFieldName];
        }
        return this._controllerValue;
    }

    // If the controller's effective value just changed and the current selection is no longer
    // valid for it, clear it and notify the datatable, mirroring standard Salesforce edit-form
    // behavior for dependent picklists. Skips the initial assignment (previousValue undefined).
    reactToControllerChange(previousValue) {
        const newValue = this.effectiveControllerValue;
        if (previousValue !== undefined && previousValue !== newValue && this.value && !this.isCurrentValueValid()) {
            this.clearInvalidValue();
        }
    }

    get isDependent() {
        return !!(this.controllerValueIndex && this.validForByValue);
    }

    isValueValidForController(value) {
        const controllerValue = this.effectiveControllerValue;
        if (controllerValue === undefined || controllerValue === null || controllerValue === '') {
            return false;   // No controller value selected -- no dependent values are valid
        }
        const controllerIndex = this.controllerValueIndex[controllerValue];
        if (controllerIndex === undefined) {
            return false;
        }
        const validIndexes = this.validForByValue[value] || [];
        return validIndexes.includes(controllerIndex);
    }

    isCurrentValueValid() {
        if (!this.isDependent || this.value === '') {
            return true;    // Not a dependent field, or blank/None is always allowed
        }
        return this.isValueValidForController(this.value);
    }

    clearInvalidValue() {
        this.value = '';
        let draftValue = {};
        draftValue[this.fieldName] = this.value;
        draftValue[this.keyField] = this.keyFieldValue;
        this.dispatchEvent(new CustomEvent('combovaluechange', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                draftValues: [draftValue]
            }
        }));
    }

    get options() {
        let _options = [];
        for(const key in this.picklistValues) {
            let value = this.picklistValues[key];
            if (this.isDependent && value !== '' && !this.isValueValidForController(value)) {
                continue;   // Filtered out by the controlling field's current value
            }
            let option = {};
            // option.label = this.picklistValues[key];
            // option.value = key;
            option.label = key;
            option.value = value;
            _options.unshift(option);
        }
        return _options
    }

    // View-mode display text. `value` always holds the picklist's raw API value (from row data,
    // or from lightning-combobox's change event) -- resolve it to its label here for display.
    get displayLabel() {
        if (this.value === '' || this.value === undefined || this.value === null) {
            return this.value;
        }
        const matchingLabel = Object.keys(this.picklistValues || {}).find(
            (label) => this.picklistValues[label] === this.value
        );
        return matchingLabel !== undefined ? matchingLabel : this.value;
    }

    // True when this row is one of more than one currently checkbox-selected rows --
    // only then does the "Update N selected items" checkbox make sense to offer.
    get isPartOfMultiSelection() {
        return !!(this.selectedRowKeys
            && this.selectedRowKeys.length > 1
            && this.selectedRowKeys.includes(this.keyFieldValue));
    }

    get applyToSelectedLabel() {
        return `Update ${this.selectedRowKeys ? this.selectedRowKeys.length : 0} selected items`;
    }

    handleApplyToSelectedChange(event) {
        this.applyToSelected = event.target.checked;
    }

    //bump left/right depending on alignment. For center, we will align the grids on a the cell level
    get valueClass() {
        let _valueClass = "slds-col_bump-right slds-align-middle slds-truncate";
        if(this.alignment.includes("right")) {
            _valueClass = "slds-col_bump-left slds-align-middle slds-truncate";
        } else if(this.alignment.includes("center")) {
            _valueClass = "slds-align-middle slds-truncate";
        }
        return _valueClass;
    }

    //if alignment is center, we align the grid to center
    get cellClass() {
        let _cellClass = "combobox-view__min-height cell__is-editable slds-grid slds-p-vertical_xx-small slds-p-horizontal_x-small slds-var-m-around_xxx-small";
        if(this.alignment.includes("center")) {
            _cellClass += " slds-grid_align-center";
        }
        return _cellClass;
    }

    handleChange(event) {
        this.setPendingSelection(event.detail.value);
    }

    // For a plain single-row edit there's no review step to offer (no Apply/Cancel shown), so
    // this commits immediately, same as before Apply/Cancel existed. Only when this row is part
    // of a multi-row selection is the commit held back for handleApply(), so the user can decide
    // whether to also apply it to the other selected rows before anything is sent to the datatable.
    setPendingSelection(newValue) {
        this.value = newValue;
        if (!this.isPartOfMultiSelection) {
            this.commit();
        }
    }

    handleApply() {
        this.commit();
    }

    commit() {
        //We will mimic the standard oncellchange event from lightning datatable
        let draftValue = {};
        draftValue[this.fieldName] = this.value;
        draftValue[this.keyField] = this.keyFieldValue;

        const customEvent = new CustomEvent('combovaluechange', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                draftValues: [draftValue],
                applyToOthers: this.isPartOfMultiSelection && this.applyToSelected
            },
        });
        this.dispatchEvent(customEvent)

        this.closeEditor();
    }

    handleCancel() {
        this.value = this._originalValue;
        this.closeEditor();
    }

    closeEditor() {
        this.applyToSelected = false;   // Reset for the next edit, same as native inline-edit re-prompts each time
        this.toggleEditMode();
        //remove combobox and remove focus
        this.template.querySelector("lightning-combobox").classList.add("slds-hide");
        this.template.querySelector("lightning-combobox").blur();
    }

    editCombobox(){
        this._originalValue = this.value;
        this.toggleEditMode();
        //show the combobox & focus on it
        this.template.querySelector("lightning-combobox").classList.remove("slds-hide");
        this.template.querySelector("lightning-combobox").focus();
    }

    toggleEditMode() {
        this.editMode = !this.editMode;
    }

    handleMouseDown() {
        // mousedown fires before blur -- flags that whatever blur is about to happen came from
        // a click inside this component (a dropdown option, the checkbox, the Apply/Cancel
        // buttons), so focusout() below knows to leave that click's own handling alone instead
        // of racing it.
        this._interactingInternally = true;
    }

    //remove combobox when not focused
    focusout() {
        // Deferred so a click on something *inside* this component finishes its own handling
        // first -- otherwise the blur that click causes would immediately (and wrongly) cancel
        // the edit before that click even takes effect. Clicking fully away from the cell
        // without an explicit Apply cancels the pending edit, same as native inline editing.
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            if (this._interactingInternally) {
                this._interactingInternally = false;
                return;
            }
            if (this.editMode) {
                this.handleCancel();
            }
        }, 300);
    }
}