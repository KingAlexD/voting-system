package com.bascode.controller;

import java.io.IOException;
import java.util.List;

import com.bascode.model.entity.ContactMessage;
import com.bascode.model.entity.User;
import com.bascode.model.enums.Role;
import com.bascode.repository.ContactMessageRepository;
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

@WebServlet("/admin/contact")
public class AdminContactServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final ContactMessageRepository msgRepo = new ContactMessageRepository();
    private final NotificationRepository notifRepo = new NotificationRepository();
    private final UserRepository userRepo = new UserRepository();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(getServletContext());
        EntityManager em = emf.createEntityManager();
        try {
            User admin = ServletUtil.getCurrentUser(request, em, userRepo);
            if (admin == null || admin.getRole() != Role.ADMIN) {
                response.sendRedirect(request.getContextPath() + "/login-view?error=unauthorized");
                return;
            }
            String q = request.getParameter("q");
            List<ContactMessage> messages = (q != null && !q.isBlank())
                ? msgRepo.searchIncoming(em, q)
                : msgRepo.findAllIncoming(em);

            request.setAttribute("messages", messages);
            request.setAttribute("q", q == null ? "" : q);
            request.setAttribute("allUsers", userRepo.findAllVotersAndContesters(em));
            request.getRequestDispatcher("/WEB-INF/views/admin/admin-contact.jsp").forward(request, response);
        } finally {
            em.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(getServletContext());
        EntityManager em = emf.createEntityManager();
        try {
            User admin = ServletUtil.getCurrentUser(request, em, userRepo);
            if (admin == null || admin.getRole() != Role.ADMIN) {
                response.sendRedirect(request.getContextPath() + "/login-view?error=unauthorized");
                return;
            }

            String action = request.getParameter("action");

            if ("mark-read".equals(action)) {
                // Admin marks a user message as read
                Long msgId = Long.valueOf(request.getParameter("messageId"));
                em.getTransaction().begin();
                msgRepo.markAdminRead(em, msgId);
                em.getTransaction().commit();
                response.sendRedirect(request.getContextPath() + "/admin/contact?status=marked");
                return;
            }

            // reply OR compose
            String body = request.getParameter("body");
            String subject = request.getParameter("subject");
            String recipientIdParam = request.getParameter("recipientId");
            String parentIdParam = request.getParameter("parentId");

            if (body == null || body.isBlank()) {
                response.sendRedirect(request.getContextPath() + "/admin/contact?error=empty_body");
                return;
            }

            Long recipientId = Long.valueOf(recipientIdParam);
            User recipient = userRepo.findById(em, recipientId).orElse(null);
            if (recipient == null) {
                response.sendRedirect(request.getContextPath() + "/admin/contact?error=user_not_found");
                return;
            }

            ContactMessage parent = null;
            if (parentIdParam != null && !parentIdParam.isBlank()) {
                parent = msgRepo.findById(em, Long.valueOf(parentIdParam)).orElse(null);
                // Auto mark original as admin-read when replying
                if (parent != null) {
                    em.getTransaction().begin();
                    msgRepo.markAdminRead(em, parent.getId());
                    em.getTransaction().commit();
                }
            }

            em.getTransaction().begin();
            ContactMessage reply = msgRepo.build(
                admin,
                "Admin",
                admin.getEmail(),
                subject != null ? subject : "Re: " + (parent != null ? parent.getSubject() : "Message"),
                body,
                true,
                recipient,
                parent
            );
            msgRepo.save(em, reply);

           
            notifRepo.create(em, recipient, "New Message from Admin",
                "You have a new message from the administrator.",
                "/contact");
            em.getTransaction().commit();

            response.sendRedirect(request.getContextPath() + "/admin/contact?status=sent");
        } catch (Exception ex) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw ex;
        } finally {
            em.close();
        }
    }
}