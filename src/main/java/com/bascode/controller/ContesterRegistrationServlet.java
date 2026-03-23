package com.bascode.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.time.Period;

@WebServlet("/register-contester")
public class ContesterRegistrationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Session Security Check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userEmail") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 2. Capture Candidate Position (e.g., President, Vice President)
        String position = request.getParameter("position");

        /* * 3. DATABASE INTEGRATION 
         * Ask your Database Lead to provide the User's birth date.
         */
        LocalDate birthDate = LocalDate.of(2010, 1, 1); // Placeholder: Replace with user.getBirthDate()

        // 4. THE "BE VOTED FOR" AGE GATE (Requirement: 18+)
        int age = Period.between(birthDate, LocalDate.now()).getYears();

        if (age < 18) {
            // Requirement Met: Decline if they are not 18 or older
            response.sendRedirect("apply-contester.jsp?error=underage_candidate");
            return;
        }

        // 5. THE "MAX 3" CAPACITY GATE
        // This should only count 'APPROVED' contesters
        int approvedCount = 2; // Placeholder: Replace with contesterService.getApprovedCount(position)

        if (approvedCount >= 3) {
            // Requirement Met: Decline if 3 people are already approved for this role
            response.sendRedirect("apply-contester.jsp?error=position_full");
            return;
        }

        // 6. SUCCESS: Proceed with registration
        // contesterService.applyAsCandidate(userEmail, position);
        response.sendRedirect("dashboard.jsp?status=application_sent");
    }
}