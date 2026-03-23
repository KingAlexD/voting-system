<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/views/fragment/head.jsp" />
    <title>Online Voting System | Home</title>
</head>
<body>
    <jsp:include page="/WEB-INF/views/fragment/navbar.jsp" />

    <div class="container mt-5">
        <div class="jumbotron text-center">
            <h1>Your Voice, Your Vote</h1>
            <p class="lead">Secure, Transparent, and Easy. Join the future of democracy today.</p>
            <hr class="my-4">
            <div class="d-flex justify-content-center gap-3">
                <a class="btn btn-primary btn-lg" href="auth/register.jsp" role="button">Register to Vote</a>
                <a class="btn btn-outline-secondary btn-lg" href="auth/login.jsp" role="button">Login</a>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/views/fragment/footer.jsp" />
</body>
</html>