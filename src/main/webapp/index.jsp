<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <%@ include file="/WEB-INF/views/fragment/head.jsp" %>
</head>
<body>
<%@ include file="/WEB-INF/views/fragment/navbar.jsp" %>
<div class="container mt-5 text-center">
    <h1>Welcome to the Online Voting System</h1>
    <p class="lead">
        Secure, transparent, and reliable voting platform.
    </p>

    <a href="#" class="btn btn-primary m-2">Login</a>
    <a href="#" class="btn btn-success m-2">Register</a>
</div>
<%@ include file="/WEB-INF/views/fragment/footer.jsp" %>
</body>
</html>
