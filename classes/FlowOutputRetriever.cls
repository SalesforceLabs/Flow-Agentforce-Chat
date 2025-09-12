global class FlowOutputRetriever {
    
    @InvocableMethod(label='Retrieve Flow Outputs' description='Retrieves previously stored flow outputs')
    global static List<FlowOutputRetrievalResult> retrieveFlowOutputs(List<FlowOutputRetrievalRequest> requests) {
        // Delegate to FlowOutputHandler
        return FlowOutputHandler.retrieveFlowOutputs(requests);
    }
    
    // Request class for retrieving flow outputs
    @JsonAccess(serializable='always' deserializable='always')
    global class FlowOutputRetrievalRequest {
        @InvocableVariable(label='Output Key' description='The key used to store the outputs')
        global String outputKey;
        
        @InvocableVariable(label='Flow API Name' description='The API name of the flow')
        global String flowApiName;
        
        @InvocableVariable(label='Session ID' description='Optional session identifier')
        global String sessionId;
    }
    
    // Result class for retrieving flow outputs
    @JsonAccess(serializable='always' deserializable='always')
    global class FlowOutputRetrievalResult {
        @InvocableVariable(label='Output JSON' description='The retrieved flow outputs as JSON string')
        global String outputJson;
        
        @InvocableVariable(label='Success' description='Whether the operation was successful')
        global Boolean success;
        
        @InvocableVariable(label='Message' description='Result message')
        global String message;
    }
}
