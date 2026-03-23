<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/views/fragment/head.jsp" />
    <title>Admin Dashboard</title>
</head>
<body class="bg-light">
    <jsp:include page="/WEB-INF/views/fragment/navbar.jsp" />
    <main class="container py-4">
        <div class="d-flex flex-wrap justify-content-between align-items-center mb-3">
            <h3 class="mb-0">Admin Command Center</h3>
            <span class="text-muted">Moderation, analytics, and election governance</span>
        </div>

        <div class="card mb-3">
            <div class="card-body d-flex flex-wrap gap-2 justify-content-between align-items-center">
                <form method="get" action="${pageContext.request.contextPath}/admin/dashboard" class="d-flex gap-2">
                    <input type="text" class="form-control" name="q" placeholder="Search users, contesters, manifesto..." value="${q}">
                    <button class="btn btn-outline-primary" type="submit">Search</button>
                </form>
                <div class="d-flex flex-wrap gap-2">
                    <a class="btn btn-sm btn-outline-secondary" href="${pageContext.request.contextPath}/admin/export?type=users&format=csv">Users CSV</a>
                    <a class="btn btn-sm btn-outline-secondary" href="${pageContext.request.contextPath}/admin/export?type=contesters&format=csv">Contesters CSV</a>
                    <a class="btn btn-sm btn-outline-secondary" href="${pageContext.request.contextPath}/admin/export?type=votes&format=pdf">Votes PDF</a>
                    <a class="btn btn-sm btn-outline-secondary" href="${pageContext.request.contextPath}/admin/export?type=audit&format=pdf">Audit PDF</a>
                </div>
            </div>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-md-3">
                <div class="soft-panel">
                    <p class="section-label mb-1">Registered Users</p>
                    <div class="metric">${statUsers}</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="soft-panel">
                    <p class="section-label mb-1">Pending Approvals</p>
                    <div class="metric">${statPending}</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="soft-panel">
                    <p class="section-label mb-1">Contesters</p>
                    <div class="metric">${statContesters}</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="soft-panel">
                    <p class="section-label mb-1">Votes Cast</p>
                    <div class="metric">${statVotes}</div>
                </div>
            </div>
        </div>

        <div class="card mb-4">
            <div class="card-header bg-white">Pending Contester Requests</div>
            <div class="card-body table-responsive">
                <table class="table align-middle">
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Position</th>
                            <th>Manifesto</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${pendingContesters}" var="c">
                            <tr>
                                <td>${c.user.firstName} ${c.user.lastName}</td>
                                <td>${c.user.email}</td>
                                <td>${c.position}</td>
                                <td style="min-width:260px;" class="text-muted small">${c.manifesto}</td>
                                <td>
                                    <form action="${pageContext.request.contextPath}/admin/contester/decision" method="post" class="d-inline">
                                        <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                                        <input type="hidden" name="contesterId" value="${c.id}">
                                        <input type="hidden" name="action" value="approve">
                                        <button class="btn btn-success btn-sm">Approve</button>
                                    </form>
                                    <form action="${pageContext.request.contextPath}/admin/contester/decision" method="post" class="d-inline">
                                        <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                                        <input type="hidden" name="contesterId" value="${c.id}">
                                        <input type="hidden" name="action" value="deny">
                                        <button class="btn btn-outline-danger btn-sm">Deny</button>
                                    </form>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty pendingContesters}">
                            <tr><td colspan="5" class="text-muted">No pending applications.</td></tr>
                        </c:if>
                    </tbody>
                </table>
                <div class="d-flex justify-content-end gap-2">
                    <a class="btn btn-sm btn-outline-secondary ${usersPage <= 1 ? 'disabled' : ''}" href="${pageContext.request.contextPath}/admin/dashboard?q=${q}&usersPage=${usersPage - 1}&contestersPage=${contestersPage}&votesPage=${votesPage}&auditPage=${auditPage}">Prev</a>
                    <span class="align-self-center small text-muted">Users page ${usersPage} / ${usersTotalPages}</span>
                    <a class="btn btn-sm btn-outline-secondary ${usersPage >= usersTotalPages ? 'disabled' : ''}" href="${pageContext.request.contextPath}/admin/dashboard?q=${q}&usersPage=${usersPage + 1}&contestersPage=${contestersPage}&votesPage=${votesPage}&auditPage=${auditPage}">Next</a>
                </div>
            </div>
        </div>

        <div class="card mb-4">
            <div class="card-header bg-white">Registered Users</div>
            <div class="card-body table-responsive">
                <table class="table table-sm">
                    <thead><tr><th>Name</th><th>Email</th><th>Role</th><th>Birth Year</th><th>Verified</th></tr></thead>
                    <tbody>
                        <c:forEach items="${allUsers}" var="u">
                            <tr>
                                <td>${u.firstName} ${u.lastName}</td>
                                <td>${u.email}</td>
                                <td>${u.role}</td>
                                <td>${u.birthYear}</td>
                                <td>${u.emailVerified}</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
                <div class="d-flex justify-content-end gap-2">
                    <a class="btn btn-sm btn-outline-secondary ${contestersPage <= 1 ? 'disabled' : ''}" href="${pageContext.request.contextPath}/admin/dashboard?q=${q}&usersPage=${usersPage}&contestersPage=${contestersPage - 1}&votesPage=${votesPage}&auditPage=${auditPage}">Prev</a>
                    <span class="align-self-center small text-muted">Contesters page ${contestersPage} / ${contestersTotalPages}</span>
                    <a class="btn btn-sm btn-outline-secondary ${contestersPage >= contestersTotalPages ? 'disabled' : ''}" href="${pageContext.request.contextPath}/admin/dashboard?q=${q}&usersPage=${usersPage}&contestersPage=${contestersPage + 1}&votesPage=${votesPage}&auditPage=${auditPage}">Next</a>
                </div>
            </div>
        </div>

        <div class="card mb-4">
            <div class="card-header bg-white">Contesters and Votes</div>
            <div class="card-body table-responsive">
                <table class="table table-sm">
                    <thead><tr><th>Name</th><th>Position</th><th>Status</th><th>Votes</th><th>Manifesto</th></tr></thead>
                    <tbody>
                        <c:forEach items="${allContesters}" var="c">
                            <tr>
                                <td>${c.user.firstName} ${c.user.lastName}</td>
                                <td>${c.position}</td>
                                <td>${c.status}</td>
                                <td>${voteCounts[c.id] == null ? 0 : voteCounts[c.id]}</td>
                                <td style="min-width:260px;" class="text-muted small">${c.manifesto}</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
                <div class="d-flex justify-content-end gap-2">
                    <a class="btn btn-sm btn-outline-secondary ${votesPage <= 1 ? 'disabled' : ''}" href="${pageContext.request.contextPath}/admin/dashboard?q=${q}&usersPage=${usersPage}&contestersPage=${contestersPage}&votesPage=${votesPage - 1}&auditPage=${auditPage}">Prev</a>
                    <span class="align-self-center small text-muted">Votes page ${votesPage} / ${votesTotalPages}</span>
                    <a class="btn btn-sm btn-outline-secondary ${votesPage >= votesTotalPages ? 'disabled' : ''}" href="${pageContext.request.contextPath}/admin/dashboard?q=${q}&usersPage=${usersPage}&contestersPage=${contestersPage}&votesPage=${votesPage + 1}&auditPage=${auditPage}">Next</a>
                </div>
            </div>
        </div>

        <div class="card mb-4">
            <div class="card-header bg-white">Vote Audit List</div>
            <div class="card-body table-responsive">
                <table class="table table-sm">
                    <thead><tr><th>Voter</th><th>Contester</th><th>Position</th></tr></thead>
                    <tbody>
                        <c:forEach items="${voteRows}" var="v">
                            <tr>
                                <td>${v.voter.firstName} ${v.voter.lastName}</td>
                                <td>${v.contester.user.firstName} ${v.contester.user.lastName}</td>
                                <td>${v.contester.position}</td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty voteRows}">
                            <tr><td colspan="3" class="text-muted">No votes cast yet.</td></tr>
                        </c:if>
                    </tbody>
                </table>
                <div class="d-flex justify-content-end gap-2">
                    <a class="btn btn-sm btn-outline-secondary ${auditPage <= 1 ? 'disabled' : ''}" href="${pageContext.request.contextPath}/admin/dashboard?q=${q}&usersPage=${usersPage}&contestersPage=${contestersPage}&votesPage=${votesPage}&auditPage=${auditPage - 1}">Prev</a>
                    <span class="align-self-center small text-muted">Audit page ${auditPage} / ${auditTotalPages}</span>
                    <a class="btn btn-sm btn-outline-secondary ${auditPage >= auditTotalPages ? 'disabled' : ''}" href="${pageContext.request.contextPath}/admin/dashboard?q=${q}&usersPage=${usersPage}&contestersPage=${contestersPage}&votesPage=${votesPage}&auditPage=${auditPage + 1}">Next</a>
                </div>
            </div>
        </div>

        <div class="card">
            <div class="card-header bg-white">Recent Admin Action Logs</div>
            <div class="card-body table-responsive">
                <table class="table table-sm">
                    <thead><tr><th>When</th><th>Admin</th><th>Action</th><th>Detail</th></tr></thead>
                    <tbody>
                        <c:forEach items="${auditLogs}" var="log">
                            <tr>
                                <td>${log.createdAt}</td>
                                <td>${log.adminUser.email}</td>
                                <td>${log.actionType}</td>
                                <td>${log.actionDetail}</td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty auditLogs}">
                            <tr><td colspan="4" class="text-muted">No admin actions logged yet.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
    <jsp:include page="/WEB-INF/views/fragment/footer.jsp" />
</body>
</html>
