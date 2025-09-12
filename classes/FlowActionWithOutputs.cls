global class FlowActionWithOutputs {

    @InvocableMethod(label='Launch Flow as Input' description='Launches a Flow as input component and automatically captures outputs after completion')
    global static List<FlowActionWithOutputsResponse> launchFlowWithOutputs(List<FlowActionWithOutputsRequest> req) {
        List<FlowActionWithOutputsResponse> flowResponses = new List<FlowActionWithOutputsResponse>();
        
        for (FlowActionWithOutputsRequest request : req) {
            FlowActionWithOutputsResponse response = new FlowActionWithOutputsResponse();
            response.flowDetails = new FlowDetails();
            response.flowDetails.flowApiName = request.flowApiName;
            response.flowDetails.flowLabel = request.flowLabel != null ? request.flowLabel : 'Flow';
            response.flowDetails.inputVariables = request.inputVariables;
            
            // Generate session ID for output tracking
            String sessionId = generateSessionId(request.flowApiName, request.customSessionId);
            response.sessionId = sessionId;
            response.retrievalInstructions = 'Flow will render as input. After user completes it, outputs will be automatically captured with session ID: ' + sessionId;
            
            // Pass session ID to LWC through FlowDetails
            response.flowDetails.sessionId = sessionId;
            
            flowResponses.add(response);
        }
        
        return flowResponses;
    }
    
    // Helper method to generate session ID
    private static String generateSessionId(String flowApiName, String customSessionId) {
        if (String.isNotBlank(customSessionId)) {
            return flowApiName + '_' + customSessionId;
        }
        return flowApiName + '_' + DateTime.now().getTime() + '_' + UserInfo.getUserId();
    }

    @JsonAccess(serializable='always' deserializable='always')
    global class FlowActionWithOutputsRequest {
        
        @InvocableVariable(label='Flow API Name' description='The API name of the flow to launch' required=true)
        global String flowApiName;
        
        @InvocableVariable(label='Flow Label' description='The display label for the flow')
        global String flowLabel;
        
        @InvocableVariable(label='Input Variables' description='JSON string of input variables for the flow')
        global String inputVariables;
        
        @InvocableVariable(label='Custom Session ID' description='Optional custom session ID for grouping related flows')
        global String customSessionId;
       
    }

    @JsonAccess(serializable='always' deserializable='always')
    global class FlowActionWithOutputsResponse {
        
        @InvocableVariable(label='Flow Details' description='The flow details to render')
        global FlowDetails flowDetails;
        
        @InvocableVariable(label='Session ID' description='The session ID for retrieving outputs after completion')
        global String sessionId;
        
        @InvocableVariable(label='Retrieval Instructions' description='Instructions for retrieving outputs')
        global String retrievalInstructions;
    }
}
