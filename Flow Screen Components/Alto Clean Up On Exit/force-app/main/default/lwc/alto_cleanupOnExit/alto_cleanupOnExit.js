import { LightningElement, api } from 'lwc';
import deleteRecord from '@salesforce/apex/CleanupOnExitController.deleteRecord';

export default class AltoCleanupOnExit extends LightningElement {
    @api recordId; // Record ID to delete
    @api deleteOnNavigate = false; // Delete when navigating away (back button, next)
    @api deleteOnPageClose = false; // Delete when closing browser/tab
    @api cascadeDelete = false; // Delete child records first
    @api lookupChildRelationships; // CSV list of lookup relationship names
    @api showDebugMessages = false; // Show console logs

    isDeleted = false; // Prevent duplicate deletions

    connectedCallback() {
        if (this.showDebugMessages) {
            console.log('[CleanupOnExit] Component connected. RecordId:', this.recordId);
        }

        // Always listen for page close events since disconnectedCallback won't fire on tab close
        window.addEventListener('beforeunload', this.handleBeforeUnload);
        window.addEventListener('pagehide', this.handlePageHide);
    }

    disconnectedCallback() {
        if (this.showDebugMessages) {
            console.log('[CleanupOnExit] Component disconnected (navigation detected)');
        }

        // Clean up event listeners
        window.removeEventListener('beforeunload', this.handleBeforeUnload);
        window.removeEventListener('pagehide', this.handlePageHide);

        // Delete record on navigation away (disconnectedCallback does NOT fire on tab close)
        if (this.deleteOnNavigate && this.recordId && !this.isDeleted) {
            this.performDelete('navigation');
        }
    }

    handleBeforeUnload = () => {
        if (this.showDebugMessages) {
            console.log('[CleanupOnExit] beforeunload triggered');
        }

        if (this.deleteOnPageClose && this.recordId && !this.isDeleted) {
            // Use sendBeacon for reliable async request during page unload
            this.performDeleteWithBeacon();
        }
    }

    handlePageHide = () => {
        if (this.showDebugMessages) {
            console.log('[CleanupOnExit] pagehide triggered');
        }

        if (this.deleteOnPageClose && this.recordId && !this.isDeleted) {
            this.performDeleteWithBeacon();
        }
    }

    performDelete(trigger) {
        if (!this.recordId) {
            if (this.showDebugMessages) {
                console.warn('[CleanupOnExit] No recordId provided, skipping delete');
            }
            return;
        }

        this.isDeleted = true;

        if (this.showDebugMessages) {
            console.log(`[CleanupOnExit] Deleting record ${this.recordId} (trigger: ${trigger})`);
        }

        // Call Apex to delete record
        deleteRecord({ 
            recordId: this.recordId, 
            cascadeDelete: this.cascadeDelete,
            lookupRelationships: this.lookupChildRelationships 
        })
            .then(result => {
                if (this.showDebugMessages) {
                    console.log('[CleanupOnExit] Delete result:', result);
                }
            })
            .catch(error => {
                // Don't throw error - just log it
                console.warn('[CleanupOnExit] Delete response:', error.body?.message || error.message);
            });
    }

    performDeleteWithBeacon() {
        if (!this.recordId) return;

        this.isDeleted = true;

        if (this.showDebugMessages) {
            console.log(`[CleanupOnExit] Attempting delete for ${this.recordId} during page unload`);
        }

        // Standard delete (may not complete if page closes too quickly)
        // Note: Navigator.sendBeacon() would be more reliable but requires REST endpoint
        deleteRecord({ 
            recordId: this.recordId, 
            cascadeDelete: this.cascadeDelete,
            lookupRelationships: this.lookupChildRelationships 
        })
            .then(result => {
                if (this.showDebugMessages) {
                    console.log('[CleanupOnExit] Delete result:', result);
                }
            })
            .catch(error => {
                // Don't throw error during unload - just log it
                console.warn('[CleanupOnExit] Delete response:', error.body?.message || error.message);
            });
    }
}
