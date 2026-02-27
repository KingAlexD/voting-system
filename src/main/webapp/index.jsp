<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/views/fragment/head.jsp" />
    <title>Votely | Secure Online Voting</title>
</head>
<body>
    <jsp:include page="/WEB-INF/views/fragment/navbar.jsp" />

    <header class="bg-primary text-white text-center py-5">
        <div class="container">
            <h1 class="display-3 fw-bold">Every Vote Counts.</h1>
            <p class="lead">A secure, transparent platform for the next generation of leadership.</p>
            <div class="mt-4">
                <a href="auth/register.jsp" class="btn btn-light btn-lg px-4 me-2">Get Started</a>
                <a href="about.jsp" class="btn btn-outline-light btn-lg px-4">Learn More</a>
            </div>
        </div>
    </header>

    <section class="py-5">
        <div class="container text-center">
            <div class="row">
                <div class="col-md-4">
                    <h3>Secure</h3>
                    <p>Encrypted data ensures your vote remains private and tamper-proof.</p>
                </div>
                <div class="col-md-4">
                    <h3>Simple</h3>
                    <p>Vote from any device, anywhere in the world, in just three clicks.</p>
                </div>
                <div class="col-md-4">
                    <h3>Transparent</h3>
                    <p>Real-time results you can trust, powered by modern backend logic.</p>
                </div>
            </div>
        </div>
    </section>

    <jsp:include page="/WEB-INF/views/fragment/footer.jsp" />
</body>
</html>