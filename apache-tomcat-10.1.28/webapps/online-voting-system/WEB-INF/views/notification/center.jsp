<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/views/fragment/head.jsp" />
    <title>Notifications</title>
</head>
<body class="bg-light">
    <jsp:include page="/WEB-INF/views/fragment/navbar.jsp" />
    <main class="container py-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h3 class="mb-0">Notification Center</h3>
            <form action="${pageContext.request.contextPath}/notifications" method="post">
                <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                <button class="btn btn-outline-primary btn-sm" type="submit">Mark all as read</button>
            </form>
        </div>

        <c:if test="${param.status == 'read'}">
            <div class="alert alert-success">All notifications marked as read.</div>
        </c:if>

        <div class="card">
            <div class="card-body">
                <c:if test="${empty notifications}">
                    <p class="text-muted mb-0">No notifications yet.</p>
                </c:if>
                <c:forEach items="${notifications}" var="n">
                    <div class="border rounded p-3 mb-2 ${n.read ? 'bg-white' : 'bg-light'}">
                        <div class="d-flex justify-content-between align-items-center">
                            <h6 class="mb-1">${n.title}</h6>
                            <small class="text-muted">${n.createdAt}</small>
                        </div>
                        <p class="mb-2 text-muted">${n.message}</p>
                        <c:if test="${not empty n.link}">
                            <a class="btn btn-sm btn-outline-secondary" href="${pageContext.request.contextPath}${n.link}">Open</a>
                        </c:if>
                    </div>
                </c:forEach>
            </div>
        </div>
    </main>
    <jsp:include page="/WEB-INF/views/fragment/footer.jsp" />
</body>
</html>
