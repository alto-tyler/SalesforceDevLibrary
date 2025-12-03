import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import getContentVersionDetails from '@salesforce/apex/DocumentJobMonitorHelper.getContentVersionDetails';

const DOCUMENT_JOB_FIELDS = [
    'DOX__Document_Job__c.DOX__Status__c',
    'DOX__Document_Job__c.DOX__Attachment_Id__c',
    'DOX__Document_Job__c.DOX__multipleAttachmentIDs__c',
    'DOX__Document_Job__c.Name'
];

export default class Alto_DocumentJobMonitor extends NavigationMixin(LightningElement) {
    @api documentJobId;
    @api headerText = '';
    @api generatedItemsLabel = 'Generated Documents';
    @api generatingText = 'Document generation in progress. This page will update automatically.';
    
    documentJob;
    wiredDocumentJobResult;
    contentVersions = [];
    contentVersionWires = [];
    error;
    isLoading = true;
    pollingInterval;
    hasFetchedFiles = false;

    connectedCallback() {
        // Poll every 3 seconds if status is not Completed or Exception
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.pollingInterval = setInterval(() => {
            if (!this.isCompleted && !this.isException && this.documentJobId && this.wiredDocumentJobResult) {
                refreshApex(this.wiredDocumentJobResult);
            } else if ((this.isCompleted || this.isException) && this.pollingInterval) {
                clearInterval(this.pollingInterval);
                this.pollingInterval = null;
            }
        }, 3000);
    }

    disconnectedCallback() {
        if (this.pollingInterval) {
            clearInterval(this.pollingInterval);
            this.pollingInterval = null;
        }
    }

    @wire(getRecord, { recordId: '$documentJobId', fields: DOCUMENT_JOB_FIELDS })
    wiredDocumentJob(result) {
        this.wiredDocumentJobResult = result;
        const { error, data } = result;
        
        if (data) {
            this.documentJob = data;
            this.error = undefined;
            console.log('Document Job Data:', data);
            this.processDocumentJob(data);
        } else if (error) {
            this.error = error;
            this.documentJob = undefined;
            this.isLoading = false;
        }
    }

    processDocumentJob(data) {
        const status = data.fields.DOX__Status__c?.value;
        const attachmentId = data.fields.DOX__Attachment_Id__c?.value;
        const multipleAttachmentIds = data.fields.DOX__multipleAttachmentIDs__c?.value;

        if (status === 'Completed') {
            this.fetchContentVersionsWithRetry(attachmentId, multipleAttachmentIds);
            if (this.pollingInterval) {
                clearInterval(this.pollingInterval);
                this.pollingInterval = null;
            }
        } else if (status === 'Exception') {
            this.isLoading = false;
            if (this.pollingInterval) {
                clearInterval(this.pollingInterval);
                this.pollingInterval = null;
            }
        } else {
            this.isLoading = false;
        }
    }

    async fetchContentVersionsWithRetry(attachmentId, multipleAttachmentIds, retryCount = 0) {
        const maxRetries = 5;
        const hasAttachments = attachmentId || multipleAttachmentIds;
        
        if (!hasAttachments && retryCount < maxRetries) {
            // Wait 1 second before retrying
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            await new Promise(resolve => setTimeout(resolve, 1000));
            
            // Refresh the document job to get updated attachment IDs
            if (this.wiredDocumentJobResult) {
                await refreshApex(this.wiredDocumentJobResult);
                const updatedAttachmentId = this.documentJob?.fields?.DOX__Attachment_Id__c?.value;
                const updatedMultipleAttachmentIds = this.documentJob?.fields?.DOX__multipleAttachmentIDs__c?.value;
                
                return this.fetchContentVersionsWithRetry(updatedAttachmentId, updatedMultipleAttachmentIds, retryCount + 1);
            }
        }
        
        // After retries or if we have attachments, proceed with fetching
        // Mark that we've finished retrying
        this.hasFetchedFiles = true;
        return this.fetchContentVersions(attachmentId, multipleAttachmentIds);
    }

    async fetchContentVersions(attachmentId, multipleAttachmentIds) {
        const ids = [];
        
        if (attachmentId) {
            ids.push(attachmentId);
        }
        
        if (multipleAttachmentIds) {
            const multipleIds = multipleAttachmentIds.split(',').map(id => id.trim()).filter(Boolean);
            ids.push(...multipleIds);
        }

        // Remove duplicate IDs
        const uniqueIds = [...new Set(ids)];

        if (uniqueIds.length === 0) {
            this.isLoading = false;
            return;
        }

        try {
            // Use Apex to fetch ContentVersion details with proper authentication
            const results = await getContentVersionDetails({ contentVersionIds: uniqueIds });
            this.contentVersions = results;
        } catch (error) {
            console.error('Error fetching content versions:', error);
            this.error = error;
            // Set placeholder data on error
            this.contentVersions = uniqueIds.map(id => ({
                id,
                contentDocumentId: null,
                title: 'Error loading'
            }));
        } finally {
            this.isLoading = false;
        }
    }

    get jobStatus() {
        return this.documentJob?.fields?.DOX__Status__c?.value;
    }

    get jobName() {
        return this.documentJob?.fields?.Name?.value;
    }

    get displayHeader() {
        return this.headerText || this.jobName;
    }

    get isCompleted() {
        return this.jobStatus === 'Completed';
    }

    get isException() {
        return this.jobStatus === 'Exception';
    }

    get hasFiles() {
        return this.contentVersions && this.contentVersions.length > 0;
    }

    get showNoFilesWarning() {
        return this.hasFetchedFiles && !this.hasFiles;
    }

    get monitorJobUrl() {
        return `/apex/DOX__MonitorJob?job=${this.documentJobId}`;
    }

    previewHandler(event) {
        const contentVersionId = event.target.dataset.id;
        const contentDocumentId = event.target.dataset.documentid;
        
        console.log('Preview handler:', { contentVersionId, contentDocumentId });
        
        // Use filePreview navigation
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: contentDocumentId
            }
        });
    }
}
