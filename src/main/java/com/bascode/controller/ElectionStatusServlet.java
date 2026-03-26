package com.bascode.controller;

import com.bascode.model.entity.Contester;
import com.bascode.model.enums.ElectionPhase;
import com.bascode.repository.ContesterRepository;
import com.bascode.repository.VoteRepository;
import com.bascode.util.AppConfigUtil;
import com.bascode.util.ServletUtil;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Map;

/**
 * GET /api/election-status
 *
 * Polled by winner-popup.js every 6 seconds from any page (logged-in or not).
 *
 * Response shape:
 * {
 *   "phase"      : "OPEN" | "DRAFT" | "CLOSED" | "RESULTS",
 *   "secondsLeft": 3600,   // >= 0 when OPEN with a timer, else null
 *   "winner"     : [       // array — one entry per position — or null
 *     { "name":"Alice Smith", "position":"PRESIDENT",     "votes": 7 },
 *     { "name":"Bob Jones",   "position":"VICE_PRESIDENT","votes": 4 },
 *     ...
 *   ]
 * }
 *
 * When the timer expires this endpoint auto-closes the election, computes
 * per-position winners, resets all contesters back to voters, and caches
 * the result so subsequent polls are cheap.
 */
@WebServlet("/api/election-status")
public class ElectionStatusServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final ContesterRepository contesterRepo = new ContesterRepository();
    private final VoteRepository      voteRepo      = new VoteRepository();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-store");

        ServletContext ctx = getServletContext();
        ElectionPhase phase = AppConfigUtil.getElectionPhase(ctx);
        LocalDateTime endTime = (LocalDateTime) ctx.getAttribute(ElectionControlServlet.KEY_END_TIME);

        // ── Auto-close when timer expires ─────────────────────────────────────
        if (phase == ElectionPhase.OPEN && endTime != null
                && LocalDateTime.now().isAfter(endTime)) {

            synchronized (this) {
                // Re-check inside lock to prevent double-close from concurrent requests
                phase = AppConfigUtil.getElectionPhase(ctx);
                if (phase == ElectionPhase.OPEN) {
                    AppConfigUtil.setElectionPhase(ctx, ElectionPhase.CLOSED);
                    ctx.setAttribute(ElectionControlServlet.KEY_END_TIME, null);
                    phase = ElectionPhase.CLOSED;

                    // Compute winners and reset contesters to voters in one DB call
                    if (ctx.getAttribute(ElectionControlServlet.KEY_WINNER) == null) {
                        computeWinnersAndReset(ctx);
                    }
                }
            }
        }

        // ── Seconds remaining ─────────────────────────────────────────────────
        Long secondsLeft = null;
        if (phase == ElectionPhase.OPEN && endTime != null) {
            long s = ChronoUnit.SECONDS.between(LocalDateTime.now(), endTime);
            secondsLeft = Math.max(0L, s);
        }

        // ── Winner JSON (already a JSON array string, or "null") ──────────────
        Object winnerRaw = ctx.getAttribute(ElectionControlServlet.KEY_WINNER);
        // winnerRaw is the raw JSON array string built by ElectionControlServlet
        String winnerJson = (winnerRaw instanceof String && !((String) winnerRaw).isBlank())
                ? (String) winnerRaw
                : "null";

        // ── Build response ────────────────────────────────────────────────────
        String json = "{"
                + "\"phase\":\"" + phase.name() + "\","
                + "\"secondsLeft\":" + (secondsLeft != null ? secondsLeft : "null") + ","
                + "\"winner\":" + winnerJson
                + "}";

        response.getWriter().write(json);
    }

    /**
     * Computes per-position winners, caches the JSON in ServletContext,
     * then demotes all approved contesters back to voters and wipes vote counts.
     * Called only once — inside the synchronized block above.
     */
    private void computeWinnersAndReset(ServletContext ctx) {
        EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(ctx);
        if (emf == null) return;

        EntityManager em = emf.createEntityManager();
        try {
            List<Contester> approved = contesterRepo.findApproved(em);
            Map<Long, Long> voteCounts = voteRepo.voteCountByContester(em);

            // Build and cache the winners JSON array
            String winnersJson = ElectionControlServlet.buildWinnersJson(approved, voteCounts);
            ctx.setAttribute(ElectionControlServlet.KEY_WINNER, winnersJson);

            // Reset all contesters → voters inside a transaction
            em.getTransaction().begin();
            for (Contester c : approved) {
                voteRepo.deleteVotesByContesterId(em, c.getId());

                com.bascode.model.entity.User u = c.getUser();
                if (u != null && u.getRole() == com.bascode.model.enums.Role.CONTESTER) {
                    u.setRole(com.bascode.model.enums.Role.VOTER);
                    em.merge(u);
                }

                c.setStatus(com.bascode.model.enums.ContesterStatus.DENIED);
                c.setRequestedPosition(null);
                em.merge(c);
            }
            em.getTransaction().commit();

        } catch (Exception ex) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            ex.printStackTrace();
        } finally {
            em.close();
        }
    }
}
