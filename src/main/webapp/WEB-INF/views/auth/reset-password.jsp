<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/views/fragment/head.jsp" />
    <title>Reset Password | Online Voting System</title>
</head>
<body>
    <jsp:include page="/WEB-INF/views/fragment/navbar.jsp" />
    <div class="container my-5">
        <div class="card mx-auto shadow-sm" style="max-width: 500px;">
            <div class="card-body p-4">
                <h3 class="text-center mb-3">Reset Password</h3>

                <c:if test="${param.error == 'invalid_token'}">
                    <div class="alert alert-danger">Reset link is invalid or expired.</div>
                </c:if>
                <c:if test="${param.error == 'password_mismatch'}">
                    <div class="alert alert-danger">Passwords do not match or are too short.</div>
                </c:if>

                <form action="${pageContext.request.contextPath}/reset-password" method="post">
                    <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                    <input type="hidden" name="token" value="${param.token}">
                    <div class="mb-3">
                        <label class="form-label">New Password</label>
                        <input type="password" class="form-control" name="newPassword" minlength="8" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Confirm Password</label>
                        <input type="password" class="form-control" name="confirmPassword" minlength="8" required>
                    </div>
                    <button type="submit" class="btn btn-success w-100">Update Password</button>
                </form>
            </div>
        </div>
    </div>
    <jsp:include page="/WEB-INF/views/fragment/footer.jsp" />
</body>
</html>
