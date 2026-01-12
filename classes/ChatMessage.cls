/**
 * @description Universal wrapper class for chat messages used across different AI implementations.
 */
public with sharing class ChatMessage {
    
    /** @description The message sender role (e.g., 'user', 'assistant') */
    @AuraEnabled
    public String role;
    
    /** @description The text content of the message */
    @AuraEnabled
    public String content;
    
    /** @description Timestamp of when the message was created */
    @AuraEnabled
    public Datetime timestamp;

    /**
     * @description Basic constructor
     */
    public ChatMessage() {
        this.timestamp = Datetime.now();
    }

    /**
     * @description Constructor with role and content
     * @param role The sender's role
     * @param content The message body
     */
    public ChatMessage(String role, String content) {
        this.role = role;
        this.content = content;
        this.timestamp = Datetime.now();
    }
}