<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Messages | VoCho</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:ital,wght@0,700;0,800;0,900;1,700;1,900&family=Syne:wght@700;800&family=Epilogue:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
  <style>
    .vmodal-bg{display:none;position:fixed;inset:0;z-index:900;background:rgba(9,18,36,.88);backdrop-filter:blur(4px);align-items:center;justify-content:center;padding:24px;}
    .vmodal-bg.open{display:flex;}
    .vmodal{background:#0e1f3a;border:1px solid rgba(212,168,67,.3);border-radius:4px;width:100%;max-width:580px;max-height:90vh;overflow-y:auto;box-shadow:0 24px 80px rgba(0,0,0,.6);animation:mIn .28s cubic-bezier(.22,1,.36,1);}
    @keyframes mIn{from{opacity:0;transform:translateY(20px);}to{opacity:1;transform:translateY(0);}}
    .vmodal__head{padding:20px 26px 16px;border-bottom:1px solid rgba(212,168,67,.15);display:flex;align-items:flex-start;justify-content:space-between;gap:14px;}
    .vmodal__title{font-family:'Barlow Condensed',sans-serif;font-size:1.3rem;font-weight:900;text-transform:uppercase;color:#eae4d6;letter-spacing:-.01em;line-height:1.1;}
    .vmodal__close{background:none;border:none;cursor:pointer;color:rgba(234,228,214,.4);font-size:1.3rem;padding:2px 8px;border-radius:3px;flex-shrink:0;transition:color .15s,background .15s;}
    .vmodal__close:hover{color:#eae4d6;background:rgba(212,168,67,.12);}
    .vmodal__body{padding:22px 26px;}
    .vmodal__msgbody{background:#1a2f55;border-left:3px solid rgba(212,168,67,.25);padding:14px 18px;border-radius:3px;font-size:.88rem;font-weight:300;color:rgba(234,228,214,.72);line-height:1.85;white-space:pre-wrap;}
    .vmodal__foot{padding:14px 26px;border-top:1px solid rgba(212,168,67,.1);display:flex;gap:10px;justify-content:flex-end;}
    .vmodal__meta{font-size:.75rem;color:rgba(234,228,214,.38);margin-top:4px;}
    .msg-from-admin{border-left-color:#d4a843;}
  </style>
</head>
<body>
  <jsp:include page="/WEB-INF/views/fragment/navbar.jsp" />

  <div class="dash-page">
    <div class="dash-header">
      <p class="dash-eyebrow">
        <c:choose>
          <c:when test="${not empty currentUser}">My Messages</c:when>
          <c:otherwise>Contact</c:otherwise>
        </c:choose>
      </p>
      <h1 class="dash-title">
        <c:choose>
          <c:when test="${not empty currentUser}">Inbox &amp; <em>Send</em></c:when>
          <c:otherwise>Get in <em>Touch</em></c:otherwise>
        </c:choose>
      </h1>
      <p class="dash-subtitle">
        <c:choose>
          <c:when test="${not empty currentUser}">Messages between you and the VoCho admin team.</c:when>
          <c:otherwise>Send us a message and we'll get back to you.</c:otherwise>
        </c:choose>
      </p>
    </div>

    <c:if test="${not empty sessionScope.success}">
      <div class="vo-alert vo-alert--success">${sessionScope.success}</div>
      <c:remove var="success" scope="session"/>
    </c:if>
    <c:if test="${not empty param.error}">
      <div class="vo-alert vo-alert--error">
        <c:choose>
          <c:when test="${param.error == 'missing_fields'}">All fields are required.</c:when>
          <c:otherwise>Something went wrong. Try again.</c:otherwise>
        </c:choose>
      </div>
    </c:if>

    <%-- ── Compose new message ─────────────────────────────── --%>
    <div class="vo-card" style="margin-bottom:24px;">
      <div class="vo-card__head"><span class="vo-card__title">New Message</span></div>
      <div class="vo-card__body">
        <form action="${pageContext.request.contextPath}/contact" method="POST">
          <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">

          <c:if test="${empty currentUser}">
            <div class="field-row-2" style="margin-bottom:14px;display:grid;grid-template-columns:1fr 1fr;gap:12px;">
              <div class="field-group">
                <label class="vo-label">Your Name</label>
                <input type="text" name="senderName" class="vo-input" required placeholder="Full name">
              </div>
              <div class="field-group">
                <label class="vo-label">Your Email</label>
                <input type="email" name="senderEmail" class="vo-input" required placeholder="you@example.com">
              </div>
            </div>
          </c:if>

          <c:if test="${not empty currentUser}">
            <input type="hidden" name="senderName"  value="${currentUser.firstName} ${currentUser.lastName}">
            <input type="hidden" name="senderEmail" value="${currentUser.email}">
          </c:if>

          <div class="field-group"><label class="vo-label">Subject</label><input type="text" name="subject" class="vo-input" required placeholder="What's this about?"></div>
          <div class="field-group"><label class="vo-label">Message</label><textarea name="message" class="vo-textarea" rows="5" required placeholder="Write your message to the admin team…"></textarea></div>
          <button type="submit" class="vo-btn vo-btn--gold">Send Message</button>
        </form>
      </div>
    </div>

    <%-- ── Inbox (logged-in users only) ───────────────────── --%>
    <c:if test="${not empty currentUser and not empty myMessages}">
      <div class="vo-card">
        <div class="vo-card__head"><span class="vo-card__title">Message History</span></div>
        <div class="vo-card__body--flush">
          <c:forEach items="${myMessages}" var="m">
            <div class="msg-thread ${m.fromAdmin ? '' : (!m.adminRead ? 'msg-thread--unread' : '')}">
              <div class="msg-thread__head">
                <div class="msg-thread__meta">
                  <div class="msg-thread__badges">
                    <c:if test="${m.fromAdmin}"><span class="vo-badge vo-badge--gold">From Admin</span></c:if>
                    <c:if test="${!m.fromAdmin and !m.adminRead}"><span class="vo-badge vo-badge--pending">Pending</span></c:if>
                    <c:if test="${!m.fromAdmin and m.adminRead}"><span class="vo-badge vo-badge--green">Seen</span></c:if>
                  </div>
                  <p class="msg-thread__subject">${m.subject}</p>
                  <p class="msg-thread__body" style="overflow:hidden;text-overflow:ellipsis;white-space:nowrap;max-width:480px;">${m.body}</p>
                  <span class="msg-thread__time">${m.createdAt}</span>
                </div>
                <div class="msg-thread__actions">
                  <button type="button" class="vo-btn vo-btn--ghost vo-btn--sm"
                          onclick="openMsgModal('${m.subject}','${m.fromAdmin ? 'Admin' : currentUser.firstName}','${m.createdAt}',`${m.body}`,${m.fromAdmin})">
                    Read Full
                  </button>
                </div>
              </div>
            </div>
          </c:forEach>
        </div>
      </div>
    </c:if>

  </div>

  <%-- ── MESSAGE DETAIL MODAL ────────────────────────────── --%>
  <div class="vmodal-bg" id="msgModal" onclick="if(event.target===this)closeMsgModal()">
    <div class="vmodal">
      <div class="vmodal__head">
        <div>
          <div class="vmodal__title" id="mmSubject"></div>
          <div class="vmodal__meta" id="mmMeta"></div>
        </div>
        <button class="vmodal__close" onclick="closeMsgModal()">&#10005;</button>
      </div>
      <div class="vmodal__body">
        <div class="vmodal__msgbody" id="mmBody"></div>
      </div>
      <div class="vmodal__foot"><button class="vo-btn vo-btn--ghost" onclick="closeMsgModal()">Close</button></div>
    </div>
  </div>

  <jsp:include page="/WEB-INF/views/fragment/footer.jsp" />

  <script>
  function openMsgModal(subject, sender, time, body, fromAdmin) {
    document.getElementById('mmSubject').textContent = subject;
    document.getElementById('mmMeta').textContent    = (fromAdmin ? 'From: Admin' : 'From: You') + ' \u00b7 ' + time;
    document.getElementById('mmBody').textContent    = body;
    var bodyEl = document.getElementById('mmBody');
    bodyEl.className = 'vmodal__msgbody' + (fromAdmin ? ' msg-from-admin' : '');
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
