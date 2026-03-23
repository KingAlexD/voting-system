<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <%@ include file="/WEB-INF/views/fragment/head.jsp" %>
</head>
<body class="bg-light d-flex flex-column min-vh-100">
    <%@ include file="/WEB-INF/views/fragment/navbar.jsp" %>
    <div class="container py-5 flex-grow-1 d-flex align-items-center">
        <div class="row justify-content-center w-100 text-center">
            <div class="col-md-6">
                <div class="card p-5 border-0 shadow">
                    <i class="bi bi-check-circle-fill text-success display-1 mb-4"></i>
                    <h2 class="fw-bold">Vote Recorded!</h2>
                    <p class="text-muted">Thank you, Mystery. Your voice has been heard. You have successfully cast your ballot for the 2026 election.</p>
                    <a href="<%=request.getContextPath()%>/dashboard" class="btn btn-outline-primary mt-3">Return to Dashboard</a>
                </div>
            </div>
        </div>
    </div>
    <%@ include file="/WEB-INF/views/fragment/footer.jsp" %>
</body>
</html>