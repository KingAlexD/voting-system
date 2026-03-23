package com.bascode.filter;

import java.io.IOException;

import com.bascode.util.CsrfUtil;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebFilter(urlPatterns = "/*")
public class CsrfFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        if (!"POST".equalsIgnoreCase(httpRequest.getMethod())) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = httpRequest.getSession(false);
        if (session == null) {
            httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "CSRF validation failed.");
            return;
        }
        String expected = (String) session.getAttribute(CsrfUtil.SESSION_KEY);
        String actual = httpRequest.getParameter(CsrfUtil.PARAM);
        if (expected == null || actual == null || !expected.equals(actual)) {
            httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "CSRF validation failed.");
            return;
        }

        chain.doFilter(request, response);
    }
}
