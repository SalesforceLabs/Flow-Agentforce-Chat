@isTest
public class AgentforceAgentHttpCalloutMock implements HttpCalloutMock {
    
    public enum ResponseType {
        SUCCESS,
        TOKEN_EXPIRED_THEN_SUCCESS,
        ERROR,
        OAUTH_ERROR
    }
    
    private ResponseType responseType;
    private Integer callCount = 0;
    
    public AgentforceAgentHttpCalloutMock(ResponseType responseType) {
        this.responseType = responseType;
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        callCount++;
        
        // Handle OAuth token requests
        if (req.getEndpoint().contains('/services/oauth2/token')) {
            return handleOAuthRequest(req, res);
        }
        
        // Handle Einstein Agent API requests
        if (req.getEndpoint().contains('/einstein/ai-agent/v1')) {
            return handleAgentAPIRequest(req, res);
        }
        
        // Default error response for unexpected endpoints
        res.setStatusCode(404);
        res.setBody('{"error": "Endpoint not found"}');
        return res;
    }
    
    private HttpResponse handleOAuthRequest(HttpRequest req, HttpResponse res) {
        if (responseType == AgentforceAgentHttpCalloutMock.ResponseType.OAUTH_ERROR) {
            res.setStatusCode(400);
            res.setBody('{"error": "invalid_client", "error_description": "Invalid client credentials"}');
            return res;
        }
        
        // Success response for OAuth
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{' +
            '"access_token": "mock_access_token_123",' +
            '"token_type": "Bearer",' +
            '"expires_in": 3600' +
        '}');
        return res;
    }
    
    private HttpResponse handleAgentAPIRequest(HttpRequest req, HttpResponse res) {
        // Handle token expiration scenario
        if (responseType == AgentforceAgentHttpCalloutMock.ResponseType.TOKEN_EXPIRED_THEN_SUCCESS && callCount == 1) {
            res.setStatusCode(401);
            res.setBody('{"error": "Unauthorized", "message": "Invalid or expired token"}');
            return res;
        }
        
        // Handle error scenario
        if (responseType == AgentforceAgentHttpCalloutMock.ResponseType.ERROR) {
            res.setStatusCode(500);
            res.setBody('{"error": "Internal Server Error", "message": "Something went wrong"}');
            return res;
        }
        
        // Handle start session requests
        if (req.getMethod() == 'POST' && req.getEndpoint().contains('/sessions') && !req.getEndpoint().contains('/messages')) {
            return handleStartSessionRequest(req, res);
        }
        
        // Handle send message requests (both streaming and non-streaming)
        if (req.getMethod() == 'POST' && req.getEndpoint().contains('/messages')) {
            return handleSendMessageRequest(req, res);
        }
        
        // Handle end session requests
        if (req.getMethod() == 'DELETE') {
            return handleEndSessionRequest(req, res);
        }
        
        // Default success response
        res.setStatusCode(200);
        res.setBody('{"status": "success"}');
        return res;
    }
    
    private HttpResponse handleStartSessionRequest(HttpRequest req, HttpResponse res) {
        res.setStatusCode(201);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{' +
            '"sessionId": "mock_session_123",' +
            '"messages": [' +
                '{' +
                    '"id": "msg_1",' +
                    '"message": "Hello! I\'m here to help you today. How can I assist you?",' +
                    '"role": "agent",' +
                    '"timestamp": "2024-01-15T10:30:00Z"' +
                '}' +
            '],' +
            '"status": "active"' +
        '}');
        return res;
    }
    
    private HttpResponse handleSendMessageRequest(HttpRequest req, HttpResponse res) {
        res.setStatusCode(200);
        
        // Check if this is a streaming request
        String acceptHeader = req.getHeader('Accept');
        if (acceptHeader != null && acceptHeader.contains('text/event-stream')) {
            // Return Server-Sent Events (SSE) format for streaming
            res.setHeader('Content-Type', 'text/event-stream');
            res.setHeader('Cache-Control', 'no-cache');
            res.setHeader('Connection', 'keep-alive');
            
            String sseResponse = 
                'data: {"timestamp": 1736902938827, "originEventId": "1736902935340-REQ", "traceId": "2fdb1d5e7eb48d35b9d1ba402eeb4b69", "offset": 0, "message": {"type": "ProgressIndicator", "id": "c4410599-8c0a-412d-910f-a60e4159d807", "indicatorType": "ACTION", "message": "Working on it"}}\n\n' +
                'data: {"timestamp": 1736902952425, "originEventId": "1736902935340-REQ", "traceId": "2fdb1d5e7eb48d35b9d1ba402eeb4b69", "offset": 1, "message": {"type": "TextChunk", "id": "6fc64974-9c20-484e-8b8c-105e460d4a00", "offset": 1, "message": "Thank", "formatType": "Text"}}\n\n' +
                'data: {"timestamp": 1736902952500, "originEventId": "1736902935340-REQ", "traceId": "2fdb1d5e7eb48d35b9d1ba402eeb4b69", "offset": 2, "message": {"type": "TextChunk", "id": "6fc64974-9c20-484e-8b8c-105e460d4a01", "offset": 2, "message": " you", "formatType": "Text"}}\n\n' +
                'data: {"timestamp": 1736902952575, "originEventId": "1736902935340-REQ", "traceId": "2fdb1d5e7eb48d35b9d1ba402eeb4b69", "offset": 3, "message": {"type": "TextChunk", "id": "6fc64974-9c20-484e-8b8c-105e460d4a02", "offset": 3, "message": " for", "formatType": "Text"}}\n\n' +
                'data: {"messages": [{"type": "Inform", "id": "f0313bcb-65a2-4abb-9d84-b872247b1420", "metrics": {}, "feedbackId": "ab403163-b87f-4e4b-9fa6-18670a2be655", "planId": "ab403163-b87f-4e4b-9fa6-18670a2be655", "isContentSafe": true, "message": "Thank you for your message. I understand your question and here is my detailed response with helpful information.", "result": [], "citedReferences": []}]}\n\n' +
                'data: {"timestamp": 1736902953027, "originEventId": "1736902935340-REQ", "traceId": "2fdb1d5e7eb48d35b9d1ba402eeb4b69", "offset": 0, "message": {"type": "EndOfTurn", "id": "2a2be92b-f479-481a-9f22-1e5bf39e038e"}}\n\n';
            
            res.setBody(sseResponse);
        } else {
            // Return regular JSON response for backward compatibility
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{' +
                '"messages": [' +
                    '{' +
                        '"id": "msg_2",' +
                        '"message": "Thank you for your message. I understand your question and here is my response.",' +
                        '"role": "agent",' +
                        '"timestamp": "2024-01-15T10:35:00Z"' +
                    '}' +
                '],' +
                '"status": "success"' +
            '}');
        }
        
        return res;
    }
    
    private HttpResponse handleEndSessionRequest(HttpRequest req, HttpResponse res) {
        res.setStatusCode(204);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('');
        return res;
    }
}