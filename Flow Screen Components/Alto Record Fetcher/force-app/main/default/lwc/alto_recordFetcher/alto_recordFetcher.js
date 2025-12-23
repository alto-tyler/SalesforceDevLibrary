import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class RecordFetcher extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api fieldList = '';
    @api outputRecord;
    
    fieldsArray = [];
    
    connectedCallback() {
        console.log('[RecordFetcher] Connected - recordId:', this.recordId, 'objectApiName:', this.objectApiName, 'fieldList:', this.fieldList);
        if (this.fieldList && this.objectApiName) {
            // Parse CSV field list and ensure they have object prefix
            this.fieldsArray = this.fieldList
                .split(',')
                .map(field => {
                    field = field.trim();
                    // If field doesn't start with a relationship (no dot), prefix with object name
                    if (!field.includes('.')) {
                        return `${this.objectApiName}.${field}`;
                    }
                    return field;
                })
                .filter(field => field.length > 0);
            console.log('[RecordFetcher] Parsed fields array:', this.fieldsArray);
        }
    }

    @wire(getRecord, { 
        recordId: '$recordId', 
        fields: '$fieldsArray' 
    })
    wiredRecord({ error, data }) {
        // If recordId is null or empty, dispatch empty object with all requested fields cleared
        if (!this.recordId) {
            console.log('[RecordFetcher] RecordId is empty/null - building empty record structure');
            // Build empty record with all requested fields as empty strings
            const emptyRecord = { Id: '' };
            
            // Parse fieldList and create empty structure matching expected output
            if (this.fieldList) {
                this.fieldList.split(',').forEach(fieldPath => {
                    fieldPath = fieldPath.trim();
                    
                    // Handle relationship fields (e.g., Account.Owner.Name)
                    if (fieldPath.includes('.')) {
                        const parts = fieldPath.split('.');
                        let currentLevel = emptyRecord;
                        
                        // Skip first part if it's the object name
                        const startIndex = parts[0] === this.objectApiName ? 1 : 0;
                        
                        // Build nested structure for relationships
                        for (let i = startIndex; i < parts.length - 1; i++) {
                            const relationshipName = parts[i];
                            if (!currentLevel[relationshipName]) {
                                currentLevel[relationshipName] = {};
                            }
                            currentLevel = currentLevel[relationshipName];
                        }
                        
                        // Set final field to empty string
                        const finalFieldName = parts[parts.length - 1];
                        currentLevel[finalFieldName] = '';
                    } else {
                        // Direct field - set to empty string
                        emptyRecord[fieldPath] = '';
                    }
                });
            }
            
            console.log('[RecordFetcher] Empty record dispatched:', JSON.stringify(emptyRecord));
            this.outputRecord = emptyRecord;
            const attributeChangeEvent = new FlowAttributeChangeEvent('outputRecord', emptyRecord);
            this.dispatchEvent(attributeChangeEvent);
            return;
        }
        
        if (data) {
            // Extract field values including nested relationships from wire format
            const processedRecord = {
                Id: data.id
            };
            
            Object.keys(data.fields).forEach(fieldKey => {
                const fieldData = data.fields[fieldKey];
                
                // Handle relationship fields (e.g., Account.Parent.Owner.Name)
                if (fieldKey.includes('.')) {
                    const parts = fieldKey.split('.');
                    let currentLevel = processedRecord;
                    
                    // Navigate through all relationship levels except the last (which is the field)
                    for (let i = 0; i < parts.length - 1; i++) {
                        const relationshipName = parts[i];
                        
                        // Create relationship object if it doesn't exist
                        if (!currentLevel[relationshipName]) {
                            currentLevel[relationshipName] = {};
                        }
                        
                        // Move to next level
                        currentLevel = currentLevel[relationshipName];
                    }
                    
                    // Set the final field value
                    const finalFieldName = parts[parts.length - 1];
                    currentLevel[finalFieldName] = fieldData.value;
                } else {
                    // Direct field
                    processedRecord[fieldKey] = fieldData.value;
                }
            });
            console.log('[RecordFetcher] Fetched Record:', JSON.stringify(processedRecord));
            this.outputRecord = processedRecord;
            
            // Dispatch to Flow
            const attributeChangeEvent = new FlowAttributeChangeEvent('outputRecord', processedRecord);
            this.dispatchEvent(attributeChangeEvent);
            
        } else if (error) {
            console.error('[RecordFetcher] Error fetching record:', error);
            this.outputRecord = null;
            
            const attributeChangeEvent = new FlowAttributeChangeEvent('outputRecord', null);
            this.dispatchEvent(attributeChangeEvent);
        }
    }
}
