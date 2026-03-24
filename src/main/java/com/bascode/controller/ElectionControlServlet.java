package com.bascode.controller;

import com.bascode.model.entity.Contester;
import com.bascode.model.entity.User;
import com.bascode.model.enums.ElectionPhase;
import com.bascode.model.enums.Position;
import com.bascode.model.enums.Role;
import com.bascode.repository.AdminAuditLogRepository;
import com.bascode.repository.ContesterRepository;
import com.bascode.repository.UserRepository;
import com.bascode.repository.VoteRepository;
import com.bascode.util.ServletUtil;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;


@WebServlet("/admin/election/control")
public class ElectionControlServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public static final String KEY_PHASE    = "election.phase";
    public static final String KEY_END_TIME = "election.endTime";
    public static final String KEY_WINNER   = "election.winner";

    /** Minimum approved contesters per position to allow election start */
    private static final int MIN_PER_POSITION = 2;
    /** Maximum approved contesters per position — no more applications after this */
    public static final int MAX_PER_POSITION = 3;

    private final UserRepository       userRepo       = new UserRepository();
    private final ContesterRepository  contesterRepo  = new ContesterRepository();
    private final VoteRepository       voteRepo       = new VoteRepository();
    private final AdminAuditLogRepository auditRepo   = new AdminAuditLogRepository();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(getServletContext());
        EntityManager em = emf.createEntityManager();
        try {
            User admin = ServletUtil.getCurrentUser(req, em, userRepo);
            if (admin == null || admin.getRole() != Role.ADMIN) {
                res.sendRedirect(req.getContextPath() + "/login-view?error=unauthorized");
                return;
            }

            String action = req.getParameter("action");
            String errorMsg = null;

            switch (action == null ? "" : action) {

               
                case "start": {
                    List<Contester> approved = contesterRepo.findApproved(em);

                    Map<Position, Long> perPos = approved.stream()
                            .collect(Collectors.groupingBy(Contester::getPosition, Collectors.counting())); if (perPos.isEmpty()) {
                        errorMsg = "Cannot start: no approved contesters found. "
                                + "Approve at least " + MIN_PER_POSITION + " per position.";
                        break;
                    }
                    boolean tooFew = perPos.values().stream().anyMatch(c -> c < MIN_PER_POSITION);
                    if (tooFew) {
                        errorMsg = "Cannot start: every position must have at least "
                                + MIN_PER_POSITION + " approved contesters. "
                                + "Check: " + perPos.entrySet().stream()
                                    .filter(e -> e.getValue() < MIN_PER_POSITION)
                                    .map(e -> e.getKey() + " (" + e.getValue() + ")")
                                    .collect(Collectors.joining(", "));
                        break;
                    }

                    // Parse duration
                    long durationMinutes = parseLong(req.getParameter("durationMinutes"), 0L);
                    durationMinutes = Math.max(0, Math.min(durationMinutes, 1440)); // cap at 24h

                    LocalDateTime endTime = durationMinutes > 0
                            ? LocalDateTime.now().plusMinutes(durationMinutes)
                            : null;

                    getServletContext().setAttribute(KEY_PHASE,    ElectionPhase.OPEN);
                    getServletContext().setAttribute(KEY_END_TIME, endTime);
                    getServletContext().setAttribute(KEY_WINNER,   null);

                    String durStr = durationMinutes > 0 ? durationMinutes + " min" : "unlimited";
                    logAudit(em, admin, "ELECTION_START",
                            "Election started. Duration: " + durStr
                            + ". Approved positions: " + perPos.keySet());
                    break;
                }

                /* ── PAUSE ──────────────────────────────────────────── */
                case "pause": {
                    getServletContext().setAttribute(KEY_PHASE, ElectionPhase.DRAFT);
                    // Keep endTime so resume knows the original end
                    logAudit(em, admin, "ELECTION_PAUSE", "Election paused by admin.");
                    break;
                }

                /* ── RESUME (re-open from pause) ────────────────────── */
                case "resume": {
                    getServletContext().setAttribute(KEY_PHASE, ElectionPhase.OPEN);
                    logAudit(em, admin, "ELECTION_RESUME", "Election resumed by admin.");
                    break;
                }

                /* ── STOP ───────────────────────────────────────────── */
                case "stop": {
                    List<Contester> approved = contesterRepo.findApproved(em);
                    Map<Long, Long> voteCounts = voteRepo.voteCountByContester(em);


                    Contester winner = approved.stream()
                            .max(Comparator.comparingLong(c -> voteCounts.getOrDefault(c.getId(), 0L)))
                            .orElse(null);

                    getServletContext().setAttribute(KEY_PHASE,    ElectionPhase.CLOSED);
                    getServletContext().setAttribute(KEY_END_TIME, null);

                    if (winner != null) {
                        long wVotes = voteCounts.getOrDefault(winner.getId(), 0L);
                        String wName = winner.getUser().getFirstName() + " " + winner.getUser().getLastName();
                        String wPos = winner.getPosition().toString();

                       
                        String winnerJson = "{\"name\":\"" + escape(wName) + "\","
                                + "\"position\":\"" + escape(wPos) + "\","
                                + "\"votes\":" + wVotes + "}";
                        getServletContext().setAttribute(KEY_WINNER, winnerJson);

                        logAudit(em, admin, "ELECTION_STOP",
                                "Election stopped. Winner: " + wName + " (" + wPos + ") — " + wVotes + " votes.");
                    } else {
                        getServletContext().setAttribute(KEY_WINNER, null);
                        logAudit(em, admin, "ELECTION_STOP", "Election stopped. No votes cast.");
                    }
                    break;
                }

                default:
                    errorMsg = "Unknown election action: " + action;
            }

            if (errorMsg != null) {
                req.getSession().setAttribute("error", errorMsg);
            }

            // Commit audit log
            if (!em.getTransaction().isActive()) em.getTransaction().begin();
            em.getTransaction().commit();

        } catch (Exception ex) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw ex;
        } finally {
            em.close();
        }

        res.sendRedirect(req.getContextPath() + "/admin/dashboard");
    }

    /* ── Helpers ─────────────────────────────────────────────────────── */
    private long parseLong(String s, long def) {
        if (s == null || s.isBlank()) return def;
        try { return Long.parseLong(s.trim()); } catch (NumberFormatException e) { return def; }
    }

    private String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    private void logAudit(EntityManager em, User admin, String action, String detail) {
        try {
            if (!em.getTransaction().isActive()) em.getTransaction().begin();
            auditRepo.log(em, admin, action, detail);
        } catch (Exception ignored) {}
    }
}
