<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/views/fragment/head.jsp" />
    <title>Voter Dashboard</title>
</head>
<body class="bg-light">
    <jsp:include page="/WEB-INF/views/fragment/navbar.jsp" />
    <main class="container py-4">
        <c:if test="${not empty param.error}">
            <div class="alert alert-danger">
                <c:choose>
                    <c:when test="${param.error == 'already_voted'}">You have already cast your vote.</c:when>
                    <c:when test="${param.error == 'position_full'}">That position already has the maximum of 3 approved contesters.</c:when>
                    <c:when test="${param.error == 'application_exists'}">You already have a contester application.</c:when>
                    <c:when test="${param.error == 'voting_closed'}">Voting and contest applications are closed due to deadline.</c:when>
                    <c:when test="${param.error == 'election_not_open'}">Election is not in OPEN phase.</c:when>
                    <c:when test="${param.error == 'underage'}">You must be 18+ to vote or contest.</c:when>
                    <c:when test="${param.error == 'manifesto_required'}">Manifesto must be at least 20 characters.</c:when>
                    <c:otherwise>Action failed.</c:otherwise>
                </c:choose>
            </div>
        </c:if>
        <c:if test="${not empty param.status}">
            <div class="alert alert-success">
                <c:choose>
                    <c:when test="${param.status == 'application_submitted'}">Contester application submitted.</c:when>
                    <c:otherwise>Operation successful.</c:otherwise>
                </c:choose>
            </div>
        </c:if>

        <div class="row g-3 mb-4">
            <div class="col-md-3">
                <div class="soft-panel">
                    <p class="section-label mb-1">Eligibility</p>
                    <div class="metric">${isAdult ? '18+ Verified' : 'Under 18'}</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="soft-panel">
                    <p class="section-label mb-1">Voting Deadline</p>
                    <div class="metric" style="font-size:1.15rem;">${votingDeadline}</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="soft-panel">
                    <p class="section-label mb-1">Election Phase</p>
                    <div class="metric" style="font-size:1.15rem;">${electionPhase}</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="soft-panel">
                    <p class="section-label mb-1">Approved Contesters</p>
                    <div class="metric">${approvedContesters.size()}</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="soft-panel">
                    <p class="section-label mb-1">Total Votes</p>
                    <div class="metric">${totalVotes}</div>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <div class="col-lg-4">
                <div class="card mb-3">
                    <div class="card-body">
                        <h4 class="mb-1">${currentUser.firstName} ${currentUser.lastName}</h4>
                        <p class="text-muted mb-3">${currentUser.email}</p>
                        <div class="soft-panel mb-2"><strong>Role:</strong> ${currentUser.role}</div>
                        <div class="soft-panel mb-2"><strong>Verified:</strong> ${currentUser.emailVerified}</div>
                        <div class="soft-panel mb-3"><strong>Status:</strong> ${isAdult ? 'Can vote/contest' : 'Can only view for now'}</div>
                        <a class="btn btn-outline-primary w-100" href="${pageContext.request.contextPath}/profile">Manage Profile</a>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header bg-white">Contester Application</div>
                    <div class="card-body">
                        <c:choose>
                            <c:when test="${not empty myContesterApplication}">
                                <p class="mb-1">Status: <strong>${myContesterApplication.status}</strong></p>
                                <p class="mb-1">Position: <strong>${myContesterApplication.position}</strong></p>
                                <p class="mb-0 text-muted small">${myContesterApplication.manifesto}</p>
                            </c:when>
                            <c:otherwise>
                                <form action="${pageContext.request.contextPath}/contester/apply" method="post">
                                    <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                                    <div class="mb-2">
                                        <select name="position" class="form-select" required ${votingClosed || !isAdult || electionPhase != 'OPEN' ? 'disabled' : ''}>
                                            <option value="">Select position</option>
                                            <c:forEach items="${positions}" var="position">
                                                <option value="${position}">${position}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="mb-2">
                                        <textarea class="form-control" name="manifesto" rows="4" minlength="20" maxlength="2000"
                                                  placeholder="Share your core agenda and priorities..." required ${votingClosed || !isAdult || electionPhase != 'OPEN' ? 'disabled' : ''}></textarea>
                                    </div>
                                    <button type="submit" class="btn btn-primary w-100" ${votingClosed || !isAdult || electionPhase != 'OPEN' ? 'disabled' : ''}>Apply as Contester</button>
                                </form>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>

            <div class="col-lg-8">
                <div class="card">
                    <div class="card-header bg-white d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">Approved Contesters & Manifestos</h5>
                        <span class="badge text-bg-dark">${approvedContesters.size()} candidates</span>
                    </div>
                    <div class="card-body">
                        <c:if test="${empty approvedContesters}">
                            <p class="text-muted mb-0">No approved contesters yet.</p>
                        </c:if>
                        <c:if test="${not empty approvedContesters}">
                            <form action="${pageContext.request.contextPath}/vote" method="post">
                                <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                                <div class="list-group mb-3">
                                    <c:forEach items="${approvedContesters}" var="c">
                                        <label class="list-group-item">
                                            <div class="d-flex justify-content-between align-items-start gap-3">
                                                <div>
                                                    <input class="form-check-input me-2" type="radio" name="contesterId" value="${c.id}" ${hasVoted || votingClosed || !isAdult || electionPhase != 'OPEN' ? 'disabled' : ''} required>
                                                    <strong><a href="${pageContext.request.contextPath}/candidate-profile?id=${c.id}" class="text-decoration-none">${c.user.firstName} ${c.user.lastName}</a></strong>
                                                    <span class="badge text-bg-secondary ms-2">${c.position}</span>
                                                    <p class="text-muted small mt-2 mb-0">${c.manifesto}</p>
                                                </div>
                                                <span class="badge text-bg-primary">Votes: ${voteCounts[c.id] == null ? 0 : voteCounts[c.id]}</span>
                                            </div>
                                        </label>
                                    </c:forEach>
                                </div>
                                <button type="submit" class="btn btn-success" ${hasVoted || votingClosed || !isAdult || electionPhase != 'OPEN' ? 'disabled' : ''}>Cast Vote</button>
                                <c:if test="${hasVoted}">
                                    <span class="ms-2 text-success fw-semibold">You already voted.</span>
                                </c:if>
                                <c:if test="${!isAdult}">
                                    <span class="ms-2 text-danger fw-semibold">Voting unlocks at age 18.</span>
                                </c:if>
                                <c:if test="${votingClosed}">
                                    <span class="ms-2 text-danger fw-semibold">Voting has closed.</span>
                                </c:if>
                                <c:if test="${electionPhase != 'OPEN'}">
                                    <span class="ms-2 text-danger fw-semibold">Election phase is ${electionPhase}.</span>
                                </c:if>
                            </form>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
    </main>
    <jsp:include page="/WEB-INF/views/fragment/footer.jsp" />
</body>
</html>
