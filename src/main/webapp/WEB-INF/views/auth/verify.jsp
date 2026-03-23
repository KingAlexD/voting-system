<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="/WEB-INF/views/fragment/head.jsp" %>
    <style>
        .code-input {
            letter-spacing: 1rem;
            font-size: 2rem;
            text-align: center;
            font-weight: bold;
        }
    </style>
</head>
<body class="bg-light d-flex flex-column min-vh-100">
    <%@ include file="/WEB-INF/views/fragment/navbar.jsp" %>

    <div class="container py-5 flex-grow-1 d-flex align-items-center">
        <div class="row justify-content-center w-100">
            <div class="col-md-6 col-lg-5">
                <div class="card shadow border-0 text-center">
                    <div class="card-body p-5">
                        <i class="bi bi-shield-check text-success display-1 mb-3"></i>
                        <h3 class="fw-bold">Verify Identity</h3>
                        <p class="text-muted mb-4">Enter the 6-digit code sent to your email to activate your account.</p>

                        <form action="<%=request.getContextPath()%>/verify" method="POST">
                            <div class="mb-4">
                                <input type="text" name="code" class="form-control code-input" 
                                       placeholder="000000" maxlength="6" pattern="\d{6}" required>
                            </div>
                            <button type="submit" class="btn btn-success w-100 py-2 fw-bold">VERIFY ACCOUNT</button>
                        </form>

                        <p class="mt-4 small text-muted">
                            Didn't get a code? <a href="#" class="text-decoration-none">Resend</a>
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%@ include file="/WEB-INF/views/fragment/footer.jsp" %>
</body>
</html>