<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="/WEB-INF/views/fragment/head.jsp" %>
    <title>Message Sent</title>
</head>
<body class="bg-light d-flex flex-column min-vh-100">
    <%@ include file="/WEB-INF/views/fragment/navbar.jsp" %>
    <main class="container py-5 flex-grow-1 d-flex align-items-center">
        <div class="row justify-content-center w-100">
            <div class="col-md-7">
                <div class="card p-5 text-center">
                    <i class="bi bi-send-check text-success display-4 mb-3"></i>
                    <h2>Message Sent Successfully</h2>
                    <p class="text-muted">Thanks for reaching out. Our team will review your request and respond as soon as possible.</p>
                    <div class="mt-3">
                        <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-primary px-4">Back to Home</a>
                    </div>
                </div>
            </div>
        </div>
    </main>
    <%@ include file="/WEB-INF/views/fragment/footer.jsp" %>
</body>
</html>
