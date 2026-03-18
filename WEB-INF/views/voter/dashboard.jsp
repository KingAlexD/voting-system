<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Dashboard | VoCho</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:ital,wght@0,700;0,800;0,900;1,700;1,900&family=Syne:wght@700;800&family=Epilogue:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
</head>
<body>
  <jsp:include page="/WEB-INF/views/fragment/navbar.jsp" />

  <div class="dash-page">

    <div class="dash-header">
      <p class="dash-eyebrow">Voter Dashboard</p>
      <h1 class="dash-title">Welcome, <em>${currentUser.firstName}</em></h1>
      <p class="dash-subtitle">${currentUser.email} &middot; ${currentUser.role}</p>
    </div>

    <%-- Alerts --%>
    <c:if test="${not empty param.error}">
      <div class="vo-alert vo-alert--error">
        <c:choose>
          <c:when test="${param.error == 'already_voted'}">You have already cast your vote.</c:when>
          <c:when test="${param.error == 'position_full'}">That position already has the maximum of 3 approved contesters.</c:when>
          <c:when test="${param.error == 'application_exists'}">You already have a contester application.</c:when>
          <c:when test="${param.error == 'voting_closed'}">Voting and applications are closed.</c:when>
          <c:when test="${param.error == 'election_not_open'}">Election is not in OPEN phase.</c:when>
          <c:when test="${param.error == 'underage'}">You must be 18+ to vote or contest.</c:when>
          <c:when test="${param.error == 'manifesto_required'}">Manifesto must be at least 20 characters.</c:when>
          <c:when test="${param.error == 'not_approved_contester'}">Only approved contesters can request a position change.</c:when>
          <c:when test="${param.error == 'same_position'}">You are already in that position.</c:when>
          <c:when test="${param.error == 'change_already_pending'}">A position change is already pending review.</c:when>
          <c:when test="${param.error == 'no_application'}">No contester application found.</c:when>
          <c:otherwise>Action failed. Please try again.</c:otherwise>
        </c:choose>
      </div>
    </c:if>
    <c:if test="${not empty param.status}">
      <div class="vo-alert vo-alert--success">
        <c:choose>
          <c:when test="${param.status == 'application_submitted'}">Contester application submitted successfully.</c:when>
          <c:when test="${param.status == 'position_change_requested'}">Position change request submitted — pending admin approval.</c:when>
          <c:when test="${param.status == 'withdrawn'}">You have withdrawn. Role reset to Voter and vote count cleared.</c:when>
          <c:when test="${param.status == 'application_cancelled'}">Your pending application has been cancelled.</c:when>
          <c:otherwise>Operation successful.</c:otherwise>
        </c:choose>
      </div>
    </c:if>

    <%-- Stat tiles --%>
    <div class="stat-row">
      <div class="stat-tile">
        <div class="stat-tile__label">Eligibility</div>
        <div class="stat-tile__value ${isAdult ? 'gold' : ''}">${isAdult ? '18+ OK' : 'Under 18'}</div>
      </div>
      <div class="stat-tile">
        <div class="stat-tile__label">Voting Deadline</div>
        <div class="stat-tile__value" style="font-size:1.6rem;">${votingDeadline}</div>
      </div>
      <div class="stat-tile">
        <div class="stat-tile__label">Election Phase</div>
        <div class="stat-tile__value ${electionPhase == 'OPEN' ? 'gold' : 'coral'}">${electionPhase}</div>
      </div>
      <div class="stat-tile">
        <div class="stat-tile__label">Total Votes Cast</div>
        <div class="stat-tile__value gold">${totalVotes}</div>
      </div>
    </div>

    <div style="display:grid; grid-template-columns: 1fr 380px; gap: 24px; align-items: start;">

      <%-- ── LEFT: Live results + voting ── --%>
      <div>

        <%-- LIVE RESULTS --%>
        <div class="vo-card" id="resultsCard">
          <div class="vo-card__head">
            <span class="vo-card__title">Live Results</span>
            <div style="display:flex;align-items:center;gap:8px;">
              <div class="live-dot"></div>
              <span style="font-family:'Syne',sans-serif;font-size:.62rem;font-weight:800;letter-spacing:.14em;text-transform:uppercase;color:rgba(234,228,214,.4);">Updating live</span>
            </div>
          </div>
          <div class="vo-card__body" id="liveResultsBody">
            <%-- Populated by JS --%>
            <div style="text-align:center;padding:32px;color:rgba(234,228,214,.3);font-family:'Syne',sans-serif;font-size:.75rem;letter-spacing:.1em;text-transform:uppercase;">
              Loading results...
            </div>
          </div>
        </div>

        <%-- VOTING FORM --%>
        <div class="vo-card">
          <div class="vo-card__head">
            <span class="vo-card__title">Cast Your Vote</span>
            <span class="vo-badge ${hasVoted ? 'vo-badge--green' : (electionPhase == 'OPEN' && !votingClosed && isAdult ? 'vo-badge--gold' : 'vo-badge--coral')}">
              ${hasVoted ? 'Voted' : (electionPhase == 'OPEN' && !votingClosed && isAdult ? 'Open' : 'Locked')}
            </span>
          </div>
          <div class="vo-card__body">
            <c:if test="${empty approvedContesters}">
              <p style="color:rgba(234,228,214,.4);font-size:.85rem;">No approved contesters yet.</p>
            </c:if>
            <c:if test="${not empty approvedContesters}">
              <form action="${pageContext.request.contextPath}/vote" method="post">
                <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">

                <div style="display:flex;flex-direction:column;gap:8px;margin-bottom:20px;">
                  <c:forEach items="${approvedContesters}" var="c">
                    <label style="display:flex;align-items:center;gap:14px;padding:14px 18px;background:#1a2f55;border:1px solid rgba(212,168,67,.12);border-radius:4px;cursor:pointer;transition:border-color .15s;"
                           onmouseover="this.style.borderColor='rgba(212,168,67,.3)'"
                           onmouseout="this.style.borderColor='rgba(212,168,67,.12)'">
                      <input type="radio" name="contesterId" value="${c.id}"
                             ${hasVoted || votingClosed || !isAdult || electionPhase != 'OPEN' ? 'disabled' : ''}
                             style="accent-color:#d4a843;width:16px;height:16px;flex-shrink:0;" required>
                      <div style="flex:1;">
                        <span style="font-family:'Barlow Condensed',sans-serif;font-size:1.05rem;font-weight:900;text-transform:uppercase;color:#eae4d6;letter-spacing:-.01em;">
                          <a href="${pageContext.request.contextPath}/candidate-profile?id=${c.id}"
                             style="color:#eae4d6;text-decoration:none;" onmouseover="this.style.color='#d4a843'" onmouseout="this.style.color='#eae4d6'">
                            ${c.user.firstName} ${c.user.lastName}
                          </a>
                        </span>
                        <span class="vo-badge vo-badge--cream" style="margin-left:8px;">${c.position}</span>
                        <p style="font-size:.78rem;font-weight:300;color:rgba(234,228,214,.42);margin-top:4px;margin-bottom:0;line-height:1.5;">${c.manifesto}</p>
                      </div>
                    </label>
                  </c:forEach>
                </div>

                <button type="submit" class="vo-btn vo-btn--gold"
                        style="width:100%;justify-content:center;"
                        ${hasVoted || votingClosed || !isAdult || electionPhase != 'OPEN' ? 'disabled' : ''}>
                  Cast Vote
                </button>
                <c:if test="${hasVoted}"><p style="text-align:center;margin-top:10px;font-size:.75rem;color:#6de08a;font-family:'Syne',sans-serif;font-weight:800;letter-spacing:.08em;text-transform:uppercase;">&#10003; Vote recorded</p></c:if>
                <c:if test="${!isAdult}"><p style="text-align:center;margin-top:10px;font-size:.75rem;color:#f08080;font-family:'Syne',sans-serif;font-weight:800;letter-spacing:.08em;text-transform:uppercase;">Unlocks at age 18</p></c:if>
                <c:if test="${votingClosed}"><p style="text-align:center;margin-top:10px;font-size:.75rem;color:#f08080;font-family:'Syne',sans-serif;font-weight:800;letter-spacing:.08em;text-transform:uppercase;">Voting has closed</p></c:if>
                <c:if test="${electionPhase != 'OPEN'}"><p style="text-align:center;margin-top:10px;font-size:.75rem;color:#f08080;font-family:'Syne',sans-serif;font-weight:800;letter-spacing:.08em;text-transform:uppercase;">Phase: ${electionPhase}</p></c:if>
              </form>
            </c:if>
          </div>
        </div>

      </div>

      <%-- ── RIGHT: Profile + Application ── --%>
      <div>

        <%-- Profile --%>
        <div class="vo-card">
          <div class="vo-card__head"><span class="vo-card__title">Profile</span></div>
          <div class="vo-card__body">
            <div class="info-row">
              <span class="info-row__label">Name</span>
              <span class="info-row__value">${currentUser.firstName} ${currentUser.lastName}</span>
            </div>
            <div class="info-row">
              <span class="info-row__label">Role</span>
              <span class="info-row__value">${currentUser.role}</span>
            </div>
            <div class="info-row">
              <span class="info-row__label">Verified</span>
              <span class="info-row__value">${currentUser.emailVerified}</span>
            </div>
            <div class="info-row">
              <span class="info-row__label">Status</span>
              <span class="info-row__value">${isAdult ? 'Eligible' : 'Underage'}</span>
            </div>
            <div style="margin-top:16px;">
              <a href="${pageContext.request.contextPath}/profile" class="vo-btn vo-btn--ghost" style="width:100%;justify-content:center;">
                Manage Profile
              </a>
            </div>
          </div>
        </div>

        <%-- My Vote --%>
        <c:if test="${hasVoted and not empty myVote}">
          <div class="vo-card">
            <div class="vo-card__head"><span class="vo-card__title">Your Vote</span></div>
            <div class="vo-card__body">
              <p style="font-family:'Barlow Condensed',sans-serif;font-size:1.4rem;font-weight:900;text-transform:uppercase;color:#eae4d6;letter-spacing:-.01em;margin-bottom:4px;">
                ${myVote.contester.user.firstName} ${myVote.contester.user.lastName}
              </p>
              <span class="vo-badge vo-badge--gold">${myVote.contester.position}</span>
            </div>
          </div>
        </c:if>

        <%-- Contester Application --%>
        <div class="vo-card">
          <div class="vo-card__head"><span class="vo-card__title">Contester Application</span></div>
          <div class="vo-card__body">
            <c:choose>
              <c:when test="${not empty myContesterApplication}">
                <div class="apply-card" style="padding:0;background:transparent;border:none;">
                  <div class="apply-card__status apply-card__status--${myContesterApplication.status == 'APPROVED' ? 'approved' : (myContesterApplication.status == 'PENDING' ? 'pending' : 'denied')}">
                    ${myContesterApplication.status}
                  </div>
                  <div class="apply-card__pos">${myContesterApplication.position}</div>
                  <p class="apply-card__manifesto">${myContesterApplication.manifesto}</p>
                </div>

                <%-- Position change for approved --%>
                <c:if test="${myContesterApplication.status == 'APPROVED'}">
                  <c:choose>
                    <c:when test="${not empty myContesterApplication.requestedPosition}">
                      <div class="vo-alert vo-alert--info" style="margin-bottom:14px;">
                        Position change to <strong>${myContesterApplication.requestedPosition}</strong> pending approval.
                      </div>
                    </c:when>
                    <c:otherwise>
                      <div class="vo-divider" data-label="REQUEST POSITION CHANGE"></div>
                      <form action="${pageContext.request.contextPath}/contester/request-position-change" method="post" style="margin-bottom:12px;">
                        <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                        <div class="field-group">
                          <select name="requestedPosition" class="vo-select" required>
                            <option value="">Select new position</option>
                            <c:forEach items="${positions}" var="pos">
                              <c:if test="${pos != myContesterApplication.position}">
                                <option value="${pos}">${pos}</option>
                              </c:if>
                            </c:forEach>
                          </select>
                        </div>
                        <button type="submit" class="vo-btn vo-btn--ghost vo-btn--sm" style="width:100%;justify-content:center;">
                          Request Position Change
                        </button>
                      </form>
                    </c:otherwise>
                  </c:choose>

                  <div class="vo-divider" data-label="WITHDRAW"></div>
                  <p style="font-size:.78rem;font-weight:300;color:rgba(234,228,214,.4);margin-bottom:10px;line-height:1.6;">
                    Withdrawing removes your contester role and resets your vote count permanently.
                  </p>
                  <form action="${pageContext.request.contextPath}/contester/withdraw" method="post">
                    <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                    <input type="hidden" name="action" value="withdraw">
                    <button type="submit" class="vo-btn vo-btn--danger-ghost vo-btn--sm" style="width:100%;justify-content:center;"
                            onclick="return confirm('Withdraw from the election? This resets your vote count and returns you to Voter status.')">
                      Withdraw from Election
                    </button>
                  </form>
                </c:if>

                <%-- Cancel pending --%>
                <c:if test="${myContesterApplication.status == 'PENDING'}">
                  <div class="vo-divider"></div>
                  <form action="${pageContext.request.contextPath}/contester/withdraw" method="post">
                    <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                    <input type="hidden" name="action" value="withdraw">
                    <button type="submit" class="vo-btn vo-btn--ghost vo-btn--sm" style="width:100%;justify-content:center;"
                            onclick="return confirm('Cancel your pending application?')">
                      Cancel Application
                    </button>
                  </form>
                </c:if>
              </c:when>

              <c:otherwise>
                <form action="${pageContext.request.contextPath}/contester/apply" method="post">
                  <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
                  <div class="field-group">
                    <label class="vo-label">Position</label>
                    <select name="position" class="vo-select" required
                            ${votingClosed || !isAdult || electionPhase != 'OPEN' ? 'disabled' : ''}>
                      <option value="">Select position</option>
                      <c:forEach items="${positions}" var="pos">
                        <option value="${pos}">${pos}</option>
                      </c:forEach>
                    </select>
                  </div>
                  <div class="field-group">
                    <label class="vo-label">Manifesto</label>
                    <textarea name="manifesto" class="vo-textarea" rows="4"
                              minlength="20" maxlength="2000"
                              placeholder="Share your core agenda..."
                              ${votingClosed || !isAdult || electionPhase != 'OPEN' ? 'disabled' : ''}></textarea>
                  </div>
                  <button type="submit" class="vo-btn vo-btn--coral" style="width:100%;justify-content:center;"
                          ${votingClosed || !isAdult || electionPhase != 'OPEN' ? 'disabled' : ''}>
                    Apply as Contester
                  </button>
                </form>
              </c:otherwise>
            </c:choose>
          </div>
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
        body.innerHTML = '<p style="text-align:center;padding:32px;color:rgba(234,228,214,.3);font-family:\'Syne\',sans-serif;font-size:.75rem;letter-spacing:.1em;text-transform:uppercase;">No votes cast yet.</p>';
        return;
      }

      // Group by position
      var positions = {};
      for (var i = 0; i < data.labels.length; i++) {
        var parts = data.labels[i].split(' — ');
        var name = parts[0] || data.labels[i];
        var pos  = parts[1] || 'General';
        var votes = data.votes[i] || 0;
        if (!positions[pos]) positions[pos] = [];
        positions[pos].push({ name: name, votes: votes });
      }

      // Sort each group descending
      Object.keys(positions).forEach(function(pos) {
        positions[pos].sort(function(a,b) { return b.votes - a.votes; });
      });

      var maxVotes = Math.max.apply(null, data.votes.concat([1]));
      var html = '';

      Object.keys(positions).forEach(function(pos) {
        html += '<div class="results-position-block">';
        html += '<div class="results-position-label">' + pos + '</div>';

        positions[pos].forEach(function(c, idx) {
          var pct = Math.round((c.votes / maxVotes) * 100);
          var isLeader = idx === 0 && c.votes > 0;
          html += '<div class="result-card ' + (isLeader ? 'result-card--leader' : '') + '">';
          html += '  <div class="result-card__bar" style="width:' + pct + '%"></div>';
          html += '  <div class="result-card__rank">' + (idx + 1) + '</div>';
          html += '  <div class="result-card__info">';
          html += '    <div class="result-card__name">' + c.name + '</div>';
          html += '    <div class="result-card__pos">' + pos + '</div>';
          html += '  </div>';
          html += '  <div class="result-card__votes">';
          html += '    <div class="result-card__num">' + c.votes + '</div>';
          html += '    <span class="result-card__vword">' + (c.votes === 1 ? 'vote' : 'votes') + '</span>';
          html += '  </div>';
          html += '</div>';
        });

        html += '</div>';
      });

      body.innerHTML = html;

      // Animate bars in after render
      setTimeout(function() {
        body.querySelectorAll('.result-card__bar').forEach(function(bar) {
          var w = bar.style.width;
          bar.style.width = '0';
          setTimeout(function() { bar.style.width = w; }, 50);
        });
      }, 10);
    }

    function refresh() {
      fetch(ctx + '/api/vote-stats')
        .then(function(r) { return r.ok ? r.json() : null; })
        .then(function(d) { if (d) renderResults(d); })
        .catch(function() {});
    }

    refresh();
    setInterval(refresh, 8000);
  })();
  </script>

</body>
</html>
