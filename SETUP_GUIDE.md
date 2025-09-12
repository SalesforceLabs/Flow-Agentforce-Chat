# Flow Agentforce Chat - Post-Installation Setup Guide

This package provides **two distinct AI chat architectures** for different use cases. Choose the implementation that best fits your needs:

## 🏗️ **Architecture Overview**

### **Option 1: Agentforce Agent Chat** (`agentforceAgentChat`)
- **Use Case:** Complex conversational agents with custom actions, workflows, and business logic
- **Backend:** Einstein Agent API with session management and streaming
- **Setup:** Requires Connected App configuration and OAuth setup
- **Features:** Agent greeting, session persistence, streaming responses, custom agent behaviors
- **Best For:** Customer service bots, complex multi-turn conversations, agents with custom actions

### **Option 2: Models API Chat** (`flowAgentforceChat`)
- **Use Case:** Direct AI model interaction for general chat and content generation
- **Backend:** Salesforce Models API (aiplatform.ModelsAPI)
- **Setup:** Minimal - works out-of-the-box with Einstein licensing
- **Features:** Direct model access, typing simulation, conversation tracking, usage monitoring
- **Best For:** Simple Q&A, content generation, general AI assistance

## 🔄 **Quick Comparison**

| Feature | **Agentforce Agent Chat** | **Models API Chat** |
|---------|---------------------------|---------------------|
| **Setup Complexity** | Complex (Connected App, OAuth) | Simple (Einstein licensing only) |
| **Custom Actions** | ✅ Supported via Agent Builder | ❌ Not supported |
| **Session Management** | ✅ Automatic with persistence | ❌ Stateless |
| **Streaming Responses** | ✅ Real-time streaming | ❌ Simulated typing effect |
| **Agent Greeting** | ✅ Custom agent greeting | ❌ Not available |
| **Usage Tracking** | ❌ Not built-in | ✅ Credit monitoring |
| **Model Selection** | ❌ Agent-defined | ✅ Configurable |
| **Business Logic Integration** | ✅ Via Agent actions | ❌ Component-level only |
| **Best for Beginners** | ❌ Advanced users | ✅ Quick prototyping |

---

## 🔧 Configuration Steps

### **For Agentforce Agent Chat Implementation**

#### 1. Configure Connected App (Required for `agentforceAgentChat` only)

**Important:** Starting with Summer '25, you can no longer create connected apps from App Manager in Setup. To create a connected app, go to Settings under External Client Apps in Setup. Agent API doesn't currently support external client apps (ECAs)—it only supports connected apps.

**Create Connected App:**
1. Open your org and go to **Setup**
2. From Setup, select **Settings** under **Apps → External Client Apps**
3. Turn on **Allow creation of connected apps**
4. Click the **New Connected App** button
5. For **Connected App Name**, specify an app name
6. For **Contact Email**, specify your admin email address
7. In the **API** section, check **Enable OAuth Settings**. This action displays additional OAuth-related settings
8. For **Callback URL**, specify `https://login.salesforce.com`
9. From **Selected OAuth Scopes**, add these scopes to the connected app:
   - Access chatbot services (`chatbot_api`)
   - Access the Salesforce API Platform (`sfap_api`)
   - Manage user data via APIs (`api`)
   - Perform requests at any time (`refresh_token`, `offline_access`)
10. **Deselect:**
    - Require Proof Key for Code Exchange (PKCE) Extension for Support Authorization Flows
    - Require Secret for Web Server Flow
    - Require Secret for Refresh Token Flow
11. **Select:**
    - Enable Client Credentials Flow
    - Issue JSON Web Token (JWT)-based access tokens for named users
12. From the bottom of the page, save the app, and then click **Continue**

**Configure Connected App Policies:**
1. After saving the app, you see the Manage Connected Apps page. Click **Manage**
2. Click **Edit Policies**
3. In the **OAuth Policies** section, from the **Permitted Users** dropdown, select the appropriate permitted users
4. In the **Client Credentials Flow** section, set **Run As** to a user that has at least API Only access
5. From the **JWT-Based Access Token Settings for Named Users** section, keep **Issue JSON Web Token (JWT)-based access tokens** checked and leave the **Token Timeout** value at 30 minutes
6. Save the app

**Add Connected App to Agent:**
1. From Setup, select **Agentforce Agents**. Select your agent
2. Select the **Connections** tab, and click **Add** from the Connections section
3. Add a new API connection, choose your connected app, and then save

**Obtain Credentials:**
1. From Setup, select **App Manager**
2. Find your connected app, click the dropdown arrow on the right, and then click **View**
3. Click **Manage Consumer Details**
4. Copy **Consumer Key** and **Consumer Secret**

#### 2. Create Platform Cache Partition (Optional but Recommended for `agentforceAgentChat`)

Create a Platform Cache partition for session caching to improve performance:

1. Go to **Setup → Platform Cache → Partition**
2. Click **New Platform Cache Partition**
3. Configure:
   - **Partition Name:** `einsteinagentcache`
   - **Type:** Session Cache
   - **Size:** 5 MB (minimum recommended)
   - **Description:** Cache partition for Einstein Agent API tokens

**Note:** If this partition is not created, the application will work but without token caching, which may result in more OAuth requests.

#### 3. Update Custom Metadata Types (Required for `agentforceAgentChat`)

We need to update the custom metadata records that are included in the package.

**Navigate to Custom Metadata Types:**
- Go to **Setup → Custom Metadata Types**

**Access the Einstein Configuration:**
- Click **Manage Records** next to **Einstein Configuration**

**Edit the Default Record:**
- Click **Edit** on the **Default** record

**Locate Configuration Fields:**
The page layout includes all configuration fields in the "Einstein API Configuration" section.

**Update the Required Fields:**

#### Client ID
- **Current Value:** `YOUR_CONNECTED_APP_CLIENT_ID_HERE`
- **Update To:** Your Connected App's Consumer Key from Step 1

#### Client Secret
- **Current Value:** `YOUR_CONNECTED_APP_CLIENT_SECRET_HERE`
- **Update To:** Your Connected App's Consumer Secret from Step 1

#### Auth Endpoint
- **Current Value:** `https://YOUR_ORG_DOMAIN.my.salesforce.com`
- **Update To:** Your org's domain URL (e.g., `https://mycompany.my.salesforce.com`)

**Save the Record:**
- Click **Save** to apply your changes

**Note:** These fields are subscriber-controlled, meaning they can be customized by each subscriber organization when the package is installed.

#### 4. Configure Agent ID (Required for `agentforceAgentChat`)

Update the default Agent ID in the component:
1. Navigate to **Setup → Lightning Components**
2. Find `agentforceAgentChat` component
3. Update the `agentId` property with your actual Einstein Agent ID
4. You can find your Agent ID in the URL when viewing your agent in Setup

---

### **For Models API Chat Implementation**

#### 1. Einstein Licensing (Required for `flowAgentforceChat`)

Ensure your org has:
- **Einstein 1 Platform** license or
- **Einstein for Sales/Service** with appropriate credits
- **AI Platform** access enabled

#### 2. Model Access Configuration

The Models API chat uses the default model `sfdc_ai__DefaultGPT4Omni`. You can:
- Use this default model (recommended)
- Configure different models via the component's `modelName` property
- Set `usageType` to 'starter' or 'standard' based on your org's configuration

---

### **Common Configuration Steps**

#### 1. Assign Permission Set

Assign the **AgentforceAgentController Access** permission set to users who need to access the AI functionality.

#### 2. Verify Remote Site Settings

The package includes these Remote Site Settings (no action needed):
- ✅ `AgentsAPI` - `https://api.salesforce.com` (for Agentforce Agent Chat)
- ✅ `Salesforce_API` - `https://api.salesforce.com` (for both implementations)

## 🧪 Testing the Setup

### **For Agentforce Agent Chat:**
1. Run the test class: `AgentforceAgentControllerTest`
2. Ensure all tests pass (should see successful OAuth and API tests)
3. Verify your Einstein Agent is configured and active in Setup
4. Test the `agentforceAgentChat` component in a Flow or Lightning App

### **For Models API Chat:**
1. Run the test class: `ModelsAPIChatGenerationsTest`
2. Verify Einstein licensing is active in your org
3. Test the `flowAgentforceChat` component in a Flow or Lightning App

### **Common Tests:**
- Run `ChatMessageTest` for message wrapper functionality
- Verify both components render properly in Lightning App Builder

---

## 🎯 **Component Usage Guide**

### **`agentforceAgentChat` Component**

**When to Use:**
- Custom Einstein Agents with specific actions
- Complex conversation flows with context preservation
- Customer service scenarios requiring agent handoffs
- Multi-turn conversations with business logic

**Configuration Properties:**
- `agentId` (required): Your Einstein Agent ID
- `bypassUser`: Whether to bypass user authentication
- `conversationHistory`: Output property for conversation transcript
- `lastAgentMessage`: Output property for the latest agent response

**Features:**
- Real-time streaming responses
- Automatic session management
- Agent greeting messages
- Conversation persistence
- Flow integration for output capture

### **`flowAgentforceChat` Component**

**When to Use:**
- Direct model interactions for Q&A
- Content generation and text processing
- Simple conversational interfaces
- Scenarios without complex agent logic

**Configuration Properties:**
- `modelName`: AI model to use (default: `sfdc_ai__DefaultGPT4Omni`)
- `usageType`: 'starter' or 'standard' (affects request calculation)
- `labelText`: Custom input field label
- `placeholderText`: Custom placeholder text
- `messageOut`: Output property for full conversation
- `messageCollection`: Output array of individual messages
- `consumedRequests`: Output property tracking API usage

**Features:**
- Typing simulation effects
- Copy-to-clipboard functionality
- Usage tracking and monitoring
- Flow integration for conversation output
- Customizable UI elements

---

## 🏗️ **Architecture Deep Dive**

### **Backend Classes:**
- **`AgentforceAgentController`** - Manages Einstein Agent API interactions, OAuth, and session handling
- **`ModelsAPIChatGenerations`** - Handles direct Models API integration using aiplatform.ModelsAPI
- **`ChatMessage`** - Universal message wrapper class for both implementations

### **Authentication & API Access:**
- **Agentforce Agent:** Custom OAuth implementation with Client Credentials Flow
- **Models API:** Built-in Salesforce authentication with Einstein licensing

### **Data Flow:**
- **Agentforce Agent:** Component → Controller → Einstein Agent API → Streaming Response
- **Models API:** Component → Controller → aiplatform.ModelsAPI → Direct Response

## 🔍 Troubleshooting

### **Agentforce Agent Chat Issues:**

**"Invalid client credentials" error:**
- Verify Custom Metadata record has correct Connected App values
- Ensure Connected App has Client Credentials Flow enabled
- Check that Client Credentials Flow is enabled in Connected App settings

**"Unauthorized" errors:**
- Verify Remote Site Settings for `AgentsAPI` are active
- Ensure user has the **AgentforceAgentController Access** permission set
- Check Connected App policies allow the running user

**Cache-related errors:**
- Ensure Platform Cache partition `einsteinagentcache` exists
- Verify partition has sufficient allocated space (5MB minimum)
- Check org cache limits haven't been exceeded

**No agent response or session timeout:**
- Verify Einstein Agent is properly configured and active in Setup
- Check that the agent ID in the component matches your actual agent
- Ensure agent has proper topic coverage and actions configured
- Test agent directly in Agent Builder first

**Streaming issues:**
- Check network connectivity for Server-Sent Events (SSE)
- Verify org allows streaming API calls
- Increase component timeout settings if needed

### **Models API Chat Issues:**

**"Model not accessible" error:**
- Verify Einstein licensing is active (Einstein 1 Platform or Einstein for Sales/Service)
- Check that AI Platform access is enabled in your org
- Ensure the specified model name is valid and available

**"Insufficient credits" error:**
- Check Einstein credit balance in Setup → Einstein Credits
- Verify usage calculation settings match your org's license type
- Consider adjusting `usageType` from 'standard' to 'starter'

**No response from model:**
- Test Models API access directly in Setup → Einstein Platform Services
- Verify message format is correct (role/message structure)
- Check debug logs for API call details

### **Common Issues:**

**Component not loading:**
- Verify permission set assignment
- Check Lightning Security settings
- Ensure components are properly deployed

**Flow integration problems:**
- Verify output properties are properly mapped in Flow
- Check that property names match component API specifications
- Test components standalone before embedding in Flows

---

## 📊 **Performance Optimization**

### **Agentforce Agent Chat:**
- Enable Platform Cache partition for token caching
- Monitor session lifecycle to avoid unnecessary sessions
- Use appropriate timeout values for your use case

### **Models API Chat:**
- Monitor `consumedRequests` output to track usage
- Optimize message history length to reduce token consumption
- Use appropriate `usageType` setting for your license

---

## 📞 Support & Resources

**Before seeking support, verify:**
1. Appropriate licensing (Einstein 1 Platform, Einstein for Sales/Service, or Einstein Credits)
2. All configuration steps completed for your chosen implementation
3. Permission sets assigned to users
4. Test classes passing for your implementation
5. Remote Site Settings active

**Additional Resources:**
- [Einstein Agent Builder Documentation](https://help.salesforce.com/s/articleView?id=sf.bot_service_intro.htm)
- [Models API Documentation](https://developer.salesforce.com/docs/einstein/genai/guide/models-api.html)
- [Einstein Platform Services Setup](https://help.salesforce.com/s/articleView?id=sf.bi_elt_admin_license.htm)