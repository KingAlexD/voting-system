<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Notifications | VoCho</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:ital,wght@0,700;0,800;0,900;1,700;1,900&family=Syne:wght@700;800&family=Epilogue:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
</head>
<body>
  <jsp:include page="/WEB-INF/views/fragment/navbar.jsp" />

  <div class="dash-page">

    <div class="dash-header">
      <p class="dash-eyebrow">Inbox</p>
      <h1 class="dash-title">Notifications</h1>
      <p class="dash-subtitle">System alerts, approvals, and messages from admin.</p>
    </div>

    <c:if test="${param.status == 'read'}">
      <div class="vo-alert vo-alert--success">Marked as read.</div>
    </c:if>

    <div class="vo-card">
      <div class="vo-card__head">
        <span class="vo-card__title">All Notifications</span>
        <%-- Mark all read --%>
        <form action="${pageContext.request.contextPath}/notifications" method="post">
          <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
          <button type="submit" class="vo-btn vo-btn--ghost vo-btn--sm">
            Mark all read
          </button>
        </form>
      </div>

      <div class="vo-card__body--flush">
        <c:if test="${empty notifications}">
          <div style="padding:48px 24px;text-align:center;">
            <p style="font-family:'Barlow Condensed',sans-serif;font-size:1.5rem;font-weight:900;text-transform:uppercase;color:rgba(234,228,214,.25);letter-spacing:-.01em;">
              No notifications yet
            </p>
            <p style="font-size:.82rem;color:rgba(234,228,214,.3);margin-top:6px;">
              System events, approvals, and messages will appear here.
            </p>
          </div>
        </c:if>

        <div class="notif-list">
          <c:forEach items="${notifications}" var="n">
            <div class="notif-item ${!n.read ? 'notif-item--unread' : ''}">

              <%-- Icon based on title keywords --%>
              <div class="notif-item__icon">
                <c:choose>
                  <c:when test="${n.title.toLowerCase().contains('message') || n.title.toLowerCase().contains('contact')}">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                      <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>
                    </svg>
                  </c:when>
                  <c:when test="${n.title.toLowerCase().contains('approved') || n.title.toLowerCase().contains('restored')}">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                      <polyline points="20 6 9 17 4 12"/>
                    </svg>
                  </c:when>
                  <c:when test="${n.title.toLowerCase().contains('denied') || n.title.toLowerCase().contains('suspended')}">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                      <circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/>
                    </svg>
                  </c:when>
                  <c:otherwise>
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                      <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/>
                    </svg>
                  </c:otherwise>
                </c:choose>
              </div>

              <div class="notif-item__body">
                <div class="notif-item__title">
                  <c:if test="${not empty n.link}">
                    <a href="${pageContext.request.contextPath}${n.link}" style="color:inherit;text-decoration:none;"
                       onmouseover="this.style.color='#d4a843'" onmouseout="this.style.color=''">
                      ${n.title}
                    </a>
                  </c:if>
                  <c:if test="${empty n.link}">${n.title}</c:if>
                </div>
                <div class="notif-item__msg">${n.message}</div>
                <span class="notif-item__time">${n.createdAt}</span>
              </div>

              <div class="notif-item__actions">
                <c:if test="${!n.read}">
                  <form action="${pageContext.request.contextPath}/notifications/read" method="post">
                    <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                    <input type="hidden" name="id" value="${n.id}">
                    <button type="submit" class="vo-btn vo-btn--ghost vo-btn--sm">
                      &#10003; Read
                    </button>
                  </form>
                </c:if>
                <c:if test="${n.read}">
                  <span style="font-family:'Syne',sans-serif;font-size:.58rem;font-weight:700;letter-spacing:.1em;text-transform:uppercase;color:rgba(234,228,214,.25);">Read</span>
                </c:if>
              </div>

            </div>
          </c:forEach>
        </div>

      </div>
    </div>
  </div>

  <jsp:include page="/WEB-INF/views/fragment/footer.jsp" />
</body>
</html>
