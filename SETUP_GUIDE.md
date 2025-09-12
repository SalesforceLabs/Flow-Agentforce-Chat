# Flow Agentforce Chat - Post-Installation Setup Guide

This package provides **three distinct AI interaction architectures** for different use cases. Choose the implementation that best fits your needs:

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

### **Option 3: Flow Integration System** (`flowRenderer` + Invocable Actions)
- **Use Case:** Launch Salesforce Flows within Agentforce and capture their outputs
- **Backend:** Native Salesforce Flow execution with output capture system
- **Setup:** Deploy components and configure Flow actions in Agentforce
- **Features:** Flow rendering, output capture, session management, automatic retrieval
- **Best For:** Complex business processes, data collection workflows, multi-step user interactions

## 🔄 **Quick Comparison**

| Feature | **Agentforce Agent Chat** | **Models API Chat** | **Flow Integration System** |
|---------|---------------------------|---------------------|------------------------------|
| **Setup Complexity** | Complex (Connected App, OAuth) | Simple (Einstein licensing only) | Medium (Flow deployment + actions) |
| **Custom Actions** | ✅ Supported via Agent Builder | ❌ Not supported | ✅ Full Flow capabilities |
| **Session Management** | ✅ Automatic with persistence | ❌ Stateless | ✅ Session-based output tracking |
| **Streaming Responses** | ✅ Real-time streaming | ❌ Simulated typing effect | ❌ Flow-based interaction |
| **Agent Greeting** | ✅ Custom agent greeting | ❌ Not available | ❌ Flow-dependent |
| **Usage Tracking** | ❌ Not built-in | ✅ Credit monitoring | ✅ Session and output tracking |
| **Model Selection** | ❌ Agent-defined | ✅ Configurable | ❌ Not applicable |
| **Business Logic Integration** | ✅ Via Agent actions | ❌ Component-level only | ✅ Full Salesforce Flow capabilities |
| **Data Collection** | ❌ Limited | ❌ Limited | ✅ Complex forms and workflows |
| **Output Capture** | ❌ Not built-in | ✅ Conversation outputs | ✅ Structured Flow outputs |
| **Best for Beginners** | ❌ Advanced users | ✅ Quick prototyping | ✅ Familiar Flow developers |

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

### **For Flow Integration System**

#### 1. Deploy Flow Components (Required for Flow integration)

The Flow Integration System requires no additional configuration - all components are included in the package:

**Components Included:**
- **`flowRenderer`** - LWC for rendering Flows in Agentforce
- **Flow Action classes** - Invocable methods for Flow management
- **Output handling system** - Automatic capture and retrieval

**Verification Steps:**
1. Go to **Setup → Flows**
2. Confirm the following Invocable Actions are available:
   - "Launch Flow as Input" (`FlowActionWithOutputs`)
   - "Retrieve Flow Outputs" (`FlowOutputRetriever`) 
   - "Auto Retrieve Flow Outputs by Session" (`AutoFlowOutputRetriever`)

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

### **For Flow Integration System:**
1. Run the test classes: `FlowDetailsTest`, `FlowOutputHandlerTest`, `FlowOutputRetrieverTest`
2. Verify all Flow action classes are accessible from Flow Builder
3. Create a simple test Flow and verify it renders in the `flowRenderer` component
4. Test Flow output capture by completing a Flow with output variables

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

### **`flowRenderer` Component**

**When to Use:**
- Launch Salesforce Flows within Agentforce interactions
- Collect structured data through Flow screens
- Execute complex business processes with user interaction
- Capture and process Flow outputs automatically

**Target Platforms:**
- `lightning__AgentforceInput`: For rendering Flows as input components
- `lightning__AgentforceOutput`: For displaying Flow results

**Key Properties:**
- `value`: FlowDetails object containing flow configuration
- `readOnly`: Boolean to control interaction mode
- `flowOutputsJson`: Captured Flow outputs in JSON format

**Features:**
- **Flow Rendering**: Renders any Salesforce Flow within Agentforce
- **Session Management**: Tracks each Flow execution with unique session IDs
- **Output Capture**: Automatically captures all Flow output variables
- **Output Storage**: Stores outputs for later retrieval by Agents
- **Event Handling**: Dispatches events for Flow completion and output storage
- **Error Handling**: Graceful error handling with partial output capture

**Flow Execution Lifecycle:**
1. **Initialize**: Flow loads with input variables (if provided)
2. **Execute**: User interacts with Flow screens
3. **Complete**: Flow finishes (status: FINISHED or FINISHED_SCREEN)
4. **Capture**: Component automatically captures all output variables
5. **Store**: Outputs stored with session ID for retrieval
6. **Notify**: Events dispatched to notify Agent of completion

---

## 🏗️ **Architecture Deep Dive**

### **Backend Classes:**

#### **Chat Implementations:**
- **`AgentforceAgentController`** - Manages Einstein Agent API interactions, OAuth, and session handling
- **`ModelsAPIChatGenerations`** - Handles direct Models API integration using aiplatform.ModelsAPI
- **`ChatMessage`** - Universal message wrapper class for both implementations

#### **Flow Integration System:**
- **`FlowOutputHandler`** - Core class for storing and retrieving Flow outputs with caching
- **`FlowActionWithOutputs`** - Invocable method that launches Flows with session tracking
- **`FlowOutputRetriever`** - Retrieves stored Flow outputs by key or session ID  
- **`AutoFlowOutputRetriever`** - Advanced retrieval with automatic formatting and session lookup
- **`FlowDetails`** - Data transfer object containing Flow configuration and metadata

### **Authentication & API Access:**
- **Agentforce Agent:** Custom OAuth implementation with Client Credentials Flow
- **Models API:** Built-in Salesforce authentication with Einstein licensing
- **Flow Integration:** Native Salesforce authentication (no additional setup required)

### **Data Flow:**
- **Agentforce Agent:** Component → Controller → Einstein Agent API → Streaming Response
- **Models API:** Component → Controller → aiplatform.ModelsAPI → Direct Response
- **Flow Integration:** Agent Action → FlowRenderer → Native Flow → Output Capture → Storage → Retrieval

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

### **Flow Integration System Issues:**

**Flow not rendering in `flowRenderer`:**
- Verify the Flow exists and is active
- Check that `FlowDetails` object has correct `flowApiName`
- Ensure the Flow has at least one Screen element
- Verify component targets include `lightning__AgentforceInput`

**Flow outputs not being captured:**
- Ensure Flow has output variables defined
- Check that variables are marked as "Available for output" 
- Verify Flow completes with status FINISHED or FINISHED_SCREEN
- Check browser console for capture errors

**"Session not found" when retrieving outputs:**
- Verify session ID was properly generated and stored
- Check that outputs were stored before attempting retrieval
- Ensure session ID format matches: `FlowApiName_Timestamp_UserId`
- Note: Cache is user-session specific and temporary

**Invocable Actions not available in Flow Builder:**
- Refresh Flow Builder page after package deployment
- Verify Apex classes are properly deployed
- Check that classes have correct `@InvocableMethod` annotations
- Ensure user has appropriate permissions to access Apex classes

**Flow execution errors:**
- Check Flow's fault paths and error handling
- Verify all required input variables are provided
- Test Flow standalone before using in `flowRenderer`
- Review Flow debug logs for specific error details

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

### **Flow Integration System:**
- Use session IDs for grouping related Flow executions
- Store outputs immediately after Flow completion for best retrieval results
- Consider implementing custom object storage for persistent output retention
- Design Flows with clear output variables for optimal data capture

---

## 🎯 **Flow Integration Usage Guide**

The Flow Integration System enables you to launch and interact with Salesforce Flows directly within Agentforce agents. Here's how to implement it:

### **Step 1: Prepare Your Flow**

**Create a Flow with:**
1. **Input Variables** (optional): Data you want to pass to the Flow
2. **Screen Elements**: User interface components for interaction  
3. **Output Variables**: Data you want to capture after completion
4. **Mark variables** as "Available for output" in Flow Builder

**Example Flow Configuration:**
```
Flow Name: Customer_Survey
Input Variables: 
  - customerName (Text)
  - accountId (Text)
Output Variables:
  - surveyScore (Number)
  - feedback (Text)
  - completedDate (Date)
```

### **Step 2: Configure Agent Action**

**In Agentforce Agent Builder:**
1. Add a new action using "Launch Flow as Input"
2. Configure the action:
   - **Flow API Name**: `Customer_Survey`
   - **Flow Label**: "Customer Feedback Survey"
   - **Input Variables**: `{"customerName": "John Doe", "accountId": "001xx000003DHPh"}`
3. The system automatically generates a session ID for output tracking

### **Step 3: Flow Execution**

**When triggered by the agent:**
1. **`flowRenderer`** component loads the specified Flow
2. User interacts with Flow screens
3. Upon completion, outputs are automatically captured
4. Session ID links the execution to retrievable outputs

### **Step 4: Retrieve Outputs**

**Use one of three retrieval methods:**

**Method 1: Auto Retrieve by Session**
```
Action: "Auto Retrieve Flow Outputs by Session"
Input: Session ID from Step 2
Output: Formatted, human-readable results
```

**Method 2: Structured Retrieval**
```  
Action: "Retrieve Flow Outputs"
Input: Output Key or Session ID + Flow API Name
Output: Raw JSON data for programmatic use
```

**Method 3: Direct Access**
- Access outputs immediately via `flowRenderer` events
- Use for real-time processing within the same agent conversation

### **Best Practices**

**Flow Design:**
- Include clear field labels and help text
- Add validation rules for data quality
- Design mobile-friendly layouts
- Test Flows standalone before Agentforce integration

**Output Variables:**
- Use descriptive variable names
- Mark all desired outputs as "Available for output"
- Consider data types for proper formatting
- Include timestamps for tracking

**Session Management:**
- Use custom session IDs for related Flow groups
- Document session patterns for team consistency
- Consider output retention requirements
- Plan for cache limitations (temporary storage)

**Agent Configuration:**
- Provide clear action descriptions
- Use meaningful Flow labels
- Test full end-to-end workflows
- Monitor output retrieval success rates

### **Common Use Cases**

1. **Data Collection**: Surveys, forms, lead qualification
2. **Approval Processes**: Multi-step approvals with routing
3. **Diagnostic Workflows**: Troubleshooting with branching logic
4. **Configuration**: User preferences, settings management
5. **Reporting**: Dynamic report generation with user inputs

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