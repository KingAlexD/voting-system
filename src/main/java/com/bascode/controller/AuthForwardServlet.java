package com.bascode.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(urlPatterns = {"/login-view", "/register-view", "/verify-view", "/dashboard"})
public class AuthForwardServlet extends HttpServlet {
    
	private static final long serialVersionUID = 1L;

	@Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String path = request.getServletPath();
        String targetJsp = "";

        // Security Check: Only allow access to dashboard if a session exists
        if (path.equals("/dashboard")) {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("user") == null) {
                // If not logged in, send them to login
                response.sendRedirect(request.getContextPath() + "/login-view");
                return;
            }
            targetJsp = "/WEB-INF/views/voter/dashboard.jsp";
        } else {
            // Public/Auth Views
            switch (path) {
                case "/login-view":
                    targetJsp = "/WEB-INF/views/auth/login.jsp";
                    break;
                case "/register-view":
                    targetJsp = "/WEB-INF/views/auth/register.jsp";
                    break;
                case "/verify-view":
                    targetJsp = "/WEB-INF/views/auth/verify.jsp";
                    break;
                default:
                    response.sendRedirect(request.getContextPath() + "/index.jsp");
                    return;
            }
        }

        request.getRequestDispatcher(targetJsp).forward(request, response);
    }
}