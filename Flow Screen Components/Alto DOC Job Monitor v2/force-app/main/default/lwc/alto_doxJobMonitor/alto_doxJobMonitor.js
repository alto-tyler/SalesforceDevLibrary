import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import getJobData   from '@salesforce/apex/alto_DoxJobMonitorController.getJobData';
import cloneJob     from '@salesforce/apex/alto_DoxJobMonitorController.cloneJob';

const POLL_INTERVAL_MS = 5000;
const ACTIVE_STATUSES  = new Set(['Not Started', 'In Progress']);

export default class AltoDoxJobMonitor extends NavigationMixin(LightningElement) {

    // ── Public API — works for URL-addressable (?recordId=xxx) and Flow input ─

    _recordId    = null;
    _isConnected = false;

    @api
    get recordId() { return this._recordId; }
    set recordId(v) {
        this._recordId = v;
        if (v && this._isConnected) this._load();
    }

    // ── Tracked state ─────────────────────────────────────────────────────────

    @track _job           = null;
    @track _tasks         = [];
    @track _docLinks      = [];
    @track _isLoading     = false;
    @track _isCloning     = false;
    @track _error         = null;
    @track _tasksOpen     = null;   // null = auto; true/false = user override

    // ── Private ───────────────────────────────────────────────────────────────

    _pollTimer        = null;
    _autoPreviewDone  = false;  // fire auto-preview at most once per load

    // ── URL-addressable: read recordId from page state (c__recordId param) ─────

    @wire(CurrentPageReference)
    wiredPageRef(pageRef) {
        const id = pageRef?.state?.c__recordId;
        if (id && id !== this._recordId) {
            this._recordId = id;
            if (this._isConnected) this._load();
        }
    }

    // ── Lifecycle ─────────────────────────────────────────────────────────────

    connectedCallback() {
        this._isConnected = true;
        if (this._recordId) this._load();
    }

    disconnectedCallback() {
        this._isConnected = false;
        this._stopPolling();
    }

    // ── Data ──────────────────────────────────────────────────────────────────

    async _load() {
        this._isLoading = true;
        this._error     = null;
        try {
            const data = await getJobData({ recordId: this._recordId });
            this._applyData(data);
        } catch (e) {
            this._error     = e?.body?.message || e?.message || 'Failed to load job data.';
            this._isLoading = false;
            this._stopPolling();
        }
    }

    async _poll() {
        try {
            const data = await getJobData({ recordId: this._recordId });
            this._applyData(data);
        } catch (e) { /* swallow transient poll errors */ }
    }

    _applyData(data) {
        this._job      = data.job;
        this._tasks    = (data.tasks || []).map(t => ({
            ...t,
            descriptionText: (t.Description || '')
                .replace(/<br\s*\/?>/gi, '\n')
                .replace(/<[^>]+>/g, ''),
            statusClass: `task-status task-status--${
                t.Status === 'Completed' ? 'completed' :
                (t.Status === 'Open' || t.Status === 'Not Started') ? 'open' : 'default'
            }`
        }));
        this._docLinks  = data.docLinks || [];
        this._isLoading = false;
        if (ACTIVE_STATUSES.has(data.job?.DOX__Status__c)) {
            this._startPolling();
        } else {
            this._stopPolling();
            this._maybeAutoPreview();
        }
    }

    _startPolling() {
        if (this._pollTimer) return;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this._pollTimer = setInterval(() => { this._poll(); }, POLL_INTERVAL_MS);
    }

    _stopPolling() {
        if (this._pollTimer) {
            clearInterval(this._pollTimer);
            this._pollTimer = null;
        }
    }

    /** Auto-open the first ContentDocument in the native file preview the first
     *  time the job lands in a non-active (completed/error) state. */
    _maybeAutoPreview() {
        if (this._autoPreviewDone) return;
        const first = this._docLinks.find(d => d.isContentDocument && d.contentDocumentId);
        if (!first) return;
        this._autoPreviewDone = true;
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: { pageName: 'filePreview' },
            state: { recordIds: first.contentDocumentId, selectedRecordId: first.contentDocumentId }
        });
    }

    // ── Computed ──────────────────────────────────────────────────────────────

    get _noRecordId() {
        return !this._recordId && !this._isLoading && !this._error;
    }

    get recordUrl() {
        return this._recordId ? `/lightning/r/DOX__Document_Job__c/${this._recordId}/view` : null;
    }

    get statusBadgeClass() {
        const s = (this.derivedStatus).toLowerCase().replace(/\s+/g, '-');
        const map = { 'not-started': 'not-started', 'in-progress': 'in-progress', 'completed': 'completed', 'error': 'error' };
        const key = map[s] || 'default';
        return `status-badge status-badge--${key}`;
    }

    // If DOX hasn't flipped the status yet but tasks have appeared, show In Progress
    get derivedStatus() {
        const jobStatus = this._job?.DOX__Status__c || '';
        if (jobStatus === 'Not Started' && this._tasks.length > 0) return 'In Progress';
        return jobStatus;
    }

    get isPolling() {
        return !!this._pollTimer;
    }

    get isNotGetFields() {
        return this._job?.DOX__Operation__c !== 'getFields';
    }

    get showEmailStatus() {
        return this.isNotGetFields && !!this._job?.DOX__emailStatus__c;
    }

    get showAdditionalLinkage() {
        return this._job?.DOX__attachDocAsFile__c &&
               this.isNotGetFields &&
               !!this._job?.DOX__Additional_Rec_Linkage_Staus__c;
    }

    get showDocLinks() {
        return this._docLinks.length > 0;
    }

    get hasTasks() {
        return this._tasks.length > 0;
    }

    get showTasksSpinner() {
        return this._tasks.length === 0 && ACTIVE_STATUSES.has(this._job?.DOX__Status__c);
    }

    get isTasksOpen() {
        if (this._tasksOpen !== null) return this._tasksOpen;
        // auto: collapsed when job is Completed
        return this._job?.DOX__Status__c !== 'Completed';
    }

    get tasksToggleIcon() {
        return this.isTasksOpen ? 'utility:chevrondown' : 'utility:chevronright';
    }

    handleToggleTasks() {
        this._tasksOpen = !this.isTasksOpen;
    }

    async handleClone() {
        this._isCloning = true;
        this._error     = null;
        try {
            const newId = await cloneJob({ recordId: this._recordId });
            // Switch to the cloned job in-place — no page reload
            this._recordId       = newId;
            this._job            = null;
            this._tasks          = [];
            this._docLinks       = [];
            this._tasksOpen      = null;
            this._autoPreviewDone = false;
            this._isCloning      = false;
            this._load();
        } catch (e) {
            this._error     = e?.body?.message || e?.message || 'Failed to clone job.';
            this._isCloning = false;
        }
    }

    handleLightningPreview(event) {
        const contentDocumentId = event.currentTarget.dataset.contentDocumentId;
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: { pageName: 'filePreview' },
            state: { recordIds: contentDocumentId, selectedRecordId: contentDocumentId }
        });
    }

    get docLinksWithUrl() {
        return this._docLinks.map(doc => ({
            rawId             : doc.rawId,
            title             : doc.title,
            isContentDocument : !!doc.isContentDocument,
            isAttachment      : !doc.isContentDocument,
            contentDocumentId : doc.contentDocumentId,
            // Attachment: relative servlet URL — LWS-safe, renders inline
            inlineUrl         : !doc.isContentDocument
                ? `/servlet/servlet.FileDownload?file=${doc.rawId}`
                : null,
            downloadUrl       : doc.isContentDocument
                ? `/sfc/servlet.shepherd/document/download/${doc.contentDocumentId}?operationContext=CHATTER`
                : `/servlet/servlet.FileDownload?file=${doc.rawId}`
        }));
    }
}
