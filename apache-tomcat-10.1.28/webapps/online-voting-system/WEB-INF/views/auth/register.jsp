<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/views/fragment/head.jsp" />
    <title>Register | Online Voting System</title>
</head>
<body>
    <jsp:include page="/WEB-INF/views/fragment/navbar.jsp" />
    <div class="container my-5">
        <div class="card mx-auto shadow-sm" style="max-width: 700px;">
            <div class="card-body p-4 p-md-5">
                <h3 class="mb-4">Voter Registration</h3>

                <c:if test="${not empty param.error}">
                    <div class="alert alert-danger">
                        <c:choose>
                            <c:when test="${param.error == 'missing_fields'}">All fields are required.</c:when>
                            <c:when test="${param.error == 'password_mismatch'}">Passwords do not match.</c:when>
                            <c:when test="${param.error == 'invalid_birth_year'}">Birth year is invalid.</c:when>
                            <c:when test="${param.error == 'email_exists'}">Email already exists.</c:when>
                            <c:otherwise>Registration failed.</c:otherwise>
                        </c:choose>
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/register" method="POST" class="row g-3">
                    <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                    <div class="col-md-6">
                        <label class="form-label">First Name</label>
                        <input type="text" name="firstName" class="form-control" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Last Name</label>
                        <input type="text" name="lastName" class="form-control" required>
                    </div>
                    <div class="col-12">
                        <label class="form-label">Email</label>
                        <input type="email" name="email" class="form-control" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Password</label>
                        <input type="password" name="password" class="form-control" minlength="8" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Confirm Password</label>
                        <input type="password" name="confirmPassword" class="form-control" minlength="8" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Birth Year</label>
                        <input type="number" name="birthYear" class="form-control" min="1900" max="2099" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">State</label>
                        <input type="text" name="state" class="form-control" required>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Country</label>
                        <input type="text" name="country" class="form-control" required>
                    </div>
                    <div class="col-12 d-grid mt-4">
                        <button type="submit" class="btn btn-success btn-lg">Create Account</button>
                    </div>
                    <div class="col-12">
                        <small class="text-muted">Users below 18 can register and login, but cannot vote or contest until age 18+.</small>
                    </div>
                </form>
            </div>
        </div>
    </div>
    <jsp:include page="/WEB-INF/views/fragment/footer.jsp" />
</body>
</html>
