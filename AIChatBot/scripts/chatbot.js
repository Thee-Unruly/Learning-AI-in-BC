(function () {
    let chatInitialized = false;
    let isWaitingForResponse = false;

    window.initAIChatBot = function () {
        if (chatInitialized || document.getElementById('ai-bot-launcher')) return;
        chatInitialized = true;

        // Create Launcher Button
        const launcher = document.createElement('div');
        launcher.id = 'ai-bot-launcher';
        launcher.title = 'Open AI ERP Onboarding & FAQ Guide';
        launcher.innerHTML = `
            <svg class="launcher-icon" viewBox="0 0 24 24">
                <path d="M12 2C6.477 2 2 6.477 2 12c0 1.821.487 3.53 1.338 5L2.1 21.9a1 1 0 0 0 1.258 1.258L8 21.862A9.957 9.957 0 0 0 12 22c5.523 0 10-4.477 10-10S17.523 2 12 2zm1 14h-2v-2h2v2zm0-4h-2V7h2v5z"/>
            </svg>
            <span class="launcher-badge"></span>
        `;
        document.body.appendChild(launcher);

        // Create Chat Window
        const chatWindow = document.createElement('div');
        chatWindow.id = 'ai-bot-window';
        chatWindow.className = 'hidden';
        chatWindow.innerHTML = `
            <div class="ai-bot-header">
                <div class="ai-bot-header-left">
                    <div class="ai-bot-avatar">🤖</div>
                    <div class="ai-bot-title-group">
                        <h3>ERP System Guide</h3>
                        <p><span class="ai-status-dot"></span> Online • Copilot Assistant</p>
                    </div>
                </div>
                <button id="ai-bot-close-btn" class="ai-bot-close-btn" title="Minimize">✕</button>
            </div>
            <div id="ai-bot-messages" class="ai-bot-messages">
                <div class="ai-welcome-card">
                    <h4>👋 Welcome to Business Central!</h4>
                    <p>I am your ERP Onboarding & FAQ Assistant. Ask me how to navigate pages, post documents, or company policies.</p>
                    <div class="ai-faq-chips-container">
                        <button class="ai-faq-chip" data-question="How do I create and post a Sales Invoice in Business Central?">
                            <span>🛒</span> How to create & post a Sales Invoice
                        </button>
                        <button class="ai-faq-chip" data-question="What is the policy when a customer exceeds their credit limit?">
                            <span>💳</span> Customer Credit Limit Policy
                        </button>
                        <button class="ai-faq-chip" data-question="How do I use the AI Customer Assistant on Customer Card?">
                            <span>🤖</span> How AI Customer Assistant works
                        </button>
                        <button class="ai-faq-chip" data-question="How do I find pages and reports using Tell Me (Alt+Q)?">
                            <span>🔍</span> How to navigate with Tell Me (Alt+Q)
                        </button>
                    </div>
                </div>
            </div>
            <div class="ai-bot-footer">
                <input type="text" id="ai-bot-input" class="ai-bot-input" placeholder="Ask about Business Central..." />
                <button id="ai-bot-send-btn" class="ai-bot-send-btn" title="Send Question">
                    <svg viewBox="0 0 24 24">
                        <path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z"/>
                    </svg>
                </button>
            </div>
        `;
        document.body.appendChild(chatWindow);

        // Event Listeners
        launcher.addEventListener('click', toggleChat);
        document.getElementById('ai-bot-close-btn').addEventListener('click', toggleChat);

        const inputField = document.getElementById('ai-bot-input');
        const sendBtn = document.getElementById('ai-bot-send-btn');

        sendBtn.addEventListener('click', handleUserSend);
        inputField.addEventListener('keydown', function (e) {
            if (e.key === 'Enter') {
                handleUserSend();
            }
        });

        // FAQ Chip Clicks
        chatWindow.addEventListener('click', function (e) {
            const chip = e.target.closest('.ai-faq-chip');
            if (chip && !isWaitingForResponse) {
                const question = chip.getAttribute('data-question');
                if (question) {
                    sendQuestion(question);
                }
            }
        });
    };

    function toggleChat() {
        const chatWindow = document.getElementById('ai-bot-window');
        if (!chatWindow) return;
        chatWindow.classList.toggle('hidden');
        if (!chatWindow.classList.contains('hidden')) {
            const inputField = document.getElementById('ai-bot-input');
            if (inputField) inputField.focus();
        }
    }

    function handleUserSend() {
        const inputField = document.getElementById('ai-bot-input');
        const text = inputField.value.trim();
        if (!text || isWaitingForResponse) return;
        inputField.value = '';
        sendQuestion(text);
    }

    function sendQuestion(questionText) {
        isWaitingForResponse = true;
        appendMessage('user', questionText);
        showTypingIndicator();

        const inputField = document.getElementById('ai-bot-input');
        const sendBtn = document.getElementById('ai-bot-send-btn');
        if (inputField) inputField.disabled = true;
        if (sendBtn) sendBtn.disabled = true;

        if (typeof Microsoft !== 'undefined' && Microsoft.Dynamics && Microsoft.Dynamics.NAV) {
            Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('AskQuestion', [questionText]);
        } else {
            setTimeout(function () {
                window.ReceiveAnswer("Simulated response: In Business Central, press Alt+Q (Tell Me) and type 'Sales Invoices' to navigate to sales documents.");
            }, 1000);
        }
    }

    function appendMessage(sender, text) {
        const messagesContainer = document.getElementById('ai-bot-messages');
        if (!messagesContainer) return;

        const msgDiv = document.createElement('div');
        msgDiv.className = `ai-message ${sender}`;

        const formattedContent = formatMarkdown(text);
        const timeStr = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

        msgDiv.innerHTML = `
            <div class="ai-bubble">${formattedContent}</div>
            <span class="ai-msg-time">${timeStr}</span>
        `;

        messagesContainer.appendChild(msgDiv);
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
    }

    function showTypingIndicator() {
        removeTypingIndicator();
        const messagesContainer = document.getElementById('ai-bot-messages');
        if (!messagesContainer) return;

        const typingDiv = document.createElement('div');
        typingDiv.id = 'ai-typing-indicator';
        typingDiv.className = 'ai-typing-indicator';
        typingDiv.innerHTML = `
            <span class="ai-typing-dot"></span>
            <span class="ai-typing-dot"></span>
            <span class="ai-typing-dot"></span>
        `;
        messagesContainer.appendChild(typingDiv);
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
    }

    function removeTypingIndicator() {
        const indicator = document.getElementById('ai-typing-indicator');
        if (indicator) indicator.remove();
    }

    function formatMarkdown(rawText) {
        if (!rawText) return '';
        let escaped = rawText
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;');

        // Bold
        escaped = escaped.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
        // Backticks code
        escaped = escaped.replace(/`([^`]+)`/g, '<code style="background: rgba(0,0,0,0.06); padding: 1px 4px; border-radius: 4px; font-family: monospace;">$1</code>');
        // Newlines
        escaped = escaped.replace(/\\n|\n/g, '<br/>');
        return escaped;
    }

    window.ReceiveAnswer = function (answerText) {
        isWaitingForResponse = false;
        removeTypingIndicator();
        appendMessage('bot', answerText);

        const inputField = document.getElementById('ai-bot-input');
        const sendBtn = document.getElementById('ai-bot-send-btn');
        if (inputField) {
            inputField.disabled = false;
            inputField.focus();
        }
        if (sendBtn) sendBtn.disabled = false;
    };

    window.ReceiveError = function (errorMsg) {
        isWaitingForResponse = false;
        removeTypingIndicator();
        appendMessage('bot', `⚠️ **Error:** ${errorMsg || 'Could not communicate with AI service. Please verify your AI Setup.'}`);

        const inputField = document.getElementById('ai-bot-input');
        const sendBtn = document.getElementById('ai-bot-send-btn');
        if (inputField) {
            inputField.disabled = false;
            inputField.focus();
        }
        if (sendBtn) sendBtn.disabled = false;
    };
})();
