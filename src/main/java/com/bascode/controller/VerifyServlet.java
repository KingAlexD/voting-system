package com.bascode.controller;

import java.io.IOException;

import com.bascode.model.entity.User;
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
import jakarta.servlet.http.HttpSession;

@WebServlet("/verify")
public class VerifyServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final UserRepository userRepository = new UserRepository();
    private final NotificationRepository notificationRepository = new NotificationRepository();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String verificationEmail = session == null ? null : (String) session.getAttribute("verificationEmail");
        String code = request.getParameter("code");

        if (verificationEmail == null || code == null || code.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/verify-view?error=session_expired");
            return;
        }

        EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(getServletContext());
        EntityManager em = emf.createEntityManager();
        try {
            User user = userRepository.findByEmail(em, verificationEmail).orElse(null);
            if (user == null || user.getVerificationCode() == null || !user.getVerificationCode().equals(code.trim())) {
                response.sendRedirect(request.getContextPath() + "/verify-view?error=invalid_code");
                return;
            }

            em.getTransaction().begin();
            user.setEmailVerified(true);
            user.setVerificationCode(null);
            userRepository.update(em, user);
            notificationRepository.create(em, user, "Account Verified",
                    "Your account has been successfully verified. You can now access your dashboard.", "/dashboard");
            em.getTransaction().commit();

            session.removeAttribute("verificationEmail");
            session.removeAttribute("lastVerificationCode");
            response.sendRedirect(request.getContextPath() + "/login-view?status=verified");
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
