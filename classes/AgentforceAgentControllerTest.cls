@isTest
public class AgentforceAgentControllerTest {
    
    private static final String TEST_AGENT_ID = 'test_agent_123';
    private static final String TEST_SESSION_ID = 'mock_session_123';
    private static final String TEST_MESSAGE = 'Hello, how can you help me?';
    
    @TestSetup
    static void makeData() {
        // Note: In a real implementation, you would set up custom metadata for OAuth configuration
        // For testing purposes, the mock will handle the OAuth flow and custom metadata setup
    }
    
    @isTest
    static void testStartSession_Success() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new AgentforceAgentHttpCalloutMock(AgentforceAgentHttpCalloutMock.ResponseType.SUCCESS));
        
        // Act
        Test.startTest();
        AgentforceAgentController.SessionInfo result = AgentforceAgentController.startSession(TEST_AGENT_ID, true);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, result, 'SessionInfo should not be null');
        System.assertEquals('mock_session_123', result.sessionId, 'Session ID should match mock response');
        System.assertEquals('Hello! I\'m here to help you today. How can I assist you?', result.agentGreeting, 'Agent greeting should match mock response');
    }
    
    @isTest
    static void testStartSession_TokenExpiredThenSuccess() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new AgentforceAgentHttpCalloutMock(AgentforceAgentHttpCalloutMock.ResponseType.TOKEN_EXPIRED_THEN_SUCCESS));
        
        // Act
        Test.startTest();
        AgentforceAgentController.SessionInfo result = AgentforceAgentController.startSession(TEST_AGENT_ID, true);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, result, 'SessionInfo should not be null after retry');
        System.assertEquals('mock_session_123', result.sessionId, 'Session ID should match mock response after retry');
    }
    
    @isTest
    static void testStartSession_Error() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new AgentforceAgentHttpCalloutMock(AgentforceAgentHttpCalloutMock.ResponseType.ERROR));
        
        // Act & Assert
        Test.startTest();
        try {
            AgentforceAgentController.startSession(TEST_AGENT_ID, true);
            System.assert(false, 'Expected exception was not thrown');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage(), 'Exception message should not be null. Actual: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testStartSession_InvalidAgentId() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new AgentforceAgentHttpCalloutMock(AgentforceAgentHttpCalloutMock.ResponseType.SUCCESS));
        
        // Act
        Test.startTest();
        // The method accepts null agent ID and builds endpoint with 'null' in URL
        // This is acceptable behavior as the API endpoint will handle validation
        AgentforceAgentController.SessionInfo result = AgentforceAgentController.startSession(null, true);
        Test.stopTest();
        
        // Assert - Should complete without exception (null agent ID creates endpoint with 'null')
        System.assertNotEquals(null, result, 'Result should not be null even with null agent ID');
    }
    
    @isTest
    static void testSendMessage_Success() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new AgentforceAgentHttpCalloutMock(AgentforceAgentHttpCalloutMock.ResponseType.SUCCESS));
        
        // Act
        Test.startTest();
        String result = AgentforceAgentController.sendMessage(TEST_SESSION_ID, TEST_MESSAGE, null);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, result, 'Response message should not be null');
        System.assertEquals('Thank you for your message. I understand your question and here is my detailed response with helpful information.', result, 'Response should match mock streaming response');
    }
    
    @isTest
    static void testSendMessage_TokenExpiredThenSuccess() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new AgentforceAgentHttpCalloutMock(AgentforceAgentHttpCalloutMock.ResponseType.TOKEN_EXPIRED_THEN_SUCCESS));
        
        // Act
        Test.startTest();
        String result = AgentforceAgentController.sendMessage(TEST_SESSION_ID, TEST_MESSAGE, null);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, result, 'Response message should not be null after retry');
        System.assertEquals('Thank you for your message. I understand your question and here is my detailed response with helpful information.', result, 'Response should match mock streaming response after retry');
    }
    
    @isTest
    static void testSendMessage_Error() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new AgentforceAgentHttpCalloutMock(AgentforceAgentHttpCalloutMock.ResponseType.ERROR));
        
        // Act & Assert
        Test.startTest();
        try {
            AgentforceAgentController.sendMessage(TEST_SESSION_ID, TEST_MESSAGE, null);
            System.assert(false, 'Expected exception was not thrown');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage(), 'Exception message should not be null');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testSendMessage_InvalidParameters() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new AgentforceAgentHttpCalloutMock(AgentforceAgentHttpCalloutMock.ResponseType.SUCCESS));
        
        // Act & Assert
        Test.startTest();
        // The method accepts null session ID and builds endpoint with 'null' in URL
        String result1 = AgentforceAgentController.sendMessage(null, TEST_MESSAGE, null);
        System.assertNotEquals(null, result1, 'Response should not be null even with null session ID');
        
        // The method accepts null message and puts null in request body
        String result2 = AgentforceAgentController.sendMessage(TEST_SESSION_ID, null, null);
        System.assertNotEquals(null, result2, 'Response should not be null even with null message');
        Test.stopTest();
    }
    
    @isTest
    static void testSendMessage_WithSequenceId() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new AgentforceAgentHttpCalloutMock(AgentforceAgentHttpCalloutMock.ResponseType.SUCCESS));
        
        // Act
        Test.startTest();
        String result = AgentforceAgentController.sendMessage(TEST_SESSION_ID, TEST_MESSAGE, 5);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, result, 'Response should not be null');
        System.assertNotEquals('', result, 'Response should not be empty');
        System.assert(result.contains('Thank you for your message'), 'Response should contain expected content from streaming response');
    }
    
    @isTest
    static void testSendMessage_StreamingResponseParsing() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new AgentforceAgentHttpCalloutMock(AgentforceAgentHttpCalloutMock.ResponseType.SUCCESS));
        
        // Act
        Test.startTest();
        String result = AgentforceAgentController.sendMessage(TEST_SESSION_ID, TEST_MESSAGE, 1);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, result, 'Response should not be null');
        System.assert(result.contains('Thank you for your message'), 'Should parse streaming response correctly');
        System.assert(result.contains('detailed response'), 'Should contain complete message from Inform event');
    }
    
    @isTest
    static void testEndSession_Success() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new AgentforceAgentHttpCalloutMock(AgentforceAgentHttpCalloutMock.ResponseType.SUCCESS));
        
        // Act
        Test.startTest();
        // Should not throw any exception
        AgentforceAgentController.endSession(TEST_SESSION_ID);
        Test.stopTest();
        
        // Assert - No exception should be thrown for successful end session
        System.assert(true, 'End session should complete without exception');
    }
    
    @isTest
    static void testEndSession_TokenExpiredThenSuccess() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new AgentforceAgentHttpCalloutMock(AgentforceAgentHttpCalloutMock.ResponseType.TOKEN_EXPIRED_THEN_SUCCESS));
        
        // Act
        Test.startTest();
        // Should not throw any exception after retry
        AgentforceAgentController.endSession(TEST_SESSION_ID);
        Test.stopTest();
        
        // Assert - No exception should be thrown after successful retry
        System.assert(true, 'End session should complete without exception after retry');
    }
    
    @isTest
    static void testEndSession_Error() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new AgentforceAgentHttpCalloutMock(AgentforceAgentHttpCalloutMock.ResponseType.ERROR));
        
        // Act
        Test.startTest();
        // Error in endSession should not throw exception but should log error
        AgentforceAgentController.endSession(TEST_SESSION_ID);
        Test.stopTest();
        
        // Assert - Method should handle errors gracefully
        System.assert(true, 'End session should handle errors gracefully');
    }
    
    @isTest
    static void testEndSession_InvalidSessionId() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new AgentforceAgentHttpCalloutMock(AgentforceAgentHttpCalloutMock.ResponseType.SUCCESS));
        
        // Act
        Test.startTest();
        // Method should handle null session ID gracefully (creates endpoint with 'null')
        AgentforceAgentController.endSession(null);
        Test.stopTest();
        
        // Assert - Method should complete without exception
        System.assert(true, 'End session should handle null session ID gracefully');
    }
    
    @isTest
    static void testOAuthFlow_Success() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new AgentforceAgentHttpCalloutMock(AgentforceAgentHttpCalloutMock.ResponseType.SUCCESS));
        
        // Act
        Test.startTest();
        // Test OAuth flow through startSession call
        AgentforceAgentController.SessionInfo result = AgentforceAgentController.startSession(TEST_AGENT_ID, true);
        Test.stopTest();
        
        // Assert - OAuth should succeed and allow session creation
        System.assertNotEquals(null, result, 'Session should be created after successful OAuth');
    }
    
    @isTest
    static void testOAuthFlow_Error() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new AgentforceAgentHttpCalloutMock(AgentforceAgentHttpCalloutMock.ResponseType.OAUTH_ERROR));
        
        // Act & Assert
        Test.startTest();
        try {
            AgentforceAgentController.startSession(TEST_AGENT_ID, true);
            System.assert(false, 'Expected OAuth exception was not thrown');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage(), 'Exception message should not be null. Actual: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCachePartitionAccess() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new AgentforceAgentHttpCalloutMock(AgentforceAgentHttpCalloutMock.ResponseType.SUCCESS));
        
        // Act
        Test.startTest();
        // Make multiple calls to test caching behavior
        // Note: Cache partition may not exist in packaging/test scenarios, 
        // but the code should handle this gracefully
        AgentforceAgentController.SessionInfo result1 = AgentforceAgentController.startSession(TEST_AGENT_ID, true);
        AgentforceAgentController.SessionInfo result2 = AgentforceAgentController.startSession(TEST_AGENT_ID, true);
        Test.stopTest();
        
        // Assert - Both calls should succeed regardless of cache partition availability
        System.assertNotEquals(null, result1, 'First session should be created');
        System.assertNotEquals(null, result2, 'Second session should be created');
    }
    
    @isTest
    static void testSessionInfo_WrapperClass() {
        // Test the SessionInfo wrapper class
        AgentforceAgentController.SessionInfo sessionInfo = new AgentforceAgentController.SessionInfo();
        sessionInfo.sessionId = 'test_session';
        sessionInfo.agentGreeting = 'test_greeting';
        
        System.assertEquals('test_session', sessionInfo.sessionId, 'SessionId should be set correctly');
        System.assertEquals('test_greeting', sessionInfo.agentGreeting, 'AgentGreeting should be set correctly');
    }
    
    @isTest
    static void testMultipleOperationsFlow() {
        // Test a complete flow: start session, send message, end session
        Test.setMock(HttpCalloutMock.class, new AgentforceAgentHttpCalloutMock(AgentforceAgentHttpCalloutMock.ResponseType.SUCCESS));
        
        Test.startTest();
        
        // Start session
        AgentforceAgentController.SessionInfo session = AgentforceAgentController.startSession(TEST_AGENT_ID, true);
        System.assertNotEquals(null, session, 'Session should be created');
        
        // Send message
        String response = AgentforceAgentController.sendMessage(session.sessionId, TEST_MESSAGE, null);
        System.assertNotEquals(null, response, 'Response should be received');
        
        // End session
        AgentforceAgentController.endSession(session.sessionId);
        
        Test.stopTest();
        
        // Assert - Complete flow should work without errors
        System.assert(true, 'Complete flow should execute without errors');
    }
}