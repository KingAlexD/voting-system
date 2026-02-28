<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/views/fragment/head.jsp" />
    <title>Candidate Profile</title>
</head>
<body class="bg-light">
    <jsp:include page="/WEB-INF/views/fragment/navbar.jsp" />
    <main class="container py-4">
        <div class="card">
            <div class="card-body p-4 p-md-5">
                <p class="section-label mb-2">Candidate Profile</p>
                <h2>${contester.user.firstName} ${contester.user.lastName}</h2>
                <p class="text-muted mb-1">Position: <strong>${contester.position}</strong></p>
                <p class="text-muted mb-3">Status: <strong>${contester.status}</strong></p>
                <div class="soft-panel mb-3">
                    <h6>Manifesto</h6>
                    <p class="mb-0 text-muted">${contester.manifesto}</p>
                </div>
                <div class="soft-panel mb-3">
                    <h6>Current Votes</h6>
                    <p class="metric mb-0">${votes}</p>
                </div>
                <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/dashboard">Back to Dashboard</a>
            </div>
        </div>
    </main>
    <jsp:include page="/WEB-INF/views/fragment/footer.jsp" />
</body>
</html>
