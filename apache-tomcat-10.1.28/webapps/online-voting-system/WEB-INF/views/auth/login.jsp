<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/views/fragment/head.jsp" />
    <title>Login | Online Voting System</title>
</head>
<body>
    <jsp:include page="/WEB-INF/views/fragment/navbar.jsp" />
    <div class="container my-5">
        <div class="card mx-auto shadow-sm" style="max-width: 450px;">
            <div class="card-body p-4">
                <h3 class="text-center mb-4">Login</h3>

                <c:if test="${param.status == 'verified'}">
                    <div class="alert alert-success">Account verified. You can login now.</div>
                </c:if>
                <c:if test="${param.status == 'password_reset'}">
                    <div class="alert alert-success">Password reset successful. Login with your new password.</div>
                </c:if>
                <c:if test="${not empty param.error}">
                    <div class="alert alert-danger py-2">
                        <c:choose>
                            <c:when test="${param.error == 'unauthorized'}">Please login to continue.</c:when>
                            <c:when test="${param.error == 'invalid'}">Invalid email or password.</c:when>
                            <c:otherwise>Unable to login.</c:otherwise>
                        </c:choose>
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/login" method="POST">
                    <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                    <div class="mb-3">
                        <label class="form-label">Email Address</label>
                        <input type="email" name="email" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Password</label>
                        <input type="password" name="password" class="form-control" required>
                    </div>
                    <button type="submit" class="btn btn-primary w-100 py-2">Login</button>
                </form>
                <div class="text-center mt-2">
                    <a href="${pageContext.request.contextPath}/forgot-password-view">Forgot password?</a>
                </div>
                <div class="text-center mt-3">
                    No account? <a href="${pageContext.request.contextPath}/register-view">Register here</a>
                </div>
                <div class="alert alert-secondary mt-3 mb-0">
                    <small>Default admin: <code>admin@votely.local</code> / <code>Admin@123</code></small>
                </div>
            </div>
        </div>
    </div>
    <jsp:include page="/WEB-INF/views/fragment/footer.jsp" />
</body>
</html>
