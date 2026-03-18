<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Password | VoCho</title>
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
            <h1 class="form-heading">Reset<br>Password</h1>
            <p class="form-subheading">Choose a new password. Must be at least 8 characters.</p>

            <c:if test="${param.error == 'invalid_token'}">
                <div class="alert alert-danger">This reset link is invalid or has expired. Request a new one.</div>
            </c:if>
            <c:if test="${param.error == 'password_mismatch'}">
                <div class="alert alert-danger">Passwords do not match or are too short.</div>
            </c:if>
            <c:if test="${param.error == 'missing_token'}">
                <div class="alert alert-danger">No reset token found. Please use the link from your email.</div>
            </c:if>

            <form action="${pageContext.request.contextPath}/reset-password" method="POST">
                <input type="hidden" name="_csrf"
                       value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                <input type="hidden" name="token" value="${param.token}">

                <div class="field">
                    <label for="newPassword">New Password</label>
                    <input type="password" id="newPassword" name="newPassword"
                           placeholder="Min. 8 characters" minlength="8"
                           autocomplete="new-password" required>
                </div>

                <div class="field">
                    <label for="confirmPassword">Confirm Password</label>
                    <input type="password" id="confirmPassword" name="confirmPassword"
                           placeholder="Repeat new password" minlength="8"
                           autocomplete="new-password" required>
                </div>

                <button type="submit" class="btn-submit"><span>Update Password</span></button>
            </form>

            <div class="form-links">
                <a href="${pageContext.request.contextPath}/login-view">&#8592; Back to Sign In</a>
                <a href="${pageContext.request.contextPath}/forgot-password-view">Resend link</a>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/views/fragment/footer.jsp" />
</body>
</html>
