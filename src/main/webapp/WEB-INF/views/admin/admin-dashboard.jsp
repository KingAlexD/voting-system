<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Admin Dashboard | VoCho</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:ital,wght@0,700;0,800;0,900;1,700;1,900&family=Syne:wght@700;800&family=Epilogue:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
</head>
<body>
  <jsp:include page="/WEB-INF/views/fragment/navbar.jsp" />

  <div class="dash-page">

    <div class="dash-header">
      <p class="dash-eyebrow">Admin Panel</p>
      <h1 class="dash-title">Command <em>Center</em></h1>
      <p class="dash-subtitle">Moderation, analytics &amp; election governance</p>
    </div>

    <div class="vo-card" style="margin-bottom:24px;">
      <div class="vo-card__body" style="padding:16px 24px;">
        <div style="display:flex;flex-wrap:wrap;gap:12px;align-items:center;justify-content:space-between;">
          <form method="get" action="${pageContext.request.contextPath}/admin/dashboard"
                style="display:flex;gap:10px;flex:1;min-width:240px;">
            <input type="text" name="q" class="vo-input" style="flex:1;"
                   placeholder="Search users, contesters, manifesto..." value="${q}">
            <button type="submit" class="vo-btn vo-btn--ghost">Search</button>
          </form>
          <div style="display:flex;flex-wrap:wrap;gap:8px;">
            <a class="vo-btn vo-btn--ghost vo-btn--sm" href="${pageContext.request.contextPath}/admin/export?type=users&format=csv">Users CSV</a>
            <a class="vo-btn vo-btn--ghost vo-btn--sm" href="${pageContext.request.contextPath}/admin/export?type=contesters&format=csv">Contesters CSV</a>
            <a class="vo-btn vo-btn--ghost vo-btn--sm" href="${pageContext.request.contextPath}/admin/export?type=votes&format=pdf">Votes PDF</a>
            <a class="vo-btn vo-btn--ghost vo-btn--sm" href="${pageContext.request.contextPath}/admin/export?type=audit&format=pdf">Audit PDF</a>
          </div>
        </div>
      </div>
    </div>

    <%-- Stat tiles --%>
    <div class="stat-row">
      <div class="stat-tile">
        <div class="stat-tile__label">Registered Users</div>
        <div class="stat-tile__value gold">${statUsers}</div>
      </div>
      <div class="stat-tile">
        <div class="stat-tile__label">Pending Approvals</div>
        <div class="stat-tile__value ${statPending > 0 ? 'coral' : ''}">${statPending}</div>
      </div>
      <div class="stat-tile">
        <div class="stat-tile__label">Contesters</div>
        <div class="stat-tile__value">${statContesters}</div>
      </div>
      <div class="stat-tile">
        <div class="stat-tile__label">Votes Cast</div>
        <div class="stat-tile__value gold">${statVotes}</div>
      </div>
    </div>

    <%-- LIVE RESULTS (replaces chart) --%>
    <div class="vo-card">
      <div class="vo-card__head">
        <span class="vo-card__title">Live Results</span>
        <div style="display:flex;align-items:center;gap:8px;">
          <div class="live-dot"></div>
          <span style="font-family:'Syne',sans-serif;font-size:.62rem;font-weight:800;letter-spacing:.14em;text-transform:uppercase;color:rgba(234,228,214,.4);">Live</span>
        </div>
      </div>
      <div class="vo-card__body" id="liveResultsBody">
        <div style="text-align:center;padding:24px;color:rgba(234,228,214,.3);font-family:'Syne',sans-serif;font-size:.75rem;letter-spacing:.1em;text-transform:uppercase;">
          Loading...
        </div>
      </div>
    </div>

    <%-- Pending Applications --%>
    <div class="vo-card">
      <div class="vo-card__head">
        <span class="vo-card__title">Pending Applications</span>
        <span class="vo-badge vo-badge--pending">${pendingContesters.size()} pending</span>
      </div>
      <div class="vo-card__body--flush">
        <c:if test="${empty pendingContesters}">
          <p style="padding:20px 24px;color:rgba(234,228,214,.35);font-size:.84rem;">No pending applications.</p>
        </c:if>
        <c:if test="${not empty pendingContesters}">
          <table class="vo-table">
            <thead><tr><th>Name</th><th>Email</th><th>Position</th><th>Manifesto</th><th>Actions</th></tr></thead>
            <tbody>
              <c:forEach items="${pendingContesters}" var="c">
                <tr>
                  <td><strong>${c.user.firstName} ${c.user.lastName}</strong></td>
                  <td>${c.user.email}</td>
                  <td><span class="vo-badge vo-badge--cream">${c.position}</span></td>
                  <td style="max-width:240px;">${c.manifesto}</td>
                  <td>
                    <div style="display:flex;gap:6px;">
                      <form action="${pageContext.request.contextPath}/admin/contester/decision" method="post" style="display:inline;">
                        <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                        <input type="hidden" name="contesterId" value="${c.id}">
                        <input type="hidden" name="action" value="approve">
                        <button type="submit" class="vo-btn vo-btn--gold vo-btn--sm">Approve</button>
                      </form>
                      <form action="${pageContext.request.contextPath}/admin/contester/decision" method="post" style="display:inline;">
                        <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                        <input type="hidden" name="contesterId" value="${c.id}">
                        <input type="hidden" name="action" value="deny">
                        <button type="submit" class="vo-btn vo-btn--danger-ghost vo-btn--sm">Deny</button>
                      </form>
                    </div>
                  </td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </c:if>
      </div>
    </div>

    <%-- Position Change Requests --%>
    <div class="vo-card">
      <div class="vo-card__head">
        <span class="vo-card__title">Position Change Requests</span>
        <span class="vo-badge vo-badge--pending">${positionChangeRequests.size()} pending</span>
      </div>
      <div class="vo-card__body--flush">
        <c:if test="${empty positionChangeRequests}">
          <p style="padding:20px 24px;color:rgba(234,228,214,.35);font-size:.84rem;">No pending position change requests.</p>
        </c:if>
        <c:if test="${not empty positionChangeRequests}">
          <table class="vo-table">
            <thead><tr><th>Contester</th><th>Current</th><th>Requested</th><th>Actions</th></tr></thead>
            <tbody>
              <c:forEach items="${positionChangeRequests}" var="c">
                <tr>
                  <td><strong>${c.user.firstName} ${c.user.lastName}</strong><br><span style="font-size:.78rem;color:rgba(234,228,214,.4);">${c.user.email}</span></td>
                  <td><span class="vo-badge vo-badge--cream">${c.position}</span></td>
                  <td><span class="vo-badge vo-badge--gold">${c.requestedPosition}</span></td>
                  <td>
                    <div style="display:flex;gap:6px;">
                      <form action="${pageContext.request.contextPath}/admin/contester/decision" method="post">
                        <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                        <input type="hidden" name="contesterId" value="${c.id}">
                        <input type="hidden" name="action" value="approve-position">
                        <button type="submit" class="vo-btn vo-btn--gold vo-btn--sm">Approve</button>
                      </form>
                      <form action="${pageContext.request.contextPath}/admin/contester/decision" method="post">
                        <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                        <input type="hidden" name="contesterId" value="${c.id}">
                        <input type="hidden" name="action" value="deny-position">
                        <button type="submit" class="vo-btn vo-btn--danger-ghost vo-btn--sm">Deny</button>
                      </form>
                    </div>
                  </td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </c:if>
      </div>
    </div>

    <%-- All Users --%>
    <div class="vo-card">
      <div class="vo-card__head"><span class="vo-card__title">Registered Users</span></div>
      <div class="vo-card__body--flush">
        <table class="vo-table">
          <thead><tr><th>#</th><th>Name</th><th>Email</th><th>Role</th><th>Verified</th><th>Actions</th></tr></thead>
          <tbody>
            <c:forEach items="${allUsers}" var="u">
              <tr>
                <td style="color:rgba(234,228,214,.3);font-size:.78rem;">${u.id}</td>
                <td>
                  <strong>${u.firstName} ${u.lastName}</strong>
                  <c:if test="${u.suspended}"><span class="vo-badge vo-badge--red" style="margin-left:6px;">Suspended</span></c:if>
                </td>
                <td>${u.email}</td>
                <td><span class="vo-badge vo-badge--${u.role == 'ADMIN' ? 'gold' : (u.role == 'CONTESTER' ? 'coral' : 'cream')}">${u.role}</span></td>
                <td>${u.emailVerified}</td>
                <td>
                  <div style="display:flex;gap:6px;flex-wrap:wrap;">
                    <form action="${pageContext.request.contextPath}/admin/contester/decision" method="post" style="display:inline;">
                      <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                      <input type="hidden" name="userId" value="${u.id}">
                      <input type="hidden" name="action" value="${u.suspended ? 'unsuspend' : 'suspend'}">
                      <button type="submit" class="vo-btn ${u.suspended ? 'vo-btn--gold' : 'vo-btn--danger-ghost'} vo-btn--sm"
                              onclick="return confirm('${u.suspended ? 'Restore' : 'Suspend'} this user?')">
                        ${u.suspended ? 'Restore' : 'Suspend'}
                      </button>
                    </form>
                    <c:if test="${u.role == 'VOTER'}">
                      <form action="${pageContext.request.contextPath}/admin/contester/decision" method="post" style="display:inline;">
                        <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                        <input type="hidden" name="userId" value="${u.id}">
                        <input type="hidden" name="action" value="promote">
                        <button type="submit" class="vo-btn vo-btn--ghost vo-btn--sm"
                                onclick="return confirm('Promote to CONTESTER? Requires an approved application.')">Promote</button>
                      </form>
                    </c:if>
                    <c:if test="${u.role == 'CONTESTER'}">
                      <form action="${pageContext.request.contextPath}/admin/contester/decision" method="post" style="display:inline;">
                        <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                        <input type="hidden" name="userId" value="${u.id}">
                        <input type="hidden" name="action" value="demote">
                        <button type="submit" class="vo-btn vo-btn--ghost vo-btn--sm"
                                onclick="return confirm('Demote to VOTER? Resets vote count.')">Demote</button>
                      </form>
                    </c:if>
                  </div>
                </td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
        <div class="vo-pagination">
          <a class="vo-btn vo-btn--ghost vo-btn--sm ${usersPage <= 1 ? 'disabled' : ''}"
             href="${pageContext.request.contextPath}/admin/dashboard?q=${q}&usersPage=${usersPage-1}&contestersPage=${contestersPage}&votesPage=${votesPage}&auditPage=${auditPage}">&#8592;</a>
          <span>Page ${usersPage} / ${usersTotalPages}</span>
          <a class="vo-btn vo-btn--ghost vo-btn--sm ${usersPage >= usersTotalPages ? 'disabled' : ''}"
             href="${pageContext.request.contextPath}/admin/dashboard?q=${q}&usersPage=${usersPage+1}&contestersPage=${contestersPage}&votesPage=${votesPage}&auditPage=${auditPage}">&#8594;</a>
        </div>
      </div>
    </div>

    <%-- Contesters --%>
    <div class="vo-card">
      <div class="vo-card__head"><span class="vo-card__title">Contesters &amp; Votes</span></div>
      <div class="vo-card__body--flush">
        <table class="vo-table">
          <thead><tr><th>Name</th><th>Position</th><th>Status</th><th>Votes</th><th>Manifesto</th></tr></thead>
          <tbody>
            <c:forEach items="${allContesters}" var="c">
              <tr>
                <td><strong>${c.user.firstName} ${c.user.lastName}</strong></td>
                <td><span class="vo-badge vo-badge--cream">${c.position}</span></td>
                <td><span class="vo-badge vo-badge--${c.status == 'APPROVED' ? 'green' : (c.status == 'PENDING' ? 'pending' : 'red')}">${c.status}</span></td>
                <td style="font-family:'Barlow Condensed',sans-serif;font-size:1.2rem;font-weight:900;color:#d4a843;">${voteCounts[c.id] == null ? 0 : voteCounts[c.id]}</td>
                <td style="max-width:260px;">${c.manifesto}</td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
        <div class="vo-pagination">
          <a class="vo-btn vo-btn--ghost vo-btn--sm ${contestersPage <= 1 ? 'disabled' : ''}"
             href="${pageContext.request.contextPath}/admin/dashboard?q=${q}&usersPage=${usersPage}&contestersPage=${contestersPage-1}&votesPage=${votesPage}&auditPage=${auditPage}">&#8592;</a>
          <span>Page ${contestersPage} / ${contestersTotalPages}</span>
          <a class="vo-btn vo-btn--ghost vo-btn--sm ${contestersPage >= contestersTotalPages ? 'disabled' : ''}"
             href="${pageContext.request.contextPath}/admin/dashboard?q=${q}&usersPage=${usersPage}&contestersPage=${contestersPage+1}&votesPage=${votesPage}&auditPage=${auditPage}">&#8594;</a>
        </div>
      </div>
    </div>

    <%-- Vote Audit --%>
    <div class="vo-card">
      <div class="vo-card__head"><span class="vo-card__title">Vote Audit</span></div>
      <div class="vo-card__body--flush">
        <table class="vo-table">
          <thead><tr><th>Voter</th><th>Contester</th><th>Position</th></tr></thead>
          <tbody>
            <c:forEach items="${voteRows}" var="v">
              <tr>
                <td>${v.voter.firstName} ${v.voter.lastName}</td>
                <td>${v.contester.user.firstName} ${v.contester.user.lastName}</td>
                <td><span class="vo-badge vo-badge--cream">${v.contester.position}</span></td>
              </tr>
            </c:forEach>
            <c:if test="${empty voteRows}">
              <tr><td colspan="3" style="padding:20px 24px;color:rgba(234,228,214,.35);">No votes cast yet.</td></tr>
            </c:if>
          </tbody>
        </table>
        <div class="vo-pagination">
          <a class="vo-btn vo-btn--ghost vo-btn--sm ${votesPage <= 1 ? 'disabled' : ''}"
             href="${pageContext.request.contextPath}/admin/dashboard?q=${q}&usersPage=${usersPage}&contestersPage=${contestersPage}&votesPage=${votesPage-1}&auditPage=${auditPage}">&#8592;</a>
          <span>Page ${votesPage} / ${votesTotalPages}</span>
          <a class="vo-btn vo-btn--ghost vo-btn--sm ${votesPage >= votesTotalPages ? 'disabled' : ''}"
             href="${pageContext.request.contextPath}/admin/dashboard?q=${q}&usersPage=${usersPage}&contestersPage=${contestersPage}&votesPage=${votesPage+1}&auditPage=${auditPage}">&#8594;</a>
        </div>
      </div>
    </div>

    <%-- Audit Logs --%>
    <div class="vo-card">
      <div class="vo-card__head"><span class="vo-card__title">Admin Action Log</span></div>
      <div class="vo-card__body--flush">
        <table class="vo-table">
          <thead><tr><th>When</th><th>Admin</th><th>Action</th><th>Detail</th></tr></thead>
          <tbody>
            <c:forEach items="${auditLogs}" var="log">
              <tr>
                <td style="font-size:.78rem;">${log.createdAt}</td>
                <td>${log.adminUser.email}</td>
                <td><code>${log.actionType}</code></td>
                <td style="max-width:300px;">${log.actionDetail}</td>
              </tr>
            </c:forEach>
            <c:if test="${empty auditLogs}">
              <tr><td colspan="4" style="padding:20px 24px;color:rgba(234,228,214,.35);">No actions logged yet.</td></tr>
            </c:if>
          </tbody>
        </table>
        <div class="vo-pagination">
          <a class="vo-btn vo-btn--ghost vo-btn--sm ${auditPage <= 1 ? 'disabled' : ''}"
             href="${pageContext.request.contextPath}/admin/dashboard?q=${q}&usersPage=${usersPage}&contestersPage=${contestersPage}&votesPage=${votesPage}&auditPage=${auditPage-1}">&#8592;</a>
          <span>Page ${auditPage} / ${auditTotalPages}</span>
          <a class="vo-btn vo-btn--ghost vo-btn--sm ${auditPage >= auditTotalPages ? 'disabled' : ''}"
             href="${pageContext.request.contextPath}/admin/dashboard?q=${q}&usersPage=${usersPage}&contestersPage=${contestersPage}&votesPage=${votesPage}&auditPage=${auditPage+1}">&#8594;</a>
        </div>
      </div>
    </div>

  </div>
  <jsp:include page="/WEB-INF/views/fragment/footer.jsp" />

  <script>
  (function () {
    var ctx = '${pageContext.request.contextPath}';

    function renderResults(data) {
      var body = document.getElementById('liveResultsBody');
      if (!data || !data.labels || data.labels.length === 0) {
        body.innerHTML = '<p style="text-align:center;padding:24px;color:rgba(234,228,214,.3);font-family:\'Syne\',sans-serif;font-size:.75rem;letter-spacing:.1em;text-transform:uppercase;">No votes yet.</p>';
        return;
      }
      var positions = {};
      for (var i = 0; i < data.labels.length; i++) {
        var parts = data.labels[i].split(' — ');
        var name = parts[0] || data.labels[i];
        var pos  = parts[1] || 'General';
        var votes = data.votes[i] || 0;
        if (!positions[pos]) positions[pos] = [];
        positions[pos].push({ name: name, votes: votes });
      }
      Object.keys(positions).forEach(function(p) {
        positions[p].sort(function(a,b) { return b.votes - a.votes; });
      });
      var maxVotes = Math.max.apply(null, data.votes.concat([1]));
      var html = '<div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:20px;">';
      Object.keys(positions).forEach(function(pos) {
        html += '<div>';
        html += '<div class="results-position-label">' + pos + '</div>';
        positions[pos].forEach(function(c, idx) {
          var pct = Math.round((c.votes / maxVotes) * 100);
          var isLeader = idx === 0 && c.votes > 0;
          html += '<div class="result-card ' + (isLeader ? 'result-card--leader' : '') + '">';
          html += '  <div class="result-card__bar" style="width:' + pct + '%"></div>';
          html += '  <div class="result-card__rank">' + (idx+1) + '</div>';
          html += '  <div class="result-card__info"><div class="result-card__name">' + c.name + '</div></div>';
          html += '  <div class="result-card__votes"><div class="result-card__num">' + c.votes + '</div><span class="result-card__vword">' + (c.votes===1?'vote':'votes') + '</span></div>';
          html += '</div>';
        });
        html += '</div>';
      });
      html += '</div>';
      body.innerHTML = html;
      setTimeout(function() {
        body.querySelectorAll('.result-card__bar').forEach(function(bar) {
          var w = bar.style.width; bar.style.width = '0';
          setTimeout(function() { bar.style.width = w; }, 50);
        });
      }, 10);
    }

    function refresh() {
      fetch(ctx + '/api/vote-stats').then(function(r){ return r.ok?r.json():null; }).then(function(d){ if(d) renderResults(d); }).catch(function(){});
    }
    refresh(); setInterval(refresh, 8000);
  })();
  </script>

</body>
</html>
