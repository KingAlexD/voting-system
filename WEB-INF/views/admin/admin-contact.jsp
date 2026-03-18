<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Admin — Messages | VoCho</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:ital,wght@0,700;0,800;0,900;1,700;1,900&family=Syne:wght@700;800&family=Epilogue:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
</head>
<body>
  <jsp:include page="/WEB-INF/views/fragment/navbar.jsp" />

  <div class="dash-page">

    <div class="dash-header">
      <p class="dash-eyebrow">Admin</p>
      <h1 class="dash-title">Contact <em>Messages</em></h1>
      <p class="dash-subtitle">Incoming messages from users and voters.</p>
    </div>

    <c:if test="${param.status == 'sent'}"><div class="vo-alert vo-alert--success">&#10003; &nbsp;Message sent.</div></c:if>
    <c:if test="${param.status == 'marked'}"><div class="vo-alert vo-alert--success">&#10003; &nbsp;Marked as read.</div></c:if>

    <%-- Search + Compose --%>
    <div class="vo-card" style="margin-bottom:24px;">
      <div class="vo-card__body" style="padding:16px 24px;">
        <div style="display:flex;gap:12px;flex-wrap:wrap;align-items:center;">
          <form method="get" action="${pageContext.request.contextPath}/admin/contact"
                style="display:flex;gap:10px;flex:1;min-width:200px;">
            <input type="text" name="q" class="vo-input" style="flex:1;"
                   placeholder="Search by name, email or subject..." value="${q}">
            <button type="submit" class="vo-btn vo-btn--ghost">Search</button>
            <c:if test="${not empty q}">
              <a href="${pageContext.request.contextPath}/admin/contact" class="vo-btn vo-btn--ghost">Clear</a>
            </c:if>
          </form>
          <button class="vo-btn vo-btn--gold" id="composeToggle">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M12 5v14M5 12h14"/></svg>
            Message a User
          </button>
        </div>
      </div>
    </div>

    <%-- Compose panel (hidden by default) --%>
    <div class="vo-card" id="composePanel" style="display:none;margin-bottom:24px;">
      <div class="vo-card__head"><span class="vo-card__title">New Message</span></div>
      <div class="vo-card__body">
        <form action="${pageContext.request.contextPath}/admin/contact" method="post">
          <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
          <input type="hidden" name="action" value="compose">
          <div class="field-row-2" style="margin-bottom:16px;">
            <div class="field-group">
              <label class="vo-label">Search User</label>
              <input type="text" id="userSearch" class="vo-input" placeholder="Filter by name or email...">
            </div>
            <div class="field-group">
              <label class="vo-label">Select Recipient</label>
              <select name="recipientId" class="vo-select" id="userSelect" required size="4">
                <c:forEach items="${allUsers}" var="u">
                  <option value="${u.id}" data-search="${u.firstName} ${u.lastName} ${u.email}">
                    ${u.firstName} ${u.lastName} — ${u.email}
                  </option>
                </c:forEach>
              </select>
            </div>
          </div>
          <div class="field-group">
            <label class="vo-label">Subject</label>
            <input type="text" name="subject" class="vo-input" required placeholder="Message subject">
          </div>
          <div class="field-group">
            <label class="vo-label">Message</label>
            <textarea name="body" class="vo-textarea" rows="5" required placeholder="Write your message..."></textarea>
          </div>
          <div style="display:flex;gap:10px;justify-content:flex-end;">
            <button type="button" class="vo-btn vo-btn--ghost" id="composeCancel">Cancel</button>
            <button type="submit" class="vo-btn vo-btn--gold">Send Message</button>
          </div>
        </form>
      </div>
    </div>

    <%-- Inbox --%>
    <div class="vo-card">
      <div class="vo-card__head">
        <span class="vo-card__title">Incoming Messages</span>
      </div>
      <div class="vo-card__body--flush">
        <c:if test="${empty messages}">
          <div style="padding:48px 24px;text-align:center;">
            <p style="font-family:'Barlow Condensed',sans-serif;font-size:1.5rem;font-weight:900;text-transform:uppercase;color:rgba(234,228,214,.25);">No messages yet</p>
          </div>
        </c:if>

        <c:forEach items="${messages}" var="m">
          <div class="msg-thread ${!m.adminRead ? 'msg-thread--unread' : ''}">
            <div class="msg-thread__head">
              <div class="msg-thread__meta">
                <div class="msg-thread__badges">
                  <c:if test="${!m.adminRead}">
                    <span class="vo-badge vo-badge--gold">Unread</span>
                  </c:if>
                  <span class="vo-badge vo-badge--cream">${m.senderName}</span>
                </div>
                <p class="msg-thread__subject">${m.subject}</p>
                <p class="msg-thread__body">${m.body}</p>
                <span class="msg-thread__time">${m.senderEmail} &middot; ${m.createdAt}</span>
              </div>
              <div class="msg-thread__actions">
                <c:if test="${!m.adminRead}">
                  <form action="${pageContext.request.contextPath}/admin/contact" method="post">
                    <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                    <input type="hidden" name="action" value="mark-read">
                    <input type="hidden" name="messageId" value="${m.id}">
                    <button type="submit" class="vo-btn vo-btn--ghost vo-btn--sm">&#10003; Read</button>
                  </form>
                </c:if>
                <button class="vo-btn vo-btn--ghost vo-btn--sm"
                        onclick="toggleAdminReply('areply-${m.id}', this)">Reply</button>
              </div>
            </div>

            <div class="msg-reply-form" id="areply-${m.id}">
              <form action="${pageContext.request.contextPath}/admin/contact" method="post">
                <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                <input type="hidden" name="action" value="reply">
                <input type="hidden" name="parentId" value="${m.id}">
                <input type="hidden" name="recipientId" value="${not empty m.sender ? m.sender.id : ''}">
                <input type="hidden" name="subject" value="Re: ${m.subject}">
                <textarea name="body" class="vo-textarea" placeholder="Your reply..." required></textarea>
                <div style="display:flex;gap:8px;justify-content:flex-end;">
                  <button type="button" class="vo-btn vo-btn--ghost vo-btn--sm"
                          onclick="toggleAdminReply('areply-${m.id}', this)">Cancel</button>
                  <button type="submit" class="vo-btn vo-btn--gold vo-btn--sm">Send Reply</button>
                </div>
              </form>
            </div>
          </div>
        </c:forEach>

      </div>
    </div>
  </div>

  <jsp:include page="/WEB-INF/views/fragment/footer.jsp" />

  <script>
  // Compose panel toggle
  document.getElementById('composeToggle').addEventListener('click', function() {
    var panel = document.getElementById('composePanel');
    panel.style.display = panel.style.display === 'none' ? 'block' : 'none';
  });
  document.getElementById('composeCancel').addEventListener('click', function() {
    document.getElementById('composePanel').style.display = 'none';
  });

  // User search filter
  document.getElementById('userSearch').addEventListener('input', function() {
    var q = this.value.toLowerCase();
    document.querySelectorAll('#userSelect option').forEach(function(opt) {
      opt.style.display = opt.dataset.search.toLowerCase().includes(q) ? '' : 'none';
    });
  });

  // Reply toggle
  function toggleAdminReply(id, btn) {
    var el = document.getElementById(id);
    var open = el.classList.toggle('open');
    btn.textContent = open ? 'Cancel' : 'Reply';
  }
  </script>

</body>
</html>
