/**
 * @description Controller for the Agentforce Chat LWC.
 * Handles interaction with Agentforce agents using native Invocable Actions.
 * Version 2.2 - Removed REST/Connected App requirements.
 */
public with sharing class AgentforceAgentController {

    /**
     * @description Wrapper class to hold the result of starting a session.
     */
    public class SessionInfo {
        @AuraEnabled public String sessionId;
        @AuraEnabled public String agentGreeting;
    }

    /**
     * @description Starts a new chat session with the Agentforce Agent using native Invocable Actions.
     * @param agentId The API Name of the Einstein Agent (e.g., 'Service_Agent').
     * @return A SessionInfo object containing the new sessionId and the agent's greeting.
     */
    @AuraEnabled(cacheable=false)
    public static SessionInfo startSession(String agentId) {
        try {
            // Use the unified Invocable Action for Agentforce
            // This runs in the context of the current user session
            Invocable.Action action = Invocable.Action.createCustomAction('generateAiAgentResponse', agentId);
            
            // Send an initial dummy prompt to trigger the session and get a greeting
            action.setInvocationParameter('userMessage', 'Hello'); 
            
            List<Invocable.Action.Result> results = Test.isRunningTest() && mockResults != null ? mockResults : action.invoke();
            
            if (results != null && !results.isEmpty() && results[0].isSuccess()) {
                SessionInfo session = new SessionInfo();
                Map<String, Object> outputs = results[0].getOutputParameters();
                session.sessionId = (String) outputs.get('sessionId');
                session.agentGreeting = getGreetingOrDefault((String) outputs.get('agentResponse'));
                return session;
            } else {
                String errorMsg = (results != null && !results.isEmpty()) ? results[0].getErrors()[0].getMessage() : 'Unknown error';
                throw new AuraHandledException('Error starting agent session: ' + errorMsg);
            }
        } catch (Exception e) {
            System.debug('Agentforce Error: ' + e.getMessage());
            throw new AuraHandledException('Unable to start Agent session. Ensure the Agent API Name is correct and you have "Einstein Agent User" permissions. Error: ' + e.getMessage());
        }
    }

    /**
     * @description Sends a message to the Agentforce Agent using native Invocable Actions.
     * @param agentId The API Name of the Einstein Agent.
     * @param sessionId The active session ID returned from startSession.
     * @param message The user's message text.
     * @param sequenceId Not used for synchronous native actions, kept for LWC compatibility.
     * @return The agent's complete text reply.
     */
    @AuraEnabled
    public static String sendMessage(String agentId, String sessionId, String message, Integer sequenceId) {
        try {
            Invocable.Action action = Invocable.Action.createCustomAction('generateAiAgentResponse', agentId);
            action.setInvocationParameter('sessionId', sessionId);
            action.setInvocationParameter('userMessage', message);
            
            List<Invocable.Action.Result> results = Test.isRunningTest() && mockResults != null ? mockResults : action.invoke();
            
            if (results != null && !results.isEmpty() && results[0].isSuccess()) {
                Map<String, Object> outputs = results[0].getOutputParameters();
                return formatAgentResponse((String) outputs.get('agentResponse'));
            } else {
                String errorMsg = (results != null && !results.isEmpty()) ? results[0].getErrors()[0].getMessage() : 'Unknown error';
                throw new AuraHandledException('Error from Agent: ' + errorMsg);
            }
        } catch (Exception e) {
            throw new AuraHandledException('Message failed: ' + e.getMessage());
        }
    }

    /**
     * @description Ends an active chat session.
     * @param sessionId The active session ID to end.
     */
    @AuraEnabled
    public static void endSession(String sessionId) {
        // Session cleanup is managed automatically by Salesforce for native actions.
        System.debug('Session end requested for: ' + sessionId);
    }

    @TestVisible
    private static String getGreetingOrDefault(String response) {
        String formatted = formatAgentResponse(response);
        if (String.isBlank(formatted)) {
            return 'Hello! I am your Agentforce assistant. How can I help you?';
        }
        return formatted;
    }

    @TestVisible private static List<Invocable.Action.Result> mockResults;

    /**
     * @description Helper to parse JSON agent response if returned in structured format.
     * Agentforce sometimes returns responses as {"type":"Text","value":"..."}.
     * @param response The raw string response from the agent.
     * @return The cleaned message text.
     */
    @TestVisible
    private static String formatAgentResponse(String response) {
        if (String.isBlank(response)) return '';
        
        // Handle JSON formatted responses from the reasoning engine
        if (response.startsWith('{') && response.endsWith('}')) {
            try {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
                if (responseMap.containsKey('value')) {
                    return (String) responseMap.get('value');
                }
            } catch (Exception e) {
                // Return original string if parsing fails
                return response;
            }
        }
        return response;
    }
}