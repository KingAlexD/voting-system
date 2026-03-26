/**
 * winner-popup.js  —  VoCho
 *
 * Polls /api/election-status every 6 seconds from any page (logged in or not).
 * When phase === 'CLOSED' and winner array is present, shows a full-screen
 * celebration popup listing the winner for every position.
 *
 * Usage (add to every page footer or the shared footer include):
 *   <script src="${pageContext.request.contextPath}/js/winner-popup.js"></script>
 *
 * The response shape expected from /api/election-status:
 * {
 *   "phase": "CLOSED",
 *   "winner": [
 *     { "name": "Alice Smith",  "position": "PRESIDENT",     "votes": 7 },
 *     { "name": "Bob Jones",    "position": "VICE_PRESIDENT", "votes": 4 },
 *     { "name": "Carol White",  "position": "SECRETARY",      "votes": 6 },
 *     { "name": "Dave Brown",   "position": "TREASURER",      "votes": 5 }
 *   ]
 * }
 */
(function () {
  'use strict';

  /* ── Derive context path ─────────────────────────────── */
  var CTX = (function () {
    var el = document.querySelector('[data-ctx]');
    if (el) return el.dataset.ctx;
    var m = location.pathname.match(/^(\/[^/]+)/);
    return m ? m[1] : '';
  })();

  var STORAGE_KEY = 'vocho_winner_seen';
  var popupEl = null;
  var winnerShown = sessionStorage.getItem(STORAGE_KEY) === '1';

  /* ── Inject popup HTML + styles once ────────────────── */
  function ensurePopup() {
    if (popupEl) return;

    var style = document.createElement('style');
    style.textContent = [
      /* overlay */
      '.winner-overlay{display:none;position:fixed;inset:0;z-index:9999;background:rgba(9,18,36,.96);backdrop-filter:blur(8px);align-items:center;justify-content:center;padding:24px;}',
      '.winner-overlay.show{display:flex;animation:wFadeIn .5s ease both;}',
      '@keyframes wFadeIn{from{opacity:0;}to{opacity:1;}}',

      /* box */
      '.winner-box{background:#0e1f3a;border:2px solid #d4a843;border-radius:6px;max-width:600px;width:100%;max-height:88vh;overflow-y:auto;text-align:center;padding:44px 40px 36px;box-shadow:0 0 80px rgba(212,168,67,.25),0 32px 80px rgba(0,0,0,.7);animation:wBoxIn .55s cubic-bezier(.22,1,.36,1) both;}',
      '@keyframes wBoxIn{from{opacity:0;transform:scale(.88)translateY(32px);}to{opacity:1;transform:scale(1)translateY(0);}}',

      /* trophy */
      '.winner-trophy{font-size:3.2rem;margin-bottom:6px;display:block;animation:wBounce 1s .5s ease both;}',
      '@keyframes wBounce{0%{transform:scale(0);}60%{transform:scale(1.2);}80%{transform:scale(.95);}100%{transform:scale(1);}}',

      /* headings */
      '.winner-eyebrow{font-family:\'Syne\',\'Segoe UI\',sans-serif;font-size:.62rem;font-weight:800;text-transform:uppercase;letter-spacing:.22em;color:#d4a843;margin-bottom:8px;}',
      '.winner-headline{font-family:\'Barlow Condensed\',\'Arial Narrow\',sans-serif;font-size:clamp(2rem,5vw,3.2rem);font-weight:900;text-transform:uppercase;color:#eae4d6;line-height:1;letter-spacing:-.02em;margin-bottom:22px;}',

      /* per-position winner cards */
      '.winner-grid{display:flex;flex-direction:column;gap:10px;margin-bottom:24px;text-align:left;}',
      '.winner-card{display:flex;align-items:center;justify-content:space-between;gap:16px;background:rgba(212,168,67,.07);border:1px solid rgba(212,168,67,.2);border-radius:4px;padding:14px 20px;}',
      '.winner-card__left{}',
      '.winner-card__pos{font-family:\'Syne\',sans-serif;font-size:.58rem;font-weight:800;text-transform:uppercase;letter-spacing:.18em;color:rgba(212,168,67,.65);margin-bottom:3px;}',
      '.winner-card__name{font-family:\'Barlow Condensed\',sans-serif;font-size:1.25rem;font-weight:900;text-transform:uppercase;color:#eae4d6;letter-spacing:-.01em;line-height:1;}',
      '.winner-card__votes{font-family:\'Barlow Condensed\',sans-serif;font-size:1.5rem;font-weight:900;color:#d4a843;letter-spacing:-.02em;white-space:nowrap;}',
      '.winner-card__votes small{font-size:.7rem;font-family:\'Syne\',sans-serif;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:rgba(234,228,214,.35);margin-left:4px;vertical-align:middle;}',

      /* dismiss button */
      '.winner-close{font-family:\'Syne\',sans-serif;font-size:.72rem;font-weight:800;text-transform:uppercase;letter-spacing:.1em;padding:12px 36px;background:#d4a843;color:#0e1f3a;border:none;border-radius:3px;cursor:pointer;transition:background .18s,transform .13s;margin-top:4px;}',
      '.winner-close:hover{background:#e8c054;transform:translateY(-1px);}',

      /* confetti */
      '.confetti-piece{position:fixed;width:8px;height:8px;opacity:0;animation:cFall linear forwards;pointer-events:none;z-index:10000;border-radius:2px;}',
      '@keyframes cFall{0%{transform:translateY(-20px) rotate(0deg);opacity:1;}100%{transform:translateY(110vh) rotate(720deg);opacity:0;}}'
    ].join('');
    document.head.appendChild(style);

    popupEl = document.createElement('div');
    popupEl.className = 'winner-overlay';
    popupEl.innerHTML =
      '<div class="winner-box">' +
        '<span class="winner-trophy">&#127942;</span>' +
        '<p class="winner-eyebrow">Election Results</p>' +
        '<div class="winner-headline">And the winners are&hellip;</div>' +
        '<div class="winner-grid" id="winnerGrid"></div>' +
        '<p style="font-size:.8rem;font-weight:300;color:rgba(234,228,214,.4);margin-bottom:20px;line-height:1.7;">The election has concluded. Congratulations to all winners!</p>' +
        '<button class="winner-close" onclick="voChoDismissWinner()">Dismiss</button>' +
      '</div>';
    document.body.appendChild(popupEl);
  }

  /* ── Show the popup ─────────────────────────────────── */
  function showWinner(winners) {
    ensurePopup();

    var grid = document.getElementById('winnerGrid');
    grid.innerHTML = '';

    // winners is an array of {name, position, votes}
    var list = Array.isArray(winners) ? winners : [winners];
    list.forEach(function (w) {
      var card = document.createElement('div');
      card.className = 'winner-card';
      card.innerHTML =
        '<div class="winner-card__left">' +
          '<div class="winner-card__pos">' + (w.position || '') + '</div>' +
          '<div class="winner-card__name">' + (w.name || 'Winner') + '</div>' +
        '</div>' +
        '<div class="winner-card__votes">' +
          (w.votes || 0) + '<small>vote' + (w.votes !== 1 ? 's' : '') + '</small>' +
        '</div>';
      grid.appendChild(card);
    });

    popupEl.classList.add('show');
    launchConfetti();
    sessionStorage.setItem(STORAGE_KEY, '1');
    winnerShown = true;
  }

  /* Exposed so the inline onclick can reach it */
  window.voChoDismissWinner = function () {
    if (popupEl) popupEl.classList.remove('show');
  };

  /* ── Confetti ────────────────────────────────────────── */
  function launchConfetti() {
    var colors = ['#d4a843', '#e8c054', '#c45c3a', '#eae4d6', '#6de08a'];
    for (var i = 0; i < 90; i++) {
      (function (i) {
        setTimeout(function () {
          var el = document.createElement('div');
          el.className = 'confetti-piece';
          el.style.left = Math.random() * 100 + 'vw';
          el.style.background = colors[Math.floor(Math.random() * colors.length)];
          el.style.animationDuration = (2 + Math.random() * 3) + 's';
          document.body.appendChild(el);
          setTimeout(function () { el.remove(); }, 6000);
        }, i * 38);
      })(i);
    }
  }

  /* ── Poll loop ───────────────────────────────────────── */
  function poll() {
    fetch(CTX + '/api/election-status')
      .then(function (r) { return r.ok ? r.json() : null; })
      .then(function (d) {
        if (!d) return;

        // Reset seen-flag when a new election starts
        if (d.phase === 'OPEN') {
          winnerShown = false;
          sessionStorage.removeItem(STORAGE_KEY);
        }

        // Show winners when election is closed and we haven't shown them yet
        if ((d.phase === 'CLOSED' || d.phase === 'RESULTS') && d.winner && !winnerShown) {
          // winner can be an array (new shape) or object (legacy single-winner)
          showWinner(d.winner);
        }
      })
      .catch(function () {});
  }

  // Also let inline scripts call showWinner directly
  window.showWinnerPopup = showWinner;

  // Start polling once DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function () { poll(); setInterval(poll, 6000); });
  } else {
    poll();
    setInterval(poll, 6000);
  }
})();
