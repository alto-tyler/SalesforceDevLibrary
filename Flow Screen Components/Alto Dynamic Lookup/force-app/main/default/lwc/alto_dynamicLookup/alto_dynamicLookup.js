import { LightningElement, track, api } from 'lwc';
import queryRecords from '@salesforce/apex/DynamicLookupQueryBuilder.queryRecords';
import getSObjectDetails from '@salesforce/apex/DynamicLookupQueryBuilder.getSObjectDetails';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { getBarcodeScanner } from 'lightning/mobileCapabilities';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LABELS } from './alto_dynamicLookupUtils';


const LOG_PREFIX = '[AltoDynamicLookup]';

export default class AltoDynamicLookup extends LightningElement {
    searchType = 'live'; // Default search type
    barcodeScanner;

    logMessages = '';
    showTooltip = false;

    // API properties
    @api label; // Label for the input field
    @api helpText; // Help text displayed in tooltip
    @api placeholder = 'Search...'; // Placeholder text for the input field
    @api iconName = 'standard:account'; // Icon name for the input field
    @api displayFieldName = 'Name'; // Field to display in the dropdown
    @api fieldApiName = 'Name'; // Field to search
    @api maxResults = 200; // Max results in dropdown
    @api valueFieldName = 'Id'; // Field used as value in dropdown
    @api valueMatchType = 'partial'; // Match type for value field
    @api allowDisplayFieldMatch = false; // Allow matching on display field
    @api value; // Value of the input field
    @api sortBy = ''; // Optional sort field (defaults to displayFieldName when not provided)
    @api sortDirection = 'asc'; // Sort direction
    @api parentFilterOperator = '='; // Operator for parent filter
    @api disableOnNoParentValue = false; // Disable input if no parent filter value
    @api allowBarcodeScanning = false; // Allow barcode scanning
    @api scanButtonIcon = 'utility:scan'; // Allow barcode scanning
    @api relativeDropdown = false;
    @api populateOnTab = false;

    // Internal properties
    @track results = [];
    @track rawData = [];
    _objectApiName;
    _selectedRecord;
    _selectedValue;
    _parentFilterField;
    _parentFilterValue;
    _whereClause = '';
    showClearText = false;
    // Rely on SLDS wrapping; removed custom inline/full width toggling.
    searchValue = '';
    highlightedIndex = -1;
    loadingMessage = LABELS.preparing;
    sObjectName;
    showInput = false;
    scannedBarcodes;
    _componentInitialized = false; // Is component initialized
    _keydownListenerAdded = false; // Has keydown listener been added
    _dropDownOpen = false; // Is dropdown open
    _parentInitialized = false; // Is parent initialized
    _getRecordsRequestId = 0; // Request ID for getRecords to handle multiple calls


    // Debounce timeout for search
    debounceTimeout;
    // Flag that indicates a selection started and we should honor the next pointerup
    _awaitPointerUp = false;
    _awaitPointerUpTimeout = null;
    // Click-delay timers for input click open
    _clickOpenTimeout = null;
    _recentPointerDown = false;
    _recentPointerDownTimeout = null;
    // Timestamp of the last pointer interaction (ms since epoch)
    _lastPointerTime = 0;

    @api get objectApiName() {
        return this._objectApiName;
    }

    set objectApiName(value) {
        this._objectApiName = value;
    }

    _disabled = false;
    _required = false;
    _readOnly = false;

    @api 
    get disabled() {
        return this._disabled;
    }
    
    set disabled(value) {
        // Handle string "true"/"false" and boolean values
        if (value === true || value === 'true') {
            this._disabled = true;
        } else if (value === false || value === 'false') {
            this._disabled = false;
        } else {
            this._disabled = Boolean(value);
        }
    }

    @api 
    get readOnly() {
        return this._readOnly;
    }
    
    set readOnly(value) {
        // Handle string "true"/"false" and boolean values
        if (value === true || value === 'true') {
            this._readOnly = true;
        } else if (value === false || value === 'false') {
            this._readOnly = false;
        } else {
            this._readOnly = Boolean(value);
        }
    }

    @api 
    get required() {
        return this._required;
    }
    
    set required(value) {
        // Handle string "true"/"false" and boolean values
        if (value === true || value === 'true') {
            this._required = true;
        } else if (value === false || value === 'false') {
            this._required = false;
        } else {
            this._required = Boolean(value);
        }
    }

    @api get whereClause() {
        return this._whereClause;
    }
    
    set whereClause(value) {
        const oldWhereClause = this._whereClause;
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} whereClause setter triggered: ${value}`);
        this._whereClause = value;
        if( oldWhereClause !== value && this.componentInitialized) {
            this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} whereClause changed from "${oldWhereClause}" to "${value}"`);
            this.getRecords(); // Re-fetch records when whereClause changes
        }
    }

    get hasLabel() {
        return !!this.label && String(this.label).trim().length > 0;
    }

    get isNonInteractive() {
        return this.disabled || this.readOnly;
    }

    @api
    validate() {
        return this.checkValidity();
    }

    @api
    checkValidity() {
        // If required and no selected record, show error and return false
        if (this.required && !this.selectedRecord) {
            return {
                isValid: false,
                errorMessage: LABELS.fieldRequired
            };
        } else if (!this.componentInitialized){
            return {
                isValid: false,
                errorMessage: LABELS.lookupNotReady
            };
        }
        return { isValid: true };
    }

    @api get parentInitialized() {
        return this._parentInitialized;
    }

    set parentInitialized(value) {
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} parentInitialized setter triggered`);
        this._parentInitialized = value;
        this.componentInitialized = false;
        this.loadingMessage = LABELS.applyingParent;
        // Re-fetch records based on the new filter value and update selection
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} Parent initialized:`, {
            parentInitialized: value,
            parentFilterField: this.parentFilterField,
            parentFilterValue: this.parentFilterValue,
            value: this.value
        });
        if( this._parentInitialized && this.parentFilterField && this.parentFilterValue && this.value) {
            this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} Parent initialized with filter field: ${this.parentFilterField}, value: ${this.parentFilterValue}`);
            this.getRecords().then(() => {
                if(this.parentFilterValue){
                    this.selectedRecord = this.findRecordByValue(this.value);
                } else {
                    this.selectedRecord = null; // Clear selected record if parent filter value is not set
                }
                this.componentInitialized = true;
                this.value = null;
            });
        } else if (this._parentInitialized) {
            this.value = null;
            this.selectedRecord = null;
            this.componentInitialized = true;
        }
    }

    @api get componentInitialized() {
        return this._componentInitialized;
    }

    set componentInitialized(value) {
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} componentInitialized setter triggered`);
        this._componentInitialized = value;
        this.dispatchEvent(
            new FlowAttributeChangeEvent('componentInitialized', value)
        );

        if( this._componentInitialized) {
            this.loadingMessage = null;
            this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} Component initialized successfully.`);
        }
    }

    @api get selectedValue() {
        return this._selectedValue;
    }

    set selectedValue(value) {
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} selectedValue setter triggered`);
        this._selectedValue = value;
        // Dispatch an event to notify parent components of the selected value
        const selectedValueEvent = new CustomEvent('selectedvaluechange', {
            detail: { value: value }
        });
        this.dispatchEvent(selectedValueEvent);
        // Notify Flow
        this.dispatchEvent(
            new FlowAttributeChangeEvent('selectedValue', value)
        );
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} Selected Value Set:`, value);
    }

    @api get parentFilterField() {
        return this._parentFilterField;
    }

    set parentFilterField(value) {
        this._parentFilterField = value;
    }

    @api get parentFilterValue() {
        return this._parentFilterValue;
    }

    set parentFilterValue(value) {
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} parentFilterValue setter triggered`);
        this._parentFilterValue = value;

        if(this._parentFilterValue == null || this._parentFilterValue === '') {   
            this.selectedRecord = null;
            this.searchValue = ''; // Clear search input if parent filter value is not set
            if(this.disableOnNoParentValue && !this.readOnly) {
                this.disabled = true; // Disable the input if no parent filter value is set
            }
        } else {
            if(!this.readOnly) {
                this.disabled = false; // Enable the input if parent filter value is set
            }
        }

        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} Parent Filter Value Set:`, value);
        // Dispatch an event to notify parent components of the filter value change
        const filterValueEvent = new CustomEvent('filtervaluechange', {
            detail: { value: value }
        });
        this.dispatchEvent(filterValueEvent);
    }

    @api get selectedRecord() {
        return this._selectedRecord;
    }

    set selectedRecord(value) {
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} selectedRecord setter triggered`);
        this._selectedRecord = value;
        this.selectedValue = value ? value[this.valueFieldName] : null;
        this.recordSelected = value ? true : false;

        // Dispatch an event to notify parent components of the selected record
        const selectedEvent = new CustomEvent('recordselected', {
            detail: { record: value }
        });
        this.dispatchEvent(selectedEvent);
        // Notify Flow
        this.dispatchEvent(
            new FlowAttributeChangeEvent('selectedRecord', value)
        );
        // Notify for recordId
        this.dispatchEvent(
            new FlowAttributeChangeEvent('recordId', value ? value.Id : null)
        );
        // Optionally, notify for selectedValue as well
        this.dispatchEvent(
            new FlowAttributeChangeEvent('selectedValue', this.selectedValue)
        );
        this.dispatchEvent(
            new FlowAttributeChangeEvent('recordSelected', value ? true : false)
        );
        this.dispatchEvent(
            new FlowAttributeChangeEvent('recordSelectedNegative', value ? false : true)
        );
    }

    @api get recordId() {
        return this._selectedRecord ? this._selectedRecord.Id : null;
    }

    @api get recordSelected() {
        return this._selectedRecord ? true : false;
    }

    @api get recordSelectedNegative() {
        return this._selectedRecord ? false : true;
    }

    @api get selectedDisplayValue() {
        return this._selectedRecord ? this._selectedRecord[this.displayFieldName] : null;
    }

    get dropDownOpen() {
        return this.componentInitialized && this._dropDownOpen;
    }

    set dropDownOpen(value) {
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} dropDownOpen setter triggered`);
        const wasOpen = this._dropDownOpen;
        this._dropDownOpen = value;

        if (this._dropDownOpen && !wasOpen) {
            // Dropdown is opening for the first time
            this.results = [];
            this.getRecords();
        } else if (this._dropDownOpen && wasOpen) {
            if(this.searchType === 'local'){
                this.applySearchFilter();
            } else if (this.searchType === 'live') {
                this.results = [];
                this.getRecords();
            }
        }
    }

    applySearchFilter(){
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} applySearchFilter triggered`);

        if(this.searchType === 'local'){
            if (this.rawData && this.rawData.length > 0 && this.fieldApiName && this.searchValue) {
                const searchLower = this.searchValue.toLowerCase();
                this.prepareData(this.rawData.filter(record => {
                    const fieldVal = record[this.fieldApiName];
                    if (!fieldVal) return false;
                    if (this.valueMatchType === 'partial') {
                        return fieldVal.toLowerCase().includes(searchLower);
                    } else {
                        return fieldVal.toLowerCase() === searchLower;
                    }
                }));
            } else {
                this.prepareData(this.rawData);
            }
        } else if (this.searchType === 'live') {
            // If live search, we already have the results from getRecords
            this.prepareData(this.rawData);
        } else {
            console.warn(`${LOG_PREFIX} - ${this.objectApiName} Invalid searchType: ${this.searchType}`);
            this.prepareData([]);
        }
    }

    async connectedCallback() {
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} connectedCallback triggered`);
        this.barcodeScanner = getBarcodeScanner();
        this.getSObjectDetails(); // Fetch SObject details on component initialization

        if(this.componentInitialized) {
            this.showInput = true; // Show the input field if component is already initialized
            
            const inputElement = this.template.querySelector('.slds-input');
            if (inputElement) {
                inputElement.blur();
            }

            return; // Exit early if component is already initialized
        }

        if(this.selectedValue) {
            this.value = this.selectedValue; // Set initial value if selectedValue is set
        }
        
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} init value: `, this.value);

        this.template.addEventListener('focusin', this.handleFocusIn.bind(this));
        this.template.addEventListener('focusout', this.handleFocusOut.bind(this));
        if(!this.parentFilterField) {
            this.loadingMessage = LABELS.preparing;
            const origMaxResults = this.maxResults;
            this.maxResults = null; // Default to 200 if not set
            this.getRecords().then(() => {
                this.selectedRecord = this.findRecordByValue(this.value,true);
                this.maxResults = origMaxResults; // Restore maxResults after fetching records
                if(!this.parentFilterField){
                    this.componentInitialized = true; // Set the flag to true after initialization
                }
            });
        } else {
            this.loadingMessage = LABELS.waitingParent;
            if(this.disableOnNoParentValue && !this.parentFilterValue) {
                this.disabled = true; // Disable the input if no parent filter value is set
            }
        }
        
        setTimeout(() => {
            this.showInput = true; // Show the input field
            const inputElement = this.template.querySelector('.slds-input');
            if (inputElement) {
                inputElement.blur();
            }
            // Pointerup fallback: ensure we can focus the combobox after selection
            // but only if the selection originated in this component.
            try {
                this._globalPointerUpHandler = (evt) => {
                    if (this._awaitPointerUp) {
                        this._awaitPointerUp = false;
                        try { if (this._awaitPointerUpTimeout) { clearTimeout(this._awaitPointerUpTimeout); this._awaitPointerUpTimeout = null; } } catch (e) {}
                        this._focusCombobox();
                    }
                };
                window.addEventListener('pointerup', this._globalPointerUpHandler, true);
            } catch (e) { /* ignore */ }
        },0);
    }

    disconnectedCallback() {
        try { if (this._globalPointerUpHandler) window.removeEventListener('pointerup', this._globalPointerUpHandler, true); } catch (e) { /* ignore */ }
        try { if (this._clickOpenTimeout) { clearTimeout(this._clickOpenTimeout); this._clickOpenTimeout = null; } } catch (e) { /* ignore */ }
        try { if (this._recentPointerDownTimeout) { clearTimeout(this._recentPointerDownTimeout); this._recentPointerDownTimeout = null; } } catch (e) { /* ignore */ }
    }

    async getSObjectDetails() {
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} getSObjectDetails triggered`);
        this.loadingMessage = LABELS.gettingContext;
            // Rely on SLDS wrapping; removed ResizeObserver and custom wrap handling.
        try {
            const sObjectDetails = await getSObjectDetails({ objectApiName: this.objectApiName });
            this.sObjectName = sObjectDetails.label;
            this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} SObject Details:`, sObjectDetails);
        } catch (error) {
            console.error(`${LOG_PREFIX} - ${this.objectApiName} Error fetching SObject details:`, error);
            this.showErrorToast(LABELS.errorSObject + ': ' + error.body.message);
        }
    }

    async getRecords(overrideSearchValue = null) {
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} getRecords triggered`);
        this._getRecordsRequestId++;
        const currentRequestId = this._getRecordsRequestId;
        const searchValue = overrideSearchValue !== null ? overrideSearchValue : this.searchValue;
        try{
            // compute effective sort field: prefer explicit sortBy, otherwise fallback to displayFieldName
            const effectiveSortBy = (this.sortBy && String(this.sortBy).trim()) ? this.sortBy : this.displayFieldName;

            this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} Fetching records with parameters:`, {
                objectApiName: this.objectApiName,
                displayField: this.displayFieldName,
                parentFilterField: this.parentFilterField,
                parentFilterValue: this.parentFilterValue,
                parentFilterOperator: this.parentFilterOperator,
                whereClause: this.whereClause,
                sortBy: effectiveSortBy,
                sortDirection: this.sortDirection,
                maxResults: (this.searchType === 'live' && this.maxResults) ? this.maxResults : null,
                searchField: this.fieldApiName,
                searchValue: (this.searchType === 'live' && searchValue) ? searchValue : null,
                valueMatchType: this.valueMatchType,
                valueFieldName: this.valueFieldName
            });
            let data = [];

            // Call the Apex method to query records
            data = JSON.parse(await queryRecords({
                    objectApiName: this.objectApiName,
                    displayField: this.displayFieldName,
                    parentFilterField: this.parentFilterField,
                    parentFilterValue: this.parentFilterValue,
                    parentFilterOperator: this.parentFilterOperator,
                    whereClause: this.whereClause,
                    sortBy: effectiveSortBy,
                    sortDirection: this.sortDirection,
                    maxResults: this.componentInitialized ? ((this.searchType === 'live' && this.maxResults) ? this.maxResults : null) : null,
                    searchField: this.fieldApiName,
                    searchValue: (this.searchType === 'live' && searchValue) ? searchValue : null,
                    valueMatchType: this.valueMatchType,
                    valueFieldName: this.valueFieldName
            }));

            if (currentRequestId === this._getRecordsRequestId) {
                this.rawData = data;
                this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} Records fetched successfully`);
                if ((this.parentFilterField && this.parentFilterValue) || !this.parentFilterField) {
                    this.applySearchFilter();
                } else {
                    this.prepareData([]);
                }
            } else {
                this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} Ignored outdated getRecords response`);
            }
        } catch (error) {
            if (currentRequestId === this._getRecordsRequestId) {
                console.error(`${LOG_PREFIX} - ${this.objectApiName} Error fetching records:`, error);
                this.showErrorToast(LABELS.errorRecords + ': ' + error.body.message);
            }
        };
    }

    showToast(title, message, variant) {
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} showToast triggered`);
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(toastEvent);
    }

    showErrorToast(message) {
        this.showToast(LABELS.error, message, 'error');
    }

    showSuccessToast(message) {
        this.showToast(LABELS.success, message, 'success');
    }

    prepareData(data){
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} prepareData triggered`);
        // Limit the data to the first maxResults entries
        const limitedData = Array.isArray(data) && this.maxResults
            ? data.slice(0, this.maxResults)
            : data;

        if(limitedData.length === 0) {
            let noRecord = {};
            noRecord["DisplayField"] = LABELS.noRecordsFound;
            noRecord["ValueField"] = "";
            noRecord["sObjectName"] = this.sObjectName;
            noRecord["index"] = 0;
            noRecord["class"] = "slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_has-meta slds-grid_vertical-align-center";
            this.results = [noRecord];
        } else {
           this.results = limitedData.map((record, idx) => {
                return {
                    Id: record.Id,
                    Name: record.Name,
                    DisplayField: record[this.displayFieldName],
                    ValueField: record[this.valueFieldName],
                    sObjectName: this.sObjectName,
                    index: idx,
                    class: "slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_has-meta slds-grid_vertical-align-center"
                };
            });
        }
        this.highlightedIndex = this.isSalesforceMobileApp ? -1 : 0; // Reset highlighted index to first item
        this.calculateHighlightedIndex();
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} Prepared data successfully`);
    }

    @api
    showDropdown() {
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} showDropdown triggered`);
        this.dropDownOpen = true;
    }

    hideDropdown() {
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} hideDropdown triggered`);
        this.dropDownOpen = false;
    }

    toggleDropdown() {
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} toggleDropdown triggered`);
        this.dropDownOpen = !this.dropDownOpen;
    }

    handleFocusIn() {
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} handleFocusIn triggered`);
    }

    handleFocusOut() {
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} handleFocusOut triggered`);
        // Small delay to ensure focus isn't moving within the component
        setTimeout(() => {
            if (!this.template.activeElement || !this.template.contains(this.template.activeElement)) {
                this.dropDownOpen = false;
                if(this.searchValue && !this.selectedRecord) {
                    this.searchValue = '';
                }
            }
        }, 10);
    }

    handleInput(event) {
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} handleInput triggered`);
        const inputValue = event.target.value;
        this.searchValue = inputValue;
        this.highlightedIndex = 0; // Reset highlight to first item on input

        // Debounce: clear previous timeout and set a new one
        if (this.debounceTimeout) {
            clearTimeout(this.debounceTimeout);
        }
        this.debounceTimeout = setTimeout(() => {
            this.showDropdown();
        }, 350); // 350ms delay, adjust as needed
    }

    handleInputPointerDown(event) {
        // Mark that a pointerdown occurred so the subsequent focus event
        // can be distinguished as coming from a click.
        this._recentPointerDown = true;
        this._lastPointerTime = Date.now();
        try { if (this._recentPointerDownTimeout) clearTimeout(this._recentPointerDownTimeout); } catch (e) {}
        this._recentPointerDownTimeout = setTimeout(() => { this._recentPointerDown = false; this._recentPointerDownTimeout = null; }, 300);
    }

    handleInputClick(event) {
        // If the dropdown is already open, no need to schedule another open
        if (this.dropDownOpen) return;
        // Use shared helper to schedule the delayed open and avoid duplicating
        // the shadow-aware activeElement logic.
        this._scheduleOpenIfFocused(200);
    }

    handleInputFocus(event) {
        this._scheduleOpenIfFocused(200);
    }

    _scheduleOpenIfFocused(delayMs = 200) {
        // No-op if already open
        if (this.dropDownOpen) return;
        try { if (this._clickOpenTimeout) clearTimeout(this._clickOpenTimeout); } catch (e) {}
        this._clickOpenTimeout = setTimeout(() => {
            try {
                const inputEl = this.template.querySelector('.slds-input');
                let active = this.template.activeElement || document.activeElement;
                if (inputEl && (active === inputEl || (inputEl.contains && inputEl.contains(active)))) {
                    this.showDropdown();
                }
            } catch (e) { /* ignore */ }
            this._clickOpenTimeout = null;
        }, delayMs);
    }

    handleSelect(event) {
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} handleSelect triggered`);
        if (event.button === 0) {
            // Left mouse button
            const selectedValue = event.currentTarget.dataset.value;
            this.selectedRecord = this.findRecordByValue(selectedValue);

            this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} Selected Value:`, this.selectedValue);
            this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} Selected Record:`, JSON.stringify(this.selectedRecord, null, 2));
            
            // Mark that a selection started so our global pointerup handler
            // will only act for selections originating here.
            this._awaitPointerUp = true;
            try { if (this._awaitPointerUpTimeout) clearTimeout(this._awaitPointerUpTimeout); } catch (e) {}
            // Clear the flag after a short period to avoid stale state
            this._awaitPointerUpTimeout = setTimeout(() => { this._awaitPointerUp = false; this._awaitPointerUpTimeout = null; }, 1500);

            setTimeout(() => {
                // Try to focus the pill or combobox reliably. Use helper so we
                // can reuse the same logic and also call it from global pointerup
                // fallback if mouseup never fires (DOM changes during mousedown).
                this._focusCombobox();
                this.hideDropdown();
            }, 0);
        } else if (event.button === 2) {
            // Right mouse button
            this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} Right mouse button clicked`);
            // Optionally, prevent default context menu:
            // event.preventDefault();
        }
    }

    handleMouseUp(event) {
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} handleMouseUp triggered`);
        const comboboxDiv = this.template.querySelector('.selection-container_combobox');
        // Use the shared focus helper (keeps behavior consistent with handleSelect)
        setTimeout(() => this._focusCombobox(), 0);
    }

    _focusCombobox() {
        try {
            const comboboxDiv = this.template.querySelector('.selection-container_combobox');
            // Prefer focusing a pill/selection element if present so keyboard
            // interactions land on the element users expect.
            const pillSelectors = ['.slds-pill', '.selection-container_pill', '.selection-pill', '.selection-container_selected'];
            let focusEl = null;
            for (const sel of pillSelectors) {
                focusEl = this.template.querySelector(sel);
                if (focusEl) break;
            }
            if (focusEl) {
                try {
                    if (!focusEl.hasAttribute('tabindex')) focusEl.setAttribute('tabindex', '0');
                    // Use requestAnimationFrame to ensure element is in DOM and painted
                    window.requestAnimationFrame(() => {
                        try { focusEl.focus(); } catch (e) { /* ignore */ }
                    });
                    return;
                } catch (e) {
                    // fallthrough to combobox focusing
                }
            }
            if (comboboxDiv && typeof comboboxDiv.focus === 'function') {
                window.requestAnimationFrame(() => {
                    try { comboboxDiv.focus(); } catch (e) { /* ignore */ }
                });
            }
        } catch (e) {
            // swallow errors - focusing is best-effort
        }
    }

    findRecordByValue(value, useValueFieldName = false, returnFirstIfMultiple = false) {
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} findRecordByValue triggered: ${value}`);
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} useValueFieldName: ${useValueFieldName}, valueFieldName: ${this.valueFieldName}`);
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} rawData length: ${this.rawData.length}`);
        
        // Try to find by valueFieldName first
        let matches = this.rawData.filter(record => (useValueFieldName ? record[this.valueFieldName] === value : record.Id === value));

        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} Searching for ${useValueFieldName ? 'valueField[' + this.valueFieldName + ']' : 'Id'} === ${value}, found ${matches.length} matches`);

        // If not found and allowDisplayFieldMatch is true, try displayFieldName with "contains"
        if (matches.length === 0 && this.allowDisplayFieldMatch && value && this.displayFieldName) {
            const searchLower = value.toLowerCase();
            matches = this.rawData.filter(record => {
                const displayVal = record[this.displayFieldName];
                return displayVal && displayVal.toLowerCase().includes(searchLower);
            });
            if (matches.length > 0) {
                this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} Found by displayFieldName (contains):`, JSON.stringify(matches, null, 2));
            } else {
                this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} No record found by displayFieldName (contains)`);
            }
        } else if (matches.length > 0) {
            this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} Found Record:`, JSON.stringify(matches, null, 2));
        } else {
            this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} No record found by valueFieldName`);
        }

        // If multiple matches and we want the first one
        if (matches.length > 1) {
            if (returnFirstIfMultiple) {
                this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} Multiple matches found, returning first match`);
                return matches[0];
            }
            this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} Multiple matches found, returning null`);
            return null;
        }
        
        return matches.length === 1 ? matches[0] : null;
    }
    
    handleSelectionClick(event) {
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} handleSelectionClick triggered`);
        event.preventDefault(); // Prevent navigation from anchor tag
        event.stopPropagation(); // Prevent the click from propagating to the combobox
    }

    @api
    handleRemoveSelection() {
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} handleRemoveSelection triggered`);
        // Prevent removal if disabled or readOnly
        if (this.isNonInteractive) {
            this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} handleRemoveSelection blocked - component is non-interactive`);
            return;
        }
        this.selectedRecord = null; // Clear the selected record
        this.searchValue = ''; // Clear the search input
        this.showClearText = false;
        this.hideDropdown();
        setTimeout(() => {
            const inputElement = this.template.querySelector('.slds-input');
            if (inputElement) {
                inputElement.focus();
            }
        },0);
    }

    handleSelectionDblClick(event) {
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} handleSelectionDblClick triggered`);
        // Prevent removal if disabled or readOnly
        if (this.isNonInteractive) {
            this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} handleSelectionDblClick blocked - component is non-interactive`);
            return;
        }
        const displayValue = this.selectedDisplayValue || '';
        this.handleRemoveSelection(); // Call the method to remove selection
        this.searchValue = displayValue;
    }  

    handleInputKeydown(event) {
        const searchValue = this.searchValue;
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} handleInputKeydown triggered`);

        // Check for Ctrl+Shift+L to toggle log messages
        if (event.ctrlKey && event.shiftKey && event.key === 'L') {
            event.preventDefault();
            this.showLogMessages = !this.showLogMessages;
            this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} showLookupLog toggled to: ${this.showLogMessages}`);
            return;
        }

        // Handle Tab key FIRST before other logic
        if (event.key === 'Tab') {
            // Get the current value directly from the input element to ensure it's up-to-date
            const inputElement = event.target;
            const currentValue = inputElement ? inputElement.value.trim() : searchValue;
            
            this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} Tab pressed. CurrentValue: "${currentValue}", populateOnTab: ${this.populateOnTab}`);
            
            // Only handle Tab if there's a search value AND populateOnTab is true
            if (currentValue && this.populateOnTab === true) {
                event.preventDefault(); // Prevent default BEFORE doing anything else
                event.stopPropagation();
                
                this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} Tab pressed with search value, fetching first match`);
                
                // Update searchValue to current input value
                this.searchValue = currentValue;
                
                // Close dropdown and blur input
                this.hideDropdown();
                setTimeout(() => {
                    const inputElement = this.template.querySelector('.slds-input');
                    if (inputElement) {
                        inputElement.blur();
                    }
                }, 0);
                
                this.selectedRecord = null;
                this.loadingMessage = LABELS.findingMatch;
                this.componentInitialized = false;

                const origMaxResults = this.maxResults;
                this.maxResults = null;
                
                this.getRecords(currentValue).then(() => {
                    this.hideDropdown();
                    this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} Records fetched for Tab key:`, JSON.stringify(this.rawData));
                    this.selectedRecord = this.findRecordByValue(currentValue, false, true); // true = return first if multiple
                    this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} Selected Record after Tab search:`, JSON.stringify(this.selectedRecord, null, 2));
                    this.maxResults = origMaxResults;
                    this.componentInitialized = true;
                    
                    setTimeout(() => {
                        if(this.selectedRecord) {
                            const comboboxDiv = this.template.querySelector('.selection-container_combobox');
                            if (comboboxDiv) {
                                comboboxDiv.focus();
                            }
                        } else {
                            const inputElement = this.template.querySelector('.slds-input');
                            if (inputElement) {
                                inputElement.focus();
                            }
                        }
                    }, 0);
                }).catch(error => {
                    console.error(`${LOG_PREFIX} - ${this.objectApiName} Error during Tab search:`, error);
                    this.maxResults = origMaxResults;
                    this.componentInitialized = true;
                });
                
                return; // Exit early to prevent further processing
            } else if (currentValue && this.populateOnTab === false && this.dropDownOpen && this.results.length > 0) {
                // If populateOnTab is false but there's a dropdown open with results, select first option
                event.preventDefault();
                const selected = this.results[0];
                this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} Tab pressed with search value, selecting first option:`, selected);
                const mockEvent = {
                    currentTarget: {
                        dataset: { value: selected.Id }
                    },
                    button: 0
                };
                this.handleSelect(mockEvent);
                return;
            }
            // If no search value or populateOnTab is not enabled, allow default Tab behaviour
            return;
        }

        // If dropdown is closed and arrow keys are pressed, open it
        if (!this.dropDownOpen && (event.key === 'ArrowDown' || event.key === 'ArrowUp')) {
            event.preventDefault();
            this.showDropdown();
            return;
        }

        if (this.results.length > 0) {
            if (event.key === 'ArrowDown') {
                event.preventDefault();
                this.highlightedIndex = (this.highlightedIndex + 1) % this.results.length;
            } else if (event.key === 'ArrowUp') {
                event.preventDefault();
                this.highlightedIndex = (this.highlightedIndex - 1 + this.results.length) % this.results.length;
            } else if (event.key === 'Enter') {
                event.preventDefault();
                if (this.highlightedIndex >= 0 && this.highlightedIndex < this.results.length) {
                    const selected = this.results[this.highlightedIndex];
                    this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} Enter pressed, selecting:`, selected);
                    const mockEvent = {
                        currentTarget: {
                            dataset: { value: selected.Id }
                        },
                        button: 0
                    };
                    this.handleSelect(mockEvent);
                }
            }
        }
        
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} highlightedIndex:`, this.highlightedIndex);
        this.calculateHighlightedIndex();
    }

    renderedCallback() {
        // Rely on SLDS `slds-wrap` for layout; custom wrap handling removed.
    }

    // Removed custom clear-meta wrap logic; rely on SLDS styles (e.g. slds-wrap).
    get clearMetaClass() {
        return 'slds-form-element__label slds-text-color_weak clear-meta slds-p-right_none';
    }

    calculateHighlightedIndex() {
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} calculateHighlightedIndex triggered`);
        this.results.forEach((result) => {
            if (result.index === this.highlightedIndex) {
                result.class = 'slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_has-meta slds-has-focus slds-grid_vertical-align-center';
            } else {
                result.class = 'slds-media slds-listbox__option slds-listbox__option_entity slds-listbox__option_has-meta slds-grid_vertical-align-center';
            }
        });

        // Scroll the highlighted item into view
        setTimeout(() => {
            const focusedLi = this.template.querySelector('li > div.slds-has-focus');
            if (focusedLi) {
                focusedLi.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
            }
        }, 0);
    }

    handleComboboxKeydown(event) {
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} handleComboboxKeydown triggered`);

        // Only trigger if Delete key is pressed and there is a selected value
        if ((event.key === 'Delete' || event.key === 'Backspace') && this.selectedRecord) {
            // Prevent removal if disabled or readOnly
            if (this.isNonInteractive) {
                this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} handleComboboxKeydown blocked - component is non-interactive`);
                event.preventDefault();
                return;
            }
            event.preventDefault();
            this.handleRemoveSelection();
        }
    }

    handleSelectionFocus(event) {
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} handleSelectionFocus triggered`);
        this.showClearText = true;
        event.currentTarget.classList.add('slds-has-focus');
    }  

    handleSelectionBlur(event) {
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} handleSelectionBlur triggered`);
        this.showClearText = false;
        event.currentTarget.classList.remove('slds-has-focus');
    }

    handleInputBlur(event) {
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} handleInputBlur triggered`);
        // Check if the newly focused element is still inside the component
        try { if (this._clickOpenTimeout) { clearTimeout(this._clickOpenTimeout); this._clickOpenTimeout = null; } } catch (e) {}
        try { if (this._recentPointerDownTimeout) { clearTimeout(this._recentPointerDownTimeout); this._recentPointerDownTimeout = null; this._recentPointerDown = false; } } catch (e) {}
        setTimeout(() => {
            this.hideDropdown();
        },10);
        
    }

    handleScanClick(event){
        // Set your configuration options, including bulk and multi-scanning if desired, in this scanningOptions object
        const scanningOptions = {
            barcodeTypes: [ 
                this.barcodeScanner.barcodeTypes.QR,
                this.barcodeScanner.barcodeTypes.CODE_128,
                this.barcodeScanner.barcodeTypes.CODE_39,
                this.barcodeScanner.barcodeTypes.CODE_93,
                this.barcodeScanner.barcodeTypes.DATA_MATRIX,
                this.barcodeScanner.barcodeTypes.UPC_A,
                this.barcodeScanner.barcodeTypes.UPC_E,
                this.barcodeScanner.barcodeTypes.EAN_8,
                this.barcodeScanner.barcodeTypes.EAN_13,
                ],
            scannerSize: "FULLSCREEN",
            cameraFacing: "BACK",
            showSuccessCheckMark: true,
            enableBulkScan: false,
            enableMultiScan: false,
            presentWithAnimation: true,
        };

        // Make sure BarcodeScanner is available before trying to use it
        if (this.barcodeScanner != null && this.barcodeScanner.isAvailable()) {
        // Reset scannedBarcodes before starting new scanning session
        this.scannedBarcodes = [];

        // Start scanning barcodes
        this.barcodeScanner
            .scan(scanningOptions)
            .then((results) => {
                this.scannedBarcodes = [];
                this.processScannedBarcodes(results);
            })
            .catch((error) => {
                this.processError(error);
            })
            .finally(() => {
                this.barcodeScanner.dismiss();
            });
        } else {
        this.appendLog(LABELS.barcodeUnavailable);
        }
    }

    processScannedBarcodes(barcodes) {
        this.appendLog(JSON.stringify(barcodes));
        this.scannedBarcodes = this.scannedBarcodes.concat(barcodes);
        this.selectedRecord = null; // Clear selected record before fetching new records
        this.loadingMessage = LABELS.processingBarcode;
        this.componentInitialized = false; // Reset component initialization state

        const origMaxResults = this.maxResults;
        this.maxResults = null; // Default to 200 if not set
        this.searchValue = '';
        this.getRecords().then(() => {
            this.selectedRecord = this.findRecordByValue(this.scannedBarcodesAsString);
            this.maxResults = origMaxResults;
            if(!this.selectedRecord){
                this.searchValue = this.scannedBarcodesAsString; // Set search value to scanned barcodes
                this.componentInitialized = true; // Set the flag to true after initialization
            
                setTimeout(() => {
                    const inputElement = this.template.querySelector('.slds-input');
                    if (inputElement) {
                        inputElement.focus();
                    }
                },0);
            }
            this.componentInitialized = true; // Set the flag to true after initialization
            this.scannedBarcodes = []; // Clear scanned barcodes after processing
            
            setTimeout(() => {
                const comboboxDiv = this.template.querySelector('.selection-container_combobox');
                if (comboboxDiv) {
                    comboboxDiv.focus();
                }
            }, 0);
        });
    }

    processError(error) {
        // Check to see if user ended scanning
        if (error.code == "USER_DISMISSED") {
        this.appendLog(LABELS.userDismissed);
        } else {
        console.error(error);
        this.showErrorToast(LABELS.errorScanning + ': ' + error.message);
        }
    }

    handleScan(event){
        this.showSuccessToast(LABELS.scanReceived + ': ' + JSON.stringify(event));
    }

    handleScanError(event){
        this.showErrorToast(LABELS.scanError + ': ' + event.detail.error);
    }

    get dropDownClass() {
        return 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click' +
            (this.dropDownOpen && this.sObjectName ? ' slds-is-open' : '');
    }

    get containerClass() {
        return 'slds-combobox_container';
    }

    get showDropdownSpinner() {
        return this.dropDownOpen && this.results.length === 0;
    }

    get showScanButton() {
        const result = this.allowBarcodeScanning && this.barcodeScanner && this.barcodeScanner.isAvailable();
        this.appendLog(`${LOG_PREFIX} - ${this.objectApiName} showScanButton: allowBarcodeScanning=${this.allowBarcodeScanning}, barcodeScanner=${!!this.barcodeScanner}, isAvailable=${this.barcodeScanner ? this.barcodeScanner.isAvailable() : 'N/A'}, result=${result}`);
        
        return result;
    }

    get debugBarcodeScannerInfo() {
        if (this.barcodeScanner) {
            return `BarcodeScanner is available: ${this.barcodeScanner.isAvailable()}`;
        } else {
            return 'BarcodeScanner not initialized';
        }
    }

    get scannedBarcodesAsString() {
        return this.scannedBarcodes.map((barcode) => barcode.value).join("\n");
    }

    get isSalesforceMobileApp() {
        return /Salesforce/i.test(navigator.userAgent);
    }

    get mobileAppOverrideStyle() {
        return this.isSalesforceMobileApp || this.relativeDropdown ? 'position:relative!important;' : '';
    }

    get showClearTextAndNotDisabled() {
        return this.showClearText && !this.isNonInteractive;
    }

    get pillClass() {
        let classes = 'selection-container_combobox slds-input_faux slds-combobox__input slds-combobox__input-value slds-button slds-text-color_default';
        if (this.disabled) {
            classes += ' slds-is-disabled';
        } else if (this.readOnly) {
            classes += ' read-only-mode';
        }
        return classes;
    }

    get searchLabel() {
        return LABELS.search;
    }

    get removeOptionLabel() {
        return LABELS.removeOption;
    }

    get retrievingRecordsLabel() {
        return LABELS.retrievingRecords;
    }

    get helpTextLabel() {
        if (this.isSalesforceMobileApp) {
            return LABELS.helpTextMobile;
        }
        return LABELS.helpTextDesktop;
    }

    get hasHelpText() {
        return this.helpText != null && this.helpText !== '';
    }

    handleHelpMouseEnter() {
        this.showTooltip = true;
    }

    handleHelpMouseLeave() {
        this.showTooltip = false;
    }

    appendLog(message, ...args) {
        const formatted = args.length ? `${message} ${args.map(a => JSON.stringify(a)).join(' ')}` : message;
        // Log to console as usual
        console.log(formatted);
        // Append to logMessages (with newline)
        this.logMessages += formatted + '\n';
    }

    _showLogMessages = false;

    get showLogMessages(){
        return this._showLogMessages;
    }

    set showLogMessages(value){
        this._showLogMessages = value;
    }
}