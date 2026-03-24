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

@WebServlet("/contact")
public class ContactServlet extends HttpServlet {
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
            User currentUser = ServletUtil.getCurrentUser(request, em, userRepo);
            if (currentUser != null && currentUser.getRole() != Role.ADMIN) {
                List<ContactMessage> myMessages = msgRepo.findByUser(em, currentUser.getId());
                request.setAttribute("myMessages", myMessages);
            }
            request.setAttribute("currentUser", currentUser);
            request.getRequestDispatcher("/contact.jsp").forward(request, response);
        } finally {
            em.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String name    = request.getParameter("senderName");
        String email   = request.getParameter("senderEmail");
        String subject = request.getParameter("subject");
        String body    = request.getParameter("message");

        if (isBlank(name) || isBlank(email) || isBlank(subject) || isBlank(body)) {
            response.sendRedirect(request.getContextPath() + "/contact?error=missing_fields");
            return;
        }

        EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(getServletContext());
        EntityManager em = emf.createEntityManager();
        try {
            User currentUser = ServletUtil.getCurrentUser(request, em, userRepo);

            // Check if replying to an existing message
            String parentIdParam = request.getParameter("parentId");
            ContactMessage parent = null;
            if (parentIdParam != null && !parentIdParam.isBlank()) {
                try {
                    parent = msgRepo.findById(em, Long.valueOf(parentIdParam)).orElse(null);
                } catch (NumberFormatException ignored) {}
            }

            em.getTransaction().begin();
            ContactMessage msg = msgRepo.build(
                currentUser, 
                currentUser != null ? currentUser.getFirstName() + " " + currentUser.getLastName() : name,
                currentUser != null ? currentUser.getEmail() : email,
                subject, body, false, null, parent
            );
            msgRepo.save(em, msg);

            // Notify the admin — find any ADMIN user and send notification
            List<User> admins = userRepo.findAllAdmins(em);
            for (User admin : admins) {
                notifRepo.create(em, admin, "New Contact Message",
                    "Message from " + msg.getSenderName() + ": " + subject,
                    "/admin/contact");
            }
            em.getTransaction().commit();

            request.getSession().setAttribute("success", "Message sent successfully.");
            response.sendRedirect(request.getContextPath() + "/contact");
        } catch (Exception ex) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw ex;
        } finally {
            em.close();
        }
    }

   
    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        }

    private boolean isBlank(String v) { return v == null || v.isBlank(); }
}