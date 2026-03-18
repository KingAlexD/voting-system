<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile | VoCho</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:ital,wght@0,700;0,800;0,900;1,700;1,900&family=Syne:wght@700;800&family=Epilogue:wght@300;400;500&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/auth-pages.css">
</head>
<body>
    <jsp:include page="/WEB-INF/views/fragment/navbar.jsp" />

    <main class="profile-page">

        <!-- ── Header ──────────────────────────────────────────── -->
        <div class="profile-header">
            <p class="profile-eyebrow">My Account</p>
            <h1 class="profile-title">
                <em>${currentUser.firstName}</em> ${currentUser.lastName}
            </h1>
            <p class="profile-subtitle">${currentUser.email}</p>
        </div>

        <!-- ── Feedback alerts ──────────────────────────────────── -->
        <c:if test="${param.status == 'updated'}">
            <div class="pf-alert pf-alert--success" style="margin-bottom:28px;">
                Profile updated successfully.
            </div>
        </c:if>
        <c:if test="${not empty param.error}">
            <div class="pf-alert pf-alert--error" style="margin-bottom:28px;">
                <c:choose>
                    <c:when test="${param.error == 'wrong_password'}">Current password is incorrect.</c:when>
                    <c:when test="${param.error == 'password_mismatch'}">New passwords do not match.</c:when>
                    <c:when test="${param.error == 'password_too_short'}">New password must be at least 8 characters.</c:when>
                    <c:otherwise>Update failed. Please try again.</c:otherwise>
                </c:choose>
            </div>
        </c:if>

        <!-- ── Two-column grid ──────────────────────────────────── -->
        <div class="profile-grid">

            <!-- Personal Information -->
            <div class="vo-card">
                <div class="vo-card__head">
                    <span class="vo-card__title">Personal Info</span>
                </div>
                <div class="vo-card__body">
                    <form action="${pageContext.request.contextPath}/profile" method="POST">
                        <input type="hidden" name="_csrf"
                               value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                        <input type="hidden" name="action" value="updateInfo">

                        <label class="pf-label" for="firstName">First Name</label>
                        <input class="pf-input" id="firstName" name="firstName"
                               type="text" value="${currentUser.firstName}" required>

                        <label class="pf-label" for="lastName">Last Name</label>
                        <input class="pf-input" id="lastName" name="lastName"
                               type="text" value="${currentUser.lastName}" required>

                        <label class="pf-label" for="state">State</label>
                        <input class="pf-input" id="state" name="state"
                               type="text" value="${currentUser.state}" required>

                        <label class="pf-label" for="country">Country</label>
                        <input class="pf-input" id="country" name="country"
                               type="text" value="${currentUser.country}" required>

                        <button class="pf-btn" type="submit">Save Changes</button>
                    </form>
                </div>
            </div>

            <!-- Change Password -->
            <div class="vo-card">
                <div class="vo-card__head">
                    <span class="vo-card__title">Change Password</span>
                </div>
                <div class="vo-card__body">
                    <form action="${pageContext.request.contextPath}/profile" method="POST">
                        <input type="hidden" name="_csrf"
                               value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                        <input type="hidden" name="action" value="changePassword">

                        <label class="pf-label" for="currentPassword">Current Password</label>
                        <input class="pf-input" id="currentPassword" name="currentPassword"
                               type="password" placeholder="Enter current password"
                               autocomplete="current-password" required>

                        <label class="pf-label" for="newPassword">New Password</label>
                        <input class="pf-input" id="newPassword" name="newPassword"
                               type="password" placeholder="Min. 8 characters"
                               minlength="8" autocomplete="new-password" required>

                        <label class="pf-label" for="confirmPassword">Confirm New Password</label>
                        <input class="pf-input" id="confirmPassword" name="confirmPassword"
                               type="password" placeholder="Repeat new password"
                               minlength="8" autocomplete="new-password" required>

                        <button class="pf-btn" type="submit">Update Password</button>
                    </form>
                </div>
            </div>

        </div>
    </main>

    <jsp:include page="/WEB-INF/views/fragment/footer.jsp" />
</body>
</html>
