/**
 * @description Invocable action to prepare Flow metadata for the FlowRenderer LWC.
 * This class handles the initialization of FlowDetails objects used by the agent.
 */
global with sharing class FlowAction {

    /**
     * @description Prepares Flow details for rendering within an Agentforce conversation.
     * @param req List of requests containing Flow API name and label.
     * @return List of responses containing populated FlowDetails objects.
     */
    @InvocableMethod(label='Launch Flow' description='Prepares a Screen Flow for rendering within an Agent interaction.')
    global static List<FlowActionWithOutputsResponse> launchFlowWithOutputs(List<FlowActionWithOutputsRequest> req) {
        List<FlowActionWithOutputsResponse> flowResponses = new List<FlowActionWithOutputsResponse>();
        
        for (FlowActionWithOutputsRequest request : req) {
            FlowActionWithOutputsResponse response = new FlowActionWithOutputsResponse();
            response.flowDetails = new FlowDetails();
            response.flowDetails.flowApiName = request.flowApiName;
            response.flowDetails.flowLabel = request.flowLabel != null ? request.flowLabel : 'Flow';
            response.flowDetails.inputVariables = request.inputVariables;     
            flowResponses.add(response);
        }
        
        return flowResponses;
    }  

    /**
     * @description Request class for Flow initialization.
     */
    @JsonAccess(serializable='always' deserializable='always')
    global class FlowActionWithOutputsRequest {
        
        /** @description The unique API name of the target Screen Flow */
        @InvocableVariable(label='Flow API Name' description='The API name of the flow to launch' required=true)
        global String flowApiName;
        
        /** @description The friendly name to display in the UI */
        @InvocableVariable(label='Flow Label' description='The display label for the flow')
        global String flowLabel;
        
        /** @description JSON-encoded string of variables to pass into the Flow */
        @InvocableVariable(label='Input Variables' description='JSON string of input variables for the flow')
        global String inputVariables;
    }

    /**
     * @description Response class containing the prepared FlowDetails.
     */
    @JsonAccess(serializable='always' deserializable='always')
    global class FlowActionWithOutputsResponse {
        
        /** @description The metadata required by the FlowRenderer LWC */
        @InvocableVariable(label='Flow Details' description='The flow details to render')
        global FlowDetails flowDetails;      
    }
}