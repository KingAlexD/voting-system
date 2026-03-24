package com.bascode.controller;

import java.io.IOException;

import com.bascode.repository.NotificationRepository;
import com.bascode.util.ServletUtil;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/notifications/read")
public class MarkNotificationReadServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final NotificationRepository notificationRepository = new NotificationRepository();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Long userId = ServletUtil.getSessionUserId(request);
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login-view?error=unauthorized");
            return;
        }

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/notifications?error=bad_request");
            return;
        }

        Long notificationId;
        try {
            notificationId = Long.valueOf(idParam);
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/notifications?error=bad_request");
            return;
        }

        EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(getServletContext());
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
           
            notificationRepository.markOneAsRead(em, notificationId, userId);
            em.getTransaction().commit();
            response.sendRedirect(request.getContextPath() + "/notifications?status=read");
        } catch (Exception ex) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw ex;
        } finally {
            em.close();
        }
    }
}
