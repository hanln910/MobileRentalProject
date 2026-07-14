<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MotoBot - AI Motorbike Consultant | MotoRent</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        body { font-family: 'Inter', sans-serif; background: #f0f2f5; }

        .chat-container {
            max-width: 900px;
            margin: 0 auto;
            height: calc(100vh - 80px);
            display: flex;
            flex-direction: column;
        }

        .chat-header {
            background: linear-gradient(135deg, #1e3a5f 0%, #2563eb 100%);
            color: white;
            padding: 20px 24px;
            border-radius: 16px 16px 0 0;
            display: flex;
            align-items: center;
            gap: 16px;
            box-shadow: 0 4px 20px rgba(37,99,235,0.3);
        }

        .bot-avatar {
            width: 52px;
            height: 52px;
            background: rgba(255,255,255,0.2);
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            backdrop-filter: blur(10px);
        }

        .chat-header-info h4 { margin: 0; font-weight: 700; font-size: 1.15rem; }
        .chat-header-info p { margin: 0; opacity: 0.85; font-size: 0.85rem; }

        .online-dot {
            width: 10px; height: 10px;
            background: #22c55e;
            border-radius: 50%;
            display: inline-block;
            margin-right: 6px;
            animation: pulse-dot 2s infinite;
        }

        @keyframes pulse-dot {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }

        .chat-messages {
            flex: 1;
            overflow-y: auto;
            padding: 24px;
            background: #f8f9fa;
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .chat-messages::-webkit-scrollbar { width: 6px; }
        .chat-messages::-webkit-scrollbar-track { background: transparent; }
        .chat-messages::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 3px; }

        .message { display: flex; gap: 12px; max-width: 85%; animation: fadeInUp 0.3s ease; }
        .message.user { align-self: flex-end; flex-direction: row-reverse; }
        .message.bot { align-self: flex-start; }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .message-avatar {
            width: 36px; height: 36px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 16px;
            flex-shrink: 0;
        }

        .bot .message-avatar { background: linear-gradient(135deg, #2563eb, #1d4ed8); color: white; }
        .user .message-avatar { background: linear-gradient(135deg, #6366f1, #4f46e5); color: white; }

        .message-bubble {
            padding: 12px 16px;
            border-radius: 16px;
            font-size: 0.925rem;
            line-height: 1.6;
            box-shadow: 0 1px 3px rgba(0,0,0,0.08);
            word-wrap: break-word;
        }

        .bot .message-bubble {
            background: white;
            color: #1e293b;
            border-bottom-left-radius: 4px;
        }

        .user .message-bubble {
            background: linear-gradient(135deg, #2563eb, #1d4ed8);
            color: white;
            border-bottom-right-radius: 4px;
        }

        .message-bubble p { margin-bottom: 8px; }
        .message-bubble p:last-child { margin-bottom: 0; }
        .message-bubble strong { font-weight: 600; }
        .message-bubble ul, .message-bubble ol { padding-left: 20px; margin-bottom: 8px; }
        .message-bubble li { margin-bottom: 4px; }
        .message-bubble code {
            background: rgba(0,0,0,0.06);
            padding: 2px 6px;
            border-radius: 4px;
            font-size: 0.85em;
        }

        .message-time {
            font-size: 0.72rem;
            color: #94a3b8;
            margin-top: 4px;
            padding: 0 4px;
        }

        .user .message-time { text-align: right; }

        .typing-indicator {
            display: flex;
            gap: 4px;
            padding: 16px;
            align-items: center;
        }

        .typing-indicator span {
            width: 8px; height: 8px;
            background: #94a3b8;
            border-radius: 50%;
            animation: typing 1.4s infinite;
        }

        .typing-indicator span:nth-child(2) { animation-delay: 0.2s; }
        .typing-indicator span:nth-child(3) { animation-delay: 0.4s; }

        @keyframes typing {
            0%, 60%, 100% { transform: translateY(0); opacity: 0.4; }
            30% { transform: translateY(-8px); opacity: 1; }
        }

        .chat-input-area {
            padding: 16px 24px;
            background: white;
            border-top: 1px solid #e2e8f0;
            border-radius: 0 0 16px 16px;
            box-shadow: 0 -2px 10px rgba(0,0,0,0.05);
        }

        .chat-input-wrapper {
            display: flex;
            gap: 12px;
            align-items: flex-end;
        }

        .chat-input-wrapper textarea {
            flex: 1;
            border: 2px solid #e2e8f0;
            border-radius: 12px;
            padding: 12px 16px;
            font-size: 0.925rem;
            font-family: 'Inter', sans-serif;
            resize: none;
            max-height: 120px;
            transition: border-color 0.2s;
            outline: none;
        }

        .chat-input-wrapper textarea:focus { border-color: #2563eb; }

        .send-btn {
            width: 48px; height: 48px;
            border: none;
            background: linear-gradient(135deg, #2563eb, #1d4ed8);
            color: white;
            border-radius: 12px;
            font-size: 18px;
            cursor: pointer;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .send-btn:hover { transform: scale(1.05); box-shadow: 0 4px 15px rgba(37,99,235,0.4); }
        .send-btn:disabled { opacity: 0.5; cursor: not-allowed; transform: none; box-shadow: none; }

        .quick-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-top: 12px;
        }

        .quick-action-btn {
            padding: 6px 14px;
            border: 1.5px solid #e2e8f0;
            border-radius: 20px;
            background: white;
            color: #475569;
            font-size: 0.8rem;
            font-family: 'Inter', sans-serif;
            cursor: pointer;
            transition: all 0.2s;
        }

        .quick-action-btn:hover {
            border-color: #2563eb;
            color: #2563eb;
            background: #eff6ff;
        }

        .welcome-card {
            background: white;
            border-radius: 16px;
            padding: 24px;
            text-align: center;
            box-shadow: 0 1px 3px rgba(0,0,0,0.08);
        }

        .welcome-card .emoji { font-size: 48px; margin-bottom: 12px; }
        .welcome-card h5 { font-weight: 700; color: #1e293b; }
        .welcome-card p { color: #64748b; font-size: 0.9rem; }

        .suggestion-chips {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            justify-content: center;
            margin-top: 16px;
        }

        .suggestion-chip {
            padding: 8px 16px;
            border: 1.5px solid #e2e8f0;
            border-radius: 20px;
            background: white;
            color: #475569;
            font-size: 0.85rem;
            cursor: pointer;
            transition: all 0.2s;
            font-family: 'Inter', sans-serif;
        }

        .suggestion-chip:hover {
            border-color: #2563eb;
            color: #2563eb;
            background: #eff6ff;
            transform: translateY(-1px);
        }

        .suggestion-chip i { margin-right: 6px; color: #2563eb; }
    </style>
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg sticky-top navbar-dark-custom">
        <div class="container-fluid px-4">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/home">
                <i class="fa-solid fa-motorcycle me-2"></i>MotoRent
            </a>
            <div class="d-flex align-items-center gap-3">
                <a href="${pageContext.request.contextPath}/home" class="nav-link">
                    <i class="fa-solid fa-home me-1"></i> Home
                </a>
                <a href="${pageContext.request.contextPath}/motorbikes" class="nav-link">
                    <i class="fa-solid fa-motorcycle me-1"></i> Browse
                </a>
                <c:choose>
                    <c:when test="${not empty sessionScope.user}">
                        <a href="${pageContext.request.contextPath}/orders?action=dashboard" class="nav-link">
                            <i class="fa-solid fa-gauge me-1"></i> Dashboard
                        </a>
                        <div class="dropdown">
                            <a href="#" class="d-flex align-items-center text-decoration-none dropdown-toggle text-white" data-bs-toggle="dropdown">
                                <img src="https://ui-avatars.com/api/?name=${sessionScope.user.fullName}&background=2563eb&color=fff" width="32" height="32" class="rounded-circle me-2">
                                <span class="fw-semibold">${sessionScope.user.fullName}</span>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end shadow border-0">
                                <li><a class="dropdown-item py-2" href="${pageContext.request.contextPath}/profile"><i class="fa-solid fa-user me-2"></i>Profile</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item py-2 text-danger" href="${pageContext.request.contextPath}/auth?action=logout"><i class="fa-solid fa-arrow-right-from-bracket me-2"></i>Logout</a></li>
                            </ul>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/auth?action=login" class="btn btn-light btn-sm rounded-pill px-3">
                            <i class="fa-solid fa-sign-in-alt me-1"></i> Login
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </nav>

    <!-- Chat Container -->
    <div class="container-fluid py-3 px-3">
        <div class="chat-container">
            <!-- Chat Header -->
            <div class="chat-header">
                <div class="bot-avatar">
                    <i class="fa-solid fa-robot"></i>
                </div>
                <div class="chat-header-info">
                    <h4><i class="fa-solid fa-sparkles me-1"></i> MotoBot AI Consultant</h4>
                    <p><span class="online-dot"></span>Online — Expert motorbike rental advisor</p>
                </div>
                <div class="ms-auto d-flex gap-2">
                    <button class="btn btn-sm btn-outline-light rounded-pill px-3" onclick="clearChat()" title="Clear conversation">
                        <i class="fa-solid fa-trash-can me-1"></i> Clear
                    </button>
                </div>
            </div>

            <!-- Chat Messages -->
            <div class="chat-messages" id="chatMessages">
                <!-- Welcome Card -->
                <div class="welcome-card" id="welcomeCard">
                    <div class="emoji">&#x1F3CD;&#xFE0F;</div>
                    <h5>Welcome to MotoBot!</h5>
                    <p>I'm your AI motorbike rental consultant. I know our entire catalog and can help you find the perfect ride. Ask me anything!</p>
                    <div class="suggestion-chips">
                        <button class="suggestion-chip" onclick="sendSuggestion(this)">
                            <i class="fa-solid fa-fire"></i>Best motorbikes under $50/day?
                        </button>
                        <button class="suggestion-chip" onclick="sendSuggestion(this)">
                            <i class="fa-solid fa-star"></i>Highest rated bikes?
                        </button>
                        <button class="suggestion-chip" onclick="sendSuggestion(this)">
                            <i class="fa-solid fa-road"></i>Best bike for city commute?
                        </button>
                        <button class="suggestion-chip" onclick="sendSuggestion(this)">
                            <i class="fa-solid fa-circle-info"></i>How does renting work?
                        </button>
                        <button class="suggestion-chip" onclick="sendSuggestion(this)">
                            <i class="fa-solid fa-bolt"></i>Sport bikes available?
                        </button>
                        <button class="suggestion-chip" onclick="sendSuggestion(this)">
                            <i class="fa-solid fa-motorcycle"></i>Show me all available bikes
                        </button>
                    </div>
                </div>
            </div>

            <!-- Chat Input -->
            <div class="chat-input-area">
                <div class="chat-input-wrapper">
                    <textarea id="chatInput" rows="1" placeholder="Ask me about motorbikes, rentals, prices..."
                              onkeydown="handleKeyDown(event)" oninput="autoResize(this)"></textarea>
                    <button class="send-btn" id="sendBtn" onclick="sendMessage()" title="Send message">
                        <i class="fa-solid fa-paper-plane"></i>
                    </button>
                </div>
                <div class="quick-actions" id="quickActions">
                    <button class="quick-action-btn" onclick="sendSuggestion(this)">Compare bikes</button>
                    <button class="quick-action-btn" onclick="sendSuggestion(this)">Cheapest options</button>
                    <button class="quick-action-btn" onclick="sendSuggestion(this)">Touring recommendations</button>
                    <button class="quick-action-btn" onclick="sendSuggestion(this)">Rental policy</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
    <script>
        const API_URL = '${pageContext.request.contextPath}/chatbot';
        let conversationHistory = [];
        let isLoading = false;

        function getTimeString() {
            return new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
        }

        function autoResize(textarea) {
            textarea.style.height = 'auto';
            textarea.style.height = Math.min(textarea.scrollHeight, 120) + 'px';
        }

        function handleKeyDown(event) {
            if (event.key === 'Enter' && !event.shiftKey) {
                event.preventDefault();
                sendMessage();
            }
        }

        function sendSuggestion(btn) {
            const text = btn.textContent.trim();
            document.getElementById('chatInput').value = text;
            sendMessage();
        }

        function addMessage(role, content) {
            const chatMessages = document.getElementById('chatMessages');
            const welcomeCard = document.getElementById('welcomeCard');
            if (welcomeCard) welcomeCard.style.display = 'none';

            const messageDiv = document.createElement('div');
            messageDiv.className = 'message ' + role;

            const avatarIcon = role === 'bot' ? 'fa-robot' : 'fa-user';
            const renderedContent = role === 'bot' ? (typeof marked !== 'undefined' ? marked.parse(content) : content.replace(/\n/g, '<br>')) : escapeHtml(content);

            messageDiv.innerHTML =
                '<div class="message-avatar"><i class="fa-solid ' + avatarIcon + '"></i></div>' +
                '<div>' +
                    '<div class="message-bubble">' + renderedContent + '</div>' +
                    '<div class="message-time">' + getTimeString() + '</div>' +
                '</div>';

            chatMessages.appendChild(messageDiv);
            chatMessages.scrollTop = chatMessages.scrollHeight;
        }

        function showTyping() {
            const chatMessages = document.getElementById('chatMessages');
            const typingDiv = document.createElement('div');
            typingDiv.className = 'message bot';
            typingDiv.id = 'typingIndicator';
            typingDiv.innerHTML =
                '<div class="message-avatar"><i class="fa-solid fa-robot"></i></div>' +
                '<div class="message-bubble">' +
                    '<div class="typing-indicator"><span></span><span></span><span></span></div>' +
                '</div>';
            chatMessages.appendChild(typingDiv);
            chatMessages.scrollTop = chatMessages.scrollHeight;
        }

        function hideTyping() {
            const typing = document.getElementById('typingIndicator');
            if (typing) typing.remove();
        }

        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }

        async function sendMessage() {
            if (isLoading) return;

            const input = document.getElementById('chatInput');
            const message = input.value.trim();
            if (!message) return;

            input.value = '';
            input.style.height = 'auto';
            addMessage('user', message);

            conversationHistory.push({ role: 'user', content: message });

            isLoading = true;
            document.getElementById('sendBtn').disabled = true;
            showTyping();

            try {
                const response = await fetch(API_URL, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ messages: conversationHistory })
                });

                const data = await response.json();
                hideTyping();

                if (data.error) {
                    addMessage('bot', 'Sorry, I encountered an error: ' + data.error + '. Please try again.');
                } else if (data.reply) {
                    const reply = data.reply;
                    conversationHistory.push({ role: 'assistant', content: reply });
                    addMessage('bot', reply);
                } else {
                    addMessage('bot', 'Sorry, I did not receive a valid response. Please try again.');
                }
            } catch (error) {
                hideTyping();
                addMessage('bot', 'Connection error. Please check your internet connection and try again.');
                console.error('Chatbot error:', error);
            }

            isLoading = false;
            document.getElementById('sendBtn').disabled = false;
            input.focus();
        }

        function clearChat() {
            conversationHistory = [];
            const chatMessages = document.getElementById('chatMessages');
            chatMessages.innerHTML = '';

            // Restore welcome card
            chatMessages.innerHTML =
                '<div class="welcome-card" id="welcomeCard">' +
                    '<div class="emoji">&#x1F3CD;&#xFE0F;</div>' +
                    '<h5>Welcome to MotoBot!</h5>' +
                    '<p>I\'m your AI motorbike rental consultant. I know our entire catalog and can help you find the perfect ride. Ask me anything!</p>' +
                    '<div class="suggestion-chips">' +
                        '<button class="suggestion-chip" onclick="sendSuggestion(this)"><i class="fa-solid fa-fire"></i>Best motorbikes under $50/day?</button>' +
                        '<button class="suggestion-chip" onclick="sendSuggestion(this)"><i class="fa-solid fa-star"></i>Highest rated bikes?</button>' +
                        '<button class="suggestion-chip" onclick="sendSuggestion(this)"><i class="fa-solid fa-road"></i>Best bike for city commute?</button>' +
                        '<button class="suggestion-chip" onclick="sendSuggestion(this)"><i class="fa-solid fa-circle-info"></i>How does renting work?</button>' +
                        '<button class="suggestion-chip" onclick="sendSuggestion(this)"><i class="fa-solid fa-bolt"></i>Sport bikes available?</button>' +
                        '<button class="suggestion-chip" onclick="sendSuggestion(this)"><i class="fa-solid fa-motorcycle"></i>Show me all available bikes</button>' +
                    '</div>' +
                '</div>';
        }

        // Focus on input when page loads
        document.addEventListener('DOMContentLoaded', function() {
            document.getElementById('chatInput').focus();
        });
    </script>
</body>
</html>
