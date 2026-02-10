# Setup Guide: Flow Agentforce Chat

This guide covers the configuration for the three AI implementation options provided in this package.

## 🏗️ Architecture Comparison

| Feature | **Agentforce Agent Chat** | **Models API Chat** | **Flow Integration** |
| :--- | :--- | :--- | :--- |
| **Backend** | Native Apex Controller | Native Apex Controller | Native Flow Engine |
| **Authentication** | Current User Session | Built-in | Current User Session |
| **Connected App** | ❌ Not Required | ❌ Not Required | ❌ Not Required |
| **Use Case** | Persona-based Agents | Direct LLM Interaction | Structured Data Collection |

---

## 1. Agentforce Agent Chat (`flowAgentforceAgentChat`)

The most common use case. It allows you to embed a full-featured Agentforce agent into a Flow screen.

### Configuration Steps:
1.  **Permissions**: Assign users the **Flow Agentforce Chat Access** and the standard **Einstein Agent User** permission sets.
2.  **Agent API Name**: In the Flow/App Builder, set the `agentId` property to the **API Name** of your agent (found in Setup > Agents).

### New Features (v2.2):
*   **Agent Joining Indicator**: Shows an animated "Agent is joining..." message immediately upon session start for better UX.
*   **Auto-Start**: If enabled, the component will wait `autoStartDelayMs` and then automatically send the `defaultMessage`.
*   **Placeholder Mode**: if `autoStart` is false, the `defaultMessage` appears as the input placeholder.
*   **Smart Parsing**: The Apex controller automatically cleans up JSON-formatted responses from the Atlas reasoning engine.

---

## 2. Models API Chat (`flowAgentforceChat`)

Direct interaction with LLMs without an Agent persona.

### Requirements:
*   **Einstein Licensing**: Org must have Einstein 1 or Sales/Service Einstein credits.
*   **Model Name**: Defaults to `sfdc_ai__DefaultGPT4Omni`. Can be changed to any model configured in Einstein Studio.

---

## 3. Flow Integration System (`flowRenderer`)

Used to render a Salesforce Flow directly inside a chat session as an interactive component. 

> **⚠️ Beta Note**: In the current Beta release, this component is focused on UI rendering. Automated capture of Flow output variables into the agent session is planned for the GA release.

### Key Components:
*   **`flowRenderer`**: The UI component that handles the multi-step Flow interaction.
*   **`FlowDetails`**: Apex class that holds configuration for the Flow to be rendered.
*   **`Launch Flow`**: Agent action used to trigger the UI from a conversation.

---

## 🔍 Common Troubleshooting

### Authentication Issues
If you receive a 401 error, verify:
1.  The user has the **Einstein Agent User** permission set and the **Flow Agentforce Chat Access** permission set.
2.  The agent is **Active** in Agent Builder.

### ID vs API Name
The `agentId` field **must** be the API Name (e.g., `Technical_Support_Agent`). If you use the 18-character ID starting with `0Xx`, the call will return a 404 error.

