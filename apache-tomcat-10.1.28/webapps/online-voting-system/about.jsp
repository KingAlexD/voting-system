<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/views/fragment/head.jsp" />
    <title>About | Online Voting System</title>
</head>
<body>
    <jsp:include page="/WEB-INF/views/fragment/navbar.jsp" />
    <main class="container py-5">
        <section class="card mb-4">
            <div class="card-body p-4 p-md-5">
                <p class="section-label mb-2">About The Project</p>
                <h1 class="mb-3">Built for Real-World Java Web Development</h1>
                <p class="text-muted mb-0">This system demonstrates end-to-end architecture for a secure online election workflow using Jakarta Servlet, JSP, JPA (Hibernate), and MySQL under MVC.</p>
            </div>
        </section>

        <section class="row g-3">
            <div class="col-md-4">
                <div class="soft-panel h-100">
                    <h5>Role Separation</h5>
                    <p class="text-muted mb-0">Voter, contester, and admin actions are isolated with strict session-based role checks.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="soft-panel h-100">
                    <h5>Election Integrity</h5>
                    <p class="text-muted mb-0">Only approved contesters can receive votes, and each voter can submit exactly one ballot.</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="soft-panel h-100">
                    <h5>Operational Controls</h5>
                    <p class="text-muted mb-0">Admin dashboards, audit logs, and configurable deadline controls support monitoring and governance.</p>
                </div>
            </div>
        </section>
    </main>
    <jsp:include page="/WEB-INF/views/fragment/footer.jsp" />
</body>
</html>
