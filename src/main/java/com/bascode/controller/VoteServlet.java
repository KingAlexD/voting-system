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

@WebServlet("/cast-vote")
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

        // 2. CAPTURE SELECTION
        String candidateId = request.getParameter("candidateId");
        if (candidateId == null || candidateId.isEmpty()) {
            response.sendRedirect("dashboard.jsp?error=no_selection");
            return;
        }

        /* * 3. DATABASE INTEGRATION 
         * Pull the following from the database via your Database Lead's JPA methods
         */
        String userRole = "CONTESTER"; // Example: A contester is voting
        LocalDate birthDate = LocalDate.of(2000, 1, 1); 
        boolean hasAlreadyVoted = false; 

        // 4. ROLE CHECK: Both Voters and Contesters can vote
        if (!"VOTER".equalsIgnoreCase(userRole) && !"CONTESTER".equalsIgnoreCase(userRole)) {
            response.sendRedirect("dashboard.jsp?error=invalid_role");
            return;
        }

        // 5. AGE CHECK: 18+ to vote
        if (birthDate == null || Period.between(birthDate, LocalDate.now()).getYears() < 18) {
            response.sendRedirect("dashboard.jsp?error=underage");
            return;
        }

        // 6. DUPLICATE VOTE CHECK: Still only ONE vote total
        if (hasAlreadyVoted) {
            response.sendRedirect("dashboard.jsp?error=already_voted");
            return;
        }

        // 7. SUCCESS: Record Vote 
        // Note: We no longer check if userId == candidateId because self-voting is allowed.
        response.sendRedirect("dashboard.jsp?status=success");
        
     // Frontend Lead: Redirect to a 'Success' landing page
        response.sendRedirect(request.getContextPath() + "/vote-success.jsp");
    }
}