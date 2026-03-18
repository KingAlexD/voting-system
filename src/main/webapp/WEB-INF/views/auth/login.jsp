<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login | VoCho</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:ital,wght@0,700;0,800;0,900;1,700;1,900&family=Syne:wght@700;800&family=Epilogue:wght@300;400;500&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/login.css">
</head>
<body>

  <jsp:include page="/WEB-INF/views/fragment/navbar.jsp"/>
  <div class= "all">
    <div class="auth-panel-image">
        <div class="bg-img"></div>
        <div class="overlay"></div>
        <div class="grain"></div>
        <div class="ornament"></div>
        <div class="panel-content">
            <h2>Welcome<br>back to<br><em>VoCho.</em></h2>
            <p>Your voice is waiting. Sign in and let your choice shape what comes next.</p>
        </div>
    </div>

    <div class="auth-panel-form">
        <div class="brand">
            <span class="brand-name"><span class="bm">V</span><span class="bt">OCHO</span></span>
        </div>

        <p class="form-eyebrow">Welcome back</p>
        <h1 class="form-heading">Sign in</h1>
        <p class="form-subheading">Enter your credentials to continue.</p>

        <c:if test="${param.status == 'verified'}">
            <div class="alert alert-success">Account verified. You can log in now.</div>
        </c:if>
        <c:if test="${param.status == 'password_reset'}">
            <div class="alert alert-success">Password reset successful.</div>
        </c:if>
        <c:if test="${param.error == 'suspended'}">
            <div class="alert alert-danger">Your account has been suspended. Contact support.</div>
        </c:if>
        <c:if test="${not empty param.error and param.error != 'suspended'}">
            <div class="alert alert-danger">
                <c:choose>
                    <c:when test="${param.error == 'unauthorized'}">Please log in to continue.</c:when>
                    <c:when test="${param.error == 'invalid'}">Invalid email or password.</c:when>
                    <c:otherwise>Unable to log in. Please try again.</c:otherwise>
                </c:choose>
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/login" method="POST">
            <input type="hidden" name="_csrf"
                   value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
            <div class="field">
                <label for="email">Email Address</label>
                <input type="email" id="email" name="email"
                       placeholder="you@example.com" autocomplete="email" required>
            </div>
            <div class="field">
                <label for="password">Password</label>
                <input type="password" id="password" name="password"
                       placeholder="Your password" autocomplete="current-password" required>
            </div>
            <button type="submit" class="btn-submit"><span>Sign In</span></button>
        </form>

        <div class="form-links">
            <a href="${pageContext.request.contextPath}/forgot-password-view">Forgot password?</a>
            <span>No account? <a href="${pageContext.request.contextPath}/register-view">Register</a></span>
        </div>
    </div>
  </div>
</body>
</html>
