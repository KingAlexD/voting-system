<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
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
  <style>
    .vmodal-bg { display:none; position:fixed; inset:0; z-index:900; background:rgba(9,18,36,.88); backdrop-filter:blur(4px); align-items:center; justify-content:center; padding:24px; }
    .vmodal-bg.open { display:flex; }
    .vmodal { background:#0e1f3a; border:1px solid rgba(212,168,67,.3); border-radius:4px; width:100%; max-width:560px; max-height:90vh; overflow-y:auto; box-shadow:0 24px 80px rgba(0,0,0,.6); animation:mIn .28s cubic-bezier(.22,1,.36,1); }
    @keyframes mIn { from{opacity:0;transform:translateY(20px);}to{opacity:1;transform:translateY(0);} }
    .vmodal__head { padding:20px 26px 16px; border-bottom:1px solid rgba(212,168,67,.15); display:flex; align-items:flex-start; justify-content:space-between; gap:14px; }
    .vmodal__title { font-family:'Barlow Condensed',sans-serif; font-size:1.4rem; font-weight:900; text-transform:uppercase; color:#eae4d6; letter-spacing:-.01em; line-height:1; }
    .vmodal__close { background:none; border:none; cursor:pointer; color:rgba(234,228,214,.4); font-size:1.3rem; padding:2px 7px; border-radius:3px; flex-shrink:0; transition:color .15s,background .15s; }
    .vmodal__close:hover { color:#eae4d6; background:rgba(212,168,67,.12); }
    .vmodal__body { padding:22px 26px; }
    .vmodal__label { font-family:'Syne',sans-serif; font-size:.58rem; font-weight:800; text-transform:uppercase; letter-spacing:.18em; color:rgba(234,228,214,.38); display:block; margin-bottom:4px; }
    .vmodal__val { font-size:.9rem; font-weight:300; color:#eae4d6; line-height:1.6; margin-bottom:14px; }
    .vmodal__manifesto { background:#1a2f55; border-left:3px solid rgba(212,168,67,.28); padding:13px 17px; border-radius:3px; font-size:.87rem; font-weight:300; color:rgba(234,228,214,.72); line-height:1.85; font-style:italic; }
    .vmodal__foot { padding:14px 26px; border-top:1px solid rgba(212,168,67,.1); display:flex; gap:10px; justify-content:flex-end; }
    .vote-confirm-warn { background:rgba(196,92,58,.12); border:1px solid rgba(196,92,58,.3); border-radius:3px; padding:12px 16px; font-size:.82rem; color:#e88a6a; line-height:1.6; margin-bottom:16px; }
  </style>
</head>
<body>
  <jsp:include page="/WEB-INF/views/fragment/navbar.jsp" />

  <div class="dash-page">

    <div class="dash-header">
      <p class="dash-eyebrow">Voter Dashboard</p>
      <h1 class="dash-title">Welcome, <em>${currentUser.firstName}</em></h1>
      <p class="dash-subtitle">${currentUser.email} &middot; ${currentUser.role}</p>
    </div>

    <c:if test="${not empty param.error}">
      <div class="vo-alert vo-alert--error">
        <c:choose>
          <c:when test="${param.error == 'already_voted'}">You have already cast your vote.</c:when>
          <c:when test="${param.error == 'position_full'}">That position already has 3 approved contesters.</c:when>
          <c:when test="${param.error == 'application_exists'}">You already have a contester application.</c:when>
          <c:when test="${param.error == 'voting_closed'}">Voting is currently closed.</c:when>
          <c:when test="${param.error == 'election_not_open'}">The election is not currently open.</c:when>
          <c:when test="${param.error == 'underage'}">You must be 18+ to vote or contest.</c:when>
          <c:when test="${param.error == 'manifesto_required'}">Manifesto must be at least 20 characters.</c:when>
          <c:when test="${param.error == 'not_approved_contester'}">Only approved contesters can request a position change.</c:when>
          <c:when test="${param.error == 'same_position'}">You are already in that position.</c:when>
          <c:when test="${param.error == 'change_already_pending'}">A position change request is already pending.</c:when>
          <c:when test="${param.error == 'no_application'}">No contester application found.</c:when>
          <c:otherwise>Action failed. Please try again.</c:otherwise>
        </c:choose>
      </div>
    </c:if>
    <c:if test="${not empty param.status}">
      <div class="vo-alert vo-alert--success">
        <c:choose>
          <c:when test="${param.status == 'application_submitted'}">Contester application submitted.</c:when>
          <c:when test="${param.status == 'position_change_requested'}">Position change submitted — pending admin approval.</c:when>
          <c:when test="${param.status == 'withdrawn'}">Withdrawn. Role reset to Voter.</c:when>
          <c:when test="${param.status == 'application_cancelled'}">Application cancelled.</c:when>
          <c:otherwise>Operation successful.</c:otherwise>
        </c:choose>
      </div>
    </c:if>
<c:if test="${userVotes[c.position]}">
  Already voted for this position
</c:if>
<c:if test="${electionPhase != 'OPEN'}">
  <p class="warn">Election has not started yet</p>
</c:if>

<c:if test="${electionPhase == 'OPEN'}">
   
</c:if>
    <div class="stat-row">
      <div class="stat-tile"><div class="stat-tile__label">Eligibility</div><div class="stat-tile__value ${isAdult ? 'gold' : ''}">${isAdult ? '18+ OK' : 'Under 18'}</div></div>
      <div class="stat-tile"><div class="stat-tile__label">Voting Deadline</div><div class="stat-tile__value" style="font-size:1.6rem;">${votingDeadline}</div></div>
      <div class="stat-tile"><div class="stat-tile__label">Election Phase</div><div class="stat-tile__value ${electionPhase == 'OPEN' ? 'gold' : 'coral'}">${electionPhase}</div></div>
      <div class="stat-tile"><div class="stat-tile__label">Total Votes</div><div class="stat-tile__value gold">${totalVotes}</div></div>
    </div>

    <div style="display:grid;grid-template-columns:1fr 380px;gap:24px;align-items:start;">

      <div>

        <%-- Live Results --%>
        <div class="vo-card" id="resultsCard">
          <div class="vo-card__head">
            <span class="vo-card__title">Live Results</span>
            <div style="display:flex;align-items:center;gap:8px;"><div class="live-dot"></div><span style="font-family:'Syne',sans-serif;font-size:.62rem;font-weight:800;letter-spacing:.14em;text-transform:uppercase;color:rgba(234,228,214,.4);">Updating live</span></div>
          </div>
          <div class="vo-card__body" id="liveResultsBody"><div style="text-align:center;padding:32px;color:rgba(234,228,214,.3);font-family:'Syne',sans-serif;font-size:.75rem;letter-spacing:.1em;text-transform:uppercase;">Loading results…</div></div>
        </div>

        <%-- Voting card — vote confirmation goes through JS modal --%>
        <div class="vo-card">
          <div class="vo-card__head">
            <span class="vo-card__title">Contester details</span>
            <span class="vo-badge ${hasVoted ? 'vo-badge--green' : (electionPhase == 'OPEN' && !votingClosed && isAdult ? 'vo-badge--gold' : 'vo-badge--coral')}">
              ${hasVoted ? 'Voted' : (electionPhase == 'OPEN' && !votingClosed && isAdult ? 'Open' : 'Locked')}
            </span>
          </div>
          <div class="vo-card__body">
            <c:if test="${empty approvedContesters}">
              <p style="color:rgba(234,228,214,.4);font-size:.85rem;">No approved contesters yet.</p>
            </c:if>
            <c:if test="${not empty approvedContesters}">
              <%-- Hidden form — JS submits it after confirmation --%>
             <form id="voteForm" action="${pageContext.request.contextPath}/vote" method="post">
  <input type="hidden" name="_csrf" value="${csrfToken}">
  <input type="hidden" name="contesterId" id="voteContesterId">
</form>

              <div style="display:flex;flex-direction:column;gap:8px;margin-bottom:20px;">
                <c:forEach items="${approvedContesters}" var="c">
                  <div style="display:flex;align-items:center;gap:10px;padding:14px 18px;background:#1a2f55;border:1px solid rgba(212,168,67,.12);border-radius:4px;transition:border-color .15s;"
                       onmouseover="this.style.borderColor='rgba(212,168,67,.3)'"
                       onmouseout="this.style.borderColor='rgba(212,168,67,.12)'">
                    <div style="flex:1;">
                      <span style="font-family:'Barlow Condensed',sans-serif;font-size:1.05rem;font-weight:900;text-transform:uppercase;color:#eae4d6;letter-spacing:-.01em;">
                        ${c.user.firstName} ${c.user.lastName}
                      </span>
                      <span class="vo-badge vo-badge--cream" style="margin-left:8px;">${c.position}</span>
                      <p style="font-size:.78rem;font-weight:300;color:rgba(234,228,214,.42);margin-top:4px;margin-bottom:0;line-height:1.5;overflow:hidden;text-overflow:ellipsis;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;">${c.manifesto}</p>
                    </div>
                    <div style="display:flex;flex-direction:column;gap:6px;flex-shrink:0;">
                      <button type="button" class="vo-btn vo-btn--ghost vo-btn--sm"
                              onclick="openCandidateModal('${c.user.firstName} ${c.user.lastName}','${c.position}',`${c.manifesto}`)">
                        Details
                      </button>
                      <c:if test="${!hasVoted && !votingClosed && isAdult && electionPhase == 'OPEN'}">
                        <button type="button" class="vo-btn vo-btn--gold vo-btn--sm"
                                onclick="openVoteConfirm('${c.id}','${c.user.firstName} ${c.user.lastName}','${c.position}')">
                          Vote
                        </button>
                      </c:if>
                    </div>
                  </div>
                </c:forEach>
              </div>
              <c:if test="${hasVoted}"><p style="text-align:center;font-size:.75rem;color:#6de08a;font-family:'Syne',sans-serif;font-weight:800;letter-spacing:.08em;text-transform:uppercase;">&#10003; Vote recorded</p></c:if>
              <c:if test="${!isAdult}"><p style="text-align:center;font-size:.75rem;color:#f08080;font-family:'Syne',sans-serif;font-weight:800;letter-spacing:.08em;text-transform:uppercase;">Unlocks at age 18</p></c:if>
              <c:if test="${votingClosed}"><p style="text-align:center;font-size:.75rem;color:#f08080;font-family:'Syne',sans-serif;font-weight:800;letter-spacing:.08em;text-transform:uppercase;">Voting has closed</p></c:if>
              <c:if test="${electionPhase != 'OPEN'}"><p style="text-align:center;font-size:.75rem;color:#f08080;font-family:'Syne',sans-serif;font-weight:800;letter-spacing:.08em;text-transform:uppercase;">Phase: ${electionPhase}</p></c:if>
            </c:if>
          </div>
        </div>

      </div>

      <%-- Right column — Profile + My Vote + Apply --%>
      <div>
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
        <div class="vo-card">
          <div class="vo-card__head"><span class="vo-card__title">Profile</span></div>
          <div class="vo-card__body">
            <div class="info-row"><span class="info-row__label">Name</span><span class="info-row__value">${currentUser.firstName} ${currentUser.lastName}</span></div>
            <div class="info-row"><span class="info-row__label">Role</span><span class="info-row__value">${currentUser.role}</span></div>
            <div class="info-row"><span class="info-row__label">Verified</span><span class="info-row__value">${currentUser.emailVerified}</span></div>
            <div class="info-row"><span class="info-row__label">Status</span><span class="info-row__value">${isAdult ? 'Eligible' : 'Underage'}</span></div>
            <div style="margin-top:16px;"><a href="${pageContext.request.contextPath}/profile" class="vo-btn vo-btn--ghost" style="width:100%;justify-content:center;">Manage Profile</a></div>
          </div>
        </div>

        <c:if test="${hasVoted and not empty myVote}">
          <div class="vo-card">
            <div class="vo-card__head"><span class="vo-card__title">Your Vote</span></div>
            <div class="vo-card__body">
              <p style="font-family:'Barlow Condensed',sans-serif;font-size:1.4rem;font-weight:900;text-transform:uppercase;color:#eae4d6;letter-spacing:-.01em;margin-bottom:4px;">${myVote.contester.user.firstName} ${myVote.contester.user.lastName}</p>
              <span class="vo-badge vo-badge--gold">${myVote.contester.position}</span>
            </div>
          </div>
        </c:if>

        <div class="vo-card">
          <div class="vo-card__head"><span class="vo-card__title">Cast your vote</span></div>
    <div class="vo-card__body">
  <c:if test="${empty approvedContesters}">
    <p style="color:rgba(234,228,214,.4);font-size:.85rem;">No approved contesters yet.</p>
  </c:if>
  <c:if test="${not empty approvedContesters}">
    <%-- Hidden form — JS submits it after confirmation --%>
    <form id="voteForm" action="${pageContext.request.contextPath}/vote" method="post">
      <input type="hidden" name="_csrf" value="<%= com.bascode.util.CsrfUtil.getToken(request.getSession(true)) %>">
      <input type="hidden" name="contesterId" id="voteContesterId">
    </form>

    <%-- **POSITION-GROUPED CANDIDATES** --%>
    <c:forEach items="${positions}" var="position">
      <c:set var="positionContesters" value="${contestersByPosition[position]}" />
      <c:if test="${not empty positionContesters}">
        <div style="margin-bottom:28px;">
          <div style="font-family:'Syne',sans-serif;font-size:.65rem;font-weight:800;letter-spacing:.2em;text-transform:uppercase;color:rgba(212,168,67,.6);margin-bottom:12px;padding-bottom:8px;border-bottom:1px solid rgba(212,168,67,.12);">
            ${position}
          </div>
          
          <c:forEach items="${positionContesters}" var="c">
            <c:set var="hasVotedThisPos" value="${userVotesByPosition[position] == true}" />
            <div style="display:flex;align-items:center;gap:10px;padding:14px 18px;background:#1a2f55;border:1px solid rgba(212,168,67,.12);border-radius:4px;transition:border-color .15s;margin-bottom:8px;"
                 onmouseover="this.style.borderColor='rgba(212,168,67,.3)'"
                 onmouseout="this.style.borderColor='rgba(212,168,67,.12)'">
              <div style="flex:1;">
                <span style="font-family:'Barlow Condensed',sans-serif;font-size:1.05rem;font-weight:900;text-transform:uppercase;color:#eae4d6;letter-spacing:-.01em;">
                  ${c.user.firstName} ${c.user.lastName}
                </span>
                <span class="vo-badge vo-badge--cream" style="margin-left:8px;">${c.position}</span>
                <p style="font-size:.78rem;font-weight:300;color:rgba(234,228,214,.42);margin-top:4px;margin-bottom:0;line-height:1.5;overflow:hidden;text-overflow:ellipsis;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;">${c.manifesto}</p>
              </div>
              <div style="display:flex;flex-direction:column;gap:6px;flex-shrink:0;">
                <button type="button" class="vo-btn vo-btn--ghost vo-btn--sm"
                        onclick="openCandidateModal('${c.user.firstName} ${c.user.lastName}','${c.position}','${fn:escapeXml(c.manifesto)}')">
                  Details
                </button>
                <c:if test="${electionPhase == 'OPEN' && !votingClosed && isAdult}">
                  <c:choose>
                    <c:when test="${hasVotedThisPos}">
                      <span class="vo-badge vo-badge--green" style="padding:8px 16px;font-weight:600;font-size:.8rem;">Voted ✓</span>
                    </c:when>
                    <c:otherwise>
                      <button type="button" class="vo-btn vo-btn--gold vo-btn--sm"
                              onclick="openVoteConfirm('${c.id}','${c.user.firstName} ${c.user.lastName}','${c.position}')">
                        Vote
                      </button>
                    </c:otherwise>
                  </c:choose>
                </c:if>
              </div>
            </div>
          </c:forEach>
        </div>
      </c:if>
    </c:forEach>

    <%-- Status messages --%>
    <c:if test="${hasVoted}">
      <p style="text-align:center;font-size:.75rem;color:#6de08a;font-family:'Syne',sans-serif;font-weight:800;letter-spacing:.08em;text-transform:uppercase;margin-top:20px;">
        &#10003; Vote${fn:length(userVotes) > 1 ? 's' : ''} recorded
      </p>
    </c:if>
    <c:if test="${!isAdult}">
      <p style="text-align:center;font-size:.75rem;color:#f08080;font-family:'Syne',sans-serif;font-weight:800;letter-spacing:.08em;text-transform:uppercase;">Unlocks at age 18</p>
    </c:if>
    <c:if test="${votingClosed}">
      <p style="text-align:center;font-size:.75rem;color:#f08080;font-family:'Syne',sans-serif;font-weight:800;letter-spacing:.08em;text-transform:uppercase;">Voting has closed</p>
    </c:if>
    <c:if test="${electionPhase != 'OPEN'}">
      <p style="text-align:center;font-size:.75rem;color:#f08080;font-family:'Syne',sans-serif;font-weight:800;letter-spacing:.08em;text-transform:uppercase;">Phase: ${electionPhase}</p>
    </c:if>
  </c:if>
</div>
        </div>

      </div>
    </div>
  </div>

  <%-- ── CANDIDATE DETAIL MODAL ─────────────────────────────────────── --%>
  <div class="vmodal-bg" id="candModal" onclick="if(event.target===this)closeCandModal()">
    <div class="vmodal">
      <div class="vmodal__head">
        <span class="vmodal__title" id="cdName"></span>
        <button class="vmodal__close" onclick="closeCandModal()">&#10005;</button>
      </div>
      <div class="vmodal__body">
        <span class="vmodal__label">Position</span>
        <div class="vmodal__val" id="cdPos"></div>
        <span class="vmodal__label">Manifesto</span>
        <p class="vmodal__manifesto" id="cdManifesto"></p>
      </div>
      <div class="vmodal__foot"><button class="vo-btn vo-btn--ghost" onclick="closeCandModal()">Close</button></div>
    </div>
  </div>

  <%-- ── VOTE CONFIRMATION MODAL ────────────────────────────────────── --%>
  <div class="vmodal-bg" id="voteModal" onclick="if(event.target===this)closeVoteModal()">
    <div class="vmodal" style="max-width:460px;">
      <div class="vmodal__head">
        <span class="vmodal__title">Confirm Your Vote</span>
        <button class="vmodal__close" onclick="closeVoteModal()">&#10005;</button>
      </div>
      <div class="vmodal__body">
        <p style="font-size:.9rem;font-weight:300;color:rgba(234,228,214,.7);margin-bottom:16px;line-height:1.7;">You are about to cast your vote for:</p>
        <p style="font-family:'Barlow Condensed',sans-serif;font-size:1.6rem;font-weight:900;text-transform:uppercase;color:#eae4d6;letter-spacing:-.01em;line-height:1;margin-bottom:6px;" id="vcName"></p>
        <span class="vo-badge vo-badge--cream" id="vcPos" style="margin-bottom:18px;display:inline-block;"></span>
        <div class="vote-confirm-warn">
          &#9888; Votes are <strong>permanent and cannot be retracted</strong>. Please make sure this is your final decision before confirming.
        </div>
      </div>
      <div class="vmodal__foot">
        <button class="vo-btn vo-btn--ghost" onclick="closeVoteModal()">Cancel</button>
        <button class="vo-btn vo-btn--gold" onclick="submitVote()">Yes, Cast My Vote</button>
      </div>
    </div>
  </div>

  <jsp:include page="/WEB-INF/views/fragment/footer.jsp" />

  <script>
  var CTX = '${pageContext.request.contextPath}';

  /* ── Candidate detail modal ──────────────────────── */
  function openCandidateModal(name, pos, manifesto) {
    document.getElementById('cdName').textContent = name;
    document.getElementById('cdPos').textContent = pos;
    document.getElementById('cdManifesto').textContent = manifesto || 'No manifesto provided.';
    document.getElementById('candModal').classList.add('open');
    document.body.style.overflow = 'hidden';
  }
  function closeCandModal() {
    document.getElementById('candModal').classList.remove('open');
    document.body.style.overflow = '';
  }

  /* ── Vote confirmation modal ─────────────────────── */
  function openVoteConfirm(id, name, pos) {
    document.getElementById('voteContesterId').value = id;
    document.getElementById('vcName').textContent = name;
    document.getElementById('vcPos').textContent = pos;
    document.getElementById('voteModal').classList.add('open');
    document.body.style.overflow = 'hidden';
  }
  function closeVoteModal() {
    document.getElementById('voteModal').classList.remove('open');
    document.body.style.overflow = '';
  }
  function submitVote() {
    document.getElementById('voteForm').submit();
  }

  document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') { closeCandModal(); closeVoteModal(); }
  });

  /* ── Election status + winner popup ─────────────── */
  var _winnerShown = sessionStorage.getItem('vochoWinnerShown') === '1';
  function pollElection() {
    fetch(CTX + '/api/election-status')
      .then(function(r) { return r.ok ? r.json() : null; })
      .then(function(d) {
        if (!d) return;
        if (d.phase === 'CLOSED' && d.winner && !_winnerShown) {
          _winnerShown = true;
          sessionStorage.setItem('vochoWinnerShown', '1');
          showWinnerPopup(d.winner);
        }
        // Reset flag when new election starts
        if (d.phase === 'OPEN') {
          _winnerShown = false;
          sessionStorage.removeItem('vochoWinnerShown');
        }
      })
      .catch(function() {});
  }
  pollElection(); setInterval(pollElection, 6000);

  /* ── Live results ────────────────────────────────── */
  (function () {
    function renderResults(data) {
      var body = document.getElementById('liveResultsBody');
      if (!data || !data.labels || data.labels.length === 0) {
        body.innerHTML = '<p style="text-align:center;padding:32px;color:rgba(234,228,214,.3);font-family:\'Syne\',sans-serif;font-size:.75rem;letter-spacing:.1em;text-transform:uppercase;">No votes cast yet.</p>';
        return;
      }
      var positions = {};
      for (var i = 0; i < data.labels.length; i++) {
        var parts = data.labels[i].split(' (');
        var name = parts[0] || data.labels[i];
        var pos  = (parts[1] || 'General').replace(')', '');
        var votes = data.votes[i] || 0;
        if (!positions[pos]) positions[pos] = [];
        positions[pos].push({ name: name, votes: votes });
      }
      Object.keys(positions).forEach(function(pos) { positions[pos].sort(function(a,b){return b.votes-a.votes;}); });
      var maxVotes = Math.max.apply(null, data.votes.concat([1]));
      var html = '';
      Object.keys(positions).forEach(function(pos) {
        html += '<div class="results-position-block">';
        html += '<div class="results-position-label">' + pos + '</div>';
        positions[pos].forEach(function(c, idx) {
          var pct = Math.round((c.votes / maxVotes) * 100);
          var isLeader = idx === 0 && c.votes > 0;
          html += '<div class="result-card ' + (isLeader ? 'result-card--leader' : '') + '">';
          html += '<div class="result-card__bar" style="width:' + pct + '%"></div>';
          html += '<div class="result-card__rank">' + (idx+1) + '</div>';
          html += '<div class="result-card__info"><div class="result-card__name">' + c.name + '</div><div class="result-card__pos">' + pos + '</div></div>';
          html += '<div class="result-card__votes"><div class="result-card__num">' + c.votes + '</div><span class="result-card__vword">' + (c.votes===1?'vote':'votes') + '</span></div>';
          html += '</div>';
        });
        html += '</div>';
      });
      body.innerHTML = html;
      setTimeout(function() {
        body.querySelectorAll('.result-card__bar').forEach(function(bar) {
          var w = bar.style.width; bar.style.width = '0';
          setTimeout(function() { bar.style.width = w; }, 50);
        });
      }, 10);
    }
    function refresh() {
      fetch(CTX + '/api/vote-stats').then(function(r){return r.ok?r.json():null;}).then(function(d){if(d)renderResults(d);}).catch(function(){});
    }
    refresh(); setInterval(refresh, 8000);
  })();
  </script>

</body>
</html>
