import { LightningElement, api } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class SimpleCalculator extends LightningElement {
    @api number1 = 0;
    @api number2 = 0;
    @api operation = 'add';
    @api result = 0;

    connectedCallback() {
        this.calculate();
    }

    @api
    get inputNumber1() {
        return this.number1;
    }
    set inputNumber1(value) {
        this.number1 = value ? Number(value) : 0;
        this.calculate();
    }

    @api
    get inputNumber2() {
        return this.number2;
    }
    set inputNumber2(value) {
        this.number2 = value ? Number(value) : 0;
        this.calculate();
    }

    @api
    get inputOperation() {
        return this.operation;
    }
    set inputOperation(value) {
        this.operation = value ? value.toLowerCase() : 'add';
        this.calculate();
    }

    calculate() {
        console.log('[SimpleCalculator] Calculate triggered');
        console.log('[SimpleCalculator] Inputs:', {
            number1: this.number1,
            number2: this.number2,
            operation: this.operation
        });
        
        let calculatedResult;
        
        switch(this.operation.toLowerCase()) {
            case 'add':
            case '+':
                calculatedResult = this.number1 + this.number2;
                console.log('[SimpleCalculator] Operation: Add, Result:', calculatedResult);
                break;
            case 'subtract':
            case '-':
                calculatedResult = this.number1 - this.number2;
                console.log('[SimpleCalculator] Operation: Subtract, Result:', calculatedResult);
                break;
            case 'multiply':
            case '*':
            case 'times':
                calculatedResult = this.number1 * this.number2;
                console.log('[SimpleCalculator] Operation: Multiply, Result:', calculatedResult);
                break;
            case 'divide':
            case '/':
                calculatedResult = this.number2 !== 0 ? this.number1 / this.number2 : 0;
                console.log('[SimpleCalculator] Operation: Divide, Result:', calculatedResult);
                if (this.number2 === 0) {
                    console.warn('[SimpleCalculator] Division by zero detected, result set to 0');
                }
                break;
            default:
                calculatedResult = this.number1 + this.number2;
                console.log('[SimpleCalculator] Operation: Default (Add), Result:', calculatedResult);
        }
        
        this.result = calculatedResult;
        console.log('[SimpleCalculator] Final result set:', this.result);
        
        // Dispatch the result back to Flow
        const attributeChangeEvent = new FlowAttributeChangeEvent('result', calculatedResult);
        this.dispatchEvent(attributeChangeEvent);
        console.log('[SimpleCalculator] Result dispatched to Flow');
    }

    get operationSymbol() {
        switch(this.operation.toLowerCase()) {
            case 'add': return '+';
            case 'subtract': return '-';
            case 'multiply': return '×';
            case 'times': return '×';
            case 'divide': return '÷';
            default: return '+';
        }
    }
}
