<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<footer class="vo-footer">
  <div class="vo-footer__inner">
    <div class="vo-footer__brand">
      <a href="${pageContext.request.contextPath}/index.jsp" style="text-decoration:none;">
        <span class="vo-footer__logo-mark">V</span><span class="vo-footer__logo-text">oCho</span>
      </a>
      <p class="vo-footer__tagline">Voice &amp; Choice Platform</p>
    </div>
    <div class="vo-footer__links">
      <a href="${pageContext.request.contextPath}/index.jsp">Home</a>
      <a href="${pageContext.request.contextPath}/about.jsp">About</a>
      <c:choose>
        <c:when test="${not empty sessionScope.userId}">
          <a href="${pageContext.request.contextPath}/contact">Messages</a>
        </c:when>
        <c:otherwise>
          <a href="${pageContext.request.contextPath}/contact.jsp">Contact</a>
        </c:otherwise>
      </c:choose>
    </div>
    <div class="vo-footer__copy">&copy; 2026 VoCho &mdash; All rights reserved.</div>
  </div>
</footer>

<%-- data-ctx lets winner-popup.js derive the context path without hardcoding --%>
<span data-ctx="${pageContext.request.contextPath}" style="display:none;"></span>
<script src="${pageContext.request.contextPath}/js/winner-popup.js"></script>
