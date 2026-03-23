<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>About Us | Online Voting System</title>
    <%@ include file="/WEB-INF/views/fragment/head.jsp" %>
</head>
<body>
    <%@ include file="/WEB-INF/views/fragment/navbar.jsp" %>

    <section class="py-5 text-center bg-light border-bottom">
        <div class="container">
            <h1 class="fw-light">About the Platform</h1>
            <p class="lead text-muted">Empowering democracy through secure Jakarta EE technology.</p>
        </div>
    </section>

    <div class="container my-5">
        <div class="row g-5">
            <div class="col-md-6">
                <h2 class="pb-3 border-bottom">Our Project Overview</h2>
                <p>The Online Voting System is a session-based web application[cite: 4]. It is designed to provide a secure environment where voters can register, verify their identity, and cast their ballots once per election[cite: 5, 15].</p>
                <p>Administrators maintain full control over the system, ensuring that contester rules—such as the maximum limit of three contesters per position—are strictly followed[cite: 5, 23].</p>
            </div>
            
            <div class="col-md-6">
                <h2 class="pb-3 border-bottom">Technology Stack</h2>
                <ul class="list-group list-group-flush">
                    <li class="list-group-item"><strong>Backend:</strong> Jakarta Servlet & JSP [cite: 2, 33]</li>
                    <li class="list-group-item"><strong>ORM:</strong> JPA with Hibernate [cite: 2, 34]</li>
                    <li class="list-group-item"><strong>Database:</strong> MySQL [cite: 2]</li>
                    <li class="list-group-item"><strong>Frontend:</strong> Bootstrap 5 [cite: 2, 35]</li>
                    <li class="list-group-item"><strong>Architecture:</strong> Model-View-Controller (MVC) [cite: 33]</li>
                </ul>
            </div>
        </div>

        <hr class="my-5">

        <div class="row text-center">
            <h2 class="mb-4">System Roles</h2>
            <div class="col-md-4">
                <div class="p-3">
                    <i class="bi bi-people-fill display-4 text-primary"></i>
                    <h4 class="mt-2">Voters</h4>
                    <p>Register, verify email, and cast a single vote securely[cite: 7].</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="p-3">
                    <i class="bi bi-person-badge display-4 text-success"></i>
                    <h4 class="mt-2">Contesters</h4>
                    <p>Apply for positions and participate in the democratic process[cite: 8].</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="p-3">
                    <i class="bi bi-shield-check display-4 text-danger"></i>
                    <h4 class="mt-2">Admins</h4>
                    <p>Monitor votes and approve or deny contester applications[cite: 9, 28].</p>
                </div>
            </div>
        </div>
    </div>

    <%@ include file="/WEB-INF/views/fragment/footer.jsp" %>
</body>
</html>