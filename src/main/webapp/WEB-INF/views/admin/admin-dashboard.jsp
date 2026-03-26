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
  <style>
    .vmodal-bg {
      display: none; position: fixed; inset: 0; z-index: 900;
      background: rgba(9,18,36,.88); backdrop-filter: blur(4px);
      align-items: center; justify-content: center; padding: 24px;
    }
    .vmodal-bg.open { display: flex; }
    .vmodal {
      background: #0e1f3a; border: 1px solid rgba(212,168,67,.3);
      border-radius: 4px; width: 100%; max-width: 620px;
      max-height: 90vh; overflow-y: auto;
      box-shadow: 0 24px 80px rgba(0,0,0,.6);
      animation: modalIn .28s cubic-bezier(.22,1,.36,1);
    }
    @keyframes modalIn { from { opacity:0;transform:translateY(20px); } to { opacity:1;transform:translateY(0); } }
    .vmodal__head { padding: 22px 28px 18px; border-bottom: 1px solid rgba(212,168,67,.15); display: flex; align-items: flex-start; justify-content: space-between; gap: 16px; }
    .vmodal__title { font-family: 'Barlow Condensed', sans-serif; font-size: 1.5rem; font-weight: 900; text-transform: uppercase; color: #eae4d6; letter-spacing: -.01em; line-height: 1; }
    .vmodal__close { background: none; border: none; cursor: pointer; color: rgba(234,228,214,.4); font-size: 1.4rem; line-height: 1; padding: 2px 8px; border-radius: 3px; flex-shrink: 0; transition: color .15s, background .15s; }
    .vmodal__close:hover { color: #eae4d6; background: rgba(212,168,67,.12); }
    .vmodal__body { padding: 24px 28px; }
    .vmodal__row { margin-bottom: 16px; }
    .vmodal__label { font-family: 'Syne', sans-serif; font-size: .58rem; font-weight: 800; text-transform: uppercase; letter-spacing: .18em; color: rgba(234,228,214,.38); display: block; margin-bottom: 4px; }
    .vmodal__val { font-size: .9rem; font-weight: 300; color: #eae4d6; line-height: 1.6; }
    .vmodal__manifesto { background: #1a2f55; border-left: 3px solid rgba(212,168,67,.28); padding: 14px 18px; border-radius: 3px; font-size: .88rem; font-weight: 300; color: rgba(234,228,214,.72); line-height: 1.85; font-style: italic; }
    .vmodal__foot { padding: 16px 28px; border-top: 1px solid rgba(212,168,67,.1); display: flex; gap: 10px; justify-content: flex-end; }

    .msg-full-body { background: #1a2f55; border-left: 3px solid rgba(212,168,67,.2); padding: 14px 18px; border-radius: 3px; font-size: .88rem; font-weight: 300; color: rgba(234,228,214,.72); line-height: 1.85; }

    .election-ctrl { background: #0e1f3a; border: 1px solid rgba(212,168,67,.28); border-radius: 4px; padding: 24px 28px; margin-bottom: 24px; }
    .election-ctrl__title { font-family: 'Barlow Condensed', sans-serif; font-size: 1.1rem; font-weight: 900; text-transform: uppercase; color: #d4a843; letter-spacing: -.01em; margin-bottom: 18px; display: flex; align-items: center; gap: 10px; }
    .election-ctrl__phase { font-family: 'Syne', sans-serif; font-size: .65rem; font-weight: 800; letter-spacing: .14em; text-transform: uppercase; padding: 4px 12px; border-radius: 2px; }
    .phase-open   { background: rgba(60,180,80,.14);  color: #6de08a; border: 1px solid rgba(60,180,80,.28); }
    .phase-draft  { background: rgba(212,168,67,.14); color: #d4a843; border: 1px solid rgba(212,168,67,.28); }
    .phase-closed { background: rgba(180,50,50,.14);  color: #f08080; border: 1px solid rgba(180,50,50,.28); }
    .election-ctrl__row { display: flex; gap: 10px; flex-wrap: wrap; align-items: flex-end; }
    .dur-field label { font-family: 'Syne', sans-serif; font-size: .6rem; font-weight: 800; text-transform: uppercase; letter-spacing: .14em; color: rgba(234,228,214,.38); display: block; margin-bottom: 5px; }
    .dur-field input { width: 160px; padding: 10px 12px; background: #243f6e; border: 1px solid rgba(212,168,67,.2); border-radius: 3px; color: #eae4d6; font-family: 'Epilogue', sans-serif; font-size: .88rem; outline: none; }
    .dur-field input:focus { border-color: #d4a843; }
    .ctrl-hint { font-size: .76rem; font-weight: 300; color: rgba(234,228,214,.32); margin-top: 12px; line-height: 1.65; }
    #timerDisplay { margin-top: 10px; font-family: 'Barlow Condensed', sans-serif; font-size: 1.6rem; font-weight: 900; color: #d4a843; letter-spacing: .04em; }
  </style>
</head>
<body>
  <jsp:include page="/WEB-INF/views/fragment/navbar.jsp" />

  <div class="dash-page">

    <div class="dash-header">
      <p class="dash-eyebrow">Admin Panel</p>
      <h1 class="dash-title">Command <em>Center</em></h1>
      <p class="dash-subtitle">Moderation, analytics &amp; election governance</p>
    </div>

    <%-- ── ELECTION CONTROLS ──────────────────────────────────────────── --%>
   <%-- ── ELECTION CONTROLS ──────────────────────────────────────────── --%>
<div class="election-ctrl">
  <div class="election-ctrl__title">
    &#9889; Election Controls
    <span id="phaseBadge" class="election-ctrl__phase phase-draft">Loading…</span>
  </div>

  <%-- Session error (e.g. not enough contestants) --%>
  <c:if test="${not empty sessionScope.error}">
    <div class="vo-alert vo-alert--error" style="margin-bottom:16px;">${sessionScope.error}</div>
    <c:remove var="error" scope="session"/>
  </c:if>

  <%-- Per-position readiness badges --%>
  <c:if test="${not empty positionReadiness}">
    <div style="margin-bottom:16px;">
      <p style="font-family:'Syne',sans-serif;font-size:.6rem;font-weight:800;letter-spacing:.14em;text-transform:uppercase;color:rgba(234,228,214,.3);margin-bottom:8px;">
        Approved per position (need &ge;2 to start)
      </p>
      <div style="display:flex;flex-wrap:wrap;gap:8px;">
        <c:forEach items="${positionReadiness}" var="entry">
          <span class="vo-badge ${entry.value >= 2 ? 'vo-badge--green' : 'vo-badge--coral'}">
            ${entry.key}: ${entry.value}
          </span>
        </c:forEach>
      </div>
    </div>
  </c:if>

  <div class="election-ctrl__row">

    <%-- START (only shown when DRAFT) --%>
    <form action="${pageContext.request.contextPath}/admin/election/control" method="POST" style="display:contents;">
      <input type="hidden" name="_csrf" value="${csrfToken}">
      <input type="hidden" name="action" value="start">
      <div class="dur-field">
        <label>Duration (1–1440 min)</label>
        <input type="number" name="durationMinutes" min="1" max="1440" placeholder="Unlimited if blank" style="width:140px;">
      </div>
      <button type="submit" class="vo-btn vo-btn--gold"
              onclick="return confirm('Start the election? Make sure all positions have ≥2 approved contestants.')">
        &#9654; Start Election
      </button>
    </form>

    <%-- PAUSE / RESUME (toggled by JS based on phase) --%>
    <form action="${pageContext.request.contextPath}/admin/election/control" method="POST" style="display:contents;">
      <input type="hidden" name="_csrf" value="${csrfToken}">
      <input type="hidden" name="action" id="pauseAction" value="pause">
      <button type="submit" class="vo-btn vo-btn--ghost" id="btnPause">
        &#9646;&#9646; Pause
      </button>
    </form>

    <%-- STOP & DECLARE --%>
    <form action="${pageContext.request.contextPath}/admin/election/control" method="POST" style="display:contents;">
      <input type="hidden" name="_csrf" value="${csrfToken}">
      <input type="hidden" name="action" value="stop">
      <button type="submit" class="vo-btn vo-btn--danger-ghost"
              onclick="return confirm('🛑 Stop election and declare winners?\n\nThis is PERMANENT. All voting stops and contestants are reset to voters.');">
        &#9632; Stop &amp; Declare
      </button>
    </form>

    <%-- RESET (only shown after CLOSED — prepares next cycle) --%>
    <form action="${pageContext.request.contextPath}/admin/election/control" method="POST" style="display:contents;">
      <input type="hidden" name="_csrf" value="${csrfToken}">
      <input type="hidden" name="action" value="reset">
      <button type="submit" class="vo-btn vo-btn--ghost" id="btnReset" style="display:none;"
              onclick="return confirm('Reset for a new election cycle? All remaining contester records will be cleared.')">
        &#8635; Reset for Next Election
      </button>
    </form>

  </div>

  <div id="timerDisplay" style="margin-top:12px;"></div>

  <p class="ctrl-hint">
    <strong>Start:</strong> Requires &ge;2 approved contestants per position.<br>
    
    <strong>Reset:</strong> Available after CLOSED — clears records so the next election can begin.
  </p>
</div>
  
  <div id="timerDisplay" style="margin-top:12px;"></div>
  
  <p class="ctrl-hint">
    <strong>Status:</strong> Requires ⩾2 approved contesters per position to start.<br>
    <strong>Position Limit:</strong> Max 3 approved per position.<br>
    <strong>Timer:</strong> 1min–24hrs or unlimited. Auto-declares winner when expired.
  </p>
</div>

    <%-- Search + exports --%>
    <div class="vo-card" style="margin-bottom:24px;">
      <div class="vo-card__body" style="padding:16px 24px;">
        <div style="display:flex;flex-wrap:wrap;gap:12px;align-items:center;justify-content:space-between;">
          <form method="get" action="${pageContext.request.contextPath}/admin/dashboard" style="display:flex;gap:10px;flex:1;min-width:240px;">
            <input type="text" name="q" class="vo-input" style="flex:1;" placeholder="Search users, contesters…" value="${q}">
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

    <div class="stat-row">
      <div class="stat-tile"><div class="stat-tile__label">Registered Users</div><div class="stat-tile__value gold">${statUsers}</div></div>
      <div class="stat-tile"><div class="stat-tile__label">Pending Approvals</div><div class="stat-tile__value ${statPending > 0 ? 'coral' : ''}">${statPending}</div></div>
      <div class="stat-tile"><div class="stat-tile__label">Contesters</div><div class="stat-tile__value">${statContesters}</div></div>
      <div class="stat-tile"><div class="stat-tile__label">Votes Cast</div><div class="stat-tile__value gold">${statVotes}</div></div>
    </div>

    <%-- Live Results --%>
    <div class="vo-card">
      <div class="vo-card__head">
        <span class="vo-card__title">Live Results</span>
        <div style="display:flex;align-items:center;gap:8px;"><div class="live-dot"></div><span style="font-family:'Syne',sans-serif;font-size:.62rem;font-weight:800;letter-spacing:.14em;text-transform:uppercase;color:rgba(234,228,214,.4);">Live</span></div>
      </div>
      <div class="vo-card__body" id="liveResultsBody"><div style="text-align:center;padding:24px;color:rgba(234,228,214,.3);font-family:'Syne',sans-serif;font-size:.75rem;letter-spacing:.1em;text-transform:uppercase;">Loading…</div></div>
    </div>

    <%-- Pending Applications (with Details modal button) --%>
    <div class="vo-card">
      <div class="vo-card__head">
        <span class="vo-card__title">Pending Applications</span>
        <span class="vo-badge vo-badge--pending">${pendingContesters.size()} pending</span>
      </div>
      <div class="vo-card__body--flush">
        <c:if test="${empty pendingContesters}"><p style="padding:20px 24px;color:rgba(234,228,214,.35);font-size:.84rem;">No pending applications.</p></c:if>
        <c:if test="${not empty pendingContesters}">
          <table class="vo-table">
            <thead><tr><th>Name</th><th>Email</th><th>Position</th><th>Actions</th></tr></thead>
            <tbody>
              <c:forEach items="${pendingContesters}" var="c">
                <tr>
                  <td><strong>${c.user.firstName} ${c.user.lastName}</strong></td>
                  <td>${c.user.email}</td>
                  <td><span class="vo-badge vo-badge--cream">${c.position}</span></td>
                  <td>
                    <div style="display:flex;gap:6px;flex-wrap:wrap;">
                      <button type="button" class="vo-btn vo-btn--ghost vo-btn--sm"
                        onclick="openCModal('${c.user.firstName} ${c.user.lastName}','${c.user.email}','${c.position}','${c.status}',`${c.manifesto}`,${c.user.birthYear},'${c.user.state}')">
                        View Details
                      </button>
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
      <div class="vo-card__head"><span class="vo-card__title">Position Change Requests</span><span class="vo-badge vo-badge--pending">${positionChangeRequests.size()} pending</span></div>
      <div class="vo-card__body--flush">
        <c:if test="${empty positionChangeRequests}"><p style="padding:20px 24px;color:rgba(234,228,214,.35);font-size:.84rem;">No pending requests.</p></c:if>
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
                        <input type="hidden" name="contesterId" value="${c.id}"><input type="hidden" name="action" value="approve-position">
                        <button type="submit" class="vo-btn vo-btn--gold vo-btn--sm">Approve</button>
                      </form>
                      <form action="${pageContext.request.contextPath}/admin/contester/decision" method="post">
                        <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                        <input type="hidden" name="contesterId" value="${c.id}"><input type="hidden" name="action" value="deny-position">
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
                <td><strong>${u.firstName} ${u.lastName}</strong><c:if test="${u.suspended}"><span class="vo-badge vo-badge--red" style="margin-left:6px;">Suspended</span></c:if></td>
                <td>${u.email}</td>
                <td><span class="vo-badge vo-badge--${u.role == 'ADMIN' ? 'gold' : (u.role == 'CONTESTER' ? 'coral' : 'cream')}">${u.role}</span></td>
                <td>${u.emailVerified}</td>
                <td>
                  <div style="display:flex;gap:6px;flex-wrap:wrap;">
                    <form action="${pageContext.request.contextPath}/admin/contester/decision" method="post" style="display:inline;">
                      <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                      <input type="hidden" name="userId" value="${u.id}"><input type="hidden" name="action" value="${u.suspended ? 'unsuspend' : 'suspend'}">
                      <button type="submit" class="vo-btn ${u.suspended ? 'vo-btn--gold' : 'vo-btn--danger-ghost'} vo-btn--sm" onclick="return confirm('${u.suspended ? 'Restore' : 'Suspend'} this user?')">${u.suspended ? 'Restore' : 'Suspend'}</button>
                    </form>
                    <c:if test="${u.role == 'VOTER'}">
                      <form action="${pageContext.request.contextPath}/admin/contester/decision" method="post" style="display:inline;">
                        <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                        <input type="hidden" name="userId" value="${u.id}"><input type="hidden" name="action" value="promote">
                        <button type="submit" class="vo-btn vo-btn--ghost vo-btn--sm">Promote</button>
                      </form>
                    </c:if>
                    <c:if test="${u.role == 'CONTESTER'}">
                      <form action="${pageContext.request.contextPath}/admin/contester/decision" method="post" style="display:inline;">
                        <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                        <input type="hidden" name="userId" value="${u.id}"><input type="hidden" name="action" value="demote">
                        <button type="submit" class="vo-btn vo-btn--ghost vo-btn--sm">Demote</button>
                      </form>
                    </c:if>
                  </div>
                </td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
        <div class="vo-pagination">
          <a class="vo-btn vo-btn--ghost vo-btn--sm ${usersPage <= 1 ? 'disabled' : ''}" href="${pageContext.request.contextPath}/admin/dashboard?q=${q}&usersPage=${usersPage-1}&contestersPage=${contestersPage}&votesPage=${votesPage}&auditPage=${auditPage}">&#8592;</a>
          <span>Page ${usersPage} / ${usersTotalPages}</span>
          <a class="vo-btn vo-btn--ghost vo-btn--sm ${usersPage >= usersTotalPages ? 'disabled' : ''}" href="${pageContext.request.contextPath}/admin/dashboard?q=${q}&usersPage=${usersPage+1}&contestersPage=${contestersPage}&votesPage=${votesPage}&auditPage=${auditPage}">&#8594;</a>
        </div>
      </div>
    </div>

    <%-- Contesters --%>
    <div class="vo-card">
      <div class="vo-card__head"><span class="vo-card__title">Contesters &amp; Votes</span></div>
      <div class="vo-card__body--flush">
        <table class="vo-table">
          <thead><tr><th>Name</th><th>Position</th><th>Status</th><th>Votes</th><th>Details</th></tr></thead>
          <tbody>
            <c:forEach items="${allContesters}" var="c">
              <tr>
                <td><strong>${c.user.firstName} ${c.user.lastName}</strong></td>
                <td><span class="vo-badge vo-badge--cream">${c.position}</span></td>
                <td><span class="vo-badge vo-badge--${c.status == 'APPROVED' ? 'green' : (c.status == 'PENDING' ? 'pending' : 'red')}">${c.status}</span></td>
                <td style="font-family:'Barlow Condensed',sans-serif;font-size:1.2rem;font-weight:900;color:#d4a843;">${voteCounts[c.id] == null ? 0 : voteCounts[c.id]}</td>
                <td><button type="button" class="vo-btn vo-btn--ghost vo-btn--sm"
                      onclick="openCModal('${c.user.firstName} ${c.user.lastName}','${c.user.email}','${c.position}','${c.status}',`${c.manifesto}`,${c.user.birthYear},'${c.user.state}')">View</button></td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
        <div class="vo-pagination">
          <a class="vo-btn vo-btn--ghost vo-btn--sm ${contestersPage <= 1 ? 'disabled' : ''}" href="${pageContext.request.contextPath}/admin/dashboard?q=${q}&usersPage=${usersPage}&contestersPage=${contestersPage-1}&votesPage=${votesPage}&auditPage=${auditPage}">&#8592;</a>
          <span>Page ${contestersPage} / ${contestersTotalPages}</span>
          <a class="vo-btn vo-btn--ghost vo-btn--sm ${contestersPage >= contestersTotalPages ? 'disabled' : ''}" href="${pageContext.request.contextPath}/admin/dashboard?q=${q}&usersPage=${usersPage}&contestersPage=${contestersPage+1}&votesPage=${votesPage}&auditPage=${auditPage}">&#8594;</a>
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
              <tr><td>${v.voter.firstName} ${v.voter.lastName}</td><td>${v.contester.user.firstName} ${v.contester.user.lastName}</td><td><span class="vo-badge vo-badge--cream">${v.contester.position}</span></td></tr>
            </c:forEach>
            <c:if test="${empty voteRows}"><tr><td colspan="3" style="padding:20px 24px;color:rgba(234,228,214,.35);">No votes yet.</td></tr></c:if>
          </tbody>
        </table>
        <div class="vo-pagination">
          <a class="vo-btn vo-btn--ghost vo-btn--sm ${votesPage <= 1 ? 'disabled' : ''}" href="${pageContext.request.contextPath}/admin/dashboard?q=${q}&usersPage=${usersPage}&contestersPage=${contestersPage}&votesPage=${votesPage-1}&auditPage=${auditPage}">&#8592;</a>
          <span>Page ${votesPage} / ${votesTotalPages}</span>
          <a class="vo-btn vo-btn--ghost vo-btn--sm ${votesPage >= votesTotalPages ? 'disabled' : ''}" href="${pageContext.request.contextPath}/admin/dashboard?q=${q}&usersPage=${usersPage}&contestersPage=${contestersPage}&votesPage=${votesPage+1}&auditPage=${auditPage}">&#8594;</a>
        </div>
      </div>
    </div>

    <%-- Audit Log --%>
    <div class="vo-card">
      <div class="vo-card__head"><span class="vo-card__title">Admin Action Log</span></div>
      <div class="vo-card__body--flush">
        <table class="vo-table">
          <thead><tr><th>When</th><th>Admin</th><th>Action</th><th>Detail</th></tr></thead>
          <tbody>
            <c:forEach items="${auditLogs}" var="log">
              <tr><td style="font-size:.78rem;">${log.createdAt}</td><td>${log.adminUser.email}</td><td><code>${log.actionType}</code></td><td style="max-width:300px;">${log.actionDetail}</td></tr>
            </c:forEach>
            <c:if test="${empty auditLogs}"><tr><td colspan="4" style="padding:20px 24px;color:rgba(234,228,214,.35);">No actions logged.</td></tr></c:if>
          </tbody>
        </table>
        <div class="vo-pagination">
          <a class="vo-btn vo-btn--ghost vo-btn--sm ${auditPage <= 1 ? 'disabled' : ''}" href="${pageContext.request.contextPath}/admin/dashboard?q=${q}&usersPage=${usersPage}&contestersPage=${contestersPage}&votesPage=${votesPage}&auditPage=${auditPage-1}">&#8592;</a>
          <span>Page ${auditPage} / ${auditTotalPages}</span>
          <a class="vo-btn vo-btn--ghost vo-btn--sm ${auditPage >= auditTotalPages ? 'disabled' : ''}" href="${pageContext.request.contextPath}/admin/dashboard?q=${q}&usersPage=${usersPage}&contestersPage=${contestersPage}&votesPage=${votesPage}&auditPage=${auditPage+1}">&#8594;</a>
        </div>
      </div>
    </div>

  </div>

  <%-- ── CONTESTER DETAIL MODAL ──────────────────────────────────────── --%>
  <div class="vmodal-bg" id="cModal" onclick="if(event.target===this)closeCModal()">
    <div class="vmodal">
      <div class="vmodal__head">
        <span class="vmodal__title" id="cmName"></span>
        <button class="vmodal__close" onclick="closeCModal()">&#10005;</button>
      </div>
      <div class="vmodal__body">
        <div class="vmodal__row"><span class="vmodal__label">Email</span><span class="vmodal__val" id="cmEmail"></span></div>
        <div class="vmodal__row"><span class="vmodal__label">Position</span><span class="vmodal__val" id="cmPos"></span></div>
        <div class="vmodal__row"><span class="vmodal__label">Status</span><span class="vmodal__val" id="cmStatus"></span></div>
        <div class="vmodal__row"><span class="vmodal__label">Birth Year</span><span class="vmodal__val" id="cmBirth"></span></div>
        <div class="vmodal__row"><span class="vmodal__label">State</span><span class="vmodal__val" id="cmState"></span></div>
        <div class="vmodal__row"><span class="vmodal__label">Manifesto</span><p class="vmodal__manifesto" id="cmManifesto"></p></div>
      </div>
      <div class="vmodal__foot"><button class="vo-btn vo-btn--ghost" onclick="closeCModal()">Close</button></div>
    </div>
  </div>

  <jsp:include page="/WEB-INF/views/fragment/footer.jsp" />

  <script>
  var CTX = '${pageContext.request.contextPath}';

  /* ── Contester modal ─────────────────────────────────── */
 function openCModal(name, email, pos, status, manifesto, birth, state) {
    document.getElementById('cmName').textContent      = name;
    document.getElementById('cmEmail').textContent     = email;
    document.getElementById('cmPos').textContent       = pos;
    document.getElementById('cmStatus').textContent    = status;
    document.getElementById('cmManifesto').textContent = manifesto || 'No manifesto provided.';
    document.getElementById('cmBirth').textContent     = birth;
    document.getElementById('cmState').textContent     = state;
    document.getElementById('cModal').classList.add('open');
    document.body.style.overflow = 'hidden';
  }
  function closeCModal() {
    document.getElementById('cModal').classList.remove('open');
    document.body.style.overflow = '';
  }
  document.addEventListener('keydown', function (e) { if (e.key === 'Escape') closeCModal(); });

  /* ── Election status poll + timer ────────────────────────────────────── */
  var _winnerShown = false;

  function pollElection() {
    fetch(CTX + '/api/election-status')
      .then(function (r) { return r.ok ? r.json() : null; })
      .then(function (d) { if (d) applyElectionStatus(d); })
      .catch(function () {});
  }

  function applyElectionStatus(d) {
    /* ── Phase badge ── */
    var badge = document.getElementById('phaseBadge');
    var cls = d.phase === 'OPEN'
      ? 'phase-open'
      : (d.phase === 'CLOSED' || d.phase === 'RESULTS' ? 'phase-closed' : 'phase-draft');
    badge.className = 'election-ctrl__phase ' + cls;
    badge.textContent = d.phase;

    /* ── Timer display ── */
    var timerEl = document.getElementById('timerDisplay');
    if (d.secondsLeft !== null && d.secondsLeft !== undefined && d.secondsLeft >= 0 && d.phase === 'OPEN') {
      var s = d.secondsLeft;
      timerEl.textContent = '⏱ '
        + Math.floor(s / 3600) + 'h '
        + Math.floor((s % 3600) / 60) + 'm '
        + (s % 60) + 's remaining';
    } else {
      timerEl.textContent = '';
    }

    /* ── Pause / Resume button ── */
    var btnPause = document.getElementById('btnPause');
    var actInput = document.getElementById('pauseAction');
    if (btnPause && actInput) {
      if (d.phase === 'DRAFT') {
        btnPause.innerHTML = '&#9654;&nbsp; Resume';
        actInput.value = 'resume';
        btnPause.style.display = '';
      } else if (d.phase === 'OPEN') {
        btnPause.innerHTML = '&#9646;&#9646;&nbsp; Pause';
        actInput.value = 'pause';
        btnPause.style.display = '';
      } else {
        btnPause.style.display = 'none';
      }
    }

    /* ── Reset button (only visible when CLOSED) ── */
    var btnReset = document.getElementById('btnReset');
    if (btnReset) {
      btnReset.style.display = d.phase === 'CLOSED' ? '' : 'none';
    }

    /* ── Winner popup (array of per-position winners) ── */
    if (d.phase === 'CLOSED' && d.winner && !_winnerShown) {
      _winnerShown = true;
      // winner-popup.js handles both array and single-object shapes
      if (typeof showWinnerPopup === 'function') {
        showWinnerPopup(d.winner);
      }
    }

    /* Reset flag when a new election starts */
    if (d.phase === 'OPEN') _winnerShown = false;
  }

  pollElection();
  setInterval(pollElection, 5000);

  /* ── Live results chart ──────────────────────────────────────────────── */
  (function () {
    function render(data) {
      var body = document.getElementById('liveResultsBody');
      if (!data || !data.labels || !data.labels.length) {
        body.innerHTML = '<p style="text-align:center;padding:24px;color:rgba(234,228,214,.3);'
          + 'font-family:\'Syne\',sans-serif;font-size:.75rem;letter-spacing:.1em;text-transform:uppercase;">No votes yet.</p>';
        return;
      }

      /* Group by position */
      var pos = {};
      for (var i = 0; i < data.labels.length; i++) {
        var p  = data.labels[i].split(' (');
        var n  = p[0];
        var pn = (p[1] || 'General').replace(')', '');
        var v  = data.votes[i] || 0;
        if (!pos[pn]) pos[pn] = [];
        pos[pn].push({ name: n, votes: v });
      }
      Object.keys(pos).forEach(function (p) {
        pos[p].sort(function (a, b) { return b.votes - a.votes; });
      });

      var mx   = Math.max.apply(null, data.votes.concat([1]));
      var html = '<div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:20px;">';

      Object.keys(pos).forEach(function (pn) {
        html += '<div><div class="results-position-label">' + pn + '</div>';
        pos[pn].forEach(function (c, i) {
          var pct  = Math.round((c.votes / mx) * 100);
          var lead = i === 0 && c.votes > 0;
          html += '<div class="result-card ' + (lead ? 'result-card--leader' : '') + '">'
            + '<div class="result-card__bar" style="width:' + pct + '%"></div>'
            + '<div class="result-card__rank">' + (i + 1) + '</div>'
            + '<div class="result-card__info"><div class="result-card__name">' + c.name + '</div></div>'
            + '<div class="result-card__votes"><div class="result-card__num">' + c.votes + '</div>'
            + '<span class="result-card__vword">' + (c.votes === 1 ? 'vote' : 'votes') + '</span></div>'
            + '</div>';
        });
        html += '</div>';
      });
      html += '</div>';

      body.innerHTML = html;
      setTimeout(function () {
        body.querySelectorAll('.result-card__bar').forEach(function (b) {
          var w = b.style.width;
          b.style.width = '0';
          setTimeout(function () { b.style.width = w; }, 50);
        });
      }, 10);
    }

    function go() {
      fetch(CTX + '/api/vote-stats')
        .then(function (r) { return r.ok ? r.json() : null; })
        .then(function (d) { if (d) render(d); })
        .catch(function () {});
    }

    go();
    setInterval(go, 8000);
  })();

  </script>

</body>
</html>
