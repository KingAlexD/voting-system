package com.bascode.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
// Import for BCrypt (Ensure the library is in your pom.xml)
import org.mindrot.jbcrypt.BCrypt; 

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Capture data from the login form
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        /* * 2. SECURITY IMPROVEMENT: Database & jBCrypt Integration
         * Once your Database Engineer provides the UserDAO/Entity:
         * User user = userDAO.findByEmail(email);
         * boolean isAuthenticated = (user != null && BCrypt.checkpw(password, user.getPassword()));
         */
        
        // Temporary logic for testing (Replace with the logic above once JPA is ready)
        boolean isAuthenticated = true; 

        if (isAuthenticated) {
            // 3. SESSION MANAGEMENT (Strictly NO JWT)
            // We use 'true' to ensure a fresh session is created on login
            HttpSession session = request.getSession(true); 
            
            // Store the email (and eventually the Role) in the session
            session.setAttribute("userEmail", email);
            
            // SECURITY BEST PRACTICE: Prevent Session Fixation
            // This generates a new session ID after login
            request.changeSessionId(); 

            // 4. REDIRECTING to the dash board
            response.sendRedirect("dashboard.jsp");
        } else {
            // Redirect back with a specific error code
            response.sendRedirect("login.jsp?error=invalid_credentials");
        }
    }
}