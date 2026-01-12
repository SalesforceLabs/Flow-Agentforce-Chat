/**
 * @description Test class for ChatMessage.
 * Verifies property assignment and constructor logic.
 */
@isTest
public class ChatMessageTest {
    
    /**
     * @description Tests the parameterized constructor.
     */
    @isTest
    static void testChatMessageConstructor() {
        // Arrange
        String role = 'user';
        String content = 'Hello, how can I help you?';

        // Act
        ChatMessage chatMessage = new ChatMessage(role, content);

        // Assert
        System.assertEquals(role, chatMessage.role, 'The role should be set correctly.');
        System.assertEquals(content, chatMessage.content, 'The content should be set correctly.');
        System.assertNotEquals(null, chatMessage.timestamp, 'The timestamp should be automatically set.');
    }

    /**
     * @description Tests the default constructor and manual property assignment.
     */
    @isTest
    static void testChatMessageDefaultConstructor() {
        // Act
        ChatMessage chatMessage = new ChatMessage();

        // Assert
        System.assertEquals(null, chatMessage.role, 'The role should be null by default.');
        System.assertEquals(null, chatMessage.content, 'The content should be null by default.');
        System.assertNotEquals(null, chatMessage.timestamp, 'The timestamp should be automatically set.');

        // Manual assignment
        chatMessage.role = 'assistant';
        chatMessage.content = 'Sure, I can help you with that.';

        System.assertEquals('assistant', chatMessage.role, 'The role should be updated correctly.');
        System.assertEquals('Sure, I can help you with that.', chatMessage.content, 'The content should be updated correctly.');
    }
}