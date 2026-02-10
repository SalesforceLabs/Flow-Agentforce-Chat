/**
 * @description Test class for FlowAction and FlowDetails classes.
 */
@isTest
private class FlowActionTest {
    
    /**
     * @description Verifies that FlowDetails properties are correctly assigned and retrieved.
     */
    @isTest
    static void testFlowDetailsProperties() {
        FlowDetails flowDetails = new FlowDetails();
        flowDetails.flowApiName = 'Test_Flow';
        flowDetails.flowLabel = 'Test Label';
        flowDetails.flowCompleted = true;
        flowDetails.outputsJson = '{"test": "value"}';
        
        System.assertEquals('Test_Flow', flowDetails.flowApiName, 'Flow API Name should match');
        System.assertEquals('Test Label', flowDetails.flowLabel, 'Flow Label should match');
        System.assertEquals(true, flowDetails.flowCompleted, 'Flow Completed flag should match');
        System.assertEquals('{"test": "value"}', flowDetails.outputsJson, 'Outputs JSON should match');
    }
    
    /**
     * @description Tests the launchFlowWithOutputs invocable method.
     */
    @isTest
    static void testLaunchFlow() {
        List<FlowAction.FlowActionWithOutputsRequest> requests = new List<FlowAction.FlowActionWithOutputsRequest>();
        FlowAction.FlowActionWithOutputsRequest request = new FlowAction.FlowActionWithOutputsRequest();
        
        request.flowApiName = 'Test_Flow';
        request.flowLabel = 'Test Label';
        request.inputVariables = '{"testVar": "testValue"}';
        
        requests.add(request);
        
        Test.startTest();
        List<FlowAction.FlowActionWithOutputsResponse> results = FlowAction.launchFlowWithOutputs(requests);
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Exactly one result should be returned');
        System.assertNotEquals(null, results[0].flowDetails, 'FlowDetails object should be populated');
        System.assertEquals('Test_Flow', results[0].flowDetails.flowApiName, 'Mapped Flow API name should match');
        System.assertEquals('Test Label', results[0].flowDetails.flowLabel, 'Mapped Flow label should match');
    }
}