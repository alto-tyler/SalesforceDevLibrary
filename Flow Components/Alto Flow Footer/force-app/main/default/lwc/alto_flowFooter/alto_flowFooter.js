import { LightningElement, api } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationBackEvent, FlowNavigationFinishEvent } from 'lightning/flowSupport';
import { NavigationMixin } from 'lightning/navigation';

export default class Alto_flowFooter extends NavigationMixin(LightningElement) {
    @api
    get actionLinks() {
        return this._actionLinks;
    }
    set actionLinks(value) {
        this._actionLinks = value;
        this.parseActionLinks();
    }
    _actionLinks;
    @api 
    get showNext() {    
        return this._showNext;
    }
    set showNext(value) {
        this._showNext = value;
        this.parseActionLinks();
    }
    _showNext;
    @api 
    get showPrevious() {
        return this._showPrevious;
    }
    set showPrevious(value) {
        this._showPrevious = value;
        this.parseActionLinks();
    }
    _showPrevious;
    @api
    get nextLabel() {
        return this._nextLabel;
    }
    set nextLabel(value) {
        this._nextLabel = value;
        this.parseActionLinks();
    }
    _nextLabel;
    @api
    get previousLabel() {
        return this._previousLabel;
    }
    set previousLabel(value) {
        this._previousLabel = value;
        this.parseActionLinks();
    }
    _previousLabel;
    @api
    get nextVariant() {
        return this._nextVariant;
    }
    set nextVariant(value) {
        this._nextVariant = value;
        this.parseActionLinks();
    }
    _nextVariant = 'brand';
    @api
    get previousVariant() {
        return this._previousVariant;
    }
    set previousVariant(value) {
        this._previousVariant = value;
        this.parseActionLinks();
    }
    _previousVariant = 'neutral';
    @api alignment = 'right'; // left, center, or right
    @api
    get displayAsGroup() {
        return this._displayAsGroup;
    }
    set displayAsGroup(value) {
        this._displayAsGroup = value;
        this.parseActionLinks();
    }
    _displayAsGroup = false;
    @api
    get footerMeta() {  
        return this._footerMeta;
    }
    set footerMeta(value) {
        this._footerMeta = value;
        this.parseActionLinks();
    }
    _footerMeta = '';
    @api
    get showFooterMeta() {
        return this._showFooterMeta;
    }
    set showFooterMeta(value) {
        this._showFooterMeta = value;
        this.parseActionLinks();
    }
    _showFooterMeta = false;
    
    _availableActions = [];
    
    @api
    get availableActions() {
        return this._availableActions;
    }
    set availableActions(value) {
        this._availableActions = value || [];
        this.parseActionLinks();
    }
    
    parsedActions = [];
    _actionClicked = '';

    @api
    get actionClicked() {
        return this._actionClicked;
    }

    connectedCallback() {
        this.parseActionLinks();
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
                const buttonClass = this.getButtonClass(variant);
                actions.push({
                    name: 'previous',
                    label: label,
                    navigate: 'previous',
                    variant: variant,
                    buttonClass: buttonClass,
                    buttonClassWithMargin: `${buttonClass} slds-m-left_x-small`,
                    key: 'auto-previous',
                    isUrl: false,
                    iconName: null,
                    showIconLeft: false,
                    showIconRight: false
                });
            }
        }
        
        // Append Next/Finish button if checkbox enabled (default to true if undefined)
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
                const variant = this.nextVariant || 'brand';
                const buttonClass = this.getButtonClass(variant);
                actions.push({
                    name: 'next',
                    label: label,
                    navigate: 'next',
                    variant: variant,
                    buttonClass: buttonClass,
                    buttonClassWithMargin: `${buttonClass} slds-m-left_x-small`,
                    key: 'auto-next',
                    isUrl: false,
                    iconName: null,
                    showIconLeft: false,
                    showIconRight: false
                });
            }
        }
        
        // Parse JSON for custom actions - insert between Previous and Next
        let customActions = [];
        if (this.actionLinks) {
            try {
                const parsed = JSON.parse(this.actionLinks);
                if (Array.isArray(parsed)) {
                    customActions = parsed
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
                            const buttonClass = this.getButtonClass(variant);
                            return {
                                ...action,
                                key: `action-${index}`,
                                variant: variant,
                                buttonClass: buttonClass,
                                buttonClassWithMargin: `${buttonClass} slds-m-left_x-small`,
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
            case 'outline-brand':
                return `${baseClass} slds-button_outline-brand`;
            case 'inverse':
                return `${baseClass} slds-button_inverse`;
            case 'neutral':
            default:
                return `${baseClass} slds-button_neutral`;
        }
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
        this.dispatchEvent(new FlowAttributeChangeEvent('actionClicked', actionName));
    }

    get hasActions() {
        return this.parsedActions.length > 0;
    }

    get containerClass() {
        const alignmentClass = this.alignment === 'center' ? 'center' : 
                              this.alignment === 'left' ? 'left' : 'right';
        // When meta is visible, place meta and buttons on opposite sides using space-between
        const metaOppositeClass = this.metaVisible ? 'meta-opposite' : '';
        return `footer-container ${metaOppositeClass} slds-border_top slds-m-top_medium slds-align_absolute-${alignmentClass}`.trim();
    }

    // Footer meta visibility helpers
    get metaVisible() {
        return this.showFooterMeta && this.footerMeta && String(this.footerMeta).trim().length > 0 && this.alignment !== 'center';
    }

    get metaOnLeft() {
        // meta appears on the left when buttons are aligned right
        return this.metaVisible && this.alignment === 'right';
    }

    get metaOnRight() {
        // meta appears on the right when buttons are aligned left
        return this.metaVisible && this.alignment === 'left';
    }

    getButtonClassWithMargin(buttonClass) {
        return `${buttonClass} slds-m-left_x-small`;
    }
}