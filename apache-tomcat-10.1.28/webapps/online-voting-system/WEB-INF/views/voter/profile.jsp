<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/views/fragment/head.jsp" />
    <title>Profile | Online Voting System</title>
</head>
<body class="bg-light">
    <jsp:include page="/WEB-INF/views/fragment/navbar.jsp" />
    <div class="container py-4">
        <c:if test="${param.status == 'updated'}">
            <div class="alert alert-success">Profile updated successfully.</div>
        </c:if>
        <c:if test="${not empty param.error}">
            <div class="alert alert-danger">
                <c:choose>
                    <c:when test="${param.error == 'wrong_password'}">Current password is incorrect.</c:when>
                    <c:when test="${param.error == 'password_mismatch'}">New passwords do not match.</c:when>
                    <c:otherwise>Update failed.</c:otherwise>
                </c:choose>
            </div>
        </c:if>
        <div class="row g-4">
            <div class="col-lg-6">
                <div class="card">
                    <div class="card-header">Personal Information</div>
                    <div class="card-body">
                        <form action="${pageContext.request.contextPath}/profile" method="post">
                            <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                            <input type="hidden" name="action" value="updateInfo">
                            <div class="mb-3">
                                <label class="form-label">First Name</label>
                                <input class="form-control" name="firstName" value="${currentUser.firstName}" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Last Name</label>
                                <input class="form-control" name="lastName" value="${currentUser.lastName}" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">State</label>
                                <input class="form-control" name="state" value="${currentUser.state}" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Country</label>
                                <input class="form-control" name="country" value="${currentUser.country}" required>
                            </div>
                            <button class="btn btn-primary" type="submit">Update Info</button>
                        </form>
                    </div>
                </div>
            </div>
            <div class="col-lg-6">
                <div class="card">
                    <div class="card-header">Change Password</div>
                    <div class="card-body">
                        <form action="${pageContext.request.contextPath}/profile" method="post">
                            <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                            <input type="hidden" name="action" value="changePassword">
                            <div class="mb-3">
                                <label class="form-label">Current Password</label>
                                <input type="password" class="form-control" name="currentPassword" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">New Password</label>
                                <input type="password" class="form-control" name="newPassword" minlength="8" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Confirm New Password</label>
                                <input type="password" class="form-control" name="confirmPassword" minlength="8" required>
                            </div>
                            <button class="btn btn-warning" type="submit">Change Password</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <jsp:include page="/WEB-INF/views/fragment/footer.jsp" />
</body>
</html>
