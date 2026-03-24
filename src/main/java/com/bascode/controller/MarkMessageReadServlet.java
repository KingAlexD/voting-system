package com.bascode.controller;

import java.io.IOException;

import com.bascode.repository.ContactMessageRepository;
import com.bascode.util.ServletUtil;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/contact/read")
public class MarkMessageReadServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final ContactMessageRepository msgRepo = new ContactMessageRepository();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long userId = ServletUtil.getSessionUserId(request);
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login-view?error=unauthorized");
            return;
        }
        String idParam = request.getParameter("id");
        if (idParam == null) {
            response.sendRedirect(request.getContextPath() + "/contact");
            return;
        }
        EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(getServletContext());
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            msgRepo.markUserRead(em, Long.valueOf(idParam), userId);
            em.getTransaction().commit();
        } catch (Exception ex) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw ex;
        } finally {
            em.close();
        }
        response.sendRedirect(request.getContextPath() + "/contact?status=read");
    }
}