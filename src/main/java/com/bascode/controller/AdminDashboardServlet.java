package com.bascode.controller;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import com.bascode.model.entity.Contester;
import com.bascode.model.entity.User;
import com.bascode.model.enums.Position;
import com.bascode.model.enums.Role;
import com.bascode.repository.AdminAuditLogRepository;
import com.bascode.repository.ContesterRepository;
import com.bascode.repository.UserRepository;
import com.bascode.repository.VoteRepository;
import com.bascode.util.AppConfigUtil;
import com.bascode.util.CsrfUtil;
import com.bascode.util.PageResult;
import com.bascode.util.PaginationUtil;
import com.bascode.util.ServletUtil;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final UserRepository userRepository = new UserRepository();
    private final ContesterRepository contesterRepository = new ContesterRepository();
    private final VoteRepository voteRepository = new VoteRepository();
    private final AdminAuditLogRepository auditLogRepository = new AdminAuditLogRepository();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(getServletContext());
        EntityManager em = emf.createEntityManager();
        try {
            User currentUser = ServletUtil.getCurrentUser(request, em, userRepository);
            if (currentUser == null || currentUser.getRole() != Role.ADMIN) {
                response.sendRedirect(request.getContextPath() + "/login-view?error=unauthorized");
                return;
            }

            List<User> allUsers = userRepository.findAllVotersAndContesters(em);
            var pending = contesterRepository.findPending(em);
            var allContesters = contesterRepository.findAll(em);
            var voteRows = voteRepository.findAll(em);
            Map<Long, Long> voteCounts = voteRepository.voteCountByContester(em);
            var auditLogs = auditLogRepository.findRecent(em, 500);

            List<Contester> positionChangeRequests = allContesters.stream()
                    .filter(c -> c.getRequestedPosition() != null)
                    .collect(Collectors.toList());

            String q = request.getParameter("q");
            String qLower = q == null ? "" : q.trim().toLowerCase();
            if (!qLower.isBlank()) {
                allUsers = allUsers.stream()
                        .filter(u -> (u.getFirstName() + " " + u.getLastName() + " " + u.getEmail())
                                .toLowerCase().contains(qLower))
                        .collect(Collectors.toList());
                allContesters = allContesters.stream()
                        .filter(c -> (c.getUser().getFirstName() + " " + c.getUser().getLastName() + " "
                                + c.getUser().getEmail() + " " + c.getPosition() + " " + c.getManifesto())
                                .toLowerCase().contains(qLower))
                        .collect(Collectors.toList());
            }

            PageResult<User> usersPage = PaginationUtil.paginate(allUsers,
                    PaginationUtil.parsePage(request.getParameter("usersPage"), 1), 10);
            PageResult<Contester> contestersPage = PaginationUtil.paginate(allContesters,
                    PaginationUtil.parsePage(request.getParameter("contestersPage"), 1), 10);
            PageResult<com.bascode.model.entity.Vote> votesPage = PaginationUtil.paginate(voteRows,
                    PaginationUtil.parsePage(request.getParameter("votesPage"), 1), 10);
            PageResult<com.bascode.model.entity.AdminAuditLog> auditPage = PaginationUtil.paginate(auditLogs,
                    PaginationUtil.parsePage(request.getParameter("auditPage"), 1), 10);

            long totalVotes = 0L;
            for (Long count : voteCounts.values()) totalVotes += count;

            // ── Per-position approved count for the readiness indicator ──────────
            Map<String, Long> positionReadiness = new HashMap<>();
            for (Position pos : Position.values()) {
                positionReadiness.put(pos.name(),
                        contesterRepository.countApprovedByPosition(em, pos));
            }

            request.setAttribute("q", q == null ? "" : q);
            request.setAttribute("allUsers", usersPage.getItems());
            request.setAttribute("pendingContesters", pending);
            request.setAttribute("positionChangeRequests", positionChangeRequests);
            request.setAttribute("allContesters", contestersPage.getItems());
            request.setAttribute("voteRows", votesPage.getItems());
            request.setAttribute("voteCounts", voteCounts);
            request.setAttribute("auditLogs", auditPage.getItems());
            request.setAttribute("statUsers", allUsers.size());
            request.setAttribute("statPending", pending.size());
            request.setAttribute("statContesters", allContesters.size());
            request.setAttribute("statVotes", totalVotes);
            request.setAttribute("usersPage", usersPage.getPage());
            request.setAttribute("usersTotalPages", usersPage.getTotalPages());
            request.setAttribute("contestersPage", contestersPage.getPage());
            request.setAttribute("contestersTotalPages", contestersPage.getTotalPages());
            request.setAttribute("votesPage", votesPage.getPage());
            request.setAttribute("votesTotalPages", votesPage.getTotalPages());
            request.setAttribute("auditPage", auditPage.getPage());
            request.setAttribute("auditTotalPages", auditPage.getTotalPages());

            // ── Election state for the controls panel ─────────────────────────
            request.setAttribute("electionPhase",
                    AppConfigUtil.getElectionPhase(getServletContext()).name());
            request.setAttribute("positionReadiness", positionReadiness);
            Object endTime = getServletContext().getAttribute("election.endTime"); // LocalDateTime
            request.setAttribute("electionEndTime", endTime);

            // ── CSRF token ────────────────────────────────────────────────────
            request.setAttribute("csrfToken", CsrfUtil.getToken(request.getSession(true)));

            // ── Single forward — do NOT call this twice ───────────────────────
            request.getRequestDispatcher("/WEB-INF/views/admin/admin-dashboard.jsp")
                    .forward(request, response);

        } finally {
            em.close();
        }
    }
}
