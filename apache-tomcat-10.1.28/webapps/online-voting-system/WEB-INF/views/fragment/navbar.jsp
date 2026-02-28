<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<nav class="navbar navbar-expand-lg navbar-dark bg-dark shadow-sm">
  <div class="container">
    <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/index.jsp">
        <i class="bi bi-check2-square me-2"></i>VoteSystem
    </a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarNav">
      <ul class="navbar-nav ms-auto align-items-center">
        <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/index.jsp">Home</a></li>
        <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/about.jsp">About</a></li>
        <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/contact.jsp">Contact</a></li>
        <c:choose>
            <c:when test="${not empty sessionScope.userId}">
                <c:if test="${sessionScope.userRole == 'ADMIN'}">
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/admin/dashboard">Admin</a></li>
                </c:if>
                <c:if test="${sessionScope.userRole != 'ADMIN'}">
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/dashboard">Dashboard</a></li>
                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/profile">Profile</a></li>
                </c:if>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/notifications">
                        <i class="bi bi-bell"></i>
                        <c:if test="${not empty unreadNotificationCount and unreadNotificationCount > 0}">
                            <span class="badge rounded-pill text-bg-danger">${unreadNotificationCount}</span>
                        </c:if>
                    </a>
                </li>
                <li class="nav-item ms-lg-2">
                    <a class="btn btn-outline-light btn-sm px-3" href="${pageContext.request.contextPath}/logout">Logout</a>
                </li>
            </c:when>
            <c:otherwise>
                <li class="nav-item ms-lg-3">
                    <a class="nav-link" href="${pageContext.request.contextPath}/login-view">Login</a>
                </li>
                <li class="nav-item ms-lg-2">
                    <a class="btn btn-primary btn-sm px-3" href="${pageContext.request.contextPath}/register-view">Register</a>
                </li>
            </c:otherwise>
        </c:choose>
      </ul>
    </div>
  </div>
</nav>
