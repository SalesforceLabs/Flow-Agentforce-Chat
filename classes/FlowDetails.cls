/**
 * @description Data Transfer Object representing the state and configuration of a Salesforce Flow.
 * Used for communication between Invocable Actions and the FlowRenderer LWC.
 */
@JsonAccess(serializable='always' deserializable='always')
global class FlowDetails {
    
    /** @description The unique API name of the Salesforce Flow */
    @InvocableVariable(label='Flow API Name' description='The API name of the flow to launch' required=true)
    global String flowApiName;
    
    /** @description The human-readable label displayed in the chat header */
    @InvocableVariable(label='Flow Label' description='The display label for the flow')
    global String flowLabel;
    
    /** @description JSON string of key-value pairs representing input variables */
    @InvocableVariable(label='Input Variables' description='JSON string of input variables for the flow')
    global String inputVariables;
    
    /** @description JSON string containing the captured output variables upon completion */
    @InvocableVariable(label='Outputs JSON' description='JSON string of captured output variables')
    global String outputsJson;
    
    /** @description The current execution status (e.g., STARTED, FINISHED, ERROR) */
    @InvocableVariable(label='Flow Status' description='Current status of the flow')
    global String flowStatus;

    /** @description Flag indicating if the flow reached its end state */
    @InvocableVariable(label='Flow Completed' description='Whether the flow has completed')
    global Boolean flowCompleted;
}