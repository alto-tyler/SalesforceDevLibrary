import { LightningElement, api } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';


export default class RollupNumbers extends LightningElement {
    // Inputs from Flow
    _records = [];
    _numberFieldApiName1 = '';
    _numberFieldApiName2 = '';
    _rollupOption1 = 'SUM';
    _rollupOption2 = 'SUM';

    // Internal results for two fields
    _result1 = null;
    _result2 = null;

    // Generic records input from Flow (matches meta `records` property)
    @api
    get records() {
        return this._records || [];
    }
    set records(val) {
        this._records = Array.isArray(val) ? val : (val ? [val] : []);
        this.computeAndNotify();
    }

    // Field 1
    @api
    get numberFieldApiName1() {
        return this._numberFieldApiName1;
    }
    set numberFieldApiName1(val) {
        this._numberFieldApiName1 = val || '';
        this.computeAndNotify();
    }

    @api
    get rollupOption1() {
        return this._rollupOption1;
    }
    set rollupOption1(val) {
        this._rollupOption1 = (val || 'SUM').toString().toUpperCase();
        this.computeAndNotify();
    }

    // Field 2
    @api
    get numberFieldApiName2() {
        return this._numberFieldApiName2;
    }
    set numberFieldApiName2(val) {
        this._numberFieldApiName2 = val || '';
        this.computeAndNotify();
    }

    @api
    get rollupOption2() {
        return this._rollupOption2;
    }
    set rollupOption2(val) {
        this._rollupOption2 = (val || 'SUM').toString().toUpperCase();
        this.computeAndNotify();
    }

    // Flow-visible outputs
    @api
    get result1() {
        return this._result1;
    }
    set result1(val) {

        this._result1 = val;
        this.notifyFlow('result1', this._result1);
    }

    @api
    get result2() {
        return this._result2;
    }
    set result2(val) {
        console.log('set result2:', val);
        this._result2 = val;
        this.notifyFlow('result2', this._result2);
    }

    // Derived UI helpers
    get resultDisplay1() {
        return (this._result1 === null || typeof this._result1 === 'undefined') ? '-' : String(this._result1);
    }

    get resultDisplay2() {
        return (this._result2 === null || typeof this._result2 === 'undefined') ? '-' : String(this._result2);
    }

    get valueCount1() {
        const vals = this.extractNumericValuesForField(this._numberFieldApiName1);
        return vals.length;
    }

    get valueCount2() {
        const vals = this.extractNumericValuesForField(this._numberFieldApiName2);
        return vals.length;
    }

    get recordsCount() {
        return (this._records || []).length;
    }

    // Compute the rollup and notify Flow if changed
    computeAndNotify() {
        console.log('computeAndNotify called');
        const prev1 = this._result1;
        const prev2 = this._result2;

        this._result1 = this.computeRollupForField(this._numberFieldApiName1, this._rollupOption1);
        this._result2 = this.computeRollupForField(this._numberFieldApiName2, this._rollupOption2);

        if (prev1 !== this._result1) {
            this.notifyFlow('result1', this._result1);
        }
        if (prev2 !== this._result2) {
            this.notifyFlow('result2', this._result2);
        }
    }

    notifyFlow(name, value) {
        // Flow screen components listen for `flowAttributeChange` events to capture output variable changes
        try {
            console.log('notifyFlow called for', name, 'with value:', value);
            this.dispatchEvent(new FlowAttributeChangeEvent(name, value));
        } catch (e) {
            // swallow - dispatch may fail in non-Flow contexts
        }
    }

    // Extract numeric values from the record collection for the specified field
    extractNumericValuesForField(field) {
        if (!field || !this._records || this._records.length === 0) return [];

        const out = [];
        for (const rec of this._records) {
            if (!rec) continue;
            let raw = undefined;

            // Common Flow record shapes: either flat (rec.MyField__c) or with `fields` metadata (rec.fields.MyField__c.value)
            if (Object.prototype.hasOwnProperty.call(rec, field)) {
                raw = rec[field];
            } else if (rec.fields && rec.fields[field] && Object.prototype.hasOwnProperty.call(rec.fields[field], 'value')) {
                raw = rec.fields[field].value;
            }

            if (raw === null || typeof raw === 'undefined') continue;

            const num = Number(raw);
            if (!Number.isFinite(num)) continue;
            out.push(num);
        }

        return out;
    }

    computeRollupForField(field, option) {
        const vals = this.extractNumericValuesForField(field);
        if (!vals || vals.length === 0) {
            if ((option || '').toString().toUpperCase() === 'COUNT') {
                return (this._records || []).length || 0;
            }
            return null;
        }

        const opt = (option || 'SUM').toString().toUpperCase();
        switch (opt) {
            case 'SUM': {
                const s = vals.reduce((acc, v) => acc + v, 0);
                return s;
            }
            case 'AVERAGE': {
                const s = vals.reduce((acc, v) => acc + v, 0);
                return s / vals.length;
            }
            case 'MEDIAN': {
                const sorted = vals.slice().sort((a, b) => a - b);
                const mid = Math.floor(sorted.length / 2);
                if (sorted.length % 2 === 1) return sorted[mid];
                return (sorted[mid - 1] + sorted[mid]) / 2;
            }
            case 'MIN': {
                return Math.min(...vals);
            }
            case 'MAX': {
                return Math.max(...vals);
            }
            case 'COUNT': {
                return (this._records || []).length || 0;
            }
            default: {
                const s = vals.reduce((acc, v) => acc + v, 0);
                return s;
            }
        }
    }
}
