package com.bascode.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/admin/approve-contester")
public class AdminApprovalServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Identify the candidate and position
        String contesterId = request.getParameter("contesterId");
        String position = request.getParameter("position");

        // 2. CAPACITY CHECK (The "Rule of 3")
        // int approvedCount = contesterDAO.countApproved(position);
        int approvedCount = 3; // Placeholder for testing

        if (approvedCount >= 3) {
            // Requirement Met: Decline approval if 3 are already approved
            response.sendRedirect("admin-dashboard.jsp?error=position_full");
        } else {
            // 3. Update status to 'APPROVED'
            // contesterDAO.updateStatus(contesterId, "APPROVED");
            response.sendRedirect("admin-dashboard.jsp?status=approved");
        }
    }
}