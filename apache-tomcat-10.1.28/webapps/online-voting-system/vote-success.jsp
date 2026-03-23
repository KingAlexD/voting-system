<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <%@ include file="/WEB-INF/views/fragment/head.jsp" %>
    <title>Vote Submitted</title>
</head>
<body class="bg-light d-flex flex-column min-vh-100">
    <%@ include file="/WEB-INF/views/fragment/navbar.jsp" %>
    <main class="container py-5 flex-grow-1 d-flex align-items-center">
        <div class="row justify-content-center w-100 text-center">
            <div class="col-md-7">
                <div class="card p-5">
                    <i class="bi bi-check-circle-fill text-success display-4 mb-3"></i>
                    <h2>Vote Recorded</h2>
                    <p class="text-muted mb-4">Your ballot has been submitted successfully. You can still review live vote counts on the dashboard.</p>
                    <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-primary px-4">Return to Dashboard</a>
                </div>
            </div>
        </div>
    </main>
    <%@ include file="/WEB-INF/views/fragment/footer.jsp" %>
</body>
</html>
