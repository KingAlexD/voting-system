package com.bascode.controller;

import java.io.IOException;
import java.time.Year;

import com.bascode.model.entity.User;
import com.bascode.model.enums.Role;
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

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final UserRepository userRepository = new UserRepository();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String birthYearParam = request.getParameter("birthYear");
        String state = request.getParameter("state");
        String country = request.getParameter("country");

        if (isBlank(firstName) || isBlank(lastName) || isBlank(email) || isBlank(password) || isBlank(confirmPassword)
                || isBlank(birthYearParam) || isBlank(state) || isBlank(country)) {
            response.sendRedirect(request.getContextPath() + "/register-view?error=missing_fields");
            return;
        }
        if (!password.equals(confirmPassword)) {
            response.sendRedirect(request.getContextPath() + "/register-view?error=password_mismatch");
            return;
        }

        int birthYear;
        try {
            birthYear = Integer.parseInt(birthYearParam);
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/register-view?error=invalid_birth_year");
            return;
        }

        int year = Year.now().getValue();
        if (birthYear < 1900 || birthYear > year) {
            response.sendRedirect(request.getContextPath() + "/register-view?error=invalid_birth_year");
            return;
        }

        EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(getServletContext());
        EntityManager em = emf.createEntityManager();
        try {
            if (userRepository.findByEmail(em, email.trim()).isPresent()) {
                response.sendRedirect(request.getContextPath() + "/register-view?error=email_exists");
                return;
            }

            em.getTransaction().begin();
            User user = new User();
            user.setFirstName(firstName.trim());
            user.setLastName(lastName.trim());
            user.setEmail(email.trim().toLowerCase());
            user.setPasswordHash(SecurityUtil.hashPassword(password));
            user.setBirthYear(birthYear);
            user.setState(state.trim());
            user.setCountry(country.trim());
            user.setRole(Role.VOTER);
            user.setEmailVerified(false);
            user.setVerificationCode(SecurityUtil.generateVerificationCode());
            userRepository.save(em, user);
            em.getTransaction().commit();

            HttpSession session = request.getSession(true);
            session.setAttribute("verificationEmail", user.getEmail());
            session.setAttribute("lastVerificationCode", user.getVerificationCode());

            try {
                EmailService.sendVerificationCode(getServletContext(), user.getEmail(), user.getVerificationCode());
            } catch (MessagingException ex) {
                getServletContext().log("Unable to send verification email to " + user.getEmail(), ex);
                response.sendRedirect(request.getContextPath() + "/verify-view?error=email_send_failed");
                return;
            }
            response.sendRedirect(request.getContextPath() + "/verify-view?status=code_sent");
        } catch (Exception ex) {
            if (em.getTransaction().isActive()) {
                em.getTransaction().rollback();
            }
            throw ex;
        } finally {
            em.close();
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
