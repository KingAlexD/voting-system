package com.bascode.controller;

import com.bascode.model.entity.Contester;
import com.bascode.model.entity.User;
import com.bascode.model.enums.ContesterStatus;
import com.bascode.model.enums.Role;
import com.bascode.repository.AdminAuditLogRepository;
import com.bascode.repository.ContesterRepository;
import com.bascode.repository.NotificationRepository;
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


@WebServlet("/contester/withdraw")
public class ContesterWithdrawServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private final UserRepository        userRepo      = new UserRepository();
    private final ContesterRepository   contestRepo   = new ContesterRepository();
    private final VoteRepository        voteRepo      = new VoteRepository();
    private final NotificationRepository notifRepo    = new NotificationRepository();
    private final AdminAuditLogRepository auditRepo   = new AdminAuditLogRepository();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action"); // "withdraw" or "request-demotion"

        EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(getServletContext());
        EntityManager em = emf.createEntityManager();
        try {
            User currentUser = ServletUtil.getCurrentUser(request, em, userRepo);
            if (currentUser == null) {
                response.sendRedirect(request.getContextPath() + "/login-view?error=unauthorized");
                return;
            }

            Contester contester = contestRepo.findByUserId(em, currentUser.getId()).orElse(null);
            if (contester == null) {
                response.sendRedirect(request.getContextPath() + "/dashboard?error=no_application");
                return;
            }

            // Only APPROVED contesters can withdraw or request demotion
            if (contester.getStatus() != ContesterStatus.APPROVED) {
                // A PENDING applicant can simply cancel their application
                if (contester.getStatus() == ContesterStatus.PENDING && "withdraw".equals(action)) {
                    em.getTransaction().begin();
                    em.remove(em.contains(contester) ? contester : em.merge(contester));
                    auditRepo.log(em, currentUser, "CONTESTER_APPLICATION_CANCELLED",
                            "User #" + currentUser.getId() + " cancelled their pending application.");
                    em.getTransaction().commit();
                    response.sendRedirect(request.getContextPath() + "/dashboard?status=application_cancelled");
                    return;
                }
                response.sendRedirect(request.getContextPath() + "/dashboard?error=not_approved_contester");
                return;
            }

            em.getTransaction().begin();

            // Delete all votes cast FOR this contester so the count resets
            voteRepo.deleteVotesByContesterId(em, contester.getId());

            // Downgrade role back to VOTER
            currentUser.setRole(Role.VOTER);
            userRepo.update(em, currentUser);

            // Mark contester record as WITHDRAWN (or remove it)
            contester.setStatus(ContesterStatus.DENIED); // re-use DENIED to mark inactive
            contester.setRequestedPosition(null);
            contestRepo.update(em, contester);

            String auditAction = "request-demotion".equals(action)
                    ? "CONTESTER_DEMOTION_SELF_REQUESTED"
                    : "CONTESTER_WITHDREW";

            auditRepo.log(em, currentUser, auditAction,
                    "User #" + currentUser.getId() + " (" + currentUser.getEmail()
                    + ") withdrew from position " + contester.getPosition() + ". Votes reset.");

            notifRepo.create(em, currentUser,
                    "You have withdrawn from the election",
                    "Your contester role has been removed and your vote count reset. You are now a Voter.",
                    "/dashboard");

            em.getTransaction().commit();

            response.sendRedirect(request.getContextPath() + "/dashboard?status=withdrawn");

        } catch (Exception ex) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw ex;
        } finally {
            em.close();
        }
    }
}
