package com.bascode.controller;

import com.bascode.model.entity.Contester;
import com.bascode.model.entity.User;
import com.bascode.model.enums.ContesterStatus;
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
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@WebServlet("/admin/election/control")
public class ElectionControlServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * ServletContext attribute keys.
     *
     * KEY_WINNER  → JSON array of per-position winners, e.g.:
     *   [{"name":"Alice","position":"PRESIDENT","votes":7},
     *    {"name":"Bob","position":"VICE_PRESIDENT","votes":5}, ...]
     *
     * KEY_END_TIME → LocalDateTime when the election timer expires (or null = unlimited)
     *
     * Phase is stored via AppConfigUtil.setElectionPhase() under "electionPhase"
     * so that AppConfigUtil.isElectionOpen() / getElectionPhase() both see it.
     */
    public static final String KEY_WINNER   = "election.winner";   // JSON array String
    public static final String KEY_END_TIME = "election.endTime";  // LocalDateTime or null

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
                    AppConfigUtil.setElectionPhase(getServletContext(), ElectionPhase.DRAFT);
                    auditRepo.log(em, admin, "ELECTION_PAUSE", "Election paused by admin.");
                    break;
                }

                // ── RESUME ────────────────────────────────────────────────────
                case "resume": {
                    ElectionPhase current = AppConfigUtil.getElectionPhase(getServletContext());
                    if (current != ElectionPhase.DRAFT) {
                        errorMsg = "Cannot resume: election is not currently paused.";
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

                    // Find the top vote-getter PER POSITION
                    String winnersJson = buildWinnersJson(approved, voteCounts);

                    AppConfigUtil.setElectionPhase(getServletContext(), ElectionPhase.CLOSED);
                    getServletContext().setAttribute(KEY_END_TIME, null);
                    getServletContext().setAttribute(KEY_WINNER, winnersJson);

                    auditRepo.log(em, admin, "ELECTION_STOP",
                            "Election stopped. Winners: " + winnersJson);

                    // ── Reset: demote all approved contesters back to VOTER
                    //    and wipe their vote counts ──────────────────────────
                    resetContestersToVoters(em, approved);

                    break;
                }

                // ── RESET (admin manually prepares next election cycle) ────────
                case "reset": {
                    ElectionPhase current = AppConfigUtil.getElectionPhase(getServletContext());
                    if (current != ElectionPhase.CLOSED) {
                        errorMsg = "Can only reset after election is CLOSED.";
                        break;
                    }

                    List<Contester> allContesters = contesterRepo.findAll(em);
                    resetContestersToVoters(em, allContesters);

                    // Clear stored winner and move phase back to DRAFT ready for next cycle
                    AppConfigUtil.setElectionPhase(getServletContext(), ElectionPhase.DRAFT);
                    getServletContext().setAttribute(KEY_WINNER, null);
                    getServletContext().setAttribute(KEY_END_TIME, null);

                    auditRepo.log(em, admin, "ELECTION_RESET",
                            "Election reset by admin. All contesters returned to voters.");
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

   
    static String buildWinnersJson(List<Contester> approved, Map<Long, Long> voteCounts) {
        // Group by position, find leader in each group
        Map<Position, List<Contester>> byPosition = approved.stream()
                .collect(Collectors.groupingBy(Contester::getPosition));

        List<String> entries = new ArrayList<>();
        for (Position pos : Position.values()) {
            List<Contester> group = byPosition.get(pos);
            if (group == null || group.isEmpty()) continue;

            Contester leader = group.stream()
                    .max(Comparator
                            .comparingLong((Contester c) -> voteCounts.getOrDefault(c.getId(), 0L))
                            .thenComparingLong(c -> -c.getId())) // tie-break: lower id wins
                    .orElse(null);

            if (leader == null) continue;

            long votes = voteCounts.getOrDefault(leader.getId(), 0L);
            String name = esc(leader.getUser().getFirstName() + " " + leader.getUser().getLastName());
            entries.add("{\"name\":\"" + name + "\","
                    + "\"position\":\"" + esc(pos.name()) + "\","
                    + "\"votes\":" + votes + "}");
        }

        return "[" + String.join(",", entries) + "]";
    }

    /**
     * Demotes every contester in the list back to VOTER role,
     * marks their Contester record as DENIED (inactive),
     * and deletes all votes cast for them.
     * Must be called inside an active transaction.
     */
    private void resetContestersToVoters(EntityManager em, List<Contester> contesters) {
        for (Contester c : contesters) {
            // Delete all votes for this contester
            voteRepo.deleteVotesByContesterId(em, c.getId());

            // Downgrade role
            User u = c.getUser();
            if (u != null && u.getRole() == Role.CONTESTER) {
                u.setRole(Role.VOTER);
                userRepo.update(em, u);
            }

            // Mark contester record inactive so it won't show up as approved
            c.setStatus(ContesterStatus.DENIED);
            c.setRequestedPosition(null);
            contesterRepo.update(em, c);
        }
    }

    private long parseLong(String s, long def) {
        if (s == null || s.isBlank()) return def;
        try { return Long.parseLong(s.trim()); } catch (NumberFormatException e) { return def; }
    }

    private static String esc(String s) {
        return s == null ? "" : s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
