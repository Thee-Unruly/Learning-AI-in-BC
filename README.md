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

### 3. 💬 Floating In-App AI Onboarding & FAQ Bot Widget
- **Website-Style Floating Chat Launcher**: Bottom-right 💬 trigger icon embedded directly on Business Central Role Centers.
- **Interactive Multi-Turn Guidance**: Helps new employees navigate Business Central, find pages using Tell Me (`Alt+Q`), and learn company policies.
- **One-Click FAQ Chips**: Instant guides for common procedures (e.g. Sales Invoices, Credit Limits, AI features).
- **100% On-Premise Compatible**: Powered by native `ControlAddIn` (HTML5/CSS3/JS) and AL `HttpClient`.

### 4. ⚙️ Universal AI Integration Engine
- **Configurable Setup Page**: Set Endpoints, Model IDs (e.g. `gpt-oss-120b`, `llama-3.3-70b-versatile`, local Ollama), and API Keys without touching code.
- **Timeout & Graceful Fallback**: 20-second connection timeout with `[TryFunction]` safety to guarantee seamless UX.
- **Reusable AL Codeunit**: `AIManagement.AskAI(Prompt)`, `AskERPGuide(Question)`, and email generators reusable across any BC object.

---

## 📂 Project Architecture

```text
ALProject1/
├── app.json                                 # Extension manifest & runtime configuration
├── AISetup.Table.al                         # Setup table for credentials & endpoint
├── AISetup.Page.al                          # Setup card with connection test action
├── AIManagement.Codeunit.al                 # Universal HTTP/JSON AI service & ERP guide
├── AICustomerAssistant.Page.al              # Customer AI workspace & email drafter
├── CustomerCardAIExt.PageExt.al             # Customer Card extension linking to AI Assistant
├── CustomerListAIExt.PageExt.al             # Customer List extension linking to AI Assistant
├── AIChatBot.CardPart.al                    # CardPart hosting the interactive chatbot
├── BusinessManagerRoleCenterAIExt.PageExt.al# Embeds chatbot on Business Manager Role Center
├── OrderProcessorRoleCenterAIExt.PageExt.al  # Embeds chatbot on Order Processor Role Center
└── AIChatBot/
    ├── AIChatBot.ControlAddIn.al            # AL Control Add-in definition
    ├── scripts/
    │   ├── startup.js                       # Startup initialization script
    │   └── chatbot.js                       # Two-way chat UI, events, markdown parser
    └── styles/
        └── chatbot.css                      # Modern glassmorphism floating styles
```
