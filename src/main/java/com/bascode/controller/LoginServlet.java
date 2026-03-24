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
import jakarta.servlet.http.HttpSession;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final UserRepository userRepository = new UserRepository();

    // Show login form
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp")
               .forward(request, response);
    }

    // Handle login submission
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(getServletContext());
        EntityManager em = emf.createEntityManager();
        try {
            User user = userRepository.findByEmail(em, email == null ? "" : email.trim()).orElse(null);

            if (user == null || !SecurityUtil.verifyPassword(password, user.getPasswordHash())) {
                response.sendRedirect(request.getContextPath() + "/login?error=invalid");
                return;
            }

            if (user.isSuspended()) {
                response.sendRedirect(request.getContextPath() + "/login?error=suspended");
                return;
            }

            if (!user.isEmailVerified()) {
                HttpSession verificationSession = request.getSession(true);
                verificationSession.setAttribute("verificationEmail", user.getEmail());
                response.sendRedirect(request.getContextPath() + "/verify-view?error=not_verified");
                return;
            }

            HttpSession session = request.getSession(true);
            request.changeSessionId();
            session.setAttribute("userId", user.getId());
            session.setAttribute("userEmail", user.getEmail());
            session.setAttribute("userRole", user.getRole().name());

            if ("ADMIN".equals(user.getRole().name())) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            } else {
                response.sendRedirect(request.getContextPath() + "/dashboard");
            }
        } finally {
            em.close();
        }
    }
}