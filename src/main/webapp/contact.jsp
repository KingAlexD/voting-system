<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="/WEB-INF/views/fragment/head.jsp" %>
</head>
<body class="d-flex flex-column min-vh-100">
    <%@ include file="/WEB-INF/views/fragment/navbar.jsp" %>

    <section class="py-5 bg-primary text-white text-center">
        <div class="container">
            <h1 class="display-4">Get in Touch</h1>
            <p class="lead">Have questions? We're here to help.</p>
        </div>
    </section>

    <div class="container my-5">
        <div class="row g-5">
            <div class="col-lg-4">
                <div class="card border-0 shadow-sm bg-light p-4">
                    <h3>Contact Info</h3>
                    <p><i class="bi bi-geo-alt-fill text-primary me-2"></i> 123 University Way</p>
                    <p><i class="bi bi-envelope-fill text-primary me-2"></i> support@voting.com</p>
                </div>
            </div>

            <div class="col-lg-8">
                <div class="card border-0 shadow-sm p-4">
                    <form action="<%=request.getContextPath()%>/contact" method="POST">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label class="form-label">Full Name</label>
                                <input type="text" name="name" class="form-control" required>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">Email</label>
                                <input type="email" name="email" class="form-control" required>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Message</label>
                            <textarea name="message" class="form-control" rows="4" required></textarea>
                        </div>
                        <button type="submit" class="btn btn-primary px-5">Send Message</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <%@ include file="/WEB-INF/views/fragment/footer.jsp" %>
</body>
</html>