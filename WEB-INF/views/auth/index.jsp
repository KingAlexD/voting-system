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

  <jsp:include page="/WEB-INF/views/fragment/navbar.jsp"/>

  <main>

    
    <section class="hero">
      <div class="hero__text">
        <p class="hero__eyebrow">Voice &amp; Choice Platform</p>

        <h1 class="catchphrase">
          <span class="word word-1">Own</span>
          <span class="word word-2">your</span><br>
          <span class="vc word word-3">Voice.</span>
          <span class="word word-4">Make your</span><br>
          <span class="vc word word-5">Choice</span>
        </h1>

        <div class="hero__cta">
          <a href="${pageContext.request.contextPath}/register-view" class="btn-fill">Create Account</a>
          <a href="${pageContext.request.contextPath}/login-view" class="btn-ghost-link">Sign In</a>
        </div>

        <div class="hero__trust">
          <span class="trust-dot"></span>
          Secure &middot; Verified &middot; Session-protected
        </div>
      </div>

      <div>
        <img src="${pageContext.request.contextPath}/images/vote.png" class="protest">
      </div>
    </section>
    
    
    <section class="pillars-section">

      <div class="pillars-header reveal">
        <h2 class="pillars-heading">Built on <em>three pillars</em></h2>
      </div>

      <div class="pillars-stage">

        <button class="stage-btn stage-btn--prev" id="pPrev" aria-label="Previous">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
               stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <path d="M19 12H5M12 19l-7-7 7-7"/>
          </svg>
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
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
               stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <path d="M5 12h14M12 5l7 7-7 7"/>
          </svg>
        </button>

      </div>

      <div class="pillars-dots" id="pDots"></div>

    </section>

    <section class="features">

      <div class="features__label reveal">
        <p class="features__label-eyebrow">Platform Features</p>
        <h2 class="features__label-heading">What <em>VoCho</em><br>includes</h2>
      </div>

      <!-- 01 -->
      <div class="feat-row">
        <div class="feat-row__img reveal reveal--left">
          <div class="feat-row__img-inner">
            <img src="${pageContext.request.contextPath}/images/raise.png" alt="Email-verified registration">
          </div>
        </div>
        <div class="feat-row__text reveal reveal--right reveal-d1">
          <span class="feat-row__num">01</span>
          <span class="feat-row__tag">Registration</span>
          <h3 class="feat-row__title">Email-Verified Registration</h3>
          <p class="feat-row__body">Every new account is confirmed via email before access is granted. No ghost voters, no duplicate entries — just a clean, verified roll.</p>
          <p class="feat-row__detail">BCrypt-hashed credentials on submission</p>
        </div>
      </div>
      <div class="feat-row feat-row--flip">
        <div class="feat-row__img reveal reveal--right">
          <div class="feat-row__img-inner">
            <img src="${pageContext.request.contextPath}/images/buzzer.png" alt="Role-based login">
          </div>
        </div>
        <div class="feat-row__text reveal reveal--left reveal-d1">
          <span class="feat-row__num">02</span>
          <span class="feat-row__tag">Access Control</span>
          <h3 class="feat-row__title">Role-Based Login</h3>
          <p class="feat-row__body">Voters, contesters, and admins each land in their own session-gated space. No action crosses role boundaries — enforced on every single request.</p>
          <p class="feat-row__detail">Session invalidated on logout, no stale access</p>
        </div>
      </div>

    
      <div class="feat-row">
        <div class="feat-row__img reveal reveal--left">
          <div class="feat-row__img-inner">
            <img src="${pageContext.request.contextPath}/images/us.png" alt="Contester applications">
          </div>
        </div>
        <div class="feat-row__text reveal reveal--right reveal-d1">
          <span class="feat-row__num">03</span>
          <span class="feat-row__tag">Candidacy</span>
          <h3 class="feat-row__title">Contester Applications</h3>
          <p class="feat-row__body">Candidates submit applications and appear on the ballot only after explicit admin approval. No self-promotion shortcuts.</p>
          <p class="feat-row__detail">Admin notified instantly on new application</p>
        </div>
      </div>

      <div class="feat-row feat-row--flip">
        <div class="feat-row__img reveal reveal--right">
          <div class="feat-row__img-inner">
            <img src="${pageContext.request.contextPath}/images/raise.png" alt="Position cap rule">
          </div>
        </div>
        <div class="feat-row__text reveal reveal--left reveal-d1">
          <span class="feat-row__num">04</span>
          <span class="feat-row__tag">Integrity</span>
          <h3 class="feat-row__title">Position Cap Rule</h3>
          <p class="feat-row__body">Maximum 3 approved contesters per position slot — enforced at the database level. The rule can't be bypassed from the UI.</p>
          <p class="feat-row__detail">Constraint lives in the schema, not just the code</p>
        </div>
      </div>

      <!-- 05 -->
      <div class="feat-row">
        <div class="feat-row__img reveal reveal--left">
          <div class="feat-row__img-inner">
            <img src="${pageContext.request.contextPath}/images/voting.png" alt="Live statistics">
          </div>
        </div>
        <div class="feat-row__text reveal reveal--right reveal-d1">
          <span class="feat-row__num">05</span>
          <span class="feat-row__tag">Transparency</span>
          <h3 class="feat-row__title">Live Vote Statistics</h3>
          <p class="feat-row__body">Dashboard shows real-time tallies the moment votes are cast. Every result is auditable and visible to all authorised parties.</p>
          <p class="feat-row__detail">No refresh needed — results update on vote submit</p>
        </div>
      </div>

      <!-- 06 — flipped -->
      <div class="feat-row feat-row--flip">
        <div class="feat-row__img reveal reveal--right">
          <div class="feat-row__img-inner">
            <img src="${pageContext.request.contextPath}/images/raise.png" alt="Profile management">
          </div>
        </div>
        <div class="feat-row__text reveal reveal--left reveal-d1">
          <span class="feat-row__num">06</span>
          <span class="feat-row__tag">Account</span>
          <h3 class="feat-row__title">Profile Management</h3>
          <p class="feat-row__body">Voters update their personal details and change passwords from a secure, session-gated profile panel. Changes take effect immediately.</p>
          <p class="feat-row__detail">Password change requires current password confirmation</p>
        </div>
      </div>

    </section>

  </main>

  <jsp:include page="/WEB-INF/views/fragment/footer.jsp" />

  <script>
  /* ── Pillars carousel ─────────────────────────────────── */
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
      Array.from(dots.querySelectorAll('.p-dot')).forEach(function(d, i) {
        d.classList.toggle('active', i === active);
      });
    }

    btnPrev.addEventListener('click', function() { go(active - 1); });
    btnNext.addEventListener('click', function() { go(active + 1); });
    cards.forEach(function(card, i) {
      card.addEventListener('click', function() { if (i !== active) go(i); });
    });
    go(0);
  })();

  (function () {
    var targets = Array.from(document.querySelectorAll('.reveal'));

    if (!targets.length) return;

    var observer = new IntersectionObserver(function(entries) {
      entries.forEach(function(entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add('in-view');
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.15 });

    targets.forEach(function(el) { observer.observe(el); });
  })();
  </script>

</body>
</html>
