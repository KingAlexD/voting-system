package com.bascode.controller;

import java.io.IOException;

import com.bascode.model.entity.User;
import com.bascode.repository.UserRepository;
import com.bascode.util.SecurityUtil;
import com.bascode.util.ServletUtil;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final UserRepository userRepository = new UserRepository();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(getServletContext());
        EntityManager em = emf.createEntityManager();
        try {
            User user = ServletUtil.getCurrentUser(request, em, userRepository);
            if (user == null) {
                response.sendRedirect(request.getContextPath() + "/login-view?error=unauthorized");
                return;
            }
            request.setAttribute("currentUser", user);
            request.getRequestDispatcher("/WEB-INF/views/voter/profile.jsp").forward(request, response);
        } finally {
            em.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(getServletContext());
        EntityManager em = emf.createEntityManager();
        try {
            User user = ServletUtil.getCurrentUser(request, em, userRepository);
            if (user == null) {
                response.sendRedirect(request.getContextPath() + "/login-view?error=unauthorized");
                return;
            }

            em.getTransaction().begin();
            if ("updateInfo".equals(action)) {
                user.setFirstName(request.getParameter("firstName"));
                user.setLastName(request.getParameter("lastName"));
                user.setState(request.getParameter("state"));
                user.setCountry(request.getParameter("country"));
                userRepository.update(em, user);
            } else if ("changePassword".equals(action)) {
                String currentPassword = request.getParameter("currentPassword");
                String newPassword = request.getParameter("newPassword");
                String confirmPassword = request.getParameter("confirmPassword");
                if (!SecurityUtil.verifyPassword(currentPassword, user.getPasswordHash())) {
                    em.getTransaction().rollback();
                    response.sendRedirect(request.getContextPath() + "/profile?error=wrong_password");
                    return;
                }
                if (newPassword == null || !newPassword.equals(confirmPassword)) {
                    em.getTransaction().rollback();
                    response.sendRedirect(request.getContextPath() + "/profile?error=password_mismatch");
                    return;
                }
                user.setPasswordHash(SecurityUtil.hashPassword(newPassword));
                userRepository.update(em, user);
            }
            em.getTransaction().commit();
            response.sendRedirect(request.getContextPath() + "/profile?status=updated");
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
