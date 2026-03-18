<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<nav class="nav" id="voNav">
  <div class="navinner">

    <a class="navbrand" href="${pageContext.request.contextPath}/index.jsp">
      <span class="navlogo">V</span><span class="navlogo-text">o<span class="navlogo">C</span>ho</span>
    </a>

    <button class="navtoggle" id="navToggle" aria-label="Toggle menu">
      <span></span><span></span><span></span>
    </button>

    <div class="navlinks" id="navLinks">
      <a class="navlink" href="${pageContext.request.contextPath}/index.jsp">Home</a>
      <a class="navlink" href="${pageContext.request.contextPath}/about.jsp">About</a>
      <a class="navlink" href="${pageContext.request.contextPath}/contact.jsp">Contact</a>

      <c:choose>
        <c:when test="${not empty sessionScope.userId}">
          <c:if test="${sessionScope.userRole == 'ADMIN'}">
            <a class="navlink" href="${pageContext.request.contextPath}/admin/dashboard">Admin</a>
          </c:if>
          <c:if test="${sessionScope.userRole != 'ADMIN'}">
            <a class="navlink" href="${pageContext.request.contextPath}/dashboard">Dashboard</a>
            <a class="navlink" href="${pageContext.request.contextPath}/profile">Profile</a>
          </c:if>

          <a class="navbell navlink" href="${pageContext.request.contextPath}/notifications">
            <svg width="17" height="17" viewBox="0 0 24 24" fill="none"
                 stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/>
              <path d="M13.73 21a2 2 0 0 1-3.46 0"/>
            </svg>
            <c:if test="${not empty unreadNotificationCount and unreadNotificationCount > 0}">
              <span class="navbadge">${unreadNotificationCount}</span>
            </c:if>
          </a>

          <a class="navpill navpill--ghost" href="${pageContext.request.contextPath}/logout">Log out</a>
        </c:when>
        <c:otherwise>
          <a class="navlink" href="${pageContext.request.contextPath}/login-view">Login</a>
          <a class="navpill" href="${pageContext.request.contextPath}/register-view">Register</a>
        </c:otherwise>
      </c:choose>
    </div>

  </div>
</nav>

<script>
(function(){
  var toggle = document.getElementById('navToggle');
  var links  = document.getElementById('navLinks');
  if (toggle) toggle.addEventListener('click', function(){
    links.classList.toggle('open');
    toggle.classList.toggle('open');
  });
})();
</script>
