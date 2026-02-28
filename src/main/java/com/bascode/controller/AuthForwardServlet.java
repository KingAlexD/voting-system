package com.bascode.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(urlPatterns = {"/login-view", "/register-view", "/verify-view", "/forgot-password-view", "/reset-password-view"})
public class AuthForwardServlet extends HttpServlet {
    
	private static final long serialVersionUID = 1L;

	@Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String path = request.getServletPath();
        String targetJsp;
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
        case "/forgot-password-view":
            targetJsp = "/WEB-INF/views/auth/forgot-password.jsp";
            break;
        case "/reset-password-view":
            targetJsp = "/WEB-INF/views/auth/reset-password.jsp";
            break;
        default:
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }

        request.getRequestDispatcher(targetJsp).forward(request, response);
    }
}
