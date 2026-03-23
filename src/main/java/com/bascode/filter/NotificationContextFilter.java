package com.bascode.filter;

import java.io.IOException;

import com.bascode.repository.NotificationRepository;
import com.bascode.util.ServletUtil;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

@WebFilter(urlPatterns = "/*")
public class NotificationContextFilter implements Filter {
    private final NotificationRepository notificationRepository = new NotificationRepository();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpSession session = httpRequest.getSession(false);
        Long userId = null;
        if (session != null && session.getAttribute("userId") instanceof Long id) {
            userId = id;
        }
        if (userId != null) {
            EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(httpRequest.getServletContext());
            if (emf != null) {
                EntityManager em = emf.createEntityManager();
                try {
                    long unreadCount = notificationRepository.countUnread(em, userId);
                    httpRequest.setAttribute("unreadNotificationCount", unreadCount);
                } finally {
                    em.close();
                }
            }
        }
        chain.doFilter(request, response);
    }
}
