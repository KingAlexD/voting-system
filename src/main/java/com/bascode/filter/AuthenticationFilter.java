package com.bascode.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

//Annotations to cover all protected areas
@WebFilter(urlPatterns = { "/dashboard.jsp", "/vote.jsp", "/apply-contester.jsp", "/submit-vote", "/register-contester",
		"/admin/*" // Protects all admin-specific pages
})
public class AuthenticationFilter implements Filter {

	@Override
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
			throws IOException, ServletException {

		HttpServletRequest httpRequest = (HttpServletRequest) request;
		HttpServletResponse httpResponse = (HttpServletResponse) response;
		HttpSession session = httpRequest.getSession(false);

		// Check if the user session exists
		boolean isLoggedIn = (session != null && session.getAttribute("userEmail") != null);

		if (isLoggedIn) {
			// User is logged in, let the request proceed
			chain.doFilter(request, response);
		} else {
			// Not logged in, block access and redirect to login
			httpResponse.sendRedirect("login.jsp?error=unauthorized");
		}
	}
}