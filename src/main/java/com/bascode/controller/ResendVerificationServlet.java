package com.bascode.controller;

import java.io.IOException;

import com.bascode.model.entity.User;
import com.bascode.repository.UserRepository;
import com.bascode.util.EmailService;
import com.bascode.util.SecurityUtil;
import com.bascode.util.ServletUtil;

import jakarta.mail.MessagingException;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/resend-verification")
public class ResendVerificationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final UserRepository userRepository = new UserRepository();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String verificationEmail = session == null ? null : (String) session.getAttribute("verificationEmail");

        if (verificationEmail == null) {
            response.sendRedirect(request.getContextPath() + "/verify-view?error=session_expired");
            return;
        }

        EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(getServletContext());
        EntityManager em = emf.createEntityManager();
        try {
            User user = userRepository.findByEmail(em, verificationEmail).orElse(null);
            if (user == null || user.isEmailVerified()) {
                response.sendRedirect(request.getContextPath() + "/verify-view?error=session_expired");
                return;
            }

            String code = SecurityUtil.generateVerificationCode();
            em.getTransaction().begin();
            user.setVerificationCode(code);
            userRepository.update(em, user);
            em.getTransaction().commit();

            try {
                EmailService.sendVerificationCode(getServletContext(), user.getEmail(), code);
                // Do NOT store the code in session — it must only travel via email
                response.sendRedirect(request.getContextPath() + "/verify-view?status=resent");
            } catch (MessagingException ex) {
                getServletContext().log("Unable to resend verification email to " + user.getEmail(), ex);
                // Do NOT expose the code as a session fallback
                response.sendRedirect(request.getContextPath() + "/verify-view?error=email_send_failed");
            }
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
