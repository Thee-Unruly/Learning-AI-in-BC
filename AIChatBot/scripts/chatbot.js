(function () {
    let chatInitialized = false;
    let isWaitingForResponse = false;
    let isOpen = false;

    window.initAIChatBot = function () {
        if (chatInitialized || document.getElementById('ai-bot-launcher')) return;
        chatInitialized = true;

        // Create Launcher Button
        const launcher = document.createElement('div');
        launcher.id = 'ai-bot-launcher';
        launcher.title = 'Ask Amira - ERP Assistant';
        launcher.innerHTML = `
            <svg id="launcher-icon-chat" viewBox="0 0 24 24">
                <path d="M12 2C6.477 2 2 6.477 2 12c0 1.821.487 3.53 1.338 5L2.1 21.9a1 1 0 0 0 1.258 1.258L8 21.862A9.957 9.957 0 0 0 12 22c5.523 0 10-4.477 10-10S17.523 2 12 2zm1 14h-2v-2h2v2zm0-4h-2V7h2v5z"/>
            </svg>
            <svg id="launcher-icon-close" style="display: none;" viewBox="0 0 24 24">
                <path d="M7.41 8.59L12 13.17l4.59-4.58L18 10l-6 6-6-6 1.41-1.41z"/>
            </svg>
            <span class="launcher-badge"></span>
        `;
        document.body.appendChild(launcher);

        // Create Chat Window
        const chatWindow = document.createElement('div');
        chatWindow.id = 'ai-bot-window';
        chatWindow.className = 'hidden';
        chatWindow.innerHTML = `
            <div class="amira-header">
                <div class="amira-header-left">
                    <div class="amira-header-avatar">🤖</div>
                    <div class="amira-header-title">Amira</div>
                </div>
                <div class="amira-header-actions">
                    <button id="amira-sound-btn" class="amira-icon-btn" title="Toggle Voice / Audio">
                        <svg viewBox="0 0 24 24">
                            <path d="M3 9v6h4l5 5V4L7 9H3zm13.5 3c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02zM14 3.23v2.06c2.89.86 5 3.54 5 6.71s-2.11 5.85-5 6.71v2.06c4.01-.91 7-4.49 7-8.77s-2.99-7.86-7-8.77z"/>
                        </svg>
                    </button>
                    <button id="amira-reset-btn" class="amira-icon-btn" title="Start New Conversation">
                        <svg viewBox="0 0 24 24">
                            <path d="M17.65 6.35A7.958 7.958 0 0 0 12 4c-4.42 0-7.99 3.58-7.99 8s3.57 8 7.99 8c3.73 0 6.84-2.55 7.73-6h-2.08A5.99 5.99 0 0 1 12 18c-3.31 0-6-2.69-6-6s2.69-6 6-6c1.66 0 3.14.69 4.22 1.78L13 11h7V4l-2.35 2.35z"/>
                        </svg>
                    </button>
                    <button id="amira-close-btn" class="amira-icon-btn" title="Close chat agent">
                        <svg viewBox="0 0 24 24">
                            <path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/>
                        </svg>
                    </button>
                </div>
            </div>
            <div id="amira-messages-area" class="amira-messages-area">
                <div id="amira-hero" class="amira-hero-card">
                    <div class="amira-hero-badge">🤖</div>
                    <h2 class="amira-hero-title">Amira</h2>
                    <p class="amira-hero-subtitle">Hi, I'm Amira, your Business Central ERP Agent!</p>
                    <div class="amira-faq-pills">
                        <button class="amira-faq-pill" data-question="How do I create and post a Sales Invoice in Business Central?">
                            <span>🛒</span> How to create & post a Sales Invoice
                        </button>
                        <button class="amira-faq-pill" data-question="What is the policy when a customer exceeds their credit limit?">
                            <span>💳</span> Customer Credit Limit Policy
                        </button>
                        <button class="amira-faq-pill" data-question="How do I use the AI Customer Assistant on Customer Card?">
                            <span>🤖</span> How AI Customer Assistant works
                        </button>
                        <button class="amira-faq-pill" data-question="How do I find pages and reports using Tell Me (Alt+Q)?">
                            <span>🔍</span> How to navigate with Tell Me (Alt+Q)
                        </button>
                    </div>
                </div>
            </div>
            <div class="amira-footer">
                <div class="amira-input-row">
                    <input type="text" id="amira-input" class="amira-input" placeholder="Ask Amira about Business Central..." />
                    <button id="amira-send-btn" class="amira-send-btn" title="Send to Amira">
                        <svg viewBox="0 0 24 24">
                            <path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z"/>
                        </svg>
                    </button>
                </div>
            </div>
        `;
        document.body.appendChild(chatWindow);

        // Event Listeners
        launcher.addEventListener('click', toggleChat);
        document.getElementById('amira-close-btn').addEventListener('click', toggleChat);
        document.getElementById('amira-reset-btn').addEventListener('click', resetChat);

        const inputField = document.getElementById('amira-input');
        const sendBtn = document.getElementById('amira-send-btn');

        sendBtn.addEventListener('click', handleUserSend);
        inputField.addEventListener('keydown', function (e) {
            if (e.key === 'Enter') {
                handleUserSend();
            }
        });

        // FAQ Chip Clicks
        chatWindow.addEventListener('click', function (e) {
            const pill = e.target.closest('.amira-faq-pill');
            if (pill && !isWaitingForResponse) {
                const question = pill.getAttribute('data-question');
                if (question) {
                    sendQuestion(question);
                }
            }
        });
    };

    function toggleChat() {
        const chatWindow = document.getElementById('ai-bot-window');
        const launcher = document.getElementById('ai-bot-launcher');
        const iconChat = document.getElementById('launcher-icon-chat');
        const iconClose = document.getElementById('launcher-icon-close');
        if (!chatWindow) return;

        isOpen = !isOpen;
        chatWindow.classList.toggle('hidden', !isOpen);

        if (isOpen) {
            launcher.title = 'Close chat agent';
            if (iconChat) iconChat.style.display = 'none';
            if (iconClose) iconClose.style.display = 'block';
            const inputField = document.getElementById('amira-input');
            if (inputField) inputField.focus();
        } else {
            launcher.title = 'Ask Amira - ERP Assistant';
            if (iconChat) iconChat.style.display = 'block';
            if (iconClose) iconClose.style.display = 'none';
        }
    }

    function resetChat() {
        const messagesArea = document.getElementById('amira-messages-area');
        if (!messagesArea) return;
        messagesArea.innerHTML = `
            <div id="amira-hero" class="amira-hero-card">
                <div class="amira-hero-badge">🤖</div>
                <h2 class="amira-hero-title">Amira</h2>
                <p class="amira-hero-subtitle">Hi, I'm Amira, your Business Central ERP Agent!</p>
                <div class="amira-faq-pills">
                    <button class="amira-faq-pill" data-question="How do I create and post a Sales Invoice in Business Central?">
                        <span>🛒</span> How to create & post a Sales Invoice
                    </button>
                    <button class="amira-faq-pill" data-question="What is the policy when a customer exceeds their credit limit?">
                        <span>💳</span> Customer Credit Limit Policy
                    </button>
                    <button class="amira-faq-pill" data-question="How do I use the AI Customer Assistant on Customer Card?">
                        <span>🤖</span> How AI Customer Assistant works
                    </button>
                    <button class="amira-faq-pill" data-question="How do I find pages and reports using Tell Me (Alt+Q)?">
                        <span>🔍</span> How to navigate with Tell Me (Alt+Q)
                    </button>
                </div>
            </div>
        `;
        const inputField = document.getElementById('amira-input');
        if (inputField) {
            inputField.disabled = false;
            inputField.value = '';
            inputField.focus();
        }
        const sendBtn = document.getElementById('amira-send-btn');
        if (sendBtn) sendBtn.disabled = false;
        isWaitingForResponse = false;
    }

    function handleUserSend() {
        const inputField = document.getElementById('amira-input');
        const text = inputField.value.trim();
        if (!text || isWaitingForResponse) return;
        inputField.value = '';
        sendQuestion(text);
    }

    function sendQuestion(questionText) {
        isWaitingForResponse = true;

        // Hide the hero card after first interaction if desired, or keep it as top context
        appendMessage('user', questionText);
        showTypingIndicator();

        const inputField = document.getElementById('amira-input');
        const sendBtn = document.getElementById('amira-send-btn');
        if (inputField) inputField.disabled = true;
        if (sendBtn) sendBtn.disabled = true;

        if (typeof Microsoft !== 'undefined' && Microsoft.Dynamics && Microsoft.Dynamics.NAV) {
            Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('AskQuestion', [questionText]);
        } else {
            setTimeout(function () {
                window.ReceiveAnswer("Hi! I'm Amira. In Business Central, press Alt+Q (Tell Me) and type 'Sales Invoices' to navigate to sales documents.");
            }, 1000);
        }
    }

    function appendMessage(sender, text) {
        const messagesArea = document.getElementById('amira-messages-area');
        if (!messagesArea) return;

        const msgDiv = document.createElement('div');
        msgDiv.className = `amira-msg ${sender}`;

        const formattedContent = formatMarkdown(text);
        const timeStr = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

        msgDiv.innerHTML = `
            <div class="amira-bubble">${formattedContent}</div>
            <span class="amira-msg-time">${timeStr}</span>
        `;

        messagesArea.appendChild(msgDiv);
        messagesArea.scrollTop = messagesArea.scrollHeight;
    }

    function showTypingIndicator() {
        removeTypingIndicator();
        const messagesArea = document.getElementById('amira-messages-area');
        if (!messagesArea) return;

        const typingDiv = document.createElement('div');
        typingDiv.id = 'amira-typing-box';
        typingDiv.className = 'amira-typing-box';
        typingDiv.innerHTML = `
            <span class="amira-typing-dot"></span>
            <span class="amira-typing-dot"></span>
            <span class="amira-typing-dot"></span>
        `;
        messagesArea.appendChild(typingDiv);
        messagesArea.scrollTop = messagesArea.scrollHeight;
    }

    function removeTypingIndicator() {
        const indicator = document.getElementById('amira-typing-box');
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
        escaped = escaped.replace(/`([^`]+)`/g, '<code style="background: rgba(0,0,0,0.06); padding: 2px 5px; border-radius: 4px; font-family: monospace;">$1</code>');
        // Newlines
        escaped = escaped.replace(/\\n|\n/g, '<br/>');
        return escaped;
    }

    window.ReceiveAnswer = function (answerText) {
        isWaitingForResponse = false;
        removeTypingIndicator();
        appendMessage('bot', answerText);

        const inputField = document.getElementById('amira-input');
        const sendBtn = document.getElementById('amira-send-btn');
        if (inputField) {
            inputField.disabled = false;
            inputField.focus();
        }
        if (sendBtn) sendBtn.disabled = false;
    };

    window.ReceiveError = function (errorMsg) {
        isWaitingForResponse = false;
        removeTypingIndicator();
        appendMessage('bot', `⚠️ **Amira says:** ${errorMsg || 'Could not communicate with AI service. Please check your AI Setup.'}`);

        const inputField = document.getElementById('amira-input');
        const sendBtn = document.getElementById('amira-send-btn');
        if (inputField) {
            inputField.disabled = false;
            inputField.focus();
        }
        if (sendBtn) sendBtn.disabled = false;
    };
})();
