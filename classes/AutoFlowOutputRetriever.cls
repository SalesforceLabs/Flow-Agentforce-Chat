global class AutoFlowOutputRetriever {
    
    @InvocableMethod(label='Auto Retrieve Flow Outputs by Session' description='Automatically retrieves all flow outputs for a given session ID')
    global static List<AutoRetrievalResult> autoRetrieveBySession(List<AutoRetrievalRequest> requests) {
        List<AutoRetrievalResult> results = new List<AutoRetrievalResult>();
        
        for (AutoRetrievalRequest request : requests) {
            AutoRetrievalResult result = new AutoRetrievalResult();
            
            try {
                String flowApiName = request.flowApiName;
                if (String.isBlank(flowApiName) && String.isNotBlank(request.sessionId)) {
                    flowApiName = extractFlowApiNameFromSession(request.sessionId);
                }
                
                if (String.isNotBlank(flowApiName)) {
                    // Use FlowOutputRetriever
                    List<FlowOutputRetriever.FlowOutputRetrievalRequest> retrieveRequests = 
                        new List<FlowOutputRetriever.FlowOutputRetrievalRequest>();
                    
                    FlowOutputRetriever.FlowOutputRetrievalRequest retrieveRequest = 
                        new FlowOutputRetriever.FlowOutputRetrievalRequest();
                    retrieveRequest.flowApiName = flowApiName;
                    retrieveRequest.sessionId = request.sessionId;
                    retrieveRequests.add(retrieveRequest);
                    
                    List<FlowOutputRetriever.FlowOutputRetrievalResult> retrieveResults = 
                        FlowOutputRetriever.retrieveFlowOutputs(retrieveRequests);
                    
                    if (!retrieveResults.isEmpty() && retrieveResults[0].success) {
                        result.success = true;
                        result.outputJson = retrieveResults[0].outputJson;
                        result.flowApiName = flowApiName;
                        result.sessionId = request.sessionId;
                        result.message = 'Flow outputs retrieved successfully';
                        result.formattedOutputs = formatOutputsForDisplay(result.outputJson);
                    } else {
                        result.success = false;
                        result.outputJson = '{}';
                        result.message = 'No outputs found for session: ' + request.sessionId;
                        result.formattedOutputs = 'No outputs available';
                    }
                } else {
                    result.success = false;
                    result.outputJson = '{}';
                    result.message = 'Could not determine flow API name from session ID';
                    result.formattedOutputs = 'Unable to retrieve outputs';
                }
                
                result.retrievalTimestamp = DateTime.now().format();
                
            } catch (Exception e) {
                result.success = false;
                result.outputJson = '{}';
                result.message = 'Error retrieving outputs: ' + e.getMessage();
                result.formattedOutputs = 'Error occurred during retrieval';
            }
            
            results.add(result);
        }
        
        return results;
    }
    
    private static String extractFlowApiNameFromSession(String sessionId) {
        if (String.isNotBlank(sessionId) && sessionId.contains('_')) {
            List<String> parts = sessionId.split('_');
            if (!parts.isEmpty()) {
                return parts[0];
            }
        }
        return null;
    }
    
    private static String formatOutputsForDisplay(String outputJson) {
        try {
            if (String.isBlank(outputJson) || outputJson == '{}') {
                return 'No outputs from this flow';
            }
            
            Map<String, Object> outputData = (Map<String, Object>) JSON.deserializeUntyped(outputJson);
            
            if (outputData.isEmpty()) {
                return 'No outputs from this flow';
            }
            
            List<String> formattedLines = new List<String>();
            
            // Check if this is the new enhanced format with outputs/metadata/flowInfo
            if (outputData.containsKey('outputs') && outputData.containsKey('flowInfo')) {
                Map<String, Object> outputs = (Map<String, Object>) outputData.get('outputs');
                Map<String, Object> metadata = (Map<String, Object>) outputData.get('metadata');
                Map<String, Object> flowInfo = (Map<String, Object>) outputData.get('flowInfo');
                
                // Add flow information
                formattedLines.add('=== FLOW INFORMATION ===');
                if (flowInfo.containsKey('flowTitle')) {
                    formattedLines.add('Flow: ' + flowInfo.get('flowTitle'));
                }
                if (flowInfo.containsKey('completedAt')) {
                    formattedLines.add('Completed: ' + flowInfo.get('completedAt'));
                }
                if (flowInfo.containsKey('outputCount')) {
                    formattedLines.add('Output Count: ' + flowInfo.get('outputCount'));
                }
                
                if (!outputs.isEmpty()) {
                    formattedLines.add('\n=== FLOW OUTPUTS ===');
                    for (String key : outputs.keySet()) {
                        Object value = outputs.get(key);
                        String valueStr = value != null ? String.valueOf(value) : 'null';
                        
                        // Add data type information if available
                        if (metadata != null && metadata.containsKey(key)) {
                            Map<String, Object> varMetadata = (Map<String, Object>) metadata.get(key);
                            String dataType = (String) varMetadata.get('dataType');
                            formattedLines.add(key + ' (' + dataType + '): ' + valueStr);
                        } else {
                            formattedLines.add(key + ': ' + valueStr);
                        }
                    }
                } else {
                    formattedLines.add('\n=== NO OUTPUTS ===');
                    if (flowInfo.containsKey('note')) {
                        formattedLines.add((String) flowInfo.get('note'));
                    }
                }
            } else {
                // Handle legacy format (simple key-value pairs)
                formattedLines.add('=== FLOW OUTPUTS (Legacy Format) ===');
                for (String key : outputData.keySet()) {
                    Object value = outputData.get(key);
                    String valueStr = value != null ? String.valueOf(value) : 'null';
                    formattedLines.add(key + ': ' + valueStr);
                }
            }
            
            return String.join(formattedLines, '\n');
            
        } catch (Exception e) {
            return 'Error formatting outputs: ' + e.getMessage();
        }
    }
    
    @JsonAccess(serializable='always' deserializable='always')
    global class AutoRetrievalRequest {
        @InvocableVariable(label='Session ID' description='The session ID to retrieve outputs for' required=true)
        global String sessionId;
        
        @InvocableVariable(label='Flow API Name' description='Optional: Flow API name if known')
        global String flowApiName;
    }
    
    @JsonAccess(serializable='always' deserializable='always')
    global class AutoRetrievalResult {
        @InvocableVariable(label='Success' description='Whether the retrieval was successful')
        global Boolean success;
        
        @InvocableVariable(label='Output JSON' description='The flow outputs as JSON string')
        global String outputJson;
        
        @InvocableVariable(label='Formatted Outputs' description='Human-readable formatted outputs')
        global String formattedOutputs;
        
        @InvocableVariable(label='Flow API Name' description='The flow that generated these outputs')
        global String flowApiName;
        
        @InvocableVariable(label='Session ID' description='The session ID used for retrieval')
        global String sessionId;
        
        @InvocableVariable(label='Message' description='Result message')
        global String message;
        
        @InvocableVariable(label='Retrieval Timestamp' description='When the outputs were retrieved')
        global String retrievalTimestamp;
    }
}
