<%-- Floating Chatbot Widget - Include this in any page to show the chat bubble --%>
<style>
    .chatbot-fab {
        position: fixed;
        bottom: 24px;
        right: 24px;
        z-index: 9999;
        display: flex;
        flex-direction: column;
        align-items: flex-end;
        gap: 12px;
    }

    .chatbot-fab-tooltip {
        background: white;
        color: #1e293b;
        padding: 10px 16px;
        border-radius: 12px;
        box-shadow: 0 4px 20px rgba(0,0,0,0.15);
        font-size: 0.85rem;
        font-weight: 500;
        font-family: 'Inter', sans-serif;
        white-space: nowrap;
        animation: tooltipBounce 0.5s ease;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .chatbot-fab-tooltip .close-tip {
        cursor: pointer;
        color: #94a3b8;
        font-size: 14px;
        padding: 2px;
    }

    .chatbot-fab-tooltip .close-tip:hover { color: #475569; }

    @keyframes tooltipBounce {
        0% { opacity: 0; transform: translateY(10px); }
        100% { opacity: 1; transform: translateY(0); }
    }

    .chatbot-fab-btn {
        width: 60px;
        height: 60px;
        border-radius: 50%;
        background: linear-gradient(135deg, #2563eb, #1d4ed8);
        color: white;
        border: none;
        font-size: 24px;
        cursor: pointer;
        box-shadow: 0 4px 20px rgba(37,99,235,0.4);
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.3s;
        position: relative;
    }

    .chatbot-fab-btn:hover {
        transform: scale(1.1);
        box-shadow: 0 6px 28px rgba(37,99,235,0.5);
    }

    .chatbot-fab-btn .pulse-ring {
        position: absolute;
        width: 100%;
        height: 100%;
        border-radius: 50%;
        border: 3px solid #2563eb;
        animation: fabPulse 2s infinite;
    }

    @keyframes fabPulse {
        0% { transform: scale(1); opacity: 0.6; }
        100% { transform: scale(1.5); opacity: 0; }
    }

    /* Mini chat window */
    .chatbot-mini-window {
        position: fixed;
        bottom: 96px;
        right: 24px;
        width: 380px;
        height: 520px;
        background: white;
        border-radius: 16px;
        box-shadow: 0 10px 40px rgba(0,0,0,0.2);
        z-index: 9998;
        display: none;
        flex-direction: column;
        overflow: hidden;
        animation: slideUp 0.3s ease;
    }

    .chatbot-mini-window.open { display: flex; }

    @keyframes slideUp {
        from { opacity: 0; transform: translateY(20px); }
        to { opacity: 1; transform: translateY(0); }
    }

    .mini-chat-header {
        background: linear-gradient(135deg, #1e3a5f, #2563eb);
        color: white;
        padding: 14px 16px;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .mini-chat-header .mini-bot-avatar {
        width: 38px; height: 38px;
        background: rgba(255,255,255,0.2);
        border-radius: 10px;
        display: flex; align-items: center; justify-content: center;
        font-size: 18px;
    }

    .mini-chat-header .header-text h6 { margin: 0; font-weight: 700; font-size: 0.95rem; }
    .mini-chat-header .header-text small { opacity: 0.85; font-size: 0.75rem; }

    .mini-chat-header .mini-actions { margin-left: auto; display: flex; gap: 6px; }
    .mini-chat-header .mini-actions button {
        background: rgba(255,255,255,0.2);
        border: none;
        color: white;
        width: 30px; height: 30px;
        border-radius: 8px;
        cursor: pointer;
        font-size: 13px;
        display: flex; align-items: center; justify-content: center;
        transition: background 0.2s;
    }
    .mini-chat-header .mini-actions button:hover { background: rgba(255,255,255,0.3); }

    .mini-chat-messages {
        flex: 1;
        overflow-y: auto;
        padding: 16px;
        display: flex;
        flex-direction: column;
        gap: 12px;
        background: #f8f9fa;
    }

    .mini-chat-messages::-webkit-scrollbar { width: 4px; }
    .mini-chat-messages::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 2px; }

    .mini-msg { display: flex; gap: 8px; max-width: 88%; animation: fadeIn 0.3s ease; }
    .mini-msg.user-msg { align-self: flex-end; flex-direction: row-reverse; }
    .mini-msg.bot-msg { align-self: flex-start; }

    @keyframes fadeIn { from { opacity: 0; transform: translateY(6px); } to { opacity: 1; transform: translateY(0); } }

    .mini-msg-avatar {
        width: 28px; height: 28px; border-radius: 8px;
        display: flex; align-items: center; justify-content: center;
        font-size: 12px; flex-shrink: 0;
    }
    .bot-msg .mini-msg-avatar { background: linear-gradient(135deg, #2563eb, #1d4ed8); color: white; }
    .user-msg .mini-msg-avatar { background: linear-gradient(135deg, #6366f1, #4f46e5); color: white; }

    .mini-msg-bubble {
        padding: 10px 14px;
        border-radius: 14px;
        font-size: 0.85rem;
        line-height: 1.55;
        word-wrap: break-word;
    }
    .mini-msg-bubble p { margin-bottom: 6px; }
    .mini-msg-bubble p:last-child { margin-bottom: 0; }
    .mini-msg-bubble ul, .mini-msg-bubble ol { padding-left: 18px; margin-bottom: 6px; }
    .mini-msg-bubble li { margin-bottom: 2px; }

    .bot-msg .mini-msg-bubble { background: white; color: #1e293b; border-bottom-left-radius: 4px; box-shadow: 0 1px 2px rgba(0,0,0,0.06); }
    .user-msg .mini-msg-bubble { background: linear-gradient(135deg, #2563eb, #1d4ed8); color: white; border-bottom-right-radius: 4px; }

    .mini-typing { display: flex; gap: 4px; padding: 10px 14px; }
    .mini-typing span { width: 6px; height: 6px; background: #94a3b8; border-radius: 50%; animation: miniType 1.4s infinite; }
    .mini-typing span:nth-child(2) { animation-delay: 0.2s; }
    .mini-typing span:nth-child(3) { animation-delay: 0.4s; }
    @keyframes miniType { 0%,60%,100%{transform:translateY(0);opacity:0.4;} 30%{transform:translateY(-6px);opacity:1;} }

    .mini-chat-input {
        padding: 12px;
        border-top: 1px solid #e2e8f0;
        display: flex;
        gap: 8px;
        background: white;
    }

    .mini-chat-input input {
        flex: 1;
        border: 1.5px solid #e2e8f0;
        border-radius: 10px;
        padding: 10px 14px;
        font-size: 0.85rem;
        font-family: 'Inter', sans-serif;
        outline: none;
        transition: border-color 0.2s;
    }
    .mini-chat-input input:focus { border-color: #2563eb; }

    .mini-chat-input button {
        width: 40px; height: 40px;
        border: none;
        background: linear-gradient(135deg, #2563eb, #1d4ed8);
        color: white;
        border-radius: 10px;
        font-size: 15px;
        cursor: pointer;
        transition: all 0.2s;
        display: flex; align-items: center; justify-content: center;
    }
    .mini-chat-input button:hover { transform: scale(1.05); }
    .mini-chat-input button:disabled { opacity: 0.5; cursor: not-allowed; transform: none; }

    .mini-welcome {
        text-align: center;
        padding: 16px;
    }
    .mini-welcome .mini-emoji { font-size: 36px; margin-bottom: 8px; }
    .mini-welcome h6 { font-weight: 700; color: #1e293b; margin-bottom: 4px; }
    .mini-welcome p { color: #64748b; font-size: 0.8rem; margin-bottom: 12px; }

    .mini-suggestions { display: flex; flex-wrap: wrap; gap: 6px; justify-content: center; }
    .mini-suggest-btn {
        padding: 6px 12px;
        border: 1.5px solid #e2e8f0;
        border-radius: 16px;
        background: white;
        color: #475569;
        font-size: 0.75rem;
        cursor: pointer;
        font-family: 'Inter', sans-serif;
        transition: all 0.2s;
    }
    .mini-suggest-btn:hover { border-color: #2563eb; color: #2563eb; background: #eff6ff; }

    @media (max-width: 480px) {
        .chatbot-mini-window { width: calc(100vw - 20px); right: 10px; bottom: 86px; height: 70vh; }
    }
</style>

<!-- Floating Chat Button -->
<div class="chatbot-fab" id="chatbotFab">
    <div class="chatbot-fab-tooltip" id="chatTip">
        <i class="fa-solid fa-sparkles" style="color: #2563eb;"></i>
        Need help choosing a bike? Ask AI!
        <span class="close-tip" onclick="document.getElementById('chatTip').style.display='none'"><i class="fa-solid fa-xmark"></i></span>
    </div>
    <button class="chatbot-fab-btn" onclick="toggleMiniChat()" title="Chat with MotoBot AI">
        <span class="pulse-ring"></span>
        <i class="fa-solid fa-robot" id="fabIcon"></i>
    </button>
</div>

<!-- Mini Chat Window -->
<div class="chatbot-mini-window" id="miniChatWindow">
    <div class="mini-chat-header">
        <div class="mini-bot-avatar"><i class="fa-solid fa-robot"></i></div>
        <div class="header-text">
            <h6>MotoBot AI</h6>
            <small><span style="width:7px;height:7px;background:#22c55e;border-radius:50%;display:inline-block;margin-right:4px;"></span>Online</small>
        </div>
        <div class="mini-actions">
            <button onclick="window.open('${pageContext.request.contextPath}/chatbot', '_blank')" title="Open full chat"><i class="fa-solid fa-expand"></i></button>
            <button onclick="clearMiniChat()" title="Clear chat"><i class="fa-solid fa-trash-can"></i></button>
            <button onclick="toggleMiniChat()" title="Close"><i class="fa-solid fa-xmark"></i></button>
        </div>
    </div>
    <div class="mini-chat-messages" id="miniMessages">
        <div class="mini-welcome" id="miniWelcome">
            <div class="mini-emoji">&#x1F3CD;&#xFE0F;</div>
            <h6>Hi! I'm MotoBot</h6>
            <p>Your AI motorbike consultant. How can I help?</p>
            <div class="mini-suggestions">
                <button class="mini-suggest-btn" onclick="sendMiniSuggestion(this)">Best bikes under $50/day</button>
                <button class="mini-suggest-btn" onclick="sendMiniSuggestion(this)">How does renting work?</button>
                <button class="mini-suggest-btn" onclick="sendMiniSuggestion(this)">Sport bikes available</button>
                <button class="mini-suggest-btn" onclick="sendMiniSuggestion(this)">Highest rated bikes</button>
            </div>
        </div>
    </div>
    <div class="mini-chat-input">
        <input type="text" id="miniChatInput" placeholder="Ask about motorbikes..." onkeydown="if(event.key==='Enter')sendMiniMessage()">
        <button id="miniSendBtn" onclick="sendMiniMessage()"><i class="fa-solid fa-paper-plane"></i></button>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
<script>
(function() {
    const MINI_API_URL = '${pageContext.request.contextPath}/chatbot';
    let miniHistory = [];
    let miniLoading = false;
    let miniOpen = false;

    window.toggleMiniChat = function() {
        const win = document.getElementById('miniChatWindow');
        const tip = document.getElementById('chatTip');
        miniOpen = !miniOpen;
        if (miniOpen) {
            win.classList.add('open');
            if (tip) tip.style.display = 'none';
            document.getElementById('miniChatInput').focus();
            const fabIcon = document.getElementById('fabIcon');
            fabIcon.className = 'fa-solid fa-xmark';
        } else {
            win.classList.remove('open');
            const fabIcon = document.getElementById('fabIcon');
            fabIcon.className = 'fa-solid fa-robot';
        }
    };

    window.sendMiniSuggestion = function(btn) {
        document.getElementById('miniChatInput').value = btn.textContent.trim();
        sendMiniMessage();
    };

    function addMiniMsg(role, content) {
        const container = document.getElementById('miniMessages');
        const welcome = document.getElementById('miniWelcome');
        if (welcome) welcome.style.display = 'none';

        const div = document.createElement('div');
        div.className = 'mini-msg ' + (role === 'user' ? 'user-msg' : 'bot-msg');
        const icon = role === 'user' ? 'fa-user' : 'fa-robot';
        const rendered = role === 'bot' ? (typeof marked !== 'undefined' ? marked.parse(content) : content.replace(/\n/g, '<br>')) : escapeHtmlMini(content);

        div.innerHTML =
            '<div class="mini-msg-avatar"><i class="fa-solid ' + icon + '"></i></div>' +
            '<div class="mini-msg-bubble">' + rendered + '</div>';
        container.appendChild(div);
        container.scrollTop = container.scrollHeight;
    }

    function showMiniTyping() {
        const container = document.getElementById('miniMessages');
        const div = document.createElement('div');
        div.className = 'mini-msg bot-msg';
        div.id = 'miniTyping';
        div.innerHTML =
            '<div class="mini-msg-avatar"><i class="fa-solid fa-robot"></i></div>' +
            '<div class="mini-msg-bubble"><div class="mini-typing"><span></span><span></span><span></span></div></div>';
        container.appendChild(div);
        container.scrollTop = container.scrollHeight;
    }

    function hideMiniTyping() {
        const el = document.getElementById('miniTyping');
        if (el) el.remove();
    }

    function escapeHtmlMini(t) {
        const d = document.createElement('div');
        d.textContent = t;
        return d.innerHTML;
    }

    window.sendMiniMessage = async function() {
        if (miniLoading) return;
        const input = document.getElementById('miniChatInput');
        const msg = input.value.trim();
        if (!msg) return;

        input.value = '';
        addMiniMsg('user', msg);
        miniHistory.push({ role: 'user', content: msg });

        miniLoading = true;
        document.getElementById('miniSendBtn').disabled = true;
        showMiniTyping();

        try {
            const resp = await fetch(MINI_API_URL, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ messages: miniHistory })
            });
            const data = await resp.json();
            hideMiniTyping();

            if (data.reply) {
                miniHistory.push({ role: 'assistant', content: data.reply });
                addMiniMsg('bot', data.reply);
            } else if (data.error) {
                addMiniMsg('bot', 'Sorry, an error occurred. Please try again.');
            } else {
                addMiniMsg('bot', 'Sorry, I could not process that. Please try again.');
            }
        } catch (e) {
            hideMiniTyping();
            addMiniMsg('bot', 'Connection error. Please try again.');
        }

        miniLoading = false;
        document.getElementById('miniSendBtn').disabled = false;
        input.focus();
    };

    window.clearMiniChat = function() {
        miniHistory = [];
        const container = document.getElementById('miniMessages');
        container.innerHTML =
            '<div class="mini-welcome" id="miniWelcome">' +
                '<div class="mini-emoji">&#x1F3CD;&#xFE0F;</div>' +
                '<h6>Hi! I\'m MotoBot</h6>' +
                '<p>Your AI motorbike consultant. How can I help?</p>' +
                '<div class="mini-suggestions">' +
                    '<button class="mini-suggest-btn" onclick="sendMiniSuggestion(this)">Best bikes under $50/day</button>' +
                    '<button class="mini-suggest-btn" onclick="sendMiniSuggestion(this)">How does renting work?</button>' +
                    '<button class="mini-suggest-btn" onclick="sendMiniSuggestion(this)">Sport bikes available</button>' +
                    '<button class="mini-suggest-btn" onclick="sendMiniSuggestion(this)">Highest rated bikes</button>' +
                '</div>' +
            '</div>';
    };

    // Auto-hide tooltip after 8 seconds
    setTimeout(function() {
        const tip = document.getElementById('chatTip');
        if (tip) tip.style.display = 'none';
    }, 8000);
})();
</script>
