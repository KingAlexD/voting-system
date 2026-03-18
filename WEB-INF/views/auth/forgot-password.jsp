<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password | VoCho</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:ital,wght@0,700;0,800;0,900;1,700;1,900&family=Syne:wght@700;800&family=Epilogue:wght@300;400;500&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/auth-pages.css">
</head>
<body>
    <jsp:include page="/WEB-INF/views/fragment/navbar.jsp" />

    <div class="auth-page">
        <div class="auth-card">

            <div class="brand">
                <span class="brand-name"><span class="bm">V</span><span class="bt">OCHO</span></span>
            </div>

            <p class="form-eyebrow">Account Recovery</p>
            <h1 class="form-heading">Forgot<br>Password</h1>
            <p class="form-subheading">Enter your email address and we'll send you a reset link.</p>

            <c:if test="${param.status == 'request_sent'}">
                <div class="alert alert-success">If that email is registered, a reset link has been sent. Check your inbox.</div>
            </c:if>
            <c:if test="${param.error == 'email_send_failed'}">
                <div class="alert alert-danger">Unable to send reset email right now. Please try again later.</div>
            </c:if>

            <form action="${pageContext.request.contextPath}/forgot-password" method="POST">
                <input type="hidden" name="_csrf"
                       value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">

                <div class="field">
                    <label for="email">Email Address</label>
                    <input type="email" id="email" name="email"
                           placeholder="you@example.com" autocomplete="email" required>
                </div>

                <button type="submit" class="btn-submit"><span>Send Reset Link</span></button>
            </form>

            <div class="form-links">
                <a href="${pageContext.request.contextPath}/login-view">&#8592; Back to Sign In</a>
                <a href="${pageContext.request.contextPath}/register-view">Create account</a>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/views/fragment/footer.jsp" />
</body>
</html>
