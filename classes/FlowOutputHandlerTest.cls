@isTest
private class FlowOutputHandlerTest {
    
    @isTest
    static void testStoreFlowOutputsSuccess() {
        List<FlowOutputHandler.FlowOutputRequest> requests = new List<FlowOutputHandler.FlowOutputRequest>();
        
        FlowOutputHandler.FlowOutputRequest request1 = new FlowOutputHandler.FlowOutputRequest();
        request1.flowApiName = 'Test_Flow_1';
        request1.outputJson = '{"result": "success", "recordId": "001XX000004TmiQ"}';
        request1.sessionId = 'session123';
        requests.add(request1);
        
        Test.startTest();
        List<FlowOutputHandler.FlowOutputResult> results = FlowOutputHandler.storeFlowOutputs(requests);
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return 1 result');
        System.assertEquals(true, results[0].success, 'Storage should be successful');
        System.assertEquals('Flow outputs stored successfully', results[0].message, 'Success message should match');
        System.assertNotEquals(null, results[0].outputKey, 'Output key should not be null');
    }
    
    @isTest
    static void testStoreFlowOutputsEmpty() {
        List<FlowOutputHandler.FlowOutputRequest> requests = new List<FlowOutputHandler.FlowOutputRequest>();
        
        Test.startTest();
        List<FlowOutputHandler.FlowOutputResult> results = FlowOutputHandler.storeFlowOutputs(requests);
        Test.stopTest();
        
        System.assertEquals(0, results.size(), 'Should return empty result list');
    }
    
    @isTest
    static void testRetrieveFlowOutputsSuccess() {
        List<FlowOutputHandler.FlowOutputRequest> storeRequests = new List<FlowOutputHandler.FlowOutputRequest>();
        FlowOutputHandler.FlowOutputRequest storeRequest = new FlowOutputHandler.FlowOutputRequest();
        storeRequest.flowApiName = 'Retrieve_Test_Flow';
        storeRequest.outputJson = '{"retrieveTest": true, "value": 42}';
        storeRequest.sessionId = 'retrieveSession';
        storeRequests.add(storeRequest);
        
        List<FlowOutputHandler.FlowOutputResult> storeResults = FlowOutputHandler.storeFlowOutputs(storeRequests);
        String outputKey = storeResults[0].outputKey;
        
        List<FlowOutputRetriever.FlowOutputRetrievalRequest> retrieveRequests = new List<FlowOutputRetriever.FlowOutputRetrievalRequest>();
        FlowOutputRetriever.FlowOutputRetrievalRequest retrieveRequest = new FlowOutputRetriever.FlowOutputRetrievalRequest();
        retrieveRequest.outputKey = outputKey;
        retrieveRequests.add(retrieveRequest);
        
        Test.startTest();
        List<FlowOutputRetriever.FlowOutputRetrievalResult> retrieveResults = FlowOutputHandler.retrieveFlowOutputs(retrieveRequests);
        Test.stopTest();
        
        System.assertEquals(1, retrieveResults.size(), 'Should return 1 retrieval result');
        System.assertEquals(true, retrieveResults[0].success, 'Retrieval should be successful');
        System.assertEquals('{"retrieveTest": true, "value": 42}', retrieveResults[0].outputJson, 'Retrieved JSON should match');
    }
    
    @isTest
    static void testRetrieveFlowOutputsNotFound() {
        List<FlowOutputRetriever.FlowOutputRetrievalRequest> retrieveRequests = new List<FlowOutputRetriever.FlowOutputRetrievalRequest>();
        FlowOutputRetriever.FlowOutputRetrievalRequest retrieveRequest = new FlowOutputRetriever.FlowOutputRetrievalRequest();
        retrieveRequest.outputKey = 'NonExistent_Key_12345';
        retrieveRequests.add(retrieveRequest);
        
        Test.startTest();
        List<FlowOutputRetriever.FlowOutputRetrievalResult> retrieveResults = FlowOutputHandler.retrieveFlowOutputs(retrieveRequests);
        Test.stopTest();
        
        System.assertEquals(1, retrieveResults.size(), 'Should return 1 retrieval result');
        System.assertEquals(false, retrieveResults[0].success, 'Retrieval should not be successful');
        System.assertEquals('{}', retrieveResults[0].outputJson, 'Should return empty JSON object');
    }
    
    @isTest
    static void testFlowOutputRequestProperties() {
        FlowOutputHandler.FlowOutputRequest request = new FlowOutputHandler.FlowOutputRequest();
        
        request.flowApiName = 'Request_Test_Flow';
        request.outputJson = '{"requestTest": true}';
        request.sessionId = 'requestSession';
        
        System.assertEquals('Request_Test_Flow', request.flowApiName, 'Flow API name should be set');
        System.assertEquals('{"requestTest": true}', request.outputJson, 'Output JSON should be set');
        System.assertEquals('requestSession', request.sessionId, 'Session ID should be set');
    }
    
    @isTest
    static void testFlowOutputResultProperties() {
        FlowOutputHandler.FlowOutputResult result = new FlowOutputHandler.FlowOutputResult();
        
        result.success = true;
        result.outputKey = 'test_key_123';
        result.message = 'Test message';
        
        System.assertEquals(true, result.success, 'Success should be set');
        System.assertEquals('test_key_123', result.outputKey, 'Output key should be set');
        System.assertEquals('Test message', result.message, 'Message should be set');
    }
}
