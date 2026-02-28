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

@WebServlet("/notifications")
public class NotificationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final NotificationRepository notificationRepository = new NotificationRepository();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Long userId = ServletUtil.getSessionUserId(request);
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login-view?error=unauthorized");
            return;
        }
        EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(getServletContext());
        EntityManager em = emf.createEntityManager();
        try {
            request.setAttribute("notifications", notificationRepository.findRecentByUser(em, userId, 100));
            request.getRequestDispatcher("/WEB-INF/views/notification/center.jsp").forward(request, response);
        } finally {
            em.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Long userId = ServletUtil.getSessionUserId(request);
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login-view?error=unauthorized");
            return;
        }
        EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(getServletContext());
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            notificationRepository.markAllAsRead(em, userId);
            em.getTransaction().commit();
            response.sendRedirect(request.getContextPath() + "/notifications?status=read");
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
