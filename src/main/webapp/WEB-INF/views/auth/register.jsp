<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="/WEB-INF/views/fragment/head.jsp" %>
</head>
<body class="bg-light d-flex flex-column min-vh-100">
    <%@ include file="/WEB-INF/views/fragment/navbar.jsp" %>

    <div class="container py-5">
        <div class="row justify-content-center">
            <div class="col-lg-7">
                <div class="card shadow border-0">
                    <div class="card-body p-5">
                        <h2 class="text-center fw-bold mb-4">Register</h2>
                        <form action="<%=request.getContextPath()%>/register" method="POST">
                            <div class="row g-3 mb-3">
                                <div class="col-md-6"><input type="text" name="firstname" class="form-control" placeholder="First Name" required></div>
                                <div class="col-md-6"><input type="text" name="lastname" class="form-control" placeholder="Last Name" required></div>
                            </div>
                            <div class="mb-3"><input type="email" name="email" class="form-control" placeholder="Email" required></div>
                            <div class="row g-3 mb-3">
                                <div class="col-md-4"><input type="number" name="birthYear" class="form-control" placeholder="Year" required></div>
                                <div class="col-md-4"><input type="text" name="state" class="form-control" placeholder="State" required></div>
                                <div class="col-md-4"><input type="text" name="country" class="form-control" placeholder="Country" required></div>
                            </div>
                            <div class="mb-4"><input type="password" name="password" class="form-control" placeholder="Password" required></div>
                            <button type="submit" class="btn btn-primary w-100">Register Now</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%@ include file="/WEB-INF/views/fragment/footer.jsp" %>
</body>
</html>