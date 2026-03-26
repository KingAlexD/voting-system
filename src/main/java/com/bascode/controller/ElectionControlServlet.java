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
import com.bascode.util.AppConfigUtil;
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

    /**
     * Phase is stored via AppConfigUtil.setElectionPhase() which uses the
     * ServletContext key "electionPhase". This is the SAME key that
     * AppConfigUtil.getElectionPhase() and AppConfigUtil.isElectionOpen() read
     * from — so VoteServlet's election gate now works correctly.
     *
     * The old bug was using a separate key "election.phase" that nothing else read.
     */
    public static final String KEY_WINNER   = "election.winner";
    public static final String KEY_END_TIME = "election.endTime"; // LocalDateTime or null

    private static final int MIN_PER_POSITION = 2;

    private final UserRepository          userRepo      = new UserRepository();
    private final ContesterRepository     contesterRepo = new ContesterRepository();
    private final VoteRepository          voteRepo      = new VoteRepository();
    private final AdminAuditLogRepository auditRepo     = new AdminAuditLogRepository();

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

            em.getTransaction().begin();

            switch (action == null ? "" : action) {

                // ── START ─────────────────────────────────────────────────────
                case "start": {
                    List<Contester> approved = contesterRepo.findApproved(em);

                    Map<Position, Long> perPos = approved.stream()
                            .collect(Collectors.groupingBy(Contester::getPosition, Collectors.counting()));

                    if (perPos.isEmpty()) {
                        errorMsg = "Cannot start: no approved contesters found. "
                                + "Approve at least " + MIN_PER_POSITION + " per position.";
                        break;
                    }

                    List<String> underStaffed = perPos.entrySet().stream()
                            .filter(e -> e.getValue() < MIN_PER_POSITION)
                            .map(e -> e.getKey().name() + " (" + e.getValue() + ")")
                            .collect(Collectors.toList());

                    if (!underStaffed.isEmpty()) {
                        errorMsg = "Cannot start: every position needs at least "
                                + MIN_PER_POSITION + " approved contesters. "
                                + "Short: " + String.join(", ", underStaffed);
                        break;
                    }

                    long durationMinutes = parseLong(req.getParameter("durationMinutes"), 0L);
                    durationMinutes = Math.max(0, Math.min(durationMinutes, 1440));

                    LocalDateTime endTime = durationMinutes > 0
                            ? LocalDateTime.now().plusMinutes(durationMinutes)
                            : null;

                    // Store phase where AppConfigUtil and VoteServlet can both read it
                    AppConfigUtil.setElectionPhase(getServletContext(), ElectionPhase.OPEN);
                    getServletContext().setAttribute(KEY_END_TIME, endTime);
                    getServletContext().setAttribute(KEY_WINNER, null);

                    String durStr = durationMinutes > 0 ? durationMinutes + " min" : "unlimited";
                    auditRepo.log(em, admin, "ELECTION_START",
                            "Election started. Duration: " + durStr
                            + ". Positions: " + perPos.keySet());
                    break;
                }

                // ── PAUSE ─────────────────────────────────────────────────────
                case "pause": {
                    ElectionPhase current = AppConfigUtil.getElectionPhase(getServletContext());
                    if (current != ElectionPhase.OPEN) {
                        errorMsg = "Cannot pause: election is not currently OPEN.";
                        break;
                    }
                    // DRAFT = paused state in your enum
                    AppConfigUtil.setElectionPhase(getServletContext(), ElectionPhase.DRAFT);
                    auditRepo.log(em, admin, "ELECTION_PAUSE", "Election paused by admin.");
                    break;
                }

                // ── RESUME ────────────────────────────────────────────────────
                case "resume": {
                    ElectionPhase current = AppConfigUtil.getElectionPhase(getServletContext());
                    if (current != ElectionPhase.DRAFT) {
                        errorMsg = "Cannot resume: election is not currently paused (DRAFT).";
                        break;
                    }
                    AppConfigUtil.setElectionPhase(getServletContext(), ElectionPhase.OPEN);
                    auditRepo.log(em, admin, "ELECTION_RESUME", "Election resumed by admin.");
                    break;
                }

                // ── STOP ──────────────────────────────────────────────────────
                case "stop": {
                    List<Contester> approved = contesterRepo.findApproved(em);
                    Map<Long, Long> voteCounts = voteRepo.voteCountByContester(em);

                    Contester winner = approved.stream()
                            .max(Comparator.comparingLong(c -> voteCounts.getOrDefault(c.getId(), 0L)))
                            .orElse(null);

                    AppConfigUtil.setElectionPhase(getServletContext(), ElectionPhase.CLOSED);
                    getServletContext().setAttribute(KEY_END_TIME, null);

                    if (winner != null) {
                        long wVotes = voteCounts.getOrDefault(winner.getId(), 0L);
                        String wName = winner.getUser().getFirstName() + " "
                                + winner.getUser().getLastName();
                        String wPos = winner.getPosition().name();
                        String winnerJson = "{\"name\":\"" + esc(wName) + "\","
                                + "\"position\":\"" + esc(wPos) + "\","
                                + "\"votes\":" + wVotes + "}";
                        getServletContext().setAttribute(KEY_WINNER, winnerJson);
                        auditRepo.log(em, admin, "ELECTION_STOP",
                                "Stopped. Winner: " + wName + " (" + wPos + ") with "
                                + wVotes + " vote(s).");
                    } else {
                        getServletContext().setAttribute(KEY_WINNER, null);
                        auditRepo.log(em, admin, "ELECTION_STOP",
                                "Election stopped. No votes cast.");
                    }
                    break;
                }

                default:
                    errorMsg = "Unknown action: " + action;
            }

            if (errorMsg != null) {
                em.getTransaction().rollback();
                req.getSession().setAttribute("error", errorMsg);
            } else {
                em.getTransaction().commit();
            }

        } catch (Exception ex) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw ex;
        } finally {
            em.close();
        }

        res.sendRedirect(req.getContextPath() + "/admin/dashboard");
    }

    private long parseLong(String s, long def) {
        if (s == null || s.isBlank()) return def;
        try { return Long.parseLong(s.trim()); } catch (NumberFormatException e) { return def; }
    }

    private String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
