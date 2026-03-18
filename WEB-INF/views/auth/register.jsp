<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register | VoCho</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:ital,wght@0,700;0,800;0,900;1,700;1,900&family=Syne:wght@700;800&family=Epilogue:wght@300;400;500&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/register.css">
</head>
<body>
  <jsp:include page="/WEB-INF/views/fragment/navbar.jsp"/>
  
  <div class= "all">
    <div class="auth-panel-image">
        <div class="bg-img"></div>
        <div class="overlay"></div>
        <div class="grain"></div>
        <div class="ornament"></div>
        <div class="panel-content">
            <h2>Own your<br><em>voice.</em><br>Make your<br><em>choice.</em></h2>
            <p>Join VoCho and become part of a platform where every vote is heard, every opinion matters, and every choice counts.</p>
        </div>
    </div>

    <div class="auth-panel-form">
        <div class="brand">
            <span class="brand-name"><span class="bm">V</span><span class="bt">OCHO</span></span>
        </div>

        <p class="form-eyebrow">Get started</p>
        <h1 class="form-heading">Create account</h1>
        <p class="form-subheading">Register to make your voice heard on VoCho.</p>

        <c:if test="${not empty error}">
            <div class="alert alert-danger">${error}</div>
        </c:if>
        <c:if test="${param.status == 'email_sent'}">
            <div class="alert alert-success">Verification email sent. Check your inbox.</div>
        </c:if>

        <form action="${pageContext.request.contextPath}/register" method="POST">
            <input type="hidden" name="_csrf"
                   value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">

            <div class="field-row">
                <div class="field">
                    <label for="firstName">First Name</label>
                    <input type="text" id="firstName" name="firstName"
                           placeholder="Name" autocomplete="given-name" required>
                </div>
                <div class="field">
                    <label for="lastName">Last Name</label>
                    <input type="text" id="lastName" name="lastName"
                           placeholder="Surname" autocomplete="family-name" required>
                </div>
            </div>

            <div class="field">
                <label for="email">Email Address</label>
                <input type="email" id="email" name="email"
                       placeholder="you@example.com" autocomplete="email" required>
            </div>

            <div class="field-row">
                <div class="field">
                    <label for="birthYear">Birth Year</label>
                    <input type="number" id="birthYear" name="birthYear"
                           placeholder="Must be 18+" min="1900" max="2010" required>
                </div>
                <div class="field">
                    <label for="state">State</label>
                    <input type="text" id="state" name="state"
                           autocomplete="address-level1" required>
                </div>
            </div>

            <div class="divider"></div>

            <div class="field-row">
                <div class="field">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password"
                           placeholder="Min. 8 chars" autocomplete="new-password" required>
                    <span class="hint">At least 8 characters</span>
                </div>
                <div class="field">
                    <label for="confirmPassword">Confirm</label>
                    <input type="password" id="confirmPassword" name="confirmPassword"
                           autocomplete="new-password" required>
                </div>
            </div>

            <button type="submit" class="btn-submit"><span>Create Account</span></button>
        </form>

        <div class="form-links">
            <span></span>
            <span>Already registered? <a href="${pageContext.request.contextPath}/login-view">Sign in</a></span>
        </div>
    </div>
    </div>
    
</body>
</html>
