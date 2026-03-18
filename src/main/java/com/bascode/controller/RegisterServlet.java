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

    /** Show the form (register-view servlet can also handle this, but just in case) */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String firstName       = request.getParameter("firstName");
        String lastName        = request.getParameter("lastName");
        String email           = request.getParameter("email");
        String password        = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String birthYearParam  = request.getParameter("birthYear");
        String state           = request.getParameter("state");
        // 'country' is NOT a field in register.jsp — do NOT check it

        // ── Presence checks ───────────────────────────────────────────────────
        if (isBlank(firstName)) {
            fail(request, response, "First name is required."); return;
        }
        if (isBlank(lastName)) {
            fail(request, response, "Last name is required."); return;
        }
        if (isBlank(email)) {
            fail(request, response, "Email address is required."); return;
        }
        if (isBlank(birthYearParam)) {
            fail(request, response, "Birth year is required."); return;
        }
        if (isBlank(state)) {
            fail(request, response, "State is required."); return;
        }
        if (isBlank(password)) {
            fail(request, response, "Password is required."); return;
        }
        if (isBlank(confirmPassword)) {
            fail(request, response, "Please confirm your password."); return;
        }

        // ── Password rules ────────────────────────────────────────────────────
        if (password.length() < 8) {
            fail(request, response, "Password must be at least 8 characters."); return;
        }
        if (!password.equals(confirmPassword)) {
            fail(request, response, "Passwords do not match. Please re-enter them."); return;
        }

        // ── Birth year ────────────────────────────────────────────────────────
        int birthYear;
        try {
            birthYear = Integer.parseInt(birthYearParam.trim());
        } catch (NumberFormatException ex) {
            fail(request, response, "Birth year must be a valid number (e.g. 1995)."); return;
        }
        int currentYear = Year.now().getValue();
        if (birthYear < 1900 || birthYear > currentYear) {
            fail(request, response,
                    "Birth year must be between 1900 and " + currentYear + "."); return;
        }
        if (currentYear - birthYear < 18) {
            fail(request, response,
                    "You must be at least 18 years old to register."); return;
        }

        // ── Database ──────────────────────────────────────────────────────────
        EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(getServletContext());
        EntityManager em = emf.createEntityManager();
        try {
            if (userRepository.findByEmail(em, email.trim().toLowerCase()).isPresent()) {
                fail(request, response,
                        "An account with that email address already exists. "
                        + "Try logging in instead."); return;
            }

            em.getTransaction().begin();
            User user = new User();
            user.setFirstName(firstName.trim());
            user.setLastName(lastName.trim());
            user.setEmail(email.trim().toLowerCase());
            user.setPasswordHash(SecurityUtil.hashPassword(password));
            user.setBirthYear(birthYear);
            user.setState(state.trim());
            user.setRole(Role.VOTER);
            user.setEmailVerified(false);
            user.setVerificationCode(SecurityUtil.generateVerificationCode());
            userRepository.save(em, user);
            em.getTransaction().commit();

            // Store for the verify page
            HttpSession session = request.getSession(true);
            session.setAttribute("verificationEmail", user.getEmail());

            // Send verification email
            try {
                EmailService.sendVerificationCode(
                        getServletContext(), user.getEmail(), user.getVerificationCode());
            } catch (MessagingException ex) {
                getServletContext().log(
                        "Could not send verification email to " + user.getEmail(), ex);
                // Account created but email failed — send them to verify page with warning
                response.sendRedirect(
                        request.getContextPath() + "/verify-view?error=email_send_failed");
                return;
            }

            response.sendRedirect(
                    request.getContextPath() + "/verify-view?status=code_sent");

        } catch (Exception ex) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw ex;
        } finally {
            em.close();
        }
    }

    /**
     * Forward back to the register form with an error message set as a request
     * attribute. Using forward (NOT redirect) so ${error} in the JSP is visible.
     */
    private void fail(HttpServletRequest req, HttpServletResponse res, String message)
            throws ServletException, IOException {
        req.setAttribute("error", message);
        req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, res);
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}