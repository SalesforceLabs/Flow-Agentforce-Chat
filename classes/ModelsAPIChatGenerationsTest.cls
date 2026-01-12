/**
 * @description Test class for ModelsAPIChatGenerations.
 * Verifies model interaction logic and history reconstruction.
 */
@isTest
private class ModelsAPIChatGenerationsTest {
    
    /**
     * @description Tests the successful generation of a chat response.
     * Uses HttpCalloutMock to simulate the external AI platform API.
     */
    @isTest
    static void testGenerateChatResponse_Success() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new ModelsAPIGenerationHttpCalloutMock());
        
        String modelName = 'test_model';
        String userPrompt = 'Hello, how are you?';
        List<ChatMessage> history = new List<ChatMessage>{
            new ChatMessage('user', 'Hi'),
            new ChatMessage('assistant', 'Hello!')
        };
        String historyJson = JSON.serialize(history);
        
        // Act
        Test.startTest();
        String result = ModelsAPIChatGenerations.createChatGenerations(modelName, historyJson);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals('Mock AI response content.', result, 'Result should match mock response');
    }
    
    /**
     * @description Tests error handling when history JSON is malformed.
     */
    @isTest
    static void testGenerateChatResponse_Error() {
        // Arrange
        String invalidJson = '{invalid}';
        
        // Act & Assert
        Test.startTest();
        try {
            ModelsAPIChatGenerations.createChatGenerations('model', invalidJson);
            System.assert(false, 'Expected an exception for invalid JSON');
        } catch (AuraHandledException e) {
            System.assert(true, 'Caught expected handled exception');
        }
        Test.stopTest();
    }
}