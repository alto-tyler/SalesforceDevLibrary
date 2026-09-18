import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { parseLookupFilter } from 'c/alto_datatableUtils';

export default class alto_lookupColumnType extends LightningElement {
    @api editable;
    @api fieldName;
    @api keyField;
    @api keyFieldValue;
    @api value;
    @api displayValue;
    @api displayFieldName;   // Row key the datatable reads for the display name -- NOT fieldName + '_name'
    @api objectApiName;
    @api nameField;
    @api lookupFilterFragment;
    @api alignment;
    @api selectedRowKeys = [];

    editMode = false;
    applyToSelected = false;   // "Update N selected items" checkbox state -- reset after each commit/cancel

    _originalValue;    // Snapshot taken on entering edit mode, restored on Cancel
    _originalDisplayValue;
    _pendingName;       // Resolved name for the currently-picked (not yet committed) record

    // Reactive params for the getRecord wire below -- set together in handleChange()
    // to (re)trigger a name lookup for whichever record was just picked.
    resolvingRecordId;
    resolvingFields;
    _pendingRecordId;

    @wire(getRecord, { recordId: '$resolvingRecordId', fields: '$resolvingFields' })
    wiredRecord({ data, error }) {
        if (!this.resolvingRecordId) {
            return;
        }
        if (data) {
            const resolvedName = getFieldValue(data, `${this.objectApiName}.${this.nameField}`);
            this.setPendingSelection(this._pendingRecordId, resolvedName);
        } else if (error) {
            console.warn('[ALTO_DATATABLE] Could not resolve lookup display name', error);
            this.setPendingSelection(this._pendingRecordId, this._pendingRecordId);
        }
    }

    get filter() {
        return parseLookupFilter(this.lookupFilterFragment) || undefined;
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

    // Bump left/right depending on alignment. For center, we align the grid at the cell level.
    get valueClass() {
        let _valueClass = 'slds-col_bump-right slds-align-middle slds-truncate';
        if (this.alignment && this.alignment.includes('right')) {
            _valueClass = 'slds-col_bump-left slds-align-middle slds-truncate';
        } else if (this.alignment && this.alignment.includes('center')) {
            _valueClass = 'slds-align-middle slds-truncate';
        }
        return _valueClass;
    }

    get cellClass() {
        let _cellClass = 'combobox-view__min-height cell__is-editable slds-grid slds-p-vertical_xx-small slds-p-horizontal_x-small slds-var-m-around_xxx-small';
        if (this.alignment && this.alignment.includes('center')) {
            _cellClass += ' slds-grid_align-center';
        }
        return _cellClass;
    }

    handleChange(event) {
        const recordId = event.detail.recordId;
        if (!recordId) {
            this.setPendingSelection(null, null);   // Cleared -- still just pending until Apply
            return;
        }
        // Trigger the getRecord wire above to resolve the picked record's name field so the
        // picker's own pill and (once applied) the datatable both show an accurate label
        // immediately instead of waiting for the next full server refresh.
        this._pendingRecordId = recordId;
        this.resolvingFields = [`${this.objectApiName}.${this.nameField}`];
        this.resolvingRecordId = recordId;
    }

    // Updates what the record-picker itself displays. For a plain single-row edit there's no
    // review step to offer (no Apply/Cancel shown), so this commits immediately, same as
    // before Apply/Cancel existed. Only when this row is part of a multi-row selection is the
    // commit held back for handleApply(), so the user can decide whether to also apply it to
    // the other selected rows before anything is sent to the datatable.
    setPendingSelection(recordId, name) {
        this.value = recordId;
        this._pendingName = name;
        this.resolvingRecordId = undefined;
        this._pendingRecordId = undefined;
        if (!this.isPartOfMultiSelection) {
            this.commit();
        }
    }

    handleApply() {
        this.commit();
    }

    commit() {
        const draftValue = {};
        draftValue[this.fieldName] = this.value;
        draftValue[this.displayFieldName] = this._pendingName;
        draftValue[this.keyField] = this.keyFieldValue;
        this.displayValue = this._pendingName;

        const customEvent = new CustomEvent('lookupvaluechange', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                draftValues: [draftValue],
                applyToOthers: this.isPartOfMultiSelection && this.applyToSelected
            }
        });
        this.dispatchEvent(customEvent);
        this.closeEditor();
    }

    handleCancel() {
        this.value = this._originalValue;
        this.displayValue = this._originalDisplayValue;
        this.closeEditor();
    }

    closeEditor() {
        this.applyToSelected = false;   // Reset for the next edit, same as native inline-edit re-prompts each time
        this.toggleEditMode();
        const picker = this.template.querySelector('lightning-record-picker');
        if (picker) {
            picker.classList.add('slds-hide');
            picker.blur();
        }
    }

    editLookup() {
        this._originalValue = this.value;
        this._originalDisplayValue = this.displayValue;
        this._pendingName = this.displayValue;
        this.toggleEditMode();
        this.template.querySelector('lightning-record-picker').classList.remove('slds-hide');
        this.template.querySelector('lightning-record-picker').focus();
    }

    toggleEditMode() {
        this.editMode = !this.editMode;
        // Host-level hook (not just internal state) so the static-resource stylesheet can
        // target ":has(c-alto_lookup-column-type.is-open)" to elevate only the row/cell whose
        // picker is actually open, instead of every row in an editable lookup column.
        this.classList.toggle('is-open', this.editMode);
    }

    handleMouseDown() {
        // mousedown fires before blur -- flags that whatever blur is about to happen came from
        // a click inside this component (a dropdown option, the clear pill, the checkbox, the
        // Apply/Cancel buttons), so focusout() below knows to leave that click's own handling
        // alone instead of racing it.
        this._interactingInternally = true;
    }

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