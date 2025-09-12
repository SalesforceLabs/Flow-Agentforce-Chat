@isTest
private class FlowDetailsTest {
    
    @isTest
    static void testFlowDetailsProperties() {
        // Test FlowDetails class property assignments
        FlowDetails details = new FlowDetails();
        
        // Test property assignments
        details.flowApiName = 'Test_Flow_API';
        details.flowLabel = 'Test Flow Label';
        details.inputVariables = '{"input1": "value1", "input2": 123}';
        details.outputVariables = '{"output1": "result1", "output2": 456}';
        details.flowStatus = 'FINISHED';
        details.sessionId = 'test_session_123';
        
        // Verify assignments
        System.assertEquals('Test_Flow_API', details.flowApiName, 'Flow API name should be set correctly');
        System.assertEquals('Test Flow Label', details.flowLabel, 'Flow label should be set correctly');
        System.assertEquals('{"input1": "value1", "input2": 123}', details.inputVariables, 'Input variables should be set correctly');
        System.assertEquals('{"output1": "result1", "output2": 456}', details.outputVariables, 'Output variables should be set correctly');
        System.assertEquals('FINISHED', details.flowStatus, 'Flow status should be set correctly');
        System.assertEquals('test_session_123', details.sessionId, 'Session ID should be set correctly');
    }
    
    @isTest
    static void testFlowDetailsWithNullValues() {
        // Test FlowDetails with null values
        FlowDetails details = new FlowDetails();
        
        // Leave all properties as null and verify they can be set to null
        details.flowApiName = null;
        details.flowLabel = null;
        details.inputVariables = null;
        details.outputVariables = null;
        details.flowStatus = null;
        details.sessionId = null;
        
        // Verify null assignments
        System.assertEquals(null, details.flowApiName, 'Flow API name should be null');
        System.assertEquals(null, details.flowLabel, 'Flow label should be null');
        System.assertEquals(null, details.inputVariables, 'Input variables should be null');
        System.assertEquals(null, details.outputVariables, 'Output variables should be null');
        System.assertEquals(null, details.flowStatus, 'Flow status should be null');
        System.assertEquals(null, details.sessionId, 'Session ID should be null');
    }
    
    @isTest
    static void testFlowDetailsWithEmptyStrings() {
        // Test FlowDetails with empty strings
        FlowDetails details = new FlowDetails();
        
        details.flowApiName = '';
        details.flowLabel = '';
        details.inputVariables = '';
        details.outputVariables = '';
        details.flowStatus = '';
        
        // Verify empty string assignments
        System.assertEquals('', details.flowApiName, 'Flow API name should be empty string');
        System.assertEquals('', details.flowLabel, 'Flow label should be empty string');
        System.assertEquals('', details.inputVariables, 'Input variables should be empty string');
        System.assertEquals('', details.outputVariables, 'Output variables should be empty string');
        System.assertEquals('', details.flowStatus, 'Flow status should be empty string');
    }
    
    @isTest
    static void testFlowDetailsWithLongStrings() {
        // Test FlowDetails with long strings
        FlowDetails details = new FlowDetails();
        
        String longString = 'x'.repeat(2000);
        String longJson = '{"longProperty": "' + 'y'.repeat(1500) + '"}';
        
        details.flowApiName = 'Long_Flow_Name_' + longString.substring(0, 100);
        details.flowLabel = 'Long Flow Label ' + longString.substring(0, 200);
        details.inputVariables = longJson;
        details.outputVariables = longJson;
        details.flowStatus = 'FINISHED_WITH_LONG_DESCRIPTION';
        
        // Verify long string assignments
        System.assertEquals(true, details.flowApiName.startsWith('Long_Flow_Name_'), 'Flow API name should start with expected prefix');
        System.assertEquals(true, details.flowLabel.startsWith('Long Flow Label'), 'Flow label should start with expected prefix');
        System.assertEquals(longJson, details.inputVariables, 'Long input variables should be set correctly');
        System.assertEquals(longJson, details.outputVariables, 'Long output variables should be set correctly');
        System.assertEquals('FINISHED_WITH_LONG_DESCRIPTION', details.flowStatus, 'Long flow status should be set correctly');
    }
    
    @isTest
    static void testFlowDetailsJsonSerialization() {
        // Test that FlowDetails can be serialized to JSON (testing @JsonAccess annotation)
        FlowDetails details = new FlowDetails();
        details.flowApiName = 'Serialization_Test_Flow';
        details.flowLabel = 'Serialization Test';
        details.inputVariables = '{"test": true}';
        details.outputVariables = '{"result": "success"}';
        details.flowStatus = 'COMPLETED';
        
        // Test JSON serialization
        String jsonString = JSON.serialize(details);
        System.assertNotEquals(null, jsonString, 'JSON serialization should not be null');
        System.assertEquals(true, jsonString.contains('Serialization_Test_Flow'), 'JSON should contain flow API name');
        System.assertEquals(true, jsonString.contains('Serialization Test'), 'JSON should contain flow label');
        
        // Test JSON deserialization
        FlowDetails deserializedDetails = (FlowDetails) JSON.deserialize(jsonString, FlowDetails.class);
        System.assertEquals(details.flowApiName, deserializedDetails.flowApiName, 'Deserialized flow API name should match');
        System.assertEquals(details.flowLabel, deserializedDetails.flowLabel, 'Deserialized flow label should match');
        System.assertEquals(details.inputVariables, deserializedDetails.inputVariables, 'Deserialized input variables should match');
        System.assertEquals(details.outputVariables, deserializedDetails.outputVariables, 'Deserialized output variables should match');
        System.assertEquals(details.flowStatus, deserializedDetails.flowStatus, 'Deserialized flow status should match');
    }
    
    @isTest
    static void testFlowDetailsSpecialCharacters() {
        // Test FlowDetails with special characters
        FlowDetails details = new FlowDetails();
        
        details.flowApiName = 'Flow_With_Special_Chars_123';
        details.flowLabel = 'Flow with Special Characters: !@#$%^&*()';
        details.inputVariables = '{"special": "value with \\"quotes\\" and \\n newlines"}';
        details.outputVariables = '{"unicode": "测试 unicode characters éñ"}';
        details.flowStatus = 'FINISHED_SUCCESS';
        
        // Verify special character assignments
        System.assertEquals('Flow_With_Special_Chars_123', details.flowApiName, 'Flow API name with special chars should be set');
        System.assertEquals('Flow with Special Characters: !@#$%^&*()', details.flowLabel, 'Flow label with special chars should be set');
        System.assertEquals(true, details.inputVariables.contains('\\"quotes\\"'), 'Input variables should contain escaped quotes');
        System.assertEquals(true, details.outputVariables.contains('测试'), 'Output variables should contain unicode characters');
    }
}
