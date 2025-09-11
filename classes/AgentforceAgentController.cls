public with sharing class AgentforceAgentController {

    // Base URL for the Agentforce Agent API, confirmed via Postman.
    private static final String AGENT_API_BASE_URL = 'https://api.salesforce.com/einstein/ai-agent/v1';

    // Define a specific partition name for our cache.
    private static final String CACHE_PARTITION = 'einsteinagentcache';
    // Key for caching the access token within our partition.
    private static final String EINSTEIN_TOKEN_CACHE_KEY = 'einsteinagentaccesstoken';

    // Wrapper class to hold the result of starting a session.
    public class SessionInfo {
        @AuraEnabled public String sessionId;
        @AuraEnabled public String agentGreeting;
    }

    /**
     * @description Starts a new chat session with the Agentforce Agent.
     * @param agentId The ID of the Einstein Agent to start a session with.
     * @param bypassUser Whether to bypass user authentication. Defaults to true if null.
     * @return A SessionInfo object containing the new sessionId and the agent's greeting.
     */
    @AuraEnabled(cacheable=false)
    public static SessionInfo startSession(String agentId, Boolean bypassUser) {
        String endpoint = AGENT_API_BASE_URL + '/agents/' + agentId + '/sessions';

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + getAccessToken());
        request.setTimeout(30000); // Set 30-second timeout

        Map<String, Object> instanceConfig = new Map<String, Object>{
            'endpoint' => URL.getOrgDomainUrl().toExternalForm()
        };

        Map<String, Object> streamingCapabilities = new Map<String, Object>{
            'chunkTypes' => new List<String>{'Text'}
        };

        Map<String, Object> requestBody = new Map<String, Object>{
            'externalSessionKey' => System.UUID.randomUUID(),
            'instanceConfig' => instanceConfig,
            'streamingCapabilities' => streamingCapabilities,
            'bypassUser' => bypassUser != null ? bypassUser : true
        };
        request.setBody(JSON.serialize(requestBody));

        Http http = new Http();
        try {
            System.debug('Einstein API Session Request - Endpoint: ' + endpoint);
            System.debug('Einstein API Session Request - Body: ' + JSON.serialize(requestBody));

            HttpResponse response = http.send(request);

            // Handle token expiration: if unauthorized, clear cache and retry once.
            if (response.getStatusCode() == 401) {
                System.debug('Received 401 Unauthorized. Token likely expired. Clearing cache and retrying.');
                clearCachedAccessToken();
                request.setHeader('Authorization', 'Bearer ' + getAccessToken());
                response = http.send(request);
            }

            System.debug('Einstein API Session Response - Status Code: ' + response.getStatusCode());
            System.debug('Einstein API Session Response - Body: ' + response.getBody());

            if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                SessionInfo session = new SessionInfo();
                session.sessionId = (String) responseBody.get('sessionId');

                // Iterate through all messages to find the first one with text content for the greeting.
                if (responseBody.containsKey('messages') && responseBody.get('messages') != null) {
                    List<Object> messages = (List<Object>) responseBody.get('messages');
                    for (Object msgObj : messages) {
                        Map<String, Object> messageMap = (Map<String, Object>) msgObj;
                        if (messageMap.containsKey('message') && String.isNotBlank((String)messageMap.get('message'))) {
                            session.agentGreeting = (String) messageMap.get('message');
                            break; // Exit loop once we've found the greeting
                        }
                    }
                }
                return session;
            } else {
                String errorMsg = 'Start Session Error. Status: ' + response.getStatusCode() + ', Body: ' + response.getBody();
                System.debug('Einstein API Error: ' + errorMsg);
                throw new CalloutException(errorMsg);
            }
        } catch (Exception e) {
            System.debug('Einstein API Exception: ' + e.getMessage());
            System.debug('Einstein API Exception Stack Trace: ' + e.getStackTraceString());
            throw new AuraHandledException('Einstein API Error: ' + e.getMessage());
        }
    }

    /**
     * @description Sends a message to the Agentforce Agent within an active session using streaming endpoint.
     * @param sessionId The active session ID.
     * @param message The user's message text.
     * @param sequenceId The sequence ID for message ordering (optional, defaults to 1 if null).
     * @return The agent's complete text reply from streaming response.
     */
    @AuraEnabled
    public static String sendMessage(String sessionId, String message, Integer sequenceId) {
        if (sequenceId == null) {
            sequenceId = 1;
        }
        
        String endpoint = AGENT_API_BASE_URL + '/sessions/' + sessionId + '/messages/stream';

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Accept', 'text/event-stream');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + getAccessToken());
        request.setTimeout(60000); // Increase timeout for streaming responses

        Map<String, Object> messageBody = new Map<String, Object>{
            'sequenceId' => sequenceId,
            'type' => 'Text',
            'text' => message
        };

        Map<String, Object> requestBody = new Map<String, Object>{
            'message' => messageBody
        };
        request.setBody(JSON.serialize(requestBody));

        Http http = new Http();
        try {
            System.debug('Einstein API Streaming Request - Endpoint: ' + endpoint);
            System.debug('Einstein API Streaming Request - Body: ' + request.getBody());
            HttpResponse response = http.send(request);

            // Handle token expiration: if unauthorized, clear cache and retry once.
            if (response.getStatusCode() == 401) {
                System.debug('Received 401 Unauthorized. Token likely expired. Clearing cache and retrying.');
                clearCachedAccessToken();
                request.setHeader('Authorization', 'Bearer ' + getAccessToken());
                response = http.send(request);
            }

            System.debug('Einstein API Streaming Response - Status Code: ' + response.getStatusCode());
            System.debug('Einstein API Streaming Response - Body Length: ' + response.getBody().length());
            
            if (response.getStatusCode() == 200) {
                return parseStreamingResponse(response.getBody());
            } else {
                throw new CalloutException('Send Streaming Message Error: ' + response.getBody());
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }



    /**
     * @description Parses the streaming response to extract the complete message from SSE events.
     * @param streamingResponse The raw streaming response body containing SSE events.
     * @return The complete agent message text.
     */
    private static String parseStreamingResponse(String streamingResponse) {
        String completeMessage = '';
        List<String> textChunks = new List<String>();
        
        try {
            // Split the response by lines to process each SSE event
            List<String> lines = streamingResponse.split('\n');
            
            for (String line : lines) {
                line = line.trim();
                
                // Skip empty lines and SSE comments
                if (String.isBlank(line) || line.startsWith(':')) {
                    continue;
                }
                
                // Process data lines from SSE
                if (line.startsWith('data: ')) {
                    String jsonData = line.substring(6); // Remove 'data: ' prefix
                    
                    // Skip if it's just whitespace or special SSE markers
                    if (String.isBlank(jsonData) || jsonData.equals('[DONE]')) {
                        continue;
                    }
                    
                    try {
                        Map<String, Object> eventData = (Map<String, Object>) JSON.deserializeUntyped(jsonData);
                        
                        // Check if this event contains a message
                        if (eventData.containsKey('message')) {
                            Map<String, Object> messageData = (Map<String, Object>) eventData.get('message');
                            String messageType = (String) messageData.get('type');
                            
                            // Handle different message types
                            if ('TextChunk'.equals(messageType)) {
                                // Collect text chunks in order
                                String chunkText = (String) messageData.get('message');
                                if (String.isNotBlank(chunkText)) {
                                    textChunks.add(chunkText);
                                }
                            } else if ('Inform'.equals(messageType)) {
                                // Get the complete message from Inform event
                                String informMessage = (String) messageData.get('message');
                                if (String.isNotBlank(informMessage)) {
                                    completeMessage = informMessage;
                                }
                            }
                        }
                        
                        // Also check for messages array (as shown in documentation)
                        if (eventData.containsKey('messages')) {
                            List<Object> messages = (List<Object>) eventData.get('messages');
                            for (Object msgObj : messages) {
                                Map<String, Object> messageMap = (Map<String, Object>) msgObj;
                                if ('Inform'.equals(messageMap.get('type'))) {
                                    String informMessage = (String) messageMap.get('message');
                                    if (String.isNotBlank(informMessage)) {
                                        completeMessage = informMessage;
                                    }
                                }
                            }
                        }
                    } catch (JSONException jsonEx) {
                        System.debug('Error parsing SSE JSON data: ' + jsonEx.getMessage() + ' - Data: ' + jsonData);
                        // Continue processing other events
                    }
                }
            }
            
            // Return the complete message if found, otherwise join text chunks
            if (String.isNotBlank(completeMessage)) {
                return completeMessage;
            } else if (!textChunks.isEmpty()) {
                return String.join(textChunks, '');
            } else {
                return 'Error: No message content found in streaming response.';
            }
            
        } catch (Exception e) {
            System.debug('Error parsing streaming response: ' + e.getMessage());
            System.debug('Raw response: ' + streamingResponse);
            throw new AuraHandledException('Error parsing streaming response: ' + e.getMessage());
        }
    }

    /**
     * @description Ends an active chat session.
     * @param sessionId The active session ID to end.
     */
    @AuraEnabled
    public static void endSession(String sessionId) {
        String endpoint = AGENT_API_BASE_URL + '/sessions/' + sessionId;

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('DELETE');
        request.setHeader('x-session-end-reason', 'UserRequest');
        request.setHeader('Authorization', 'Bearer ' + getAccessToken());
        request.setTimeout(30000); // Set 30-second timeout

        Http http = new Http();
        try {
            HttpResponse response = http.send(request);

            // Handle token expiration: if unauthorized, clear cache and retry once.
            if (response.getStatusCode() == 401) {
                System.debug('Received 401 Unauthorized. Token likely expired. Clearing cache and retrying.');
                clearCachedAccessToken();
                request.setHeader('Authorization', 'Bearer ' + getAccessToken());
                response = http.send(request);
            }

            if (response.getStatusCode() != 204) {
                System.debug('Failed to end session: ' + response.getBody());
            }
        } catch (Exception e) {
            System.debug('Error ending session: ' + e.getMessage());
        }
    }

    /**
     * @description Helper method to clear the cached access token.
     */
    private static void clearCachedAccessToken() {
        try {
            Cache.SessionPartition sessionPartition = Cache.Session.getPartition('local.' + CACHE_PARTITION);
            sessionPartition.remove(EINSTEIN_TOKEN_CACHE_KEY);
        } catch (Cache.Session.SessionCacheException e) {
            // Cache partition doesn't exist, no action needed
            System.debug('Cache partition not found - skipping token clear: ' + e.getMessage());
        }
    }

    /**
     * @description Retrieves an OAuth access token using the Client Credentials Flow.
     * Caches the token in a specific Platform Cache partition in a namespace-safe way.
     * @return An access token string.
     */
    private static String getAccessToken() {
        // Get a reference to the partition. This handles namespaces automatically.
        String cachedToken = null;
        Cache.SessionPartition sessionPartition = null;
        
        try {
            sessionPartition = Cache.Session.getPartition('local.' + CACHE_PARTITION);
            // First, check if a valid token is already in the cache using the partition reference.
            cachedToken = (String) sessionPartition.get(EINSTEIN_TOKEN_CACHE_KEY);
            if (String.isNotBlank(cachedToken)) {
                return cachedToken;
            }
        } catch (Cache.Session.SessionCacheException e) {
            // Cache partition doesn't exist, continue without caching
            System.debug('Cache partition not found - proceeding without cache: ' + e.getMessage());
        }

        // --- Configuration via Custom Metadata ---
        Einstein_Configuration__mdt config = Einstein_Configuration__mdt.getInstance('Default');
        String clientId = config.Client_Id__c;
        String clientSecret = config.Client_Secret__c;
        String authEndpoint = config.Auth_Endpoint__c;

        String tokenEndpoint = authEndpoint + '/services/oauth2/token';

        // Prepare the body for the token request.
        String body = 'grant_type=client_credentials' +
                      '&client_id=' + clientId +
                      '&client_secret=' + clientSecret;

        HttpRequest request = new HttpRequest();
        request.setEndpoint(tokenEndpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setBody(body);
        request.setTimeout(30000); // Set 30-second timeout

        Http http = new Http();
        try {
            System.debug('OAuth Token Request - Endpoint: ' + tokenEndpoint);
            System.debug('OAuth Token Request - Body: ' + body);

            HttpResponse response = http.send(request);
            System.debug('OAuth Token Response - Status Code: ' + response.getStatusCode());
            System.debug('OAuth Token Response - Body: ' + response.getBody());

            if (response.getStatusCode() == 200) {
                Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                String accessToken = (String) responseBody.get('access_token');

                // Put the token into our specific cache partition using the partition reference.
                try {
                    if (sessionPartition != null) {
                        sessionPartition.put(EINSTEIN_TOKEN_CACHE_KEY, accessToken);
                    }
                } catch (Cache.Session.SessionCacheException e) {
                    // Cache partition doesn't exist, continue without caching
                    System.debug('Cache partition not found - proceeding without storing token: ' + e.getMessage());
                }

                return accessToken;
            } else {
                String errorMsg = 'Failed to get access token. Status: ' + response.getStatusCode() + ', Body: ' + response.getBody();
                System.debug('OAuth Error: ' + errorMsg);
                throw new CalloutException(errorMsg);
            }
        } catch (Exception e) {
            System.debug('OAuth Exception: ' + e.getMessage());
            System.debug('OAuth Exception Stack Trace: ' + e.getStackTraceString());
            throw new AuraHandledException('OAuth Error: ' + e.getMessage());
        }
    }
}
