<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Contact &mdash; VoCho</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:ital,wght@0,700;0,800;0,900;1,700;1,900&family=Syne:wght@700;800&family=Epilogue:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/contact.css">
</head>
<body>

  <jsp:include page="/WEB-INF/views/fragment/navbar.jsp" />

  <main class="contact-page">

   
    <div class="contact-header">
      <p class="contact-eyebrow">Get in Touch</p>
      <h1 class="contact-heading">Contact<br><em>Support</em></h1>
      <p class="contact-subhead">Questions about your vote, account, or candidacy? Send a message and the admin team will get back to you.</p>
    </div>

    <c:if test="${not empty param.status}">
      <div class="vo-alert vo-alert--success">
        <c:choose>
          <c:when test="${param.status == 'sent'}">&#10003; &nbsp;Message sent successfully.</c:when>
          <c:when test="${param.status == 'read'}">&#10003; &nbsp;Message marked as read.</c:when>
        </c:choose>
      </div>
    </c:if>
    <c:if test="${param.error == 'missing_fields'}">
      <div class="vo-alert vo-alert--error">&#9888; &nbsp;Please fill in all required fields.</div>
    </c:if>


    <div class="contact-body">

      <!-- ── Contact Form ─────────────────────────────── -->
      <div class="form-panel">
        <h2 class="form-panel__title">Send a <span>message</span></h2>

        <form action="${pageContext.request.contextPath}/contact" method="POST" class="vo-form">
          <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">

          <div class="form-row">
            <div class="field-group">
              <label class="field-label">Full Name</label>
              <input type="text" name="senderName" class="field-input"
                     placeholder="Your name"
                     value="${not empty currentUser ? currentUser.firstName.concat(' ').concat(currentUser.lastName) : ''}"
                     required>
            </div>
            <div class="field-group">
              <label class="field-label">Email Address</label>
              <input type="email" name="senderEmail" class="field-input"
                     placeholder="you@email.com"
                     value="${not empty currentUser ? currentUser.email : ''}"
                     required>
            </div>
          </div>

          <div class="field-group">
            <label class="field-label">Subject</label>
            <select name="subject" class="field-select">
              <option value="Registration Issue">Registration Issue</option>
              <option value="Vote Confirmation">Vote Confirmation</option>
              <option value="Candidate Application">Candidate Application</option>
              <option value="Technical Issue">Technical Issue</option>
              <option value="Other">Other</option>
            </select>
          </div>

          <div class="field-group">
            <label class="field-label">Message</label>
            <textarea name="message" class="field-textarea"
                      placeholder="Describe your issue or question..." required></textarea>
          </div>

          <div class="form-submit">
            <button type="submit" class="btn-submit">
              Send Message
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
                   stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <path d="M5 12h14M12 5l7 7-7 7"/>
              </svg>
            </button>
          </div>
        </form>
      </div>

      <!-- ── Message History (logged-in non-admin only) ── -->
      <c:if test="${not empty currentUser and currentUser.role != 'ADMIN'}">
        <div class="history-panel">
          <h3 class="history-panel__title">Your Messages</h3>

          <c:if test="${empty myMessages}">
            <p class="history-empty">No messages yet. Send one using the form.</p>
          </c:if>

          <c:forEach items="${myMessages}" var="m">
            <div class="msg-thread ${m.fromAdmin and !m.userRead ? 'msg-thread--unread' : ''}">

              <div class="msg-thread__head">
                <div class="msg-thread__meta">
                  <div class="msg-thread__badges">
                    <c:choose>
                      <c:when test="${m.fromAdmin}">
                        <span class="vo-badge vo-badge--admin">Admin &rarr; You</span>
                        <c:if test="${!m.userRead}">
                          <span class="vo-badge vo-badge--new">New</span>
                        </c:if>
                      </c:when>
                      <c:otherwise>
                        <span class="vo-badge vo-badge--user">You &rarr; Admin</span>
                        <c:if test="${m.adminRead}">
                          <span class="vo-badge vo-badge--read">Read</span>
                        </c:if>
                        <c:if test="${!m.adminRead}">
                          <span class="vo-badge vo-badge--unread">Pending</span>
                        </c:if>
                      </c:otherwise>
                    </c:choose>
                  </div>
                  <p class="msg-thread__subject">${m.subject}</p>
                  <p class="msg-thread__body">${m.body}</p>
                  <span class="msg-thread__time">${m.createdAt}</span>
                </div>

                <div class="msg-thread__actions">
                  <c:if test="${m.fromAdmin and !m.userRead}">
                    <form action="${pageContext.request.contextPath}/contact/read" method="post">
                      <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                      <input type="hidden" name="id" value="${m.id}">
                      <button type="submit" class="btn-sm-mark">&#10003; Mark read</button>
                    </form>
                  </c:if>
                  <button class="btn-sm-reply"
                          onclick="toggleReply('reply-${m.id}', this)">Reply</button>
                </div>
              </div>

              <!-- Inline reply -->
              <div class="msg-reply-form" id="reply-${m.id}">
                <form action="${pageContext.request.contextPath}/contact" method="post">
                  <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                  <input type="hidden" name="parentId" value="${m.id}">
                  <input type="hidden" name="senderName" value="${currentUser.firstName} ${currentUser.lastName}">
                  <input type="hidden" name="senderEmail" value="${currentUser.email}">
                  <input type="hidden" name="subject" value="Re: ${m.subject}">
                  <textarea name="message" placeholder="Your reply..." required></textarea>
                  <button type="submit" class="btn-reply-send">Send Reply</button>
                </form>
              </div>

            </div>
          </c:forEach>
        </div>
      </c:if>

    </div>
  </main>

  <jsp:include page="/WEB-INF/views/fragment/footer.jsp" />

  <script>
  function toggleReply(id, btn) {
    var el = document.getElementById(id);
    var open = el.classList.toggle('open');
    btn.textContent = open ? 'Cancel' : 'Reply';
  }
  </script>

</body>
</html>
