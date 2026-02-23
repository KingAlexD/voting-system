package com.bascode.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

// This maps the servlet to the /login URL
@WebServlet("/login")
public class LoginServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	@Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Authentication: Capture data from the login form [cite: 10, 11]
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // NOTE: You will eventually call your Database Engineer's JPA logic here
        // For now, we are setting up the workflow logic.
        boolean isAuthenticated = true; // Temporary placeholder for DB check

        if (isAuthenticated) {
            // 2. Session Management: Create session (Strictly NO JWT) 
            HttpSession session = request.getSession();
            session.setAttribute("userEmail", email);
            
            // 3. Redirecting: Send them to the voting dashboard [cite: 14]
            response.sendRedirect("dashboard.jsp");
        } else {
            // Redirect back to login with an error if authentication fails
            response.sendRedirect("login.jsp?error=invalid");
        }
    }
}