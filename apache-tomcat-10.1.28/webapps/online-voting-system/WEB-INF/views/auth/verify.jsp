<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <jsp:include page="/WEB-INF/views/fragment/head.jsp" />
    <title>Verify Account</title>
    <style>
        .code-input {
            letter-spacing: 0.6rem;
            font-size: 1.8rem;
            text-align: center;
            font-weight: 700;
        }
    </style>
</head>
<body class="bg-light d-flex flex-column min-vh-100">
    <jsp:include page="/WEB-INF/views/fragment/navbar.jsp" />
    <div class="container py-5 flex-grow-1 d-flex align-items-center">
        <div class="row justify-content-center w-100">
            <div class="col-md-6 col-lg-5">
                <div class="card shadow border-0 text-center">
                    <div class="card-body p-5">
                        <h3 class="fw-bold">Verify Identity</h3>
                        <p class="text-muted mb-4">Enter the 6-digit code sent to your email address.</p>

                        <c:if test="${param.status == 'code_sent'}">
                            <div class="alert alert-info">Verification code sent. Check your inbox and spam folder.</div>
                        </c:if>
                        <c:if test="${param.status == 'resent'}">
                            <div class="alert alert-info">A new verification code has been sent.</div>
                        </c:if>
                        <c:if test="${not empty sessionScope.lastVerificationCode}">
                            <div class="alert alert-warning text-start">
                                <strong>Verification code:</strong>
                                <code>${sessionScope.lastVerificationCode}</code>
                            </div>
                        </c:if>
                        <c:if test="${not empty param.error}">
                            <div class="alert alert-danger">
                                <c:choose>
                                    <c:when test="${param.error == 'invalid_code'}">Invalid verification code.</c:when>
                                    <c:when test="${param.error == 'session_expired'}">Verification session expired. Register again.</c:when>
                                    <c:when test="${param.error == 'email_send_failed'}">Could not send email. Contact admin or retry.</c:when>
                                    <c:otherwise>Verification failed.</c:otherwise>
                                </c:choose>
                            </div>
                        </c:if>

                        <form action="${pageContext.request.contextPath}/verify" method="POST">
                            <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                            <div class="mb-4">
                                <input type="text" name="code" class="form-control code-input"
                                       placeholder="000000" maxlength="6" pattern="[0-9]{6}" required>
                            </div>
                            <button type="submit" class="btn btn-success w-100 py-2 fw-bold">VERIFY ACCOUNT</button>
                        </form>

                        <form action="${pageContext.request.contextPath}/resend-verification" method="POST" class="mt-3">
                            <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                            <button type="submit" class="btn btn-link text-decoration-none">Resend Code</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <jsp:include page="/WEB-INF/views/fragment/footer.jsp" />
</body>
</html>
