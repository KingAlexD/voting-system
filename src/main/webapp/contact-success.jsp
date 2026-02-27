<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="/WEB-INF/views/fragment/head.jsp" %>
</head>
<body class="bg-light d-flex flex-column min-vh-100">
    <%@ include file="/WEB-INF/views/fragment/navbar.jsp" %>

    <div class="container py-5 flex-grow-1 d-flex align-items-center">
        <div class="row justify-content-center w-100">
            <div class="col-md-6 text-center">
                <div class="card shadow border-0 p-5">
                    <i class="bi bi-send-check text-success display-1 mb-4"></i>
                    <h2 class="fw-bold">Message Sent!</h2>
                    <p class="text-muted">Thank you for reaching out, Mystery. Our team will review your inquiry and get back to you via email shortly.</p>
                    <div class="mt-4">
                        <a href="<%=request.getContextPath()%>/index.jsp" class="btn btn-primary px-4">Back to Home</a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%@ include file="/WEB-INF/views/fragment/footer.jsp" %>
</body>
</html>