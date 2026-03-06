import { LightningElement, api } from 'lwc';

export default class AltoDisablePullToRefresh extends LightningElement {
    @api enablePullToRefresh = false;
    @api enablePullToShowMore = false;
    
    connectedCallback() {
        // Dispatch the updateScrollSettings event to disable pull-to-refresh
        this.disableScrollFeatures();
    }

    disableScrollFeatures() {
        const detail = {};
        
        detail.isPullToRefreshEnabled = this.enablePullToRefresh;
        detail.isPullToShowMoreEnabled = this.enablePullToShowMore;
        
        const updateScrollSettingsEvent = new CustomEvent('updateScrollSettings', {
            detail: detail,
            bubbles: true,
            composed: true
        });

        this.dispatchEvent(updateScrollSettingsEvent);
    }
}
