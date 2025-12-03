import LightningDatatable from "lightning/datatable";
import alto_richTextColumnType from "./alto_richTextColumnType.html";
import alto_comboboxColumnType from "./alto_comboboxColumnType.html";
import stylesheet from '@salesforce/resourceUrl/alto_customLightningDatatableStyles';
import {loadStyle} from "lightning/platformResourceLoader";
import { getConstants } from 'c/alto_datatableUtils';

const CONSTANTS = getConstants();   // From alto_datatableUtils : SHOW_DEBUG_INFO, DEBUG_INFO_PREFIX

const SHOW_DEBUG_INFO = CONSTANTS.SHOW_DEBUG_INFO;
const DEBUG_INFO_PREFIX = CONSTANTS.DEBUG_INFO_PREFIX;

/**
 * Custom component that extends LightningDatatable
 * and adds a new column type
 */
export default class alto_customLightningDatatable extends LightningDatatable {
    constructor() {
        super();
        //load style sheets to bypass shadow dom
        Promise.all([
            loadStyle(this, stylesheet)
        ]).then(() => {
            console.log(DEBUG_INFO_PREFIX+"Loaded style sheet");
        }).catch(error => {
            console.error(DEBUG_INFO_PREFIX+'Error loading stylesheet', error);
        });
    }

    static customTypes={
        // custom type definition
        richtext: {
            template: alto_richTextColumnType,
            standardCellLayout: true
        },
        combobox: {
            template: alto_comboboxColumnType,
            standardCellLayout: false,
            typeAttributes: ['editable', 'fieldName', 'keyField', 'keyFieldValue', 'picklistValues', 'alignment']
        }
    }
}
