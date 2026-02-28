package com.bascode.controller;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.UUID;

import com.bascode.model.entity.PasswordResetToken;
import com.bascode.model.entity.User;
import com.bascode.repository.PasswordResetTokenRepository;
import com.bascode.repository.UserRepository;
import com.bascode.util.AppConfigUtil;
import com.bascode.util.EmailService;
import com.bascode.util.ServletUtil;

import jakarta.mail.MessagingException;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final UserRepository userRepository = new UserRepository();
    private final PasswordResetTokenRepository tokenRepository = new PasswordResetTokenRepository();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        if (email == null || email.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/forgot-password-view?error=invalid_email");
            return;
        }

        EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(getServletContext());
        EntityManager em = emf.createEntityManager();
        try {
            User user = userRepository.findByEmail(em, email.trim().toLowerCase()).orElse(null);
            if (user == null) {
                response.sendRedirect(request.getContextPath() + "/forgot-password-view?status=request_sent");
                return;
            }

            String tokenValue = UUID.randomUUID().toString().replace("-", "");
            em.getTransaction().begin();
            tokenRepository.invalidateUserTokens(em, user.getId());
            PasswordResetToken token = new PasswordResetToken();
            token.setUser(user);
            token.setToken(tokenValue);
            token.setExpiresAt(LocalDateTime.now().plusMinutes(20));
            token.setUsed(false);
            tokenRepository.save(em, token);
            em.getTransaction().commit();

            String resetLink = AppConfigUtil.getBaseUrl(getServletContext()) + "/reset-password-view?token=" + tokenValue;
            try {
                EmailService.sendPlainEmail(getServletContext(), user.getEmail(), "Password Reset Request",
                        "Reset your password using this link:\n" + resetLink
                                + "\n\nThis link expires in 20 minutes.");
            } catch (MessagingException ex) {
                getServletContext().log("Unable to send password reset email to " + user.getEmail(), ex);
                response.sendRedirect(request.getContextPath() + "/forgot-password-view?error=email_send_failed");
                return;
            }

            response.sendRedirect(request.getContextPath() + "/forgot-password-view?status=request_sent");
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
