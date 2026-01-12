/**
 * @description HTTP Mock implementation for the Salesforce Models API.
 * Simulates response from the einstein/platform chat generations endpoint.
 */
@isTest
public class ModelsAPIGenerationHttpCalloutMock implements HttpCalloutMock {
    
    /**
     * @description Generates a mock HTTP response for the Models API callout.
     * @param req The outgoing HTTP request.
     * @return A populated HTTP response with mock chat completion data.
     */
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        // Mock body representing the structure of Models API response
        String body = '{"id":"mock_gen_123","generationDetails":{"generations":[{"id":"g1","role":"assistant","content":"Mock AI response content."}]}}';
        
        res.setBody(body);
        res.setStatusCode(200);
        return res;
    }
}