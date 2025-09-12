global class FlowOutputHandler {
    
    // Static variable to temporarily store flow outputs (could be enhanced with custom objects)
    @TestVisible
    private static Map<String, String> flowOutputsCache = new Map<String, String>();
    
    // AuraEnabled method for LWC calls
    @AuraEnabled
    global static List<FlowOutputResult> storeFlowOutputsFromLWC(List<FlowOutputRequest> requests) {
        return storeFlowOutputsInternal(requests);
    }
    
    @InvocableMethod(label='Store Flow Outputs' description='Stores flow outputs for later retrieval')
    global static List<FlowOutputResult> storeFlowOutputs(List<FlowOutputRequest> requests) {
        return storeFlowOutputsInternal(requests);
    }
    
    // Internal method that both @AuraEnabled and @InvocableMethod can call
    private static List<FlowOutputResult> storeFlowOutputsInternal(List<FlowOutputRequest> requests) {
        List<FlowOutputResult> results = new List<FlowOutputResult>();
        
        for (FlowOutputRequest request : requests) {
            FlowOutputResult result = new FlowOutputResult();
            
            try {
                // Generate a unique key for this flow execution
                String outputKey = generateOutputKey(request.flowApiName, request.sessionId);
                
                // Store the outputs in cache (in production, consider using custom objects)
                flowOutputsCache.put(outputKey, request.outputJson);
                
                result.success = true;
                result.outputKey = outputKey;
                result.message = 'Flow outputs stored successfully';
                
                // Optional: Log or create a record for persistence
                System.debug('Flow outputs stored for key: ' + outputKey);
                System.debug('Outputs: ' + request.outputJson);
                
            } catch (Exception e) {
                result.success = false;
                result.message = 'Error storing flow outputs: ' + e.getMessage();
                System.debug(LoggingLevel.ERROR, 'Error storing flow outputs: ' + e.getMessage());
            }
            
            results.add(result);
        }
        
        return results;
    }
    
    // Public method to retrieve flow outputs
    global static List<FlowOutputRetriever.FlowOutputRetrievalResult> retrieveFlowOutputs(List<FlowOutputRetriever.FlowOutputRetrievalRequest> requests) {
        List<FlowOutputRetriever.FlowOutputRetrievalResult> results = new List<FlowOutputRetriever.FlowOutputRetrievalResult>();
        
        for (FlowOutputRetriever.FlowOutputRetrievalRequest request : requests) {
            FlowOutputRetriever.FlowOutputRetrievalResult result = new FlowOutputRetriever.FlowOutputRetrievalResult();
            
            try {
                String outputKey = request.outputKey != null ? 
                    request.outputKey : 
                    generateOutputKey(request.flowApiName, request.sessionId);
                
                if (flowOutputsCache.containsKey(outputKey)) {
                    result.outputJson = flowOutputsCache.get(outputKey);
                    result.success = true;
                    result.message = 'Flow outputs retrieved successfully';
                } else {
                    result.outputJson = '{}';
                    result.success = false;
                    result.message = 'No outputs found for the specified flow';
                }
                
            } catch (Exception e) {
                result.success = false;
                result.message = 'Error retrieving flow outputs: ' + e.getMessage();
                result.outputJson = '{}';
                System.debug(LoggingLevel.ERROR, 'Error retrieving flow outputs: ' + e.getMessage());
            }
            
            results.add(result);
        }
        
        return results;
    }
    
    // Helper method to generate a unique key for flow outputs
    private static String generateOutputKey(String flowApiName, String sessionId) {
        if (String.isBlank(sessionId)) {
            sessionId = String.valueOf(DateTime.now().getTime());
        }
        return flowApiName + '_' + sessionId + '_' + UserInfo.getUserId();
    }
    
    // Request class for storing flow outputs
    @JsonAccess(serializable='always' deserializable='always')
    global class FlowOutputRequest {
        @InvocableVariable(label='Flow API Name' description='The API name of the flow' required=true)
        global String flowApiName;
        
        @InvocableVariable(label='Output JSON' description='The flow outputs as JSON string' required=true)
        global String outputJson;
        
        @InvocableVariable(label='Session ID' description='Optional session identifier for grouping outputs')
        global String sessionId;
    }
    
    // Result class for storing flow outputs
    @JsonAccess(serializable='always' deserializable='always')
    global class FlowOutputResult {
        @InvocableVariable(label='Success' description='Whether the operation was successful')
        global Boolean success;
        
        @InvocableVariable(label='Output Key' description='The key used to store the outputs')
        global String outputKey;
        
        @InvocableVariable(label='Message' description='Result message')
        global String message;
    }
    

}
