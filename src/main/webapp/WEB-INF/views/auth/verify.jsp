<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verify Account | VoCho</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:ital,wght@0,700;0,800;0,900;1,700;1,900&family=Syne:wght@700;800&family=Epilogue:wght@300;400;500&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/auth-pages.css">
</head>
<body>
    <jsp:include page="/WEB-INF/views/fragment/navbar.jsp" />

    <div class="auth-page">
        <div class="auth-card" style="text-align: center;">

            <!-- Envelope icon -->
            <div class="verify-icon">
                <svg width="26" height="26" viewBox="0 0 24 24" fill="none"
                     stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
                    <polyline points="22,6 12,13 2,6"/>
                </svg>
            </div>

            <p class="form-eyebrow">Email Verification</p>
            <h1 class="form-heading">Verify<br>Identity</h1>
            <p class="form-subheading">Enter the 6-digit code sent to your email address. Check your inbox and spam folder.</p>

            <c:if test="${param.status == 'code_sent'}">
                <div class="alert alert-info">Verification code sent. Check your inbox and spam folder.</div>
            </c:if>
            <c:if test="${param.status == 'resent'}">
                <div class="alert alert-info">A new verification code has been sent to your email.</div>
            </c:if>
            <c:if test="${not empty sessionScope.lastVerificationCode}">
                <div class="alert alert-warning" style="text-align:left;">
                    <strong style="font-family:'Syne',sans-serif;font-size:0.65rem;letter-spacing:.1em;">DEV — CODE:</strong>
                    <span style="font-family:'Barlow Condensed',sans-serif;font-size:1.1rem;font-weight:900;color:#d4a843;letter-spacing:.12em;">
                        ${sessionScope.lastVerificationCode}
                    </span>
                </div>
            </c:if>
            <c:if test="${not empty param.error}">
                <div class="alert alert-danger">
                    <c:choose>
                        <c:when test="${param.error == 'invalid_code'}">Invalid verification code. Please try again.</c:when>
                        <c:when test="${param.error == 'session_expired'}">Verification session expired. Please register again.</c:when>
                        <c:when test="${param.error == 'email_send_failed'}">Could not send email. Contact support or retry.</c:when>
                        <c:otherwise>Verification failed. Please try again.</c:otherwise>
                    </c:choose>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/verify" method="POST">
                <input type="hidden" name="_csrf"
                       value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                <div class="field" style="margin-bottom:20px;">
                    <input type="text" name="code" class="code-input"
                           placeholder="000000" maxlength="6" pattern="[0-9]{6}"
                           inputmode="numeric" autocomplete="one-time-code" required>
                </div>
                <button type="submit" class="btn-submit"><span>Verify Account</span></button>
            </form>

            <form action="${pageContext.request.contextPath}/resend-verification" method="POST" style="margin-top:14px;">
                <input type="hidden" name="_csrf"
                       value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                <button type="submit" class="btn-ghost">Resend Code</button>
            </form>

            <div class="form-links" style="margin-top:14px; justify-content:center;">
                <a href="${pageContext.request.contextPath}/register-view">&#8592; Back to Register</a>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/views/fragment/footer.jsp" />
</body>
</html>
