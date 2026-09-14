(function () {
    let chatInitialized = false;
    let isWaitingForResponse = false;
    let isOpen = false;
    let nudgeTimeout = null;

    const amiraCSS = `
        @import url('https://fonts.googleapis.com/css2?family=Segoe+UI:wght@400;500;600;700&display=swap');

        :root {
            --amira-primary: #00a4e4;
            --amira-primary-dark: #008cc3;
            --amira-primary-gradient: linear-gradient(135deg, #00a4e4 0%, #0077b5 100%);
            --amira-bg: #ffffff;
            --amira-surface: #f8fafc;
            --amira-border: #e2e8f0;
            --amira-text-main: #1e293b;
            --amira-text-muted: #64748b;
            --amira-user-bubble: #00a4e4;
            --amira-bot-bubble: #f8fafc;
            --amira-shadow: 0 20px 48px rgba(0, 0, 0, 0.16), 0 8px 24px rgba(0, 164, 228, 0.18);
        }

        .hidden,
        #ai-bot-window.hidden,
        .amira-nudge-toast.hidden {
            display: none !important;
            opacity: 0 !important;
            visibility: hidden !important;
            pointer-events: none !important;
        }

        /* Floating Launcher Button */
        #ai-bot-launcher {
            position: fixed !important;
            bottom: 24px !important;
            right: 24px !important;
            width: 62px !important;
            height: 62px !important;
            border-radius: 50% !important;
            background: #00a4e4 !important;
            box-shadow: 0 12px 32px rgba(0, 164, 228, 0.35), 0 4px 12px rgba(0, 0, 0, 0.12) !important;
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
            cursor: pointer !important;
            z-index: 2147483647 !important;
            transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1) !important;
            border: 3px solid #ffffff !important;
            box-sizing: border-box !important;
        }

        #ai-bot-launcher:hover {
            transform: translateY(-4px) scale(1.06) !important;
            box-shadow: 0 18px 40px rgba(0, 164, 228, 0.45) !important;
        }

        #ai-bot-launcher svg {
            width: 28px !important;
            height: 28px !important;
            fill: #ffffff !important;
            transition: transform 0.3s ease !important;
        }

        #ai-bot-launcher .launcher-badge {
            position: absolute !important;
            top: -2px !important;
            right: -2px !important;
            width: 15px !important;
            height: 15px !important;
            background: #107c41 !important;
            border: 2.5px solid #ffffff !important;
            border-radius: 50% !important;
            box-shadow: 0 0 8px rgba(16, 124, 65, 0.6) !important;
        }

        /* Amira Floating Nudge Toast */
        .amira-nudge-toast {
            position: fixed !important;
            bottom: 96px !important;
            right: 24px !important;
            background: #ffffff !important;
            border: 1.5px solid #bae6fd !important;
            border-radius: 16px !important;
            padding: 12px 16px !important;
            box-shadow: 0 16px 36px rgba(0, 164, 228, 0.22), 0 4px 12px rgba(0, 0, 0, 0.08) !important;
            display: flex !important;
            align-items: center !important;
            gap: 12px !important;
            max-width: 330px !important;
            z-index: 2147483646 !important;
            cursor: pointer !important;
            animation: amiraNudgeSlideIn 0.5s cubic-bezier(0.16, 1, 0.3, 1), amiraNudgeFloat 3s ease-in-out infinite alternate 0.5s !important;
            transition: all 0.25s ease !important;
            font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, Roboto, sans-serif !important;
            box-sizing: border-box !important;
        }

        .amira-nudge-toast:hover {
            transform: translateY(-3px) scale(1.02) !important;
            border-color: #00a4e4 !important;
            box-shadow: 0 18px 40px rgba(0, 164, 228, 0.32) !important;
        }

        .amira-nudge-avatar {
            width: 38px !important;
            height: 38px !important;
            border-radius: 50% !important;
            background: linear-gradient(135deg, #008cc3, #00a4e4) !important;
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
            font-size: 20px !important;
            flex-shrink: 0 !important;
            box-shadow: 0 4px 10px rgba(0, 164, 228, 0.3) !important;
        }

        .amira-nudge-text {
            flex: 1 !important;
        }

        .amira-nudge-text strong {
            display: block !important;
            font-size: 13px !important;
            color: #0f172a !important;
            margin-bottom: 2px !important;
            font-weight: 700 !important;
        }

        .amira-nudge-text p {
            margin: 0 !important;
            font-size: 11.5px !important;
            color: #475569 !important;
            line-height: 1.35 !important;
        }

        .amira-nudge-close {
            background: transparent !important;
            border: none !important;
            color: #94a3b8 !important;
            font-size: 14px !important;
            cursor: pointer !important;
            padding: 4px !important;
            border-radius: 6px !important;
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
            transition: all 0.2s !important;
        }

        .amira-nudge-close:hover {
            color: #0f172a !important;
            background: #f1f5f9 !important;
        }

        /* Large Floating Chat Window */
        #ai-bot-window {
            position: fixed !important;
            bottom: 96px !important;
            right: 24px !important;
            width: 440px !important;
            height: 680px !important;
            max-width: calc(100vw - 36px) !important;
            max-height: calc(100vh - 116px) !important;
            background: #ffffff !important;
            border: 1px solid #e2e8f0 !important;
            border-radius: 20px !important;
            box-shadow: 0 24px 60px rgba(0, 0, 0, 0.18), 0 8px 24px rgba(0, 164, 228, 0.2) !important;
            display: none !important;
            flex-direction: column !important;
            z-index: 2147483646 !important;
            overflow: hidden !important;
            font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, Roboto, sans-serif !important;
            transform-origin: bottom right !important;
            box-sizing: border-box !important;
        }

        /* Top Header Bar */
        .amira-header {
            background: #00a4e4 !important;
            color: #ffffff !important;
            padding: 16px 20px !important;
            display: flex !important;
            align-items: center !important;
            justify-content: space-between !important;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08) !important;
            flex-shrink: 0 !important;
        }

        .amira-header-left {
            display: flex !important;
            align-items: center !important;
            gap: 12px !important;
        }

        .amira-header-avatar {
            width: 38px !important;
            height: 38px !important;
            border-radius: 50% !important;
            background: rgba(255, 255, 255, 0.25) !important;
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
            font-size: 20px !important;
            border: 1.5px solid rgba(255, 255, 255, 0.5) !important;
        }

        .amira-header-title {
            font-size: 19px !important;
            font-weight: 700 !important;
            letter-spacing: -0.3px !important;
            color: #ffffff !important;
        }

        .amira-header-actions {
            display: flex !important;
            align-items: center !important;
            gap: 8px !important;
        }

        .amira-icon-btn {
            background: transparent !important;
            border: none !important;
            color: #ffffff !important;
            cursor: pointer !important;
            padding: 6px !important;
            border-radius: 8px !important;
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
            transition: background 0.2s, transform 0.15s !important;
        }

        .amira-icon-btn:hover {
            background: rgba(255, 255, 255, 0.2) !important;
            transform: scale(1.08) !important;
        }

        .amira-icon-btn svg {
            width: 20px !important;
            height: 20px !important;
            fill: #ffffff !important;
        }

        /* Messages / Chat Space */
        .amira-messages-area {
            flex: 1 !important;
            padding: 24px 20px !important;
            overflow-y: auto !important;
            display: flex !important;
            flex-direction: column !important;
            gap: 16px !important;
            background: #ffffff !important;
            box-sizing: border-box !important;
        }

        /* Center Hero Section */
        .amira-hero-card {
            display: flex !important;
            flex-direction: column !important;
            align-items: center !important;
            text-align: center !important;
            margin: 10px 0 16px 0 !important;
            animation: amiraFadeIn 0.4s ease !important;
        }

        .amira-hero-badge {
            width: 88px !important;
            height: 88px !important;
            border-radius: 50% !important;
            background: linear-gradient(135deg, #008cc3 0%, #00a4e4 100%) !important;
            box-shadow: 0 10px 24px rgba(0, 164, 228, 0.28) !important;
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
            font-size: 42px !important;
            color: #ffffff !important;
            margin-bottom: 12px !important;
            border: 3px solid #ffffff !important;
            outline: 2px solid #e0f2fe !important;
        }

        .amira-hero-title {
            font-size: 22px !important;
            font-weight: 700 !important;
            color: #0f172a !important;
            margin: 0 0 4px 0 !important;
            letter-spacing: -0.4px !important;
        }

        .amira-hero-subtitle {
            font-size: 13.5px !important;
            color: #475569 !important;
            margin: 0 0 16px 0 !important;
            line-height: 1.45 !important;
            max-width: 320px !important;
        }

        /* FAQ Suggestion Pills */
        .amira-faq-pills {
            display: flex !important;
            flex-direction: column !important;
            gap: 8px !important;
            width: 100% !important;
            margin-top: 4px !important;
        }

        .amira-faq-pill {
            background: #f0f9ff !important;
            border: 1px solid #bae6fd !important;
            color: #0284c7 !important;
            padding: 11px 16px !important;
            border-radius: 12px !important;
            font-size: 13px !important;
            font-weight: 600 !important;
            text-align: left !important;
            cursor: pointer !important;
            transition: all 0.2s ease !important;
            display: flex !important;
            align-items: center !important;
            gap: 10px !important;
            font-family: inherit !important;
            box-sizing: border-box !important;
        }

        .amira-faq-pill:hover {
            background: #e0f2fe !important;
            border-color: #00a4e4 !important;
            color: #0369a1 !important;
            transform: translateX(4px) !important;
            box-shadow: 0 4px 12px rgba(0, 164, 228, 0.12) !important;
        }

        .amira-faq-pill span {
            font-size: 17px !important;
        }

        /* Message Bubbles */
        .amira-msg {
            display: flex !important;
            flex-direction: column !important;
            max-width: 86% !important;
            animation: amiraFadeIn 0.25s ease forwards !important;
        }

        .amira-msg.user {
            align-self: flex-end !important;
        }

        .amira-msg.bot {
            align-self: flex-start !important;
        }

        .amira-bubble {
            padding: 12px 18px !important;
            border-radius: 16px !important;
            font-size: 13.5px !important;
            line-height: 1.55 !important;
            word-break: break-word !important;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.04) !important;
        }

        .amira-msg.user .amira-bubble {
            background: #00a4e4 !important;
            color: #ffffff !important;
            border-radius: 18px 18px 4px 18px !important;
            font-weight: 500 !important;
        }

        .amira-msg.bot .amira-bubble {
            background: #f8fafc !important;
            color: #1e293b !important;
            border: 1px solid #e2e8f0 !important;
            border-radius: 18px 18px 18px 4px !important;
        }

        .amira-bubble p {
            margin: 0 0 8px 0 !important;
        }

        .amira-bubble p:last-child {
            margin-bottom: 0 !important;
        }

        .amira-bubble ol, .amira-bubble ul {
            margin: 6px 0 8px 20px !important;
            padding: 0 !important;
        }

        .amira-bubble li {
            margin-bottom: 6px !important;
        }

        .amira-msg-time {
            font-size: 11px !important;
            color: #94a3b8 !important;
            margin-top: 4px !important;
            padding: 0 4px !important;
        }

        .amira-msg.user .amira-msg-time {
            text-align: right !important;
        }

        /* Typing Indicator */
        .amira-typing-box {
            display: flex !important;
            align-items: center !important;
            gap: 5px !important;
            padding: 12px 18px !important;
            background: #f8fafc !important;
            border-radius: 16px 16px 16px 4px !important;
            border: 1px solid #e2e8f0 !important;
            width: fit-content !important;
        }

        .amira-typing-dot {
            width: 7px !important;
            height: 7px !important;
            background: #00a4e4 !important;
            border-radius: 50% !important;
            animation: amiraPulse 1.2s infinite ease-in-out !important;
        }

        .amira-typing-dot:nth-child(2) {
            animation-delay: 0.2s !important;
        }

        .amira-typing-dot:nth-child(3) {
            animation-delay: 0.4s !important;
        }

        /* Footer / Input Area */
        .amira-footer {
            padding: 14px 18px !important;
            background: #ffffff !important;
            border-top: 1px solid #f1f5f9 !important;
            display: flex !important;
            flex-direction: column !important;
            gap: 10px !important;
            flex-shrink: 0 !important;
            box-sizing: border-box !important;
        }

        .amira-input-row {
            display: flex !important;
            align-items: center !important;
            gap: 10px !important;
        }

        .amira-input {
            flex: 1 !important;
            border: 1.5px solid #cbd5e1 !important;
            border-radius: 24px !important;
            padding: 11px 18px !important;
            font-size: 13.5px !important;
            outline: none !important;
            font-family: inherit !important;
            transition: all 0.2s ease !important;
            background: #f8fafc !important;
            box-sizing: border-box !important;
        }

        .amira-input:focus {
            border-color: #00a4e4 !important;
            background: #ffffff !important;
            box-shadow: 0 0 0 3px rgba(0, 164, 228, 0.18) !important;
        }

        .amira-send-btn {
            width: 42px !important;
            height: 42px !important;
            border-radius: 50% !important;
            background: #00a4e4 !important;
            border: none !important;
            color: #ffffff !important;
            cursor: pointer !important;
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
            transition: background 0.2s, transform 0.15s !important;
            box-shadow: 0 4px 10px rgba(0, 164, 228, 0.3) !important;
            flex-shrink: 0 !important;
        }

        .amira-send-btn:hover {
            background: #008cc3 !important;
            transform: scale(1.06) !important;
        }

        .amira-send-btn:disabled {
            background: #cbd5e1 !important;
            cursor: not-allowed !important;
            transform: none !important;
            box-shadow: none !important;
        }

        .amira-send-btn svg {
            width: 18px !important;
            height: 18px !important;
            fill: #ffffff !important;
        }

        /* Custom Scrollbar */
        .amira-messages-area::-webkit-scrollbar {
            width: 6px !important;
        }

        .amira-messages-area::-webkit-scrollbar-track {
            background: transparent !important;
        }

        .amira-messages-area::-webkit-scrollbar-thumb {
            background: #cbd5e1 !important;
            border-radius: 10px !important;
        }

        .amira-messages-area::-webkit-scrollbar-thumb:hover {
            background: #94a3b8 !important;
        }

        /* Keyframes */
        @keyframes amiraFadeIn {
            from { opacity: 0; transform: translateY(8px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes amiraPulse {
            0%, 100% { transform: scale(0.8); opacity: 0.5; }
            50% { transform: scale(1.25); opacity: 1; }
        }

        @keyframes amiraNudgeSlideIn {
            from {
                opacity: 0;
                transform: translateY(25px) scale(0.9);
            }
            to {
                opacity: 1;
                transform: translateY(0) scale(1);
            }
        }

        @keyframes amiraNudgeFloat {
            0% { transform: translateY(0); }
            100% { transform: translateY(-4px); }
        }
    `;

    function getTargetDocument() {
        try {
            if (window.parent && window.parent.document && window.parent.document.body) {
                return window.parent.document;
            }
        } catch (e) {
            // Cross-origin fallback
        }
        return document;
    }

    function injectStyles(targetDoc) {
        if (targetDoc.getElementById('amira-injected-styles')) return;
        const styleEl = targetDoc.createElement('style');
        styleEl.id = 'amira-injected-styles';
        styleEl.textContent = amiraCSS;
        (targetDoc.head || targetDoc.body).appendChild(styleEl);
    }

    function collapseHostPartContainer(targetDoc) {
        try {
            if (window.frameElement) {
                const frame = window.frameElement;
                frame.style.setProperty('position', 'absolute', 'important');
                frame.style.setProperty('width', '0px', 'important');
                frame.style.setProperty('height', '0px', 'important');
                frame.style.setProperty('opacity', '0', 'important');
                frame.style.setProperty('pointer-events', 'none', 'important');

                let parent = frame.parentElement;
                let steps = 0;
                while (parent && parent !== targetDoc.body && steps < 10) {
                    const classListStr = (parent.className || '').toString();
                    const tagName = (parent.tagName || '').toLowerCase();
                    if (
                        classListStr.includes('part') || 
                        classListStr.includes('card') || 
                        classListStr.includes('widget') || 
                        classListStr.includes('layout-grid-item') ||
                        classListStr.includes('ms-nav-band') ||
                        parent.getAttribute('data-is-part') === 'true' ||
                        tagName === 'section'
                    ) {
                        parent.style.setProperty('display', 'none', 'important');
                        break;
                    }
                    steps++;
                    parent = parent.parentElement;
                }
            }
        } catch (e) {
            // Ignore cross-origin issues
        }
    }

    window.initAIChatBot = function () {
        const targetDoc = getTargetDocument();
        collapseHostPartContainer(targetDoc);
        if (chatInitialized || targetDoc.getElementById('ai-bot-launcher')) return;
        chatInitialized = true;
        injectStyles(targetDoc);
        injectStyles(document);

        // Create Launcher Button
        const launcher = targetDoc.createElement('div');
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
        targetDoc.body.appendChild(launcher);

        // Create Nudge Toast
        const nudgeToast = targetDoc.createElement('div');
        nudgeToast.id = 'amira-nudge-toast';
        nudgeToast.className = 'amira-nudge-toast hidden';
        nudgeToast.innerHTML = `
            <div class="amira-nudge-avatar">👋</div>
            <div class="amira-nudge-text">
                <strong>Hi, I'm Amira!</strong>
                <p>Your ERP Assistant — click here if you need any help navigating Business Central.</p>
            </div>
            <button id="amira-nudge-close-btn" class="amira-nudge-close" title="Dismiss">✕</button>
        `;
        targetDoc.body.appendChild(nudgeToast);

        // Create Chat Window
        const chatWindow = targetDoc.createElement('div');
        chatWindow.id = 'ai-bot-window';
        chatWindow.className = 'hidden';
        chatWindow.style.setProperty('display', 'none', 'important');
        chatWindow.innerHTML = `
            <div class="amira-header">
                <div class="amira-header-left">
                    <div class="amira-header-avatar">🤖</div>
                    <div class="amira-header-title">Amira</div>
                </div>
                <div class="amira-header-actions">
                    <button id="amira-sound-btn" class="amira-icon-btn" title="Voice Audio">
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
        targetDoc.body.appendChild(chatWindow);

        // Show Nudge Toast after 2.5 seconds
        nudgeTimeout = setTimeout(function () {
            if (!isOpen && nudgeToast) {
                nudgeToast.classList.remove('hidden');
                nudgeToast.style.setProperty('display', 'flex', 'important');
            }
        }, 2500);

        // Event Listeners
        launcher.addEventListener('click', function (e) {
            e.stopPropagation();
            toggleChat();
        });

        targetDoc.getElementById('amira-close-btn').addEventListener('click', function (e) {
            e.stopPropagation();
            closeChat();
        });

        targetDoc.getElementById('amira-reset-btn').addEventListener('click', function (e) {
            e.stopPropagation();
            resetChat();
        });

        // Nudge click opens chat
        nudgeToast.addEventListener('click', function (e) {
            if (e.target.id === 'amira-nudge-close-btn') {
                e.stopPropagation();
                dismissNudge();
                return;
            }
            dismissNudge();
            openChat();
        });

        const inputField = targetDoc.getElementById('amira-input');
        const sendBtn = targetDoc.getElementById('amira-send-btn');

        sendBtn.addEventListener('click', handleUserSend);
        inputField.addEventListener('keydown', function (e) {
            if (e.key === 'Enter') {
                handleUserSend();
            }
        });

        // Close on Escape key
        targetDoc.addEventListener('keydown', function (e) {
            if (e.key === 'Escape' && isOpen) {
                closeChat();
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

    function dismissNudge() {
        const targetDoc = getTargetDocument();
        const nudgeToast = targetDoc.getElementById('amira-nudge-toast');
        if (nudgeToast) {
            nudgeToast.classList.add('hidden');
            nudgeToast.style.setProperty('display', 'none', 'important');
        }
        if (nudgeTimeout) {
            clearTimeout(nudgeTimeout);
            nudgeTimeout = null;
        }
    }

    function openChat() {
        const targetDoc = getTargetDocument();
        const chatWindow = targetDoc.getElementById('ai-bot-window');
        const launcher = targetDoc.getElementById('ai-bot-launcher');
        const iconChat = targetDoc.getElementById('launcher-icon-chat');
        const iconClose = targetDoc.getElementById('launcher-icon-close');
        if (!chatWindow) return;

        isOpen = true;
        chatWindow.classList.remove('hidden');
        chatWindow.style.setProperty('display', 'flex', 'important');
        chatWindow.style.setProperty('opacity', '1', 'important');
        chatWindow.style.setProperty('pointer-events', 'auto', 'important');

        dismissNudge();
        if (launcher) launcher.title = 'Close chat agent';
        if (iconChat) iconChat.style.display = 'none';
        if (iconClose) iconClose.style.display = 'block';

        const inputField = targetDoc.getElementById('amira-input');
        if (inputField) inputField.focus();
    }

    function closeChat() {
        const targetDoc = getTargetDocument();
        const chatWindow = targetDoc.getElementById('ai-bot-window');
        const launcher = targetDoc.getElementById('ai-bot-launcher');
        const iconChat = targetDoc.getElementById('launcher-icon-chat');
        const iconClose = targetDoc.getElementById('launcher-icon-close');
        if (!chatWindow) return;

        isOpen = false;
        chatWindow.classList.add('hidden');
        chatWindow.style.setProperty('display', 'none', 'important');
        chatWindow.style.setProperty('opacity', '0', 'important');
        chatWindow.style.setProperty('pointer-events', 'none', 'important');

        if (launcher) launcher.title = 'Ask Amira - ERP Assistant';
        if (iconChat) iconChat.style.display = 'block';
        if (iconClose) iconClose.style.display = 'none';
    }

    function toggleChat() {
        if (isOpen) {
            closeChat();
        } else {
            openChat();
        }
    }

    function resetChat() {
        const targetDoc = getTargetDocument();
        const messagesArea = targetDoc.getElementById('amira-messages-area');
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
        const inputField = targetDoc.getElementById('amira-input');
        if (inputField) {
            inputField.disabled = false;
            inputField.value = '';
            inputField.focus();
        }
        const sendBtn = targetDoc.getElementById('amira-send-btn');
        if (sendBtn) sendBtn.disabled = false;
        isWaitingForResponse = false;
    }

    function handleUserSend() {
        const targetDoc = getTargetDocument();
        const inputField = targetDoc.getElementById('amira-input');
        const text = inputField.value.trim();
        if (!text || isWaitingForResponse) return;
        inputField.value = '';
        sendQuestion(text);
    }

    let responseTimeoutTimer = null;

    function sendQuestion(questionText) {
        if (responseTimeoutTimer) clearTimeout(responseTimeoutTimer);
        isWaitingForResponse = true;
        appendMessage('user', questionText);
        showTypingIndicator();

        const targetDoc = getTargetDocument();
        const inputField = targetDoc.getElementById('amira-input');
        const sendBtn = targetDoc.getElementById('amira-send-btn');
        if (inputField) inputField.disabled = true;
        if (sendBtn) sendBtn.disabled = true;

        // Safety timeout in case the backend HTTP request takes too long
        responseTimeoutTimer = setTimeout(function () {
            if (isWaitingForResponse) {
                const lower = questionText.toLowerCase();
                if (lower.includes('alt+q') || lower.includes('tell me') || lower.includes('search') || lower.includes('navigate')) {
                    window.ReceiveAnswer("**How to Navigate with Tell Me (Alt+Q):**\n1. Press **Alt+Q** (or click the search magnifying glass at the top right).\n2. Type the name of the page, report, or feature (e.g., *Customers*, *Sales Invoices*, or *AI Setup*).\n3. Press **Enter** or click from the matching results to jump directly there.");
                } else if (lower.includes('sales invoice') || lower.includes('invoice') || lower.includes('sales')) {
                    window.ReceiveAnswer("**How to Create & Post a Sales Invoice:**\n1. Press **Alt+Q** and search for **Sales Invoices**, then choose **+ New**.\n2. In the **Customer Name** field, select your customer.\n3. Under **Lines**, set Type = *Item*, select the Item No., and specify Quantity.\n4. Review prices, totals, and posting dates.\n5. Click **Posting -> Post (F9)** to record and finalize.");
                } else if (lower.includes('credit limit') || lower.includes('credit') || lower.includes('block')) {
                    window.ReceiveAnswer("**Customer Credit Limit & Policy:**\n1. Open any **Customer Card** via **Alt+Q -> Customers**.\n2. Expand the **Payments** / **General** FastTab to view or adjust the **Credit Limit (LCY)**.\n3. If an order exceeds this limit, Business Central triggers a credit limit warning.\n4. You can set **Blocked** to *Ship*, *Invoice*, or *All* to freeze transactions.");
                } else if (lower.includes('assistant') || lower.includes('health') || lower.includes('email')) {
                    window.ReceiveAnswer("**How the AI Customer Assistant Works:**\n1. Open any **Customer Card** or **Customer List**.\n2. Click the promoted **AI Insights** action.\n3. The assistant evaluates total balance, sales velocity, payment terms, and churn risk.\n4. Click **Draft Email with AI** to generate a personalized outreach email.");
                } else {
                    window.ReceiveError("Server response timed out. Please check your **AI Setup** (Alt+Q -> AI Setup) and ensure **Allow HttpClient Requests** is enabled under **Extension Management**.");
                }
            }
        }, 8000);

        if (typeof Microsoft !== 'undefined' && Microsoft.Dynamics && Microsoft.Dynamics.NAV) {
            Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('AskQuestion', [questionText]);
        } else {
            setTimeout(function () {
                window.ReceiveAnswer("Hi! I'm Amira. In Business Central, press Alt+Q (Tell Me) and type 'Sales Invoices' to navigate to sales documents.");
            }, 1000);
        }
    }

    function appendMessage(sender, text) {
        const targetDoc = getTargetDocument();
        const messagesArea = targetDoc.getElementById('amira-messages-area');
        if (!messagesArea) return;

        const msgDiv = targetDoc.createElement('div');
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
        const targetDoc = getTargetDocument();
        const messagesArea = targetDoc.getElementById('amira-messages-area');
        if (!messagesArea) return;

        const typingDiv = targetDoc.createElement('div');
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
        const targetDoc = getTargetDocument();
        const indicator = targetDoc.getElementById('amira-typing-box');
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
        if (responseTimeoutTimer) {
            clearTimeout(responseTimeoutTimer);
            responseTimeoutTimer = null;
        }
        isWaitingForResponse = false;
        removeTypingIndicator();
        appendMessage('bot', answerText);

        const targetDoc = getTargetDocument();
        const inputField = targetDoc.getElementById('amira-input');
        const sendBtn = targetDoc.getElementById('amira-send-btn');
        if (inputField) {
            inputField.disabled = false;
            inputField.focus();
        }
        if (sendBtn) sendBtn.disabled = false;
    };

    window.ReceiveError = function (errorMsg) {
        if (responseTimeoutTimer) {
            clearTimeout(responseTimeoutTimer);
            responseTimeoutTimer = null;
        }
        isWaitingForResponse = false;
        removeTypingIndicator();
        appendMessage('bot', `⚠️ **Amira says:** ${errorMsg || 'Could not communicate with AI service. Please check your AI Setup.'}`);

        const targetDoc = getTargetDocument();
        const inputField = targetDoc.getElementById('amira-input');
        const sendBtn = targetDoc.getElementById('amira-send-btn');
        if (inputField) {
            inputField.disabled = false;
            inputField.focus();
        }
        if (sendBtn) sendBtn.disabled = false;
    };
})();
