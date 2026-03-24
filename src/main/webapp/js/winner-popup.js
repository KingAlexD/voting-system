/**
 * winner-popup.js
 * Drop this script into the footer include or every JSP.
 * Polls /api/election-status every 6 seconds from any page (logged in or not).
 * When phase === 'CLOSED' and winner is present, shows a full-screen celebration popup.
 *
 * Usage: <script src="${pageContext.request.contextPath}/js/winner-popup.js"></script>
 * Requires the VoCho dashboard.css colour variables already on the page.
 */
(function () {
  'use strict';

  var CTX = (function() {
    // Derive context path from a known element if available, else guess from URL
    var el = document.querySelector('[data-ctx]');
    if (el) return el.dataset.ctx;
    var m = location.pathname.match(/^(\/[^/]+)/);
    return m ? m[1] : '';
  })();

  var STORAGE_KEY = 'vocho_winner_seen';
  var popupEl = null;
  var winnerShown = sessionStorage.getItem(STORAGE_KEY) === '1';

  /* ── Inject popup HTML once ─────────────────────── */
  function ensurePopup() {
    if (popupEl) return;
    var style = document.createElement('style');
    style.textContent = [
      '.winner-overlay{display:none;position:fixed;inset:0;z-index:9999;background:rgba(9,18,36,.96);backdrop-filter:blur(8px);align-items:center;justify-content:center;padding:24px;}',
      '.winner-overlay.show{display:flex;animation:wFadeIn .5s ease both;}',
      '@keyframes wFadeIn{from{opacity:0;}to{opacity:1;}}',
      '.winner-box{background:#0e1f3a;border:2px solid #d4a843;border-radius:6px;max-width:520px;width:100%;text-align:center;padding:48px 40px;box-shadow:0 0 80px rgba(212,168,67,.25),0 32px 80px rgba(0,0,0,.7);animation:wBoxIn .55s cubic-bezier(.22,1,.36,1) both;}',
      '@keyframes wBoxIn{from{opacity:0;transform:scale(.88)translateY(32px);}to{opacity:1;transform:scale(1)translateY(0);}}',
      '.winner-trophy{font-size:3.6rem;margin-bottom:8px;display:block;animation:wBounce 1s .5s ease both;}',
      '@keyframes wBounce{0%{transform:scale(0);}60%{transform:scale(1.2);}80%{transform:scale(.95);}100%{transform:scale(1);}}',
      '.winner-eyebrow{font-family:\'Syne\',\'Segoe UI\',sans-serif;font-size:.62rem;font-weight:800;text-transform:uppercase;letter-spacing:.22em;color:#d4a843;margin-bottom:10px;}',
      '.winner-headline{font-family:\'Barlow Condensed\',\'Arial Narrow\',sans-serif;font-size:clamp(2.2rem,6vw,3.8rem);font-weight:900;text-transform:uppercase;color:#eae4d6;line-height:1;letter-spacing:-.02em;margin-bottom:8px;}',
      '.winner-pos{font-family:\'Syne\',sans-serif;font-size:.72rem;font-weight:800;text-transform:uppercase;letter-spacing:.14em;background:rgba(212,168,67,.15);color:#d4a843;border:1px solid rgba(212,168,67,.3);border-radius:3px;padding:5px 14px;display:inline-block;margin-bottom:6px;}',
      '.winner-votes{font-family:\'Barlow Condensed\',sans-serif;font-size:2.4rem;font-weight:900;color:#d4a843;letter-spacing:-.03em;margin:10px 0 24px;}',
      '.winner-votes small{font-size:.9rem;color:rgba(234,228,214,.4);font-family:\'Syne\',sans-serif;font-weight:700;letter-spacing:.06em;text-transform:uppercase;margin-left:6px;vertical-align:middle;}',
      '.winner-close{font-family:\'Syne\',sans-serif;font-size:.72rem;font-weight:800;text-transform:uppercase;letter-spacing:.1em;padding:12px 32px;background:#d4a843;color:#0e1f3a;border:none;border-radius:3px;cursor:pointer;transition:background .18s,transform .13s;}',
      '.winner-close:hover{background:#e8c054;transform:translateY(-1px);}',
      '.confetti-piece{position:fixed;width:8px;height:8px;opacity:0;animation:cFall linear forwards;pointer-events:none;z-index:10000;border-radius:2px;}',
      '@keyframes cFall{0%{transform:translateY(-20px) rotate(0deg);opacity:1;}100%{transform:translateY(110vh) rotate(720deg);opacity:0;}}'
    ].join('');
    document.head.appendChild(style);

    popupEl = document.createElement('div');
    popupEl.className = 'winner-overlay';
    popupEl.innerHTML =
      '<div class="winner-box">' +
        '<span class="winner-trophy">&#127942;</span>' +
        '<p class="winner-eyebrow">Election Result</p>' +
        '<div class="winner-headline" id="wName"></div>' +
        '<div class="winner-pos" id="wPos"></div>' +
        '<div class="winner-votes" id="wVotes"></div>' +
        '<p style="font-size:.82rem;font-weight:300;color:rgba(234,228,214,.45);margin-bottom:22px;line-height:1.7;">The election has concluded. Congratulations to the winner!</p>' +
        '<button class="winner-close" onclick="this.closest(\'.winner-overlay\').classList.remove(\'show\')">Dismiss</button>' +
      '</div>';
    document.body.appendChild(popupEl);
  }

  /* ── Show the popup ─────────────────────────────── */
  function showWinner(winner) {
    ensurePopup();
    document.getElementById('wName').textContent = winner.name || 'Winner';
    document.getElementById('wPos').textContent  = winner.position || '';
    document.getElementById('wVotes').innerHTML  = (winner.votes || 0) + '<small>votes</small>';
    popupEl.classList.add('show');
    launchConfetti();
    sessionStorage.setItem(STORAGE_KEY, '1');
    winnerShown = true;
  }

  /* ── Confetti ────────────────────────────────────── */
  function launchConfetti() {
    var colors = ['#d4a843','#e8c054','#c45c3a','#eae4d6','#6de08a'];
    for (var i = 0; i < 80; i++) {
      (function(i) {
        setTimeout(function() {
          var el = document.createElement('div');
          el.className = 'confetti-piece';
          el.style.left = Math.random() * 100 + 'vw';
          el.style.background = colors[Math.floor(Math.random() * colors.length)];
          el.style.animationDuration = (2 + Math.random() * 3) + 's';
          el.style.animationDelay = '0s';
          document.body.appendChild(el);
          setTimeout(function() { el.remove(); }, 6000);
        }, i * 40);
      })(i);
    }
  }

  /* ── Poll loop ───────────────────────────────────── */
  function poll() {
    fetch(CTX + '/api/election-status')
      .then(function(r) { return r.ok ? r.json() : null; })
      .then(function(d) {
        if (!d) return;
        if (d.phase === 'OPEN') {
          // Reset when new election starts
          winnerShown = false;
          sessionStorage.removeItem(STORAGE_KEY);
        }
        if ((d.phase === 'CLOSED' || d.phase === 'RESULTS') && d.winner && !winnerShown) {
          showWinner(d.winner);
        }
      })
      .catch(function() {});
  }

  // Also expose for direct call from inline scripts
  window.showWinnerPopup = showWinner;

  // Start polling when DOM ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function() { poll(); setInterval(poll, 6000); });
  } else {
    poll(); setInterval(poll, 6000);
  }
})();
