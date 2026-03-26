package com.bascode.controller;

import com.bascode.model.enums.ElectionPhase;
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

/**
 * GET /api/election-status
 *
 * Polled by winner-popup.js every 6 seconds from any page.
 *
 * Response shape (matches what winner-popup.js expects):
 * {
 *   "phase"      : "OPEN" | "DRAFT" | "CLOSED" | "RESULTS",
 *   "secondsLeft": 3600,        // present & >= 0 when OPEN with a timer, else null
 *   "winner"     : { "name":"...", "position":"...", "votes":12 }  // or null
 * }
 *
 * Also handles auto-close: if phase is OPEN and the endTime has passed,
 * this endpoint transitions the phase to CLOSED and computes the winner
 * (same logic as the Stop action in ElectionControlServlet).
 */
@WebServlet("/api/election-status")
public class ElectionStatusServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

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
                    // Compute winner if not already set
                    if (ctx.getAttribute(ElectionControlServlet.KEY_WINNER) == null) {
                        computeAndCacheWinner(ctx);
                    }
                }
            }
        }

        // ── Build seconds remaining ───────────────────────────────────────────
        Long secondsLeft = null;
        if (phase == ElectionPhase.OPEN && endTime != null) {
            long s = ChronoUnit.SECONDS.between(LocalDateTime.now(), endTime);
            secondsLeft = Math.max(0, s);
        }

        // ── Get winner JSON ───────────────────────────────────────────────────
        Object winnerRaw = ctx.getAttribute(ElectionControlServlet.KEY_WINNER);
        String winnerJson = (winnerRaw instanceof String) ? (String) winnerRaw : "null";

        // ── Assemble response ─────────────────────────────────────────────────
        StringBuilder json = new StringBuilder("{");
        json.append("\"phase\":\"").append(phase.name()).append("\"");
        json.append(",\"secondsLeft\":").append(secondsLeft != null ? secondsLeft : "null");
        json.append(",\"winner\":").append(winnerJson);
        json.append("}");

        response.getWriter().write(json.toString());
    }

    /**
     * Finds the approved contester with the most votes and stores their
     * data as a JSON string in ServletContext under KEY_WINNER.
     */
    private void computeAndCacheWinner(ServletContext ctx) {
        EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(ctx);
        if (emf == null) return;
        EntityManager em = emf.createEntityManager();
        try {
            com.bascode.repository.ContesterRepository contesterRepo =
                    new com.bascode.repository.ContesterRepository();
            com.bascode.repository.VoteRepository voteRepo =
                    new com.bascode.repository.VoteRepository();

            java.util.List<com.bascode.model.entity.Contester> approved =
                    contesterRepo.findApproved(em);
            java.util.Map<Long, Long> voteCounts = voteRepo.voteCountByContester(em);

            com.bascode.model.entity.Contester winner = approved.stream()
                    .max(java.util.Comparator.comparingLong(
                            c -> voteCounts.getOrDefault(c.getId(), 0L)))
                    .orElse(null);

            if (winner != null) {
                long wVotes = voteCounts.getOrDefault(winner.getId(), 0L);
                String wName = winner.getUser().getFirstName() + " "
                        + winner.getUser().getLastName();
                String wPos = winner.getPosition().name();
                String json = "{\"name\":\"" + esc(wName) + "\","
                        + "\"position\":\"" + esc(wPos) + "\","
                        + "\"votes\":" + wVotes + "}";
                ctx.setAttribute(ElectionControlServlet.KEY_WINNER, json);
            }
        } finally {
            em.close();
        }
    }

    private String esc(String s) {
        return s == null ? "" : s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
