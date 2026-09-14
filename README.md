# Learning-AI-in-BC

A Proof of Concept (PoC) demonstrating how to natively integrate external Artificial Intelligence (**Groq Cloud**, OpenAI, Anthropic, DeepSeek, or Local Ollama) directly inside **Microsoft Dynamics 365 Business Central (AL)**.

---

## ⚡ Why Groq for Business Central?

- **Ultra-low latency inference**: Delivers responses in milliseconds, making in-ERP ERP interactions feel instantaneous.
- **OpenAI Compatibility**: Seamlessly integrates using standard OpenAI chat completion payloads.
- **Top Open-Weights Models**: Powered by `llama-3.3-70b-versatile`, `llama-3.1-8b-instant`, `mixtral-8x7b-32768`, etc.

---

## 🚀 Features

- **Native REST & JSON**: Uses AL's native `HttpClient` and `JsonObject` structures to communicate with Groq's high-speed API.
- **Dynamic AI Setup Page**: Configure API Endpoints, Model Names, and your Groq API Key (`gsk_...`) directly inside Business Central without hardcoding secrets.
- **Connection Test Action**: Built-in test trigger in the setup card to verify connectivity to Groq.
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

## 🛠️ Configuration Defaults

| Setting | Default Value |
| :--- | :--- |
| **API Endpoint** | `https://api.groq.com/openai/v1/chat/completions` |
| **Model Name** | `llama-3.3-70b-versatile` *(or `llama-3.1-8b-instant`)* |
| **API Key** | Your Groq API Key (`gsk_...`) |

---

## 🏁 Quickstart

1. Build and publish the extension (**`F5`** or **`Ctrl+F5`**).
2. In Business Central, open **Extension Management** → Find **ALProject1** → **Configure** → Enable **Allow HttpClient Requests**.
3. Search for **AI Setup** (`Alt+Q`), paste your `gsk_...` Groq API key, and click **Test AI Connection**.
4. Open the **Customers** list and click **Analyze with AI** on any customer record!
