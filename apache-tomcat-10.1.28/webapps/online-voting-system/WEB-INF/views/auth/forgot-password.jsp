<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/views/fragment/head.jsp" />
    <title>Forgot Password | Online Voting System</title>
</head>
<body>
    <jsp:include page="/WEB-INF/views/fragment/navbar.jsp" />
    <div class="container my-5">
        <div class="card mx-auto shadow-sm" style="max-width: 500px;">
            <div class="card-body p-4">
                <h3 class="text-center mb-3">Forgot Password</h3>
                <p class="text-muted text-center">Enter your email to receive a reset link.</p>

                <c:if test="${param.status == 'request_sent'}">
                    <div class="alert alert-success">If the email exists, a reset link has been sent.</div>
                </c:if>
                <c:if test="${param.error == 'email_send_failed'}">
                    <div class="alert alert-danger">Unable to send reset email currently. Try again later.</div>
                </c:if>

                <form action="${pageContext.request.contextPath}/forgot-password" method="post">
                    <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                    <div class="mb-3">
                        <label class="form-label">Email Address</label>
                        <input type="email" class="form-control" name="email" required>
                    </div>
                    <button type="submit" class="btn btn-primary w-100">Send Reset Link</button>
                </form>
            </div>
        </div>
    </div>
    <jsp:include page="/WEB-INF/views/fragment/footer.jsp" />
</body>
</html>
