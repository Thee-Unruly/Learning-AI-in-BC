# Learning-AI-in-BC

A Proof of Concept (PoC) demonstrating how to natively integrate external Artificial Intelligence (OpenAI, Anthropic, DeepSeek, Local Ollama, or Custom REST APIs) directly inside **Microsoft Dynamics 365 Business Central (AL)**.

---

## 🚀 Features

- **Native REST & JSON**: Uses AL's native `HttpClient` and `JsonObject` structures to communicate with any OpenAI-compatible chat completion endpoint.
- **Dynamic AI Setup Page**: Configure API Endpoints, Model Names (e.g. `gpt-4o-mini`, `deepseek-chat`, `llama3`), and API Keys directly inside Business Central without hardcoding secrets.
- **Connection Test Action**: Built-in test trigger in the setup card to verify connectivity to the external LLM.
- **ERP Business Context Analysis**: Custom page extension on the **Customer List** that extracts real ERP customer metrics (Balance, Sales, Credit Limit, Terms) and sends them to the AI for executive summaries and risk recommendations.

---

## 📂 Project Structure

```text
ALProject1/
├── app.json                       # Extension manifest & runtime configuration
├── AISetup.Table.al               # Table storing endpoint, model, and masked API key
├── AISetup.Page.al                # Setup UI with connection test action
├── AIManagement.Codeunit.al       # Core service for HTTP calls & JSON serialization
└── CustomerListAIExt.PageExt.al   # Customer List extension with "Analyze with AI" action
```

---

## 🛠️ Getting Started

### 1. Requirements
- Business Central 24+ / 26+ (On-Premises or Cloud)
- AL Language Extension for VS Code
- An API Key from OpenAI, OpenRouter, Groq, or a local Ollama instance

### 2. Deployment
1. Download symbols in VS Code (`AL: Download Symbols`).
2. Build and publish the extension (`F5` or `Ctrl+F5`).
3. In Business Central, navigate to **Extension Management** → Find **ALProject1** → **Configure** → Enable **Allow HttpClient Requests**.
4. Search for **AI Setup** (`Alt+Q`), enter your API Key and Endpoint, and click **Test AI Connection**.
