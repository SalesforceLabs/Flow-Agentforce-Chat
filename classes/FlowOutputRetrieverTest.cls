@isTest
private class FlowOutputRetrieverTest {
    
    @isTest
    static void testRetrieveFlowOutputsSuccess() {
        // First store some outputs using FlowOutputHandler
        List<FlowOutputHandler.FlowOutputRequest> storeRequests = new List<FlowOutputHandler.FlowOutputRequest>();
        FlowOutputHandler.FlowOutputRequest storeRequest = new FlowOutputHandler.FlowOutputRequest();
        storeRequest.flowApiName = 'Retriever_Test_Flow';
        storeRequest.outputJson = '{"retrieverTest": true, "data": "test_value"}';
        storeRequest.sessionId = 'retrieverSession';
        storeRequests.add(storeRequest);
        
        List<FlowOutputHandler.FlowOutputResult> storeResults = FlowOutputHandler.storeFlowOutputs(storeRequests);
        String outputKey = storeResults[0].outputKey;
        
        // Now test the retriever class
        List<FlowOutputRetriever.FlowOutputRetrievalRequest> retrieveRequests = new List<FlowOutputRetriever.FlowOutputRetrievalRequest>();
        FlowOutputRetriever.FlowOutputRetrievalRequest retrieveRequest = new FlowOutputRetriever.FlowOutputRetrievalRequest();
        retrieveRequest.outputKey = outputKey;
        retrieveRequests.add(retrieveRequest);
        
        Test.startTest();
        List<FlowOutputRetriever.FlowOutputRetrievalResult> results = FlowOutputRetriever.retrieveFlowOutputs(retrieveRequests);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, results.size(), 'Should return 1 result');
        FlowOutputRetriever.FlowOutputRetrievalResult result = results[0];
        System.assertEquals(true, result.success, 'Retrieval should be successful');
        System.assertEquals('{"retrieverTest": true, "data": "test_value"}', result.outputJson, 'Retrieved JSON should match stored JSON');
        System.assertEquals('Flow outputs retrieved successfully', result.message, 'Success message should match');
    }
    
    @isTest
    static void testRetrieveFlowOutputsWithFlowApiAndSession() {
        // Store outputs first
        List<FlowOutputHandler.FlowOutputRequest> storeRequests = new List<FlowOutputHandler.FlowOutputRequest>();
        FlowOutputHandler.FlowOutputRequest storeRequest = new FlowOutputHandler.FlowOutputRequest();
        storeRequest.flowApiName = 'API_Retriever_Flow';
        storeRequest.outputJson = '{"apiRetrieverTest": "success"}';
        storeRequest.sessionId = 'apiRetrieverSession';
        storeRequests.add(storeRequest);
        
        FlowOutputHandler.storeFlowOutputs(storeRequests);
        
        // Test retrieval using flow API name and session ID
        List<FlowOutputRetriever.FlowOutputRetrievalRequest> retrieveRequests = new List<FlowOutputRetriever.FlowOutputRetrievalRequest>();
        FlowOutputRetriever.FlowOutputRetrievalRequest retrieveRequest = new FlowOutputRetriever.FlowOutputRetrievalRequest();
        retrieveRequest.flowApiName = 'API_Retriever_Flow';
        retrieveRequest.sessionId = 'apiRetrieverSession';
        retrieveRequests.add(retrieveRequest);
        
        Test.startTest();
        List<FlowOutputRetriever.FlowOutputRetrievalResult> results = FlowOutputRetriever.retrieveFlowOutputs(retrieveRequests);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, results.size(), 'Should return 1 result');
        FlowOutputRetriever.FlowOutputRetrievalResult result = results[0];
        System.assertEquals(true, result.success, 'Retrieval should be successful');
        System.assertEquals('{"apiRetrieverTest": "success"}', result.outputJson, 'Retrieved JSON should match');
    }
    
    @isTest
    static void testRetrieveFlowOutputsNotFound() {
        // Test retrieving outputs that don't exist
        List<FlowOutputRetriever.FlowOutputRetrievalRequest> retrieveRequests = new List<FlowOutputRetriever.FlowOutputRetrievalRequest>();
        FlowOutputRetriever.FlowOutputRetrievalRequest retrieveRequest = new FlowOutputRetriever.FlowOutputRetrievalRequest();
        retrieveRequest.outputKey = 'NonExistent_Retriever_Key';
        retrieveRequests.add(retrieveRequest);
        
        Test.startTest();
        List<FlowOutputRetriever.FlowOutputRetrievalResult> results = FlowOutputRetriever.retrieveFlowOutputs(retrieveRequests);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, results.size(), 'Should return 1 result');
        FlowOutputRetriever.FlowOutputRetrievalResult result = results[0];
        System.assertEquals(false, result.success, 'Retrieval should not be successful');
        System.assertEquals('{}', result.outputJson, 'Should return empty JSON object');
        System.assertEquals('No outputs found for the specified flow', result.message, 'Error message should match');
    }
    
    @isTest
    static void testRetrieveFlowOutputsEmptyRequest() {
        // Test with empty request list
        List<FlowOutputRetriever.FlowOutputRetrievalRequest> requests = new List<FlowOutputRetriever.FlowOutputRetrievalRequest>();
        
        Test.startTest();
        List<FlowOutputRetriever.FlowOutputRetrievalResult> results = FlowOutputRetriever.retrieveFlowOutputs(requests);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(0, results.size(), 'Should return empty result list');
    }
    
    @isTest
    static void testRetrieveFlowOutputsMultipleRequests() {
        // Store multiple outputs first
        List<FlowOutputHandler.FlowOutputRequest> storeRequests = new List<FlowOutputHandler.FlowOutputRequest>();
        
        FlowOutputHandler.FlowOutputRequest storeRequest1 = new FlowOutputHandler.FlowOutputRequest();
        storeRequest1.flowApiName = 'Multi_Retriever_Flow_1';
        storeRequest1.outputJson = '{"multiTest1": true}';
        storeRequest1.sessionId = 'multiSession1';
        storeRequests.add(storeRequest1);
        
        FlowOutputHandler.FlowOutputRequest storeRequest2 = new FlowOutputHandler.FlowOutputRequest();
        storeRequest2.flowApiName = 'Multi_Retriever_Flow_2';
        storeRequest2.outputJson = '{"multiTest2": true}';
        storeRequest2.sessionId = 'multiSession2';
        storeRequests.add(storeRequest2);
        
        List<FlowOutputHandler.FlowOutputResult> storeResults = FlowOutputHandler.storeFlowOutputs(storeRequests);
        
        // Retrieve multiple outputs
        List<FlowOutputRetriever.FlowOutputRetrievalRequest> retrieveRequests = new List<FlowOutputRetriever.FlowOutputRetrievalRequest>();
        
        FlowOutputRetriever.FlowOutputRetrievalRequest retrieveRequest1 = new FlowOutputRetriever.FlowOutputRetrievalRequest();
        retrieveRequest1.outputKey = storeResults[0].outputKey;
        retrieveRequests.add(retrieveRequest1);
        
        FlowOutputRetriever.FlowOutputRetrievalRequest retrieveRequest2 = new FlowOutputRetriever.FlowOutputRetrievalRequest();
        retrieveRequest2.outputKey = storeResults[1].outputKey;
        retrieveRequests.add(retrieveRequest2);
        
        // Add one that doesn't exist
        FlowOutputRetriever.FlowOutputRetrievalRequest retrieveRequest3 = new FlowOutputRetriever.FlowOutputRetrievalRequest();
        retrieveRequest3.outputKey = 'Non_Existent_Key';
        retrieveRequests.add(retrieveRequest3);
        
        Test.startTest();
        List<FlowOutputRetriever.FlowOutputRetrievalResult> results = FlowOutputRetriever.retrieveFlowOutputs(retrieveRequests);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(3, results.size(), 'Should return 3 results');
        
        // First result should be successful
        System.assertEquals(true, results[0].success, 'First retrieval should be successful');
        System.assertEquals('{"multiTest1": true}', results[0].outputJson, 'First JSON should match');
        
        // Second result should be successful
        System.assertEquals(true, results[1].success, 'Second retrieval should be successful');
        System.assertEquals('{"multiTest2": true}', results[1].outputJson, 'Second JSON should match');
        
        // Third result should fail
        System.assertEquals(false, results[2].success, 'Third retrieval should fail');
        System.assertEquals('{}', results[2].outputJson, 'Third JSON should be empty');
    }
    
    @isTest
    static void testFlowOutputRetrievalRequestClass() {
        // Test FlowOutputRetrievalRequest class properties
        FlowOutputRetriever.FlowOutputRetrievalRequest request = new FlowOutputRetriever.FlowOutputRetrievalRequest();
        
        request.outputKey = 'test_output_key_123';
        request.flowApiName = 'Request_Class_Test_Flow';
        request.sessionId = 'requestClassSession';
        
        // Verify assignments
        System.assertEquals('test_output_key_123', request.outputKey, 'Output key should be set');
        System.assertEquals('Request_Class_Test_Flow', request.flowApiName, 'Flow API name should be set');
        System.assertEquals('requestClassSession', request.sessionId, 'Session ID should be set');
    }
    
    @isTest
    static void testFlowOutputRetrievalResultClass() {
        // Test FlowOutputRetrievalResult class properties
        FlowOutputRetriever.FlowOutputRetrievalResult result = new FlowOutputRetriever.FlowOutputRetrievalResult();
        
        result.outputJson = '{"resultTest": true}';
        result.success = true;
        result.message = 'Result class test message';
        
        // Verify assignments
        System.assertEquals('{"resultTest": true}', result.outputJson, 'Output JSON should be set');
        System.assertEquals(true, result.success, 'Success should be set');
        System.assertEquals('Result class test message', result.message, 'Message should be set');
    }
    
    @isTest
    static void testRetrieveFlowOutputsWithNullValues() {
        // Test retrieval with null values in request
        List<FlowOutputRetriever.FlowOutputRetrievalRequest> retrieveRequests = new List<FlowOutputRetriever.FlowOutputRetrievalRequest>();
        FlowOutputRetriever.FlowOutputRetrievalRequest retrieveRequest = new FlowOutputRetriever.FlowOutputRetrievalRequest();
        // Leave all properties null
        retrieveRequest.outputKey = null;
        retrieveRequest.flowApiName = null;
        retrieveRequest.sessionId = null;
        retrieveRequests.add(retrieveRequest);
        
        Test.startTest();
        List<FlowOutputRetriever.FlowOutputRetrievalResult> results = FlowOutputRetriever.retrieveFlowOutputs(retrieveRequests);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, results.size(), 'Should return 1 result');
        FlowOutputRetriever.FlowOutputRetrievalResult result = results[0];
        System.assertEquals(false, result.success, 'Retrieval with null values should fail');
        System.assertEquals('{}', result.outputJson, 'Should return empty JSON object');
    }
    
    @isTest
    static void testLargeJsonRetrieval() {
        // Store a large JSON output first
        List<FlowOutputHandler.FlowOutputRequest> storeRequests = new List<FlowOutputHandler.FlowOutputRequest>();
        FlowOutputHandler.FlowOutputRequest storeRequest = new FlowOutputHandler.FlowOutputRequest();
        storeRequest.flowApiName = 'Large_Retriever_Flow';
        
        String largeData = 'x'.repeat(3000);
        storeRequest.outputJson = '{"largeRetrieverData": "' + largeData + '", "size": "large"}';
        storeRequest.sessionId = 'largeRetrieverSession';
        storeRequests.add(storeRequest);
        
        List<FlowOutputHandler.FlowOutputResult> storeResults = FlowOutputHandler.storeFlowOutputs(storeRequests);
        
        // Retrieve the large JSON
        List<FlowOutputRetriever.FlowOutputRetrievalRequest> retrieveRequests = new List<FlowOutputRetriever.FlowOutputRetrievalRequest>();
        FlowOutputRetriever.FlowOutputRetrievalRequest retrieveRequest = new FlowOutputRetriever.FlowOutputRetrievalRequest();
        retrieveRequest.outputKey = storeResults[0].outputKey;
        retrieveRequests.add(retrieveRequest);
        
        Test.startTest();
        List<FlowOutputRetriever.FlowOutputRetrievalResult> results = FlowOutputRetriever.retrieveFlowOutputs(retrieveRequests);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(1, results.size(), 'Should return 1 result');
        FlowOutputRetriever.FlowOutputRetrievalResult result = results[0];
        System.assertEquals(true, result.success, 'Large JSON retrieval should be successful');
        System.assertEquals(true, result.outputJson.contains(largeData), 'Retrieved JSON should contain large data');
        System.assertEquals(true, result.outputJson.contains('"size": "large"'), 'Retrieved JSON should contain size field');
    }
}
