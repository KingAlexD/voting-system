package com.bascode.controller;

import java.io.IOException;

import com.bascode.model.entity.PasswordResetToken;
import com.bascode.repository.PasswordResetTokenRepository;
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

@WebServlet("/reset-password")
public class ResetPasswordServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final PasswordResetTokenRepository tokenRepository = new PasswordResetTokenRepository();
    private final UserRepository userRepository = new UserRepository();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String tokenValue = request.getParameter("token");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (tokenValue == null || tokenValue.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/reset-password-view?error=invalid_token");
            return;
        }
        if (newPassword == null || newPassword.length() < 8 || !newPassword.equals(confirmPassword)) {
            response.sendRedirect(
                    request.getContextPath() + "/reset-password-view?token=" + tokenValue + "&error=password_mismatch");
            return;
        }

        EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(getServletContext());
        EntityManager em = emf.createEntityManager();
        try {
            PasswordResetToken token = tokenRepository.findActiveByToken(em, tokenValue).orElse(null);
            if (token == null) {
                response.sendRedirect(request.getContextPath() + "/reset-password-view?error=invalid_token");
                return;
            }

            em.getTransaction().begin();
            token.getUser().setPasswordHash(SecurityUtil.hashPassword(newPassword));
            token.setUsed(true);
            userRepository.update(em, token.getUser());
            tokenRepository.update(em, token);
            em.getTransaction().commit();
            response.sendRedirect(request.getContextPath() + "/login-view?status=password_reset");
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
