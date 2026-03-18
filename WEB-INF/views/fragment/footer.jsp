<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<footer class="vo-footer">
  <div class="vo-footer__inner">

    <div class="vo-footer__brand">
      <span class="vo-footer__logo-mark">V</span><span class="vo-footer__logo-text">oCho</span>
      <p class="vo-footer__tagline">Where every voice finds its choice.</p>
    </div>

    <nav class="vo-footer__links">
      <a href="${pageContext.request.contextPath}/index.jsp">Home</a>
      <a href="${pageContext.request.contextPath}/about.jsp">About</a>
      <a href="${pageContext.request.contextPath}/contact">Contact</a>
    </nav>

    <p class="vo-footer__copy">&copy; 2026 VoCho &mdash; Voice &amp; Choice</p>

  </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/js/index.js"></script>
