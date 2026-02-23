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

@WebServlet("/submit-vote")
public class VoteServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. SESSION VALIDATION
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userEmail") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String userEmail = (String) session.getAttribute("userEmail");
        
        /* * COORDINATION POINT: Replace placeholders below with User object from Database.
         * User user = userService.getUserByEmail(userEmail);
         */
        
        // --- PLACEHOLDERS FOR DATABASE VALUES ---
        String userRole = "VOTER"; // Should come from user.getRole()
        LocalDate birthDate = LocalDate.of(2005, 1, 1); // Should come from user.getBirthDate()
        boolean hasAlreadyVoted = false; // Should come from user.getHasVoted()
        // ----------------------------------------

        // 2. ROLE CHECK: Only 'VOTER' can vote. 'ADMIN' cannot.
        if (!"VOTER".equalsIgnoreCase(userRole)) {
            response.sendRedirect("dashboard.jsp?error=invalid_role");
            return;
        }

        // 3. AGE CHECK: Must be 18+ to participate in voting
        if (birthDate == null || calculateAge(birthDate) < 18) {
            response.sendRedirect("dashboard.jsp?error=underage");
            return;
        }

        // 4. DUPLICATE VOTE CHECK: One Person, One Vote
        if (hasAlreadyVoted) {
            response.sendRedirect("dashboard.jsp?error=already_voted");
            return;
        }

        // 5. CAPTURE CANDIDATE & RECORD VOTE
        String candidateId = request.getParameter("candidateId");
        if (candidateId == null || candidateId.isEmpty()) {
            response.sendRedirect("dashboard.jsp?error=no_selection");
            return;
        }

        /* * FINAL INTEGRATION:
         * votingService.processVote(userEmail, candidateId); 
         * This method should update 'hasVoted' to true and increment candidate count.
         */
        
        response.sendRedirect("dashboard.jsp?status=success");
    }

    // Helper method to calculate age precisely
    private int calculateAge(LocalDate birthDate) {
        return Period.between(birthDate, LocalDate.now()).getYears();
    }
}