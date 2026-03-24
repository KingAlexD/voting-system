package com.bascode.controller;

import com.bascode.model.entity.Contester;
import com.bascode.model.entity.User;
import com.bascode.model.enums.ContesterStatus;
import com.bascode.model.enums.Position;
import com.bascode.model.enums.Role;
import com.bascode.repository.AdminAuditLogRepository;
import com.bascode.repository.ContesterRepository;
import com.bascode.repository.NotificationRepository;
import com.bascode.repository.UserRepository;
import com.bascode.util.ServletUtil;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;


@WebServlet("/admin/contester/decision")
public class AdminApprovalServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final UserRepository userRepository = new UserRepository();
    private final ContesterRepository contesterRepository = new ContesterRepository();
    private final AdminAuditLogRepository adminAuditLogRepository = new AdminAuditLogRepository();
    private final NotificationRepository notificationRepository = new NotificationRepository();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null || action.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?error=bad_request");
            return;
        }

        EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(getServletContext());
        EntityManager em = emf.createEntityManager();
        try {
            User currentUser = ServletUtil.getCurrentUser(request, em, userRepository);
            if (currentUser == null || currentUser.getRole() != Role.ADMIN) {
                response.sendRedirect(request.getContextPath() + "/login-view?error=unauthorized");
                return;
            }

    
            if (action.equals("suspend") || action.equals("unsuspend")
                    || action.equals("promote") || action.equals("demote")) {

                String userIdParam = request.getParameter("userId");
                if (userIdParam == null) {
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard?error=bad_request");
                    return;
                }
                Long userId;
                try {
                    userId = Long.valueOf(userIdParam);
                } catch (NumberFormatException ex) {
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard?error=bad_request");
                    return;
                }

                User target = userRepository.findById(em, userId).orElse(null);
                if (target == null) {
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard?error=not_found");
                    return;
                }

                em.getTransaction().begin();

                if (action.equals("suspend")) {
                    target.setSuspended(true);
                    userRepository.update(em, target);
                    adminAuditLogRepository.log(em, currentUser, "USER_SUSPENDED",
                            "User #" + target.getId() + " (" + target.getEmail() + ") suspended.");
                    notificationRepository.create(em, target, "Account Suspended",
                            "Your account has been suspended by an administrator. Contact support if you believe this is an error.",
                            "/contact");

                } else if (action.equals("unsuspend")) {
                    target.setSuspended(false);
                    userRepository.update(em, target);
                    adminAuditLogRepository.log(em, currentUser, "USER_UNSUSPENDED",
                            "User #" + target.getId() + " (" + target.getEmail() + ") unsuspended.");
                    notificationRepository.create(em, target, "Account Restored",
                            "Your account suspension has been lifted. You can now log in.", "/login-view");

                } else if (action.equals("promote")) {
                    // Only promote if the user has an APPROVED contester record
                    Contester contester = contesterRepository.findByUserId(em, target.getId()).orElse(null);
                    if (contester == null || contester.getStatus() != ContesterStatus.APPROVED) {
                        em.getTransaction().rollback();
                        response.sendRedirect(request.getContextPath() + "/admin/dashboard?error=no_approved_application");
                        return;
                    }
                    target.setRole(Role.CONTESTER);
                    userRepository.update(em, target);
                    adminAuditLogRepository.log(em, currentUser, "USER_PROMOTED_TO_CONTESTER",
                            "User #" + target.getId() + " promoted to CONTESTER.");
                    notificationRepository.create(em, target, "Role Updated: Contester",
                            "An administrator has promoted your role to Contester.", "/dashboard");

                } else { // demote
                    Contester contester = contesterRepository.findByUserId(em, target.getId()).orElse(null);
                    if (contester == null) {
                        em.getTransaction().rollback();
                        response.sendRedirect(request.getContextPath() + "/admin/dashboard?error=no_contester_record");
                        return;
                    }
                    target.setRole(Role.VOTER);
                    userRepository.update(em, target);
                    adminAuditLogRepository.log(em, currentUser, "USER_DEMOTED_TO_VOTER",
                            "User #" + target.getId() + " demoted to VOTER.");
                    notificationRepository.create(em, target, "Role Updated: Voter",
                            "An administrator has changed your role back to Voter.", "/dashboard");
                }

                em.getTransaction().commit();
                response.sendRedirect(request.getContextPath() + "/admin/dashboard?status=updated");
                return;
            }

            // ── Contester-level actions (approve / deny / approve-position / deny-position) ──
            String contesterIdParam = request.getParameter("contesterId");
            if (contesterIdParam == null) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard?error=bad_request");
                return;
            }
            Long contesterId;
            try {
                contesterId = Long.valueOf(contesterIdParam);
            } catch (NumberFormatException ex) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard?error=bad_request");
                return;
            }

            Contester contester = contesterRepository.findById(em, contesterId).orElse(null);
            if (contester == null) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard?error=not_found");
                return;
            }

            em.getTransaction().begin();

            if ("approve".equalsIgnoreCase(action)) {
                long approvedCount = contesterRepository.countApprovedByPosition(em, contester.getPosition());
                if (approvedCount >= 3) {
                    contester.setStatus(ContesterStatus.DENIED);
                    adminAuditLogRepository.log(em, currentUser, "CONTESTER_DENIED_AUTO_CAP",
                            "Contester #" + contester.getId() + " denied; position " + contester.getPosition() + " is full.");
                    notificationRepository.create(em, contester.getUser(), "Application Denied",
                            "Your contester application was denied because the position already has 3 approved candidates.",
                            "/dashboard");
                } else {
                    contester.setStatus(ContesterStatus.APPROVED);
                    contester.getUser().setRole(Role.CONTESTER);
                    userRepository.update(em, contester.getUser());
                    adminAuditLogRepository.log(em, currentUser, "CONTESTER_APPROVED",
                            "Contester #" + contester.getId() + " approved for " + contester.getPosition() + ".");
                    notificationRepository.create(em, contester.getUser(), "Application Approved",
                            "Congratulations! Your contester application for " + contester.getPosition() + " has been approved.",
                            "/dashboard");
                }

            } else if ("deny".equalsIgnoreCase(action)) {
                contester.setStatus(ContesterStatus.DENIED);
                adminAuditLogRepository.log(em, currentUser, "CONTESTER_DENIED",
                        "Contester #" + contester.getId() + " denied by admin.");
                notificationRepository.create(em, contester.getUser(), "Application Denied",
                        "Your contester application has been denied by an administrator.", "/dashboard");

            } else if ("approve-position".equalsIgnoreCase(action)) {
                Position requested = contester.getRequestedPosition();
                if (requested == null) {
                    em.getTransaction().rollback();
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard?error=no_position_request");
                    return;
                }
                long approvedCount = contesterRepository.countApprovedByPosition(em, requested);
                if (approvedCount >= 3) {
                    contester.setRequestedPosition(null);
                    adminAuditLogRepository.log(em, currentUser, "POSITION_CHANGE_DENIED_CAP",
                            "Position change for Contester #" + contester.getId() + " denied; " + requested + " is full.");
                    notificationRepository.create(em, contester.getUser(), "Position Change Denied",
                            "Your request to move to " + requested + " was denied because that position is already full.",
                            "/dashboard");
                } else {
                    contester.setPosition(requested);
                    contester.setRequestedPosition(null);
                    adminAuditLogRepository.log(em, currentUser, "POSITION_CHANGE_APPROVED",
                            "Contester #" + contester.getId() + " moved to " + requested + ".");
                    notificationRepository.create(em, contester.getUser(), "Position Change Approved",
                            "Your position has been updated to " + requested + ".", "/dashboard");
                }

            } else if ("deny-position".equalsIgnoreCase(action)) {
                Position requested = contester.getRequestedPosition();
                contester.setRequestedPosition(null);
                adminAuditLogRepository.log(em, currentUser, "POSITION_CHANGE_DENIED",
                        "Position change request for Contester #" + contester.getId() + " denied by admin.");
                notificationRepository.create(em, contester.getUser(), "Position Change Denied",
                        "Your request to change position to " + (requested != null ? requested : "unknown") + " was denied.",
                        "/dashboard");
            }

            contesterRepository.update(em, contester);
            em.getTransaction().commit();
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?status=updated");

        } catch (Exception ex) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw ex;
        } finally {
            em.close();
        }
    }
}
