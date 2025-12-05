// Import custom labels
import LABEL_PREPARING from '@salesforce/label/c.alto_DynLookup_Preparing';
import LABEL_GETTING_CONTEXT from '@salesforce/label/c.alto_DynLookup_GettingContext';
import LABEL_APPLYING_PARENT from '@salesforce/label/c.alto_DynLookup_ApplyingParent';
import LABEL_WAITING_PARENT from '@salesforce/label/c.alto_DynLookup_WaitingParent';
import LABEL_FINDING_MATCH from '@salesforce/label/c.alto_DynLookup_FindingMatch';
import LABEL_PROCESSING_BARCODE from '@salesforce/label/c.alto_DynLookup_ProcessingBarcode';
import LABEL_RETRIEVING_RECORDS from '@salesforce/label/c.alto_DynLookup_RetrievingRecords';
import LABEL_NO_RECORDS_FOUND from '@salesforce/label/c.alto_DynLookup_NoRecordsFound';
import LABEL_ERROR_SOBJECT from '@salesforce/label/c.alto_DynLookup_ErrorSObject';
import LABEL_ERROR_RECORDS from '@salesforce/label/c.alto_DynLookup_ErrorRecords';
import LABEL_ERROR_SCANNING from '@salesforce/label/c.alto_DynLookup_ErrorScanning';
import LABEL_FIELD_REQUIRED from '@salesforce/label/c.alto_DynLookup_FieldRequired';
import LABEL_LOOKUP_NOT_READY from '@salesforce/label/c.alto_DynLookup_LookupNotReady';
import LABEL_USER_DISMISSED from '@salesforce/label/c.alto_DynLookup_UserDismissed';
import LABEL_BARCODE_UNAVAILABLE from '@salesforce/label/c.alto_DynLookup_BarcodeUnavailable';
import LABEL_SEARCH from '@salesforce/label/c.alto_DynLookup_Search';
import LABEL_REMOVE_OPTION from '@salesforce/label/c.alto_DynLookup_RemoveOption';
import LABEL_ERROR from '@salesforce/label/c.alto_DynLookup_Error';
import LABEL_SUCCESS from '@salesforce/label/c.alto_DynLookup_Success';
import LABEL_SCAN_RECEIVED from '@salesforce/label/c.alto_DynLookup_ScanReceived';
import LABEL_SCAN_ERROR from '@salesforce/label/c.alto_DynLookup_ScanError';
import LABEL_HELP_TEXT_DESKTOP from '@salesforce/label/c.alto_DynLookup_HelpTextDesktop';
import LABEL_HELP_TEXT_MOBILE from '@salesforce/label/c.alto_DynLookup_HelpTextMobile';

// Export labels object for use in component with fallbacks
export const LABELS = {
    preparing: LABEL_PREPARING || 'Preparing lookup...',
    gettingContext: LABEL_GETTING_CONTEXT || 'Getting context...',
    applyingParent: LABEL_APPLYING_PARENT || 'Applying parent values...',
    waitingParent: LABEL_WAITING_PARENT || 'Waiting for parent...',
    findingMatch: LABEL_FINDING_MATCH || 'Finding match...',
    processingBarcode: LABEL_PROCESSING_BARCODE || 'Processing scanned barcode...',
    retrievingRecords: LABEL_RETRIEVING_RECORDS || 'Retrieving records...',
    noRecordsFound: LABEL_NO_RECORDS_FOUND || 'No Records Found',
    errorSObject: LABEL_ERROR_SOBJECT || 'Error fetching SObject details',
    errorRecords: LABEL_ERROR_RECORDS || 'Error fetching records',
    errorScanning: LABEL_ERROR_SCANNING || 'Error during scanning',
    fieldRequired: LABEL_FIELD_REQUIRED || 'Field is required.',
    lookupNotReady: LABEL_LOOKUP_NOT_READY || 'Lookup was not ready before proceeding.',
    userDismissed: LABEL_USER_DISMISSED || 'User terminated scanning session.',
    barcodeUnavailable: LABEL_BARCODE_UNAVAILABLE || 'BarcodeScanner unavailable. Non-mobile device?',
    search: LABEL_SEARCH || 'Search',
    removeOption: LABEL_REMOVE_OPTION || 'Remove selected option',
    error: LABEL_ERROR || 'Error',
    success: LABEL_SUCCESS || 'Success',
    scanReceived: LABEL_SCAN_RECEIVED || 'Scan event received',
    scanError: LABEL_SCAN_ERROR || 'Scan error',
    helpTextDesktop: LABEL_HELP_TEXT_DESKTOP || 'Press Delete or Backspace to clear. Double-click to edit.',
    helpTextMobile: LABEL_HELP_TEXT_MOBILE || 'Double-tap to edit.'
};
