package com.bascode.controller;

import com.bascode.model.entity.Contester;
import com.bascode.model.entity.User;
import com.bascode.model.enums.ContesterStatus;
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
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String contesterIdParam = request.getParameter("contesterId");
        String action = request.getParameter("action");
        if (contesterIdParam == null || action == null) {
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

        EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(getServletContext());
        EntityManager em = emf.createEntityManager();
        try {
            User currentUser = ServletUtil.getCurrentUser(request, em, userRepository);
            if (currentUser == null || currentUser.getRole() != Role.ADMIN) {
                response.sendRedirect(request.getContextPath() + "/login-view?error=unauthorized");
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
                    adminAuditLogRepository.save(em, currentUser, "CONTESTER_DENIED_AUTO_CAP",
                            "Contester #" + contester.getId() + " denied because position " + contester.getPosition()
                                    + " is already full.");
                    notificationRepository.create(em, contester.getUser(), "Application Denied",
                            "Your contester application was denied because the position already has 3 approved candidates.",
                            "/dashboard");
                } else {
                    contester.setStatus(ContesterStatus.APPROVED);
                    contester.getUser().setRole(Role.CONTESTER);
                    userRepository.update(em, contester.getUser());
                    adminAuditLogRepository.save(em, currentUser, "CONTESTER_APPROVED",
                            "Contester #" + contester.getId() + " approved for " + contester.getPosition() + ".");
                    notificationRepository.create(em, contester.getUser(), "Application Approved",
                            "Congratulations. Your contester application for " + contester.getPosition()
                                    + " has been approved.",
                            "/dashboard");
                }
            } else if ("deny".equalsIgnoreCase(action)) {
                contester.setStatus(ContesterStatus.DENIED);
                adminAuditLogRepository.save(em, currentUser, "CONTESTER_DENIED",
                        "Contester #" + contester.getId() + " denied by admin.");
                notificationRepository.create(em, contester.getUser(), "Application Denied",
                        "Your contester application has been denied by admin.", "/dashboard");
            }
            contesterRepository.update(em, contester);
            em.getTransaction().commit();
            response.sendRedirect(request.getContextPath() + "/admin/dashboard?status=updated");
        } catch (Exception ex) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            throw ex;
        } finally {
            em.close();
        }
    }
}
