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
  <style>
    .vmodal-bg{display:none;position:fixed;inset:0;z-index:900;background:rgba(9,18,36,.88);backdrop-filter:blur(4px);align-items:center;justify-content:center;padding:24px;}
    .vmodal-bg.open{display:flex;}
    .vmodal{background:#0e1f3a;border:1px solid rgba(212,168,67,.3);border-radius:4px;width:100%;max-width:600px;max-height:90vh;overflow-y:auto;box-shadow:0 24px 80px rgba(0,0,0,.6);animation:mIn .28s cubic-bezier(.22,1,.36,1);}
    @keyframes mIn{from{opacity:0;transform:translateY(20px);}to{opacity:1;transform:translateY(0);}}
    .vmodal__head{padding:20px 26px 16px;border-bottom:1px solid rgba(212,168,67,.15);display:flex;align-items:flex-start;justify-content:space-between;gap:14px;}
    .vmodal__title{font-family:'Barlow Condensed',sans-serif;font-size:1.3rem;font-weight:900;text-transform:uppercase;color:#eae4d6;letter-spacing:-.01em;line-height:1.1;}
    .vmodal__close{background:none;border:none;cursor:pointer;color:rgba(234,228,214,.4);font-size:1.3rem;padding:2px 8px;border-radius:3px;flex-shrink:0;transition:color .15s,background .15s;}
    .vmodal__close:hover{color:#eae4d6;background:rgba(212,168,67,.12);}
    .vmodal__body{padding:22px 26px;}
    .vmodal__label{font-family:'Syne',sans-serif;font-size:.58rem;font-weight:800;text-transform:uppercase;letter-spacing:.18em;color:rgba(234,228,214,.38);display:block;margin-bottom:4px;}
    .vmodal__val{font-size:.88rem;font-weight:300;color:#eae4d6;line-height:1.6;margin-bottom:14px;}
    .vmodal__msgbody{background:#1a2f55;border-left:3px solid rgba(212,168,67,.25);padding:14px 18px;border-radius:3px;font-size:.88rem;font-weight:300;color:rgba(234,228,214,.72);line-height:1.85;}
    .vmodal__foot{padding:14px 26px;border-top:1px solid rgba(212,168,67,.1);display:flex;gap:10px;justify-content:flex-end;}
  </style>
</head>
<body>
  <jsp:include page="/WEB-INF/views/fragment/navbar.jsp" />

  <div class="dash-page">
    <div class="dash-header">
      <p class="dash-eyebrow">Admin</p>
      <h1 class="dash-title">Contact <em>Messages</em></h1>
      <p class="dash-subtitle">Incoming messages from users and voters.</p>
    </div>

    <c:if test="${param.status == 'sent'}"><div class="vo-alert vo-alert--success">&#10003;&nbsp; Message sent.</div></c:if>
    <c:if test="${param.status == 'marked'}"><div class="vo-alert vo-alert--success">&#10003;&nbsp; Marked as read.</div></c:if>

    <div class="vo-card" style="margin-bottom:24px;">
      <div class="vo-card__body" style="padding:16px 24px;">
        <div style="display:flex;gap:12px;flex-wrap:wrap;align-items:center;">
          <form method="get" action="${pageContext.request.contextPath}/admin/contact" style="display:flex;gap:10px;flex:1;min-width:200px;">
            <input type="text" name="q" class="vo-input" style="flex:1;" placeholder="Search by name, email or subject…" value="${q}">
            <button type="submit" class="vo-btn vo-btn--ghost">Search</button>
            <c:if test="${not empty q}"><a href="${pageContext.request.contextPath}/admin/contact" class="vo-btn vo-btn--ghost">Clear</a></c:if>
          </form>
          <button class="vo-btn vo-btn--gold" id="composeToggle">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M12 5v14M5 12h14"/></svg>
            Message a User
          </button>
        </div>
      </div>
    </div>

    <div class="vo-card" id="composePanel" style="display:none;margin-bottom:24px;">
      <div class="vo-card__head"><span class="vo-card__title">New Message</span></div>
      <div class="vo-card__body">
        <form action="${pageContext.request.contextPath}/admin/contact" method="post">
          <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
          <input type="hidden" name="action" value="compose">
          <div class="field-row-2" style="margin-bottom:16px;">
            <div class="field-group">
              <label class="vo-label">Filter Users</label>
              <input type="text" id="userSearch" class="vo-input" placeholder="Name or email…">
            </div>
            <div class="field-group">
              <label class="vo-label">Select Recipient</label>
              <select name="recipientId" class="vo-select" id="userSelect" required size="4">
                <c:forEach items="${allUsers}" var="u">
                  <option value="${u.id}" data-search="${u.firstName} ${u.lastName} ${u.email}">${u.firstName} ${u.lastName} — ${u.email}</option>
                </c:forEach>
              </select>
            </div>
          </div>
          <div class="field-group"><label class="vo-label">Subject</label><input type="text" name="subject" class="vo-input" required placeholder="Message subject"></div>
          <div class="field-group"><label class="vo-label">Message</label><textarea name="body" class="vo-textarea" rows="5" required placeholder="Write your message…"></textarea></div>
          <div style="display:flex;gap:10px;justify-content:flex-end;">
            <button type="button" class="vo-btn vo-btn--ghost" id="composeCancel">Cancel</button>
            <button type="submit" class="vo-btn vo-btn--gold">Send Message</button>
          </div>
        </form>
      </div>
    </div>

    <div class="vo-card">
      <div class="vo-card__head"><span class="vo-card__title">Incoming Messages</span></div>
      <div class="vo-card__body--flush">
        <c:if test="${empty messages}">
          <div style="padding:48px 24px;text-align:center;"><p style="font-family:'Barlow Condensed',sans-serif;font-size:1.5rem;font-weight:900;text-transform:uppercase;color:rgba(234,228,214,.2);">No messages yet</p></div>
        </c:if>
        <c:forEach items="${messages}" var="m">
          <div class="msg-thread ${!m.adminRead ? 'msg-thread--unread' : ''}">
            <div class="msg-thread__head">
              <div class="msg-thread__meta">
                <div class="msg-thread__badges">
                  <c:if test="${!m.adminRead}"><span class="vo-badge vo-badge--gold">Unread</span></c:if>
                  <span class="vo-badge vo-badge--cream">${m.senderName}</span>
                </div>
                <p class="msg-thread__subject">${m.subject}</p>
                <%-- Truncated preview — click to open modal --%>
                <p class="msg-thread__body" style="overflow:hidden;text-overflow:ellipsis;white-space:nowrap;max-width:500px;">${m.body}</p>
                <span class="msg-thread__time">${m.senderEmail} &middot; ${m.createdAt}</span>
              </div>
              <div class="msg-thread__actions">
                <button type="button" class="vo-btn vo-btn--ghost vo-btn--sm"
                        onclick="openMsgModal('${m.senderName}','${m.senderEmail}','${m.subject}',`${m.body}`)">
                  Read Full
                </button>
                <c:if test="${!m.adminRead}">
                  <form action="${pageContext.request.contextPath}/admin/contact" method="post" style="display:inline;">
                    <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                    <input type="hidden" name="action" value="mark-read">
                    <input type="hidden" name="messageId" value="${m.id}">
                    <button type="submit" class="vo-btn vo-btn--ghost vo-btn--sm">&#10003; Read</button>
                  </form>
                </c:if>
                <button class="vo-btn vo-btn--ghost vo-btn--sm" onclick="toggleReply('areply-${m.id}',this)">Reply</button>
              </div>
            </div>
            <div class="msg-reply-form" id="areply-${m.id}">
              <form action="${pageContext.request.contextPath}/admin/contact" method="post">
                <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                <input type="hidden" name="action" value="reply">
                <input type="hidden" name="parentId" value="${m.id}">
                <input type="hidden" name="recipientId" value="${not empty m.sender ? m.sender.id : ''}">
                <input type="hidden" name="subject" value="Re: ${m.subject}">
                <textarea name="body" class="vo-textarea" placeholder="Your reply…" required></textarea>
                <div style="display:flex;gap:8px;justify-content:flex-end;margin-top:8px;">
                  <button type="button" class="vo-btn vo-btn--ghost vo-btn--sm" onclick="toggleReply('areply-${m.id}',this)">Cancel</button>
                  <button type="submit" class="vo-btn vo-btn--gold vo-btn--sm">Send Reply</button>
                </div>
              </form>
            </div>
          </div>
        </c:forEach>
      </div>
    </div>
  </div>

  <%-- ── MESSAGE DETAIL MODAL ────────────────────────────────────────── --%>
  <div class="vmodal-bg" id="msgModal" onclick="if(event.target===this)closeMsgModal()">
    <div class="vmodal">
      <div class="vmodal__head">
        <div>
          <div class="vmodal__title" id="mmSubject"></div>
          <div style="font-size:.78rem;color:rgba(234,228,214,.4);margin-top:4px;" id="mmMeta"></div>
        </div>
        <button class="vmodal__close" onclick="closeMsgModal()">&#10005;</button>
      </div>
      <div class="vmodal__body">
        <div class="vmodal__msgbody" id="mmBody" style="white-space:pre-wrap;"></div>
      </div>
      <div class="vmodal__foot"><button class="vo-btn vo-btn--ghost" onclick="closeMsgModal()">Close</button></div>
    </div>
  </div>

  <jsp:include page="/WEB-INF/views/fragment/footer.jsp" />

  <script>
  document.getElementById('composeToggle').addEventListener('click', function() {
    var p = document.getElementById('composePanel');
    p.style.display = p.style.display === 'none' ? 'block' : 'none';
  });
  document.getElementById('composeCancel').addEventListener('click', function() {
    document.getElementById('composePanel').style.display = 'none';
  });
  document.getElementById('userSearch').addEventListener('input', function() {
    var q = this.value.toLowerCase();
    document.querySelectorAll('#userSelect option').forEach(function(opt) {
      opt.style.display = opt.dataset.search.toLowerCase().includes(q) ? '' : 'none';
    });
  });
  function toggleReply(id, btn) {
    var el = document.getElementById(id);
    var open = el.classList.toggle('open');
    btn.textContent = open ? 'Cancel' : 'Reply';
  }

  /* ── Message modal ──────────────── */
  function openMsgModal(sender, email, subject, body) {
    document.getElementById('mmSubject').textContent = subject;
    document.getElementById('mmMeta').textContent    = sender + ' <' + email + '>';
    document.getElementById('mmBody').textContent    = body;
    document.getElementById('msgModal').classList.add('open');
    document.body.style.overflow = 'hidden';
  }
  function closeMsgModal() {
    document.getElementById('msgModal').classList.remove('open');
    document.body.style.overflow = '';
  }
  document.addEventListener('keydown', function(e){ if(e.key==='Escape') closeMsgModal(); });
  </script>
</body>
</html>
