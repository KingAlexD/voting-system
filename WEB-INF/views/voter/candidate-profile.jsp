<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${contester.user.firstName} ${contester.user.lastName} | VoCho</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:ital,wght@0,700;0,800;0,900;1,700;1,900&family=Syne:wght@700;800&family=Epilogue:wght@300;400;500&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/auth-pages.css">
</head>
<body>
    <jsp:include page="/WEB-INF/views/fragment/navbar.jsp" />

    <main class="candidate-page">

        <div class="candidate-card">

            <div class="candidate-card__top">
                <span class="candidate-eyebrow">Candidate Profile</span>
                <h1 class="candidate-name">
                    ${contester.user.firstName}<br>${contester.user.lastName}
                </h1>
                <div class="candidate-meta">
                    <span class="candidate-badge candidate-badge--position">${contester.position}</span>
                    <span class="candidate-badge candidate-badge--status">${contester.status}</span>
                </div>
            </div>

            <div class="candidate-card__body">

                <span class="manifesto-label">Manifesto</span>
                <p class="manifesto-text">
                    <c:choose>
                        <c:when test="${not empty contester.manifesto}">${contester.manifesto}</c:when>
                        <c:otherwise>No manifesto provided.</c:otherwise>
                    </c:choose>
                </p>

                <div class="votes-block">
                    <span class="votes-num">${votes}</span>
                    <span class="votes-label">Votes<br>Received</span>
                </div>

                <a class="btn-back" href="${pageContext.request.contextPath}/dashboard">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
                         stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M19 12H5M12 19l-7-7 7-7"/>
                    </svg>
                    Back to Dashboard
                </a>

            </div>
        </div>

    </main>

    <jsp:include page="/WEB-INF/views/fragment/footer.jsp" />
</body>
</html>
