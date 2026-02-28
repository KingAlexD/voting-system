<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/views/fragment/head.jsp" />
    <title>Online Voting System | Home</title>
</head>
<body>
    <jsp:include page="/WEB-INF/views/fragment/navbar.jsp" />

    <main class="container py-4 py-md-5">
        <section class="hero-wrap mb-5">
            <div class="overlay-content text-center text-md-start">
                <p class="section-label mb-2">Civic Tech Demo</p>
                <h1 class="display-3 mb-3">Vote Smarter. Lead Better.</h1>
                <p class="lead mb-4">A secure, session-based election platform built with Jakarta EE, JSP, JPA, and MySQL.</p>
                <div class="d-flex flex-wrap gap-2 justify-content-center justify-content-md-start">
                    <a href="${pageContext.request.contextPath}/register-view" class="btn btn-light btn-lg px-4">Create Account</a>
                    <a href="${pageContext.request.contextPath}/login-view" class="btn btn-outline-light btn-lg px-4">Access Dashboard</a>
                </div>
            </div>
        </section>

        <section class="row g-3 mb-5">
            <div class="col-md-4">
                <div class="soft-panel h-100">
                    <p class="section-label mb-1">Security</p>
                    <div class="metric">BCrypt + JPA</div>
                    <p class="text-muted mb-0">Password hashing, role-based access, and protected authenticated routes.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="soft-panel h-100">
                    <p class="section-label mb-1">Fairness</p>
                    <div class="metric">One Voter, One Vote</div>
                    <p class="text-muted mb-0">Database-level one-vote rule and admin-controlled contester approvals.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="soft-panel h-100">
                    <p class="section-label mb-1">Transparency</p>
                    <div class="metric">Live Count View</div>
                    <p class="text-muted mb-0">Vote totals are visible in read-only mode for all approved contesters.</p>
                </div>
            </div>
        </section>

        <section class="card">
            <div class="card-body p-4 p-md-5">
                <h2 class="mb-3">What This Demo Includes</h2>
                <div class="row g-3 text-muted">
                    <div class="col-md-6"><i class="bi bi-check2-circle text-success me-2"></i>User registration with email verification</div>
                    <div class="col-md-6"><i class="bi bi-check2-circle text-success me-2"></i>Session-based login for voters/admins</div>
                    <div class="col-md-6"><i class="bi bi-check2-circle text-success me-2"></i>Contester applications and admin approval</div>
                    <div class="col-md-6"><i class="bi bi-check2-circle text-success me-2"></i>Position cap rule (max 3 approved)</div>
                    <div class="col-md-6"><i class="bi bi-check2-circle text-success me-2"></i>Dashboard voting and statistics</div>
                    <div class="col-md-6"><i class="bi bi-check2-circle text-success me-2"></i>Profile update and password management</div>
                </div>
            </div>
        </section>
    </main>

    <jsp:include page="/WEB-INF/views/fragment/footer.jsp" />
</body>
</html>
