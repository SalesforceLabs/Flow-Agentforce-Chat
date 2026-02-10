import { LightningElement, api, track } from 'lwc';

export default class FlowRenderer extends LightningElement {
    
    @api
    get value() {
        return this._value;
    }
    
    set value(value) {
        this._value = value;
        this.initializeFlow();
    }
    
    @api 
    get readOnly() {
        return this._readOnly;
    }
    
    set readOnly(value) {
        this._readOnly = value;
    }
    
    @track _value;
    _readOnly = false;
    flowApiName;
    flowTitle = 'Flow';
    flowInputVariables = [];
    flowStatus = '';
    flowError = '';
    isLoading = false;
    flowCompleted = false;
    flowOutputsJson = '{}';
    sessionId;

    connectedCallback() {
        this.initializeFlow();
    }
    
    initializeFlow() {
        if (this.value) {
            this.flowApiName = this.value.flowApiName;
            this.flowTitle = this.value.flowLabel || 'Flow';
            this.flowStatus = this.value.flowStatus || '';
            this.flowCompleted = this.value.flowCompleted || false;
            
            // Generate a simple session ID if not present
            this.sessionId = this.generateSessionId();
            
            console.log('FlowRenderer initialized:');
            console.log('- Flow API Name:', this.flowApiName);
            console.log('- Read Only:', this.readOnly);
            
            // Parse input variables if provided
            if (this.value.inputVariables) {
                try {
                    const inputVars = JSON.parse(this.value.inputVariables);
                    this.flowInputVariables = Object.keys(inputVars).map(key => ({
                        name: key,
                        type: this.getVariableType(inputVars[key]),
                        value: inputVars[key]
                    }));
                } catch (error) {
                    console.error('Error parsing input variables:', error);
                    this.flowInputVariables = [];
                }
            }
        }
    }

    generateSessionId() {
        return 'flow_' + Math.random().toString(36).substr(2, 9);
    }

    // Determine the type of variable based on its value
    getVariableType(value) {
        if (typeof value === 'string') {
            return 'String';
        } else if (typeof value === 'number') {
            return 'Number';
        } else if (typeof value === 'boolean') {
            return 'Boolean';
        } else if (value instanceof Date) {
            return 'Date';
        } else if (Array.isArray(value)) {
            return 'SObject';
        } else if (typeof value === 'object') {
            return 'SObject';
        }
        return 'String';
    }

    // Handle flow status changes
    handleStatusChange(event) {
        const status = event.detail.status;
        this.flowStatus = status;
        
        console.log('Flow status changed:', status);
        
        switch (status) {
            case 'FINISHED':
            case 'FINISHED_SCREEN':
                console.log('Flow completed successfully');
                this.captureOutputs(event.detail.outputVariables);
                this.dispatchFlowCompleteEvent(status);
                break;
                
            case 'ERROR':
                console.error('Flow encountered an error:', event.detail);
                this.handleFlowError(event.detail);
                break;
                
            case 'PAUSED':
                break;
                
            case 'STARTED':
                break;
                
            default:
                console.log('Unknown flow status:', status);
        }
    }

    captureOutputs(outputVariables) {
        if (outputVariables && outputVariables.length > 0) {
            const outputs = {};
            outputVariables.forEach(variable => {
                if (variable.name && variable.value !== undefined) {
                    outputs[variable.name] = variable.value;
                }
            });
            this.flowOutputsJson = JSON.stringify(outputs);
            console.log('Captured outputs:', this.flowOutputsJson);
        }
    }
    
    // Helper method to dispatch flow complete event and notify agent
    dispatchFlowCompleteEvent(status) {
        this.flowCompleted = true;
        this.dispatchValueChangeEvent();
        
        this.dispatchEvent(new CustomEvent('flowcomplete', { 
            detail: {
                status: status,
                flowApiName: this.flowApiName,
                outputsJson: this.flowOutputsJson
            }
        }));
    }
    
    // Dispatch valuechange event for agent input components
    dispatchValueChangeEvent() {
        console.log('Dispatching valuechange event');
        
        this.dispatchEvent(new CustomEvent('valuechange', {
            detail: {
                value: {
                    flowCompleted: true,
                    flowStatus: this.flowStatus,
                    flowApiName: this.flowApiName,
                    flowLabel: this.flowTitle,
                    outputsJson: this.flowOutputsJson
                }
            }
        }));
    }   
    
    // Helper method to handle flow errors
    handleFlowError(eventDetail) {
        this.flowStatus = 'ERROR';
        this.flowError = eventDetail.message || 'An error occurred while running the flow';
        
        // Still try to capture any partial outputs if available
        if (eventDetail.outputVariables && eventDetail.outputVariables.length > 0) {
            this.captureOutputs(eventDetail.outputVariables);
        }
    }  
  
    // Getter for flow status CSS class
    get flowStatusClass() {
        let baseClass = 'flow-status';
        if (this.flowStatus === 'FINISHED') {
            return baseClass + ' status-finished';
        } else if (this.flowStatus === 'ERROR') {
            return baseClass + ' status-error';
        } else if (this.flowStatus === 'FINISHED_SCREEN') {
            return baseClass + ' status-finished-screen';
        }
        return baseClass;
    }
}