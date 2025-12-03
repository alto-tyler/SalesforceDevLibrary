import { LightningElement, api } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationBackEvent, FlowNavigationFinishEvent } from 'lightning/flowSupport';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import getUserInfo from '@salesforce/apex/FlowHeaderController.getUserInfo';

export default class Alto_flowHeader extends NavigationMixin(LightningElement) {
    @api
    get actionLinks() {
        return this._actionLinks;
    }
    set actionLinks(value) {
        this._actionLinks = value;
        console.log('actionLinks set to:', value);
        this.parseActionLinks();
    }
    _actionLinks;
    @api
    get maxVisibleActions() {
        return this._maxVisibleActions;
    }
    set maxVisibleActions(value) {
        this._maxVisibleActions = value;
        this.parseActionLinks();
    }
    _maxVisibleActions = 3;
    @api
    get customActionsInDropdown() {
        return this._customActionsInDropdown;
    }
    set customActionsInDropdown(value) {
        this._customActionsInDropdown = value;
        this.parseActionLinks();
    }
    _customActionsInDropdown = false;
    @api
    get showNext() { // Show auto-generated Next/Finish button
        return this._showNext;
    }
    set showNext(value) {
        this._showNext = value;
        this.parseActionLinks();
    }
    _showNext = true;
    @api
    get showPrevious() { // Show auto-generated Previous button
        return this._showPrevious;
    }
    set showPrevious(value) {
        this._showPrevious = value;
        this.parseActionLinks();
    }
    _showPrevious = true;
    @api
    get nextLabel() { return this._nextLabel; } // Custom label for Next/Finish button
    set nextLabel(value) {
        this._nextLabel = value;
        this.parseActionLinks();
    }
    _nextLabel = '';
    @api
    get previousLabel() { return this._previousLabel; } // Custom label for Previous button
    set previousLabel(value) {
        this._previousLabel = value;
        this.parseActionLinks();
    }
    _previousLabel = '';
    @api
    get nextVariant() { return this._nextVariant; } // Variant for Next button
    set nextVariant(value) {
        this._nextVariant = value;
        this.parseActionLinks();
    }
    _nextVariant = 'neutral';
    @api
    get previousVariant() { return this._previousVariant; } // Variant for Previous button
    set previousVariant(value) {
        this._previousVariant = value;
        this.parseActionLinks();
    }
    _previousVariant = 'neutral';
    // Optional custom title/meta inputs
    @api  get useCustomTitle() { return this._useCustomTitle; }
    set useCustomTitle(value) {
        this._useCustomTitle = value;
        this.parseActionLinks();
    }
    _useCustomTitle = false;
    @api  get pageTitleInput() { return this._pageTitleInput; }
    set pageTitleInput(value) {
        this._pageTitleInput = value;
        this.parseActionLinks();
    }
    _pageTitleInput = '';

    @api
     get pageMetaInput() { return this._pageMetaInput; }
    set pageMetaInput(value) {
        this._pageMetaInput = value;
        this.parseActionLinks();
    }
    _pageMetaInput = '';
    
    _availableActions = [];
    
    @api
    get availableActions() {
        return this._availableActions;
    }
    set availableActions(value) {
        this._availableActions = value || [];
        this.parseActionLinks();
    }
    
    userId = Id;
    companyName = '';
    divisionName = '';
    logoUrl = '';
    isLoading = true;
    error;
    parsedActions = [];
    dropdownOpen = false;
    _actionClicked = '';

    @api
    get actionClicked() {
        return this._actionClicked;
    }

    connectedCallback() {
        // If consumer requests custom title/meta, skip fetching Rootstock user/company data
        if (this.useCustomTitle) {
            this.isLoading = false;
            this.parseActionLinks();
        } else {
            this.loadUserInfo();
            this.parseActionLinks();
        }
        // Close dropdown when clicking outside
        this.handleClickOutside = this.handleClickOutside.bind(this);
        document.addEventListener('click', this.handleClickOutside);
    }

    disconnectedCallback() {
        document.removeEventListener('click', this.handleClickOutside);
    }

    handleClickOutside(event) {
        const dropdown = this.template.querySelector('.slds-dropdown-trigger');
        if (dropdown && !dropdown.contains(event.target)) {
            this.dropdownOpen = false;
        }
    }

    parseActionLinks() {
        let actions = [];
        
        // Prepend Previous button if checkbox enabled (default to true if undefined)
        if (this.showPrevious !== false) {
            // Only show button if BACK is available
            if (this._availableActions.find(a => a === 'BACK')) {
                const label = this.previousLabel && this.previousLabel.trim() !== '' 
                    ? this.previousLabel 
                    : 'Previous';
                const variant = this.previousVariant || 'neutral';
                actions.push({
                    name: 'previous',
                    label: label,
                    navigate: 'previous',
                    variant: variant,
                    buttonClass: this.getButtonClass(variant),
                    key: 'auto-previous',
                    isUrl: false,
                    iconName: null,
                    showIconLeft: false,
                    showIconRight: false
                });
            }
        }
        
        // Prepend Next/Finish button if checkbox enabled (default to true if undefined)
        if (this.showNext !== false) {
            const hasFinish = this._availableActions.find(a => a === 'FINISH');
            const hasNext = this._availableActions.find(a => a === 'NEXT');
            
            // Only show button if NEXT or FINISH is available
            if (hasNext || hasFinish) {
                let label;
                if (this.nextLabel && this.nextLabel.trim() !== '') {
                    label = this.nextLabel;
                } else {
                    label = hasFinish && !hasNext ? 'Finish' : 'Next';
                }
                const variant = this.nextVariant || 'neutral';
                actions.push({
                    name: 'next',
                    label: label,
                    navigate: 'next',
                    variant: variant,
                    buttonClass: this.getButtonClass(variant),
                    key: 'auto-next',
                    isUrl: false,
                    iconName: null,
                    showIconLeft: false,
                    showIconRight: false
                });
            }
        }
        
        // Parse JSON for custom actions and append after navigation buttons
        if (this.actionLinks) {
            try {
                const parsed = JSON.parse(this.actionLinks);
                if (Array.isArray(parsed)) {
                    const customActions = parsed
                        .filter(action => {
                            // Skip actions without required fields
                            if (!action.label || !action.name) return false;
                            
                            // Filter based on visible property (default to true if not specified)
                            const visible = action.visible !== undefined ? action.visible : true;
                            // Handle string "true"/"false" from formulas
                            if (typeof visible === 'string') {
                                return visible.toLowerCase() === 'true';
                            }
                            return Boolean(visible);
                        })
                        .map((action, index) => {
                            const variant = action.variant || 'neutral';
                            const iconPosition = action.iconPosition || 'left';
                            return {
                                ...action,
                                key: `action-${index}`,
                                variant: variant,
                                buttonClass: this.getButtonClass(variant),
                                iconName: action.iconName || null,
                                iconPosition: iconPosition,
                                showIconLeft: action.iconName && iconPosition === 'left',
                                showIconRight: action.iconName && iconPosition === 'right',
                                isUrl: !!action.url
                            };
                        });
                    actions = actions.concat(customActions);
                }
            } catch (e) {
                console.error('Error parsing action links:', e);
            }
        }
        
        this.parsedActions = actions;
    }

    getButtonClass(variant) {
        const baseClass = 'slds-button';
        switch(variant) {
            case 'brand':
                return `${baseClass} slds-button_brand`;
            case 'destructive':
                return `${baseClass} slds-button_destructive`;
            case 'success':
                return `${baseClass} slds-button_success`;
            case 'neutral':
            default:
                return `${baseClass} slds-button_neutral`;
        }
    }

    loadUserInfo() {
        getUserInfo({ userId: this.userId })
            .then(result => {
                if (result) {
                    this.companyName = result.companyName || '';
                    this.divisionName = result.divisionName || '';
                    this.logoUrl = result.logoUrl || '';
                }
                this.isLoading = false;
            })
            .catch(error => {
                this.error = error;
                this.isLoading = false;
                console.error('Error loading user info:', error);
            });
    }

    handleActionClick(event) {
        // prevent default navigation from anchor elements and stop propagation
        if (event && typeof event.preventDefault === 'function') {
            event.preventDefault();
        }
        event.stopPropagation();
        const actionName = event.currentTarget.dataset.name;
        const action = this.parsedActions.find(a => a.name === actionName);
        if (!action) return;

        // Simple / original navigation behaviour: use NavigationMixin for pageReference,
        // open new tab for explicit urls with _blank, otherwise navigate via webPage.
        if (action.pageReference) {
            try {
                this[NavigationMixin.Navigate](action.pageReference);
            } catch (err) {
                // fallback: no-op (keeps behaviour simple)
                console.error('Navigation failed', err);
            }
            return;
        }

        if (action.url) {
            try {
                if (action.target === '_blank' || action.target === '_new') {
                    window.open(action.url, '_blank', 'noopener');
                    return;
                }

                if (action.target === '_self') {
                    // Prefer top-level navigation where possible
                    try { window.top.location.href = action.url; return; } catch { /* may be blocked */ }
                    try { window.open(action.url, '_top'); return; } catch { /* fallback below */ }
                }

                // Default: in-context navigation via NavigationMixin
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: { url: action.url }
                });
            } catch (err) {
                console.error('URL navigation failed', err);
            }
            return;
        }

        // Flow navigation / built-in actions (next, previous, finish)
        if (action.navigate) {
            const nav = action.navigate.toLowerCase();
            this._actionClicked = actionName;
            this.dispatchEvent(new FlowAttributeChangeEvent('actionClicked', actionName));
            if (nav === 'next') {
                if (this._availableActions.find(a => a === 'NEXT')) {
                    this.dispatchEvent(new FlowNavigationNextEvent());
                } else if (this._availableActions.find(a => a === 'FINISH')) {
                    this.dispatchEvent(new FlowNavigationFinishEvent());
                }
            } else if (nav === 'finish') {
                if (this._availableActions.find(a => a === 'FINISH')) {
                    this.dispatchEvent(new FlowNavigationFinishEvent());
                } else if (this._availableActions.find(a => a === 'NEXT')) {
                    this.dispatchEvent(new FlowNavigationNextEvent());
                }
            } else if (nav === 'previous' || nav === 'back') {
                if (this._availableActions.find(a => a === 'BACK')) {
                    this.dispatchEvent(new FlowNavigationBackEvent());
                }
            }
            return;
        }

        // default: set output so Flow can react
        this._actionClicked = actionName;
        this.dropdownOpen = false;
        this.dispatchEvent(new FlowAttributeChangeEvent('actionClicked', actionName));
    }

    handleDropdownToggle(event) {
        event.stopPropagation();
        this.dropdownOpen = !this.dropdownOpen;
    }

    get hasLogo() {
        return this.logoUrl && this.logoUrl.trim() !== '';
    }

    get hasCompanyInfo() {
        return this.companyName || this.divisionName;
    }

    // Show header title block when either company/division info exists
    // or when the consumer has provided a custom title/meta via Flow inputs.
    get showHeaderTitle() {
        const hasCustomTitle = this.useCustomTitle && (
            (this.pageTitleInput && String(this.pageTitleInput).trim().length > 0) ||
            (this.pageMetaInput && String(this.pageMetaInput).trim().length > 0)
        );
        return Boolean(this.hasCompanyInfo) || Boolean(hasCustomTitle);
    }

    // Provide a plain-text version of the title (HTML stripped) for the title attribute
    get pageTitleText() {
        const raw = this.pageTitle || '';
        return String(raw).replace(/<[^>]*>/g, '').trim();
    }

    get hasActions() {
        return this.parsedActions.length > 0;
    }

    get visibleActions() {
        if (this.customActionsInDropdown) {
            // Only show nav buttons (Previous/Next), custom actions go to dropdown
            return this.parsedActions.filter(a => a.name === 'previous' || a.name === 'next');
        }
        const max = parseInt(this.maxVisibleActions, 10) || 3;
        return this.parsedActions.slice(0, max);
    }

    get overflowActions() {
        if (this.customActionsInDropdown) {
            // All custom actions (non-nav buttons) go to dropdown
            return this.parsedActions.filter(a => a.name !== 'previous' && a.name !== 'next');
        }
        const max = parseInt(this.maxVisibleActions, 10) || 3;
        return this.parsedActions.slice(max);
    }

    get hasOverflow() {
        return this.overflowActions.length > 0;
    }

    get dropdownClass() {
        return this.dropdownOpen 
            ? 'slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open'
            : 'slds-dropdown-trigger slds-dropdown-trigger_click';
    }

    get pageTitle() {
        if (this.useCustomTitle && this.pageTitleInput && String(this.pageTitleInput).trim().length) {
            return this.pageTitleInput;
        }
        if (this.divisionName) {
            return this.divisionName;
        }
        return this.companyName || '';
    }

    get pageMeta() {
        if (this.useCustomTitle && this.pageMetaInput && String(this.pageMetaInput).trim().length) {
            return this.pageMetaInput;
        }
        if (this.divisionName && this.companyName) {
            return `Company: ${this.companyName}`;
        }
        return '';
    }

    get dropdownTriggerClass() {
        return this.dropdownOpen 
            ? 'slds-dropdown-trigger slds-dropdown-trigger_click slds-button_last slds-is-open'
            : 'slds-dropdown-trigger slds-dropdown-trigger_click slds-button_last';
    }
}
