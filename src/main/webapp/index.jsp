<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VoCho &mdash; Voice &amp; Choice</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:ital,wght@0,700;0,800;0,900;1,700;1,900&family=Syne:wght@700;800&family=Epilogue:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/index.css">
</head>
<body>

  <jsp:include page="/WEB-INF/views/fragment/navbar.jsp" />

  <main>

    <section class="hero">
      <div class="hero__text">
        <p class="hero__eyebrow">Voice &amp; Choice Platform</p>
        <h1 class="catchphrase">
          Own <br> your<br>
          <span class="vc">Voice.</span>
          Make your<br>
          <span class="vc">Choice</span>
        </h1>
        
        <div class="hero__trust">
          <span class="trust-dot"></span>
          Secure &middot; Verified &middot; Session-protected
        </div>
      </div>
      <div>
        <img src="${pageContext.request.contextPath}/images/vote.png" class="protest">
      </div>
    </section>

    <%-- ── LIVE RESULTS STRIP ───────────────────────────────────────────── --%>
    <section style="padding:0 max(32px,5vw) 48px;">
      <div style="background:#0e1f3a;border:1px solid rgba(212,168,67,.2);border-radius:4px;overflow:hidden;">
        <div style="padding:14px 24px;border-bottom:1px solid rgba(212,168,67,.12);display:flex;align-items:center;gap:10px;">
          <div style="width:8px;height:8px;border-radius:50%;background:#6de08a;box-shadow:0 0 8px #6de08a;animation:livePulse 2s ease-in-out infinite;flex-shrink:0;"></div>
          <span style="font-family:'Syne',sans-serif;font-size:.62rem;font-weight:800;letter-spacing:.18em;text-transform:uppercase;color:#d4a843;">Live Vote Tally</span>
        </div>
        <div id="homeResultsBody" style="padding:20px 24px;min-height:60px;">
          <span style="font-family:'Syne',sans-serif;font-size:.72rem;color:rgba(234,228,214,.3);letter-spacing:.1em;text-transform:uppercase;">Loading…</span>
        </div>
      </div>
    </section>

    <section class="pillars-section">
      <div class="pillars-header reveal">
        <h2 class="pillars-heading">Built on <em>three pillars</em></h2>
      </div>
      <div class="pillars-stage">
        <button class="stage-btn stage-btn--prev" id="pPrev" aria-label="Previous">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>
        </button>
        <div class="pillars-track" id="pTrack">
          <div class="pillar-card">
            <span class="pillar-card__num">01</span>
            <p class="pillar-card__tag">Security</p>
            <p class="pillar-card__val">BCrypt + JPA</p>
            <p class="pillar-card__desc">Hashed passwords, role-gated routes, and session-controlled access at every layer.</p>
          </div>
          <div class="pillar-card">
            <span class="pillar-card__num">02</span>
            <p class="pillar-card__tag">Fairness</p>
            <p class="pillar-card__val">One Voice,<br>One Vote</p>
            <p class="pillar-card__desc">Database-enforced single-vote rule. Admin-approved contesters only. No loopholes.</p>
          </div>
          <div class="pillar-card">
            <span class="pillar-card__num">03</span>
            <p class="pillar-card__tag">Transparency</p>
            <p class="pillar-card__val">Live Count</p>
            <p class="pillar-card__desc">Real-time vote totals visible to all. Every result auditable and accountable.</p>
          </div>
        </div>
        <button class="stage-btn stage-btn--next" id="pNext" aria-label="Next">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
        </button>
      </div>
      <div class="pillars-dots" id="pDots"></div>
    </section>

    <section class="features">
      <div class="features__label reveal">
        <p class="features__label-eyebrow">Platform Features</p>
        <h2 class="features__label-heading">What <em>VoCho</em><br>includes</h2>
      </div>
      <div class="feat-row">
        <div class="feat-row__img reveal reveal--left"><div class="feat-row__img-inner"><img src="${pageContext.request.contextPath}/images/red.png" alt="Email-verified registration"></div></div>
        <div class="feat-row__text reveal reveal--right reveal-d1">
          <span class="feat-row__num">01</span><span class="feat-row__tag">Registration</span>
          <h3 class="feat-row__title">Email-Verified Registration</h3>
          <p class="feat-row__body">Every new account is confirmed via email before access is granted. No ghost voters, no duplicate entries — just a clean, verified roll.</p>
          <p class="feat-row__detail">BCrypt-hashed credentials on submission</p>
        </div>
      </div>
      <div class="feat-row feat-row--flip">
        <div class="feat-row__img reveal reveal--right"><div class="feat-row__img-inner"><img src="${pageContext.request.contextPath}/images/user.jpg" alt="Role-based login"></div></div>
        <div class="feat-row__text reveal reveal--left reveal-d1">
          <span class="feat-row__num">02</span><span class="feat-row__tag">Access Control</span>
          <h3 class="feat-row__title">Role-Based Login</h3>
          <p class="feat-row__body">Voters, contesters, and admins each land in their own session-gated space. No action crosses role boundaries — enforced on every single request.</p>
          <p class="feat-row__detail">Session invalidated on logout, no stale access</p>
        </div>
      </div>
      <div class="feat-row">
        <div class="feat-row__img reveal reveal--left"><div class="feat-row__img-inner"><img src="${pageContext.request.contextPath}/images/contest.png" alt="Contester applications"></div></div>
        <div class="feat-row__text reveal reveal--right reveal-d1">
          <span class="feat-row__num">03</span><span class="feat-row__tag">Candidacy</span>
          <h3 class="feat-row__title">Contester Applications</h3>
          <p class="feat-row__body">Candidates submit applications and appear on the ballot only after explicit admin approval. No self-promotion shortcuts.</p>
          <p class="feat-row__detail">Admin notified instantly on new application</p>
        </div>
      </div>
      <div class="feat-row feat-row--flip">
        <div class="feat-row__img reveal reveal--right"><div class="feat-row__img-inner"><img src="${pageContext.request.contextPath}/images/us.png" alt="Position cap rule"></div></div>
        <div class="feat-row__text reveal reveal--left reveal-d1">
          <span class="feat-row__num">04</span><span class="feat-row__tag">Integrity</span>
          <h3 class="feat-row__title">Position Cap Rule</h3>
          <p class="feat-row__body">Maximum 3 approved contesters per position slot — enforced at the database level. The rule can't be bypassed from the UI.</p>
          <p class="feat-row__detail">Constraint lives in the schema, not just the code</p>
        </div>
      </div>
      <div class="feat-row">
        <div class="feat-row__img reveal reveal--left"><div class="feat-row__img-inner"><img src="${pageContext.request.contextPath}/images/voting.png" alt="Live statistics"></div></div>
        <div class="feat-row__text reveal reveal--right reveal-d1">
          <span class="feat-row__num">05</span><span class="feat-row__tag">Transparency</span>
          <h3 class="feat-row__title">Live Vote Statistics</h3>
          <p class="feat-row__body">Dashboard shows real-time tallies the moment votes are cast. Every result is auditable and visible to all authorised parties.</p>
          <p class="feat-row__detail">No refresh needed — results update on vote submit</p>
        </div>
      </div>
      <div class="feat-row feat-row--flip">
        <div class="feat-row__img reveal reveal--right"><div class="feat-row__img-inner"><img src="${pageContext.request.contextPath}/images/profiles.png" alt="Profile management"></div></div>
        <div class="feat-row__text reveal reveal--left reveal-d1">
          <span class="feat-row__num">06</span><span class="feat-row__tag">Account</span>
          <h3 class="feat-row__title">Profile Management</h3>
          <p class="feat-row__body">Voters update their personal details and change passwords from a secure, session-gated profile panel. Changes take effect immediately.</p>
          <p class="feat-row__detail">Password change requires current password confirmation</p>
        </div>
      </div>
    </section>

  </main>

  <jsp:include page="/WEB-INF/views/fragment/footer.jsp" />

  <style>
    @keyframes livePulse { 0%,100%{opacity:1;transform:scale(1);} 50%{opacity:.5;transform:scale(1.4);} }
  </style>

  <script>
  var CTX = '${pageContext.request.contextPath}';

  /* ── Compact live results strip ─────────────────────── */
  (function () {
    function renderHomeResults(data) {
      var body = document.getElementById('homeResultsBody');
      if (!data || !data.labels || !data.labels.length) {
        body.innerHTML = '<span style="font-family:\'Syne\',sans-serif;font-size:.72rem;color:rgba(234,228,214,.3);letter-spacing:.1em;text-transform:uppercase;">No votes cast yet.</span>';
        return;
      }
      var maxV = Math.max.apply(null, data.votes.concat([1]));
      var html = '<div style="display:flex;flex-wrap:wrap;gap:8px;">';
      for (var i = 0; i < data.labels.length; i++) {
        var parts = data.labels[i].split(' (');
        var name  = parts[0];
        var pos   = (parts[1] || '').replace(')', '');
        var votes = data.votes[i] || 0;
        var pct   = Math.round((votes / maxV) * 100);
        var isLead = i === 0 || votes === Math.max.apply(null, data.votes);
        html += '<div style="flex:1;min-width:160px;background:#1a2f55;border:1px solid rgba(212,168,67,' + (isLead?'.3':'.1') + ');border-radius:3px;padding:10px 14px;position:relative;overflow:hidden;">';
        html += '<div style="position:absolute;left:0;top:0;bottom:0;width:' + pct + '%;background:rgba(212,168,67,' + (isLead?'.12':'.06') + ');transition:width .6s ease;"></div>';
        html += '<div style="position:relative;display:flex;align-items:center;justify-content:space-between;gap:8px;">';
        html += '<div><div style="font-family:\'Barlow Condensed\',sans-serif;font-size:1rem;font-weight:900;text-transform:uppercase;color:' + (isLead?'#d4a843':'#eae4d6') + ';letter-spacing:-.01em;line-height:1;">' + name + '</div>';
        if (pos) html += '<div style="font-family:\'Syne\',sans-serif;font-size:.58rem;font-weight:700;text-transform:uppercase;letter-spacing:.12em;color:rgba(234,228,214,.35);margin-top:2px;">' + pos + '</div>';
        html += '</div><div style="font-family:\'Barlow Condensed\',sans-serif;font-size:1.5rem;font-weight:900;color:' + (isLead?'#d4a843':'rgba(234,228,214,.7)') + ';flex-shrink:0;">' + votes + '</div></div></div>';
      }
      html += '</div>';
      body.innerHTML = html;
    }
    function goHome() {
      fetch(CTX + '/api/vote-stats').then(function(r){return r.ok?r.json():null;}).then(function(d){if(d)renderHomeResults(d);}).catch(function(){});
    }
    goHome(); setInterval(goHome, 10000);
  })();

  /* ── Pillars carousel ─────────────────────────────── */
  (function () {
    var cards   = Array.from(document.querySelectorAll('.pillar-card'));
    var dots    = document.getElementById('pDots');
    var btnPrev = document.getElementById('pPrev');
    var btnNext = document.getElementById('pNext');
    var total   = cards.length;
    var active  = 0;
    cards.forEach(function(_, i) {
      var d = document.createElement('button');
      d.className = 'p-dot' + (i === 0 ? ' active' : '');
      d.setAttribute('aria-label', 'Pillar ' + (i + 1));
      d.addEventListener('click', function() { go(i); });
      dots.appendChild(d);
    });
    function go(idx) {
      active = ((idx % total) + total) % total;
      cards.forEach(function(card, i) {
        card.classList.remove('state-center','state-left-1','state-right-1','state-left-2','state-right-2','state-hidden');
        var diff = i - active;
        if (diff >  total / 2) diff -= total;
        if (diff < -total / 2) diff += total;
        if      (diff ===  0) card.classList.add('state-center');
        else if (diff ===  1) card.classList.add('state-right-1');
        else if (diff === -1) card.classList.add('state-left-1');
        else if (diff ===  2) card.classList.add('state-right-2');
        else if (diff === -2) card.classList.add('state-left-2');
        else                  card.classList.add('state-hidden');
      });
      Array.from(dots.querySelectorAll('.p-dot')).forEach(function(d, i) { d.classList.toggle('active', i === active); });
    }
    btnPrev.addEventListener('click', function() { go(active - 1); });
    btnNext.addEventListener('click', function() { go(active + 1); });
    cards.forEach(function(card, i) { card.addEventListener('click', function() { if (i !== active) go(i); }); });
    go(0);
  })();

  /* ── Scroll reveal (fixed typo: IntersectionObserver) ── */
  (function () {
    var targets = Array.from(document.querySelectorAll('.reveal'));
    if (!targets.length) return;
    var observer = new IntersectionObserver(function(entries) {
      entries.forEach(function(entry) {
        if (entry.isIntersecting) { entry.target.classList.add('in-view'); observer.unobserve(entry.target); }
      });
    }, { threshold: 0.15 });
    targets.forEach(function(el) { observer.observe(el); });
  })();
  </script>

</body>
</html>
