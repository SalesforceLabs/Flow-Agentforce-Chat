# Flow Agentforce Chat

A comprehensive package for integrating Salesforce Agentforce Agents and AI Models directly into Salesforce Flows and Lightning Pages. This project provides a production-ready chat interface with native integration patterns that require **no Connected Apps, no Secrets, and no manual OAuth management**.

## 🏗️ Architecture Overview

The package provides three distinct AI interaction architectures:

### 1. Agentforce Agent Chat (`flowAgentforceAgentChat`)
*   **Use Case**: Interact with configured Einstein Agents (Service Agents, Employee Agents, etc.).
*   **Backend**: Native Apex Controller (`AgentforceAgentController`).
*   **Setup**: Zero-config authentication (uses current user session).
*   **Features**: Real-time streaming, agent greetings, animated joining indicator, configurable auto-start with delay, dynamic placeholders.
*   **Best For**: Deploying Agentforce personas with custom topics and actions into Flow screens.

### 2. Models API Chat (`flowAgentforceChat`)
*   **Use Case**: Direct LLM interaction (GPT-4, Claude, etc.) for general chat.
*   **Backend**: Native Apex Controller (`ModelsAPIChatGenerations`) using Salesforce Models API.
*   **Setup**: Requires Einstein licensing only.
*   **Features**: typing simulation, usage/credit tracking, multi-model support.
*   **Best For**: Simple Q&A, summarization, and content generation tasks.

### 3. Flow Integration System (`flowRenderer`)
*   **Use Case**: Launch and render Salesforce Flows *inside* Agentforce as interactive components.
*   **Backend**: Native Flow Engine with automated output capture into the current session.
*   **Features**: Automated output capture, structured data collection, and direct agent-retrievable outputs.
*   **Best For**: Complex data collection or business processes within a chat session.

---

## 🚀 Quick Setup (New Implementation)

Starting with Version 2.2, the requirement for Connected Apps and Named Credentials has been **removed**. The system now uses native Salesforce-to-Salesforce "Loopback" authentication.

### 1. Remote Site Settings
Ensure your **Org's My Domain URL** is allowed for callouts:
1.  Go to **Setup > Remote Site Settings**.
2.  Add a new entry for your org (e.g., `OrgLoopback` -> `https://your-domain.my.salesforce.com`).

### 2. Component Configuration
When adding the `flowAgentforceAgentChat` component to a Flow or Page:
*   **Agentforce Agent API Name**: Use the **API Name** of your agent (e.g., `Service_Agent`) instead of the ID.
*   **Default Starting Message**: (Optional) Text to pre-fill or auto-send.
*   **Auto-Start**: Set to `True` to send the default message automatically.
*   **Auto-Start Delay**: (Default 2000ms) Delay before the auto-sent message is triggered.

### 3. Permissions
Assign the **Flow Agentforce Chat Access** permission set to all users. Users must also have the standard **Einstein Agent User** permission set assigned by your administrator.

---

## 🛠️ Configuration & Customization

See the [SETUP_GUIDE.md](SETUP_GUIDE.md) for a detailed breakdown of each implementation option and performance optimization tips.

## 🔍 Troubleshooting

*   **401 Unauthorized**: Ensure the user has "Einstein Agent User" permissions and the `OrgLoopback` Remote Site Setting is correct.
*   **404 Not Found**: Verify you are using the **Agent API Name** (not the 18-character ID).
*   **Message Formatting**: The Apex controller automatically parses JSON responses (e.g. `{"type":"Text","value":"..."}`) into plain text for the UI.

---

## 📄 License
MIT License - Developed for the Salesforce community.
