# Learning-AI-in-BC

A Proof of Concept demonstrating native integration between **Microsoft Dynamics 365 Business Central** and external Generative AI models (**Groq Cloud / OpenAI / Anthropic / Local LLMs**) using pure AL code.

---

## 🚀 Key Capabilities

### 1. 🏢 Executive Account Intelligence
- **Natural, Human-Like Tone**: Tailored, professional enterprise phrasing without robotic buzzwords or emoji clutter.
- **Collapsible FastTabs**: Organized into clean collapsible sections for Customer Overview, Executive Analysis, and Email Drafting.
- **Live ERP Context**: Dynamically analyzes customer balances, lifetime sales volume, credit limits, and payment terms.

### 2. ✉️ Smart Business Email Drafter
- **Context-Aware Outreach**: Generates tailored emails (Re-engagement, Executive Check-in, Partnership Expansion, Balance Review) based on live account activity.
- **Editable Subject & Body**: Review and customize the generated email directly in Business Central before sending.
- **1-Click Mail Client Integration**: Open the draft directly in Outlook or your default email client with recipient, subject, and body automatically populated.

### 3. ⚙️ Universal AI Integration Engine
- **Configurable Setup Page**: Set Endpoints, Model IDs (e.g. `gpt-oss-120b`, `llama-3.3-70b-versatile`), and API Keys without touching code.
- **Reusable AL Codeunit**: `AIManagement.AskAI(Prompt)` and `AIManagement.GenerateCustomerEmail(...)` can be leveraged across any BC object.

---

## 📂 Project Architecture

```text
ALProject1/
├── app.json                          # Extension manifest & runtime configuration
├── AISetup.Table.al                  # Setup table for credentials & endpoint
├── AISetup.Page.al                   # Setup card with connection test action
├── AIManagement.Codeunit.al          # Universal HTTP/JSON AI service & email generator
├── AICustomerAssistant.Page.al       # Interactive workspace with collapsible sections & email drafter
├── CustomerCardAIExt.PageExt.al      # Customer Card extension linking to AI Assistant
└── CustomerListAIExt.PageExt.al      # Customer List extension linking to AI Assistant
```
