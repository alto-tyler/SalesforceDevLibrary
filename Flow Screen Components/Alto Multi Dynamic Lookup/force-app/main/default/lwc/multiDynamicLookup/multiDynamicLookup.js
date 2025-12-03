import { LightningElement, api } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class MultiDynamicLookup extends LightningElement {
    // Display
    @api label = 'Search and Select';
    @api placeholder = 'Search...';
    @api iconName = 'standard:account';
    
    // Object Configuration
    @api objectApiName;
    @api displayFieldName = 'Name';
    @api fieldApiName = 'Name';
    @api valueFieldName = 'Id';
    
    // Query Configuration
    @api maxResults = 200;
    @api whereClause = '';
    @api sortBy = '';
    @api sortDirection = 'asc';
    @api valueMatchType = 'partial';
    
    // Parent Filter
    @api parentInitialized;
    @api parentFilterField = '';
    @api parentFilterValue = '';
    @api parentFilterOperator = '=';
    @api disableOnNoParentValue = false;
    
    // Behavior
    @api required = false;
    @api disabled = false;
    @api allowDisplayFieldMatch = false;
    @api relativeDropdown = false;
    @api populateOnTab = false;
    
    // Barcode Scanning
    @api allowBarcodeScanning = false;
    @api scanButtonIcon = 'utility:scan';
    
    selectedItems = [];
    _selectedValues = '';
    _selectedNames = '';
    _selectedNamesCollection = [];
    _selectedValuesCollection = [];
    _initializedFromFlow = false;
    
    @api
    get selectedValues() {
        return this._selectedValues;
    }

    // allow Flow to set selectedValues (semicolon string) and rehydrate component
    set selectedValues(val) {
        this._selectedValues = val;
        this._initializedFromFlow = false;
        this.rehydrateFromFlowInputs();
    }

    @api
    get selectedNames() {
        return this._selectedNames;
    }

    // allow Flow to set selectedNames (semicolon string) and rehydrate component
    set selectedNames(val) {
        this._selectedNames = val;
        this._initializedFromFlow = false;
        this.rehydrateFromFlowInputs();
    }
    
    @api
    get selectedValuesCollection() {
        return this._selectedValuesCollection;
    }

    // allow Flow to set selectedValuesCollection (array) and rehydrate component
    set selectedValuesCollection(val) {
        this._selectedValuesCollection = Array.isArray(val) ? val : (typeof val === 'string' && val.length ? val.split(';').map(s => s.trim()).filter(Boolean) : []);
        this._initializedFromFlow = false;
        this.rehydrateFromFlowInputs();
    }

    @api
    get selectedNamesCollection() {
        return this._selectedNamesCollection;
    }

    // allow Flow to set selectedNamesCollection (array) and rehydrate component
    set selectedNamesCollection(val) {
        this._selectedNamesCollection = Array.isArray(val) ? val : (typeof val === 'string' && val.length ? val.split(';').map(s => s.trim()).filter(Boolean) : []);
        this._initializedFromFlow = false;
        this.rehydrateFromFlowInputs();
    }
    
    @api
    validate() {
        if (this.required && this.selectedItems.length === 0) {
            return {
                isValid: false,
                errorMessage: 'Please select at least one item.'
            };
        }
        return { isValid: true };
    }
    
    connectedCallback() {
        // initialize from Flow inputs if provided
        this.rehydrateFromFlowInputs();
    }
    
    // Rehydrate internal selectedItems from Flow inputs (values + optional names)
    rehydrateFromFlowInputs() {
        if (this._initializedFromFlow) return;

        // derive arrays: prefer collection inputs, fallback to semicolon strings
        const vals = Array.isArray(this._selectedValuesCollection) && this._selectedValuesCollection.length
            ? this._selectedValuesCollection.slice()
            : (this._selectedValues && typeof this._selectedValues === 'string'
                ? this._selectedValues.split(';').map(s=>s.trim()).filter(Boolean)
                : []);

        const names = Array.isArray(this._selectedNamesCollection) && this._selectedNamesCollection.length
            ? this._selectedNamesCollection.slice()
            : (this._selectedNames && typeof this._selectedNames === 'string'
                ? this._selectedNames.split(';').map(s=>s.trim()).filter(Boolean)
                : []);

        if (vals.length) {
            // build selectedItems preserving order; if a name exists at same index use it, else fallback to value
            this.selectedItems = vals.map((v, idx) => {
                const label = (names[idx]) ? names[idx] : v;
                return {
                    name: v,
                    label: label,
                    displayValue: label,
                    value: v,
                    iconName: this.iconName
                };
            });

            // sync backing fields and notify Flow (ensure flows get normalized values/names)
            this._selectedValues = this.selectedItems.map(i => i.value).join(';');
            this._selectedValuesCollection = this.selectedItems.map(i => i.value);

            this._selectedNames = this.selectedItems.map(i => i.displayValue || i.label || i.value).join(';');
            this._selectedNamesCollection = this.selectedItems.map(i => i.displayValue || i.label || i.value);

            try {
                this.dispatchEvent(new FlowAttributeChangeEvent('selectedValues', this._selectedValues));
                this.dispatchEvent(new FlowAttributeChangeEvent('selectedValuesCollection', this._selectedValuesCollection));
                this.dispatchEvent(new FlowAttributeChangeEvent('selectedNames', this._selectedNames));
                this.dispatchEvent(new FlowAttributeChangeEvent('selectedNamesCollection', this._selectedNamesCollection));
            } catch (e) {
                // Flow may not be ready yet — harmless
            }
        }

        this._initializedFromFlow = true;
    }
    
    get selectedOptions() {
        return this.selectedItems.map(item => ({
            label: item.displayValue || item.label || item.value,
            value: item.recordId || item.value
        }));
    }
    
    get hasSelectedItems() {
        return this.selectedItems.length > 0;
    }
    
    get isParentInitialized() {
        // If no parent filter field is specified, parent initialization is not needed
        if (!this.parentFilterField) {
            return true;
        }
        return this.parentInitialized !== false;
    }
    
    updateOutputs() {
        try {
            // Create semicolon-separated string
            const valueString = this.selectedItems.map(item => item.value).join(';');
            const valueArray = this.selectedItems.map(item => item.value);
            const nameString = this.selectedItems.map(item => item.displayValue || item.label || item.value).join(';');
            const nameArray = this.selectedItems.map(item => item.displayValue || item.label || item.value);
            
            // update backing fields
            this._selectedValues = valueString;
            this._selectedValuesCollection = valueArray;
            this._selectedNames = nameString;
            this._selectedNamesCollection = nameArray;
            
            // Notify Flow of changes
            this.dispatchEvent(new FlowAttributeChangeEvent('selectedValues', valueString));
            this.dispatchEvent(new FlowAttributeChangeEvent('selectedValuesCollection', valueArray));
            this.dispatchEvent(new FlowAttributeChangeEvent('selectedNames', nameString));
            this.dispatchEvent(new FlowAttributeChangeEvent('selectedNamesCollection', nameArray));
        } catch (error) {
            console.error('Error updating outputs:', error);
        }
    }

    handleLookupSelect(event) {
        const record = event.detail.record;
        
        if (!record) {
            return;
        }
        
        const value = record[this.valueFieldName];
        const label = record[this.displayFieldName];
        
        // Check for duplicates
        const exists = this.selectedItems.some(item => item.value === value);
        
        if (!exists) {
            this.selectedItems = [...this.selectedItems, {
                name: value,
                label: label,
                displayValue: label,
                value: value,
                iconName: this.iconName
            }];
            
            this.updateOutputs();
        } else {
            // still clear lookup so user can search again
            this.updateOutputs();
        }
        
        // Clear the lookup
        Promise.resolve().then(() => {
            const lookupComponent = this.template.querySelector('c-alto_dynamic-lookup');
            if (lookupComponent && typeof lookupComponent.handleRemoveSelection === 'function') {
                try {
                    lookupComponent.handleRemoveSelection();
                } catch (e) {
                    // swallow child errors
                }
            }
            // try to blur input to avoid focus issues (guarded)
            if (lookupComponent && typeof lookupComponent.blur === 'function') {
                try { lookupComponent.blur(); } catch (e) {}
            } else {
                // try blurring host input if available
                const inputEl = this.template.querySelector('c-alto_dynamic-lookup lightning-input, c-alto_dynamic-lookup input');
                if (inputEl && typeof inputEl.blur === 'function') {
                    try { inputEl.blur(); } catch (e) {}
                }
            }
        });
    }

    handleRemove(event) {
        const itemName = event.detail.name;
        this.selectedItems = this.selectedItems.filter(item => item.name !== itemName);
        
        this.updateOutputs();
    }

    handleClearAll() {
        this.selectedItems = [];
        
        this.updateOutputs();
    }
}