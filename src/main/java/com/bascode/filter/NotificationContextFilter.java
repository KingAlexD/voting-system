package com.bascode.filter;

import java.io.IOException;

import com.bascode.repository.ContactMessageRepository;
import com.bascode.repository.NotificationRepository;
import com.bascode.model.enums.Role;
import com.bascode.util.ServletUtil;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;

@WebFilter(urlPatterns = "/*")
public class NotificationContextFilter implements Filter {
    private final NotificationRepository notificationRepository = new NotificationRepository();
    private final ContactMessageRepository contactMessageRepository = new ContactMessageRepository();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpSession session = httpRequest.getSession(false);

        Long userId = null;
        String userRole = null;
        if (session != null) {
            if (session.getAttribute("userId") instanceof Long id) userId = id;
            if (session.getAttribute("userRole") instanceof String r) userRole = r;
        }

        if (userId != null) {
            EntityManagerFactory emf = ServletUtil.getEntityManagerFactory(httpRequest.getServletContext());
            if (emf != null) {
                EntityManager em = emf.createEntityManager();
                try {
                    long unreadNotifs = notificationRepository.countUnread(em, userId);
                    httpRequest.setAttribute("unreadNotificationCount", unreadNotifs);

                    if ("ADMIN".equals(userRole)) {
            
                        long unreadMsgs = contactMessageRepository.countUnreadForAdmin(em);
                        httpRequest.setAttribute("unreadMessageCount", unreadMsgs);
                    } else {
                        
                        long unreadMsgs = contactMessageRepository.countUnreadForUser(em, userId);
                        httpRequest.setAttribute("unreadMessageCount", unreadMsgs);
                    }
                } finally {
                    em.close();
                }
            }
        }
        chain.doFilter(request, response);
    }
}